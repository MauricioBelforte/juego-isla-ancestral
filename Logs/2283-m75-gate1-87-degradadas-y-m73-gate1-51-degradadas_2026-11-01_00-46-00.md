# Log 2283: M75 gate-1 (87 degradadas) + M73 gate-1 (51 degradadas) — 138 marcas en 2 módulos

**Fecha:** 2026-11-01
**Hora:** 00:43
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (mensaje 235)
**Rol:** gate-1 (§21.8.2.b) — auditor verificador del canal, **no sella**

---

## Resumen

La directora `agnes-3-flash` (mensaje 234) **invalidó el sello de M75** por drift (72 ítems de diferencia
entre lo declarado y el disco) y autorizó gate-1 sobre **M75 + M73 ahora**, sin esperar el GO macro del
fundador para el resto del pool. Este log cierra ambas auditorías.

Resultado: **138 marcas `[x]` → `[?]`** en dos módulos, con nota por línea, bloque de evidencia y
`Totales` re-baselinizado. Cero commits propios: el de M75 lo hizo la directora en `22c2bcf`; el de M73
queda en el árbol para que lo commitee ella.

| Módulo | Antes | Después | Degradadas | Mantenidas |
|---|---|---|---|---|
| M75 Postgame | 130 / 0 / 0 | **43 / 0 / 87** | 87 | 9 (+34 del baseline) |
| M73 Coleccionables | 127 / 3 / 5 | **76 / 3 / 56** | 51 | 13 |

## Cambios realizados

### M75 — Postgame (87 degradadas, 9 mantenidas)

De los **96 pares puros** de `dd6fb70` (líneas idénticas al commit padre salvo la marca, sin nota ni
artefacto) se degradaron **87**. Los 9 restantes tienen artefacto propio demostrable y quedaron anotados
con `MANTENIDO — <evidencia>`:

- L25 y L216 → `sugerir_que_sigue()` en `postgame_manager.gd` L172
- L34/L35 → filas `postgame_isla_este` / `postgame_isla_flotante` en `actividades.json`
- L50 → fila `postgame_muebles_evento`
- L196 → `validate_mp_contract.gd` L128 exige cero refs de red
- L209 → catálogo sin campos de fecha; `repite` en las 7 filas
- L241 → `## Notas del Agente` en `04-Codigo.md`
- L242 → 5 documentos firmados

Los **34 `[x]` no promovidos** son el baseline legítimo: llevan evidencia «iter. 1 / iter. 2» con el
artefacto citado. `postgame_manager.gd` tiene `activar_postgame()` L101, `es_visible_al_jugador()` L118,
`actividades_disponibles()` L127, `sugerir_que_sigue()` L172, `registrar_actividad()` L201 y
`marcar_epilogo_visto()` L238; `actividades.json` tiene 7 filas con campo `dueno` externo (`M27`,
`M27/M10`, `M25/M37`, `M19/M71`, `M50/M33`, `M36/M35`, `M18/M16`).

**3 ítems de cierre medidos como FALSOS:** `verificar_checklist.py` sale **código 1**; `plan-inicial ==
plan-actual` es FALSO (4 de 5 archivos difieren, solo `02-Analisis.md` idéntico); `ESTADO-PARALELO.md`
tiene 0 menciones de M75 y el Global quedó en un `130/130` inválido.

### M73 — Coleccionables (51 degradadas, 13 mantenidas)

M73 **sí tiene sistema real**, así que la degradación fue selectiva y no en bloque. Artefactos
verificados en disco: `catalog.json` con **81 filas en 19 categorías**, `coleccionables_manager.gd` con
`registrar()` / `registrar_por_local()` / `registrar_por_fuente()` / `es_collected()` /
`porcentaje_categoria()` / `porcentaje_total()` / `get_save_data()` / `restore_save_data()`, y 5 suites de
test + `validate_collectibles.gd` (87 líneas, existe).

