# SellaCorreo · sitio web completo en un solo contenedor (puerto 8090)
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PYTHONPATH=/app \
    SELLACORREO_DB_PATH=/data/sellacorreo.db SELLACORREO_KEY_PATH=/data/ed25519.pem
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY common/autenticidad ./autenticidad
COPY sellacorreo ./sellacorreo
RUN useradd -r -u 10005 sella && mkdir -p /data && chown sella /data
USER sella
VOLUME ["/data"]
EXPOSE 8090
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --start-interval=2s --retries=5 \
  CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8090/health')"
CMD ["uvicorn", "sellacorreo.main:app", "--host", "0.0.0.0", "--port", "8090"]
