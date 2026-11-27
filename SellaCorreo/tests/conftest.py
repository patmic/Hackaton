import os
import sys
import tempfile
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
# El observador del Observatorio vive en ../Analisis-de-comportamiento (en Docker se copia a /app).
sys.path[:0] = [str(ROOT), str(ROOT / "common"), str(ROOT.parent / "Analisis-de-comportamiento")]
_tmp = Path(tempfile.mkdtemp(prefix="sellacorreo-tests-"))
TEST_ENV = {
    "SELLACORREO_DB_PATH": str(_tmp / "sellacorreo.db"),
    "SELLACORREO_KEY_PATH": str(_tmp / "ed25519.pem"),
    "SELLACORREO_SESSION_KEY": "test-session-key-000000000000000000000",
    "SELLACORREO_HMAC_KEY": "test-hmac-key-0000000000000000000000000",
    "SELLACORREO_USUARIO_1": "iess.comunicacion|Dirección de Comunicación|Comunicación Social|comunicacion@demo.institucion.test|clave-prueba-1",
    "SELLACORREO_USUARIO_2": "iess.afiliacion|Dirección de Afiliación|Afiliación|afiliacion@demo.institucion.test|clave-prueba-2",
    "SELLACORREO_USUARIO_3": "iess.admin|Administración|Subdirección de Tecnología|admin@demo.institucion.test|",
    "SELLACORREO_DEMO": "true",
    "SELLACORREO_DEMO_PASSWORD": "Demo2026",
    "SELLACORREO_TAXONOMIAS": "comunicacional,informativo,recordatorio,campaña",
    "SELLACORREO_RATE_LIMIT_PER_MIN": "1000",
    "SELLACORREO_LOGIN_LIMIT_PER_MIN": "1000",
    "SELLACORREO_OBSERVATORIO_LIMIT_PER_MIN": "1000",
    "SELLACORREO_OBSERVATORIO_PERSONAS": "200",
}
os.environ.update(TEST_ENV)

from fastapi.testclient import TestClient  # noqa: E402

from sellacorreo.main import app  # noqa: E402

USER, PASS = "iess.comunicacion", "clave-prueba-1"


@pytest.fixture(scope="session")
def _app_started():
    with TestClient(app) as c:
        yield c


@pytest.fixture()
def anon(_app_started):
    return TestClient(app, base_url="http://localhost:8090")


@pytest.fixture()
def staff(_app_started):
    c = TestClient(app, base_url="http://localhost:8090")
    r = c.post("/login", data={"usuario": USER, "clave": PASS}, follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"] == "/genkey"
    return c
