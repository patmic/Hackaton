# Servidor de IA de AIESS en Oracle Cloud (OCI)

Un solo servidor publica **la web** y **la API del modelo** en la misma dirección.
La app Android se conecta a esa dirección (Ajustes › Inteligencia de AIESS).

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

## 4. Compilar la web para el servidor
La web usa la misma dirección desde la que se abre (Caddy pasa la API al modelo), así que se compila sin URL fija:
```bash
cd app
flutter build web --release --no-web-resources-cdn --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=
```
Para probarla en tu PC igual que en el servidor: `python servidor/servir_web_local.py app/build/web 8090 http://127.0.0.1:8080`
y abre http://127.0.0.1:8090.

## 5. Subir los archivos (desde tu PC)
```bash
scp -r servidor ubuntu@IP_DEL_SERVIDOR:~/aiess
scp modelos/aiess-lfm2-1.2b-Q4_K_M.gguf ubuntu@IP_DEL_SERVIDOR:~/aiess/modelos/
scp -r app/build/web ubuntu@IP_DEL_SERVIDOR:~/aiess/web
```

## 6. Arrancar
```bash
cd ~/aiess
cp .env.ejemplo .env      # pon AIESS_CLAVE; con dominio: DOMINIO=ia.tudominio.com (HTTPS automático)
docker compose up -d
curl http://localhost/health   # {"status":"ok"}
```
- Web: `http://IP_DEL_SERVIDOR` (o `https://ia.tudominio.com`).
- App: en Ajustes pon esa misma dirección y toca "Guardar y probar conexión".

## Sin exponer la IP: Cloudflare Tunnel (recomendado)
El servidor se conecta hacia Cloudflare y la gente entra por un dominio con HTTPS gratis.
La IP real no aparece y no hay que abrir ningún puerto.

1. En `.env`: `PUERTO_HTTP=127.0.0.1:8090` y `PUERTO_HTTPS=127.0.0.1:8443` (solo escucha dentro del servidor).
   `docker compose up -d`.
2. Si el servidor no tiene túnel: instala `cloudflared` y crea uno en Cloudflare Zero Trust
   (Networks › Tunnels › Create a tunnel) siguiendo el comando que te da el panel.
3. En el túnel: **Public Hostname › Add**: subdominio (por ejemplo `aiess`), tu dominio,
   y en Service URL `http://localhost:8090`. Cloudflare crea el DNS solo.
4. Compila la app con esa dirección (no con la IP):
   `flutter build apk --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=https://aiess.tudominio.com`
   La web no hace falta recompilarla: usa la dirección desde la que se abre.

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
- **Anonimización en el dispositivo:** antes de enviar, la app tapa nombre, cédula, RUC, teléfonos, tarjetas,
  cuentas bancarias y la parte personal de los correos (`[NOMBRE]`, `[CÉDULA]`…). Solo viajan las señales del engaño.
- Los correos **no se usan para entrenar** el modelo.
- Usa **HTTPS** (con dominio) para que el texto viaje cifrado.

## Tiempos de referencia
Modelo LFM2 1.2B Q4_K_M, respuesta completa en JSON:
- Laptop i5-1135G7 (4 hilos): 12–21 s en total; el veredicto llega en streaming en ~5–7 s.
- Celular (modelo local): ~30 s.
- OCI Ampere A1 4 OCPU: tiempos parecidos a la laptop; con más OCPU baja proporcionalmente.
