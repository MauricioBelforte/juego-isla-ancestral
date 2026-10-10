# Log 1587: BUG-130 verificado — null-guard YA presente en gaviota_npc.gd L112-114

**Fecha:** 2026-10-10
**Hora:** 06:45
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
BUG-130: el null-guard entre `load()` e `instantiate()` YA está en `gaviota_npc.gd` L112-114. El bug reportado por DeepSeek ya no existe en el código actual.

## Verificación
- `gaviota_npc.gd` L108: `ResourceLoader.exists()` → cubre "archivo no existe"
- `gaviota_npc.gd` L111: `load(glb)` → carga recurso
- `gaviota_npc.gd` L112-114: `if res_glb == null: push_warning(...); return` → **null-guard PRESENTE**
- `gaviota_npc.gd` L115: `res_glb.instantiate()` → seguro
- `--check-only` → exit 0

## Causa probable
El fix se aplicó en paralelo al registro del bug (o el bug fue reportado sobre una versión anterior).

## Acción
Reportado al director (msg 196) para cierre de BUG-130 en 11-BUGS.md.

## Reglas
- Sin commits ✓
- READ-ONLY sobre marcas ✓
