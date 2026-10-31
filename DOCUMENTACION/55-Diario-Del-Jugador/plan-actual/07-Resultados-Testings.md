**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 07-Resultados-Testings.md — Módulo 55: Diario del Jugador

Fecha de la corrida: **2026-10-04** (iter. 2, lote 1 de UI). Entorno: Godot 4.7.2 headless,
Windows. Logs completos en `$env:TEMP\opencode\` (no se versionan).

## 1. Resultados

| Suite | Comando (`--headless --path game/isla-ancestral --script …`) | Resultado | Log |
|---|---|---|---|
| S1 servicio | `res://scripts/diario/test_diario.gd` | **0 fallos, exit=0** | `m55_reg_diario.log` |
| S2 UI (nueva) | `res://scripts/ui/test_diario_ui.gd` | **89 checks, 0 fallos, exit=0** | `m55_verde_final.log` |
| S3 i18n regresión | `res://scripts/ui/test_ui_i18n_m53.gd` | **0 fallos, exit=0** | `m55_reg_i18n.log` |
| S4 framework regresión | `res://scripts/ui/test_ui_framework.gd` | **0 fallos, exit=0** | `m55_reg_framework.log` |
| S5 settings regresión | `res://scripts/ui/test_settings_audio_roundtrip.gd` | **51 checks, 0 fallos, exit=0** | `m55_reg_settings.log` |

**Total: 5/5 suites verdes.** Baselines previos a tocar código (misma sesión, antes de
escribir): `m55_base_diario.log` (S1 0 fallos) y `m55_base_i18n.log` (S3 0 fallos) — sin
regresión respecto del punto de partida.

## 2. Sonda rojo demostrada (guardián del test)

1. **Sabotaje:** en `diary_layer.gd`, `_texto_fila` dejó de anteponer `★ ` (`"XXX "` a cambio).
2. **Corrida rojo:** `m55_rojo.log` → `exit=1`, `FALLO: ★ al inicio de la fila tras marcar
   favorito (obtuvo: XXX Catalina Oso · Visto)`, `=== TEST M55 DIARIO UI: 89 checks, 1 fallo(s) ===`.
3. **Revert** del sabotaje → `m55_verde_final.log` → `exit=0`, **89/0**.

Conclusión: el test **detecta regresiones reales** (no es verde por omisión).

## 3. Bugs encontrados y corregidos durante los tests

| # | Bug | Causa | Fix | Detectado por |
|---|---|---|---|---|
| B1 | Desmarcar favorito no refrescaba la fila | `_on_favorito_pressed` usaba `if not alternar_favorito(...)` como guard, pero devuelve el **nuevo estado** (false al desmarcar) | guard con `esta_registrada()` + refresh incondicional | check ★ de S2 (corrida 1) |
| B2 | Textos estáticos no se re-traducían al abrir en locale EN | `on_layer_opened` no volvía a aplicar i18n | `_aplicar_textos_estaticos()` al abrir | check `Close` de S2 (corrida 1) |
| B3 | Atajos `diario`/`favorito` no encontraban la capa | el test la instanciaba como `DiaryTest`; `ui_manager` busca `"DiaryLayer"` | nombre correcto + liberación preventiva de capa homónima previa | acciones de S2 (corrida 1) |
| B4 (preexistente, NO mío) | `SCRIPT ERROR: Nonexistent 'bool' constructor` en `interaction_manager.gd:669` al hacer `pop_layer` | `interaction_manager` (zona BUG-096, kimi-k3) | **no tocado** — emisión de ruido que no aborta resultados; aparece también en las suites de M53 | consola de S2 |

Corrida 1 de S2: **89 checks, 4 fallos + 1 error preexistente** → fixes B1–B3 → corrida 2 verde.

## 4. Verificaciones de calidad de archivo

- `es.po`/`en.po`: UTF-8 sin BOM, 0 U+FFFD, EOL LF, +19 claves `DIARY.*` por idioma (verificado con script propio).
- `project.godot`: bloque `[input]` con CRLF preservado; acción `diario` insertada idempotente (script con guard).
- `05-Checklist.md`: UTF-8 sin BOM/FFFD, CRLF intacto (230 líneas), conteo de marcas 33 [x] / 1 [?] / 97 [ ] = 131.

## 5. Pendientes no cubiertos por esta corrida (honestidad)

- 13/14 categorías con entradas (`fotografías` = 0, falta M56) → checklist Y en `[?]`.
- Rendimiento/500+ entradas, virtualización, pooling (W), tercer idioma (V), `validate_diary.gd` (Y),
  persistencia entre sesiones reales (Z): **fuera de esta corrida**, sin probar.
- Estética "cozy": sin vía de visión (M154) usada en esta sesión; verificación solo estructural.

---

## 6. Corrida T-M1 lote 2 — 2026-10-05 (mimo-v2.6-flash-free / opencode)

