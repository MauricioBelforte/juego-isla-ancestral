# Módulo 119: Actualizaciones — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## 1. Flujo de Actualización

```
[Conexión a Internet]
       │
       ▼
[UpdateChecker] ──► Verificar versión actual vs. última disponible
       │
       ▼
[¿Hay actualización?] ── NO ──► [Sin cambios]
       │
      SÍ
       │
       ▼
[Notificar al Jugador] ──► Popup en menú principal
       │
       ▼
[Jugador Acepta] ──► [Descargar Update]
       │
       ▼
[Backup Save] ──► Guardar copia de seguridad
       │
       ▼
[Aplicar Update] ──► Instalar archivos nuevos
       │
       ▼
[Migrar Save] ──► Convertir save a nuevo schema
       │
       ▼
[Reiniciar Juego] ──► Cargar nueva versión
       │
       ▼
[¿Funciona?] ── SÍ ──► [Eliminar backup antiguo]
       │
      NO
       │
       ▼
[Rollback] ──► Restaurar versión anterior + save
```

## 2. Recursos de Datos

### GameVersion (Resource)

```gdscript
class_name GameVersion
extends Resource

@export var major: int
@export var minor: int
@export var patch: int
@export var build: int
@export var date: String

func to_string() -> String:
    return "v%s.%s.%s.%s (%s)" % [major, minor, patch, build, date]

func is_newer_than(other: GameVersion) -> bool:
    if major != other.major: return major > other.major
    if minor != other.minor: return minor > other.minor
    if patch != other.patch: return patch > other.patch
    return build > other.build

## Compatibilidad mismo major.minor (helper pedido por el item del checklist;
## sin consumidor aun - deuda de implementacion M59).
func is_same_major_minor(other: GameVersion) -> bool:
    return major == other.major and minor == other.minor
```

### UpdateInfo (Resource)

```gdscript
class_name UpdateInfo
extends Resource

@export var version: GameVersion
@export var title: String
@export var description: String
@export var changelog: Array[String]
@export var download_url: String
@export var file_size_mb: int
@export var is_critical: bool
@export var required_version: GameVersion
@export var release_date: String
```

### SaveMigration (Resource)

```gdscript
class_name SaveMigration
extends Resource

@export var from_version: GameVersion
@export var to_version: GameVersion
@export var migration_script: String        # Ruta al script de migración
@export var backup_required: bool
@export var description: String
```

## 3. Nodos Principales

### UpdateManager (Node)

```gdscript
class_name UpdateManager
extends Node

## Gestor principal de actualizaciones del juego.

signal update_available(info: UpdateInfo)
signal update_downloaded(info: UpdateInfo)
signal update_applied(info: UpdateInfo)
signal update_failed(error: String)

var current_version: GameVersion
var latest_version: GameVersion

func check_for_updates() -> void:
    # Verificar con la API de la plataforma
    # Emitir signal si hay actualización

func download_update(info: UpdateInfo) -> void:
    # Descargar actualización
    # Mostrar progreso
    # Emitir signal al completar

func apply_update(info: UpdateInfo) -> void:
    # Backup del save actual
    # Aplicar archivos nuevos
    # Migrar save si es necesario
    # Reiniciar juego

func rollback() -> void:
    # Restaurar versión anterior
    # Restaurar save desde backup
```

### UpdateChecker (Node)

```gdscript
class_name UpdateChecker
extends Node

## Verifica actualizaciones disponibles.

func check_steam() -> UpdateInfo:
    # Verificar vía Steamworks API
    pass

func check_gog() -> UpdateInfo:
    # Verificar vía GOG Galaxy
    pass

func check_manual(url: String) -> UpdateInfo:
    # Verificar vía URL manual
    pass

## Fachada unica pedida por el item del checklist 'Crear UpdateChecker con
## check_latest()': despacha segun el canal de versions.json (estable/beta/dev)
## leido por UpdateManager y devuelve el UpdateInfo del canal activo. NO crea
## un segundo sistema de versionado.
func check_latest() -> UpdateInfo:
    pass
```

