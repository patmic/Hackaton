"""Almacén de observaciones en SQLite (solo biblioteca estándar).

Puede usar su propio archivo o el de SellaCorreo (`/data/sellacorreo.db`): sus
tablas llevan el prefijo `obs_` para no chocar con las del sello.

Qué se guarda: el `id_seudonimo`, sus tipos y rango de edad, y las
observaciones (códigos de indicios, tipologías, niveles y resultados). Nunca
cédula, nombre, correo ni IP. `borrar_persona` cumple el derecho de
eliminación (LOPDP): la app lo llama al salir de la capacitación.
"""
from __future__ import annotations

import json
import sqlite3
import threading
from collections import defaultdict
from contextlib import contextmanager
from pathlib import Path

from .observaciones import Observacion

ESQUEMA = """
CREATE TABLE IF NOT EXISTS obs_observaciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  id_seudonimo TEXT NOT NULL,
  tipo TEXT NOT NULL,
  momento TEXT NOT NULL,
  origen TEXT NOT NULL DEFAULT 'real',
  datos TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS obs_observaciones_persona ON obs_observaciones(id_seudonimo, momento);
CREATE INDEX IF NOT EXISTS obs_observaciones_origen ON obs_observaciones(origen);
"""


class Almacen:
    def __init__(self, ruta: str | Path = ":memory:") -> None:
        self.ruta = str(ruta)
        self._lock = threading.Lock()
        # Con ":memory:" la base vive mientras viva esta conexión.
        self._memoria = sqlite3.connect(":memory:", check_same_thread=False) if self.ruta == ":memory:" else None
        with self._conexion() as c:
            c.executescript(ESQUEMA)
        self.version = 0  # cambia con cada escritura; sirve para cachear el modelo de población

    @contextmanager
    def _conexion(self):
        if self._memoria is not None:
            with self._lock:
                yield self._memoria
                self._memoria.commit()
            return
        c = sqlite3.connect(self.ruta, timeout=10)
        try:
            yield c
            c.commit()
        finally:
            c.close()

    def registrar(self, observaciones: list[Observacion]) -> int:
        filas = [(o.id_seudonimo, o.tipo, o.momento.isoformat(), o.origen, json.dumps(o.a_json(), ensure_ascii=False))
                 for o in observaciones]
        with self._conexion() as c:
            c.executemany("INSERT INTO obs_observaciones(id_seudonimo, tipo, momento, origen, datos) "
                          "VALUES (?, ?, ?, ?, ?)", filas)
        self.version += 1
        return len(filas)

    def de_persona(self, id_seudonimo: str) -> list[Observacion]:
        with self._conexion() as c:
            filas = c.execute("SELECT datos FROM obs_observaciones WHERE id_seudonimo = ? ORDER BY momento",
                              (id_seudonimo,)).fetchall()
        return [Observacion.desde_json(json.loads(f[0])) for f in filas]

    def por_persona(self) -> dict[str, list[Observacion]]:
        res: dict[str, list[Observacion]] = defaultdict(list)
        with self._conexion() as c:
            for ident, datos in c.execute("SELECT id_seudonimo, datos FROM obs_observaciones ORDER BY momento"):
                res[ident].append(Observacion.desde_json(json.loads(datos)))
        return dict(res)

    def borrar_persona(self, id_seudonimo: str) -> int:
        with self._conexion() as c:
            n = c.execute("DELETE FROM obs_observaciones WHERE id_seudonimo = ?", (id_seudonimo,)).rowcount
        self.version += 1
        return n

    def borrar_sinteticos(self) -> int:
        with self._conexion() as c:
            n = c.execute("DELETE FROM obs_observaciones WHERE origen = 'sintetico'").rowcount
        self.version += 1
        return n

    def contar(self) -> dict:
        with self._conexion() as c:
            total, personas = c.execute(
                "SELECT COUNT(*), COUNT(DISTINCT id_seudonimo) FROM obs_observaciones").fetchone()
            sint = c.execute("SELECT COUNT(*) FROM obs_observaciones WHERE origen = 'sintetico'").fetchone()[0]
        return {"observaciones": total, "personas": personas, "sinteticas": sint}
