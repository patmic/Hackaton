"""Prueba de punta a punta contra el contenedor (docker compose up). Se omite si no responde."""
import os
import re
from pathlib import Path

import httpx
import pytest

URL = os.environ.get("E2E_SELLACORREO_URL", "http://localhost:8090")


def _up():
    try:
        return httpx.get(f"{URL}/health", timeout=2).status_code == 200
    except httpx.HTTPError:
        return False


pytestmark = [pytest.mark.e2e, pytest.mark.skipif(not _up(), reason="SellaCorreo no está levantado en :8090")]


def _user():
    env = Path(__file__).resolve().parent.parent / ".env"
    vals = dict(l.split("=", 1) for l in env.read_text(encoding="utf-8").splitlines() if "=" in l and not l.startswith("#"))
    if "SELLACORREO_USUARIO_1" not in vals:
        pytest.skip("sin SELLACORREO_USUARIO_1 en .env")
    p = vals["SELLACORREO_USUARIO_1"].split("|")
    return p[3], p[4] or vals.get("SELLACORREO_DEMO_PASSWORD", "")


def test_e2e_login_genkey_checkin():
    usuario, clave = _user()
    with httpx.Client(base_url=URL, follow_redirects=True) as c:
        assert c.post("/login", data={"usuario": usuario, "clave": clave}).url.path == "/genkey"
        csrf = re.search(r'name="csrf" value="([0-9a-f]+)"', c.get("/genkey").text).group(1)
        r = c.post("/genkey", data={"csrf": csrf, "taxonomia": "comunicacional",
                                    "asunto": "Comunicado: prueba e2e", "destinatario": ""})
        link = re.search(r'id="enlace" readonly value="([^"]+)"', r.text).group(1)
    path = link.replace("http://localhost:8090", URL)
    valido = httpx.get(path).text  # el emisor se verifica solo con el hash: resultado directo
    assert "Correo válido y seguro" in valido and "Falta un paso" not in valido
    token, h16 = link.rsplit("/", 1)[1].split(".")
    malo = httpx.get(f"{URL}/checkin/{token}.{'0' * 16 if h16 != '0' * 16 else '1' * 16}").text
    assert "Correo falso" in malo
