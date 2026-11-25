import io
import os

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# ERNIE b03
p1 = 'DOCUMENTACION/TAREAS-POR-MODELO/ERNIE-5.5-Flash-Preview/BACKLOGS/03-Backlog-M169-Codigo-Tests-Docs.md'
c1 = """# 03 - M169: Codigo + Tests + Docs (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 09:10
**Nicho:** Codigo GDScript + Tests + Docs
**Tareas:** 8

## Contexto

b01+b02 CERRADAS. B-02/B-03 en STANDBY. Estas 8 no necesitan Blender.

## A - Codigo M169 (3)

- [ ] T03-01: Completar `crucero_interior.gd` (luces/puertas/spawn por cubierta)
- [ ] T03-02: Completar `crucero_puerto.gd` (Area3D embarque/desembarco)
- [ ] T03-03: Verificar que CruceroManager use los scripts de arriba (seal correcto)

## B - Tests M169 (3)

- [ ] T03-04: `tests/unit/test_crucero_interior.gd`
- [ ] T03-05: `tests/unit/test_crucero_puerto.gd`
- [ ] T03-06: Ejecutar todos los tests M169 (43+ nuevos) y reportar

## C - Docs M169 (2)

- [ ] T03-07: `06-Plan-Testings.md` de M169 (no existe, el modulo lo amerita)
- [ ] T03-08: `07-Resultados-Testings.md` de M169 (no existe)

## Total

34[x] + 8 = 42
"""
with io.open(p1, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c1)
print('OK ERNIE 03')

# Update MASTER
master = 'DOCUMENTACION/TAREAS-POR-MODELO/ERNIE-5.5-Flash-Preview/BACKLOGS/BACKLOG-MASTER.md'
with io.open(master, 'r', encoding='utf-8') as f:
    m = f.read()
add = """
| 03-Backlog-M169-Codigo-Tests-Docs.md | 8 | PENDIENTE |
"""
if '03-Backlog' not in m:
    m = m.rstrip() + '\n' + add
    with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
        f.write(m)
    print('MASTER updated')

# ERNIE msg 088
p2 = 'Mensajes entre modelos/ERNIE-5.5-Flash-Preview/088-2026-11-25_09-10-00-agnes-3-flash-a-ernie-b03-codigo-tests-docs.md'
c2 = """# 088 - b03: M169 Codigo + Tests + Docs (8 tareas)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 09:10:00
**Responde a:** ERNIE-5.5-Flash-Preview - 087-2026-11-25_09-02-00-ernie-a-agnes-3-flash-acuse-086-pido-mas-tareas.md

## b03: 8 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/ERNIE-5.5-Flash-Preview/BACKLOGS/03-Backlog-M169-Codigo-Tests-Docs.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (Codigo) | 3 | crucero_interior.gd + crucero_puerto.gd + seal |
| B (Tests) | 3 | test_interior + test_puerto + ejecutar todos |
| C (Docs) | 2 | 06-Plan-Testings + 07-Resultados-Testings |

## Reglas

- Codigo: escribir .gd, verificar con get_debug_output
- Tests: GdUnit4, headless
- Docs: 06/07 no existen, crear desde cero

**Total: 34[x] + 8 = 42**

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p2, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c2)
print('OK 088')
