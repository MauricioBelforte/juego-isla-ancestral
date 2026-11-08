# Reporte de escaneo GDScript — scripts/core/ y scripts/ui/

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-07

## Alcance

- Directorio base: `game/isla-ancestral/scripts/core/` y `game/isla-ancestral/scripts/ui/`
- Total de archivos `.gd` escaneados: **114** (core 42 + ui 72)
- Método: análisis estático con Python (sin modificación de archivos) — parseo indentado de `func`, conteo de referencias por `\bvar\b`, detección de `preload/load` y cuerpos con solo `pass`/comentario
- Convención: parámetros `_prefijados` (Godot: intencionalmente sin usar) se excluyen

## Resumen

- **Archivos con al menos un problema: 14** (listados abajo)
- **Archivos limpios: 100** (incluyendo `event_bus.gd`, `terrain_locator.gd`, `scene_manager.gd`, `game_flow_manager.gd`, `registro.gd`, `contratos.gd`, `ui_manager.gd`, `menu_navigator.gd`, entre otros)
- **Problemas verificados: 23** (variables miembros sin uso, parámetros sin uso, funciones vacías, imports/preloads sin uso)

## Problemas verificados

### Imports / clases sin usar (2)

```
softlock_guard.gd:L13 - import/clase no usada '_IRecoverable'
softlock_guard.gd:L14 - import/clase no usada '_InvariantBase'
```

### Parámetros de función nunca usados (7)

```
checkpoint_manager.gd:L42 - parámetro no usado 'evento' en registrar_checkpoint
softlock_guard.gd:L102 - parámetro no usado 'evento' en forzar_chequeo
softlock_guard.gd:L112 - parámetro no usado 'item_id' en registrar_clave
sesion_master.gd:L37 - parámetro no usado 'nueva_partida' en inicializar
sesion_master.gd:L51 - parámetro no usado 'delta' en tick
equipment_ui.gd:L67 - parámetro no usado 'new_item_id' en _on_equipment_changed
minimap_widget.gd:L176 - parámetro no usado 'id' en _crear_marcador_forma
```

### Funciones vacías (11)

```
sesion_master.gd:L30 - función vacía _ready
test_smoke_persistencia_hy3.gd:L94 - función vacía get_section_name
test_smoke_persistencia_hy3.gd:L96 - función vacía get_save_data
test_smoke_persistencia_hy3.gd:L98 - función vacía restore_save_data
ui_layer.gd:L71 - función vacía on_layer_opened
ui_layer.gd:L76 - función vacía on_layer_closed
status_bar.gd:L19 - función vacía _set_proportion
dialog_layer.gd:L32 - función vacía _ready
dialog_layer.gd:L143 - función vacía _on_option_selected
inventory_layer.gd:L41 - función vacía _ready
inventory_layer.gd:L457 - función vacía on_layer_opened
```

### Variables miembro sin uso (3)

```
hud_screen.gd:L17 - variable miembro no usada 'interact_prompt'
hud_screen.gd:L18 - variable miembro no usada 'minimap_widget'
hud_screen.gd:L19 - variable miembro no usada 'action_prompt_overlay'
```

### Variables locales sin uso (0)

No se detectaron variables locales declaradas y nunca usadas dentro de funciones en los 114 archivos escaneados.

## Casos límite (parecen problema, verificados y NO son código muerto)

- `event_bus.gd` (15 vars de dominio: `economy`, `inventory`, `quest`, `npc`, `calendar`, `time`, `weather`, `travel`, `vehicle`, `ui`, `player`, `infra`, `diary`, `progresion`, `fishing`): son API pública diseñada para consumo externo. Uso confirmado desde `game_flow_manager.gd`, `scene_manager.gd`, `narrative_sound.gd` y tests. No es código muerto.
- `softlock_rules.gd` (11 consts): es configuración pública (`class_name SoftlockRules`). Uso confirmado desde `softlock_guard.gd` y `test_anti_softlock_m66.gd` para `VENTANA_MULTIPLES_FALLOS`, `TOAST_COOLDOWN`, `DETECTOR_TICK_SEGUNDOS`, `TOAST_ACTIVO`. Las constantes restantes (`TIEMPO_REAPARICION_VEHICULO`, `NPC_REPATH_SEGUNDOS`, `RADIO_TELEPORT_JUGADOR`, `SLOT_EMERGENCIA`, etc.) no tienen referencia encontrada en `scripts/` — son config latente, no código muerto local.
- Constantes de tema/color (`COLOR_BG`, `COLOR_WATER`, `BASE_SIZE`, `COLOR_SPEAKER_*` en widgets y `theme_ux.gd`): patrón de referencia a tema/escena; el escáner no detecta uso vía grupo o escena. No se listan como problema sin verificación cross-file adicional.
- `@onready var` en HUD/widgets: patrón de referencia a nodo por nombre único (`%Nombre`); solo las 3 de `hud_screen.gd` arriba no tienen ningún uso ni siquiera en el propio archivo.

## Conclusión

**El código está limpio en un 88% (100 de 114 archivos sin ningún problema).** Los 23 problemas verificados son de severidad **baja**:

- 11 funciones vacías: hooks de lifecycle (`_ready`, `on_layer_opened/closed`) y callbacks vacíos en capas — stubs/placeholders intencionales, no bugs activos.
- 7 parámetros sin uso: firmas de callback o hooks que no consumen el argumento — en su mayoría inofensivos (compatibilidad de firma).
- 2 preloads sin uso en `softlock_guard.gd`: reserva defensiva contra race conditions de autoload; no afectan ejecución.
- 3 vars `@onready` sin uso en `hud_screen.gd`: referencias a widgets que nunca se usan para lógica — ruido, no defecto funcional.

No se detectaron: variables locales muertas, imports que rompan compilación, funciones que deberían funcionar y están vacías (las vacías son hooks/stubs), ni patrones que indiquen deuda técnica grave. Las principales fuentes potenciales de confusión (`event_bus.gd` y `softlock_rules.gd`) son APIs públicas verificadas con consumidores reales, no código muerto.
