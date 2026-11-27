"""Catálogo de plantillas de correo de prueba.

Espeja `Capacitacion/lib/src/domain/plantillas_prueba.dart`: las de nivel 2 son
el «primer correo por tipo» (CLAUDE.md §11); las de nivel 1 y 3 son la escalera.
A cada plantilla se le añade la **tipología** que imita, para que el generador
construya una «piel legítima» convincente a partir de `tipologias.json`.

El `asunto` aquí es la base; el generador puede ajustarlo según los indicios
(por ejemplo, añade «vence HOY» cuando está I1).
"""

from __future__ import annotations

import json
import logging
import os
from dataclasses import dataclass, field
from pathlib import Path

from .catalogo import EXTERNOS, INTERNOS
from .config import RAIZ_REPO, config

log = logging.getLogger("capacitacion.plantillas")


@dataclass(frozen=True)
class Plantilla:
    id: str
    tipos: frozenset[str]
    nivel: int  # 1 fácil (4+ indicios), 2 medio (2-3), 3 difícil (1 sutil)
    tipologia: str  # tipología que imita (T1..T6)
    asunto: str
    indicios: tuple[str, ...]
    # Las 6 plantillas del «primer correo por tipo» (CLAUDE.md §11).
    es_primer_correo: bool = False
    # Contexto opcional para enriquecer el cuerpo (montos, áreas, referencias).
    contexto: dict = field(default_factory=dict)

    def aplica_a(self, tipos: set[str]) -> bool:
        return bool(self.tipos & tipos)

    @property
    def indicios_implicitos(self) -> tuple[str, ...]:
        """I7 e I2 siempre están presentes (remitente y enlace no oficiales),
        aunque no sean «la lección» declarada. Útil para A1 «caza la señal»."""
        return tuple(i for i in ("I7", "I2") if i not in self.indicios)


def _f(*tipos: str) -> frozenset[str]:
    return frozenset(tipos)


# Plantillas embebidas: espejo de Capacitacion/lib/src/domain/plantillas_prueba.dart
# (Bloque 2, commit 015f3ce). Se usan si no está el JSON exportado (ver abajo).
_EMBEBIDAS: list[Plantilla] = [
    # ---------- Nivel 2: primer correo por tipo (§11) ----------
    Plantilla(
        id="N2-EX1-reembolso",
        tipos=_f("EX1"),
        nivel=2,
        tipologia="T2",
        asunto="Tienes un reembolso pendiente de $187,40, vence hoy",
        indicios=("I6", "I1", "I7"),
        es_primer_correo=True,
        contexto={"monto": "187,40", "periodo": "octubre-diciembre"},
    ),
    Plantilla(
        id="N2-EX2-pension",
        tipos=_f("EX2"),
        nivel=2,
        tipologia="T2",
        asunto="Tu pensión será suspendida si no actualizas tus datos hoy",
        indicios=("I8", "I1", "I9"),
        es_primer_correo=True,
    ),
    Plantilla(
        id="N2-EX3-glosa",
        tipos=_f("EX3"),
        nivel=2,
        tipologia="T2",
        asunto="Glosa por aportes impagos: evita la coactiva cancelando la tasa hoy",
        indicios=("I8", "I10", "I7"),
        es_primer_correo=True,
        contexto={"monto": "48,60"},
    ),
    Plantilla(
        id="N2-EX4-planillas",
        tipos=_f("EX4"),
        nivel=2,
        tipologia="T2",
        asunto="Liquidación de planillas retenida: revisa el detalle adjunto",
        indicios=("I5", "I7", "I1"),
        es_primer_correo=True,
        contexto={"adjunto_ext": "zip"},
    ),
    Plantilla(
        id="N2-EX5-certificado",
        tipos=_f("EX5"),
        nivel=2,
        tipologia="T3",
        asunto="Tu certificado de afiliación está listo. Escanea el QR para descargarlo",
        indicios=("I11", "I7", "I1"),
        es_primer_correo=True,
    ),
    Plantilla(
        id="N2-IN-buzon",
        tipos=frozenset(INTERNOS),
        nivel=2,
        tipologia="T6",
        asunto="Tu buzón institucional está lleno. Valida tu usuario y contraseña",
        indicios=("I3", "I1", "I2"),
        es_primer_correo=True,
    ),
    # ---------- Nivel 2: adicionales para la escalera ----------
    Plantilla(
        id="N2-EX-turno-qr",
        tipos=_f("EX1", "EX2", "EX4"),
        nivel=2,
        tipologia="T4",
        asunto="Turno médico confirmado: escanea el QR y valida tus datos",
        indicios=("I11", "I9", "I1"),
    ),
    Plantilla(
        id="N2-EX-clave",
        tipos=frozenset(EXTERNOS),
        nivel=2,
        tipologia="T5",
        asunto="Actividad inusual en tu cuenta: confirma tu clave ahora",
        indicios=("I3", "I4", "I1"),
    ),
    # ---------- Nivel 1: 4 o más indicios, obvios ----------
    Plantilla(
        id="N1-EX-bloqueo",
        tipos=frozenset(EXTERNOS),
        nivel=1,
        tipologia="T5",
        asunto="¡URGENTE! Tu cuenta será bloqueada hoy: confirma tu clave y tu tarjeta",
        indicios=("I1", "I8", "I3", "I7", "I2"),
    ),
    Plantilla(
        id="N1-EX-premio",
        tipos=frozenset(EXTERNOS),
        nivel=1,
        tipologia="T2",
        asunto="Ganaste un bono de $500: envía tu cédula y paga $5 de envío antes de las 18:00",
        indicios=("I6", "I9", "I10", "I1", "I7"),
        contexto={"monto": "500,00", "tasa": "5,00"},
    ),
    Plantilla(
        id="N1-EX-cita-pago",
        tipos=_f("EX1", "EX2", "EX4"),
        nivel=1,
        tipologia="T4",
        asunto="Su cita será cancelada hoy: pague la tasa para confirmarla",
        indicios=("I1", "I8", "I10", "I7", "I2"),
        contexto={"tasa": "4,50"},
    ),
    Plantilla(
        id="N1-IN-parche",
        tipos=frozenset(INTERNOS),
        nivel=1,
        tipologia="T6",
        asunto="Soporte TI: tu cuenta se desactiva HOY. Instala el parche adjunto e ingresa tu clave",
        indicios=("I1", "I8", "I5", "I3", "I7"),
        contexto={"adjunto_ext": "exe"},
    ),
    # ---------- Nivel 3: 1 indicio, sutil ----------
    Plantilla(
        id="N3-EX-enlace",
        tipos=frozenset(EXTERNOS),
        nivel=3,
        tipologia="T3",
        asunto="Actualizamos el formato de tus certificados",
        indicios=("I4",),
    ),
    Plantilla(
        id="N3-EX-remitente",
        tipos=frozenset(EXTERNOS),
        nivel=3,
        tipologia="T4",
        asunto="Recordatorio de tu cita de control",
        indicios=("I7",),
    ),
    Plantilla(
        id="N3-EX-adjunto",
        tipos=frozenset(EXTERNOS),
        nivel=3,
        tipologia="T2",
        asunto="Tu estado de cuenta de noviembre (adjunto)",
        indicios=("I5",),
        contexto={"adjunto_ext": "pdf"},
    ),
    Plantilla(
        id="N3-EX-datos",
        tipos=frozenset(EXTERNOS),
        nivel=3,
        tipologia="T1",
        asunto="Completa tu fecha de nacimiento para mantener tu perfil al día",
        indicios=("I9",),
    ),
    Plantilla(
        id="N3-EX-pago",
        tipos=frozenset(EXTERNOS),
        nivel=3,
        tipologia="T3",
        asunto="Emisión de tu certificado: valor de $2,50",
        indicios=("I10",),
        contexto={"tasa": "2,50"},
    ),
    Plantilla(
        id="N3-IN-documento",
        tipos=frozenset(INTERNOS),
        nivel=3,
        tipologia="T6",
        asunto="Nueva política de vacaciones: revisa el documento compartido",
        indicios=("I2",),
    ),
    Plantilla(
        id="N3-IN-reunion",
        tipos=frozenset(INTERNOS),
        nivel=3,
        tipologia="T6",
        asunto="Acta de la reunión de coordinación (adjunto)",
        indicios=("I5",),
        contexto={"adjunto_ext": "docx"},
    ),
    Plantilla(
        id="N3-IN-nomina",
        tipos=frozenset(INTERNOS),
        nivel=3,
        tipologia="T6",
        asunto="Novedades de nómina de este mes",
        indicios=("I4",),
    ),
]