Entorno: Godot 4.7.2 headless, `C:\Temp\godot\godot472.exe`. Criterio: exit code + conteo de FALLO.

| Suite | Comando (`--path game/isla-ancestral`) | Resultado | EXIT |
|---|---|---|---|
| Validador | `--script res://scripts/diario/validate_diary.gd` | **0 fallos, 1 aviso** (aviso = `fotografías` 0 entradas, pendiente M56) | 0 |
| Servicio | `--script res://scripts/diario/test_diario.gd` | **0 fallos** | 0 |
| UI (regresión) | `--script res://scripts/ui/test_diario_ui.gd` | **89 checks, 0 fallos** (SCRIPT ERROR `interaction_manager` = BUG-096 preexistente, no del diario) | 0 |
| Persistencia 2 procesos | `--script res://scripts/diario/test_diario_persist.gd` | **0 fallos** (padre guarda M59 slot 3 → hijo `load_slot` verifica ★/estado/día/ui prefs → padre restaura backup) | 0 |

**Sonda roja del validador** (demostración de que detecta catálogo roto):
copia truncada al 60% (`JSONDecodeError` confirmado en Python) pasada como user arg →
`21 fallos, 0 avisos`, **EXIT 1**. Copia borrada tras la prueba.

**Persistencia — detalle:** el padre hace backup byte a byte de slot 3 (`.save` + `.bak`),
siembra datos, `request_save` esperando `save_completed` por frames, lanza al hijo con
`OS.execute` bloqueante y exige `salida == 0`; el hijo `load_slot(3)` verifica y
re-serializa `get_save_data()`. Restauración del slot previo + `SaveWriter.cleanup_orphan_tmp()`
garantizan que el save del jugador no queda tocado.

**Decisión de pipeline:** `OS.execute(..., read_stderr=true)` colgaba el proceso en Windows
(timeout sin EXIT) → `read_stderr=false` (el exit code es el contrato del test).

**Estado de marcas tras la corrida:** 37 [x] / 3 [?] / 91 [ ] en `05-Checklist.md`.
Los [?] restantes documentados en §5 y en el 05 (L20 icono, L53/L212 foto M56, L212 13/14).

## 7. Pendientes heredados (siguen sin cubrirse)

- Virtualización/pooling/LazyLoad y 500+ entradas (W) — lote de rendimiento aparte.
- Tercer idioma / plurales (V).
- Descripciones para 36/44 entradas, iconos (L203), galería Q, estética cozy (L29).

---

## 8. Iter. 6 — iconografía (2026-10-27, DeepSeek-V4.1-Flash, Log 2210)

### 8.1 Suite nueva: `scripts/diario/test_diario_iconos_m55.gd`

**MEDIDO: 56 checks / 0 fallos / EXIT 0 ×3 corridas, 0 SCRIPT ERROR.**
Piso `CHECKS_MINIMOS = 56` **medido** en verde (bloques A 14 · B 17 · C 10 · D 11 · E 4).

| Bloque | Qué ejercita |
|---|---|
| A | derivación del id: los 4 prefijos de familia, categorías sin familia, id sin prefijo, id que queda vacío |
| B | resolución en 3 niveles, fallback nunca `null`, instancia cacheada, 16×16, `Button.icon` + `icon_max_width` como constante de tema |
| C | inventario medido: aritmética (derivables+sin_familia==entradas), contrato con M46 (minerales y plantas resuelven), `iconos_ausentes()` == derivables − en_inventario, sin duplicados |
| D | integración por fuente: el layer precarga y llama al resolutor, fila y detalle asignan icono, la secreta no, el service expone `icono`, el validador corre el bloque y tiene piso |
| E | forma del catálogo M46: ≥40 ids, cada id declara `estado` y `familia` |

**Guardián probado EN ROJO** (sonda con restauración byte-exacta, sha256
`70c2ce01…` verificado tras restaurar):

| Corrida | Resultado |
|---|---|
| control (sin mutar) | EXIT 0, 2,8 s |
| inyección de aborto de runtime al inicio del bloque B | **EXIT 1**, 2,9 s (**sin cuelgue**), `[FALLO] el bloque B NO se ejecutó`, `[FALLO] solo 41 checks ejecutados (mínimo medido 56)`, resumen `41 checks, 2 fallo(s)` |

La inyección usa un **intermedio sin tipo** (`var _pv: Variant = []` → `var _pboom: Dictionary = _pv`):
un literal mal tipado sería `Parse Error` estático y no probaría el guardián de runtime.

### 8.2 Regresión de las suites del módulo (todas EXIT 0, 0 SCRIPT ERROR)

| Suite | Resultado |
|---|---|
| `test_diario.gd` | 0 fallo(s) |
| `test_diario_ui.gd` | **89** checks / 0 fallos (sin cambios: el icono no altera el paso) |
| `test_diario_perf_m55.gd` | **26** checks / 0 fallos (sin cambios) |
| `test_diario_persist.gd` | 0 fallo(s) |
| `validate_diary.gd` | **388** checks / 0 fallos / **3 avisos** (antes 3 avisos, ahora 2 de ellos son la deuda de iconografía medida) |

