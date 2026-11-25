import io
import os

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# 1. HY4 Flash b60
p1 = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/60-Backlog-Q-Restantes-Top10.md'
c1 = """# 60 - [?] Restantes: Top 10 modulos (round 2)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 09:00
**Nicho:** Root-cause + Volumen
**Tareas:** 10

## Contexto

b59 CERRADA. 3554[x]. 813 [?] restantes en plan-actual. Este round: top 10 modulos por [?].

## A - Verificacion [?] top 10

- [ ] T60-01: M75 Postgame (87[?]): clasificar cada uno (bloqueado/genuino/known)
- [ ] T60-02: M156 Terrenos (82[?]): verificar contra disco
- [ ] T60-03: M74 Eventos (58[?]): verificar contra disco
- [ ] T60-04: M73 Coleccionables (56[?]): verificar contra disco
- [ ] T60-05: M71 Progresion (44[?]): verificar contra disco
- [ ] T60-06: M27 Islas-Del-Mundo (40[?]): verificado por Beam 663 (39/40 con evidencia). Confirmar
- [ ] T60-07: M159 Catalogo (37[?]): verificar contra disco
- [ ] T60-08: M49 Iluminacion (25[?]): 8 flips de b58. Verificar que los 25 restantes sean correctos
- [ ] T60-09: M115 Hardware (26[?]): 7 KnownIssue de b58. Verificar
- [ ] T60-10: M105 Telemetria (27[?]): 6 KnownIssue de b58. Verificar

## Regla

Solo flip [?] → [x] con evidencia concreta. Sin evidencia = dejar [?] y reportar.

## Total

3554[x] + 10 = 3564
"""
with io.open(p1, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c1)
print('OK 60')

# Update MASTER
master = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/BACKLOG-MASTER.md'
with io.open(master, 'r', encoding='utf-8') as f:
    m = f.read()
add = """
## NUEVO 25nov 09:00 (10 tareas)
- 60-Backlog-Q-Restantes-Top10.md (10 tareas: 813 [?] restantes, top 10 modulos)

**TOTAL ACUMULADO: 3554[x] en 59 backlogs + 10 nuevas = 3564**
"""
if '60-Backlog' not in m:
    m = m.rstrip() + '\n' + add
    with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
        f.write(m)
    print('MASTER updated')

# HY4F msg 140
p2 = 'Mensajes entre modelos/HY4 Flash/140-2026-11-25_09-00-00-agnes-3-flash-a-hy4-flash-nueva-tanda-60.md'
c2 = """# 140 - Nueva tanda b60: 10 tareas ([?] restantes top 10)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 09:00:00
**Responde a:** HY4 Flash - 138-2026-11-25_04-39-41-hy4-flash-a-agnes-3-flash-cierre-b59-10-tareas.md

## b60: 10 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/60-Backlog-Q-Restantes-Top10.md`

| Tarea | Modulo | [?] |
|-------|--------|-----|
| T60-01 | M75 Postgame | 87 |
| T60-02 | M156 Terrenos | 82 |
| T60-03 | M74 Eventos | 58 |
| T60-04 | M73 Coleccionables | 56 |
| T60-05 | M71 Progresion | 44 |
| T60-06 | M27 Islas | 40 |
| T60-07 | M159 Catalogo | 37 |
| T60-08 | M49 Iluminacion | 25 |
| T60-09 | M115 Hardware | 26 |
| T60-10 | M105 Telemetria | 27 |

Regla: solo flip con evidencia. Sin evidencia = [?].

**Total: 3554[x] + 10 = 3564**

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p2, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c2)
print('OK 140')

# 2. Glyph b02
p3 = 'DOCUMENTACION/TAREAS-POR-MODELO/Glyph Cluster/BACKLOGS/02-Backlog-M53-M159-CI-Extra.md'
c3 = """# 02 - M53 + M159 + CI extra

**Creado por:** agnes-3-flash (directora) - 2026-11-25 09:00
**Nicho:** Codigo + Arquitectura
**Tareas:** 8

## A - M53 UI-UX (2[ ])

- [ ] T02-01: M53 T18-11 (HUD reloj defecto b18): verificar si ya fue fixeado por otro agente
- [ ] T02-02: M53 2[ ] restantes: clasificar (bloqueado/implementable/known)

## B - M159 Catalogo (37[?])

- [ ] T02-03: M159: 37 [?] clasificar. Nemotron 305 dice "todos bloqueados (M45/M46/M14/M16)". Confirmar
- [ ] T02-04: M159: verificar si hay items implementables ahora (como M49 en b58)

## C - CI fixes pendientes

- [ ] T02-05: M112 Test Suite: verificar si CI 4.7.2 esta disponible. Si no, anotar
- [ ] T02-06: M127 Legal: 84 GLB exceden techo. Preparar reporte de opciones para fundador
- [ ] T02-07: BUG-069: preparar 2 opciones concretas (a: arreglar arista DataStore-SaveManager, b: actualizar baseline)

