"""Esquemas Pydantic de la API (request/response). Contratos de CLAUDE.md §12."""

from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field


# --------------------------------------------------------------------------- #
# /api/v1/me
# --------------------------------------------------------------------------- #


class MeOut(BaseModel):
    tipos: list[str]
    zona: str
    rango_etario: str
    perfil_conducta: str = "SIN_PERFIL"
    es_alto_privilegio: bool = False


# --------------------------------------------------------------------------- #
# /api/v1/eventos
# --------------------------------------------------------------------------- #


class EventosIn(BaseModel):
    eventos: list[dict] = Field(default_factory=list)


class EventosOut(BaseModel):
    registrados: int


# --------------------------------------------------------------------------- #
# Capacitación
# --------------------------------------------------------------------------- #


class ConsentimientoIn(BaseModel):
    version: str
    aceptado: bool = True


class InscribirIn(BaseModel):
    consentimiento: ConsentimientoIn
    # Correo del destinatario (doble opt-in si no viene de una cuenta).
    correo: EmailStr
    tipos: list[str] = Field(default_factory=list)
    tiene_cuenta: bool = True
    rango_etario: str = "desconocido"
    es_cuidador: bool = False


class CorreoResumen(BaseModel):
    simulacro_id: str
    plantilla_id: str
    tipo_usuario: str
    tipologia: str
    nivel: int
    indicios: list[str]
    asunto: str
    remitente_visible: str
    enviado_en: str
    vence_en: str
    resultado: str


class DesenlaceOut(BaseModel):
    resultado: str
    titulo: str
    mensaje: str
    indicios: list[str]
    microcursos: list[str] = Field(default_factory=list)


class EstadoOut(BaseModel):
    fase: str
    inscrito: bool
    pausada: bool
    nivel_inicial: str | None = None
    nivel_correo: int
    es_centinela: bool
    mapa_indicios: dict[str, str] = Field(default_factory=dict)
    correo_actual: CorreoResumen | None = None
    ultimo_desenlace: DesenlaceOut | None = None
    proximo_envio: str | None = None


# --------------------------------------------------------------------------- #
# Reportes
# --------------------------------------------------------------------------- #


class ReporteEntranteIn(BaseModel):
    """Webhook de recepción: el correo reenviado por la persona (reporte)."""

    # Se busca el token en el cuerpo o en la cabecera X-Simulacro-Ref.
    token: str | None = None
    cuerpo: str | None = None
    cabeceras: dict[str, str] = Field(default_factory=dict)


class ReaccionOut(BaseModel):
    aceptado: bool
    resultado: str | None = None
    desenlace: DesenlaceOut | None = None
