"""Observador de comportamiento · Escudo Cognitivo IESS (AI-IESS).

Aprende de cómo reacciona cada persona a los correos de prueba y a las
actividades de capacitación, y arma un plan personalizado según sus falencias.
También aprende de toda la población (con k = 10) para el Observatorio.

Solo usa la biblioteca estándar; `observador.api` necesita FastAPI.
"""
from .almacen import Almacen
from .catalogo import INDICIOS, CatalogoTipologias
from .observaciones import Observacion, ObservacionInvalida
from .plan import elegir_plantilla, generar_plan
from .poblacion import K_ANONIMATO, ModeloPoblacion
from .servicio import Observador

__all__ = [
    "INDICIOS",
    "K_ANONIMATO",
    "Almacen",
    "CatalogoTipologias",
    "ModeloPoblacion",
    "Observacion",
    "ObservacionInvalida",
    "Observador",
    "elegir_plantilla",
    "generar_plan",
]
