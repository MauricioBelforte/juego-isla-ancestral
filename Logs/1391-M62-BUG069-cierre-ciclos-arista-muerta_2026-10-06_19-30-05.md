# Log 1391 - M62 (arquitectura) - BUG-069: ciclos CERRADOS (A1 1 -> 0) y estado medido de A2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Modulo:** M62 (arquitectura de servicios) - BUG-069 (dueno en el registro)
**Fecha:** 2026-10-06 19:30
**Pedido por:** Atria-Dawn-Preview (director), canal 58 (2026-10-06 18:23), seccion 5

## 1. Encargo (canal 58, seccion 5)

"cerrar la arista A2 restante de BUG-069 (referencias a autoload posterior)". Metodo pedido:
sonda roja probada por inyeccion + regresion de las suites de M59/M14/M62. Si la arista ya no
existe: medir, reportar y actualizar la fila (autorizado en la seccion 3 del mismo mensaje).

## 2. Baseline medido ANTES (auditor `scripts/auditar_arquitectura_m62.py`)

```
autoloads declarados ....... 114
aristas explicitas ......... 229
A1 componentes con ciclo ... 1   {ThemeService, UIManager}
A2 refs fuera de orden ..... 10  (las 10 en allowlist)
Grupo B .................... 0
Grupo C .................... 0
Hallazgos NUEVOS ........... 0
EXIT 0
```

## 3. Lo que encontre midiendo: la deuda A2 NO es una arista suelta

Las 10 A2 son **dependencias VIVAS**. Verifique el guard de cada una contra su destino (la
senal/metodo que la arista usa debe EXISTIR en el proyecto):

| A2 | archivo:linea | guard | destino existe? |
|---|---|---|---|
| UIManager -> AccesibilityManager | ui_manager.gd:473 | has_signal("pausa_instantanea_activada") | SI (accesibilidad_manager.gd:18) |
| UIManager -> Localization | ui_manager.gd:511 | has_signal("locale_changed") | SI (localization_manager.gd:13) |
| UIManager -> ControlInput | ui_manager.gd:54 (DIRECTO en _ready) | has_signal("dispositivo_cambiado") | SI (control_input.gd:16) |
| Localization -> DataStore | localization_manager.gd:69,368 | has_method("cargar_config") | SI (data_store.gd:411) |
| Friendship -> VillagerManager | friendship_service.gd:178,226 | has_signal("poblacion_cambio") | SI (villager_manager.gd:17) |
| Friendship -> GameTime | friendship_service.gd:161 | fallback de _calendario() | SI |
| WorldState -> SaveManager | world_state_service.gd:118 | has_method("register_provider") | SI (save_manager.gd:179) |
| TimeCalendar -> GameTime | time_calendar.gd:55 | conexion directa de senales | SI |
| ShopManager -> GameTime | shop_manager.gd:60,76,83,202,288 | has_signal("hora_cambio") | SI |
| AudioConfig -> DataStore | audio_config_service.gd:79,267 | has_method("cargar_config") | SI |

=> **Ninguna es codigo muerto.** Cerrarlas es **invertir dependencias reales** (EventBus /
descubrimiento) en >=8 modulos ajenos (M19, M20, M29, M30, M41-44, M53, M57, M58, M60, M87).
La unica de **familia save** es `WorldState (#2) -> SaveManager (#9)`: invertirla exige que
`SaveManager` DESCUBRA a los proveedores en vez de que ~40 servicios se registren empujandose
(el patron real medido: `_registrar_proveedor_guardado()` en audio, clima, crafting, datos,
dialogos, diario, dlc, economia, ...) -> cambio de comportamiento de M59, no una arista suelta.
**NO se toco.** El encargo era una arista, no un refactor de 8 modulos.

## 4. Lo que SI se podia cerrar: el ciclo restante, y su arista era MUERTA

El ultimo SCC `{ThemeService, UIManager}` se sostenia con 2 aristas:

- `ThemeService -> UIManager` (theme_service.gd:64-66): `ui_mgr.viewport_resized.emit()` bajo
  `has_signal("viewport_resized")`. **Esa senal NO existe**: `grep -rn viewport_resized` en
  TODO el repo devuelve **solo esas 2 lineas** -> `has_signal()` siempre false -> el bloque
  NUNCA corre. **Mismo patron que BUG-116** (arista viva en el grafo, muerta en runtime).
- `UIManager -> ThemeService` (ui_manager.gd:460-462): llama `aplicar_tema_global()`, que
  EXISTE (theme_service.gd:30) -> arista VIVA.

Corte minimo medido con el **Tarjan del propio auditor** (sonda que importa
`analizar_servicios`/`componentes_ciclicas`, sin duplicar logica):

| corte | SCCs resultantes |
|---|---|
| ThemeService -> UIManager (la MUERTA) | 0 |
| UIManager -> ThemeService (la VIVA) | 0 |
| ninguna | 1 |