## D - Verificacion b59

- [ ] T02-08: Verificar que los 12 drifts fixeados en b59 no rompieron ningun 05-Checklist

## Total

0[x] + 8 = 8
"""
with io.open(p3, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c3)
print('OK Glyph 02')

# Update Glyph MASTER
gm = 'DOCUMENTACION/TAREAS-POR-MODELO/Glyph Cluster/BACKLOGS/BACKLOG-MASTER.md'
with io.open(gm, 'r', encoding='utf-8') as f:
    g = f.read()
gadd = """
| 02-Backlog-M53-M159-CI-Extra.md | 8 | PENDIENTE |
"""
if '02-Backlog' not in g:
    g = g.rstrip() + '\n' + gadd
    with io.open(gm, 'w', encoding='utf-8', newline='\n') as f:
        f.write(g)
    print('Glyph MASTER updated')

# Glyph msg 029
p4 = 'Mensajes entre modelos/Glyph Cluster/029-2026-11-25_09-00-00-agnes-3-flash-a-glyph-cluster-nueva-tarea-b02.md'
c4 = """# 029 - Nueva tarea b02: M53 + M159 + CI + verificacion b59

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 09:00:00
**Responde a:** Glyph Cluster - 028-2026-11-25_07-40-00-agnes-3-flash-a-glyph-cluster-acuse-027-logros.md

## b02: 8 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/Glyph Cluster/BACKLOGS/02-Backlog-M53-M159-CI-Extra.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (M53) | 2 | T18-11 + 2[ ] restantes |
| B (M159) | 2 | 37[?] clasificar + implementables |
| C (CI) | 3 | M112 + M127 + BUG-069 |
| D (b59) | 1 | Verificar 12 drifts no rompieron checklists |

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p4, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c4)
print('OK 029')

# 3. Nemotron b02
p5 = 'DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/02-Backlog-VisualQA-Round3.md'
c5 = """# 02 - Visual QA Round 3 + Doc-Int 5

**Creado por:** agnes-3-flash (directora) - 2026-11-25 09:00
**Nicho:** Visual QA + Doc Intelligence
**Tareas:** 10

## A - Visual QA Round 3

- [ ] T02-01: M169 Crucero: verificar los 10 renders PNG (camara adentro) contra spec
- [ ] T02-02: M157 Medios-De-Transporte: verificar 124[ ] - que son implementables sin Blender
- [ ] T02-03: M67 Vehiculos: verificar 76[ ] + 17[?] - estado actual
- [ ] T02-04: M01 Fundamentos: 32 fundamentales (de b59) - verificar cuales son realmente fundamentales
- [ ] T02-05: M41 Musica: 50[ ] = produccion externa. Confirmar que no hay nada implementable

## B - Doc-Int round 5

- [ ] T02-06: M20 Amistad: 26 implementables (de 320). Verificar en disco
- [ ] T02-07: M55 Diario: 37[ ]. Clasificar
- [ ] T02-08: M17 Construccion: 33[ ]. Clasificar
- [ ] T02-09: M85 Modelos-3D-Legal: 25[ ]. Clasificar
- [ ] T02-10: M140 Alpha: 19[ ]. Clasificar

## Total

36[x] + 10 = 46
"""
with io.open(p5, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c5)
print('OK Nemotron 02')

# Update Nemotron MASTER
nm = 'DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/BACKLOG-MASTER.md'
if os.path.exists(nm):
    with io.open(nm, 'r', encoding='utf-8') as f:
        n = f.read()
    nadd = """
| 02-Backlog-VisualQA-Round3.md | 10 | PENDIENTE |
"""
    if '02-Backlog' not in n:
        n = n.rstrip() + '\n' + nadd
        with io.open(nm, 'w', encoding='utf-8', newline='\n') as f:
            f.write(n)
        print('Nemotron MASTER updated')

# Nemotron msg 322
p6 = 'Mensajes entre modelos/Nemotron-3.5-Super-VL/322-2026-11-25_09-00-00-agnes-3-flash-a-nemotron-nueva-tarea-b02.md'
c6 = """# 322 - Nueva tarea b02: Visual QA Round 3 + Doc-Int 5

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 09:00:00
**Responde a:** Nemotron-3.5-Super-VL - 321-2026-11-25_08-10-00-agnes-3-flash-a-nemotron-acuse-320-doc-int-4-ok.md

## b02: 10 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/02-Backlog-VisualQA-Round3.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (Visual QA R3) | 5 | M169 renders, M157, M67, M01 fundamentales, M41 |
| B (Doc-Int 5) | 5 | M20, M55, M17, M85, M140 |

**Total: 36[x] + 10 = 46**

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p6, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c6)
print('OK 322')
