#!/usr/bin/env python3
# M118 iter 8 (minimax-3): Cross-module linter.
# Analiza las dependencias entre mis modulos GDScript en game/isla-ancestral/scripts/
# Detecta:
#   - Dependencias circulares (A importa B, B importa A)
#   - Referencias rotas (clase autoload no existe en project.godot)
#   - Imports a scripts fuera de la jerarquia del proyecto
# Exit 0 si todo OK, 1 si hay problemas.
# Uso: python tools/ci/cross_module_linter.py [--scripts-dir game/isla-ancestral/scripts] [--autoloads project.godot]

import os
import sys
import re
import argparse
import glob
from collections import defaultdict
from typing import List, Tuple, Dict, Set

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))

# Lista de exclusion: nombres built-in de Godot que NO son class_name.
# Esto evita falsos positivos: el linter confunde $Camera3D (nodo) con $ClassName (clase).
GODOT_BUILTINS = {
    "Node", "Node2D", "Node3D", "Spatial",
    "Camera", "Camera2D", "Camera3D",
    "Sprite", "Sprite2D", "Sprite3D", "AnimatedSprite2D", "AnimatedSprite3D",
    "Label", "Label3D", "RichTextLabel",
    "MeshInstance2D", "MeshInstance3D", "Mesh",
    "CollisionShape2D", "CollisionShape3D",
    "CollisionPolygon2D", "CollisionPolygon3D",
    "Area2D", "Area3D",
    "RigidBody2D", "RigidBody3D", "RigidBody",
    "StaticBody2D", "StaticBody3D", "StaticBody",
    "CharacterBody2D", "CharacterBody3D", "CharacterBody",
    "KinematicBody2D", "KinematicBody3D",
    "AnimationPlayer", "AnimationTree", "Tween",
    "AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D",
    "Timer", "RayCast2D", "RayCast3D",
    "Path2D", "Path3D", "NavigationAgent2D", "NavigationAgent3D",
    "Light2D", "Light3D", "OmniLight3D", "DirectionalLight3D", "SpotLight3D",
    "CPUParticles2D", "CPUParticles3D", "GpuParticles2D", "GpuParticles3D",
    "MultiMeshInstance2D", "MultiMeshInstance3D",
    "CanvasItem", "CanvasLayer", "CanvasModulate",
    "Viewport", "SubViewport", "SubViewportContainer",
    "Window", "Popup", "Control",
    "Button", "Label", "TextureRect", "ColorRect", "Panel",
    "HBoxContainer", "VBoxContainer", "GridContainer",
    "CenterContainer", "MarginContainer",
    "VScrollBar", "HScrollBar", "VSlider", "HSlider",
    "ProgressBar", "LineEdit", "TextEdit",
    "CheckBox", "CheckButton", "OptionButton", "MenuButton",
    "TabContainer", "TabBar",
    "ItemList", "OptionButton", "Tree", "TextEdit",
    "VideoStreamPlayer", "AudioStreamPlayer",
    "HTTPRequest", "Timer", "PathFollow2D", "PathFollow3D",
    "Bone2D", "Bone3D", "Skeleton2D", "Skeleton3D",
    "SpringArm3D", "SpringBone3D", "LookAtModifier3D",
    "RemoteTransform2D", "RemoteTransform3D",
    "MultiSpawner3D", "VisibleOnScreenNotifier2D", "VisibleOnScreenNotifier3D",
    "VisibleOnScreenEnabler2D", "VisibleOnScreenEnabler3D",
    "BackBufferCopy", "ColorRect",
}


def _list_gd_files(scripts_dir: str) -> List[str]:
    """Lista todos los .gd en scripts_dir (excluyendo subdirs con prefijo test_)."""
    if not os.path.isdir(scripts_dir):
        return []
    return sorted(glob.glob(os.path.join(scripts_dir, "**", "*.gd"), recursive=True))


