#!/usr/bin/env python3
"""
Generador de Referencias Cruzadas — Proyecto Isla Ancestral
Lee las dependencias de CHECKLIST-GLOBAL.md y genera:
1. Sección '## Módulos Relacionados' para cada módulo
2. Documento maestro de referencia cruzada
"""

import re
import os
from collections import defaultdict

# ============================================================
# 1. GRAFO DE DEPENDENCIAS (extraído de CHECKLIST-GLOBAL.md)
# ============================================================

# Mapa ID → (Nombre, Dependencias[])
MODULES = {
    1: ("Fundamentos del Proyecto", []),
    2: ("Visión y Concepto", [1]),
    3: ("Documentación del Proyecto", [1]),
    4: ("Game Engine", [1]),
    5: ("Lenguaje y Programación", [4]),
    6: ("Control de Versiones", [1]),
    7: ("Arquitectura General", [4]),
    8: ("Mundo Voxel", [7]),
    9: ("Terreno y Geografía", [8]),
    10: ("Generación del Mundo", [8]),
    11: ("Personaje del Jugador", [7]),
    12: ("Cámara", [11]),
    13: ("Herramientas", [11]),
    14: ("Inventario", [11]),
    15: ("Recursos", [14]),
    16: ("Crafting", [14, 15]),
    17: ("Construcción", [8, 14]),
    18: ("Casas", [17]),
    19: ("NPC y Vecinos", [11, 25]),
    20: ("Sistema de Amistad", [19]),
    21: ("Diálogos", [19]),
    22: ("Historia Principal", [21, 28]),
    23: ("Historias Secundarias", [22]),
    24: ("Templos y Puzzles", [13]),
    25: ("Ruinas", [24]),
    26: ("Templo Subterráneo", [24, 25]),
    27: ("Islas del Mundo", [28, 29]),
    28: ("Viajes", [22, 27]),
    29: ("Tiempo y Calendario", [7]),
    30: ("Reloj en Tiempo Real", [29]),
    31: ("Ciclo Día/Noche", [29]),
    32: ("Clima", [29, 31]),
    33: ("Agricultura", [17, 29]),
    34: ("Pesca", [32]),
    35: ("Minería", [8, 13]),
    36: ("Fauna", [7, 31]),
    37: ("Museos y Colecciones", [36]),
    38: ("Economía", [15, 16, 20]),
    39: ("Tiendas", [38]),
    40: ("Infraestructura", [38]),
    41: ("Música", []),
    42: ("Sonido Ambiental", [41]),
    43: ("Efectos de Sonido", [41]),
    44: ("ASMR y Feedback", [43]),
    45: ("Arte 3D", []),
    46: ("Arte 2D", [45]),
    47: ("Texturas y Materiales", [45]),
    48: ("Animación", [45, 11, 19]),
    49: ("Iluminación", [7, 45]),
    50: ("Vegetación", [8, 45]),
    51: ("Agua", [8, 24]),
    52: ("Partículas y VFX", [45]),
    53: ("UI/UX", [11, 14]),
    54: ("Mapa", [53]),
    55: ("Diario del Jugador", [53]),
    56: ("Fotografía", [53]),
    57: ("Interfaz de Control", [4]),
    58: ("Accesibilidad", [53, 57]),
    59: ("Guardado", [7, 14]),
    60: ("Datos y Serialización", [59]),
    61: ("Rendimiento", [8, 49]),
    62: ("Memoria", [61]),
    63: ("Cargas y Streaming", [8, 61]),
    64: ("IA de NPC", [19, 61]),
    65: ("Animales IA", [36, 64]),
    66: ("Anti-Softlock", [22, 26]),
    67: ("Vehículos", [28]),
    68: ("Transporte y Navegación", [28, 67]),
    69: ("Fast Travel", [28]),
    70: ("Interacciones", [11, 13]),
    71: ("Progresión", [22, 38]),
    72: ("Sistema de Logros", [71]),
    73: ("Coleccionables", [71, 36]),
    74: ("Eventos", [30, 29]),
    75: ("Postgame", [22]),
    76: ("Multijugador", []),
    77: ("Online y Red", [76]),
    78: ("Legal — Propiedad Intelectual", [1]),
    79: ("Legal — Contratos", [78]),
    80: ("Legal — Privacidad", [78]),
    81: ("Legal — Menores", [80]),
    82: ("Clasificación por Edades", [78]),
    83: ("Licencias de Software", [55, 117]),
    84: ("Música y Audio — Legal", [41, 78]),
    85: ("Modelos 3D — Legal", [45, 78]),
    86: ("IA Generativa", [78]),
    87: ("Localización", [21, 53]),
    88: ("Fuentes Tipográficas", [53]),
    89: ("Diseño de Menús", [53]),
    90: ("Configuración Gráfica", [53]),
    91: ("Configuración de Audio", [53]),
    92: ("Tutorial", [53, 70]),
    93: ("Balance", [38, 20]),
    94: ("Retención sin FOMO", [93]),
    95: ("Monetización", [38]),
    96: ("Plataformas", [4]),
    97: ("Steam / Store Page", [96]),
    98: ("Trailer", [97]),
    99: ("Marketing", [97]),
    100: ("Community Management", [99]),
    101: ("QA General", [110]),
    102: ("Bug Tracking", [101]),
    103: ("Logging", [4]),
    104: ("Analytics", [103]),
    105: ("Telemetría de Gameplay", [104]),
    106: ("Seguridad", [77]),
    107: ("Backups", [59]),
    108: ("Pipeline de Assets", [45]),
    109: ("Herramientas Internas", [4]),
    110: ("Debug Menu", [4]),
    111: ("Código de Calidad", [4]),
    112: ("Testing Automático", [111]),
    113: ("Pruebas de Stress", [112]),
    114: ("Playtest", [101, 137]),
    115: ("Hardware", [4, 61]),
    116: ("Instalador", []),
    117: ("Build System", [116]),
    118: ("CI/CD", [117]),
    119: ("Actualizaciones", [117, 59]),
    120: ("DLC y Expansiones", [95, 142]),
    121: ("Soporte Post-Lanzamiento", [142]),
    122: ("Crash Reporting", [103]),
    123: ("Modding", [117]),
    124: ("Contenido Generado por Usuarios", [123]),
    125: ("Términos de Servicio", [78]),
    126: ("Marketing Legal", [78]),
    127: ("Copyright del Juego", [78]),
    128: ("Identidad de Marca", [78]),
    129: ("Merchandising", [142]),
    130: ("Artbook", [45, 46, 128, 129, 131]),
    131: ("Créditos", [142]),
    132: ("Producción del Equipo", [134]),
    133: ("Gestión del Proyecto", [1]),
    134: ("Presupuesto", [133]),
    135: ("Riesgos del Proyecto", [133]),
    136: ("Roadmap", [133, 135]),
    137: ("Prototipo", [8, 11, 14, 59]),
    138: ("Vertical Slice", [137, 26, 19]),
    139: ("Pre-Alpha", [138]),
    140: ("Alpha", [139]),
    141: ("Beta", [140]),
    142: ("Release Candidate", [141]),
    143: ("Lanzamiento", [142, 97]),
    144: ("Después del Lanzamiento", [143]),
    145: ("Diseño de Experiencia", [1]),
    146: ("Diseño Emocional", [145]),
    147: ("World Building", [22]),
    148: ("Lore Ambiental", [147, 24]),
    149: ("Nombres y Nomenclatura", [147]),
    150: ("Diseño Sonoro Narrativo", [149]),
    151: ("Control Final", [143]),
    152: ("Principios Innegociables", [1]),
    153: ("Objetivo Final del Proyecto", [151]),
    154: ("Visión del Agente", [4, 103]),
    155: ("Vestimenta y Accesorios", [11, 14, 156]),
    156: ("Terrenos y Movimiento Diferenciado", [11, 155]),
    157: ("Medios de Transporte", [69, 22, 24, 19]),
    158: ("Herramientas y Desbloqueo de Zonas", [13, 38, 27, 28]),
    159: ("Catálogo de Objetos", [14, 16, 18, 45]),
    160: ("Diseño de Ubicaciones del Mundo", [27, 17, 18, 39, 159]),
    161: ("Diseño Visual de NPCs", [19, 159, 45, 46, 155]),
    162: ("Diálogos Contextuales de NPCs", [21, 22, 19, 161, 20, 29, 160]),
}

