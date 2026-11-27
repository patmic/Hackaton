# AIESS: pantera guardiana antiphishing del IESS (todo en el celular)

- Arquitectura: [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md)
- Fase 2 (datos y modelo): `ml/`
- Fase 3 (Flutter): `app/` (pendiente)

## Fase 2: cómo correrla

Pasos 01–03 y la evaluación por reglas: solo usan la librería estándar de Python (corren en este PC).

```powershell
python -I ml/scripts/01_analizar_dataset.py
python -I ml/scripts/02_generar_simulaciones.py
python -I ml/scripts/03_construir_sft.py
python -I ml/scripts/05_evaluar.py --backend reglas
```

Pasos 04–06 (fine-tuning y GGUF): necesitan una GPU NVIDIA. Hay dos opciones:

1. **Google Colab** (T4 gratis o L4): subir la carpeta `iesston/`, luego
   `pip install -r ml/requirements-train.txt` y correr:
   ```
   python ml/scripts/04_finetune_lora.py --qlora          # en T4
   python ml/scripts/06_exportar_gguf.py --corrida ml/outputs/lfm2-1.2b-qlora
   python ml/scripts/05_evaluar.py --backend gguf --modelo ml/outputs/gguf/aiess-lfm2-1.2b-Q4_K_M.gguf
   ```
2. **Docker con GPU**: ver el encabezado de `ml/Dockerfile`.

Para gama baja o el análisis en segundo plano: `--modelo LiquidAI/LFM2-350M`.

Licencia: los pesos de LFM2 usan la *LFM Open License v1.0*. Revisar sus condiciones de uso comercial antes de publicar.