### SaveMigrator (Node)

```gdscript
class_name SaveMigrator
extends Node

## Migra saves a nueva versión del juego.

func migrate_save(save_path: String, from_version: GameVersion, to_version: GameVersion) -> bool:
    # Buscar migración necesaria
    # Ejecutar script de migración
    # Verificar integridad del save migrado
    # Retornar éxito/fallo

func backup_save(save_path: String) -> String:
    # Crear copia de seguridad
    # Retornar ruta del backup

func restore_save(backup_path: String) -> bool:
    # Restaurar save desde backup
    pass
```

### UpdateDownloader (Node)

```gdscript
class_name UpdateDownloader
extends Node

## Descarga paquetes de actualizacion. Seccion disenada el 2026-10-20
## (Step-5-WorkBuddy, Log 2023) para cerrar T-022. NO implementado aún:
## KnownIssue no bloqueante DoD, duenio deimplementacion M96/M118.

signal download_started(url: String)
signal download_progress(recibido: int, total: int)
signal download_completed(ruta: String, sha256: String)
signal download_failed(motivo: String)

const DIR_TMP := "user://updates/tmp/"

func download(info: UpdateInfo) -> void:
    # 1. Verificar espacio antes de empezar (ver reglas)
    # 2. HTTPRequest al info.download_url
    # 3. Progreso por download_chunk_size
    # 4. Renombrar .tmp al completar
    pass

func cancelar() -> void:
    # HTTPRequest.cancel_request() + borrar el .tmp parcial
    pass

func verificar_integridad(ruta: String, sha256_esperado: String) -> bool:
    # SHA-256 del paquete vs UpdateInfo.sha256
    pass
```

Reglas de diseno:

- Descarga a `user://updates/tmp/<version>.pck.tmp`; al completar se renombra a `<version>.pck`.
- Progreso: senial cada ~5 % o 250 KB (lo que ocurra primero), para no spamear la UI.
- Resume: cabecera `Range: bytes=<inicio>-` sobre el `.tmp` existente; si el servidor no acepta rangos, se reinicia la descarga.
- Integridad: SHA-256 del paquete comparado con el campo `sha256` a agregar en `UpdateInfo` (Resource de §2) ANTES de aplicar.
- Errores de red: 3 reintentos con backoff 1 s / 5 s / 15 s; sin spinner infinito.
- Espacio insuficiente: `DirAccess.get_space_left()` sobre `user://` (no `OS.get_static_memory_usage()`, que mide RAM); si `tamano + 10 % > libre`, abortar con aviso al jugador.
- Cancelacion: `HTTPRequest.cancel_request()` + borrado del `.tmp` parcial; el jugador puede reintentar.
- Un solo download a la vez (mutex interno). NO crea un segundo sistema de versionado: se apoya en `versions.json` (canales/politica) y `UpdateManager` (autoload); `comparar_versiones()` sigue siendo la comparacion canonica.

### RollbackManager (Node)

```gdscript
class_name RollbackManager
extends Node

## Restaura la version anterior + su save.Seccion disenada el 2026-10-20
## (Step-5-WorkBuddy, Log 2023) para cerrar T-049 a T-056. NO implementado
## aún: KnownIssue no bloqueante DoD, duenio deimplementacion M107/M59.

signal rollback_iniciado(desde: String, hacia: String)
signal rollback_completado()
signal rollback_fallido(motivo: String)

const DIR_VERSIONES := "user://updates/versiones/"

func restore_previous_version() -> bool:
    # 1. Elegir la version anterior inmediata
    # 2. Verificar integridad del backup (fail-closed)
    # 3. Restaurar .pck + save del backup
    # 4. Verificar y reiniciar el juego
    pass

func listar_versiones() -> Array:
    # Versiones con backup disponible en DIR_VERSIONES
    pass

func verificar_integridad(directorio: String) -> bool:
    # Hash del backup vs manifiesto; si falla, NO restaurar
    pass
```

