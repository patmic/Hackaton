@echo off
REM ============================================================================
REM  AIESS con IA LOCAL en esta computadora (requisito del reto: el modelo corre
REM  en el equipo y el correo no sale). Sin Docker y sin internet para analizar.
REM
REM  Necesita, junto a este archivo:
REM    bin\      llama.cpp para Windows (llama-server.exe)
REM    modelos\  aiess-lfm2-1.2b-Q4_K_M.gguf  (LFM2 1.2B afinado para el IESS)
REM    web\      la web compilada:  flutter build web --release --no-web-resources-cdn
REM              --dart-define-from-file=secretos.json --dart-define=AIESS_SERVIDOR=
REM
REM  Escucha SOLO en esta PC (127.0.0.1): nadie más puede usarlo.
REM ============================================================================
cd /d "%~dp0"
if not exist bin\llama-server.exe (echo Falta bin\llama-server.exe & pause & exit /b 1)
if not exist modelos\aiess-lfm2-1.2b-Q4_K_M.gguf (echo Falta el modelo en modelos\ & pause & exit /b 1)
if not exist web\index.html (echo Falta la web compilada en web\ & pause & exit /b 1)

echo AIESS: iniciando la IA local en http://localhost:8090 ...
echo Los correos se analizan en esta computadora, en memoria, y no se guardan.
start "AIESS - IA local" /min bin\llama-server.exe -m modelos\aiess-lfm2-1.2b-Q4_K_M.gguf ^
  --host 127.0.0.1 --port 8090 -c 4096 -np 2 -t 4 --cache-reuse 256 --no-slots --path web
timeout /t 8 /nobreak >nul
start "" http://localhost:8090
echo Listo. Para apagar AIESS, cierra la ventana "AIESS - IA local".
pause
