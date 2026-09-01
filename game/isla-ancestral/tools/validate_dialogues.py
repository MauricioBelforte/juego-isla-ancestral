#!/usr/bin/env python3
"""Validador de grafos de dialogo JSON para Isla Ancestral."""
import json
import os
import sys

DIALOGUE_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "dialogues")

def validate_dialogue(filepath):
    errors = []
    with open(filepath, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            return [f"JSON invalido: {e}"]

    if not isinstance(data, dict):
        return ["Root no es un Dictionary"]

    for field in ["id", "start", "nodes"]:
        if field not in data:
            errors.append(f"Falta campo '{field}'")
    if errors:
        return errors

    nodes = data["nodes"]
    if not nodes:
        return ["No hay nodos definidos"]

    if data["start"] not in nodes:
        errors.append(f"start '{data['start']}' no existe en nodes")

    visited = {}
    for node_id, node in nodes.items():
        node_errors = validate_node(node_id, node, nodes, visited)
        errors.extend(node_errors)

    for node_id in nodes:
        if node_id == data.get("start", ""):
            continue
        if node_id not in visited:
            errors.append(f"Nodo huerfano: '{node_id}' no es alcanzable desde start")

    return errors

def validate_node(node_id, node, all_nodes, visited):
    errors = []
    if "tipo" not in node:
        errors.append(f"Nodo '{node_id}': falta 'tipo'")
        return errors

    tipo = node["tipo"]

    if "speaker_key" not in node:
        errors.append(f"Nodo '{node_id}': falta 'speaker_key'")

    if tipo == 0:
        if "text_key" not in node:
            errors.append(f"Nodo '{node_id}': speech sin 'text_key'")
        if "next_id" in node:
            nxt = node["next_id"]
            visited[nxt] = True
            if nxt not in all_nodes:
                errors.append(f"Nodo '{node_id}': next_id '{nxt}' no existe")

    elif tipo == 1:
        if "options" not in node:
            errors.append(f"Nodo '{node_id}': choice sin 'options'")
        else:
            options = node["options"]
            if not options:
                errors.append(f"Nodo '{node_id}': choice con options vacio")
            for i, opt in enumerate(options):
                if "next_id" not in opt:
                    errors.append(f"Nodo '{node_id}': option[{i}] sin 'next_id'")
                else:
                    nxt = opt["next_id"]
                    visited[nxt] = True
                    if nxt not in all_nodes:
                        errors.append(f"Nodo '{node_id}': option[{i}] next_id '{nxt}' no existe")

    elif tipo == 3:
        pass
    else:
        errors.append(f"Nodo '{node_id}': tipo desconocido {tipo}")

    return errors

def main():
    print("=== Validador de Grafos de Dialogo ===")
    if not os.path.exists(DIALOGUE_DIR):
        print(f"ERROR: Directorio no encontrado: {DIALOGUE_DIR}")
        sys.exit(1)

    total = 0
    error_count = 0
    for fname in sorted(os.listdir(DIALOGUE_DIR)):
        if fname.endswith(".json"):
            total += 1
            fpath = os.path.join(DIALOGUE_DIR, fname)
            result = validate_dialogue(fpath)
            if result:
                error_count += 1
                for err in result:
                    print(f"  [ERROR] {fname}: {err}")
            else:
                print(f"  [OK] {fname}")

    print(f"\n=== Resultado: {total} archivos, {error_count} con errores ===")
    sys.exit(error_count)

if __name__ == "__main__":
    main()
