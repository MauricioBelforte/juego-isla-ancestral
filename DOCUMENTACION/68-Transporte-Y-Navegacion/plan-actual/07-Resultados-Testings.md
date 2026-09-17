**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Log:** 910

# 07-Resultados-Testings.md — Módulo 68: Transporte y Navegación (iter. 2)

## 1. Resultado

```
=== Resumen M68 iter.2: 199 checks, 0 fallos ===
TEST M68 iter.2 OK — todos los checks pasaron
EXIT 0
SCRIPT ERROR: 0
```

Corridas: **×3** (`199/0`, `EXIT 0`, `SCRIPT ERROR: 0` en las tres).
Regresión iter. 1 (`test_transporte_m68.gd`): **177/0**, `EXIT 0`, `SCRIPT ERROR: 0`.

**Total M68: 376 checks, 0 fallos** (177 iter. 1 + 199 iter. 2).

## 2. Conteo por bloque (medido, no estimado)

| Bloque | Foco | Checks | Fallos |
|--------|------|--------|--------|
| A | planner: tiempos, cozy, fases, orientación, aborto | 39 | 0 |
| B | viajes especiales (M74/M31/tour) | 24 | 0 |
| C | viajes narrativos (M22/M23) | 24 | 0 |
| D | eventos de ruta (M64, RF18) | 15 | 0 |
| E | puente con M69 | 19 | 0 |
| F | localización (M87) | 30 | 0 |
| G | validador unificado + ciclo completo | 29 | 0 |
| H | integración en el autoload | 16 | 0 |
| — | arranque + guarda anti-falso-verde | 3 | 0 |
| | **Total** | **199** | **0** |

## 3. Bugs y hallazgos reales

### 3.1 Falso verde por aborto silencioso — reproducido en vivo (crítico)

Al dejar un `Identifier "_resultados" not declared` en `validate_transport.gd`
(resto de un `var` que eliminé), el compilador de GDScript hizo lo siguiente:

```
SCRIPT ERROR: Parse Error: Identifier "_resultados" not declared in the current scope.
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
```

Consecuencia: **el bloque G entero se saltó** (ni una sola de sus 29
comprobaciones se ejecutó) y la suite terminó con:

```
=== Resumen M68 iter.2: 169 checks, 0 fallos ===
TEST M68 iter.2 OK — todos los checks pasaron
```

Es decir: **"0 fallos" con 30 checks menos**. Es exactamente el patrón que el
proyecto ya había documentado en M124, aquí confirmado de nuevo.

**Fix aplicado (dos capas):**

1. Cada bloque registra su letra en `_fin()`; `_summary()` comprueba que estén las
   8 y **falla** si falta alguna.
2. Watchdog por temporizador (90 s) que imprime el último bloque iniciado y sale
   con código 1.

**Verificación de la guarda con sonda.** Se inyectó un aborto al inicio del bloque
C y la suite pasó a fallar correctamente:

```
[FAIL] los 8 bloques se completaron (sin abortos silenciosos) bloques que no terminaron: ["C"]
=== Resumen M68 iter.2: 175 checks, 1 fallos ===
TEST M68 iter.2 FALLÓ — 1 checks fallaron
```

### 3.2 Sobre-cierre de la iter. 1: "coste directo > combinar" NO es universal

La iter. 1 marcó `[x]` el ítem *"Coste directo mayor que combinar rutas (incentivo
de exploración)"* y lo documentó como *"el test la verifica"*. El test sólo
comprobaba **2 rutas** (aurora→sur y aurora→este). Medición real sobre las 20 rutas
(`ValidateTransport.medir_directo_vs_combinar`):

| Categoría | Rutas | Detalle |
|---|---|---|
| **Cumplen** (directo > combinar) | **4** | expresas: `r_aurora_sur`, `r_sur_aurora`, `r_aurora_este`, `r_este_aurora` |
| **Violan** | **6** | locales del muelle: `r_aurora_muelle`, `r_muelle_aurora` (8 vs 140), `r_muelle_sur`, `r_sur_muelle` (60 vs 88), `r_muelle_este`, `r_este_muelle` (70 vs 98) |
| **Sin alternativa** | **10** | la propiedad no aplica |

Las 6 violaciones son **correctas por diseño**: en una ruta local el viaje directo
*debe* ser la opción barata. Exigir la propiedad como invariante habría fallado en
6 rutas buenas. **Fix:** la propiedad pasa de invariante a **medición**
(`medir_directo_vs_combinar`), que el validador reporta en su informe y el test
comprueba (4 / 6 / 10). Corregido el `[x]` con nota en el `05-Checklist.md`.

### 3.3 M69 y M68 no comparten ninguna estación (hallazgo medido)

