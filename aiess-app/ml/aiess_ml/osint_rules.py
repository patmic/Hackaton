"""Reglas OSINT OFFLINE y deterministas (sin red).

Esta logica se replica 1:1 en Dart (app/lib/features/osint/...) para que el texto
[OSINT] que ve el modelo en el entrenamiento sea identico al que vera en el celular.
Las verificaciones de red (SSL, redirecciones, edad del dominio) solo existen en la app.
"""
from __future__ import annotations

import ipaddress
import re
from urllib.parse import urlsplit

from .config import CANALES
from .datos import URL_RE, plegar

SUFIJOS_2_NIVELES = {"gob.ec", "com.ec", "edu.ec", "org.ec", "net.ec", "fin.ec", "mil.ec",
                     "co.uk", "com.co", "com.pe", "com.mx", "com.ar", "com.br", "co.jp"}
HOMOGLIFOS = [("rn", "m"), ("vv", "w"), ("0", "o"), ("1", "i"), ("l", "i"), ("|", "i"),
              ("3", "e"), ("5", "s"), ("4", "a"), ("@", "a")]
RUTA_SENSIBLE = re.compile(r"(login|signin|verific|actualiz|reembolso|desbloque|clave|password|premio|"
                           r"bono|pago|validar|confirmar|seguridad|cuenta)", re.I)


def _coincide(host: str, dominio: str) -> bool:
    return host == dominio or host.endswith("." + dominio)


def partir_url(url: str):
    u = url.strip().strip(".,;:!?»«\"'")
    if not re.match(r"^[a-z][a-z0-9+.-]*://", u, re.I):
        u = "http://" + u
    try:
        p = urlsplit(u)
        host = (p.hostname or "").rstrip(".").lower()
    except ValueError:
        return None, ""
    return p, host


def dominio_registrable(host: str) -> str:
    partes = host.split(".")
    if len(partes) >= 3 and ".".join(partes[-2:]) in SUFIJOS_2_NIVELES:
        return ".".join(partes[-3:])
    return ".".join(partes[-2:])


def esqueleto(s: str) -> str:
    s = plegar(s)
    for a, b in HOMOGLIFOS:
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]", "", s)


def distancia(a: str, b: str) -> int:
    """Damerau-Levenshtein (OSA)."""
    d = [[0] * (len(b) + 1) for _ in range(len(a) + 1)]
    for i in range(len(a) + 1):
        d[i][0] = i
    for j in range(len(b) + 1):
        d[0][j] = j
    for i in range(1, len(a) + 1):
        for j in range(1, len(b) + 1):
            c = 0 if a[i - 1] == b[j - 1] else 1
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + c)
            if i > 1 and j > 1 and a[i - 1] == b[j - 2] and a[i - 2] == b[j - 1]:
                d[i][j] = min(d[i][j], d[i - 2][j - 2] + 1)
    return d[-1][-1]


def _es_ip(host: str) -> bool:
    try:
        ipaddress.ip_address(host.strip("[]"))
        return True
    except ValueError:
        return False


def _tokens_host(host: str) -> list[str]:
    reg = dominio_registrable(host)
    sub = host[: -len(reg)].rstrip(".") if host != reg else ""
    etiquetas = [reg.split(".")[0]] + [x for x in sub.split(".") if x and x != "www"]
    toks = []
    for e in etiquetas:
        toks.append(e)
        toks += [t for t in re.split(r"[-_]", e) if t and t != e]
    return toks


def analizar_url(url: str) -> dict:
    hallazgos: list[dict] = []

    def add(codigo: str, detalle: str, peso: int, indicio: str | None = None) -> None:
        hallazgos.append({"codigo": codigo, "detalle": detalle, "peso": peso, "indicio": indicio})

    p, host = partir_url(url)
    if p is None or not host:
        add("URL_INVALIDA", "la direccion no tiene un formato valido", 30, "I2")
        return _cerrar(url, host or "", hallazgos, False, False)

    oficial = any(_coincide(host, d) for d in CANALES["dominios_iess"])
    confiable = oficial or any(_coincide(host, d) for d in CANALES["dominios_confiables"])
    reg = dominio_registrable(host)
    tld = host.rsplit(".", 1)[-1]
    url_l = url.lower()

    if p.scheme == "http" and url_l.startswith("http://"):
        add("SIN_HTTPS", "usa http sin cifrado", 15)
    if "@" in (p.netloc or ""):
        add("USUARIO_EN_URL", "la direccion esconde el destino real detras de un '@'", 35, "I4")
    if _es_ip(host):
        add("IP_DIRECTA", "apunta a una direccion IP en lugar de un dominio", 35, "I2")
    if "xn--" in host:
        add("PUNYCODE", "usa caracteres especiales para imitar otro dominio", 30, "I2")
    if host in CANALES["acortadores"] or reg in CANALES["acortadores"]:
        add("ACORTADOR", f"{host} es un acortador: oculta el destino real", 35, "I4")
    if any(_coincide(host, d.split("/")[0]) and (("/" not in d) or d.split("/", 1)[1] in url_l)
           for d in CANALES["alojamiento_generico"]):
        add("ALOJAMIENTO_GENERICO", f"{host} es un servicio de alojamiento gratuito que cualquiera puede usar", 25, "I2")
    if tld in CANALES["tlds_riesgosos"]:
        add("TLD_RIESGOSO", f"la terminacion .{tld} es frecuente en sitios de estafa", 20)

    if not confiable:
        add("DOMINIO_NO_OFICIAL", f"{reg} no es un dominio del IESS ni de una entidad conocida", 30, "I2")
        toks = _tokens_host(host)
        esqs = {t: esqueleto(t) for t in toks}
        for marca in CANALES["marcas_vigiladas"]:
            m = esqueleto(marca)
            for t, e in esqs.items():
                if len(m) >= 3 and e == m:
                    add("SUPLANTA_MARCA", f"usa el nombre '{marca}' pero no es el sitio oficial", 25, "I2")
                    break
                lim = 1 if len(m) <= 6 else 2
                if len(m) >= 4 and len(e) >= 3 and 0 < distancia(e, m) <= lim:
                    add("TYPOSQUATTING", f"'{t}' imita a '{marca}' con letras cambiadas", 40, "I2")
                    break
            else:
                continue
            break
        if re.search(r"(^|\.)(iess|gob|sri)\.(gob\.)?(ec)\.", host):
            add("SUBDOMINIO_ENGANOSO", f"{host} pone un dominio oficial al inicio pero el sitio real es {reg}", 35, "I2")
        if RUTA_SENSIBLE.search(p.path or ""):
            add("RUTA_SENSIBLE", "la ruta pide verificar, actualizar o ingresar datos", 10)
        if host.count(".") >= 4:
            add("MUCHOS_SUBDOMINIOS", "tiene demasiados subdominios", 10)
    return _cerrar(url, host, hallazgos, oficial, confiable)


