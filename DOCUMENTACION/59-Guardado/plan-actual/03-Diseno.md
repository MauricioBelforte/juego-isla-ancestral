**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 59: Guardado

## 1. Arquitectura

```
Assets/_Project/Saving/
├── data/
│   └── save_schema.gd              (esquema del save: campos, versiones, defaults)
├── service/
│   ├── save_manager.gd             (autoload: encola peticiones, slots, hitos M07)
│   ├── save_writer.gd              (escritura atómica .tmp+rename, background thread)
│   ├── save_loader.gd              (carga, validación, checksum, migración M60, backup)
│   ├── save_backup.gd              (rotación local slot_N.bak, backups manuales)
│   └── save_snapshot.gd            (recolecta/restaura estado de sistemas vía interfaces)
├── ui/
│   ├── save_menu.gd                (menú de guardado en M53: slots, auto-save, borrar)
│   └── save_toast.gd               (feedback sutil "Guardado" M44)
└── validators/
    └── validate_save.gd            (validación: atómico, checksum, migración, perfiles, rendimiento)

Assets/_Project/Services/
└── (autoloads: SaveManager, GameState M60, EventBus M07)
```

`SaveManager` (autoload) recibe peticiones (manuales M53 o por hitos M07), encola y delega la escritura a `save_writer` en background thread; `save_loader` valida y carga al inicio (con migración M60 y backup si es necesario); `save_backup` mantiene la rotación local; `save_snapshot` recolecta el estado de cada sistema vía interfaces (`ISaveProvider`) y lo restaura en carga. La UI (M53) muestra slots y feedback (M44). El formato y las migraciones los define M60.

## 2. Diagramas de Flujo (texto)

### 2.1 Guardado (automático o manual)

```
evento de hito (M07: DAY_END, MISSION_COMPLETED, EVENT_END) o petición manual (M53)
  → SaveManager.request_save(slot)
    → 1) encolar (si hay guardado en curso, esperar su fin)
    → 2) save_snapshot.collect() → payload compacto (interfaces ISaveProvider)
    → 3) save_writer.write_atomic(): payload → slot_N.tmp → fsync → rename slot_N.save
    → 4) save_backup.rotate(): save anterior → slot_N.bak (conserva 1-2)
    → 5) toast "Guardado" (M44) sin bloquear
    → 6) log SAVE-OK (o SAVE-ERROR con fallback)
```

### 2.2 Carga y validación

```
inicio del juego / selección de slot (M53)
  → save_loader.load(slot):
    → 1) leer slot_N.save + verificar existencia
    → 2) validar checksum (SHA-256 del payload)
    → 3) validar estructura (campos, tipos, rangos — save_schema.gd)
    → 4) si falla → avisar y ofrecer slot_N.bak (recuperación)
    → 5) si schema_version < actual → migrar (M60) con backup previo
    → 6) save_snapshot.restore() → cada sistema restaura vía ISaveProvider
    → 7) log SAVE-LOAD (slot, versión, tiempo de carga)
```

### 2.3 Manejo de falta de espacio

```
save_writer.write_atomic() falla por disco lleno
  → 1) NUNCA tocar slot_N.save (sigue intacto)
  → 2) limpiar slot_N.tmp huérfano
  → 3) aviso claro en UI (M53): "Guardado fallido: sin espacio"
  → 4) log SAVE-DISKFULL
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