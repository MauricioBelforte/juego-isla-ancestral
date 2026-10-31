**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 59: Guardado

## 1. Arquitectura

```
Assets/_Project/Saving/
â”œâ”€â”€ data/
â”‚   â””â”€â”€ save_schema.gd              (esquema del save: campos, versiones, defaults)
â”œâ”€â”€ service/
â”‚   â”œâ”€â”€ save_manager.gd             (autoload: encola peticiones, slots, hitos M07)
│   ├── save_writer.gd              (escritura atómica .tmp+rename, background thread)
│   ├── save_loader.gd              (carga, validación, checksum, migración M60, backup)
│   ├── save_backup.gd              (rotación local slot_N.bak, backups manuales)
│   └── save_snapshot.gd            (recolecta/restaura estado de sistemas vía interfaces)
â”œâ”€â”€ ui/
│   ├── save_menu.gd                (menú de guardado en M53: slots, auto-save, borrar)
â”‚   â””â”€â”€ save_toast.gd               (feedback sutil "Guardado" M44)
â””â”€â”€ validators/
    └── validate_save.gd            (validación: atómico, checksum, migración, perfiles, rendimiento)

Assets/_Project/Services/
â””â”€â”€ (autoloads: SaveManager, GameState M60, EventBus M07)
```

`SaveManager` (autoload) recibe peticiones (manuales M53 o por hitos M07), encola y delega la escritura a `save_writer` en background thread; `save_loader` valida y carga al inicio (con migración M60 y backup si es necesario); `save_backup` mantiene la rotación local; `save_snapshot` recolecta el estado de cada sistema vía interfaces (`ISaveProvider`) y lo restaura en carga. La UI (M53) muestra slots y feedback (M44). El formato y las migraciones los define M60.

## 2. Diagramas de Flujo (texto)

### 2.1 Guardado (automático o manual)

```
evento de hito (M07: DAY_END, MISSION_COMPLETED, EVENT_END) o petición manual (M53)
  â†’ SaveManager.request_save(slot)
    â†’ 1) encolar (si hay guardado en curso, esperar su fin)
    â†’ 2) save_snapshot.collect() â†’ payload compacto (interfaces ISaveProvider)
    â†’ 3) save_writer.write_atomic(): payload â†’ slot_N.tmp â†’ fsync â†’ rename slot_N.save
    â†’ 4) save_backup.rotate(): save anterior â†’ slot_N.bak (conserva 1-2)
    â†’ 5) toast "Guardado" (M44) sin bloquear
    â†’ 6) log SAVE-OK (o SAVE-ERROR con fallback)
```

### 2.2 Carga y validación

```
inicio del juego / selección de slot (M53)
  â†’ save_loader.load(slot):
    â†’ 1) leer slot_N.save + verificar existencia
    â†’ 2) validar checksum (SHA-256 del payload)
    → 3) validar estructura (campos, tipos, rangos — save_schema.gd)
    → 4) si falla → avisar y ofrecer slot_N.bak (recuperación)
    â†’ 5) si schema_version < actual â†’ migrar (M60) con backup previo
    → 6) save_snapshot.restore() → cada sistema restaura vía ISaveProvider
    → 7) log SAVE-LOAD (slot, versión, tiempo de carga)
```

### 2.3 Manejo de falta de espacio

```
save_writer.write_atomic() falla por disco lleno
  â†’ 1) NUNCA tocar slot_N.save (sigue intacto)
  → 2) limpiar slot_N.tmp huérfano
  â†’ 3) aviso claro en UI (M53): "Guardado fallido: sin espacio"
  â†’ 4) log SAVE-DISKFULL
```

## 3. Tablas de Métricas (técnico)

### 3.1 Contenido del save (snapshot por sistema)

| Sistema | Interface ISaveProvider | Contenido | Tamaño típico |
|---|---|---|---|
| Mundo (M09/M10/M54) | `IWorldSave` | islas, POI, exploración | ~20 KB |
| Inventario (M14) | `IInventorySave` | ítems, cantidades, equipo | ~15 KB |
| Construcciones (M17/M18) | `IBuildingSave` | casas, estado | ~10 KB |
| NPC (M19/M21) | `INpcSave` | posición, diálogos, estado | ~15 KB |
| Misiones (M22/M23) | `IQuestSave` | progreso, estado | ~10 KB |
| Relaciones (M20) | `IFriendshipSave` | niveles de amistad | ~5 KB |
| Economía (M38/M39) | `IEconomySave` | dinero, tiendas | ~8 KB |
| Tiempo (M29/M31) | `ITimeSave` | fecha, hora, estación | ~1 KB |
| Eventos (M74) | `IEventSave` | pasados/futuros | ~5 KB |
| Colecciones (M37) | `ICollectionSave` | museo, bestiario | ~5 KB |
| Diario (M55) | `IDiarySave` | entradas, estados | ~10 KB |
| Fotos (M56) | `IPhotoSave` | solo ids de fotos | ~2 KB |
| Configuración (M90/M91) | (slot aparte) | opciones | ~2 KB |

### 3.2 Robustez (reglas duras)

| Caso | Comportamiento |
|---|---|
| Apagado durante escritura | `.tmp` huérfano; `slot_N.save` intacto; `.tmp` se limpia al arrancar |
| Corrupción detectada | Aviso + oferta de `slot_N.bak` |
| Migración | Backup previo + solo hacia delante (M60) |
| Disco lleno | Nunca tocar el save; aviso claro |
| Slots | 3+ perfiles con id de perfil validado |