Se corto LA MUERTA: cierra el ciclo Y elimina codigo muerto, sin romper una dependencia real.

## 5. Cambio (1 archivo de produccion, +4/-4)

`game/isla-ancestral/scripts/ui/theme/theme_service.gd`: se removio el bloque muerto y se dejo
una nota que cita lo que decia (para que nadie lo re-introduzca). El archivo es **LF puro**
(`git ls-files --eol` = `w/lf`, `eol=lf`): editado a nivel de BYTES; invariantes verificados
(bom=False, crlf=0, cr=0, nul=0, fffd=0, LF 66 -> 66). `--check-only` sobre el archivo: EXIT 0.

**Nota de alcance:** la notificacion a capas que se pretendia (`viewport_resized`) NUNCA
existio; no se "arreglo" una feature inexistente, se removio su referencia muerta.

## 6. Auditor DESPUES

```
autoloads declarados ....... 114
aristas explicitas ......... 228   (-1)
A1 componentes con ciclo ... 0     (era 1)
A2 refs fuera de orden ..... 10    (sin cambio)
Grupo B .................... 0
Grupo C .................... 0
Hallazgos NUEVOS ........... 0
EXIT 0
Aviso: 1 entrada de PERMITIDOS ya no se observa: A1|ThemeService,UIManager
```

`--selftest` del auditor: **0 fallos**.

## 7. Sonda ROJA por inyeccion (0 -> 1 -> 0)

Reinyecte el bloque muerto y exigi que el auditor volviera a ver el ciclo:

```
A1 sin inyeccion (debe ser 0): 0
A1 CON inyeccion (debe ser 1): 1
  -> rojo OK: el auditor nombra 'ThemeService, UIManager'
restaurado: sha 0f59ec83ab90 == inicial
A1 tras restaurar (debe ser 0): 0
SONDA ROJA OK: 0 -> 1 -> 0, restauracion byte-exacta verificada
```

## 8. Regresion (todas EXIT 0, 0 SCRIPT ERROR)

| suite | resultado |
|---|---|
| M62 test_m62_liberacion.gd | 15 checks, 0 fallos |
| M62 test_m62_leaks_teleport.gd | 21 checks, 0 fallos |
| M62 test_m62_pureza_save.gd | 59 checks, 0 fallos |
| M59 validate_save.gd | 16 checks, 0 fallos |
| M59 test_rotate_m59.gd | 43 checks, 0 fallos |
| M59 test_slots_m59.gd | 22 checks, 0 fallos |
| M59 test_fishing_save_block.gd | 11 checks, 0 fallos |
| M59 test_autosave_m59.gd | 0 fallos (sin contador de checks) |
| M14 test_inventario.gd | 0 fallos (sin contador de checks) |
| M14 test_inventario_restore_robusto.gd | 12 checks, 0 fallos |
| M53 test_ui_i18n_m53.gd | 0 fallos (sin contador de checks) |

**Observacion (ajena, no tocada):** 3 suites imprimen "0 fallo(s)" SIN contador de checks
(M59 autosave, M14 inventario, M53 i18n). Es el patron de la trampa 85 (una suite que aborta en
silencio tambien dice "0 fallos"). Quedan para su dueno.

## 9. Registro

`DOCUMENTACION/11-BUGS.md`: fila BUG-069 actualizada a `[->] Parcial` (ciclos CERRADOS; A2
abierta con el motivo medido) + subseccion "Cierre parcial de BUG-069" con la tabla de aristas,
el corte minimo, la medicion antes/despues y la sonda roja. **Commit separado**, autorizado por
el director (canal 58 seccion 3). **NO se commiteo la fila BUG-078** que el director tiene sin
commitear en el worktree: se uso la tecnica de bytes (blob = `HEAD` + solo mi parte) para no
arrastrar trabajo ajeno (trampa 87).

## 10. Pendientes / para el director

1. **A2 = 10 sigue ABIERTA** (10 dependencias vivas, todas en allowlist). Cerrarla = inversion
   de dependencias en >=8 modulos. Se autoriza como frente propio? Sugerencia: empezar por
   `WorldState -> SaveManager` (familia save, con regresion M59/M14/M62).
2. **Allowlist obsoleta:** `A1|ThemeService,UIManager` en `PERMITIDOS` ya no se observa. La
   borra s2 (dueno del Guard). Dejarla **enmascara la reaparicion** del ciclo.
3. **Push:** mis commits locales siguen sin empujar (pido autorizacion expresa).

## 11. Numeracion

- Log: **1391** (head justo antes 1391; tras reservar, 1392). Pool v3, sin archivo de reserva.
- Reporte al director: **59** (mi carpeta).
- `--estado` final: 1 conflicto AJENO (colision 1290, ya conocida) -> reportado, NO tocado.
- **NO commiteo el pool.**
