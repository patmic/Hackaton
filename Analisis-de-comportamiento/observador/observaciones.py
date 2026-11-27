"""Observaciones de conducta: lo único que el observador recibe.

Tres tipos, todos ligados a un `id_seudonimo` (nunca cédula, nombre ni correo):

- `SIMULACRO`: reacción a un correo de prueba (REPORTO, CLIC o IGNORO). La envía
  la API de Capacitación (`backend/capacitacion`) o el mock de la app.
- `DECISION`: un juicio dentro de una actividad (tarjeta de «¿Real o estafa?»,
  correo de la bandeja simulada, señal de «Caza la señal»).
- `VERIFICACION`: la persona verificó un correo en la app antes de actuar.

El contrato en JSON está en `contrato/` y en el README.
"""
from __future__ import annotations

import re
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone

from .catalogo import INDICIOS, NIVELES, RANGOS_ETARIOS, RESULTADOS, SEMAFOROS, TIPOS_USUARIO

TIPOS_OBSERVACION = ("SIMULACRO", "DECISION", "VERIFICACION")
ORIGENES = ("real", "sintetico")
ID_RE = re.compile(r"^[A-Za-z0-9_-]{16,64}$")
_TEXTO_ID_RE = re.compile(r"^[A-Za-z0-9_.:-]{1,80}$")
_TIPOLOGIA_RE = re.compile(r"^T[1-6]$")


class ObservacionInvalida(ValueError):
    """La observación no cumple el contrato."""


def ahora_utc() -> datetime:
    return datetime.now(timezone.utc)


def _fecha(valor) -> datetime:
    if isinstance(valor, datetime):
        d = valor
    else:
        try:
            d = datetime.fromisoformat(str(valor).replace("Z", "+00:00"))
        except ValueError as e:
            raise ObservacionInvalida(f"momento inválido: {valor!r}") from e
    return d if d.tzinfo else d.replace(tzinfo=timezone.utc)


def _indicios(valor, campo: str) -> tuple[str, ...]:
    lista = tuple(str(i).strip().upper() for i in (valor or []))
    malos = [i for i in lista if i not in INDICIOS]
    if malos:
        raise ObservacionInvalida(f"{campo}: indicios desconocidos {malos}")
    return tuple(dict.fromkeys(lista))  # sin repetidos, en orden


