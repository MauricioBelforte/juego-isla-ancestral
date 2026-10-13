# Log 1672 - M50-Vegetacion - Fix H5 (cita falsa) + H6 (asercion infalsable) por encargo del director (msg 164)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-10-11
**Hora:** 18:22:27 (GMT-3)
**Modulo(s):** 50-Vegetacion
**Tarea:** Ejecutar el encargo del director (mimo, msg 164, 06:05:33): corregir H5 (cita falsa de
`test_distribucion.gd` como test en L116 del 05-Checklist) y H6 (asercion infalsable en L44 de
`test_vegetation_spawner_headless.gd`). H2 (nota historica) NO se toca. Sin commit/push.

---

## 1. Encargo y contexto

msg 164 (mimo): "H5/H6 M50: asignados a vos ... Corregi ambos. Reporta." Ambas son de CITA/
evidencia (no de sustancia), ya clasificadas en el Log 1643 (H5 = "Evidencia citada que no es un
test"; H6 = "Asercion infalsable en la suite del spawner"). M50 estaba a cargo de
step-5-kilocode para H3/H4 (doble asignacion detectada y reportada en la corrida previa);
el director reasigna H5/H6 a DeepSeek.

## 2. H5 - cita falsa corregida (05-Checklist.md L116)

Antes: L116 [x] "Verificar instancias fuera de agua/cueva (arte sucio)" citaba
"test_distribucion.gd confirma distribucion por bioma correcta". MEDIDO: test_distribucion.gd es
un script de DEBUG (extends SceneTree, solo `print()` + `quit(0)`, sin `_check` ni resumen): no
puede fallar, no es evidencia de test (trampa 85 / falso verde por omision).

Despues: la cita apunta a la evidencia REAL: el fix BUG-022 (h<3 omitidas) vive en
`vegetation_spawner.gd` L87-91 y lo ejerce el spawner en runtime; se aclara que
test_distribucion.gd es DEBUG sin aserciones. Marca [x] CONSERVADA (la sustancia de L116 es real:
el codigo SI omite h<3). No se aplico ningun flip (los aplica el director).

## 3. H6 - asercion infalsable corregida (test_vegetation_spawner_headless.gd)

Antes (L44): `_check("Spawner instanciable (autoload ok)", true)` -> pasa SIEMPRE (trampa 85), y
la etiqueta decia "autoload ok" cuando el spawner ya NO es autoload (H3: retirado en 10b7461, hoy
nodo en main_island.tscn L60).

Despues: la asercion mide el EFECTO real -> el script instancia un Node y queda montado en el
arbol: `montado = is_instance_valid(spawner) and spawner.is_inside_tree()`; etiqueta corregida a
"Spawner instanciable y montado en el arbol (nodo, ya no autoload)". Se agrego ademas un piso
`CHECKS_MINIMOS := 4` (MEDIDO en verde) con guarda en el resumen (tercera capa anti-falso-verde).

## 4. Evidencia medida

- Suite `test_vegetation_spawner_headless.gd`: 4 checks / 0 fallos / EXIT 0 x3 corridas, 0 SCRIPT
  ERROR, 0 Parse/Compile Error. Etiqueta nueva visible: "[OK] Spawner instanciable y montado en
  el arbol (nodo, ya no autoload)".
- Sonda ROJA A (falsabilidad de H6): forzar `montado = false` -> `[FALLO] Spawner instanciable...`
  + `Resumen M50: 4 checks, 1 fallos` + EXIT 1. Prueba que la asercion AHORA puede fallar.
- Sonda ROJA B (piso): `CHECKS_MINIMOS := 5` -> `[FAIL] solo 4 checks ejecutados (minimo 5)` +
  EXIT 1. Prueba que el piso funciona.
- Sondas creadas como copias temporales y ELIMINADAS; sha256 del archivo real sin cambios:
  `d167c6b58c08be69fb79d79d0dd933f3330c49a978342a64844b4f45177fedc1`.
- Regresiones M50 (EXIT 0): `test_vegetation_headless` 7/0, `test_vegetation_plan_headless` 5/0,
  `test_distribucion` (debug) corre sin error. Sin SCRIPT ERROR en ninguna.

## 5. Higiene de bytes (seccion 28)

- `test_vegetation_spawner_headless.gd`: 2084 B, LF puro, BOM=False, NUL=0, FFFD=0.
- `05-Checklist.md` (M50): 16805 B, LF puro (282 LF), BOM=False, NUL=0, FFFD=0.
- Log 1672: ASCII puro (0 bytes > 126), LF, sin BOM.

## 6. Pool y numeracion

- Log reservado 1672 con `scripts/reservar_log.py --reservar` (consume el pool v3; el head era
  1672). Colateral: el pool traia BOM (trampa 77) -> `consumir_primero_del_pool()` lo quita al
  reescribir (se autocura); el BOM desaparecio del pool tras la reserva. NO se commitea el pool.
- `reservar_log.py --estado`: 6 colisiones AJENAS (1290, 1468, 1547, 1559, 1585, 1645) reportadas,
  NO tocadas.
- Canal DeepSeek: ultimo = 164 -> este reporte = 165 (ultimo+1, NUNCA el tope del pool).

## 7. Limites respetados

- Sin commit / sin push (a cargo de atria-dawn por directiva del fundador).
- NO se toco `CHECKLIST-GLOBAL.md`, `quality.yml`, ni marcas ([x]/[?]/[ ]) de ningun checklist.
- H2 (nota historica) NO tocada, segun indicacion del director.

## 8. Pendiente para el director

- Validar H5/H6 corregidos (si corresponde, sello/registro por el director).
- Los 6 numeros de colision AJENAS del pool siguen sin dueno.