# --------------------------------------------------------------------------- #
# Carga desde el JSON exportado del Dart (fuente de verdad única, anti-drift)
# --------------------------------------------------------------------------- #
#
# El Bloque 2 exporta Analisis-de-comportamiento/datos/plantillas.json desde el
# Dart, con una prueba que falla si se desfasa. Si ese archivo existe, se usa; si
# no, se usan las plantillas embebidas de arriba. Solo se toman los campos
# estructurales (id, tipos, nivel, tipología, indicios, asunto, es_primer_correo,
# extensión del adjunto): el cuerpo del correo lo construye el generador.


def _plantilla_desde_json(p: dict) -> Plantilla:
    contexto: dict = {}
    adjunto = p.get("adjunto")
    if adjunto and "." in adjunto:
        contexto["adjunto_ext"] = adjunto.rsplit(".", 1)[1].lower()
    return Plantilla(
        id=p["id"],
        tipos=frozenset(p["tipos"]),
        nivel=int(p["nivel"]),
        tipologia=p["tipologia"],
        asunto=p["asunto"],
        indicios=tuple(p["indicios"]),
        es_primer_correo=bool(p.get("es_primer_correo", False)),
        contexto=contexto,
    )


def _cargar_plantillas() -> tuple[list[Plantilla], str]:
    ruta = Path(
        os.environ.get(
            "PLANTILLAS_JSON",
            str(RAIZ_REPO / "Analisis-de-comportamiento" / "datos" / "plantillas.json"),
        )
    )
    if not ruta.exists():
        return _EMBEBIDAS, "embebidas"
    try:
        datos = json.loads(ruta.read_text(encoding="utf-8"))
        dominio = datos.get("dominio_practica")
        if dominio and dominio != config.dominio_practica:
            log.warning(
                "El dominio de %s (%s) no coincide con DOMINIO_PRACTICA (%s).",
                ruta,
                dominio,
                config.dominio_practica,
            )
        plantillas = [_plantilla_desde_json(p) for p in datos["plantillas"]]
        if not plantillas:
            raise ValueError("sin plantillas")
        log.info("Plantillas cargadas de %s (%d).", ruta, len(plantillas))
        return plantillas, str(ruta)
    except Exception as exc:  # JSON ausente o malformado → respaldo embebido
        log.warning("No se pudo leer %s (%s); uso plantillas embebidas.", ruta, exc)
        return _EMBEBIDAS, "embebidas(fallback)"


PLANTILLAS, FUENTE_PLANTILLAS = _cargar_plantillas()
PLANTILLAS_POR_ID: dict[str, Plantilla] = {p.id: p for p in PLANTILLAS}


def plantillas_para(tipos: set[str]) -> list[Plantilla]:
    return [p for p in PLANTILLAS if p.aplica_a(tipos)]