@dataclass(frozen=True)
class Observacion:
    id_seudonimo: str
    tipo: str
    momento: datetime
    tipos: tuple[str, ...] = ()
    rango_etario: str | None = None
    origen: str = "real"
    # Indicios presentes en el correo o en el ítem
    indicios: tuple[str, ...] = ()
    # Solo SIMULACRO: indicios que están sin buscarlos (I7 e I2 en todo correo de práctica)
    indicios_implicitos: tuple[str, ...] = ()
    tipologia: str | None = None
    # SIMULACRO
    plantilla_id: str | None = None
    nivel: int | None = None
    resultado: str | None = None
    reporto_despues_de_clic: bool = False
    segundos_hasta_reaccion: float | None = None
    # DECISION
    actividad_id: str | None = None
    item_id: str | None = None
    es_estafa: bool | None = None
    acerto: bool | None = None
    # VERIFICACION
    semaforo: str | None = None
    extra: dict = field(default_factory=dict, compare=False)

    # -------------------------------------------------------------- lectura
    @classmethod
    def desde_json(cls, d: dict, *, origen: str | None = None) -> "Observacion":
        if not isinstance(d, dict):
            raise ObservacionInvalida("se esperaba un objeto JSON")
        ident = str(d.get("id_seudonimo", ""))
        if not ID_RE.match(ident):
            raise ObservacionInvalida("id_seudonimo debe tener entre 16 y 64 caracteres [A-Za-z0-9_-]")
        tipo = str(d.get("tipo", "")).upper()
        if tipo not in TIPOS_OBSERVACION:
            raise ObservacionInvalida(f"tipo debe ser uno de {TIPOS_OBSERVACION}")
        tipos = tuple(str(t).upper() for t in d.get("tipos", []) or [])
        if any(t not in TIPOS_USUARIO for t in tipos):
            raise ObservacionInvalida(f"tipos desconocidos: {tipos}")
        rango = d.get("rango_etario")
        if rango is not None and rango not in RANGOS_ETARIOS:
            raise ObservacionInvalida(f"rango_etario debe ser uno de {RANGOS_ETARIOS}")
        tipologia = d.get("tipologia")
        if tipologia is not None:
            tipologia = str(tipologia).upper()
            if not _TIPOLOGIA_RE.match(tipologia):
                raise ObservacionInvalida("tipologia debe ser T1 a T6")
        orig = origen or str(d.get("origen", "real"))
        if orig not in ORIGENES:
            raise ObservacionInvalida(f"origen debe ser uno de {ORIGENES}")

        campos = dict(
            id_seudonimo=ident, tipo=tipo, momento=_fecha(d.get("momento") or ahora_utc()),
            tipos=tuple(t for t in TIPOS_USUARIO if t in tipos), rango_etario=rango, origen=orig,
            indicios=_indicios(d.get("indicios"), "indicios"), tipologia=tipologia,
        )
        for clave in ("plantilla_id", "actividad_id", "item_id"):
            v = d.get(clave)
            if v is not None and not _TEXTO_ID_RE.match(str(v)):
                raise ObservacionInvalida(f"{clave} con formato inválido")
            campos[clave] = None if v is None else str(v)

        if tipo == "SIMULACRO":
            resultado = str(d.get("resultado", "")).upper()
            if resultado not in RESULTADOS:
                raise ObservacionInvalida(f"resultado debe ser uno de {RESULTADOS}")
            try:
                nivel = int(d.get("nivel"))
            except (TypeError, ValueError) as e:
                raise ObservacionInvalida("nivel debe ser 1, 2 o 3") from e
            if nivel not in NIVELES:
                raise ObservacionInvalida("nivel debe ser 1, 2 o 3")
            if not campos["indicios"]:
                raise ObservacionInvalida("un simulacro necesita al menos un indicio")
            seg = d.get("segundos_hasta_reaccion")
            if seg is not None:
                try:
                    seg = float(seg)
                except (TypeError, ValueError) as e:
                    raise ObservacionInvalida("segundos_hasta_reaccion debe ser un número") from e
                if seg < 0:
                    raise ObservacionInvalida("segundos_hasta_reaccion no puede ser negativo")
            implicitos = tuple(i for i in _indicios(d.get("indicios_implicitos"), "indicios_implicitos")
                               if i not in campos["indicios"])
            campos.update(resultado=resultado, nivel=nivel, segundos_hasta_reaccion=seg,
                          indicios_implicitos=implicitos,
                          reporto_despues_de_clic=bool(d.get("reporto_despues_de_clic", False)))
        elif tipo == "DECISION":
            if not isinstance(d.get("es_estafa"), bool) or not isinstance(d.get("acerto"), bool):
                raise ObservacionInvalida("una decisión necesita es_estafa y acerto (true/false)")
            if d["es_estafa"] and not campos["indicios"]:
                raise ObservacionInvalida("un ítem que es estafa necesita sus indicios")
            campos.update(es_estafa=d["es_estafa"], acerto=d["acerto"])
        else:
            semaforo = str(d.get("semaforo", "")).upper()
            if semaforo not in SEMAFOROS:
                raise ObservacionInvalida(f"semaforo debe ser uno de {SEMAFOROS}")
            campos["semaforo"] = semaforo
        return cls(**campos)

    def a_json(self) -> dict:
        d = asdict(self)
        d.pop("extra", None)
        d["momento"] = self.momento.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")
        d["tipos"] = list(self.tipos)
        d["indicios"] = list(self.indicios)
        d["indicios_implicitos"] = list(self.indicios_implicitos)
        def vacio(k, v):
            # Se omiten los campos que no aplican a este tipo de observación.
            return v is None or v == [] or (v is False and k == "reporto_despues_de_clic")

        return {k: v for k, v in d.items() if not vacio(k, v)}

    # -------------------------------------------------------------- consultas
    @property
    def es_juicio(self) -> bool:
        """Cuenta para la precisión (§7): decisiones y reacciones con clic o reporte."""
        return self.tipo == "DECISION" or (self.tipo == "SIMULACRO" and self.resultado in ("REPORTO", "CLIC"))

    @property
    def juicio_correcto(self) -> bool:
        if self.tipo == "DECISION":
            return bool(self.acerto)
        return self.resultado == "REPORTO"
