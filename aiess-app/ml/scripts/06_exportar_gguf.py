"""Fase 2.6 - Fusion LoRA -> modelo completo -> GGUF -> cuantizacion para el celular.

  python ml/scripts/06_exportar_gguf.py --corrida ml/outputs/lfm2-1.2b-lora
  python ml/scripts/06_exportar_gguf.py --corrida ml/outputs/lfm2-1.2b-lora --llama-cpp /opt/llama.cpp

Cuantizaciones generadas (llama.cpp):
  Q4_K_M  -> la que va a la app (equilibrio tamano/calidad)
  Q8_0    -> referencia de calidad para comparar en 05_evaluar.py
Salida: ml/outputs/gguf/*.gguf + manifest.json (sha256, tamano) que la app usa para verificar la descarga.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from aiess_ml import config  # noqa: E402
from aiess_ml.prompts import SYSTEM_PROMPT  # noqa: E402

LLAMA_CPP_REPO = "https://github.com/ggml-org/llama.cpp"


def sh(cmd: list[str], **kw) -> None:
    print("$", " ".join(map(str, cmd)))
    subprocess.run(list(map(str, cmd)), check=True, **kw)


def fusionar(corrida: Path) -> Path:
    import torch
    from peft import PeftModel
    from transformers import AutoModelForCausalLM, AutoTokenizer
    meta = json.loads((corrida / "entrenamiento.json").read_text(encoding="utf-8"))
    destino = corrida / "merged"
    # Siempre se fusiona sobre el modelo base en precision completa (no en 4-bit), tambien si se entreno con QLoRA.
    base = AutoModelForCausalLM.from_pretrained(meta["modelo_base"], dtype=torch.bfloat16, device_map="cpu")
    model = PeftModel.from_pretrained(base, corrida / "adapter").merge_and_unload()
    model.save_pretrained(destino, safe_serialization=True)
    AutoTokenizer.from_pretrained(corrida / "adapter").save_pretrained(destino)
    print(f"Modelo fusionado en {destino}")
    return destino


def preparar_llama_cpp(ruta: Path) -> tuple[Path, Path]:
    if not (ruta / "convert_hf_to_gguf.py").exists():
        sh(["git", "clone", "--depth", "1", LLAMA_CPP_REPO, ruta])
        sh([sys.executable, "-m", "pip", "install", "-r", ruta / "requirements" / "requirements-convert_hf_to_gguf.txt"])
    quant = next((p for p in [ruta / "build" / "bin" / "llama-quantize", ruta / "build" / "bin" / "llama-quantize.exe",
                              ruta / "build" / "bin" / "Release" / "llama-quantize.exe"] if p.exists()), None)
    if quant is None:
        sh(["cmake", "-B", ruta / "build", "-S", ruta, "-DLLAMA_CURL=OFF"])
        sh(["cmake", "--build", ruta / "build", "--config", "Release", "-j", "--target", "llama-quantize"])
        return preparar_llama_cpp(ruta)
    return ruta / "convert_hf_to_gguf.py", quant


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for bloque in iter(lambda: f.read(1 << 20), b""):
            h.update(bloque)
    return h.hexdigest()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--corrida", type=Path, required=True, help="carpeta de salida de 04_finetune_lora.py")
    ap.add_argument("--llama-cpp", type=Path, default=config.OUTPUTS_DIR / "llama.cpp")
    ap.add_argument("--quants", nargs="+", default=["Q4_K_M", "Q8_0"])
    args = ap.parse_args()

    merged = args.corrida / "merged"
    if not (merged / "config.json").exists():
        merged = fusionar(args.corrida)
    convert, quantize = preparar_llama_cpp(args.llama_cpp)

    out = config.OUTPUTS_DIR / "gguf"
    out.mkdir(parents=True, exist_ok=True)
    base = "aiess-" + args.corrida.name.replace("-qlora", "").replace("-lora", "")
    f16 = out / f"{base}-F16.gguf"
    sh([sys.executable, convert, merged, "--outfile", f16, "--outtype", "f16"])

    manifest = {"modelo": base, "system_prompt": SYSTEM_PROMPT, "n_ctx_recomendado": 2048,
                "muestreo": {"analisis": {"temperature": 0.0}, "chat": {"temperature": 0.3, "min_p": 0.15,
                                                                         "repeat_penalty": 1.05}},
                "archivos": []}
    for q in args.quants:
        destino = out / f"{base}-{q}.gguf"
        sh([quantize, f16, destino, q])
        manifest["archivos"].append({"quant": q, "archivo": destino.name, "bytes": destino.stat().st_size,
                                     "sha256": sha256(destino)})
    f16.unlink(missing_ok=True)
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    for a in manifest["archivos"]:
        print(f"{a['archivo']}: {a['bytes'] / 1e6:.0f} MB")
    print("Siguiente: python ml/scripts/05_evaluar.py --backend gguf --modelo", out / f"{base}-Q4_K_M.gguf")
    if shutil.which("adb"):
        print("Prueba rapida en un Android conectado: adb push", out / f"{base}-Q4_K_M.gguf", "/sdcard/Download/")


if __name__ == "__main__":
    main()
