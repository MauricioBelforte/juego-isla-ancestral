# Log 409: M120 DLC y Expansiones — Núcleo Iter. 1

**Fecha:** 2026-09-01
**Hora:** 23:50
**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code

## Resumen

Se implementó el núcleo del Módulo 120 (DLC y Expansiones): DlcManager autoload (manifest data-driven, compatibilidad con versión base, activación/desactivación, bundles) + dlc_manifest.json (2 DLC: isla_hielo expansión, pack_aurora cosmético) + bundles.json (bundle_deluxe con 15%). Test headless 16/0 OK, regresión M60 66/0 OK.

## Archivos Creados

- scripts/dlc/dlc_manager.gd (autoload)
- scripts/dlc/test_dlc_m120.gd
- data/dlc/dlc_manifest.json
- data/dlc/bundles.json

## Verificación

- Test M120: 16 checks, 0 fallos
- Regresión M60: 66/0 OK

## Pendientes (96 ítems)

Carga real de contenido DLC (islas/biomas/NPCs), compatibility checker profundo, uninstaller, integración M95/M142.

