# Módulo 85: Modelos 3D — Legal — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## 1. Flujo de Licenciamiento de Modelos

```
[Necesidad de Modelo 3D]
       │
       ▼
[Tipo de Modelo] ──┬── Original ──► Work-for-Hire Contract
                   │                  │
                   │                  ▼
                   │             [Artista 3D]
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
                   │             [Royalty-Free?]
                   │                  │
                   │              SÍ ──► [Usar + Attribution]
                   │              NO ──► [Buscar Alternativa]
                   │
                   └── IA ──► [AI as Tool]
                                  │
                                  ▼
                             [Artista como Autor Final]
                                  │
                                  ▼
                             [Disclosure en Créditos]
```

## 2. Recursos de Datos

### ModelLicense (Resource)

```gdscript
class_name ModelLicense
extends Resource

@export var model_name: String
@export var model_type: ModelType
@export var license_type: LicenseType
@export var licensor: String
@export var license_scope: LicenseScope
@export var perpetual: bool
@export var commercial_use: bool
@export var attribution_required: bool
@export var attribution_text: String
@export var redistribution_allowed: bool
@export var modification_allowed: bool
@export var territory: String
@export var license_document_path: String
@export var notes: String
```

### ModelType (Enum)

```gdscript
enum ModelType {
    ORIGINAL,          # Creado para el juego
    STOCK,             # Librería de terceros
    OPEN_SOURCE,       # Código abierto (CC, GPL)
    AI_GENERATED,      # Generado por IA
    MODIFIED           # Remix de modelo existente
}
```

### ModelCredit (Resource)

```gdscript
class_name ModelCredit
extends Resource

@export var artist_name: String
@export var role: String                    # 3D Artist, Modeler, Sculptor
@export var contribution: String            # Qué modeló específicamente
@export var model_list: Array[String]       # Modelos en los que trabajó
@export var contract_reference: String
@export var payment_status: String
```

## 3. Nodos Principales

### ModelLegalManager (Node)

```gdscript
class_name ModelLegalManager
extends Node

## Gestiona todos los aspectos legales de modelos 3D del juego.

var licenses: Array[ModelLicense] = []
var credits: Array[ModelCredit] = []

func validate_all_models() -> ModelLegalValidationResult:
    # Verificar que todos los modelos tengan licencia válida
    # Verificar que todos los artistas tengan contrato
    # Retornar resultado de validación

func add_license(license: ModelLicense) -> void:
    licenses.append(license)

func add_credit(credit: ModelCredit) -> void:
    credits.append(credit)

func generate_credits_text() -> String:
    # Generar texto de créditos para el juego

func generate_credits_web() -> String:
    # Generar créditos detallados para archivo web
```

### ModelLicenseValidator (Node)

```gdscript
class_name ModelLicenseValidator
extends Node

func validate_license(license: ModelLicense) -> ModelLicenseValidationResult:
    # Verificar que la licencia sea válida
    # Verificar que cubra el uso previsto
    # Verificar perpetual vs. subscription

func check_commercial_use(license: ModelLicense) -> bool:
    # Verificar si la licencia permite uso comercial

func check_redistribution(license: ModelLicense) -> bool:
    # Verificar si permite redistribución (importante para mods)
```

## 4. Integración con Sistemas Existentes

### Con M45 (Arte 3D)

```
[M45 Modelos] ──► [ModelLegalManager]
                       │
                       ├── License para cada modelo
                       ├── Credit para cada artista
                       └── Validación de uso
```

### Con M71 (Gestión de Assets)

```
[M71 Assets] ──► [ModelLicenseValidator]
                      │
                      ▼
                 [Verificar licencia al importar]
```

### Con M72 (Validación de Builds)

```
[M72 Builds] ──► [ModelLegalManager.validate_all_models()]
                      │
                      ▼
                 [Build falla si hay licencia inválida]
```

## 5. Formato de Créditos

### En el Juego (Compacto)

```
ARTE 3D
Modelado: [Nombre del Artista]
Props: [Nombres]
```

### En Archivo Web (Detallado)

```
## Arte 3D

### Modelado Principal
- **Artista:** [Nombre]
- **Modelos:** Personaje principal, NPCs principales
- **Contrato:** Work-for-Hire #001

### Props y Decoración
- **Artista:** [Nombre]
- **Modelos:** 50+ props de escenarios

### Modelos de Stock
- **Fuente:** [Nombre de librería]
- **Licencia:** Royalty-Free
- **Atribución:** [Texto requerido]
```
