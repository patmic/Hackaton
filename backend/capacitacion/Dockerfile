# API de Capacitación · Escudo Cognitivo IESS (puerto 8080)
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PYTHONPATH=/app
WORKDIR /app
COPY backend/capacitacion/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/capacitacion ./backend/capacitacion
COPY tipologias-correo ./tipologias-correo
COPY Analisis-de-comportamiento/datos ./Analisis-de-comportamiento/datos
RUN useradd -r -u 10006 cap && mkdir -p /data/salida && chown -R cap /data
USER cap
ENV SALIDA_DIR=/data/salida
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8080/salud')"
CMD ["uvicorn", "backend.capacitacion.main:app", "--host", "0.0.0.0", "--port", "8080"]
