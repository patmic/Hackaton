"""Levanta SellaCorreo en un paso, desde cualquier carpeta (solo biblioteca estándar).

    python scripts/levantar.py            # crea .env si falta, construye y espera
    python scripts/levantar.py --detener
"""
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def fail(msg):
    print(f"\n[ERROR] {msg}")
    sys.exit(1)


def run(cmd):
    print("\n> " + " ".join(cmd))
    if subprocess.call(cmd, cwd=ROOT) != 0:
        fail("falló: " + " ".join(cmd))


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="replace")
    if shutil.which("docker") is None:
        fail("Docker no está instalado o no está en el PATH.")
    if subprocess.call(["docker", "info"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
        fail("Docker no responde. Abra Docker Desktop y espere a que diga 'Engine running'.")
    compose = ["docker", "compose", "--project-directory", str(ROOT)]
    if "--detener" in sys.argv:
        return run(compose + ["down"])
    if not (ROOT / ".env").exists():
        run([sys.executable, str(ROOT / "scripts" / "init_env.py")])
    run(compose + ["up", "--build", "-d", "--wait", "--wait-timeout", "300"])
    for _ in range(30):
        try:
            urllib.request.urlopen("http://localhost:8090/health", timeout=2)
            break
        except Exception:  # noqa: BLE001
            time.sleep(1)
    print("\nSellaCorreo listo:  http://localhost:8090")
    print("  Login:   http://localhost:8090/login   (usuarios en SELLACORREO_USUARIO_* de .env)")
    print("  GenKey:  http://localhost:8090/genkey")
    print("  CheckIn: http://localhost:8090/checkin")


if __name__ == "__main__":
    main()
