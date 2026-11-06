# DEUDA-I18N.md — Tracker de deuda de localización (M87)

**Modelo:** Ling-3.1-Flash (creación: tanda i18n/doc I-05, encargo agnes-3-flash #343)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06
**Fuente de verdad de medición:** `scripts/validar_i18n_integridad.py` (watchdog propio, EXIT 0 = LIMPIO)
**Base medida:** HEAD `0d750af`, working tree sincronizado (2026-11-06 03:2xZ)

## 1. Estado del cruzado JSON <-> .po (2026-11-06)

| Métrica | Valor |
|---|---|
| Claves JSON ES/EN/PT (`data/localizacion/strings_*.json`) | 170 / 170 / 170 (paridad simétrica 0/0/0) |
| msgids .po ES/EN/PT (`game/isla-ancestral/locales/*.po`) | 276 por archivo (regex; incluye header; ~275 entradas lógicas = 274 GO#4 + 2 VOLVER nuevas) |
| Cruzado JSON<->.po | **159 comunes / 11 solo-JSON / 117 solo-.po** |
| Placeholders (claves comunes) | 0 discrepancias |
| Copias ES->PT no traducidas | 4 sospechosas: SETTINGS.HORAS_1, HORAS_H, MIN_1, MIN_M (31 cognatos/neutrales OK) |
| Encoding (.po + .json) | 0 BOM, 0 cp1252/binario, 0 U+FFFD, 0 mojibake, 0 TODO/FIXME en código i18n |
| msgids duplicados en .po | 0 (276 por archivo) |
| Plurales PT (K2) | `_indice_plural` intacto (localization_manager.gd L358, nplurals=2) |

## 2. Evolución del cruzado (trazabilidad)

- **2026-10-21** (TANDA 18, msg 194): 145/25/115 -> 159/11/115 — migración de `eventos.historia_c*` al .po (commit `3b43f64`, conciliación por lotes msg 153).
- **2026-10-27** (GO#4 PT, Log 2217): pt.po creado (274 entradas, sha1 `95ee2ce0d1df`), cruzado 159/11/115 estable.
- **2026-11-01** (commit `22c2bcf`, cierre jornada agnes): **+SETTINGS.VOLVER_TITULO y SETTINGS.VOLVER_TITULO_CONFIRMAR en los 3 .po** (+6 líneas c/u) pero **ausentes de strings_*.json** -> cruzado pasa a **159/11/117**.

## 3. Deudas vivas (con dueño)

1. **11 solo-JSON mortuas** — `msg.inventario_lleno`, `msg.no_materiales`, `msg.nuevo_dia`, `npc.adios`, `npc.hola`, `ui.diario`, `ui.guardar`, `ui.inventario`, `ui.mapa`, `ui.opciones`, `ui.tienda`. Legado M60: el runtime M87 carga **solo .po** (autoload `Localization`), estas claves **no son traducibles en runtime**. Dueño: decisión del fundador (borrar del JSON o migrar a .po). Insumo conciliación msg 153.
2. **2 VOLVER* divergentes (NUEVO 1nov)** — `SETTINGS.VOLVER_TITULO` y `SETTINGS.VOLVER_TITULO_CONFIRMAR` existen en es/en/pt.po (`22c2bcf`) pero NO en strings_*.json. Pregunta de arquitectura: ¿canónico = .po (runtime) o JSON (maestro/validación)? Ver 04-Codigo.md §8b F1 (doble catálogo, dos roles). Necesita decisión antes de conciliar.
3. **117 solo-.po** — reclasificación T3 (msg 305): 108 vivas-runtime (89 M68 narrativas + 14 DIARY.CAT_* dinámicas + 4 CLOCK.ESTACIONES + 30 plantillas ROUTE/SIGN + UI.INTERACTUAR + SIGN.GENERICO + LM fallback) + 2 test-only + 2 drift + 1 deuda M53 + 1 muerta + 1 exenta (npc.catalina) + **2 VOLVER nuevas**. El .po NO está inflado.
4. **4 copies ES->PT** (HORAS_1/HORAS_H/MIN_1/MIN_M) — cognatos numéricos; revisión del traductor humano (RN9).
5. **Deuda de alcance** — 313 entidades traducibles fuera del riel (13 islas + 300 ítems): decisión GO del fundador (pendiente; no es de M87).
6. **Autoload duplicado (H-1)** — `Localization` (.po, canónico) vs `LocalizationManager` (JSON, `scripts/localizacion/`, sin consumidores de producción; preloadado solo por `_colector_sintaxis.gd` L541). Decisión del usuario.
7. **Drift documental de sha (reportado I-15/I-06, sin corregir por report-only)** — `87-Localizacion/plan-actual/05-Checklist.md` L68 y `04-Codigo.md` L223/L383 citan sha `95ee2ce0d1df` para pt.po; el canónico actual es **`6E5C19683F`** (commit `22c2bcf`, 21.359 B). Los docs quedaron stale tras la mejora de volver-al-menú.
8. **Gate CI qa_dirty** — 0 hits en `.github` (Familia C pendiente Cron C + cableado #452); afecta detección automática, no es deuda i18n propiamente.

## 4. Cómo verificar (reproducible)

```
python -X utf8 scripts/validar_i18n_integridad.py
```

Salida esperada (EXIT 0): ES/EN/PT 170/170/170 claves, paridad 0/0/0, placeholders 0, copias ES->PT 4, cruzado **159/11/117**.

## 5. Reglas de higiene (del proyecto)

- Texto nuevo jugador-visible -> clave en es.po + en.po + pt.po en el mismo cambio (política anti-huérfanas, TANDA 21).
- .po UTF-8 sin BOM y LF (AGENTS.md §28); exenciones de traducción con marcador `#. no-traducir: <motivo>` (ValidadorPO P5).
- Placeholders: una convención `{clave}` por catálogo JSON; `.po` usa `{n}` para plurales y printf `%s` heredado (ValidadorPO R12 vigila la mezcla).
- Todo cambio de catálogo -> re-correr el watchdog y actualizar §1 y §2 de este archivo.

---

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-11-06 (tanda i18n/doc I-05, encargo #343)
