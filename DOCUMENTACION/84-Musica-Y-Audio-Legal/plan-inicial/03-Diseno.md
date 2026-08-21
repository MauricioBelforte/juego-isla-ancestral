# Módulo 84: Música y Audio — Legal — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## 1. Flujo de Licenciamiento de Audio

```
[Necesidad de Audio]
       │
       ▼
[Tipo de Audio] ──┬── Original ──► Work-for-Hire Contract
                   │                  │
                   │                  ▼
                   │             [Composer/Musician]
                   │                  │
                   │                  ▼
                   │             [Copyright al Estudio]
                   │                  │
                   │                  ▼
                   │             [Credito Obligatorio]
                   │
                   ├── Stock ──► License Verification
                   │                  │
                   │                  ▼
                   │             [Perpetual License?]
                   │                  │
                   │              SÍ ──► [Usar + Attribution]
                   │              NO ──► [Buscar Alternativa]
                   │
                   └── IA ──► [AI as Tool]
                                  │
                                  ▼
                             [Composer como Autor Final]
                                  │
                                  ▼
                             [Disclosure en Créditos]
```

## 2. Recursos de Datos

### AudioLicense (Resource)

```gdscript
class_name AudioLicense
extends Resource

@export var audio_name: String
@export var audio_type: AudioType
@export var license_type: LicenseType
@export var licensor: String                    # Quién dio la licencia
@export var license_scope: LicenseScope         # Exclusiva, no-exclusiva, etc.
@export var perpetual: bool                     # ¿Es perpetua?
@export var commercial_use: bool                # ¿Permite uso comercial?
@export var attribution_required: bool          # ¿Requiere credito?
@export var attribution_text: String            # Texto de credito requerido
@export var royalty_required: bool              # ¿Requiere regalías?
@export var royalty_rate: float                 # Tasa de regalías (si aplica)
@export var territory: String                   # Territorio de la licencia
@export var duration: String                    # Duración de la licencia
@export var license_document_path: String       # Ruta al documento de licencia
@export var notes: String                       # Notas adicionales
```

### AudioType (Enum)

```gdscript
enum AudioType {
    ORIGINAL_COMPOSITION,    # Composición original para el juego
    STOCK_LIBRARY,           # Librería de stock
    AI_GENERATED,            # Generado por IA
    SAMPLE,                  # Muestra de canción existente
    SOUND_DESIGN,            # Diseño de sonido original
    VOICE_ACTING             # Grabación de voz
}
```

### AudioCredit (Resource)

```gdscript
class_name AudioCredit
extends Resource

@export var person_name: String
@export var role: String                    # Composer, Musician, Sound Designer, etc.
@export var contribution: String            # Qué contribuyó específicamente
@export var track_list: Array[String]       # Pistas en las que trabajó
@export var contract_reference: String      # Referencia al contrato
@export var payment_status: String          # Paid, Pending, Royalty-based
```

## 3. Nodos Principales

### AudioLegalManager (Node)

```gdscript
class_name AudioLegalManager
extends Node

## Gestiona todos los aspectos legales del audio del juego.

var licenses: Array[AudioLicense] = []
var credits: Array[AudioCredit] = []

func validate_all_audio() -> AudioLegalValidationResult:
    # Verificar que todos los audios tengan licencia válida
    # Verificar que todos los artistas tengan contrato
    # Retornar resultado de validación

func add_license(license: AudioLicense) -> void:
    # Agregar licencia al inventario

func add_credit(credit: AudioCredit) -> void:
    # Agregar crédito al registro

func generate_credits_text() -> String:
    # Generar texto de créditos para el juego
    # Formato: "Música: [Nombre] - [Rol]"

func generate_credits_web() -> String:
    # Generar créditos detallados para archivo web
    # Incluye: nombre, rol, contribución, tracks
```

### AudioLicenseValidator (Node)

```gdscript
class_name AudioLicenseValidator
extends Node

func validate_license(license: AudioLicense) -> AudioLicenseValidationResult:
    # Verificar que la licencia sea válida
    # Verificar que cubra el uso previsto
    # Verificar perpetual vs. subscription
    # Verificar territory y duration

func check_commercial_use(license: AudioLicense) -> bool:
    # Verificar si la licencia permite uso comercial

func check_attribution(license: AudioLicense) -> AudioCredit:
    # Generar crédito basado en la licencia
```

### AudioCreditsGenerator (Node)

```gdscript
class_name AudioCreditsGenerator
extends Node

func generate_game_credits(credits: Array[AudioCredit]) -> String:
    # Generar créditos para menú del juego
    # Formato compacto y legible

func generate_web_credits(credits: Array[AudioCredit]) -> String:
    # Generar créditos detallados para archivo web
    # Formato completo con descripciones

func generate_build_credits(output_path: String) -> void:
    # Generar archivo de créditos para build
```

## 4. Integración con Sistemas Existentes

### Con M41 (Música)

```
[M41 Banda Sonora] ──► [AudioLegalManager]
                           │
                           ├── License para cada composición
                           ├── Credit para cada artista
                           └── Validación de uso
```

### Con M79 (Legal Contratos)

```
[M79 Contratos] ──► [AudioLicense.contract_reference]
                        │
                        ▼
                   [Contrato Work-for-Hire]
                        │
                        ▼
                   [Cesión de PI al Estudio]
```

### Con M86 (IA Generativa)

```
[M86 IA Generativa] ──► [AudioLicense(AI_GENERATED)]
                            │
                            ▼
                       [Composer como Autor Final]
                            │
                            ▼
                       [Disclosure en Créditos]
```

## 5. Formato de Créditos

### En el Juego (Compacto)

```
MÚSICA
Banda Sonora: [Nombre del Compositor]
Música Adicional: [Nombres]

SONIDO
Diseño de Sonido: [Nombre]
```

### En Archivo Web (Detallado)

```
## Música y Audio

### Banda Sonora Original
- **Compositor:** [Nombre]
- **Pistas:** 12 composiciones originales
- **Contrato:** Work-for-Hire #001
- **Fecha:** 2026

### Músicos Adicionales
- [Nombre] - Guitarra (Pistas 3, 7)
- [Nombre] - Piano (Pista 5)

### Diseño de Sonido
- [Nombre] - Efectos de sonido
- [Nombre] - Ambiente

### Música Generada por IA
- Herramienta: [Nombre herramienta]
- Supervisión: [Nombre del compositor]
- Disclosure: Esta banda sonora incluye elementos generados por IA
```
