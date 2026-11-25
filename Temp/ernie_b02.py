import io
import os

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# ERNIE b02
er_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/ERNIE-5.5-Flash-Preview/BACKLOGS'
os.makedirs(er_dir, exist_ok=True)

content = """# 02 - M169 Doc + Verificacion + Codigo (sin Blender)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 08:15
**Nicho:** Documentacion + Verificacion + Codigo
**Tareas:** 12

## Contexto

b01 CERRADA (12/12). M169 sigue con 147[ ] pero 144 son Blender. Estas 12 no necesitan Blender.

## A - Verificacion M169 (6)

- [ ] T02-01: Verificar que CruceroManager autoload este en project.godot y funcione
- [ ] T02-02: Verificar que los 5 interiores tengan CollisionShape3D (no atraviesen paredes)
- [ ] T02-03: Verificar que el bote salvavidas tenga colision correcta
- [ ] T02-04: Verificar que las 24 ventanas de camarote no se solapen (AABB)
- [ ] T02-05: Verificar que el HUD de tienda (M-06) muestre precios correctos
- [ ] T02-06: Verificar que no haya 2 cubiertas en memoria simultaneamente (K-03)

## B - Codigo M169 (4)

- [ ] T02-07: P-01: tests/unit/test_crucero_manager.gd (4 estados: inactivo/embarque/zarpe/llegada)
- [ ] T02-08: P-02: tests/integration/test_crucero_viaje.gd (embarque → zarpe → llegada)
- [ ] T02-09: Q-13: Conectar 5 actividades al EventManager de M74
- [ ] T02-10: L-04: Dialogo ambiental simple al interactuar (1 linea por NPC)

## C - Doc M169 (2)

- [ ] T02-11: Actualizar 03-Diseno de M169 con los 56 drifts fixeados + 18 iconos logros
- [ ] T02-12: Verificar que 04-Codigo de M169 mencione CruceroManager + autoload + tests

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Verif) | 6 |
| B (Code) | 4 |
| C (Doc) | 2 |
| **Total** | **12** |

**Nota:** B-02/B-03 siguen en STANDBY (Blender + fundador). Estas 12 son complemento.
"""
with io.open(os.path.join(er_dir, '02-Backlog-M169-Doc-Verify-Code.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('OK ERNIE 02')

# Update ERNIE MASTER
master_p = os.path.join(er_dir, 'BACKLOG-MASTER.md')
with io.open(master_p, 'r', encoding='utf-8') as f:
    master = f.read()
addition = """
| 02-Backlog-M169-Doc-Verify-Code.md | 12 | PENDIENTE |
"""
if '02-Backlog' not in master:
    master = master.rstrip() + '\n' + addition
    with io.open(master_p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(master)
    print('MASTER updated')

# ERNIE msg 084
p2 = 'Mensajes entre modelos/ERNIE-5.5-Flash-Preview/084-2026-11-25_08-15-00-agnes-3-flash-a-ernie-nueva-tanda-02.md'
c2 = """# 084 - Nueva tanda b02: M169 Doc + Verify + Code (sin Blender, 12 tareas)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 08:15:00
**Responde a:** ERNIE-5.5-Flash-Preview - 083-2026-11-21_08-50-00-agnes-3-flash-a-ernie-nueva-tarea-01.md

## Contexto

b01 CERRADA. 24[x] total. Nueva tanda.

## b02: 12 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/ERNIE-5.5-Flash-Preview/BACKLOGS/02-Backlog-M169-Doc-Verify-Code.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (Verif) | 6 | CruceroManager, colisiones interiores, bote, ventanas, HUD, memoria |
| B (Code) | 4 | test manager, test viaje, EventManager M74, dialogos NPCs |
| C (Doc) | 2 | 03-Diseno update + 04-Codigo verificacion |

## Reglas

- Seccion A: verificar en disco (.tscn, .gd, .tres), no ejecutar Godot
- Seccion B: escribir code, verificar con get_debug_output
- Seccion C: actualizar docs

**Total: 24[x] + 12 = 36**

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p2, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c2)
print('OK 084')
