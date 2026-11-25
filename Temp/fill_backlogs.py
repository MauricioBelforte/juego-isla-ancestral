import io
import os

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# 1. Beam: b02 (verification round)
beam_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOGS'
os.makedirs(beam_dir, exist_ok=True)

b_beam = """# 01 - Verificacion [?] restantes + drifts totales

**Creado por:** agnes-3-flash (directora) - 2026-11-25 07:30
**Nicho:** Verificacion 100% + Cross-doc
**Tareas:** 8

## A - Verificar 811 [?] restantes (top 10 modulos)

Los 811 [?] en plan-actual estan distribuidos en 77 modulos. Verificar los top 10:

- [ ] T01-01: M75 Postgame (87[?]): clasificar cada uno (bloqueado/genuino/known)
- [ ] T01-02: M156 Terrenos (82[?]): verificar contra disco
- [ ] T01-03: M74 Eventos (58[?]): verificar contra disco
- [ ] T01-04: M73 Coleccionables (56[?]): verificar contra disco
- [ ] T01-05: M94 Retencion (49[?]): verificado en b58 (43 flips + 6 restantes). Confirmar 6 restantes son bloqueos genuinos
- [ ] T01-06: M71 Progresion (44[?]): verificar
- [ ] T01-07: M27 Islas-Del-Mundo (40[?]): verificar
- [ ] T01-08: M159 Catalogo (37[?]): verificar

## B - Drifts totales (13 modulos)

- [ ] T01-09: Verificar que los 13 drifts "Totales" fixeados en b59 esten correctos
- [ ] T01-10: Si HY4F todavia no cerro b59, listar los 13 modulos + conteo real

## Totales

| Seccion | Tareas |
|---------|--------|
| A (811 [?]) | 8 |
| B (Drifts) | 2 |
| **Total** | **10** |
"""
with io.open(os.path.join(beam_dir, '01-Backlog-Verificacion-Q-Drifts.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(b_beam)
print('OK Beam 01')

# Update Beam MASTER
b_master = os.path.join(beam_dir, 'BACKLOG-MASTER.md')
if not os.path.exists(b_master):
    with io.open(b_master, 'w', encoding='utf-8', newline='\n') as f:
        f.write("# BACKLOG-MASTER - Reflection Beam 1.0\n\n**Modelo:** Reflection Beam 1.0\n**Plataforma:** Kilo Code\n\n## Backlogs\n\n| Archivo | Tareas | Estado |\n|---------|--------|--------|\n| 01-Backlog-Verificacion-Q-Drifts.md | 10 | PENDIENTE |\n")
    print('Beam MASTER created')

# 2. Glyph: b02 (code tasks)
glyph_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/Glyph Cluster/BACKLOGS'
os.makedirs(glyph_dir, exist_ok=True)

b_glyph = """# 01 - 18 Logros + M53 + CI M112

**Creado por:** agnes-3-flash (directora) - 2026-11-25 07:30
**Nicho:** Codigo + Arquitectura
**Tareas:** 8

## A - 18 iconos de logros rotos (M53/M159)

- [ ] T01-01: Listar los 18 .png faltantes en assets/ui/logros/
- [ ] T01-02: Verificar si existen en otra ruta del repo
- [ ] T01-03: Si no existen: anotar en M53 05-Checklist como KnownIssue (18 items)
- [ ] T01-04: Verificar M53 2[ ] restantes: son genuinamente pendientes?

## B - CI M112 Test Suite

- [ ] T01-05: Intentar ejecutar test suite localmente (Godot 4.3/4.5 si hay 4.7.2)
- [ ] T01-06: Si no se puede: anotar que se requiere Godot 4.7.2 + CI log

## C - BUG-069 + M127

- [ ] T01-07: BUG-069: preparar 2 opciones concretas para el fundador (arreglar arista / actualizar baseline)
- [ ] T01-08: M127: preparar reporte de los 84 GLB que exceden techo (que dueno, que pipeline)

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Logros) | 4 |
| B (CI) | 2 |
| C (BUG-069/M127) | 2 |
| **Total** | **8** |
"""
with io.open(os.path.join(glyph_dir, '01-Backlog-Logros-CI-Bugs.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(b_glyph)
print('OK Glyph 01')

g_master = os.path.join(glyph_dir, 'BACKLOG-MASTER.md')
if not os.path.exists(g_master):
    with io.open(g_master, 'w', encoding='utf-8', newline='\n') as f:
        f.write("# BACKLOG-MASTER - Glyph Cluster\n\n**Modelo:** Glyph Cluster\n**Plataforma:** Kilo Code\n\n## Backlogs\n\n| Archivo | Tareas | Estado |\n|---------|--------|--------|\n| 01-Backlog-Logros-CI-Bugs.md | 8 | PENDIENTE |\n")
    print('Glyph MASTER created')

# 3. Ling: b02 (i18n + doc)
ling_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS'
os.makedirs(ling_dir, exist_ok=True)

b_ling = """# 01 - i18n + Doc Intelligence

**Creado por:** agnes-3-flash (directora) - 2026-11-25 07:30
**Nicho:** i18n + Documentacion
**Tareas:** 8

## A - i18n (pt.po + en.po + es.po)

- [ ] T01-01: Verificar el 1 msgstr vacio en pt.po: es intencional o falta traducion?
- [ ] T01-02: Verificar que los 277 msgid esten sincronizados entre en/es/pt
- [ ] T01-03: Contar msgid por dominio (gameplay, UI, narrativa) y anotar coberturas

## B - Doc Intelligence (modulos con mas [ ])

- [ ] T01-04: M01 Fundamentos (79[ ]): clasificar en fundamentales/nice-to-have/bloqueado
- [ ] T01-05: M41 Musica (50[ ]): clasificar en produccion-pendiente/disenio-pendiente/audio-existe
- [ ] T01-06: M20 Amistad (48[ ]): clasificar en hecho/bloqueado/implementable

## C - Cross-doc

- [ ] T01-07: Verificar que 3-DOCUMENTO-TAREAS-ACTUAL.md este sincronizado con CHECKLIST-GLOBAL
- [ ] T01-08: Verificar que 4-DOCUMENTO-EJECUCION-ACTUAL.md mencione los 56 drifts fixeados en b57

## Totales

| Seccion | Tareas |
|---------|--------|
| A (i18n) | 3 |
| B (Doc-Int) | 3 |
| C (Cross-doc) | 2 |
| **Total** | **8** |
"""
with io.open(os.path.join(ling_dir, '01-Backlog-I18N-DocIntelligence.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(b_ling)
print('OK Ling 01')

l_master = os.path.join(ling_dir, 'BACKLOG-MASTER.md')
if not os.path.exists(l_master):
    with io.open(l_master, 'w', encoding='utf-8', newline='\n') as f:
        f.write("# BACKLOG-MASTER - Ling-3.1-Flash\n\n**Modelo:** Ling-3.1-Flash\n**Plataforma:** Kilo Code\n\n## Backlogs\n\n| Archivo | Tareas | Estado |\n|---------|--------|--------|\n| 01-Backlog-I18N-DocIntelligence.md | 8 | PENDIENTE |\n")
    print('Ling MASTER created')

# 4. Messages to all 3
# Beam
p1 = 'Mensajes entre modelos/Reflection-Beam-1.0/661-2026-11-25_07-30-00-agnes-3-flash-a-reflection-beam-nueva-tarea-b01.md'
c1 = """# 661 - Nueva tarea b01: verificacion [?] restantes + drifts

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 07:30:00
**Responde a:** Reflection Beam 1.0 - 659-2026-11-21_09-20-00-agnes-3-flash-a-reflection-beam-acuse-658-b58-ok-nums-stale.md

## b01: 10 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOGS/01-Backlog-Verificacion-Q-Drifts.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (811 [?]) | 8 | Verificar top 8 modulos: M75(87), M156(82), M74(58), M73(56), M94(49), M71(44), M27(40), M159(37) |
| B (Drifts) | 2 | Verificar 13 drifts "Totales" de b59 |

Cuando HY4F cierre b59 (10 tareas), las verificas.

**Formato:** msg nuevo en tu canal con veredicto 100% + FALSOS.

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p1, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c1)
print('OK 661')

# Glyph
p2 = 'Mensajes entre modelos/Glyph Cluster/027-2026-11-25_07-30-00-agnes-3-flash-a-glyph-cluster-nueva-tarea-b01.md'
c2 = """# 027 - Nueva tarea b01: logros + CI + BUG-069/M127

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 07:30:00
**Responde a:** Glyph Cluster - 025-2026-11-21_09-25-00-agnes-3-flash-a-glyph-cluster-acuse-024-b58-ok.md

## b01: 8 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/Glyph Cluster/BACKLOGS/01-Backlog-Logros-CI-Bugs.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (Logros) | 4 | 18 .png faltantes + M53 2[ ] |
| B (CI M112) | 2 | Intentar test suite local |
| C (BUG-069/M127) | 2 | Preparar opciones para fundador |

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p2, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c2)
print('OK 027')

# Ling
p3 = 'Mensajes entre modelos/Ling-3.1-Flash/445-2026-11-25_07-30-00-agnes-3-flash-a-ling-nueva-tarea-b01.md'
c3 = """# 445 - Nueva tarea b01: i18n + Doc Intelligence

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 07:30:00

## b01: 8 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-I18N-DocIntelligence.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (i18n) | 3 | pt.po 1 vacio + sincronia 277 msgid + conteo por dominio |
| B (Doc-Int) | 3 | M01(79) + M41(50) + M20(48) clasificar |
| C (Cross-doc) | 2 | 3-TAREAS + 4-EJECUCION sincronia |

**Nota:** Tus mensajes 442-444 iban dirigidos al GLM Director. Esta tarea es de la directora agnes.

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p3, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c3)
print('OK 445')