# ============================================================
# 2. CONSTRUIR GRAFO INVERSO (quién depende de mí)
# ============================================================

def build_reverse_graph(modules):
    """Para cada módulo, calcular qué otros módulos dependen de él."""
    reverse = defaultdict(list)  #Dependencias inversas: módulo → lista de módulos que lo usan
    for mod_id, (name, deps) in modules.items():
        for dep_id in deps:
            reverse[dep_id].append(mod_id)
    return reverse

# ============================================================
# 3. GENERAR SECCIÓN DE REFERENCIAS CRUZADAS
# ============================================================

def generate_cross_ref_section(mod_id, modules, reverse_graph):
    """Genera la sección 'Módulos Relacionados' para un módulo."""
    name = modules[mod_id][0]
    deps = modules[mod_id][1]  # Lo que ESTE módulo necesita
    dependents = reverse_graph.get(mod_id, [])  # Lo que NECESITA a ESTE módulo

    lines = []
    lines.append("## Módulos Relacionados")
    lines.append("")
    lines.append("> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.")
    lines.append("")

    # Dependencias directas (lo que yo necesito)
    if deps:
        lines.append("### Depende de (necesito su documentación)")
        lines.append("")
        lines.append("| Módulo | Qué aporta a este módulo |")
        lines.append("|--------|--------------------------|")
        for dep_id in sorted(deps):
            dep_name = modules[dep_id][0]
            relevance = get_relevance(mod_id, dep_id, modules)
            lines.append(f"| **M{dep_id:03d}** — {dep_name} | {relevance} |")
        lines.append("")

    # Dependientes inversos (quién necesita mi documentación)
    if dependents:
        lines.append("### Usado por (otros módulos que referencian este)")
        lines.append("")
        lines.append("| Módulo | Qué usa de este módulo |")
        lines.append("|--------|------------------------|")
        for dep_id in sorted(dependents):
            dep_name = modules[dep_id][0]
            relevance = get_reverse_relevance(mod_id, dep_id, modules)
            lines.append(f"| **M{dep_id:03d}** — {dep_name} | {relevance} |")
        lines.append("")

    # Relaciones laterales (módulos que comparten dependencias)
    siblings = get_siblings(mod_id, modules, reverse_graph)
    if siblings:
        lines.append("### Relacionados laterales (mismo dominio)")
        lines.append("")
        lines.append("| Módulo | Relación |")
        lines.append("|--------|----------|")
        for sib_id, relation in siblings:
            sib_name = modules[sib_id][0]
            lines.append(f"| **M{sib_id:03d}** — {sib_name} | {relation} |")
        lines.append("")

    return "\n".join(lines)


