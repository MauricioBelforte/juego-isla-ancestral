# 512 — Barrido anti-drift M37-Museos-Y-Colecciones: DRIFT 0 (5 MISS = diseño)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:51

## M37 — 04-Codigo.md vs. scripts/museum/ + ui/museum/

**En disco (núcleo OK):** collection_registry.gd, donation_service.gd, exhibit_slot.gd, museum.gd, test_museo_persistencia.gd, test_museo_rf2d.gd.

**MISS (5) — §1 "Rutas de Archivos" + §2 "Firmas de Funciones Clave":**
| Ruta | Contexto doc |
|------|--------------|
| exhibition_data.gd | L11 inventario + L42 firmas (diseño) |
| exhibit_data.gd | L12 inventario + L57 firmas (diseño) |
| museum_curator.gd | L17 inventario (NPC curador) |
| ui/museum/museum_panel.gd | L19 inventario |
| ui/museum/exhibition_progress_bar.gd | L20 inventario |

**Clave:** ningún `[x]` en 05-Checklist afirma la existencia de estos 5 archivos. El único `[x]` relacionado (L112 `get_exhibition_progress`) vive en `collection_registry.gd` (OK en disco). Los 5 MISSING son inventario de diseño / firmas de clase, no implementaciones declaradas `[x]`.

## Veredicto

**DRIFT 0.** El núcleo M37 está en disco; los 5 archivos faltantes son notas de diseño (§1/§2), sin inflación de `[x]`.
