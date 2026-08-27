#!/usr/bin/env python3
"""
screen-mcp — Vía V2: MCP custom de captura de pantalla (fallback universal).

Tools expuestas:
    - list_windows(): lista ventanas visibles (título) para encontrar la del juego/editor.
    - capture_screen(): captura pantalla completa y devuelve la imagen al agente.
    - capture_window(title): captura la ventana cuyo título contenga `title`.
    - save_capture(path): guarda la última captura en disco (historial de capturas).

Uso: este script se registra en cline_mcp_settings.json con transporte stdio:
    "command": "python", "args": ["<ruta>/server.py"]
"""
from io import BytesIO
from pathlib import Path

from fastmcp import FastMCP
from fastmcp.utilities.types import Image as MCPImage
from PIL import ImageGrab
import pygetwindow as gw

mcp = FastMCP("screen-capture")

_ultima: bytes | None = None  # última captura en PNG (para save_capture)


def _capturar(bbox=None) -> bytes:
    img = ImageGrab.grab(bbox=bbox, all_screens=True)
    buf = BytesIO()
    img.save(buf, format="PNG")
    global _ultima
    _ultima = buf.getvalue()
    return _ultima


@mcp.tool
def list_windows() -> list[dict]:
    """Lista las ventanas visibles con su título y posición, para elegir cuál capturar."""
    out = []
    for title in dict.fromkeys(gw.getAllTitles()):
        if not title.strip():
            continue
        wins = gw.getWindowsWithTitle(title)
        if wins and wins[0].visible:
            w = wins[0]
            out.append({
                "title": title,
                "left": w.left, "top": w.top,
                "width": w.width, "height": w.height,
            })
    return out


@mcp.tool
def capture_screen() -> MCPImage:
    """Captura la pantalla completa y devuelve la imagen para análisis visual."""
    return MCPImage(data=_capturar(), format="png")


@mcp.tool
def capture_window(title: str) -> MCPImage:
    """Captura la primera ventana visible cuyo título contenga `title` (case-insensitive)."""
    for t in gw.getAllTitles():
        if title.lower() in t.lower():
            win = gw.getWindowsWithTitle(t)[0]
            try:
                win.restore()
            except Exception:
                pass
            try:
                win.activate()  # puede fallar si Windows bloquea el foco
                import time
                time.sleep(0.3)
            except Exception:
                pass  # capturar igualmente por coordenadas
            l, tp = win.topleft
            r, b = win.bottomright
            data = _capturar(bbox=(int(l), int(tp), int(r), int(b)))
            return MCPImage(data=data, format="png")
    raise ValueError(f"No se encontró ventana con título que contenga: {title!r}")


@mcp.tool
def save_capture(path: str) -> str:
    """Guarda la última captura realizada en `path` (crea carpetas si no existen)."""
    if _ultima is None:
        raise RuntimeError("No hay captura previa; llamá capture_screen o capture_window primero.")
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(_ultima)
    return f"Guardado: {p} ({len(_ultima)} bytes)"


if __name__ == "__main__":
    mcp.run()  # transporte stdio
