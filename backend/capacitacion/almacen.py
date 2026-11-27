"""Almacén en memoria para la demo.

Mapea las tablas `simulaciones_correo`, `mapa_indicios` y la parte de
inscripción de `usuarios` (CLAUDE.md §13). En producción se reemplaza por la BD
del Núcleo (Bloque 3) sin tocar la lógica: estas clases son el modelo.

LOPDP: en las métricas (eventos del observatorio) solo viaja `id_seudonimo`. El
correo del destinatario vive aquí porque enviar lo exige, no en las métricas.
"""

from __future__ import annotations

import threading
from dataclasses import dataclass, field
from datetime import datetime

from .seudonimo import hash_token

# Fases del flujo (espejo de FaseCapacitacion en Dart).
NO_INSCRITO = "NO_INSCRITO"
CONFIRMANDO_CORREO = "CONFIRMANDO_CORREO"
ESPERANDO_REACCION = "ESPERANDO_REACCION"
EN_CURSO = "EN_CURSO"
PAUSADA = "PAUSADA"


@dataclass
class Simulacion:
    """Un correo de prueba enviado (tabla `simulaciones_correo`)."""

    simulacro_id: str
    id_seudonimo: str
    tipo_usuario: str
    nivel: int
    indicios: tuple[str, ...]
    plantilla_id: str
    token_hash: str
    enviado_en: datetime
    vence_en: datetime
    asunto: str = ""
    remitente_visible: str = ""
    resultado: str = "PENDIENTE"
    resultado_en: datetime | None = None
    microcurso_enviado: bool = False
    hubo_clic: bool = False
    reporto_despues_de_clic: bool = False

    @property
    def pendiente(self) -> bool:
        return self.resultado == "PENDIENTE"


@dataclass
class Inscripcion:
    """Estado de capacitación de un usuario (flujo «Quiero capacitarme»)."""

    id_seudonimo: str
    correo: str  # destino operativo; no se usa en métricas
    tipos: set[str]
    rango_etario: str = "desconocido"  # 18-29 / 30-49 / 50-64 / 65+
    es_cuidador: bool = False
    fase: str = NO_INSCRITO
    fase_antes_de_pausa: str | None = None
    consentimiento: dict | None = None
    nivel_inicial: str | None = None
    nivel_correo: int = 2
    mapa: dict[str, str] = field(default_factory=dict)
    reportes_seguidos_nivel3: int = 0
    es_centinela: bool = False
    ultimo_envio: datetime | None = None
    simulacro_actual: str | None = None  # simulacro_id en curso
    enviadas: set[str] = field(default_factory=set)  # plantilla ids usadas
    ultimo_desenlace: dict | None = None  # momento enseñable más reciente

    @property
    def inscrito(self) -> bool:
        return self.fase != NO_INSCRITO

    @property
    def pausada(self) -> bool:
        return self.fase == PAUSADA


class Almacen:
    def __init__(self) -> None:
        self._lock = threading.RLock()
        self._inscripciones: dict[str, Inscripcion] = {}
        self._simulaciones: dict[str, Simulacion] = {}  # por simulacro_id
        self._por_token_hash: dict[str, str] = {}  # token_hash -> simulacro_id

    # ---- Inscripciones ----
    def inscripcion(self, id_seudonimo: str) -> Inscripcion | None:
        with self._lock:
            return self._inscripciones.get(id_seudonimo)

    def obtener_o_crear_inscripcion(
        self, id_seudonimo: str, correo: str, tipos: set[str]
    ) -> Inscripcion:
        with self._lock:
            insc = self._inscripciones.get(id_seudonimo)
            if insc is None:
                insc = Inscripcion(
                    id_seudonimo=id_seudonimo, correo=correo, tipos=set(tipos)
                )
                self._inscripciones[id_seudonimo] = insc
            return insc

    def eliminar_inscripcion(self, id_seudonimo: str) -> None:
        with self._lock:
            self._inscripciones.pop(id_seudonimo, None)

    # ---- Simulaciones ----
    def guardar_simulacion(self, sim: Simulacion) -> None:
        with self._lock:
            self._simulaciones[sim.simulacro_id] = sim
            self._por_token_hash[sim.token_hash] = sim.simulacro_id

    def simulacion(self, simulacro_id: str) -> Simulacion | None:
        with self._lock:
            return self._simulaciones.get(simulacro_id)

    def simulacion_por_token(self, token: str) -> Simulacion | None:
        with self._lock:
            sid = self._por_token_hash.get(hash_token(token))
            return self._simulaciones.get(sid) if sid else None

    def vencidas(self, ahora: datetime) -> list[Simulacion]:
        with self._lock:
            return [
                s
                for s in self._simulaciones.values()
                if s.pendiente and ahora >= s.vence_en
            ]

    def simulaciones_de(self, id_seudonimo: str) -> list[Simulacion]:
        with self._lock:
            return [
                s
                for s in self._simulaciones.values()
                if s.id_seudonimo == id_seudonimo
            ]


# Instancia única para la demo.
almacen = Almacen()