**Las 13 mantenidas:** L44 (minerales_005 «Mineral Ancestral» rareza 3 con `gema_ancestral`), L92 (filas
«Foto de Criatura» y «Foto de Paisaje»), L139 (fuente `simbolo`→`simbolos` probada en lote4), L140 (3 de 4
filas son runas), L148 (fila «Mensaje de Correo»), L150 (fuente `mensaje`→`mensajes` probada), L151
(dedupe probado por `_test_registro_idempotente` / `_test_reliquia_duplicada_idempotente` /
`_test_fragmento_dedupe`), L156 (secretos de exploración + fuente `secreto`), L164 (objetos_historia por
capítulo + fuente `mision`), L181 (`porcentaje_total()` probado), L183 (`achievement_service.gd` L157-158
conecta `categoria_completed`), L203 (`validate_collectibles.gd` **existe**; la nota «revertido: artefacto
inexistente» era **stale**), L205 (`_test_persistencia` L149).

**Las 51 degradadas, por causa:**

1. **Integración no cableada (la causa más grande).** `_conectar_a_fuentes()` solo conecta
   `especie_avistada` (fauna). Un comentario del propio manager dice que minería «por ahora no conecta
   directo (no hay señal pública estable)». Todos los «Registrar al extraer/pescar/cosechar/colocar/leer»
   son deuda, no hecho.
2. **Recompensa que no se entrega.** `_on_categoria_completa()` (L188) **solo emite la señal**; comentario
   literal: «Por ahora solo emitimos la señal. M14/M38 darán el ítem cuando lo consuman». El único
   consumidor de `categoria_completed` es `achievement_service.gd` (logros), no un dador de ítems. Por eso
   caen L172-L175 y los 14 «X como recompensa (Mn)»: la recompensa real de toda categoría es
   `moneda_ancestral` o `gema_ancestral`, nunca trofeo de pesca, jaula, álbum, sobre, esqueleto, tesoro,
   pista, historia de NPC, contenido oculto, final alterno ni mejora de herramienta.
3. **Categoría inexistente.** `catalog.json` no tiene `documentos` (19 categorías, ninguna es documentos) →
   la sección O completa cae, y `_categoria_para_fuente` no mapea `leer`/`documento`.
4. **Migración que no migra.** `restore_save_data()` hace `if int(data.get("version", 0)) < VERSION:
   return` → descarta el save viejo en vez de migrarlo (L190).
5. **Mediciones no ejecutadas.** L198 pide 500 ítems y el catálogo tiene 81; L199 pide 22 categorías y hay
   19 (lote4 afirma «19 categorias coexisten»); L197 apoya media afirmación en M62, que está en gate por
   BUG-069.
6. **Dato numérico falso.** L215 pide confirmar 130 ítems cuando el header dice 135 y `plan-inicial !=
   plan-actual`.

**Bonus:** se corrigió mojibake preexistente en L204/L205 (`â†’` → `→`).

## Archivos modificados

- `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md` — 87 `[x]`→`[?]`, 9 `MANTENIDO`, bloque de
  evidencia (40 líneas), `Totales` 29/101/0 tachado + 43/0/87 nuevo. **Commiteado por la directora en
  `22c2bcf`.**
- `DOCUMENTACION/73-Coleccionables/plan-actual/05-Checklist.md` — 51 `[x]`→`[?]`, 13 `MANTENIDO`, bloque de
  evidencia (~60 líneas), `Totales` 63/70/2 tachado + 76/3/56 nuevo, mojibake corregido. **Sin commit
  (lo commitea la directora).**
- `Logs/NUMEROS_DISPONIBLES.txt` — consumido el 2283.
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/235-...md` — reporte a la directora.

## Verificación

- M73 en disco: `[x]=76  [ ]=3  [?]=56  total=135` (coincide con la línea `Totales` nueva).
- BOM: **no**. CRLF: **0** (LF preservado). Mojibake: **0** tras el fix.
- Las 5 `[?]` previas (L60, L79, L84, L100, L132) y las 63 marcas del baseline **no se tocaron**.
- `git status` de M73: **1 archivo modificado**, sin otros archivos de documentación tocados por mí.

## Notas

- **No se tocaron las otras 859 marcas** del pool: eso espera el GO macro del fundador.
- **No se tocó `CHECKLIST-GLOBAL.md`**: los sellos y las filas globales son de la directora.
- M67, M75 y M73 no son el mismo caso: M67 era librería headless sin artefactos (63/63 revertidas);
  M75 y M73 tienen sistema real y por eso la degradación fue selectiva.
- Acumulado de la sesión: **373 marcas** (235 previas + M75 87 + M73 51) en 8 módulos.