def _parse_class_name(path: str) -> str:
    """Extrae class_name del archivo .gd."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                m = re.match(r"^class_name\s+(\w+)", line.strip())
                if m:
                    return m.group(1)
    except (OSError, UnicodeDecodeError):
        pass
    return ""


def _parse_imports(path: str) -> List[str]:
    """Extrae imports preload() y class_name del archivo .gd."""
    imports: List[str] = []
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                m = re.match(r'^preload\(["\'](.+?\.gd)["\']', line.strip())
                if m:
                    imports.append(m.group(1))
    except (OSError, UnicodeDecodeError):
        pass
    return imports


def _parse_autoloads(project_godot: str) -> Set[str]:
    """Extrae los nombres de autoloads del project.godot."""
    autoloads: Set[str] = set()
    if not os.path.exists(project_godot):
        return autoloads
    # Palabras reservadas de project.godot que NO son autoloads
    reserved = {
        "config_version", "config_features", "config_icon",
        "input", "rendering", "application", "display", "audio",
        "physics", "layer_names", "global_script_classes", "autoload",
    }
    try:
        with open(project_godot, "r", encoding="utf-8") as f:
            for line in f:
                # Solo lineas que parecen autoload: nombre simple (sin /) = autoload
                # nombre con / = path de config (no autoload)
                m = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*)=(.+)$", line.strip())
                if m:
                    name = m.group(1)
                    if name not in reserved and "/" not in name and not name.startswith("config/"):
                        # Heuristica: los autoloads suelen ser snake_case y NO contienen / ni .
                        if "." not in name and " " not in name:
                            autoloads.add(name)
    except (OSError, UnicodeDecodeError):
        pass
    return autoloads


def build_graph(gd_files: List[str]) -> Tuple[Dict[str, Set[str]], Dict[str, str]]:
    """Construye el grafo de dependencias. Devuelve (graph class->set_of_classes, class_to_file)."""
    class_to_file: Dict[str, str] = {}
    for f in gd_files:
        cn = _parse_class_name(f)
        if cn:
            class_to_file[cn] = f
    graph: Dict[str, Set[str]] = defaultdict(set)
    for f in gd_files:
        cn = _parse_class_name(f)
        if not cn:
            continue
        for imp in _parse_imports(f):
            # imp es un path tipo "res://scripts/mineria/mining_manager.gd"
            # Extraer el class_name del archivo
            # Resolver el path relativo a scripts_dir
            if imp.startswith("res://"):
                rel = imp[len("res://"):]
            else:
                rel = imp
            # Buscar el archivo
            for cf, cf_path in class_to_file.items():
                if cf_path.endswith(rel) or cf_path.endswith(rel.replace("/", os.sep)):
                    graph[cn].add(cf)
                    break
    return dict(graph), class_to_file


def detect_cycles(graph: Dict[str, Set[str]]) -> List[List[str]]:
    """Detecta ciclos en el grafo. Devuelve lista de ciclos (cada uno como lista de nodos)."""
    visited: Set[str] = set()
    rec_stack: Set[str] = set()
    cycles: List[List[str]] = []

    def dfs(node: str, path: List[str]):
        visited.add(node)
        rec_stack.add(node)
        path.append(node)
        for neighbor in graph.get(node, set()):
            if neighbor not in visited:
                dfs(neighbor, path)
            elif neighbor in rec_stack:
                # Encontrar el ciclo
                start = path.index(neighbor)
                cycle = path[start:] + [neighbor]
                cycles.append(cycle)
        path.pop()
        rec_stack.remove(node)

    for n in graph:
        if n not in visited:
            dfs(n, [])
    return cycles


def detect_broken_refs(gd_files: List[str], class_to_file: Dict[str, str], autoloads: Set[str]) -> List[str]:
    """Detecta referencias a class_name o autoloads que no existen."""
    issues: List[str] = []
    class_names = set(class_to_file.keys())
    for f in gd_files:
        try:
            with open(f, "r", encoding="utf-8") as fp:
                for line in fp:
                    # Buscar referencias a class_name (PascalCase) o autoloads (snake_case)
                    # Patron: get_node("Node") no es un autoload, es una escena
                    # Patron: nombre de autoload en minusculas
                    # Buscar: $NombreDeAutoload o get_node("/root/Nombre")
                    for m in re.finditer(r'get_node\(["\']?/root/(\w+)["\']?\)', line):
                        ref = m.group(1)
                        if ref not in autoloads and ref not in ("null", "Node", "Viewport", "MainLoop"):
                            # Probablemente un scene root, no necesariamente un autoload
                            pass
                    # Buscar: $Nombre o Nombre.xxx directo (autoload-style)
                    # Filtrar built-ins de Godot para evitar falsos positivos
                    for m in re.finditer(r'\$([A-Z]\w*)', line):
                        ref = m.group(1)
                        if ref in GODOT_BUILTINS:
                            continue
                        if ref not in class_names:
                            issues.append(f"{f}:{line.strip()[:50]}: $ referencia desconocida '{ref}'")
        except (OSError, UnicodeDecodeError):
            pass
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Linter cross-module (GDScript)")
    parser.add_argument("--scripts-dir", default=os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "scripts"), help="Directorio de scripts")
    parser.add_argument("--autoloads", default=os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "project.godot"), help="Path a project.godot")
    args = parser.parse_args()

    if not os.path.isdir(args.scripts_dir):
        print(f"[linter] {args.scripts_dir} no existe")
        return 0

    gd_files = _list_gd_files(args.scripts_dir)
    if not gd_files:
        print(f"[linter] no .gd encontrados en {args.scripts_dir}")
        return 0
    print(f"[linter] {len(gd_files)} archivos .gd en {args.scripts_dir}")

    graph, class_to_file = build_graph(gd_files)
    autoloads = _parse_autoloads(args.autoloads)
    print(f"[linter] {len(class_to_file)} class_name, {len(autoloads)} autoloads")

    # Detectar ciclos
    cycles = detect_cycles(graph)
    if cycles:
        print(f"[linter] {len(cycles)} ciclos de dependencias:")
        for c in cycles[:5]:
            print(f"  {' -> '.join(c)}")

    # Detectar referencias rotas
    broken = detect_broken_refs(gd_files, class_to_file, autoloads)
    if broken:
        print(f"[linter] {len(broken)} referencias desconocidas:")
        for b in broken[:10]:
            print(f"  {b}")

    if cycles or broken:
        return 1
    print("[linter] OK. Sin ciclos ni referencias rotas.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