def get_relevance(mod_id, dep_id, modules):
    """Describe qué aporta dep_id a mod_id."""
    # Mapa de relevancia predefinido para las relaciones más importantes
    relevance_map = {
        # Fundamentos
        (2, 1): "Visión del proyecto y filosofía",
        (3, 1): "Convenciones de documentación",
        (4, 1): "Decisiones de motor y plataforma",
        (6, 1): "Flujos de versionado",
        (78, 1): "Marco legal general",
        (133, 1): "Estructura de gestión",
        (145, 1): "Player journey y onboarding",
        (152, 1): "Principios innegociables del proyecto",
        # Engine
        (5, 4): "Convenciones GDScript y patrones",
        (7, 4): "Service Locator, capas, EventBus",
        (57, 4): "Sistema de acciones de entrada",
        (96, 4): "Soporte multiplataforma",
        (103, 4): "Logging y categorías",
        (109, 4): "Editores del editor",
        (110, 4): "Panel de debug",
        (111, 4): "Guía de estilo y calidad",
        (115, 4): "Detección de hardware",
        (154, 4): "Vías de visión del agente",
        # Arquitectura
        (8, 7): "Voxel Engine, chunks, bloques",
        (11, 7): "FSM del jugador, hitbox",
        (29, 7): "GameClock como servicio puro",
        (36, 7): "Sistema de fauna y comportamientos",
        (49, 7): "Presupuestos de iluminación",
        (61, 7): "Frame budget y benchmarks",
        # Voxel
        (9, 8): "Biomas, terreno, formaciones",
        (10, 8): "Pipeline de generación procedural",
        (17, 8): "Construcción sobre bloques",
        (35, 8): "Extracción de minerales",
        (50, 8): "Vegetación por bioma",
        (51, 8): "Agua por chunks",
        (63, 8): "Streaming de chunks",
        # Player
        (11, 7): "FSM, hitbox, interacción",
        (12, 11): "Cámara seguimiento",
        (13, 11): "Herramientas en mano",
        (14, 11): "Inventario del jugador",
        (48, 11): "Animaciones del personaje",
        (53, 11): "UI del jugador",
        (70, 11): "Sistema de interacciones",
        (137, 11): "Prototipo con jugador",
        (155, 11): "Vestimenta del jugador",
        (156, 11): "Movimiento por terreno",
        # Herramientas
        (24, 13): "Puzzles que requieren herramientas",
        (35, 13): "Minería con herramientas",
        (70, 13): "Interacciones con herramientas",
        (158, 13): "Progresión de tiers T1-T4",
        # Inventario
        (14, 11): "Capacidad y slots del jugador",
        (15, 14): "Recursos almacenados",
        (16, 14): "Materiales de crafting",
        (17, 14): "Materiales de construcción",
        (59, 14): "Persistencia de inventario",
        (137, 14): "Inventario en prototipo",
        (159, 14): "Catálogo de objetos",
        # NPC
        (19, 11): "Rutinas y personalidades",
        (19, 25): "NPCs en ruinas",
        (20, 19): "Sistema de amistad",
        (21, 19): "Motor de diálogos",
        (48, 19): "Animaciones de NPCs",
        (64, 19): "IA de rutinas",
        (138, 19): "NPCs en vertical slice",
        (157, 19): "NPCs en transporte",
        (161, 19): "Diseño visual de NPCs",
        (162, 19): "Diálogos contextuales",
        # Diálogos
        (22, 21): "Historia en diálogos",
        (23, 21): "Misiones secundarias",
        (87, 21): "Textos localizables",
        (162, 21): "Contenido de diálogos por capítulo",
        # Historia
        (22, 21): "Trama principal en nodos",
        (22, 28): "Viajes narrativos",
        (23, 22): "Secuelas de la historia",
        (66, 22): "Anti-softlock narrativo",
        (71, 22): "Progresión de la historia",
        (75, 22): "Postgame después de la historia",
        (147, 22): "World building y lore",
        (157, 22): "Viajes narrativos en transporte",
        # Tiempo
        (29, 7): "GameClock servicio puro",
        (30, 29): "Widget de reloj",
        (31, 29): "Ciclo día/noche",
        (32, 29): "Clima depende de tiempo",
        (33, 29): "Cultivos por estación",
        (74, 29): "Eventos calendario",
        (162, 29): "Diálogos por hora/estación",
        # Economía
        (38, 15): "Precios de recursos",
        (38, 16): "Costos de crafting",
        (38, 20): "Precios por amistad",
        (39, 38): "Tiendas con precios",
        (40, 38): "Infraestructura económica",
        (71, 38): "Progresión económica",
        (93, 38): "Balance de economía",
        (95, 38): "Monetización",
        (158, 38): "Precios de herramientas",
        # Arte
        (46, 45): "Estilo 2D hereda del 3D",
        (47, 45): "Texturas de modelos",
        (48, 45): "Sockets de animación",
        (49, 45): "Luces en escenas",
        (50, 45): "Modelos de vegetación",
        (52, 45): "Partículas sobre modelos",
        (108, 45): "Pipeline de assets 3D",
        (159, 45): "Modelos de objetos",
        (161, 45): "Modelos de NPCs",
        # UI
        (53, 11): "UI del jugador",
        (53, 14): "Inventario en UI",
        (54, 53): "Mapa en UI",
        (55, 53): "Diario en UI",
        (56, 53): "Fotografía en UI",
        (58, 53): "Accesibilidad UI",
        (87, 53): "Textos localizados en UI",
        (88, 53): "Fuentes en UI",
        (89, 53): "Menús",
        (90, 53): "Configuración gráfica",
        (91, 53): "Configuración de audio",
        (92, 53): "Tutorial en UI",
        # Audio
        (42, 41): "Ambiente sobre música base",
        (43, 41): "SFX sobre familia tonal",
        (44, 43): "ASMR con SFX",
        (84, 41): "Legal de música",
        (150, 149): "Nombres en diseño sonoro",
        # Rendimiento
        (61, 8): "Presupuestos de chunks",
        (61, 49): "Presupuestos de iluminación",
        (62, 61): "Gestión de memoria",
        (63, 61): "Streaming optimizado",
        (64, 61): "IA dentro de budget",
        (115, 61): "Ajuste por hardware",
        # IA
        (64, 19): "IA de NPCs",
        (64, 61): "IA dentro de frame budget",
        (65, 36): "IA de animales",
        (65, 64): "Patrones de IA reutilizados",
        # Build
        (83, 117): "Licencias en build",
        (117, 116): "Build system sobre instalador",
        (118, 117): "CI/CD sobre build",
        (119, 117): "Updates con build",
        (123, 117): "Modding con build",
        # Progresión
        (71, 22): "Historia como guía",
        (71, 38): "Economía como recompensa",
        (72, 71): "Logros sobre progresión",
        (73, 71): "Coleccionables sobre progresión",
        (93, 38): "Balance de progresión",
        (94, 93): "Retención sobre balance",
        # Producción
        (134, 133): "Presupuesto de gestión",
        (135, 133): "Riesgos de gestión",
        (136, 133): "Roadmap de gestión",
        (137, 136): "Prototipo según roadmap",
        # Release
        (139, 138): "Pre-Alpha sobre vertical slice",
        (140, 139): "Alpha sobre pre-alpha",
        (141, 140): "Beta sobre alpha",
        (142, 141): "RC sobre beta",
        (143, 142): "Lanzamiento sobre RC",
        (143, 97): "Lanzamiento en Steam",
        (144, 143): "Post-lanzamiento",
        (151, 143): "Control final post-lanzamiento",
        # Lore
        (148, 147): "Lore ambiental en world building",
        (149, 147): "Nombres en world building",
        (150, 149): "Sonido narrativo con nombres",
        # Herramientas avanzadas
        (155, 11): "Vestimenta sobre jugador",
        (155, 14): "Vestimenta en inventario",
        (155, 156): "Vestimenta y terreno",
        (156, 11): "Terrenos sobre movimiento",
        (156, 155): "Terrenos y vestimenta",
        (157, 69): "Transporte y fast travel",
        (157, 22): "Transporte narrativo",
        (157, 24): "Transporte y templos",
        (157, 19): "Transporte con NPCs",
        (158, 13): "Herramientas T1-T4",
        (158, 38): "Precios de herramientas",
        (158, 27): "Gates por isla",
        (158, 28): "Gates por viaje",
        (159, 14): "Objetos en inventario",
        (159, 16): "Objetos de crafting",
        (159, 18): "Objetos en casas",
        (159, 45): "Modelos 3D de objetos",
        (160, 27): "Ubicaciones por isla",
        (160, 17): "Ubicaciones y construcción",
        (160, 18): "Ubicaciones y casas",
        (160, 39): "Ubicaciones y tiendas",
        (160, 159): "Objetos en ubicaciones",
        (161, 19): "NPCs y su visual",
        (161, 159): "Herramientas en mano (M159)",
        (161, 45): "Modelos 3D de NPCs",
        (161, 46): "Retratos 2D de NPCs",
        (161, 155): "Ropa de NPCs",
        (161, 160): "NPCs en ubicaciones",
        (162, 21): "Motor de diálogos",
        (162, 22): "Contenido por capítulo",
        (162, 19): "Personalidades de NPCs",
        (162, 161): "NPCs referenciados",
        (162, 20): "Condiciones de amistad",
        (162, 29): "Condiciones de tiempo",
        (162, 160): "Condiciones de ubicación",
    }

    key = (mod_id, dep_id)
    if key in relevance_map:
        return relevance_map[key]

    # Fallback genérico
    mod_name = modules[mod_id][0]
    dep_name = modules[dep_id][0]
    return f"Base para {dep_name.lower()}"


