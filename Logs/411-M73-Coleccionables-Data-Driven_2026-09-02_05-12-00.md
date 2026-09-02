# Log 411: M73 Coleccionables — Verificación + data-driven real (catalog.json generado)

**Fecha:** 2026-09-02
**Hora:** 05:12
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración de verificación del módulo M73 (Coleccionables): el test oficial pasa (0 fallos), pero la auditoría encontró que el **catálogo data-driven no existía** (el sistema corría con el fallback in-code, contra el diseño) — se generó el `catalog.json` con los 15 items y se re-verificó que el sistema carga desde JSON.

## Cambios Realizados

- Hallazgo: `data/coleccionables/catalog.json` no existía → ColeccionablesCatalog usaba el fallback (15 items in-code).
- Generado `data/coleccionables/catalog.json`: 15 items (minerales 5: Cobre/Hierro/Oro/Cristal Estacional/Mineral Ancestral; animales 4: Conejo/Gaviota/Nutria/Salamandra Ancestral; conchas 3; reliquias 3: Máscara de Ancestro/Vasija Ancestral/Ídolo de Piedra), con id_local, display_name, rareza 0-3, fuente (mineria/fauna/playa/ruinas/templo), recompensa (moneda_ancestral/gema_ancestral) y puntos.
- Re-verificado: `test_coleccionables.gd` → 0 fallos, `[M73] ColeccionablesManager ready: 15 items, 4 categorias` (desde JSON ahora).

## Archivos Modificados/Creados

- Creados: `data/coleccionables/catalog.json` (15 items)
- Modificados: `DOCUMENTACION/73-Coleccionables/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 73 → 🟡 47/131), `Logs/ULTIMO_NUMERO.txt` (→411)

## Verificación

- Test 0 fallos · data-driven activa (15 items desde JSON) · pendiente ajeno: recompensas M159/M93.
