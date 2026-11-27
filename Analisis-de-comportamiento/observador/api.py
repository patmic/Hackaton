"""Rutas HTTP del observador para montar en una app FastAPI (SellaCorreo).

    from observador.api import crear_router
    app.include_router(crear_router(observador, puede_ver_panel=...), prefix="/api/v1/observatorio")

| Método y ruta | Quién | Qué hace |
|---|---|---|
| `POST /observaciones` | App y API de Capacitación | Registra una observación o `{"observaciones": [...]}` |
| `GET /personas/{id}/plan` | App | Plan personalizado (`?tipos=EX1,IN1&rango=30-49` para arrancar sin historial) |
| `POST /personas/{id}/siguiente` | API de Capacitación | Elige el siguiente correo de prueba entre `candidatas` |
| `DELETE /personas/{id}` | App (al salir) | Borra todo lo de esa persona (LOPDP) |
| `GET /resumen` | Panel del Observatorio, con sesión | Métricas agregadas con k = 10 |

El `id_seudonimo` es aleatorio y no se deriva de datos personales: quien lo
conoce puede ver ese plan, como con un token. FastAPI solo se importa aquí; el
resto del paquete usa la biblioteca estándar.
"""
from __future__ import annotations

from typing import Callable

from .observaciones import ObservacionInvalida
from .servicio import Observador
from .sintetico import cargar_plantillas


def crear_router(observador: Observador, *, puede_ver_panel: Callable[[object], bool],
                 permitir: Callable[[object], bool] | None = None):
    from fastapi import APIRouter, Body, HTTPException, Request
    from fastapi.responses import JSONResponse

    router = APIRouter(tags=["observatorio"])
    plantillas = cargar_plantillas()

    def _limite(request: Request) -> None:
        if permitir is not None and not permitir(request):
            raise HTTPException(status_code=429, detail="Demasiadas solicitudes. Intente en un minuto.")

    def _invalida(e: ObservacionInvalida):
        return JSONResponse(status_code=422, content={"error": str(e)})

    @router.post("/observaciones", status_code=201)
    def registrar(request: Request, cuerpo: dict | list = Body(...)):
        _limite(request)
        lote = cuerpo.get("observaciones", cuerpo) if isinstance(cuerpo, dict) else cuerpo
        try:
            # Desde la red solo entran datos reales: «sintetico» lo marca la siembra de la demo.
            n = observador.registrar(lote, origen="real")
        except ObservacionInvalida as e:
            return _invalida(e)
        return {"registradas": n}

    @router.get("/personas/{id_seudonimo}/plan")
    def plan(id_seudonimo: str, request: Request, tipos: str = "", rango: str | None = None):
        _limite(request)
        lista = [t.strip().upper() for t in tipos.split(",") if t.strip()]
        try:
            return observador.plan(id_seudonimo, tipos=lista or None, rango_etario=rango)
        except ObservacionInvalida as e:
            return _invalida(e)

    @router.post("/personas/{id_seudonimo}/siguiente")
    def siguiente(id_seudonimo: str, request: Request, cuerpo: dict = Body(default={})):
        _limite(request)
        candidatas = cuerpo.get("candidatas") or plantillas
        try:
            return observador.siguiente_plantilla(id_seudonimo, candidatas, cuerpo.get("ya_enviadas", []))
        except ObservacionInvalida as e:
            return _invalida(e)

    @router.delete("/personas/{id_seudonimo}")
    def borrar(id_seudonimo: str, request: Request):
        _limite(request)
        try:
            return {"borradas": observador.borrar_persona(id_seudonimo)}
        except ObservacionInvalida as e:
            return _invalida(e)

    @router.get("/resumen")
    def resumen(request: Request):
        if not puede_ver_panel(request):
            raise HTTPException(status_code=401, detail="Inicie sesión para ver el Observatorio.")
        return observador.resumen()

    return router
