@echo off
REM Servidor de IA de AIESS en Windows (sin Docker): modelo + web en http://localhost:8080
REM Requiere bin\ (llama.cpp para Windows), modelos\aiess-lfm2-1.2b-Q4_K_M.gguf y web\ (app\build\web).
cd /d "%~dp0"
echo AIESS: iniciando el servidor de IA en http://localhost:8080 ...
echo Los correos se analizan en memoria y no se guardan.
bin\llama-server.exe -m modelos\aiess-lfm2-1.2b-Q4_K_M.gguf --host 0.0.0.0 --port 8080 -c 4096 -np 2 -t 4 --cache-reuse 256 --no-slots --path web
pause