Reglas de diseno (T-049 a T-056):

- T-049 backup por version: `user://updates/versiones/<X.Y.Z>/` con el `.pck` aplicado y su save.
- T-050 politica de retencion: `min_versiones_atras` de `versions.json` (hoy 2) define cuantas versiones anteriores se conservan; las mas viejas se borran.
- T-051 disparo: automatico si `apply_update()` falla o el juego cae 2 veces seguidas tras el update; manual desde settings.
- T-052 verificacion fail-closed: hash del backup contra su manifiesto ANTES de restaurar; si no cuadra, abortar sin tocar el juego.
- T-053 save: restaura `save_001_backup_v<X.Y.Z>.tres` (hoy copia manual; con SaveMigrator implementado §5).
- T-054 UI: popup "Hubo un problema con la actualizacion. Restaurar version anterior?" + entrada en settings con la lista de versiones disponibles.
- T-055 notificacion post-rollback + registro con fecha, version desde/hacia y motivo.
- T-056 integridad post-rollback: re-verificar `.pck` restaurado y save antes de arrancar.

## 4. Integración con Plataformas

### Steam (Steamworks)

```
[Steam API] ──► SteamApp.UpdateAvailable()
                     │
                     ▼
               [Download via Steam]
                     │
                     ▼
               [Auto-apply on restart]
```

### GOG (Galaxy)

```
[GOG API] ──► Galaxy.UpdateAvailable()
                    │
                    ▼
              [Download via GOG]
                    │
                    ▼
              [Apply on restart]
```

### Manual (itch.io, etc.)

```
[Manual Check] ──► HTTP GET to URL
                         │
                         ▼
                   [Compare versions]
                         │
                         ▼
                   [Download ZIP]
                         │
                         ▼
                   [Extract + Apply]
```

## 5. Compatibilidad de Saves

### Estrategia de Migración

```
[Save Version X] ──► Migración 1 ──► [Save Version X+1]
                                            │
                                            ▼
                                      Migración 2
                                            │
                                            ▼
                                      [Save Version X+2]
```

### Backup Automático

```
user://saves/
├── save_001.tres              ← Save actual
├── save_001_backup_v1.2.2.tres  ← Backup antes de migrar
└── save_001_backup_v1.2.3.tres  ← Backup de versión anterior
```
## Actualizaciones y versiones (cola total M119 batch)

### Resource GameVersion
- Resource GameVersion con campos major, minor, patch, build.
- to_string() para mostrar version.
- is_same_major_minor() para compatibilidad.

### UpdateChecker
- UpdateChecker con check_latest().
- Verificar actualizaciones disponibles.

### UpdateDownloader
- UpdateDownloader con download().
- Descargar actualizaciones.

### SaveMigrator
- SaveMigrator con migrate_save().
- Migrar saves entre versiones.

### RollbackManager
- RollbackManager con restore_previous_version().
- Restaurar version anterior.

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 13 | % de peso del parche promedio sobre tamano base | 5-15% | Coherente con 5GB de M116. Parche = 250-750 MB. |
| 14 | % de cobertura del simulador de update | 80% de los flujos de update | Coherente con lanes de M112. |
| 15 | Timeline de anuncios pre-patch/patch-day/post-patch | T-30 freeze, T-14 envio, T-7 avisos, dia 0 anuncio, D+1-D+7 monitorizacion | Coherente con M99 runbook. |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de cadencia hotfix < 72h numerico** [x] - formula que extendiera su apilado #4 (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de etapas de rollout canary 5%/25%/100%** [x] - formula de phases numeric con circuit-breaker <2% fail (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 9. Cadencia hotfix < 72h numerico
- Formula: hotfix_tiempo_max = 72h = 3 dias. Patch mensual = 30 dias. Respuesta < 48h. SLA primera respuesta <= 72h.
- Cadencias: hotfix P0/P1 < 72h, patch mensual (30 dias), respuesta < 48h.
- Coherente con M144 (SLA <=72h, hotfix <72h).
- Unidad: horas. Dependencia: M144.