### 3.3 Rendimiento (contra M61)

- Guardado típico: < 80 ms en background (no bloquea el frame).
- Carga: < 500 ms para saves de sesión larga (validación + migración incluidas).
- Tamaño del save: < 120 KB típico (fotos por referencia).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M60 | Formato, schema_version, migraciones |
| M07 | Eventos de hito para auto-save |
| M40 | Servicios base y bootstrap (carga al iniciar) |
| M53 | Menú de guardado, selección de slots, feedback (M44) |
| M09/M10/M54, M14, M17/M18, M19/M21, M22/M23, M20, M38/M39, M29/M31, M74, M37, M55, M56 | Interfaces ISaveProvider |
| M90/M91 | Slot de configuración separado |
| M107 | Backups 3-2-1 externos (rotación local aquí) |
| M97 | Steam Cloud sync (opcional futuro) |
| M61 | Guardado en background thread |
| M102 | Bug-Tracking de fallos de guardado |
| M108/M118 | Importación y validación en CI |


## Atomicidad y multiplataforma (L4 - specs)

### Guardado atomico
- Escribir en archivo temporal (.tmp) y luego rename atomico al archivo final.
- Si el rename falla (permisos, disco lleno), mantener el archivo anterior intacto.
- Checksum (SHA-256) del archivo final para detectar corrupcion.

### Multiplataforma
- Windows: MoveFileEx con MOVEFILE_REPLACE_EXISTING (atomico en NTFS).
- macOS/Linux: rename() es atomico en POSIX (mismo filesystem).
- Fallback: si rename atomico no disponible, copiar + verificar + borrar original.

### Verificacion
- Probar en Windows/macOS/Linux: rename atomico varia por SO.
- Test de crash durante guardado: archivo anterior debe quedar intacto.
## Guardado manual y slots (P-30 L4-P1/P2)

### Guardado manual
- Trigger: boton en menu principal + atajo de teclado (F5 default).
- Feedback: toast Guardado + timestamp del slot.
- No interrumpe gameplay: ejecuta en background thread (M61).

### Slots
- Minimo 3 slots por perfil de jugador.
- UI de seleccion: lista con nombre, fecha, hora, screenshot thumbnail.
- Cambio de slot en plena sesion: confirmacion + guardado del slot actual antes de cargar.
## Guardado de mundo (P-30 L4-P3/P4)

### Islas, POI, exploracion, niebla (M54)
- Guardar: lista de islas descubiertas, POI visitados, estado de niebla de guerra.
- Formato: array de IDs + coordenadas + timestamp de descubrimiento.

### Ruinas (M25) y templos (M26)
- Guardar: estado de cada ruina/templo (visitado, puzzle resuelto, cofres abiertos).
- Formato: map de id -> estado (enum: no_visitado, visitado, completado).
## Guardado de mundo extendido (P-30 L4-P5/P6/P7/P8)

### Mostrar hora/fecha del ultimo guardado por slot
- UI: timestamp formateado (dd/mm/yyyy HH:MM) en la tarjeta de cada slot.
- Fuente: metadata del archivo de guardado (mtime o campo guardado_en).

### Guardar modificaciones del mundo (tala M50, minado M35)
- Guardar: lista de bloques modificados (posicion + nuevo tipo).
- Formato: array de {pos: [x,y,z], tipo: int, timestamp}.

### Guardar semillas y cultivos en proceso (M33)
- Guardar: estado de cada cultivo (semilla, etapa de crecimiento, agua, fertilizante).
- Formato: map de posicion -> {semilla_id, etapa, agua, fertilizante, timestamp}.

### Guardar trampas y redes de pesca (M34)
- Guardar: estado de cada trampa/red (activa, capturas, tiempo restante).
- Formato: array de {pos, tipo, activa, capturas, tiempo_restante}.
## Guardado de construcciones y decoracion (P-30 L4-P9/P10/P11/P12)

### Guardar casas/edificios
- Guardar: fase de construccion, mejoras aplicadas, materiales usados.
- Formato: map de building_id -> {fase, mejoras[], materiales_usados}.

### Guardar decoracion, muebles y cofres
- Guardar: items colocados (posicion, rotacion, item_id) + contenido de cofres.
- Formato: array de {pos, rot, item_id, cofre_contenido[]}.

### Guardar estado de puertas y ventanas
- Guardar: estado abierto/cerrado/bloqueado por puerta/ventana.
- Formato: map de door_id -> {estado, bloqueada}.
## Guardado extendido (cola total M59 batch)

### Guardar posicion, estado y rutinas de NPC (M64)
- Guardar: posicion, estado actual, rutina diaria, inventario NPC.
- Formato: map de npc_id -> {pos, estado, rutina, inventario}.

### Guardar dialogos vistos y elecciones tomadas
- Guardar: set de dialogos vistos + elecciones tomadas por NPC.
- Formato: map de npc_id -> {dialogos_vistos[], elecciones[]}.

### Guardar amistad (M20) y regalos entregados
- Guardar: nivel de amistad + lista de regalos entregados por NPC.
- Formato: map de npc_id -> {amistad, regalos[]}.

### Guardar encargos activos (M23)
- Guardar: encargos activos con progreso.
- Formato: array de {encargo_id, progreso, timestamp}.
## Specs Guardado (Beam 513)

### Testear eventos no duplicados al recargar
- Spec: testear eventos no duplicados al recargar. Coherente con M59 (guardado) y M74 (eventos).