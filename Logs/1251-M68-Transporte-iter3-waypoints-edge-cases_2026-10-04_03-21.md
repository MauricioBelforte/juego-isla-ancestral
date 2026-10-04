# Log 1251 - M68 Transporte y Navegacion iter. 3

- Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
- Fecha: 2026-10-04 03:21 (UTC)
- Modulo: M68 Transporte y Navegacion
- Iteracion: 3 (waypoints de ruta + edge cases T verificables headless)
- Entrada: M17 iter. 3 APROBADA por el coordinador (mensaje 07-2026-10-04_02-38-00); M68 asignado como frente prioritario
- Reserva: log 1251 (pool NUMEROS_DISPONIBLES.txt, protocolo v3; cabecera del pool ahora 1252)

## 1. Alcance

La iter. 3 cierra la mitad verificable headless que quedaba de las secciones
J (Marcadores y Waypoints) y T (Edge Cases), sin tocar escena/UI/3D:

- Modelo puro de waypoints de ruta (`TransportRouteWaypoints`).
- API del manager: `waypoints_de_ruta()` / `es_ruta_larga()`.
- Gate de contexto de viaje: dialogo (M21) bloquea; inventario lleno se reporta.
- Edge cases T: dinero justo, ultima hora de horario, parada recien desbloqueada
  (M71) + clima (M32).

## 2. Archivos

Nuevos:

- `game/isla-ancestral/scripts/transporte/transport_route_waypoints.gd`
  (`class_name TransportRouteWaypoints`, `extends RefCounted`, modelo PURO)
- `game/isla-ancestral/scripts/transporte/test_transporte_m68_iter3.gd`

Modificados:

- `game/isla-ancestral/scripts/transporte/transport_manager.gd`
  (+ waypoints_de_ruta, + es_ruta_larga, + contexto_de_viaje / gate en buy_ticket,
   + forzar_contexto_viaje / limpiar_contexto_viaje)
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/04-Codigo.md` (nota iter. 3)
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/05-Checklist.md`
  (encabezado stale 36/131 -> estado real; 70 -> 75 [x]; totales)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`

NO modificados (por indicacion del director):

- `.github/workflows/quality.yml` (lo edita s2 por BUG-091 modo A; evitar edicion
  concurrente). La suite iter. 3 queda SIN cablear; ver seccion 6.
- `CHECKLIST-GLOBAL.md` (fila 68; tiene una edicion AJENA en vuelo, ver seccion 9).

## 3. Decisiones de diseno

(a) MODELO PURO SEPARADO. `TransportRouteWaypoints` no conoce nodos ni el autoload:
   convierte un camino (lista de paradas) o un plan de `planificar()` en waypoints
   (`{indice, stop_id, pos, fraccion, es_destino, tramo_m, acumulado_m}`). Asi la
   logica de waypoints se testea headless y la UI (M54) solo consume posiciones.

(b) `de_camino` SALTA ids que no resuelven contra la red (no revienta). La red es la
   fuente de verdad; un id desconocido simplemente no produce waypoint.

(c) `validar()` como invariante explicito: orden, fraccion/acumulado monotonos,
   primero `fraccion == 0.0`, ultimo `es_destino` con `fraccion == 1.0`. Una ruta
   degenerada de 1 parada queda exenta de las reglas de fraccion 1.0 (no hay tramo).

(d) GATE DE CONTEXTO. `buy_ticket()` consulta `contexto_de_viaje()` justo despues de
   `_viaje_activo`. SOLO el dialogo bloquea. El inventario lleno se REPORTA
   (`inventario_lleno`) pero NO bloquea: viajar no requiere espacio libre (el
   equipaje se resuelve al llegar). Divergencia DECLARADA, no silenciada.

(e) DUCK-TYPING. `_en_dialogo()` lee `/root/DialogueManager.is_dialogue_active` y
   `_inventario_lleno()` lee `/root/Inventario.has_free_space(0)` por duck-typing: si
   el modulo no esta o no expone el metodo, el gate degrada a "no bloqueado" (nunca
   crashea). En headless M21 esta presente pero inactivo -> no bloquea.

(f) "sin senal" (cartel M46) es EXTERNO: la suite lo declara como nota y no lo
   finge. El resto del item T (desbloqueo + clima) si se verifica.

## 4. Prueba (verde)

Comando:

```
C:/Temp/godot/godot472.exe --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68_iter3.gd
```

Resultado (x3, identico):

```
=== Resumen M68 iter.3: 108 checks, 0 fallos ===
TEST M68 iter.3 OK -- todos los checks pasaron
EXIT 0
```

`CHECKS_MINIMOS := 108` MEDIDO en verde (no estimado, no copiado). 8 bloques:

1. A. Waypoints de camino (de_camino: orden, indices, fraccion 0.0->1.0, distancias).
2. B. Waypoints de plan (de_plan + validar + es_larga + avance/indice mas cercano).
3. C. Manager: waypoints_de_ruta / es_ruta_larga reales + coherencia con planificar.
4. D. Contexto de viaje (dialogo M21 bloquea; inventario lleno reportado, no bloquea).
5. E. Edge: dinero justo (saldo exacto compra y queda en 0; un AO menos no cobra).
6. F. Edge: ultima hora (21:00 abierta / 22:00 cerrada / 06:00 abierta / 05:00 cerrada).
7. G. Edge: parada recien desbloqueada (M71) + ruta solo-verano + clima (M32).
8. H. Integridad (10 paradas, 20 rutas, validar(), compra normal, persistencia).

Sin regresion:

```
test_transporte_m68.gd       EXIT 0 -> 177 checks / 0 fallos
test_transporte_m68_iter2.gd EXIT 0 -> 199 checks / 0 fallos
```

`SCRIPT ERROR`: 0. Advertencias: 12 de M39 (Tienda, preexistentes: item_ids de M15)
+ 1 `ObjectDB instances were leaked at exit` (artefacto de salida headless comun a
las suites); identicas en iter. 2 -> la iter. 3 NO introduce advertencias nuevas.

## 5. Prueba en ROJO (guardia anti-falso-verde)

Mutando el archivo REAL, exigiendo EXIT 1 y restaurando byte-exacto:

```
CONTROL (sin mutar)                 -> EXIT 0
SONDA A (modelo: es_destino=false)  -> EXIT 1  (3 FAILs) restaurado=True
SONDA B (aborto bloque C)           -> EXIT 1  (nombra C=True) restaurado=True
SONDA C (CHECKS_MINIMOS=999)        -> EXIT 1  (piso=True) restaurado=True
SONDA D (sin _fin del bloque H)     -> EXIT 1  (nombra H=True) restaurado=True
RESULTADO: TODAS LAS SONDAS OK
```

4/4 sondas en ROJO limpio. Las 3 capas de la guardia (cierre de bloque `_fin`,
piso `CHECKS_MINIMOS` medido, `_summary()` en `call_deferred` separado + watchdog)
se encienden. Restauracion verificada byte-exacta (anclas intactas, 0 residuos).

Leccion de la sonda: un archivo `class_name ... extends RefCounted` NO se puede
correr con `--script` (nunca llama a `quit()` -> cuelga). Para probar el modelo hay
que correr la SUITE que lo usa. (La primera version de la sonda corria el modelo y
murio por timeout de 180 s; se corrigio.)

## 6. Gate de CI (NO aplicado)

El job `test-suite` de `.github/workflows/quality.yml` ya cablea iter. 1 (linea 241)
e iter. 2 (linea 249) con `|| FAIL=1`. Falta la linea de iter. 3:

```
godot --headless --script scripts/transporte/test_transporte_m68_iter3.gd 2>&1 || FAIL=1
```

NO se aplico: el director (mensaje 07, seccion "Hallazgo (1) del CI") indico
explicitamente no tocar `quality.yml` porque s2 lo esta editando por BUG-091 modo A
(evitar edicion concurrente, cf. el conflicto de M70). La linea queda propuesta y
reportada para que s2 la aplique junto con la suya en una sola edicion.

Relacionado: BUG-091 modo B (hallazgo de M17 iter. 3) -- el job `test-suite` carece
del paso `--import` que SI tiene `godot-lint`; en checkout limpio las suites con
`class_name` mueren por PARSEO antes de sus aserciones. Documentado, no parcheado
(mismo motivo).

## 7. Checklist

`05-Checklist.md`: encabezado stale corregido (decia 36/131 / 10 [?] / 85 [ ]; el
real era 70/47/14, fijado por la auditoria de drift de atria del 2026-09-20).
Marcas 70 -> **75 [x]** (+5):

- J. Waypoints automaticos en rutas largas.
- J. Testear waypoints con rutas de 2+ paradas.
- T. Viajar con dinero justo o en la ultima hora de horario.
- T. Viajar durante dialogo (M21) o con inventario lleno (divergencia declarada).
- T. Parada recien desbloqueada sin senal y clima cambiadizo (M32) -- "sin senal"
  externo declarado.

Totales: **75 [x] / 42 [ ] / 14 [?] = 131** (conteo por prefijo de linea).

## 8. Trampa de tooling (medida)

CACHE DE CLASES GLOBALES. Un `class_name` nuevo NO se resuelve en headless hasta que
Godot regenera `.godot/global_script_class_cache.cfg`. Con la cache PRESENTE pero
STALE, `--script` NO la regenera (medido: la suite moria por parseo). Se regenera con
`godot --headless --path <proj> --import`. Leccion: tras crear un `class_name`,
correr `--import` antes de medir la suite. Registrado en el skill
`isla-ancestral-ciclo-modulo` (seccion G) y pedido por el director para la guia
`DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (cuando se toque esa guia).

