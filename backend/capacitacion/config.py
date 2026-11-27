"""Configuración de la API de Capacitación.

Se lee de variables de entorno con valores por defecto seguros para la demo.
El valor por defecto de `ENVIO_MODO` es `consola`: **no** envía correos, solo los
escribe como archivos `.eml`. Enviar de verdad requiere configurarlo a propósito.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from datetime import timedelta
from pathlib import Path

# Raíz del repositorio: backend/capacitacion/config.py -> parents[2]
RAIZ_REPO = Path(__file__).resolve().parents[2]


def _bool_env(nombre: str, por_defecto: bool) -> bool:
    valor = os.environ.get(nombre)
    if valor is None:
        return por_defecto
    return valor.strip().lower() in {"1", "true", "si", "sí", "yes", "on"}


@dataclass(frozen=True)
class Config:
    # --- Entorno y ventana de reacción (CLAUDE.md §11: 10 min demo, 48 h prod) ---
    entorno: str = os.environ.get("ENTORNO", "demo").strip().lower()

    # --- Envío ---
    # consola | mailpit | resend | brevo
    envio_modo: str = os.environ.get("ENVIO_MODO", "consola").strip().lower()
    resend_api_key: str | None = os.environ.get("RESEND_API_KEY")
    brevo_api_key: str | None = os.environ.get("BREVO_API_KEY")
    mailpit_host: str = os.environ.get("MAILPIT_HOST", "127.0.0.1")
    mailpit_port: int = int(os.environ.get("MAILPIT_PORT", "1025"))
    # Carpeta donde el modo `consola` escribe los .eml generados.
    salida_dir: Path = field(
        default_factory=lambda: Path(
            os.environ.get(
                "SALIDA_DIR",
                str(Path(__file__).resolve().parent / "salida"),
            )
        )
    )

    # --- Dominio de práctica (regla 5: NUNCA iess.gob.ec) ---
    # Dominio propio, verificado con SPF/DKIM, desde el que se envía de verdad.
    dominio_practica: str = os.environ.get(
        "DOMINIO_PRACTICA", "escuela-antiphishing.ec"
    ).strip().lower()
    # Buzón de reportes del dominio de práctica (reenviar aquí = reportar).
    buzon_reportes: str = os.environ.get(
        "BUZON_REPORTES", "reportes@escuela-antiphishing.ec"
    ).strip().lower()

    # --- URL pública de la plataforma (páginas /p/{token}) ---
    base_url: str = os.environ.get("BASE_URL", "http://localhost:8080").rstrip("/")

    # --- Seudonimización (LOPDP, regla 3) ---
    secreto_seudonimo: str = os.environ.get(
        "SECRETO_SEUDONIMO", "dev-insegura-cambiar-en-produccion"
    )

    # --- Núcleo central (Bloque 3). Si está vacío, los eventos solo se guardan. ---
    nucleo_url: str | None = (os.environ.get("NUCLEO_URL") or "").rstrip("/") or None

    # --- Scheduler de simulaciones vencidas (segundos; 0 = desactivado) ---
    procesar_vencidas_seg: int = int(os.environ.get("PROCESAR_VENCIDAS_SEG", "60"))

    # --- Origen de datos ---
    tipologias_json: Path = field(
        default_factory=lambda: Path(
            os.environ.get(
                "TIPOLOGIAS_JSON",
                str(RAIZ_REPO / "tipologias-correo" / "tipologias.json"),
            )
        )
    )

    # --- CORS para la app Flutter web ---
    cors_origenes: tuple[str, ...] = tuple(
        o.strip()
        for o in os.environ.get("CORS_ORIGENES", "*").split(",")
        if o.strip()
    )

    @property
    def es_demo(self) -> bool:
        return self.entorno != "produccion"

    @property
    def ventana_reaccion(self) -> timedelta:
        # Demo: 10 min para ver el ciclo completo. Producción: 48 h.
        return timedelta(minutes=10) if self.es_demo else timedelta(hours=48)

    @property
    def envia_de_verdad(self) -> bool:
        return self.envio_modo in {"mailpit", "resend", "brevo"}

    def validar(self) -> list[str]:
        """Devuelve advertencias (no lanza), para mostrarlas al arrancar."""
        avisos: list[str] = []
        if self.dominio_practica.endswith("iess.gob.ec"):
            raise RuntimeError(
                "DOMINIO_PRACTICA no puede ser iess.gob.ec (regla 5 de CLAUDE.md)."
            )
        if self.secreto_seudonimo == "dev-insegura-cambiar-en-produccion":
            avisos.append(
                "SECRETO_SEUDONIMO usa el valor de desarrollo; cámbialo antes de "
                "cualquier uso real."
            )
        if self.envia_de_verdad and not self.es_demo:
            avisos.append(
                "Envío real activado en entorno de producción: confirma que el "
                "grupo dio consentimiento y que el dominio tiene SPF/DKIM."
            )
        if self.envio_modo == "resend" and not self.resend_api_key:
            avisos.append("ENVIO_MODO=resend pero falta RESEND_API_KEY.")
        if self.envio_modo == "brevo" and not self.brevo_api_key:
            avisos.append("ENVIO_MODO=brevo pero falta BREVO_API_KEY.")
        return avisos


config = Config()