def get_reverse_relevance(mod_id, dep_id, modules):
    """Describe qué usa dep_id de mod_id."""
    relevance_map = {
        # Quién usa a Fundamentos
        (1, 2): "Visión y concepto del proyecto",
        (1, 3): "Convenciones de documentación",
        (1, 4): "Decisiones de motor",
        (1, 6): "Versionado",
        (1, 78): "Marco legal",
        (1, 133): "Gestión del proyecto",
        (1, 145): "Diseño de experiencia",
        (1, 152): "Principios innegociables",
        # Quién usa a Game Engine
        (4, 5): "Convenciones GDScript",
        (4, 7): "Arquitectura del engine",
        (4, 57): "Sistema de entrada",
        (4, 96): "Multiplataforma",
        (4, 103): "Logging",
        (4, 109): "Herramientas internas",
        (4, 110): "Debug menu",
        (4, 111): "Código de calidad",
        (4, 115): "Hardware",
        (4, 154): "Visión del agente",
        # Quién usa a Arquitectura
        (7, 8): "Mundo voxel",
        (7, 11): "Personaje",
        (7, 29): "Tiempo/calendario",
        (7, 36): "Fauna",
        (7, 49): "Iluminación",
        (7, 61): "Rendimiento",
        # Quién usa a Mundo Voxel
        (8, 9): "Terreno y geografía",
        (8, 10): "Generación del mundo",
        (8, 17): "Construcción",
        (8, 35): "Minería",
        (8, 50): "Vegetación",
        (8, 51): "Agua",
        (8, 63): "Cargas y streaming",
        (8, 137): "Prototipo",
        # Quién usa a Personaje
        (11, 12): "Cámara",
        (11, 13): "Herramientas",
        (11, 14): "Inventario",
        (11, 48): "Animación",
        (11, 53): "UI/UX",
        (11, 70): "Interacciones",
        (11, 137): "Prototipo",
        (11, 155): "Vestimenta",
        (11, 156): "Terrenos",
        # Quién usa a Inventario
        (14, 15): "Recursos",
        (14, 16): "Crafting",
        (14, 17): "Construcción",
        (14, 59): "Guardado",
        (14, 137): "Prototipo",
        (14, 159): "Catálogo de objetos",
        # Quién usa a NPC
        (19, 20): "Amistad",
        (19, 21): "Diálogos",
        (19, 48): "Animación de NPCs",
        (19, 64): "IA de NPCs",
        (19, 138): "Vertical slice",
        (19, 157): "Transporte",
        (19, 161): "Diseño visual",
        (19, 162): "Diálogos contextuales",
        # Quién usa a Diálogos
        (21, 22): "Historia principal",
        (21, 23): "Historias secundarias",
        (21, 87): "Localización",
        (21, 162): "Diálogos contextuales",
        # Quién usa a Historia Principal
        (22, 23): "Historias secundarias",
        (22, 66): "Anti-softlock",
        (22, 71): "Progresión",
        (22, 75): "Postgame",
        (22, 147): "World building",
        (22, 157): "Transporte narrativo",
        # Quién usa a Tiempo
        (29, 30): "Reloj en tiempo real",
        (29, 31): "Ciclo día/noche",
        (29, 32): "Clima",
        (29, 33): "Agricultura",
        (29, 74): "Eventos",
        (29, 162): "Diálogos por hora/estación",
        # Quién usa a Economía
        (38, 39): "Tiendas",
        (38, 40): "Infraestructura",
        (38, 71): "Progresión",
        (38, 93): "Balance",
        (38, 95): "Monetización",
        (38, 158): "Herramientas y zonas",
        # Quién usa a Arte 3D
        (45, 46): "Arte 2D",
        (45, 47): "Texturas y materiales",
        (45, 48): "Animación",
        (45, 49): "Iluminación",
        (45, 50): "Vegetación",
        (45, 52): "Partículas y VFX",
        (45, 108): "Pipeline de assets",
        (45, 159): "Catálogo de objetos",
        (45, 161): "Diseño visual de NPCs",
        # Quién usa a UI/UX
        (53, 54): "Mapa",
        (53, 55): "Diario",
        (53, 56): "Fotografía",
        (53, 58): "Accesibilidad",
        (53, 87): "Localización",
        (53, 88): "Fuentes tipográficas",
        (53, 89): "Diseño de menús",
        (53, 90): "Configuración gráfica",
        (53, 91): "Configuración de audio",
        (53, 92): "Tutorial",
        # Quién usa a Rendimiento
        (61, 62): "Memoria",
        (61, 63): "Cargas y streaming",
        (61, 64): "IA de NPCs",
        (61, 115): "Hardware",
        # Quiénusa Build System
        (117, 83): "Licencias en build",
        (117, 118): "CI/CD",
        (117, 119): "Actualizaciones",
        (117, 123): "Modding",
        # Quién usa a Progresión
        (71, 72): "Logros",
        (71, 73): "Coleccionables",
        # Quién usa a Roadmap
        (133, 134): "Presupuesto",
        (133, 135): "Riesgos",
        (133, 136): "Roadmap",
        # Quién usa a release stages
        (138, 139): "Pre-Alpha",
        (139, 140): "Alpha",
        (140, 141): "Beta",
        (141, 142): "Release Candidate",
        (142, 143): "Lanzamiento",
        (143, 144): "Después del lanzamiento",
        (143, 151): "Control final",
        # World building
        (147, 148): "Lore ambiental",
        (147, 149): "Nombres y nomenclatura",
        (149, 150): "Diseño sonoro narrativo",
    }

    key = (mod_id, dep_id)
    if key in relevance_map:
        return relevance_map[key]

    return f"Usado por {modules[dep_id][0].lower()}"


