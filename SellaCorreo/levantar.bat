@echo off
REM Levanta el stack completo. Funciona con doble clic o desde cualquier carpeta.
setlocal
cd /d "%~dp0"
where py >nul 2>nul
if %errorlevel%==0 (
  py -3 scripts\levantar.py %*
) else (
  python scripts\levantar.py %*
)
if errorlevel 1 (
  echo.
  echo No se pudo levantar el stack. Revise el mensaje de arriba.
)
pause
