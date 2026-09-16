# Log 910 — M68 Transporte y Navegación, iteración 2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Módulo:** 68-Transporte-Y-Navegacion (A2)
**Reserva:** `Logs/reservas/910-DSV41F-M68.txt` (borrada al cerrar)
**Reclamo:** no aplica — la iter. 1 (Log 828) es de este mismo agente.
**Entrada:** `36 [x] · 10 [?] · 85 [ ] = 131`
**Salida:** `70 [x] · 14 [?] · 47 [ ] = 131` (+35 `[x]`, +5 `[?]` con dueño)

---

## 1. Cómo apareció

M68 estaba `🟡 Liberado (Log 828)` con el núcleo data-driven cerrado y **85 ítems
abiertos**. Al abrir el `05-Checklist.md` aparecieron las secciones que la iter. 1
nunca tocó: **L** (viajes y tiempos), **M** (transiciones), **N** (viajes
especiales), **O** (viajes narrativos), **P** (eventos de ruta), **Q**
(coordinación con M69), **V** (localización) y **W** (validación y QA). Son
exactamente las 8 secciones que pedían *lógica* y no *escena*: todo eso es
verificable headless.

La iter. 1 había dejado además una **nota trampa** en el `04-Codigo.md`: la sección
*"Regla «nunca perder al jugador» (documentada, aún sin implementar)"* y
*"Coordinación con M69"*. Esas dos promesas son las que esta iteración convierte en
código.

Antes de escribir una línea se leyeron los **datasets reales** de las dependencias,
para no inventar ids:

| Dependencia | Fuente real leída | Qué se tomó |
|---|---|---|
| M74 festivales | `scripts/eventos/data/festivales/*.tres` (5) | fechas, estación, franja horaria |
| M22/M23 historia | `data/historia/historia_principal.json` | hitos `c4`, `c7`, `final_secreto`; sellos; flags |
| M31 luna llena | calendario lunar | ciclo 28 d, día 14 |
| M64/M43/M44 | `data/villagers/*.tres` (5 NPCs) | ids de NPC, clima adverso, señal audio/visual |
| M69 | `data/fasttravel/anclas.json` (4 anclas) | ids y coordenadas de anclas |
| M87 | `locales/es.po` / `en.po` | esquema de claves, formatos 12 h/24 h |
| — | `data/transporte/transport_network.tres` | 10 paradas / 20 rutas (única fuente de verdad) |

## 2. Qué se implementó (la parte verificable headless)

| Archivo | Bytes | Qué hace |
|---|---:|---|
| `scripts/transporte/transport_trip_planner.gd` | 10 069 | `TransportTripPlanner` — PLAN del viaje: 7 fases en orden fijo, duración cozy 2.4–4.0 s, umbral de viaje corto 90 s, **cargar destino ANTES de mover** y orientación al destino. `motivo_aborto` → `puede_perder_jugador = false`. |
| `scripts/transporte/transport_special_trips.gd` | 12 872 | `TransportSpecialTrips` — 7 viajes: los **5 festivales reales de M74** con sus fechas/franjas reales + `esp_luna_llena` (M31, ciclo 28 d) + `esp_tour_dirigible` (fin de semana). M74 gana si llega `contexto.eventos_activos`; si no, cae al calendario de M29. |
| `scripts/transporte/transport_narrative_trips.gd` | 10 407 | `TransportNarrativeTrips` — 3 viajes narrativos anclados a `historia_principal.json`: `nar_c4_templo_brisa`, `nar_c7_camara_sello`, `nar_final_secreto`. `avanzar_hitos()` duck-typea `Historia.completar_nodo()`/`marcar_sello()` y **nunca lanza**. |
| `scripts/transporte/transport_route_events.gd` | 11 475 | `TransportRouteEvents` — 5 eventos sobre NPCs reales. `FASES_SEGURAS = ["preparar","notificar"]`, climas adversos `[3,7]`, señal audio/visual/ambas. `elegir()` determinista por semilla. |
| `scripts/transporte/transport_m69_bridge.gd` | 11 059 | `TransportM69Bridge` — radio 12 m en XZ, empareja `stop_id`→`poi_id`→proximidad. Regla de precio `max(ceil(boleto×1.6), boleto+10)`. `detectar_duplicacion()` y `informe()`. |
| `scripts/transporte/transport_localizer.gd` | 22 589 | `TransportLocalizer` — resolución **por locale** leyendo el `.po` por su cuenta (verificar `en` no toca `Localization.set_locale`). 86 claves simples + 3 plurales por locale. |
| `scripts/transporte/validate_transport.gd` | 14 983 | `ValidateTransport` — **validador unificado**, 9 bloques + `simular_ciclo()` contra el manager real. `PENDIENTES_EXTERNOS` declara lo visual. |
| `scripts/transporte/dump_locales_m68.gd` | 1 838 | Vuelca el catálogo a `data/transporte/m68_catalogo.json`. |
| `scripts/transporte/test_transporte_m68_iter2.gd` | 39 818 | **199 checks** en 8 bloques con `_fin()` + watchdog. |
| `scripts/aplicar_locales_m68.py` | — | Fusiona el catálogo en `es.po`/`en.po`. Idempotente, rechaza BOM/CRLF, no pisa claves de M87. |

