# Log 1244 - M17 Construccion iter. 3

- Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
- Fecha: 2026-10-04 02:26
- Modulo: M17 Construccion
- Iteracion: 3 (HUD del modo + mesh real + follow lerp + auto-ocultado + permisos M18/M25 + stress M112)
- Entrada: iter. 2 APROBADA por el coordinador (mensaje 05-2026-10-04_00-45-00); iter. 3 AUTORIZADA
- Reserva: log 1244 (pool NUMEROS_DISPONIBLES.txt, protocolo v3)

## 1. Alcance

Se implementa lo autorizado por el coordinador (encargo M17 iter. 3):

- HUD del modo: modelo PURO de costo y motivos de rechazo (la capa UI es M18).
- MESH REAL de la receta en el fantasma (con caja de respaldo si la ruta no resuelve).
- FOLLOW con lerp (sin sobrepasar el objetivo).
- AUTO-OCULTADO del fantasma fuera de zona / sin terreno.
- Permisos finos M18 (casa del jugador / parcelas NPC) y M25 (ruinas/templos).
- STRESS M112 de 200+ piezas (251) con consistencia de ocupacion y undo/redo masivo.

## 2. Archivos

Nuevos:

- `game/isla-ancestral/scripts/construccion/build_hud.gd` (`class_name BuildHudModel`)
- `game/isla-ancestral/scripts/construccion/zonas_permisos.gd` (`class_name ZonasPermisos`)
- `game/isla-ancestral/scripts/construccion/test_construccion_iter3.gd`

Modificados:

- `game/isla-ancestral/scripts/construccion/placement_rule.gd` (+`mesh_path`)
- `game/isla-ancestral/scripts/construccion/build_ghost.gd` (+malla real, +follow, +auto-ocultado)
- `game/isla-ancestral/data/construccion/piezas/*.tres` (30 recetas con `mesh_path`)
- `.github/workflows/quality.yml` (gate de la suite iter. 3)
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` (nota iter. 3)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (45 -> 59 [x])
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`
- `CHECKLIST-GLOBAL.md` (fila 17, byte-exacta, SIN commitear: la commitea el coordinador)

## 3. Decisiones de diseno

(a) HUD = MODELO PURO. `BuildHudModel` no conoce nodos ni temas: convierte el resultado
de `BuildPreview` + la receta en filas (`{item_id, nombre, cantidad, texto}` y
`{motivo, texto}`) y una linea de estado. La UI de M18 solo DIBUJA. Asi el HUD se
testea headless y no se acopla logica de colocacion a los scripts de UI (03-Diseno s2).

(b) MESH REAL POR DATO. `PlacementRule.mesh_path` (String) en vez de `@export var mesh:
PackedScene` del diseno: una ruta res:// es serializable, viaja en el round-trip
`desde_dict`/`a_dict` y NO obliga a cargar la malla al parsear la receta. El fantasma
la resuelve con `malla_desde_ruta()` (cache ruta -> Mesh), acepta un `Mesh` directo o
un `PackedScene` (.glb) del que toma la primera `MeshInstance3D`, y si la ruta esta
vacia o rota cae a la CAJA de respaldo (`usando_malla_real()` lo reporta). 30 de las 33
recetas apuntan a `assets/3d/alta/` (las 3 sin asset: cerca_madera, cerca_piedra,
camino_arena).

(c) FOLLOW ACOTADO. `seguir()` usa `position.lerp(objetivo, clampf(vel*delta, 0, 1))`:
el factor NUNCA supera 1, de modo que el fantasma no sobrepasa el objetivo (un lerp sin
clamp oscila). `destino_de()` centraliza la huella (con rotacion) para que el objetivo
coincida con `aplicar_resultado()`.

(d) AUTO-OCULTADO. `debe_ocultarse(res)` es true si el rechazo es de ZONA
(FUERA_DE_ZONA / ZONA_PROTEGIDA / ZONA_NARRATIVA / AGUA_NO_PERMITIDA): no tiene sentido
pintar una caja roja fuera de la zona edificable. Un rechazo de soporte o de recursos
deja el fantasma VISIBLE en rojo. `actualizar_visibilidad(res, terreno_cargado)` oculta
tambien cuando no hay terreno.

