**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 81: Legal — Menores

## Arquitectura de Cumplimiento Legal Menores

### 1. Patrón de Diseño: Privacy by Design Integrated

El patrón Privacy by Design Integrated (PbD-I) significa que la protección de menores no es un módulo opcional o añadir después, sino que está integrado en la arquitectura base desde el diseño inicial. Todos los nodos, recursos y sistemas deben consultar un servicio central antes de operar con datos de jugadores potencialmente menores.

### 2. Service Locator: LegalConfigService

Un Resource central que contiene la configuración legal activa para el proyecto. Este servicio es el punto único de consulta para todos los sistemas que necesitan verificar edad/consentimiento.

**Estructura del servicio:**

```gdscript
# res://scripts/core/legal/legal_config.gd
class_name LegalConfig
extends Resource

## Configuración de edad y consentimiento
@export var default_age_group: AgeGroup = AgeGroup.TEEN
@export var require_parental_consent_for_online: bool = true
@export var enable_age_gating_on_startup: bool = true
@export var iarc_rating: IARCRating = IARCRating.EVERYONE

## Datos por cuenta (serializados en save)
var player_age_data: Dictionary = {}  # {player_id: PlayerAgeData}

class PlayerAgeData:
    var player_id: String
    var assigned_age_group: AgeGroup
    var parental_consent_verified: bool
    var consent_date: String  # ISO 8601
    var consent_method: String  # "parental_email", "id_document", "verbal"

## Configuración por plataforma
@export var platform_configs: Array[PlatformConfig] = []

enum AgeGroup {
    UNKNOWN = 0,
    CHILDREN_UNDER_13 = 1,    # <13 años (COPPA protected)
    TEENS_13_17 = 2,          # 13-17 años (GDPR-K / LGPD teens)
    ADULTS_18_PLUS = 3,       # 18+ años
    UNKNOWN_BUT_VERIFIED = 4  # Edad conocida pero no revelada en UI
}

enum IARCRating {
    NONE = 0,
    EVERYONE = 1,
    EVERYONE_10_PLUS = 2,
    TEEN = 3,
    MATURE = 4,
    ADULTS_ONLY = 5
}
```

### 3. Flujos Principales

#### Flujo A: Age Gating en Arranque (Startup Age Gating)

```
INICIO → LegalConfig.cargar() → Detectar Plataforma →
  Verificar Configuración Global →
    SI require_parental_consent_for_online = TRUE:
      → Consultar player_age_data del save actual
        SI no existe:
          → AgeGateScreen.mostrar() → Presentar Opciones:
            1. Continuar como "Visitante" (sin features online)
            2. Verificar edad → Flujo Consentimiento Parental
            3. Salir del juego
        SI edad ya asignada:
          → Verificar parental_consent_verified
            SI FALSE:
              → AgeGateScreen.mostrar() → Solicitar Consentimiento
            SI TRUE:
              → Flujo Normal → Inicializar Features Online
    SI require_parental_consent_for_online = FALSE:
      → Flujo Normal → Inicializar Features Online (sin age check)
  → Aplicar iarc_rating a configuraciones de plataforma
FIN
```

#### Flujo B: Consentimiento Parental

```
→ AgeGateScreen → Solicitar Consentimiento Parental
     │
     ├──→ Opción: Verificación por Email
     │     → Padre recibe email con enlace único
     │     → Padre hace clic en enlace → Servicio de Verificación
     │     → Servicio retorna: {verified: true, player_id: X}
     │     → LegalConfig.actualizar(player_id, {consent: true})
     │     → AgeGateScreen.mostrar() → "Consentimiento otorgado" → Flujo Normal
     │
     ├──→ Opción: Documento ID (más robusto, menos común)
     │     → Padre sube ID → Servicio de Verificación (tercero)
     │     → Servicio retorna: {verified: true, player_id: X, age: Y}
     │     → LegalConfig.actualizar(player_id, {consent: true, age_group: Y})
     │     → AgeGateScreen.mostrar() → "Consentimiento otorgado" → Flujo Normal
     │
     └──→ Opción: Declaración Verbal (menos robusto)
           → Padre escribe confirmación → Hash almacenado (sin ID)
           → LegalConfig.actualizar(player_id, {consent: true, method: "verbal"})
           → AgeGateScreen.mostrar() → "Consentimiento otorgado" → Flujo Normal
```