**Integración en el autoload** (`transport_manager.gd`, 21 497 B): los 5 registros
se crean en `_ready()`; `list_routes()` omite rutas programadas fuera de su ventana
y `_motivo_bloqueo()` ganó `"viaje especial: sólo programado"` (protege también
`buy_ticket`/`planificar`). Hooks de fecha forzada para los tests.

## 3. Causa raíz — hallazgos medidos

### 3.1 Falso verde por aborto silencioso — reproducido en vivo (crítico)

Al dejar un `Identifier "_resultados" not declared` en `validate_transport.gd`
(resto de un `var` que eliminé), el compilador hizo:

```
SCRIPT ERROR: Parse Error: Identifier "_resultados" not declared in the current scope.
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
```

Consecuencia: **el bloque G entero se saltó** (ni una de sus 29 comprobaciones
corrió) y la suite terminó con:

```
=== Resumen M68 iter.2: 169 checks, 0 fallos ===
TEST M68 iter.2 OK — todos los checks pasaron
```

**"0 fallos" con 30 checks menos.** Es el patrón dominante del proyecto (M124,
Log 905) reconfirmado.

### 3.2 Sobre-cierre de la iter. 1: "coste directo > combinar" NO es universal

La iter. 1 marcó `[x]` el ítem *"Coste directo mayor que combinar rutas (incentivo
de exploración)"* y lo justificó con *"el test la verifica"* — pero el test sólo
comprobaba **2 rutas**. Medición real sobre las 20 rutas:

| Categoría | Rutas | Detalle |
|---|---:|---|
| **Cumplen** | **4** | expresas: `r_aurora_sur`, `r_sur_aurora`, `r_aurora_este`, `r_este_aurora` |
| **Violan** | **6** | locales del muelle: `r_aurora_muelle`/`r_muelle_aurora` (8 vs 140), `r_muelle_sur`/`r_sur_muelle` (60 vs 88), `r_muelle_este`/`r_este_muelle` (70 vs 98) |
| **Sin alternativa** | **10** | la propiedad no aplica |

Las 6 violaciones son **correctas por diseño**: en una ruta local el directo *debe*
ser lo barato. Exigirlo como invariante habría roto 6 rutas buenas.

### 3.3 M69 y M68 no comparten ninguna estación (hallazgo medido)

Emparejando las 4 anclas reales de `anclas.json` con las 10 paradas del `.tres`
(radio 12 m en XZ + enlace por `stop_id`/`poi_id`):

```
M69/M68: 4 anclas, 0 compartidas, 4 huérfanas, 0 ofrecibles
  huérfanas: [LOC-RIZ-CASA-001, LOC-RIZ-PUB-001, LOC-RIZ-TIE-001, ancla_playa_norte]
```

