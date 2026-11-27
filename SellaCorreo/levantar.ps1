# Levanta el stack completo desde cualquier carpeta:
#   powershell -ExecutionPolicy Bypass -File C:\ruta\SellaCorreo\levantar.ps1
Set-Location -Path $PSScriptRoot
if (Get-Command py -ErrorAction SilentlyContinue) { py -3 scripts\levantar.py @args }
else { python scripts\levantar.py @args }
exit $LASTEXITCODE