def _cerrar(url, host, hallazgos, oficial, confiable) -> dict:
    puntaje = min(100, sum(h["peso"] for h in hallazgos))
    nivel = "alto" if puntaje >= 60 else "medio" if puntaje >= 30 else "bajo"
    return {"url": url, "host": host, "dominio": dominio_registrable(host) if host else "",
            "oficial_iess": oficial, "confiable": confiable, "puntaje": puntaje, "nivel": nivel,
            "hallazgos": hallazgos,
            "indicios": sorted({h["indicio"] for h in hallazgos if h["indicio"]}, key=lambda k: int(k[1:]))}


def analizar_remitente(remitente: str | None) -> dict | None:
    if not remitente:
        return None
    m = re.search(r"[\w.+-]+@([\w-]+(?:\.[\w-]+)+)", remitente)
    if not m:
        return {"remitente": remitente, "sospechoso": True, "detalle": "no es una direccion de correo valida"}
    dom = m.group(1).lower()
    if any(_coincide(dom, d) for d in CANALES["dominios_iess"]):
        return {"remitente": remitente, "sospechoso": False, "detalle": "dominio oficial del IESS"}
    if dom in CANALES["proveedores_correo_gratuito"]:
        return {"remitente": remitente, "sospechoso": True, "detalle": f"usa un correo gratuito ({dom})"}
    if any(_coincide(dom, d) for d in CANALES["dominios_confiables"]):
        return {"remitente": remitente, "sospechoso": False, "detalle": "dominio de entidad conocida"}
    r = analizar_url("http://" + dom)
    extra = "; ".join(h["detalle"] for h in r["hallazgos"] if h["codigo"] in {"SUPLANTA_MARCA", "TYPOSQUATTING"})
    return {"remitente": remitente, "sospechoso": True,
            "detalle": f"dominio no oficial ({dom})" + (f"; {extra}" if extra else "")}


def enlaces_enganosos(cuerpo: str, hrefs: list[str]) -> list[tuple[str, str]]:
    """Texto visible muestra un dominio y el enlace real va a otro (I4)."""
    if not hrefs:
        return []
    hosts_reales = {partir_url(h)[1] for h in hrefs}
    res = []
    for v in URL_RE.findall(cuerpo):
        hv = partir_url(v)[1]
        if hv and hv not in hosts_reales:
            destino = next(iter(sorted(h for h in hosts_reales if h)), "")
            res.append((hv, destino))
    return res


def analizar_mensaje(cuerpo: str, hrefs: list[str] | None = None, remitente: str | None = None) -> dict:
    hrefs = list(hrefs or []) or URL_RE.findall(cuerpo)
    urls = [analizar_url(u) for u in dict.fromkeys(hrefs)]
    engano = enlaces_enganosos(cuerpo, hrefs)
    rem = analizar_remitente(remitente)
    indicios = {i for u in urls for i in u["indicios"]}
    if engano:
        indicios.add("I4")
    if rem and rem["sospechoso"]:
        indicios.add("I7")
    puntaje = max([u["puntaje"] for u in urls] + [60 if engano else 0, 40 if rem and rem["sospechoso"] else 0])
    return {"urls": urls, "enganosos": engano, "remitente": rem, "puntaje": puntaje,
            "indicios": sorted(indicios, key=lambda k: int(k[1:]))}


def resumen_osint(res: dict, red: list[str] | None = None) -> str:
    """Bloque de texto compacto que se inyecta al prompt del modelo (mismo formato en Dart)."""
    lineas = ["[OSINT]"]
    if not res["urls"]:
        lineas.append("- Enlaces: ninguno")
    for u in res["urls"][:4]:
        if u["confiable"] and not u["hallazgos"]:
            lineas.append(f"- {u['host']}: oficial o conocido, sin alertas")
        else:
            det = "; ".join(h["detalle"] for h in u["hallazgos"][:3]) or "sin alertas"
            lineas.append(f"- {u['host'] or u['url']}: riesgo {u['nivel']} ({u['puntaje']}): {det}")
    for vis, real in res["enganosos"][:2]:
        lineas.append(f"- El texto muestra {vis} pero el enlace real lleva a {real}")
    rem = res["remitente"]
    lineas.append(f"- Remitente: {rem['detalle']}" if rem else "- Remitente: no disponible")
    lineas += [f"- {x}" for x in (red or ["Verificacion en red: no realizada"])]
    return "\n".join(lineas)