M69 usa x/z 256..320 (isla RIZ) y M68 usa `pos` con Z arriba en ±200: **marcos de
coordenadas distintos**. El puente lo **detecta y lo reporta** en vez de fingir que
comparten. El mecanismo sí queda verificado con 3 destinos anclados a paradas
reales (3 emparejadas por proximidad, 3 ofrecibles).

### 3.4 Traducción incompleta silenciosa (en)

`nombre_ruta(ruta, "en")` devolvía los nombres en **español** porque `nombre_parada()`
sólo consultaba los `.po` —que aún no tenían las claves— y caía al
`nombre_fallback` español. Detectado comparando el catálogo `es` vs `en`: 13 claves
idénticas, de las cuales **2 eran rutas mal traducidas**.

### 3.5 Claves plurales contadas como "texto vacío"

El lector `.po` metía las claves plurales en `mensajes` con `msgstr ""`, de modo que
`claves_vacias()` las reportaba como traducción vacía (falso positivo).

### 3.6 `Array` genérico rechazado por un parámetro `Array[String]`

```
SCRIPT ERROR: Invalid type in function 'validar_localizacion'. The array of argument 2
(Array) does not have the same element type as the expected typed array argument.
```

`contexto.get("locales", ["es","en"])` devuelve un `Array` sin tipar. Falló 7 checks.

### 3.7 Escapes `\n` / `\t` destrozados por Git Bash

Un `python -c "..."` con `\n`/`\t` escribió `/n/t/treturn` dentro del archivo de
sonda (el `if true:` quedó en una línea y el script no parseaba).

## 4. Fix aplicado

| Hallazgo | Fix | Evidencia |
|---|---|---|
| 3.1 aborto silencioso | (a) cada bloque registra su letra en `_fin()`; `_summary()` **falla** si falta alguna; (b) watchdog de 90 s que imprime el último bloque y sale con 1 | sonda inyectada en el bloque C → `[FAIL] los 8 bloques se completaron ... no terminaron: ["C"]`, `175 checks, 1 fallos` |
| 3.1 stale `_resultados` | declaración y uso eliminados por completo | `SCRIPT ERROR: 0` en 3 corridas |
| 3.2 propiedad falsa | de **invariante** a **medición**: `ValidateTransport.medir_directo_vs_combinar()` la reporta y el test comprueba 4/6/10 | `[x]` corregido con nota en el checklist |
| 3.3 M69 sin estaciones | no se finge: `detectar_duplicacion()` + `informe()` lo reportan; el mecanismo se verifica con 3 anclas sobre paradas reales | §Q del informe |
| 3.4 EN en español | `nombre_parada()` consulta también la tabla `NOMBRES_EN` antes del fallback | sólo quedan idénticas las claves legítimas (`M68.SIGN.*`, `M68.TRIP.CURRENCY`="AO", `M68.TRIP.HORAS_MINUTOS`) |
| 3.5 plurales "vacíos" | las claves plurales viven **sólo** en `plurales`; el `msgid` ya no crea entrada en `mensajes` | `claves_vacias()` = 0 |
| 3.6 `Array` sin tipar | parámetro pasa a `Array` y se convierte internamente a `Array[String]` | 7 checks en verde |
| 3.7 escapes | construir con `chr(10)`/`chr(9)` en vez de escapes | sonda parsea |

## 5. Verificación

```
=== Resumen M68 iter.2: 199 checks, 0 fallos ===
TEST M68 iter.2 OK — todos los checks pasaron
EXIT 0 · SCRIPT ERROR: 0        (×3 corridas)
```

Regresión iter. 1 (`test_transporte_m68.gd`): **177/0**, `EXIT 0`, `SCRIPT ERROR: 0`.
**Total M68: 376 checks, 0 fallos.**

Bloques medidos (no estimados): A 39 · B 24 · C 24 · D 15 · E 19 · F 30 · G 29 ·
H 16 = 196 + 3 de arranque/guarda = **199**.

Comando:

```bash
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/transporte/test_transporte_m68_iter2.gd
```

