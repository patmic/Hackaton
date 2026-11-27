"""Crea .env a partir de .env.example con claves y contraseñas aleatorias.

Uso:  python scripts/init_env.py           (no sobrescribe un .env existente)
      python scripts/init_env.py --force
Las cuentas de demostración usan SELLACORREO_DEMO_PASSWORD (se muestra en el login).
"""
import secrets
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
example, target = root / ".env.example", root / ".env"
if not example.exists() or not (root / "docker-compose.yml").exists():
    sys.exit(f"[ERROR] No encuentro .env.example ni docker-compose.yml en {root}.\n"
             "Este script debe quedarse en la carpeta SellaCorreo/scripts.")
if target.exists() and "--force" not in sys.argv:
    sys.exit(".env ya existe; use --force para regenerarlo")

lines, users = [], []
for line in example.read_text(encoding="utf-8").splitlines():
    if line.startswith("SELLACORREO_USUARIO_") and "CAMBIAR" in line:
        key, value = line.split("=", 1)
        parts = value.split("|")
        parts[-1] = "Demo-" + secrets.token_urlsafe(9)
        users.append((parts[0], parts[-1]))
        line = f"{key}={'|'.join(parts)}"
    elif "=" in line and not line.startswith("#") and "CAMBIAR" in line:
        key, value = line.split("=", 1)
        line = f"{key}={value.split('CAMBIAR')[0]}{secrets.token_urlsafe(32)}"
    lines.append(line)
target.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Creado {target}")
env = dict(l.split("=", 1) for l in lines if "=" in l and not l.startswith("#"))
demo = env.get("SELLACORREO_DEMO_PASSWORD", "")
for k in sorted(k for k in env if k.startswith("SELLACORREO_USUARIO_")):
    parts = env[k].split("|")
    print(f"  {parts[3]:<38} contraseña: {parts[4] or demo}")