(e) PERMISOS M18/M25. `ZoneRegistry` es el MECANISMO (iter. 1); `ZonasPermisos` es la
POLITICA: presets (casa del jugador -> EDIFICABLE; parcela NPC y ruina M25 ->
PROTEGIDA; narrativa; agua), registro data-driven por `origen` con DEFAULT SEGURO
(origen desconocido -> PROTEGIDA, para no construir por accidente en una parcela
desconocida) y traduccion permiso -> motivo para el HUD.

(f) STRESS = M112 (Testing Automatico). El stress vive en la suite headless (M112), no
en el runner de M113: registrar un escenario alli exigiria editar `stress_runner.gd`
(ajeno). 251 piezas reales: 225 pisos (15x15) + 25 paredes (5x5) + 1 techo 2x2.

## 4. Prueba (verde)

Comando:

```
C:/Temp/godot/godot472.exe --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter3.gd
```

Resultado (x3, identico):

```
=== RESUMEN M17 CONSTRUCCION iter.3: 138 checks, 0 fallos, 9 bloques cerrados ===
RESULTADO: OK
EXIT 0
```

`CHECKS_MINIMOS = 138` MEDIDO en verde (no estimado, no copiado). Bloques:

1. `BuildHudModel` costo (filas ordenadas, nombre legible, gratis, null).
2. `BuildHudModel` motivos (traduccion de 5 motivos, linea de estado, resumen).
3. `PlacementRule.mesh_path` (round-trip; 30 recetas declaran malla; el asset existe).
4. `BuildGhost` malla real (inyectada, resuelta por ruta, fallback a caja, sin colision).
5. `BuildGhost` follow (sin sobrepasar, converge, `destino_de` con rotacion, elevacion).
6. `BuildGhost` auto-ocultado (4 motivos de zona; soporte/recursos siguen visibles).
7. `ZonasPermisos` (presets, registro, motivo, default seguro, `ORDEN[0]=="zona"`).
8. STRESS M112 (251 piezas, 254 celdas ocupadas, undo/redo masivo con tope 200).
9. End-to-end (preview -> HUD -> fantasma; zona protegida oculta el fantasma).

No regresion: suite iter. 1 = **131 checks / 0 fallos / EXIT 0**; iter. 2 = **99 / 0 / EXIT 0**.

## 5. Prueba en ROJO (guardia anti-falso-verde)

Mutando el archivo REAL y restaurando byte-exacto (`restaurado=True` en las 4):

```
CONTROL (sin mutar)                    -> EXIT 0
SONDA A (HUD: otro separador)          -> EXIT 1  (1 fallo)
SONDA B (follow SIN clamp)             -> EXIT 1  (3 fallos)
SONDA C (origen desconocido EDIFICABLE)-> EXIT 1  (1 fallo)
SONDA D (CHECKS_MINIMOS=999)           -> EXIT 1  (piso no cumplido: suite incompleta)
```

4/4 sondas en ROJO limpio. Las 3 capas de la guardia (cierre de bloque `_fin`, piso
medido, `_summary()` en `call_deferred` separado) se encienden.

## 6. Gate de CI

`.github/workflows/quality.yml` (job `test-suite`):

```
godot --headless --script scripts/construccion/test_construccion_iter3.gd 2>&1 || FAIL=1
```

EOL CRLF preservado (CR = LF = 876; +11/+11 por el bloque de comentario). El YAML valida
con PyYAML. `validar_workflows.py` dara rojo hasta que la suite este en HEAD (trampa 98)
-> se limpia al commitear.

## 7. Checklist

`05-Checklist.md`: 45 -> **59 [x]** (+14: mesh de la receta, follow lerp, rotacion y
elevacion en tiempo real, HUD costo+motivos, auto-ocultado, sin colision, 4 permisos de
zona, verificacion de recursos en preview, recursos insuficientes en preview, zona antes
que soporte, stress M112). Totales **59 / 116 / 175** (contador `verificar_checklist.py`
coincide). Fila 17 de `CHECKLIST-GLOBAL.md` editada byte-exacta (`59/175` + nota iter. 3)
**SIN commitear**; invariantes preservados (NUL=1, CRLF=231, LF=231, bareCR=218).

NO se marca "Aviso claro con motivo al intentar colocar fuera de zona (fantasma rojo +
texto)": el diseno de iter. 3 OCULTA el fantasma fuera de zona en vez de pintarlo rojo.
La divergencia queda declarada, no silenciada.

## 8. Trampa de tooling (medida)

