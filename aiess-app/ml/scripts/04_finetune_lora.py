"""Fase 2.4 - Fine-tuning LoRA / QLoRA de Liquid AI LFM2 con TRL.

Requiere GPU NVIDIA (Colab T4/L4/A100, o el contenedor ml/Dockerfile con --gpus all).
  pip install -r ml/requirements-train.txt
  python ml/scripts/04_finetune_lora.py                       # LoRA bf16/fp16
  python ml/scripts/04_finetune_lora.py --qlora               # QLoRA 4-bit (GPU de 8-16 GB)
  python ml/scripts/04_finetune_lora.py --modelo LiquidAI/LFM2-350M   # gama baja / segundo plano
Salida: ml/outputs/<nombre>/adapter  (+ config del entrenamiento)
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--modelo", default=config.BASE_MODEL)
    ap.add_argument("--qlora", action="store_true", help="carga el modelo base en 4-bit (bitsandbytes)")
    ap.add_argument("--epocas", type=float, default=2.0)
    ap.add_argument("--lr", type=float, default=2e-4)
    ap.add_argument("--rank", type=int, default=16)
    ap.add_argument("--batch", type=int, default=4)
    ap.add_argument("--acum", type=int, default=4)
    ap.add_argument("--max-len", type=int, default=1536)
    ap.add_argument("--salida", type=Path, default=None)
    args = ap.parse_args()

    import torch
    from datasets import load_dataset
    from peft import LoraConfig, prepare_model_for_kbit_training
    from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
    from trl import SFTConfig, SFTTrainer

    if not torch.cuda.is_available():
        sys.exit("No hay GPU CUDA. Usa Colab o el contenedor con --gpus all (en CPU tardaria dias).")
    bf16 = torch.cuda.is_bf16_supported()
    dtype = torch.bfloat16 if bf16 else torch.float16
    nombre = args.modelo.split("/")[-1].lower() + ("-qlora" if args.qlora else "-lora")
    salida = args.salida or (config.OUTPUTS_DIR / nombre)

    sft = config.DATA_DIR / "sft"
    ds = load_dataset("json", data_files={"train": str(sft / "train.jsonl"), "validation": str(sft / "val.jsonl")})
    ds = ds.remove_columns([c for c in ("id", "tarea") if c in ds["train"].column_names])

    tok = AutoTokenizer.from_pretrained(args.modelo)
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token

    quant = None
    if args.qlora:
        quant = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4",
                                   bnb_4bit_compute_dtype=dtype, bnb_4bit_use_double_quant=True)
    model = AutoModelForCausalLM.from_pretrained(args.modelo, dtype=dtype, quantization_config=quant,
                                                 device_map={"": 0}, attn_implementation="sdpa")
    if args.qlora:
        model = prepare_model_for_kbit_training(model, use_gradient_checkpointing=True)

    # "all-linear" cubre proyecciones de atencion, convoluciones cortas (in_proj/out_proj) y MLP (w1,w2,w3) de LFM2.
    lora = LoraConfig(r=args.rank, lora_alpha=2 * args.rank, lora_dropout=0.05, bias="none",
                      target_modules="all-linear", task_type="CAUSAL_LM")

    cfg = SFTConfig(
        output_dir=str(salida / "checkpoints"),
        num_train_epochs=args.epocas,
        per_device_train_batch_size=args.batch,
        per_device_eval_batch_size=args.batch,
        gradient_accumulation_steps=args.acum,
        learning_rate=args.lr,
        lr_scheduler_type="cosine",
        warmup_ratio=0.05,
        weight_decay=0.0,
        max_length=args.max_len,
        completion_only_loss=True,      # la pérdida solo se calcula sobre la respuesta del robot
        packing=False,
        gradient_checkpointing=True,
        bf16=bf16, fp16=not bf16,
        logging_steps=10,
        eval_strategy="steps", eval_steps=50,
        save_strategy="steps", save_steps=50, save_total_limit=2,
        load_best_model_at_end=True, metric_for_best_model="eval_loss",
        report_to="none",
        seed=config.SEED,
    )
    trainer = SFTTrainer(model=model, args=cfg, train_dataset=ds["train"], eval_dataset=ds["validation"],
                         processing_class=tok, peft_config=lora)
    trainer.model.print_trainable_parameters()
    trainer.train()

    (salida / "adapter").mkdir(parents=True, exist_ok=True)
    trainer.model.save_pretrained(salida / "adapter")
    tok.save_pretrained(salida / "adapter")
    meta = {"modelo_base": args.modelo, "qlora": args.qlora, "rank": args.rank, "epocas": args.epocas,
            "lr": args.lr, "max_len": args.max_len, "metricas_finales": trainer.evaluate()}
    (salida / "entrenamiento.json").write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")
    print(f"Adaptador LoRA guardado en {salida / 'adapter'}")


if __name__ == "__main__":
    main()
