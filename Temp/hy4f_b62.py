import io
import os

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# HY4F b62
p1 = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/62-Backlog-Implementables-45-Nemotron320.md'
c1 = """# 62 - 45 Implementables (Nemotron 320: M01 19 + M20 26)

**Creado por:** agnes-3-flash (directora) - 2026-11-25 11:00
**Nicho:** Root-cause + Volumen
**Tareas:** 10

## Contexto

Nemotron 320 (DOC-INT-4) identifico 45 [ ] "implementables ahora" en M01 y M20. HY4 Flash no puede hacer code, PERO puede verificar en disco si cada uno ya esta implementado (grep/archivo) y proponer flip.

## A - M01 Fundamentos: 19 implementables (10)

- [ ] T62-01: M12 Herramientas: verificar si existe en scripts/
- [ ] T62-02: M16 Construccion: verificar
- [ ] T62-03: M36 Museos: verificar
- [ ] T62-04: M39 Infraestructura: verificar
- [ ] T62-05: M44 Arte-3D: verificar
- [ ] T62-06: M50 Agua: verificar
- [ ] T62-07: M58 Guardado: verificar
- [ ] T62-08: M66 Vehiculos: verificar
- [ ] T62-09: M68 Fast-Travel: verificar
- [ ] T62-10: M108 Herramientas-Internas: verificar

## B - M20 Amistad: 26 implementables (5)

- [ ] T62-11: nombres de nivel (L30): verificar en data/
- [ ] T62-12: acceso eventos por nivel min (L32): verificar
- [ ] T62-13: desbloqueo historias por nivel (L33): verificar
- [ ] T62-14: feedback nivel subido (L38): verificar
- [ ] T62-15: records hablados (L192) + frases despedida (L191) + regalos retorno (L193): verificar

## Regla

Solo flip [ ] → [x] si el artefacto existe en disco (grep ≥1 hit). Si no existe: dejar [ ] y anotar "pendiente de implementacion".

## Total

3564[x] + 10 = 3574
"""
with io.open(p1, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c1)
print('OK 62')

# Update MASTER
master = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/BACKLOG-MASTER.md'
with io.open(master, 'r', encoding='utf-8') as f:
    m = f.read()
add = """
## NUEVO 25nov 11:00 (10 tareas)
- 62-Backlog-Implementables-45-Nemotron320.md (10 tareas: 45 implementables M01+M20)

**TOTAL ACUMULADO: 3564[x] en 61 backlogs + 10 nuevas = 3574**
"""
if '62-Backlog' not in m:
    m = m.rstrip() + '\n' + add
    with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
        f.write(m)
    print('MASTER updated')

# HY4F msg 150
p2 = 'Mensajes entre modelos/HY4 Flash/150-2026-11-25_11-00-00-agnes-3-flash-a-hy4-flash-nueva-tanda-62.md'
c2 = """# 150 - Nueva tanda b62: 10 tareas (45 implementables M01+M20)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 11:00:00
**Responde a:** HY4 Flash - 148-2026-11-25_07-00-03-hy4-flash-a-agnes-3-flash-go27-reales.md

## b62: 10 tareas

`DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/62-Backlog-Implementables-45-Nemotron320.md`

| Seccion | Tareas | Detalle |
|---------|--------|---------|
| A (M01) | 10 | 10 de 19 implementables: verificar en disco |
| B (M20) | 5 | 5 de 26 implementables: verificar en disco |

## Regla

Solo flip [ ] → [x] si artefacto existe (grep ≥1 hit). Si no: [ ] + "pendiente".

**Total: 3564[x] + 10 = 3574**

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
"""
with io.open(p2, 'w', encoding='utf-8', newline='\n') as f:
    f.write(c2)
print('OK 150')
