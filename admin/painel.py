#!/usr/bin/env python3
"""Painel Admin do Genius Kiddo — só para o Rhoney, só neste computador.

Uso:  python3 admin/painel.py      e abra  http://127.0.0.1:8765

Segurança:
- escuta só em 127.0.0.1 (nada de fora do computador alcança o painel);
- confere o cabeçalho Host (barra "DNS rebinding");
- toda gravação exige o cabeçalho X-Painel, que um site qualquer aberto no
  navegador não consegue mandar sem permissão (barra pedidos forjados);
- nada daqui vai para dentro do app.
"""

from __future__ import annotations

import json
import sys
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conteudo  # noqa: E402

HOST, PORTA = "127.0.0.1", 8765
WEB = Path(__file__).resolve().parent / "web"
HOSTS_OK = {f"127.0.0.1:{PORTA}", f"localhost:{PORTA}"}


class Painel(BaseHTTPRequestHandler):
    server_version = "PainelGeniusKiddo"

    def _host_ok(self) -> bool:
        return self.headers.get("Host", "") in HOSTS_OK

    def _json(self, dados, status=HTTPStatus.OK):
        corpo = json.dumps(dados, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(corpo)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(corpo)

    def _corpo(self):
        n = int(self.headers.get("Content-Length", "0"))
        return json.loads(self.rfile.read(n).decode("utf-8")) if n else None

    def do_GET(self):
        if not self._host_ok():
            return self._json({"erro": "host recusado"}, HTTPStatus.FORBIDDEN)
        if self.path in ("/", "/index.html"):
            corpo = (WEB / "index.html").read_bytes()
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(corpo)))
            self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'")
            self.end_headers()
            self.wfile.write(corpo)
        elif self.path == "/api/conteudo":
            self._json(conteudo.carregar())
        elif self.path == "/api/git":
            self._json({"mudancas": conteudo.mudancas_git()})
        else:
            self._json({"erro": "não encontrado"}, HTTPStatus.NOT_FOUND)

    def do_POST(self):
        if not self._host_ok() or self.headers.get("X-Painel") != "1":
            return self._json({"erro": "pedido recusado"}, HTTPStatus.FORBIDDEN)
        if self.path == "/api/validar":
            self._json({"erros": conteudo.validar(self._corpo())})
        elif self.path == "/api/salvar":
            erros = conteudo.salvar(self._corpo())
            if erros:
                return self._json({"erros": erros})
            ok, log = conteudo.gerar_traducoes()
            self._json({"erros": [], "traducoesOk": ok, "log": log, "mudancas": conteudo.mudancas_git()})
        elif self.path == "/api/testes":
            ok, resumo = conteudo.rodar_testes()
            self._json({"ok": ok, "resumo": resumo})
        else:
            self._json({"erro": "não encontrado"}, HTTPStatus.NOT_FOUND)

    def log_message(self, fmt, *args):  # silencioso, menos o essencial
        if "/api/" in (args[0] if args else ""):
            sys.stderr.write("%s\n" % (fmt % args))


def main():
    servidor = ThreadingHTTPServer((HOST, PORTA), Painel)
    print(f"Painel Admin do Genius Kiddo: http://{HOST}:{PORTA}  (Ctrl+C para fechar)")
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        print("\nPainel fechado.")


if __name__ == "__main__":
    main()
