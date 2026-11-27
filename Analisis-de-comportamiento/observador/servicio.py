"""Fachada del observador: lo que usan SellaCorreo, la API de Capacitación y la CLI."""
from __future__ import annotations

import time
from datetime import datetime
from typing import Callable

from .almacen import Almacen
from .catalogo import CatalogoTipologias
from .observaciones import ID_RE, Observacion, ObservacionInvalida, ahora_utc
from .plan import elegir_plantilla, generar_plan
from .poblacion import ModeloPoblacion

MAX_LOTE = 200


class Observador:
    def __init__(self, almacen: Almacen | None = None, catalogo: CatalogoTipologias | None = None,
                 reloj: Callable[[], datetime] = ahora_utc, ttl_poblacion: float = 30.0) -> None:
        self.almacen = almacen or Almacen()
        self.catalogo = catalogo or CatalogoTipologias.cargar()
        self.reloj = reloj
        self.ttl_poblacion = ttl_poblacion
        self._poblacion: ModeloPoblacion | None = None
        self._poblacion_clave: tuple | None = None

    # -------------------------------------------------------------- escritura
    def registrar(self, datos, *, origen: str | None = None) -> int:
        """Registra una observación o una lista (máximo `MAX_LOTE`). Valida
        todo antes de escribir: si una falla, no se guarda ninguna."""
        lote = datos if isinstance(datos, list) else [datos]
        if len(lote) > MAX_LOTE:
            raise ObservacionInvalida(f"máximo {MAX_LOTE} observaciones por envío")
        obs = [d if isinstance(d, Observacion) else Observacion.desde_json(d, origen=origen) for d in lote]
        return self.almacen.registrar(obs)

    def borrar_persona(self, id_seudonimo: str) -> int:
        self._validar_id(id_seudonimo)
        return self.almacen.borrar_persona(id_seudonimo)

    # -------------------------------------------------------------- lectura
    def poblacion(self) -> ModeloPoblacion:
        clave = (self.almacen.version, int(time.monotonic() // self.ttl_poblacion))
        if self._poblacion is None or clave != self._poblacion_clave:
            self._poblacion = ModeloPoblacion.construir(self.almacen.por_persona(), self.reloj())
            self._poblacion_clave = clave
        return self._poblacion

    def plan(self, id_seudonimo: str, *, tipos=None, rango_etario: str | None = None) -> dict:
        """Plan de la persona. Sin observaciones todavía, `tipos` y
        `rango_etario` permiten arrancar con lo aprendido de su segmento."""
        self._validar_id(id_seudonimo)
        return generar_plan(id_seudonimo, self.almacen.de_persona(id_seudonimo), self.reloj(), self.catalogo,
                            self.poblacion(), tipos=tipos, rango_etario=rango_etario)

    def siguiente_plantilla(self, id_seudonimo: str, candidatas: list[dict], ya_enviadas=()) -> dict:
        plan = self.plan(id_seudonimo)
        return {"plantilla_id": elegir_plantilla(plan, candidatas, ya_enviadas),
                "siguiente_correo": plan["siguiente_correo"]}

    def resumen(self) -> dict:
        res = self.poblacion().resumen(self.catalogo)
        res["almacen"] = self.almacen.contar()
        return res

    @staticmethod
    def _validar_id(id_seudonimo: str) -> None:
        if not ID_RE.match(id_seudonimo or ""):
            raise ObservacionInvalida("id_seudonimo inválido")
