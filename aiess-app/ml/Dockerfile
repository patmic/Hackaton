# Entorno de entrenamiento/exportacion de AIESS (NO es lo que corre en el celular).
# Build:  docker build -t aiess-ml -f ml/Dockerfile .
# Run:    docker run --gpus all -it --rm -v ${PWD}:/work -v ${PWD}/datos:/datos:ro \
#           -e AIESS_CSV=/datos/dataset_entrenamiento_IESS_1000.csv aiess-ml
# Requiere Docker Desktop con WSL2 + GPU NVIDIA. Sin GPU, entrenar en Google Colab.
FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel

RUN apt-get update && apt-get install -y --no-install-recommends git cmake build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY ml/requirements-train.txt /tmp/req.txt
RUN pip install --no-cache-dir -r /tmp/req.txt

ENV HF_HOME=/work/ml/outputs/hf_cache PYTHONUTF8=1
CMD ["bash", "-lc", "python ml/scripts/01_analizar_dataset.py && python ml/scripts/02_generar_simulaciones.py && python ml/scripts/03_construir_sft.py && python ml/scripts/04_finetune_lora.py && python ml/scripts/06_exportar_gguf.py --corrida ml/outputs/lfm2-1.2b-lora && python ml/scripts/05_evaluar.py --backend gguf --modelo ml/outputs/gguf/aiess-lfm2-1.2b-Q4_K_M.gguf"]