def get_siblings(mod_id, modules, reverse_graph):
    """Encuentra módulos en el mismo dominio (comparten dependencias similares)."""
    my_deps = set(modules[mod_id][1])
    my_name = modules[mod_id][0]

    siblings = []
    for other_id, (other_name, other_deps) in modules.items():
        if other_id == mod_id:
            continue
        other_deps_set = set(other_deps)
        # Si comparten al menos 2 dependencias O uno depende del otro
        shared = my_deps & other_deps_set
        if len(shared) >= 2 or mod_id in other_deps or other_id in my_deps:
            # Determinar la relación
            if other_id in my_deps:
                relation = f"Depende de este módulo"
            elif mod_id in other_deps:
                relation = f"Este módulo lo necesita"
            elif len(shared) >= 2:
                shared_names = ", ".join(f"M{s:03d}" for s in sorted(shared)[:3])
                relation = f"Comparten dependencias ({shared_names})"
            else:
                relation = "Mismo dominio"
            siblings.append((other_id, relation))

    # Limitar a 8 para no saturar
    siblings.sort(key=lambda x: x[0])
    return siblings[:8]


# ============================================================
# 4. GENERAR DOCUMENTO MAESTRO
# ============================================================

def generate_master_reference(modules, reverse_graph):
    """Genera el documento maestro de referencia cruzada."""
    lines = []
    lines.append("**Modelo:** MiMo V2.5")
    lines.append("**Plataforma:** OpenCode")
    lines.append("")
    lines.append("# Referencia Cruzada Maestra — Todos los Módulos")
    lines.append("")
    lines.append("> **Propósito:** Al trabajar en cualquier módulo, consultar rápidamente qué otros módulos necesita y qué otros módulos lo usan.")
    lines.append(">")
    lines.append("> **Cómo usar:** Buscá el módulo en la tabla, identificá las dependencias y abrí solo esos archivos.")
    lines.append("")
    lines.append("---")
    lines.append("")

    # Agrupar por dominio
    domains = {
        "CORE (Fundamentos, Engine, Arquitectura)": [1, 2, 3, 4, 5, 6, 7],
        "MUNDO (Voxel, Terreno, Generación)": [8, 9, 10],
        "JUGADOR (Personaje, Cámara, Herramientas, Inventario)": [11, 12, 13, 14, 15, 16],
        "CONSTRUCCIÓN Y HOGAR": [17, 18],
        "NPCS Y RELACIONES": [19, 20, 21, 161, 162],
        "HISTORIA Y NARRATIVA": [22, 23, 147, 148, 149, 150],
        "TEMPLOS Y PUZZLES": [24, 25, 26],
        "ISLAS Y VIAJES": [27, 28, 67, 68, 69, 157],
        "TIEMPO Y CLIMA": [29, 30, 31, 32],
        "ACTIVIDADES (Agricultura, Pesca, Minería)": [33, 34, 35, 36, 37],
        "ECONOMÍA Y TIENDAS": [38, 39, 40],
        "AUDIO (Música, SFX, Ambiente)": [41, 42, 43, 44],
        "ARTE (3D, 2D, Texturas, Animación)": [45, 46, 47, 48, 49, 50, 51, 52],
        "UI/UX Y ACCESIBILIDAD": [53, 54, 55, 56, 57, 58, 88, 89, 90, 91],
        "PERSISTENCIA Y RENDIMIENTO": [59, 60, 61, 62, 63],
        "IA": [64, 65],
        "SISTEMAS DE JUEGO": [66, 70, 71, 72, 73, 74, 75, 92, 93, 94],
        "MULTIJUGADOR Y RED": [76, 77, 106],
        "LEGAL": [78, 79, 80, 81, 82, 83, 84, 85, 86, 125, 126, 127],
        "LOCALIZACIÓN E IDENTIDAD": [87, 128, 130],
        "MONETIZACIÓN Y PLATAFORMAS": [95, 96, 97, 98, 99, 100, 120, 121, 129],
        "CALIDAD Y TESTING": [101, 102, 103, 104, 105, 107, 110, 111, 112, 113, 114, 122],
        "HARDWARE Y BUILD": [115, 116, 117, 118, 119, 123, 124],
        "PRODUCCIÓN Y GESTIÓN": [131, 132, 133, 134, 135, 136],
        "HITOS DE LANZAMIENTO": [137, 138, 139, 140, 141, 142, 143, 144],
        "DISEÑO EXPERIENCIA": [145, 146, 151, 152, 153, 154],
        "MÓDULOS AVANZADOS (155-162)": [155, 156, 158, 159, 160],
    }

    for domain_name, mod_ids in domains.items():
        lines.append(f"## {domain_name}")
        lines.append("")
        lines.append("| ID | Módulo | Depende de | Usado por |")
        lines.append("|----|--------|------------|-----------|")
        for mod_id in sorted(mod_ids):
            if mod_id not in modules:
                continue
            name = modules[mod_id][0]
            deps = modules[mod_id][1]
            dependents = reverse_graph.get(mod_id, [])
            deps_str = ", ".join(f"M{d:03d}" for d in sorted(deps)) if deps else "—"
            deps_str = deps_str[:60] + "..." if len(deps_str) > 60 else deps_str
            dep_str = ", ".join(f"M{d:03d}" for d in sorted(dependents)) if dependents else "—"
            dep_str = dep_str[:60] + "..." if len(dep_str) > 60 else dep_str
            lines.append(f"| {mod_id:03d} | {name} | {deps_str} | {dep_str} |")
        lines.append("")

    # Mapa de módulos más referenciados
    lines.append("---")
    lines.append("")
    lines.append("## Top 20 Módulos Más Referenciados")
    lines.append("")
    lines.append("> Estos módulos son los que más veces aparecen como dependencia. Conocerlos bien acelera todo el desarrollo.")
    lines.append("")
    lines.append("| Pos | ID | Módulo | Veces referenciado |")
    lines.append("|-----|----|--------|--------------------|")
    ref_count = []
    for mod_id in modules:
        count = len(reverse_graph.get(mod_id, []))
        ref_count.append((mod_id, count))
    ref_count.sort(key=lambda x: -x[1])
    for pos, (mod_id, count) in enumerate(ref_count[:20], 1):
        name = modules[mod_id][0]
        lines.append(f"| {pos} | {mod_id:03d} | {name} | {count} |")
    lines.append("")

    # Mapa de flujo de trabajo
    lines.append("---")
    lines.append("")
    lines.append("## Flujo de Trabajo: Qué leer antes de codificar")
    lines.append("")
    lines.append("| Estoy trabajando en... | Lee primero... | Luego... |")
    lines.append("|------------------------|----------------|----------|")
    lines.append("| Cualquier cosa nueva | M001 (Fundamentos), M152 (Principios) | M004 (Engine), M007 (Arquitectura) |")
    lines.append("| Un sistema de gameplay | M011 (Personaje), M014 (Inventario) | El módulo específico + sus dependencias |")
    lines.append("| NPCs o diálogos | M019 (NPCs), M021 (Diálogos) | M161 (Visual NPCs), M162 (Diálogos Contextuales) |")
    lines.append("| Historia o narrativa | M022 (Historia), M147 (World Building) | M023 (Secundarias), M148 (Lore) |")
    lines.append("| Economía o tiendas | M038 (Economía), M039 (Tiendas) | M093 (Balance), M158 (Herramientas) |")
    lines.append("| Arte o assets | M045 (Arte 3D), M108 (Pipeline) | M046-052 (subdominios de arte) |")
    lines.append("| UI o menús | M053 (UI/UX), M089 (Menús) | M058 (Accesibilidad), M087 (Localización) |")
    lines.append("| Rendimiento | M061 (Rendimiento), M062 (Memoria) | M063 (Streaming), M115 (Hardware) |")
    lines.append("| IA de NPCs | M064 (IA NPC), M019 (NPCs) | M065 (Animales), M061 (Rendimiento) |")
    lines.append("| Build y deploy | M117 (Build), M118 (CI/CD) | M116 (Instalador), M083 (Licencias) |")
    lines.append("| World building | M147 (WB), M149 (Nombres) | M148 (Lore), M022 (Historia) |")
    lines.append("| Módulos nuevos 155-162 | M155-M162 específicos | M11, M14, M19, M21, M22 como base |")
    lines.append("")

    return "\n".join(lines)


