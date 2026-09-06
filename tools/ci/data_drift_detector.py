#!/usr/bin/env python3
# M118 iter 7 (minimax-3): Detector de drift en data/.
# Compara el estado actual de data/ contra un snapshot data.drift.json
# que documenta la "intencion" del proyecto. Si un archivo data-driven
# cambio sin documentar en el snapshot, lo reporta.
# Tambien detecta archivos nuevos que deberian estar en el snapshot.
# Uso: python tools/ci/data_drift_detector.py [--snapshot data.drift.json] [--data-dir game/isla-ancestral/data]

import os
import sys
import json
import argparse
import hashlib
import glob
from datetime import datetime
from typing import List, Tuple, Dict

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
DEFAULT_SNAPSHOT = os.path.join(PROJECT_ROOT, "data.drift.json")
DEFAULT_DATA_DIR = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data")


def _compute_hash(path: str) -> str:
    """SHA256 de un archivo. Devuelve hex (16 chars)."""
    h = hashlib.sha256()
    try:
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                h.update(chunk)
        return h.hexdigest()[:16]
    except OSError:
        return ""


def _walk_data(data_dir: str) -> Dict[str, str]:
    """Devuelve dict {path_relativo: hash} de todos los JSONs en data_dir."""
    if not os.path.isdir(data_dir):
        return {}
    data_dir_norm = data_dir.replace(os.sep, "/")
    paths = sorted(glob.glob(os.path.join(data_dir_norm, "**", "*.json"), recursive=True))
    result: Dict[str, str] = {}
    for p in paths:
        rel = os.path.relpath(p, data_dir_norm).replace(os.sep, "/")
        result[rel] = _compute_hash(p)
    return result


def _load_snapshot(snapshot_path: str) -> Dict:
    """Carga el snapshot. Si no existe, devuelve dict vacio."""
    if not os.path.exists(snapshot_path):
        return {"version": 0, "files": {}}
    try:
        with open(snapshot_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return {"version": 0, "files": {}}


def _save_snapshot(snapshot_path: str, data: Dict) -> None:
    """Guarda el snapshot."""
    with open(snapshot_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


def detect_drift(current: Dict[str, str], snapshot: Dict) -> List[str]:
    """Detecta drift entre current y snapshot. Devuelve lista de mensajes."""
    msgs: List[str] = []
    snap_files = snapshot.get("files", {})
    # Archivos modificados o eliminados
    for rel, expected_hash in snap_files.items():
        if rel not in current:
            msgs.append(f"ELIMINADO: {rel}")
        elif current[rel] != expected_hash:
            msgs.append(f"MODIFICADO: {rel} (hash {snap_files[rel][:8]} -> {current[rel][:8]})")
    # Archivos nuevos
    snap_keys = set(snap_files.keys())
    for rel in current:
        if rel not in snap_keys:
            msgs.append(f"NUEVO: {rel}")
    return msgs


def main() -> int:
    parser = argparse.ArgumentParser(description="Detector de drift en data/ contra snapshot")
    parser.add_argument("--snapshot", default=DEFAULT_SNAPSHOT, help="Path al snapshot")
    parser.add_argument("--data-dir", default=DEFAULT_DATA_DIR, help="Directorio de data")
    parser.add_argument("--update", action="store_true", help="Actualizar el snapshot con el estado actual")
    parser.add_argument("--init", action="store_true", help="Inicializar snapshot si no existe")
    args = parser.parse_args()

    if not os.path.isdir(args.data_dir):
        print(f"[drift] {args.data_dir} no existe")
        return 0

    current = _walk_data(args.data_dir)
    snapshot = _load_snapshot(args.snapshot)

    if args.update:
        new_snap = {
            "version": snapshot.get("version", 0) + 1,
            "timestamp": datetime.now().isoformat(),
            "data_dir": args.data_dir,
            "files": current,
        }
        _save_snapshot(args.snapshot, new_snap)
        print(f"[drift] snapshot actualizado a v{new_snap['version']} ({len(current)} archivos)")
        return 0

    if not os.path.exists(args.snapshot) and args.init:
        new_snap = {
            "version": 1,
            "timestamp": datetime.now().isoformat(),
            "data_dir": args.data_dir,
            "files": current,
        }
        _save_snapshot(args.snapshot, new_snap)
        print(f"[drift] snapshot inicializado con v1 ({len(current)} archivos)")
        return 0

    if not os.path.exists(args.snapshot):
        print(f"[drift] snapshot {args.snapshot} no existe. Usa --init para crearlo.")
        return 0

    msgs = detect_drift(current, snapshot)
    if not msgs:
        print(f"[drift] 0 cambios desde v{snapshot.get('version', 0)} ({len(current)} archivos OK)")
        return 0
    print(f"[drift] {len(msgs)} cambios desde v{snapshot.get('version', 0)}:")
    for m in msgs:
        print(f"  - {m}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
