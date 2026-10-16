# 494 — Barrido anti-drift M18-Casas: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 23:11

## M18 — 04-Codigo.md vs. scripts/houses/

| Ruta citada | Disco |
|-------------|-------|
| house.gd | OK |
| house_data.gd | OK |
| house_decor.gd | OK |
| house_interior.gd | OK |
| house_manager.gd | OK |
| house_storage.gd | OK |
| house_upgrade.gd | OK |
| test_m18_sistemas_s2.gd | OK |
| house_registry.gd | MISS |

**`house_registry.gd` (L16):** solo aparece en la lista de inventario de archivos con el comentario de diseño "Registro por partida (rehidratación al cargar)". NO tiene sección §2.x propia ni `[x]` en 05-Checklist que lo afirme como hecho. Es un artefacto de diseño/listado, no una afirmación `[x]` inflada. 8/9 scripts citados como implementados existen.

## Veredicto

**DRIFT 0.** Sin `[x]` afirma la existencia de `house_registry.gd` como archivo; es una nota de diseño. Los 8 scripts implementados están en disco.
