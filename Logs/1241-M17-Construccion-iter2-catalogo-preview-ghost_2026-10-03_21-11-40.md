# Log 1241 - M17 Construccion iter. 2

- Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
- Fecha: 2026-10-03 21:11:40
- Modulo: M17 Construccion
- Iteracion: 2 (catalogo de 12 familias + preview/ghost + integracion M18/M64)
- Entrada: iter. 1 aprobada por el coordinador (Log 1211)
- Reserva: log 1241 (pool NUMEROS_DISPONIBLES.txt, protocolo v3)

## 1. Alcance

Se implementa lo autorizado por el coordinador (encargo M17 iter. 2):

- Catalogo data-driven de 12 FAMILIAS (RF12 / bloque J): 33 recetas .tres.
- `BuildCatalogDB`: indexado por id y por familia, vistas por modo, auditoria.
- `PlacementRule.familia` (round-trip dict).
- `BuildPreview`: evaluacion para el fantasma, cache por celda/rotacion/receta.
- `BuildGhost`: malla semi-transparente, color, rotacion, LOD y pooling.
- Integracion M64: senal `navmesh_delta` al colocar/demoler/undo.
- Integracion M18: catalogo filtrado por modo (interiores = decoracion).

## 2. Archivos

Nuevos:

- `game/isla-ancestral/scripts/construccion/build_catalog_db.gd`
- `game/isla-ancestral/scripts/construccion/build_preview.gd`
- `game/isla-ancestral/scripts/construccion/build_ghost.gd`
- `game/isla-ancestral/scripts/construccion/test_construccion_iter2.gd`
- `game/isla-ancestral/data/construccion/piezas/*.tres` (33 recetas, 12 familias)

Modificados:

- `game/isla-ancestral/scripts/construccion/placement_rule.gd` (+`familia`)
- `game/isla-ancestral/scripts/construccion/build_manager.gd` (+`catalogo_db`, +`preview`, +`navmesh_delta`)
- `game/isla-ancestral/scripts/construccion/test_construccion.gd` (2 aserciones: 3 -> 33 piezas; `madera` -> `planks`)
- `game/isla-ancestral/data/construccion/piezas/pared_madera.tres`, `piso_tablones.tres` (id de item invalido)
- `.github/workflows/quality.yml` (gate de la suite iter. 2)

## 3. Hallazgos propios (corregidos)

(a) ID DE ITEM INVALIDO EN iter. 1. `pared_madera.tres` y `piso_tablones.tres` declaraban
costo `{"madera": N}`, pero `madera` NO existe en `data/items/` (M14); el id real es
`planks`. El catalogo iter. 2 los regenera con ids REALES. El bug estaba oculto porque la
suite iter. 1 no cruzaba los item_id contra `data/items/`; la suite iter. 2 si lo hace
(bloque 3: "todo item_id del costo existe en data/items/").

(b) RECETA DE TECHO INCONSTRUIBLE. `techo_losa.tres` y `techo_paja.tres` declaraban
`soportes_minimos = 2` con huella 1x1. La huella 1x1 aporta a lo sumo 1 soporte
(`contar_soportes` itera las celdas de la base) -> un techo NUNCA podia validar, lo que
contradice `03-Diseno` seccion 5.3 ("techos exigen 2+ soportes"). Corregido: techo -> 2x2.
Regresion cubierta por el bloque 8 de la suite.

(c) TRAMPA DE EOL EN PYTHON. `Path.write_text()` en Windows traduce LF -> CRLF. La edicion de
`05-Checklist.md` quedo con CR=263 / LF=263; se normalizo a LF (CR=0). Leccion: escribir
BYTES, no texto, cuando el EOL importa (el repo usa autocrlf=true y mide `git ls-files --eol`).

## 4. Prueba (verde)

Comando:

```
C:/Temp/godot/godot472.exe --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter2.gd
```

Resultado:

```
=== RESUMEN M17 CONSTRUCCION iter.2: 99 checks, 0 fallos, 9 bloques cerrados ===
RESULTADO: OK
EXIT 0
```

