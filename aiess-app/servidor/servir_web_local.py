"""Servidor local de AIESS para probar en la PC, igual que Caddy en el servidor:
sirve la web (app/build/web) y pasa solo la API del modelo (/completion, /health, /v1/*) a llama-server.

Uso:  python servir_web_local.py [carpeta_web] [puerto] [url_del_modelo]
      python servir_web_local.py ../app/build/web 8090 http://127.0.0.1:8080
No guarda nada: no hay registro de solicitudes (los correos no quedan en ningún log).
"""
import http.server
import socketserver
import sys
import urllib.request
from functools import partial

WEB = sys.argv[1] if len(sys.argv) > 1 else '../app/build/web'
PUERTO = int(sys.argv[2]) if len(sys.argv) > 2 else 8090
MODELO = sys.argv[3] if len(sys.argv) > 3 else 'http://127.0.0.1:8080'
API = ('/completion', '/health', '/v1/')


class Manejador(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):  # sin registro: privacidad
        pass

    def _es_api(self):
        return self.path.startswith(API)

    def _pasar(self, metodo):
        largo = int(self.headers.get('Content-Length') or 0)
        cuerpo = self.rfile.read(largo) if largo else None
        cabeceras = {k: v for k, v in self.headers.items() if k.lower() in ('authorization', 'content-type', 'accept')}
        pedido = urllib.request.Request(MODELO + self.path, data=cuerpo, headers=cabeceras, method=metodo)
        try:
            with urllib.request.urlopen(pedido, timeout=300) as r:
                self.send_response(r.status)
                for k, v in r.getheaders():
                    if k.lower() in ('content-type', 'cache-control'):
                        self.send_header(k, v)
                self.end_headers()
                # Streaming: se reenvía cada trozo apenas llega.
                while True:
                    trozo = r.read1(4096) if hasattr(r, 'read1') else r.read(4096)
                    if not trozo:
                        break
                    self.wfile.write(trozo)
                    self.wfile.flush()
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
        except Exception:
            self.send_response(502)
            self.end_headers()

    def do_GET(self):
        if self._es_api():
            return self._pasar('GET')
        if self.path == '/' or '.' not in self.path.split('?')[0].rsplit('/', 1)[-1]:
            self.path = '/index.html'  # rutas de la app -> index.html
        return super().do_GET()

    def do_POST(self):
        if self._es_api():
            return self._pasar('POST')
        self.send_response(405)
        self.end_headers()


class Servidor(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == '__main__':
    with Servidor(('127.0.0.1', PUERTO), partial(Manejador, directory=WEB)) as s:
        print(f'AIESS web en http://127.0.0.1:{PUERTO}  (modelo: {MODELO})')
        s.serve_forever()