# ============================================================
# 5. MAIN — Generar todo
# ============================================================

def main():
    project_root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
    doc_dir = os.path.join(project_root, "DOCUMENTACION")

    print("=== Generador de Referencias Cruzadas ===")
    print(f"Proyecto: {project_root}")
    print(f"Módulos: {len(MODULES)}")
    print()

    # Construir grafo inverso
    reverse_graph = build_reverse_graph(MODULES)
    print(f"Grafo inverso construido: {len(reverse_graph)} módulos con dependientes")

    # Generar documento maestro
    master_content = generate_master_reference(MODULES, reverse_graph)
    master_path = os.path.join(doc_dir, "00-REFERENCIA-CRUZADA-MAESTRA.md")
    with open(master_path, "w", encoding="utf-8") as f:
        f.write(master_content)
    print(f"Documento maestro creado: {master_path}")

    # Generar secciones para cada módulo
    success = 0
    errors = []
    # Pre-cargar todas las carpetas de módulos
    all_folders = {}
    for entry in os.listdir(doc_dir):
        full_path = os.path.join(doc_dir, entry)
        if os.path.isdir(full_path) and entry[0].isdigit():
            # Extraer número del inicio del nombre
            match = re.match(r'^(\d+)', entry)
            if match:
                num = int(match.group(1))
                all_folders[num] = entry

    for mod_id in sorted(MODULES.keys()):
        name = MODULES[mod_id][0]
        # Buscar carpeta del módulo
        folder_found = all_folders.get(mod_id)

        if not folder_found:
            errors.append(f"M{mod_id:03d} ({name}): carpeta no encontrada")
            continue

        # Buscar 01-Requerimientos.md en plan-actual
        req_path = os.path.join(doc_dir, folder_found, "plan-actual", "01-Requerimientos.md")
        if not os.path.exists(req_path):
            # Intentar plan-inicial
            req_path = os.path.join(doc_dir, folder_found, "plan-inicial", "01-Requerimientos.md")
        if not os.path.exists(req_path):
            errors.append(f"M{mod_id:03d} ({name}): 01-Requerimientos.md no encontrado")
            continue

        # Leer archivo actual
        with open(req_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Verificar si ya tiene la sección
        if "## Módulos Relacionados" in content:
            print(f"  M{mod_id:03d} ({name}): ya tiene referencias, saltando")
            success += 1
            continue

        # Generar sección
        section = generate_cross_ref_section(mod_id, MODULES, reverse_graph)

        # Agregar al final del archivo
        if not content.endswith("\n"):
            content += "\n"
        content += "\n---\n\n" + section + "\n"

        # Escribir
        with open(req_path, "w", encoding="utf-8") as f:
            f.write(content)

        success += 1
        print(f"  M{mod_id:03d} ({name}): referencias agregadas")

    print()
    print(f"=== Resultado ===")
    print(f"Exitosos: {success}/{len(MODULES)}")
    if errors:
        print(f"Errores ({len(errors)}):")
        for e in errors:
            print(f"  - {e}")
    print(f"Documento maestro: {master_path}")


if __name__ == "__main__":
    main()