#### Flujo C: Minimización y Anonimización de Datos

```
Cada Sistema → Operación → LegalConfig.verificar_age_group(player_id)
    SI AgeGroup = CHILDREN_UNDER_13:
      → Eliminar PII (Información Personal Identificable) de datos
      → Aplicar anonimización: hashear player_id, reducir granularidad timestamps
      → Establecer retención máxima = 30 días (o según normativa)
      → Marcar para eliminación automática después del período de retención
    SI AgeGroup = TEENS_13_17:
      → Anonimización estándar con retención más larga
      → Notificación opcional a padres para ciertos tipos de datos
    SI AgeGroup = ADULTS_18_PLUS:
      → Manejo normal de datos, sin restricciones
    SI AgeGroup = UNKNOWN:
      → Default a tratamiento más restrictivo: CHILDREN_UNDER_13
```

#### Flujo D: Crash Reporting Sanitizado para Menores

```
Crash del Juego → CrashReporter.registrar() →
    LegalConfig.verificar_age_group(current_player_id) →
        SI CHILDREN_UNDER_13 O TEENS_13_17 SIN consentimiento:
            → Omitir del crash report: player_id, session_id, ubicación, detalles dispositivo
            → Reemplazar con: "{age_restricted_player}"
            → Agregar metadata: {ageGroup: "children", reason: "COPPA/GDPR-K compliance"}
            → Enviar al servicio: {anonymousCrashData, ageGroupFlag}
        SI TEENS_13_17 CON consentimiento O ADULTS_18_PLUS:
            → Transmisión normal de crash report
        SI UNKNOWN:
            → Default a tratamiento restrictivo (ruta children)
```

#### Flujo E: Analytics y Telemetría Sanitizados

```
Cada Evento → TelemetryService.registrar(eventType, data) →
    LegalConfig.verificar_age_group(player_id) →
        SI CHILDREN_UNDER_13:
            → Eliminar: player_id, session_id, timestamps granulares
            → Hashear todos los identificadores
            → Limitar puntos de datos por sesión (ej: máx 50 eventos)
            → Sin targeting basado en comportamiento
        SI TEENS_13_17:
            → Anonimización estándar, retención más larga
        SI ADULTS_18_PLUS O UNKNOWN:
            → Telemetría normal
```

### 4. Diagramas

#### Diagrama 1: Arquitectura Legal Flow

```
+----------------------+        +----------------------+        +----------------------+
|   Game Systems       |        |   LegalConfigService |        |     Platform API     |
|  (Gameplay, UI, etc.)| <-----> | (Resource central)   | <-----> | (Steam, Console, etc)|
+----------------------+        +----------------------+        +----------------------+
         ^                           ^                           ^
         |                           |                           |
         |  Request: "Can we log?" |                           |
         |------------------------->|                           |
         |                            |                           |
         |  Response: "Yes/No + How"|                           |
         | <-------------------------|                           |
         |                            |                           |
+----------------------+        +----------------------+        +----------------------+
|   Age Gate System    |        |   Data Sanitization  |        |   Crash Reporting    |
|  (Startup, In-game)  |        |  (Per-data-point)    |        |  (Automatic)         |
+----------------------+        +----------------------+        +----------------------+
```

#### Diagrama 2: Age Gating Decision Tree