### 10. Etapas de rollout canary 5%/25%/100%
- Formula: rollout = [5%, 25%, 100%]. Circuit-breaker: si fail_rate > 2%, rollback automatico.
- 5% de usuarios = test inicial. 25% = expansion. 100% = rollout completo.
- Coherente con M107 (rollback automatico si apply_update() falla o juego cae 2 veces).
- Unidad: porcentaje de usuarios. Dependencia: M107 (rollback).



## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25, riel design-docs agnes msg 258 lote 2)

Metodo produce-first: grep + lectura directa, sin ejecutar Godot. Citas archivo:Línea.

### 11. Cadencia hotfix < 72h (medida)
- update_manager.gd (92 lineas; autoload UpdateManager, project.godot L112) es 100% PASIVO: 0 hits de Timer/_process/intervalo/cron (grep) — el chequeo de actualizaciones es BAJA DEMANDA (hay_actualizacion L64, version_remota L70), no hay cadencia automatica.
- Carga data/updates/versions.json (RUTA_VERSIONS L13): 3 canales (estable 1.0.0 / beta 1.1.0-beta.1 / dev 1.1.0-dev.3, URLs example.com placeholders) + politica {min_versiones_atras: 2, aviso_previa: true, requiere_reinicio: true}. Persistencia user://version.tres (L14, _guardar_version L83).
- comparar_versiones L45: semver X.Y.Z; _parsear hace split("-")[0] (L56) -> IGNORA sufijos pre-release ("1.1.0-beta" == "1.1.0"); test_updates_m119.gd L52 lo afirma como esperado. set_canal L74 valida canal existente.
- hotfix P0/P1 < 72h, patch mensual 30d, respuesta < 48h = PROCESO OPERATIVO documentado en M144 (03-Diseno.md L19-25, flujo de parches RF3: D1-D7 hotfix, mensual patch), NO en runtime.
- DRIFT CI: la suite scripts/updates/test_updates_m119.gd (73 lineas; 4 fases: config, versiones, canales, resumen) NO esta cableada en .github/workflows/quality.yml (grep "updates|update_manager|test_updates" = 0 hits). Las suites M72 (quality.yml L523-528), M105 (L487-490, 4 suites con pisos CHECKS_MINIMOS 16/10/11/27) y M107 (L358-362) SÍ estan cableadas.
- Unidad: horas/dias (proceso). Dependencia: M144.

### 12. Rollout canary 5%/25%/100% (medido)
- 0 hits de canary/rollout/circuit-breaker/fail_rate/porcentaje_usuarios en game/ (grep; unicos falsos positivos = "circuito central" de suites de test). Los porcentajes Beam 316 ###10 y el circuit-breaker <2% NO estan implementados en runtime.
- scripts/updates/ tiene SOLO 2 archivos (update_manager.gd + test_updates_m119.gd): el "RollbackManager con restore_previous_version()" citado en este 03 L365 es INEXISTENTE en disco. El rollback real hoy = reinstalar manualmente la version anterior del canal.
- Mecanismo real en disco = PROMOCION ENTRE CANALES: versions.json 3 canales (dev -> beta -> estable) + politica.min_versiones_atras = 2 (ventana de compatibilidad hacia atras); UpdateManager.set_canal (L74) + hay_actualizacion por canal (L64).
- La via análoga operativa al canary es el despliegue por canales con min_versiones_atras=2; la via del circuit-breaker no existe (no hay telemetria de fallos de update cableada a un rollback — M105 no emite eventos de actualizacion).
- Fórmula Beam [5%, 25%, 100%] + fail_rate > 2% queda como DISENO NO MATERIALIZADO. Deuda (decision del fundador): para canary real hacen falta (a) versionado de payload M105 + eventos de update, (b) RollbackManager nuevo (flujo paralelo, regla §15), (c) cablear test_updates_m119 en CI.
- Unidad: % de usuarios (diseño) / canales (disco). Dependencia: M107 (rollback), M105 (telemetria de fallos).
