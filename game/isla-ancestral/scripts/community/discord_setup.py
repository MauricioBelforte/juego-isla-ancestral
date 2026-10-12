#!/usr/bin/env python3
"""M100 — discord_setup.py: crea estructura de canales y roles del servidor."""
import json, pathlib

def create_discord_structure(discord_token: str, guild_id: int, config_path: str = "res://data/community/roles.json"):
    """Lee roles.json y crea canales/roles en el servidor Discord."""
    cfg = json.loads(pathlib.Path(config_path).read_text())
    for role in cfg.get("roles", []):
        print(f"[M100] Rol: {role['id']} — {role.get('permisos', [])}")
    for chan in cfg.get("canales", {}).get("admin", []):
        print(f"[M100] Canal: {chan}")
    print("[M100] Estructura Discord definida (ejecutar con bot token para crear)")

if __name__ == "__main__":
    create_discord_structure("", 0)
