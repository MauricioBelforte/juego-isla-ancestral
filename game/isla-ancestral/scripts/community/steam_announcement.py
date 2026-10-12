#!/usr/bin/env python3
"""M100 — steam_announcement.py: genera borrador de anuncio para Steam."""
import json, pathlib

def generate_announcement(phase: str = "beta", date: str = ""):
    """Genera texto de anuncio según fase (teaser/beta/lanzamiento)."""
    tpl = {
        "teaser": "Isla Ancestral está en camino. Descubre un mundo voxel cozy lleno de misterios. Wishlist ahora.",
        "beta": "Isla Ancestral: Beta abierta! Comparte tu isla y ayuda a pulir la experiencia.",
        "lanzamiento": "Isla Ancestral ya está disponible! Construye tu hogar, descubre sus secretos."
    }
    return tpl.get(phase, tpl["teaser"]) + (f" Fecha: {date}" if date else "")

if __name__ == "__main__":
    print(generate_announcement("beta", "2026-12-01"))
