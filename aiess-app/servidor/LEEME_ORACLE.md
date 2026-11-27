# Servidor de IA de AIESS en Oracle Cloud (OCI)

Un solo servidor publica **la web** y **la API del modelo** en la misma dirección.
La app Android se conecta a esa dirección (Ajustes › Inteligencia del cóndor).

## 1. Crear la instancia (gratis)
- Imagen: **Ubuntu 24.04**. Forma: **VM.Standard.A1.Flex** (Ampere ARM), 4 OCPU y 24 GB (Always Free).
- Disco: 50 GB es suficiente.

## 2. Abrir puertos 80 y 443
- **Red virtual › Lista de seguridad › Reglas de entrada:** TCP 80 y 443 desde 0.0.0.0/0.
- **Dentro de la VM** (Ubuntu en OCI bloquea por iptables):
  ```bash
  sudo iptables -I INPUT 6 -p tcp --dport 80 -j ACCEPT
  sudo iptables -I INPUT 6 -p tcp --dport 443 -j ACCEPT
  sudo netfilter-persistent save
  ```

## 3. Instalar Docker
```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker
```

## 4. Subir los archivos (desde tu PC)
```bash
scp -r servidor ubuntu@IP_DEL_SERVIDOR:~/aiess
scp modelos/aiess-lfm2-1.2b-Q4_K_M.gguf ubuntu@IP_DEL_SERVIDOR:~/aiess/modelos/
scp -r app/build/web ubuntu@IP_DEL_SERVIDOR:~/aiess/web
```

## 5. Arrancar
```bash
cd ~/aiess
cp .env.ejemplo .env      # pon AIESS_CLAVE; con dominio: DOMINIO=ia.tudominio.com (HTTPS automático)
docker compose up -d
curl http://localhost/health   # {"status":"ok"}
```
- Web: `http://IP_DEL_SERVIDOR` (o `https://ia.tudominio.com`).
- App: en Ajustes pon esa misma dirección y toca "Guardar y probar conexión".

## Clave del servidor (secreto)
- En el servidor, `.env` lleva `AIESS_CLAVE=` (una clave larga). Sin ella el modelo responde 401.
- En tu PC, `app/secretos.json` (copia de `secretos.ejemplo.json`) lleva la dirección y la misma clave.
  Compila con `flutter build apk --dart-define-from-file=secretos.json` (igual para `flutter build web`).
- `.env` y `secretos.json` están en `.gitignore`: nunca se suben al repositorio.
- Caddy sirve la web como archivos estáticos y solo pasa al modelo `/completion`, `/health` y `/v1/*`.
- Ojo: en la web la clave queda dentro del JavaScript y alguien con conocimientos puede verla.
  Si eso importa, cámbiala de vez en cuando o limita el número de solicitudes en Caddy.

## Privacidad (lo que el servidor hace y no hace)
- El texto del correo llega solo para analizarlo y se procesa **en memoria**.
- **No se guarda en disco ni en registros:** llama-server sin `--log-prompts-dir`, sin el endpoint `/slots`
  (`--no-slots`), y Caddy descarta el log de solicitudes.
- La memoria temporal se **reemplaza** con la siguiente revisión y se borra al reiniciar el servidor.
- Los correos **no se usan para entrenar** el modelo.
- Usa **HTTPS** (con dominio) para que el texto viaje cifrado.

## Tiempos de referencia
Modelo LFM2 1.2B Q4_K_M, respuesta completa en JSON:
- Laptop i5-1135G7 (4 hilos): 12–21 s en total; el veredicto llega en streaming en ~5–7 s.
- Celular (modelo local): ~30 s.
- OCI Ampere A1 4 OCPU: tiempos parecidos a la laptop; con más OCPU baja proporcionalmente.