## 6. Trabajo colateral

- `04-Codigo.md` reescrito: cabecera a iter. 2, mapa de archivos real y §10–§16
  (API nueva, corrección del `[x]` optimista, integración en el manager, honestidad,
  trampas, comandos, recomendaciones).
- `06-Plan-Testings.md` y `07-Resultados-Testings.md` **creados** (no existían).
- `05-Checklist.md`: 33 `[ ]`→`[x]` simples + 6 líneas reemplazadas (5 → `[?]` con
  dueño, 1 `[?]`→`[x]`). Estado final `70/14/47`.
- **Localización:** `dump_locales_m68.gd` → `data/transporte/m68_catalogo.json`;
  `scripts/aplicar_locales_m68.py` fusionó **+89 claves por locale** en
  `locales/es.po`/`en.po` (segunda corrida: `nada nuevo (idempotente)`).
- **CI:** `test_transporte_m68.gd` (iter. 1) y `..._iter2.gd` (199) cableados en la
  job `test-suite` de `.github/workflows/quality.yml`.
- **Caché de clases:** `--headless --editor --quit` registró las 7 clases nuevas
  (`TransportTripPlanner`, `TransportSpecialTrips`, `TransportNarrativeTrips`,
  `TransportRouteEvents`, `TransportM69Bridge`, `TransportLocalizer`,
  `ValidateTransport`); antes sólo había 3 (`Network`/`Route`/`Stop`).

## 7. Hallazgo secundario (no resuelto, es de otros)

- **M69 debe re-anclar** sus 4 anclas a paradas de M68 (o declarar formalmente que
  son redes distintas). Dueño: M69.
- **M74 debe exponer** el flag `festival_activo` y emitir `STOP_BUILT`, que el
  puente de viajes especiales consume cuando existe. Dueño: M74.
- **M53 (panel)** debe mostrar tiempos y descuentos; **M21** los grafos de diálogo a
  bordo; **M46/M54** los carteles y la capa de rutas en el mapa. Dueños externos.

## 8. Lección transversal

> **Un `[x]` no puede apoyarse en "el test lo verifica" si el test no cubre todos
> los casos.** La iter. 1 cerró una propiedad universal con una aserción de 2 rutas;
> la medición real dio 4/6/10. Cuando una propiedad no se cumple en el 100 % de los
> casos, deja de ser invariante y pasa a ser **medición reportada**.

> **"0 fallos" sin `SCRIPT ERROR: 0` no es verde.** Un aborto silencioso dentro de un
> bloque salta el bloque entero y la suite sigue diciendo "OK". La guarda de
> marcadores + watchdog convierte ese fallo invisible en un fallo ruidoso — y hay que
> **probar la guarda con una sonda**, no confiar en que funciona.

## 9. Cierre del ciclo

- `05-Checklist.md` → **70 `[x]` · 14 `[?]` · 47 `[ ]`** (131 ítems reales).
- **Fila 68 de `CHECKLIST-GLOBAL.md`:** `🔵 En curso (iter. 2) | 36/131` →
  `🟡 Con dudas / Liberado (iter. 2 ✅) | 70/131`.
- `Mensajes entre modelos/ESTADO-PARALELO.md` actualizado (cierre + liberación).
- Reserva `910-DSV41F-M68.txt` borrada. `Logs/ULTIMO_NUMERO.txt` en 911 (reservado
  por `glm-5.3-flash` para M92).
- **CI verde**, `global_script_class_cache.cfg` regenerado.

## 10. Pendientes

- **QA cruzado §21.8 de M68 iter. 2** por otro agente (verificador ≠ autor).
- **5 `[?]` propios con dueño externo:** M21 (diálogos a bordo), M53 (tiempos en el
  panel), M69 ×2 (compartir estaciones / sólo desbloqueadas), M87+M46 (tercer idioma
  / carteles).
- **Cola:** siguiente módulo propio = **M27 Islas-Del-Mundo** (A5, 16 `[ ]` propios).

---

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-15