CACHE DE CLASES GLOBALES. Un `class_name` nuevo NO se resuelve en headless hasta que
Godot regenera `.godot/global_script_class_cache.cfg`. Sintoma: `Parse Error: Identifier
"BuildHudModel" not declared in the current scope` en la suite, aunque el archivo exista
y parsee bien. Con la cache PRESENTE pero STALE, `--script` NO la regenera (medido: se
movio la cache y la suite salio EXIT 1; la cache no se recreo). Se regenera con
`godot --headless --path <proj> --import`. Leccion: tras crear un `class_name`, correr
`--import` antes de medir la suite.

## 9. Hallazgos AJENOS (reportados, NO parcheados)

(1) **El job `test-suite` de CI carece del paso de importacion que SI tiene
`godot-lint`.** En un checkout limpio (sin `.godot`) la cache de class_names no existe y
las suites que usan `class_name` entre archivos fallan por PARSEO antes de sus
aserciones. Medido en el run 37165093372 (job 111326276212): `Parse Error: Identifier
"SaveSchema"/"SaveBackup"/"SaveWriter"/"SaveLoader" not declared in the current scope`.
`godot-lint` documenta el arreglo ("fresh + import => EXIT 0; fresh sin import => EXIT 1
falso") pero el paso NO se replico en `test-suite`. **Patch propuesto (NO aplicado,
porque cambia la semantica de un job COMPARTIDO que el coordinador esta tocando por
BUG-091):** insertar, antes de "Run validation tests", el mismo paso

```
      - name: Import project resources
        run: godot --headless --path game/isla-ancestral --import
```

Sin esto, TODOS los gates de suites con `class_name` (incluido el de iter. 3) son
decorativos en CI: el job muere por parseo antes de evaluarlos.

(2) **Gates de `quality.yml` citando scripts NO trackeados.** `scripts/build/` tiene
**0 archivos trackeados**, pero la linea 364 cita `scripts/build/test_build_m117.gd`
(con `|| true`, no-op) y la linea 372 cita `scripts/build/test_instalador_m116.gd`
(SIN `|| true` -> falla el job). En el run 37165093372 el job murio con `Can't load
script: scripts/build/test_instalador_m116.gd` (File not found). **Ya esta registrado
como BUG-078** y `validar_workflows.py` lo trata como AVISO de deuda conocida (duenos
M117/M116) -> no es un hallazgo nuevo, solo lo confirmo como causa del rojo del job.

(3) El worktree tiene ediciones AJENAS en vuelo (NO tocadas): M70
(`scripts/interacciones/*.gd`, `DOCUMENTACION/70-*/`), `DOCUMENTACION/08-*`,
`DOCUMENTACION/37-*`, mas varios scratch `.py` y `Obsoletos/` ajenos.

(4) CI globalmente en ROJO en `main` (run 37165093372): ademas de lo anterior fallan
`Legal Tooling Tests`, `GDScript Formatting Check`, `Architecture Guard` y `UTF-8 sin
BOM`. No es de M17; se reporta para contexto.

## 10. Estado

M17 iter. 3 ENTREGADA. **NO sella seccion 21.8** (autor != verificador): queda para QA
cruzado. Deuda restante de M17: UI real del modo (M18), raycast de cursor (requiere
escena), colisiones reales de pieza (M08), luces de farol (M31), VFX/audio de colocacion
(M51/M43), copiar/almacenar, techos con vegetacion, serializacion de zonas (M58),
M73/M71/M93. Nota: el HUD y los permisos M18/M25 quedan listos para que M18 los consuma.

## 4.3 Huella de push (AGENTS.md 4.3)

- Rango: `b8a9724..56d4eff` (1 commit, PROPIO: `56d4eff`).
- Hora: 2026-10-04 02:26 (UTC).
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy).
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- Contenido: 40 archivos, 1353 inserciones, 25 borrados.
- Ajenos arrastrados: 3 commits (ya locales, no mios): `83ebeb0` (GLOBAL M06 + reserva
  M130), `af02710` y `303763b` (M130 Artbook, agnes-3-flash / coordinador). Mi commit es
  el HEAD del rango; los 3 ajenos eran ancestros locales sin pushear.
- Verificacion: `git ls-remote origin refs/heads/main` =
  `56d4eff493e93db99dcae3afa0a3baeb49403fd0` == HEAD local. `validar_workflows.py` EXIT 0
  (trampa 98 limpiada: la suite iter. 3 ya esta en HEAD; queda solo el AVISO de deuda
  conocida BUG-078 de M117/M116).