Emparejando las 4 anclas reales de `data/fasttravel/anclas.json` con las 10 paradas
de `transport_network.tres` (radio 12 m en XZ, más enlace por `stop_id`/`poi_id`):

```
M69/M68: 4 anclas, 0 compartidas, 4 huérfanas, 0 ofrecibles
  huérfanas (M69 sin parada M68): [LOC-RIZ-CASA-001, LOC-RIZ-PUB-001, LOC-RIZ-TIE-001, ancla_playa_norte]
```

M69 usa coordenadas x/z 256..320 (isla RIZ) y M68 usa `pos` con Z arriba en ±200:
**son marcos de coordenadas distintos**. La sección Q pide "compartir estaciones
con M69 (misma red)" y hoy eso no ocurre: el puente lo **detecta y lo reporta** en
vez de fingir que comparten. El mecanismo sí está verificado con 3 destinos
anclados a paradas reales (3 emparejadas por proximidad, 3 ofrecibles).
→ Dueño del re-anclaje: **M69**.

### 3.4 Traducción incompleta silenciosa (en)

`nombre_ruta(ruta, "en")` devolvía los nombres en **español** (`"Puerto de Aurora →
Puerto de la Isla del Sur"`) porque `nombre_parada()` sólo consultaba los `.po`
—que aún no tenían las claves— y caía al `nombre_fallback` español. Se detectó
comparando el catálogo generado `es` vs `en`: 13 claves idénticas, de las cuales 11
eran plantillas/moneda legítimas y **2 eran rutas mal traducidas**.
**Fix:** `nombre_parada()` consulta también `NOMBRES_EN` antes del fallback.
Tras el fix sólo quedan idénticas las claves legítimas (plantillas `M68.SIGN.*`,
`M68.TRIP.CURRENCY` = "AO", `M68.TRIP.HORAS_MINUTOS` = "{h} h {m} min").

### 3.5 Claves plurales contadas como "texto vacío"

El lector `.po` de `TransportLocalizer` metía las claves plurales en `mensajes` con
`msgstr ""`, de modo que `claves_vacias()` las reportaba como traducción vacía.
**Fix:** las claves plurales viven **sólo** en `plurales`; el `msgid` ya no crea
entrada en `mensajes`.

### 3.6 `Array` genérico rechazado por un parámetro `Array[String]`

`contexto.get("locales", ["es","en"])` devuelve un `Array` sin tipar. Pasarlo a
`validar_localizacion(locales: Array[String])` da:

```
SCRIPT ERROR: Invalid type in function 'validar_localizacion'. The array of argument 2
(Array) does not have the same element type as the expected typed array argument.
```

**Fix:** el parámetro pasa a `Array` y se convierte internamente a `Array[String]`.

### 3.7 Escapes `\n` / `\t` destrozados por Git Bash

Un `python -c "..."` con `\n`/`\t` escribió `/n/t/treturn` dentro del archivo de
sonda (el `if true:` quedó en una sola línea y el script no parseaba).
**Fix:** construir los caracteres con `chr(10)`/`chr(9)` en vez de escapes.

## 4. Cobertura conseguida en el `05-Checklist.md`

| Sección | Ítems marcados `[x]` en iter. 2 | Ítems que siguen abiertos / `[?]` |
|---|---|---|
| L. Viajes y Tiempos | 4 | 1 (`[?]` tiempos en el panel → M53) |
| M. Transiciones | 5 | 0 |
| N. Viajes Especiales | 5 | 0 |
| O. Viajes Narrativos | 4 | 1 (`[?]` diálogos a bordo → M21) |
| P. Eventos de Ruta | 5 | 0 |
| Q. Coordinación con M69 | 3 | 2 (`[?]` compartir estaciones y "M69 sólo muestra desbloqueadas" → M69) |
| V. Localización | 4 | 1 (`[?]` 3 idiomas → M87; carteles → M46) |
| W. Validación y QA | 5 | 0 |
| **Total iter. 2** | **35** | **5** |

## 5. Conclusión

- **376 checks headless, 0 fallos, 3 corridas, `SCRIPT ERROR: 0`** entre las dos
  iteraciones del módulo.
- La lógica de viaje del módulo queda **completa y verificada** en todo lo que no
  requiere escena, jugador, UI o mundo: plan, transiciones, viajes especiales,
  viajes narrativos, eventos de ruta, puente con M69, localización y validador.
- **5 ítems declarados `[?]` con dueño externo** (M21, M53, M69 ×2, M87/M46): no se
  cierran en falso.
- **1 `[x]` de la iter. 1 corregido** (§3.2) y **1 hallazgo nuevo** abierto para
  M69 (§3.3).
- **1 bug de proceso re-confirmado** (§3.1): el falso verde por aborto silencioso
  sigue siendo el patrón de fallo dominante del proyecto; esta iteración añade una
  guarda que lo convierte en un fallo ruidoso.