## 9. Hallazgos AJENOS (reportados, NO tocados)

(1) `CHECKLIST-GLOBAL.md` tiene una edicion AJENA en vuelo (fila 152, revertida a
    dudas por la auditoria de atria-dawn-s2, 2026-10-04). NO se toco la fila 68 para no
    pisar esa sesion ni arriesgar un conflicto en un archivo binario fragil (1 NUL,
    231 CRLF, bare-CR). Fila 68 pendiente para el coordinador: hoy dice `70/131` ->
    `75/131` (estado En curso iter. 3 + nota).

(2) El worktree tiene ediciones AJENAS en vuelo (NO tocadas): M70
    (`scripts/interacciones/*.gd`, `DOCUMENTACION/70-*/`), `DOCUMENTACION/08-*`,
    `DOCUMENTACION/37-*`, `scripts-prueba-temp-analisis.py`, `diag_fila37.py`,
    `reconstruir_fila37.py`, `reserva_g8_ep.py`, `scripts/add_terms_autoload.py`,
    `Obsoletos/CHECKLIST-GLOBAL-backup-*`, y logs untracked (1179, 1185, 1195).

(3) `Mensajes entre modelos/06-M70-Conflicto-Edicion-Concurrente/` (atria) sigue
    presente: aviso de edicion concurrente de M70. Contexto, no accion.

## 10. Estado

M68 iter. 3 ENTREGADA. **NO sella seccion 21.8** (autor != verificador): queda para
QA cruzado. Deuda propia restante: cablear la suite en `quality.yml` (diferida por
indicacion del director). Fuera del alcance headless (dueno externo): puertos
M17/M40, mapa M54, senalizacion M46, panel M53, animaciones M48/M64, rendimiento
M61, accesibilidad M58, vehiculos M67.

## 4.3 Huella de push (AGENTS.md 4.3)

- Rango: (a completar tras el push)
- Hora: 2026-10-04 03:21 (UTC).
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy).
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- Contenido: (a completar)