`--check-only` sobre los 5 archivos tocados: **EXIT 0** y **0** `SCRIPT ERROR|Parse Error|Compile Error`.

### 8.3 Efecto sobre las marcas (NO aplicado: lo aplica el director)

| Ítem | Estado en disco | Propuesta | Evidencia |
|---|---|---|---|
| L203 icono faltante con fallback | `[ ]` | **`[x]`** | resolutor de 3 niveles + fallback procedural cacheado + bloque B (17 checks) |
| L93 validar iconos de gemas/minerales | `[ ]` | **`[x]`** | `_validar_iconos()` + bloque C: 3/3 minerales y 2/2 plantas resuelven en el inventario M46 |
| L20 modelo de entrada con `icono` | `[x]` (flip Beam sin sustento) | **`[x]` (ahora sí con evidencia)** | el campo existe, se expone por el service y tiene consumidor real (nivel 1 del resolutor) |
| L117 iconografía de Sellos (M46) | `[ ]` | **sigue `[ ]`** | 0/7 sellos con id en el inventario; 3 vocabularios disjuntos (ver 04-Codigo iter. 6, hallazgo 2) |
| L77 siluetas del bestiario (M46) | `[x]` (flip Beam sin sustento) | **bajar a `[ ]`** | el validador ya existe, pero 0/4 criaturas tienen id en el inventario M46: la iconografía no existe |
| L85 iconos de hojas | `[x]` (flip Beam sin sustento) | **bajar a `[ ]`** | ídem: las 2 plantas sí resuelven, pero la validación de "hojas" como familia no tiene arte |

Los 3 flips de Reflection-Beam-1.0 (L20/L77/L85) citan `03-Diseno.md §` **sin número de
sección** y su propia nota dice "no hay validador / ICONO pendiente". Eran flips inflados
cuando se aplicaron; L20 pasa a tener sustento real con esta iteración, L77/L85 no.

## 9. Iter. 7 — "???" solo en lore + loader del icono (2026-10-28, DeepSeek-V4.1-Flash, Log 2237)

### 9.1 Suite nueva: `scripts/diario/test_diario_lore_m55.gd` (67 checks)

| Bloque | Qué prueba | Checks |
|---|---|---|
| A | clasificación de las 14 categorías + tabla de verdad de `bloqueada()` + cruce con `CATEGORIAS` del servicio | 29 |
| B | visibilidad REAL del servicio con catálogo sintético (la secreta de lore aparece; la de colección no hasta registrarse) | 14 |
| C | **capa instanciada en el árbol**: texto de fila y de detalle para ambos casos + `_cat_de` sin `cat` | 9 |
| D | regla de datos: catálogo real sin violaciones + fixture que la dispara + tipo del campo | 9 |
| E | el loader propaga `icono` (44/44) y el nivel 1 del resolutor queda alcanzable | 6 |
| **Total** | **A 29 + B 14 + C 9 + D 9 + E 6** | **67** |

Resultado: **67 checks / 0 fallos / EXIT 0 ×3**, `SCRIPT ERROR: 0`, piso **67 MEDIDO**.

### 9.2 Regresión de las suites del módulo (todas EXIT 0, 0 SCRIPT ERROR)

| Suite | Resultado |
|---|---|
| `scripts/diario/validate_diary.gd` | 392 checks, 0 fallos, 3 avisos (piso 391) |
| `scripts/diario/test_diario.gd` | 36 checks, 0 fallos (piso 36, contador nuevo) |
| `scripts/diario/test_diario_persist.gd` | 0 fallos (sin contador: reportado) |
| `scripts/diario/test_diario_iconos_m55.gd` | 56 checks, 0 fallos |
| `scripts/ui/test_diario_ui.gd` | 89 checks, 0 fallos |
| `scripts/ui/test_diario_perf_m55.gd` | 26 checks, 0 fallos |

### 9.3 Regresión PROPIA corregida en esta vuelta

`test_diario_iconos_m55.gd` (iter. 6) afirmaba el piso del validador como **literal**
(`CHECKS_MINIMOS: int = 387`). Al subir el piso a 391 la suite se puso ROJA — es el patrón "test que
fija una cifra que legítimamente cambia" (trampa 97). Ahora el piso se **parsea** con `RegEx` y se
afirma `>= 387` (que exista y que no baje del mínimo histórico).

### 9.4 Efecto sobre las marcas (NO aplicado: lo aplica el director)

- **L164** `[ ]` → **`[x]` propuesto**: la regla está implementada en las 3 capas y verificada con 67
  checks + 5 sondas en rojo. Caveat explícito: el catálogo tiene **0** entradas `secreta`, así que el
  cambio **no se observa todavía en juego**.
- `test_diario.gd` gana guardián; **no** cambia ninguna marca.