```
                   +----------------------+
                   |    JUEGO INICIA      |
                   +----------+-----------+
                              |
                              v
          +----------------------+
          | Verificar LegalConfig|
          +----------+-----------+
                     |
          +----------+-----------+
          | requireParentalConsent|
          +----------+-----------+
                     | Sí
                     v
          +----------------------+
          | Mostrar Age Gate     |
          +----------+-----------+
                     |
          +----------+-----------+
          | Padre selecciona:    |
          | 1. Visitante         |
          | 2. Verificar Edad    |
          +----------+-----------+
                   | Sí
                   v
          +----------------------+
          | Consentimiento       |
          | Parental             |
          +----------+-----------+
                   |
          +----------+-----------+
          | Actualizar           |
          | LegalConfig          |
          +----------+-----------+
                   |
                   v
          +----------------------+
          | Inicializar Features |
          +----------------------+
```

### 5. Dependencias de Implementación

| Componente | Módulo Dependiente | Estado |
|------------|-------------------|--------|
| LegalConfig Service | M57 Arquitectura General | Por crear |
| Age Gate System | M53 UI/UX, M59 Guardado, M115 Instalador | Por crear |
| Data Sanitization System | M60 Datos y Serialización, M103 Logging, M104 Analytics, M105 Telemetría, M121 Crash Reporting | Por crear |
| Parental Consent Service | M53 UI/UX, M78 Legal—Propiedad Intelectual, M79 Legal—Contratos | Por crear |
| IARC Rating Integration | M96 Plataformas, M97 Steam Store Page, M117 Build System | Por crear |
| Platform-Specific Config | M96 Plataformas, M117 Build System | Por crear |

### 6. Interfaces Públicas (API Contract)

```gdscript
# Consultar edad actual del jugador
func get_player_age_group(player_id: String) -> AgeGroup

# Verificar si se puede loguear un evento específico
func can_log_event(event_type: String, player_id: String) -> bool

# Sanitizar datos antes de enviar a analytics/crash
func sanitize_for_telemetry(data: Dictionary, player_id: String) -> Dictionary

# Verificar si consentimiento parental está verificado
func is_parental_consent_verified(player_id: String) -> bool

# Obtener rating IARC aplicable
func get_applicable_iarc_rating() -> IARCRating

# Actualizar configuración después de consentimiento
func update_after_parental_consent(player_id: String, age_group: AgeGroup, consent_method: String) -> void
```

### 7. Casos Edge y Manejo de Errores

| Escenario | Manejo |
|-----------|--------|
| Jugador rechaza age gating | Permitir continuar como "Visitante" — features online desactivadas automáticamente |
| Save corrupto (sin datos de edad) | Default a tratamiento CHILDREN_UNDER_13 (máxima restricción) |
| API de plataforma retorna error | Fallback a política más restrictiva, log error pero no bloquear juego |
| Edad del jugador cambia (ej. cumpleaños) | Re-evaluar grupo de edad, revocar features online si ahora <13, notificar UI |
| Múltiples perfiles en mismo dispositivo | Cada perfil obtiene flag de edad independiente, almacenado por perfil en save |
| Juego modificado / save hackeado | Validación al arranque: si flags inconsistentes, default a modo restrictivo |
| Adición futura de plataforma (mobile) | LegalConfig extensible, nuevo PlatformConfig agregado, lógica de age gating misma |

### 8. Checklist de Diseño

Este checklist está integrado en el `05-Checklist.md` del módulo (secciones C, D, E, F). Los ítems de diseño específicos son:

- **C.1-C.15**: Arquitectura y flujos del age gating
- **D.1-D.10**: Sistema de consentimiento parental
- **E.1-E.13**: Minimización y anonimización de datos
- **F.1-F.10**: Rating IARC y contenido
- **G.1-G.13**: Políticas legales (ToS y Privacy Policy)
- **H.1-H.13**: Integración con sistemas existentes

Total de ítems de diseño: **74 ítems** (cubiertos en secciones C-H del 05-Checklist.md)