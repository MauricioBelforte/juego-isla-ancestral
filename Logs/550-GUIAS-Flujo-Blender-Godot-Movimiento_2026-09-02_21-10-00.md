# Log 550: Guías 07/09 — Flujo Completo Blender→Godot→Movimiento

**Fecha:** 2026-09-02
**Hora:** 21:10
**Modelo:** GLM 5.3 (z-ai)
**Plataforma:** Kilo Code

## Resumen

Directiva del usuario tras aprobar la tortuga NPC funcionando: documentar en
las guías el flujo VERIFICADO para que cualquier agente aporte objetos 3D
animados — modelar en Blender, llevarlos a Godot y moverlos — "tal como lo
hice yo", con lo correcto y lo que NO se debe hacer.

## Cambios Realizados

- **`DOCUMENTACION/07-GUIA-GODOT.md` — NUEVA §11** (7 subsecciones):
  - 11.1 Arquitectura: GLB sin armature, animación procedural en Godot.
  - 11.2 Requisitos del asset en Blender (piezas SM_ separadas, pivotes
    lógicos, conteo E-70 con animables, z_min 0.045).
  - 11.3 Procedimiento paso a paso (plantear → exportar → script NPC
    patrón villager → nodo en escena → animar).
  - 11.4 Plantilla de animación verificada (resolver refs tras instanciar,
    guardar rotaciones base, animar base+seno, fases espejo +PI, amplitudes
    mínimas visibles).
  - 11.5 **7 ERRORES FATALES pisados** (el @onready null que paralizó la
    tortuga, amplitudes invisibles, no rotar el body, no IslandGenerator
    propio, offset -0.045, parser ajenos bloqueantes, variables duplicadas).
  - 11.6 DoD del objeto animado (boot limpio, N/N nodos, 60s sin errores,
    captura, confirmación V1 del usuario).
- **`DOCUMENTACION/09-GUIA-BLENDER.md` — NUEVA §8** (3 subsecciones):
  requisitos del asset ANIMABLE lado Blender (E-74 espejo, pivote en la raíz
  articular, ALTA sin fundir animables, z_min exacto) + 5 errores fatales +
  checklist propio. Referencia cruzada con 07 §11.
- Firmas de ambas guías actualizadas a GLM 5.3 (z-ai) con historial.
- Verificación UTF-8 §28: ambas limpias (sin mojibake).

## Archivos Modificados/Creados

- `DOCUMENTACION/07-GUIA-GODOT.md` (+§11, firma)
- `DOCUMENTACION/09-GUIA-BLENDER.md` (+§8, firma)
- `Logs/550-...` (este log)

## QA

- Secciones verificadas por estructura: 07 §11 con 7 encabezados, 09 §8 con 4.
- UTF-8 sin BOM válido en ambos (regex de mojibake da limpio).
- Contenido extraído 100% del caso real verificado (tortuga M36, logs 533/545,
  aprobación del usuario en 3 iteraciones de feedback).

## Pendiente / Próximo agente

- El caso de referencia vivo es `scripts/fauna/tortuga_npc.gd` — citarlo al
  usar la §11 (no re-explicar).
- Cuando otro animal entre al pipeline (cangrejo, gaviota), validar contra
  07 §11.6 y anotar en la guía cualquier desvío nuevo.