`CHECKS_MINIMOS = 99` MEDIDO en verde (no estimado, no copiado). Re-ejecutada la suite iter. 1
(no regresion): **131 checks / 0 fallos / EXIT 0**.

Bloques de la suite iter. 2:

1. `BuildCatalogDB` (carga real 33, 12 familias, `por_modo`, `validar`, quitar/limpiar).
2. `PlacementRule.familia` (round-trip dict).
3. Integridad (item ids de M14; agua/techos/pared).
4. Carga recursiva (subcarpetas de familia).
5. `BuildPreview` (color, cache, costo, no cobra ni escribe).
6. `BuildGhost` (perezoso, tamano/rotacion, pooling, LOD).
7. M64 `navmesh_delta` (colocar/demoler/undo).
8. Obra real (piso -> pared -> techo 2x2; rechazos SIN_SOPORTE/puente).
9. M18/M60 (modo decoracion + round-trip de persistencia con huella 2x2).

## 5. Prueba en ROJO (guardia anti-falso-verde)

Mutando el propio runner y restaurando byte-exacto (`bytes restaurados = True`):

```
CONTROL (sin mutar)            -> EXIT 0
PROBE A (asercion rota)        -> EXIT 1  (1 fallo)
PROBE B (aborto runtime b. 9)  -> EXIT 1  (nombra [9] en NO CERRARON + piso 88 < 99)
PROBE C (un check menos)       -> EXIT 1  (98 < 99: capa del piso)
```

Guardia OK: las 3 capas (cierre de bloque, piso medido, resumen en `call_deferred`) se encienden.

## 6. Gate de CI

`.github/workflows/quality.yml` (job `test-suite`): se agrega

```
godot --headless --script scripts/construccion/test_construccion_iter2.gd 2>&1 || FAIL=1
```

con el comentario del modulo. EOL CRLF preservado (CR = LF = 865). El YAML valida con PyYAML.
`validar_workflows.py` dara rojo hasta que la suite este en HEAD (trampa 98) -> se limpia al commitear.

## 7. Checklist

`05-Checklist.md`: 23 -> **45 [x]** (+22 respaldados por el catalogo de 12 familias,
preview/ghost y M64). Totales **45 / 130 / 175**. Fila 17 de `CHECKLIST-GLOBAL.md` editada
byte-exacta (`45/175` + nota iter. 2) **SIN commitear** (la commitea el coordinador;
invariantes CR=449, LF=231, bareCR=218, NUL=1 preservados). `verificar_checklist.py`: M17
consistente; quedan 2 alertas AJENAS (M06 Control-De-Versiones).

## 8. Hallazgos AJENOS

(1) **godot-lint / `_colector_sintaxis.gd`**: 109 errores en 44 archivos VERSIONADOS.
Clasificacion: **73 REALES en 27 archivos** + 36 artefactos de contexto (`Identifier not
found:` de un autoload o `class_name` fuera del alcance del colector). El colector SALE 0 con
esos 109 -> el gate `godot-lint` es CIEGO a los 73 reales (solo falla si el propio colector no
compila). La lista exacta (archivo + linea + error) va en el informe de la carpeta de mensajes
(`04-...`). Colector restaurado byte-exacto.

(2) El worktree tiene ediciones AJENAS en vuelo (NO tocadas): M70 (`scripts/interacciones/*.gd`,
`DOCUMENTACION/70-*/`), `DOCUMENTACION/08-*`, `DOCUMENTACION/37-*`.

## 9. Estado

M17 iter. 2 ENTREGADA. **NO sella seccion 21.8** (autor != verificador): queda para QA cruzado.
Deuda para iter. 3: HUD del modo (costo/motivos en pantalla), mesh REAL de la receta en el
fantasma, follow con lerp, permisos de zona finos (M18/M25), stress M112.

## 4.3 Huella de push (AGENTS.md 4.3)

PENDIENTE: se completa tras el push.
