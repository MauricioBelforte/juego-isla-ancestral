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


## Specs Modelos 3D Legal (Beam 688)

### Crear inventario de todas las librerias de stock
- Spec: crear inventario de todas las librerias de stock. KnownIssue no bloqueante DoD: inventario de assets en inventario_3d.json + GLB manifest; documentacion de licencias por asset en data/licenses/. Inventario parcial existente. Coherente with M85 (modelos 3D legal) and M107 (pipeline).

### Crear ModelLegalManager con validate_all_models()
- Spec: crear ModelLegalManager con validate_all_models(). BUG-070 lote 10 re-verif (atria-dawn, evidencia Ling #97 + s3 #98 + verificacion propia): Familia A - los artefactos citados NO existen: model_legal_manager.gd, model_license_validator.gd, model_license.gd, model_credit.gd, build_script.gd = 0 en disco; git grep ModelLegalManager/ModelLicenseValidator/MODEL_CREDITS = 0 en scripts/. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Implementar add_license() y add_credit()
- Spec: implementar add_license() y add_credit(). INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco, model_license.gd/model_credit.gd ausentes. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Implementar generate_credits_text() (formato compacto)
- Spec: implementar generate_credits_text() (formato compacto). INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Implementar generate_credits_web() (formato detallado)
- Spec: implementar generate_credits_web() (formato detallado). INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).


## Specs Modelos 3D Legal (Beam 689)

### Implementar save_build_credits() para builds
- Spec: implementar save_build_credits() para builds. INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Generar archivo MODEL_CREDITS.txt en cada build
- Spec: generar archivo MODEL_CREDITS.txt en cada build. BUG-070 lote 10 re-verif: Familia A - los artefactos citados NO existen. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Test de ModelLicenseValidator con licencia completa
- Spec: test de ModelLicenseValidator con licencia completa. BUG-070 lote 10 re-verif: Familia A - los artefactos citados NO existen. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de ModelLicenseValidator con licencia sin attribution
- Spec: test de ModelLicenseValidator con licencia sin attribution. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de ModelLicenseValidator con licencia no-perpetual
- Spec: test de ModelLicenseValidator con licencia no-perpetual. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).


## Specs Modelos 3D Legal (Beam 690)

### Test de ModelLegalManager con inventario vacio
- Spec: test de ModelLegalManager con inventario vacio. BUG-070 lote 10 re-verif: Familia A - los artefactos citados NO existen. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de ModelLegalManager con inventario completo
- Spec: test de ModelLegalManager con inventario completo. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de generacion de creditos compactos
- Spec: test de generacion de creditos compactos. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de generacion de creditos web
- Spec: test de generacion de creditos web. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Test de verificacion de uso comercial
- Spec: test de verificacion de uso comercial. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).


## Specs Modelos 3D Legal (Beam 691)

### Test de edge case: modelo con multiples licencias
- Spec: test de edge case: modelo con multiples licencias. BUG-070 lote 10 re-verif: Familia A - los artefactos citados NO existen. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M112 (testing).

### Build incluye MODEL_CREDITS.txt automaticamente
- Spec: build incluye MODEL_CREDITS.txt automaticamente. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Integracion con M117 (Build Pipeline)
- Spec: integracion con M117 (Build Pipeline). BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Integracion con M72 (Validacion de Builds)
- Spec: integracion con M72 (Validacion de Builds). BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M72 (logros).


## Specs Modelos 3D Legal (Beam 692)

### Integracion con M71 (Gestion de Assets)
- Spec: integracion con M71 (Gestion de Assets). BUG-070 lote 10 re-verif: Familia A - los artefactos citados NO existen. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M71 (gestion de assets).

### Logging de validacion de modelos en build log
- Spec: logging de validacion de modelos en build log. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M102 (logging).

### Modo dry-run para verificar sin generar outputs
- Spec: modo dry-run para verificar sin generar outputs. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Skip de validacion en builds de desarrollo
- Spec: skip de validacion en builds de desarrollo. BUG-070 lote 10 re-verif: Familia A. Nucleo real: model3d_validator.gd + modelos_3d.json. Coherente with M85 (modelos 3D legal) and M117 (build pipeline).

### Specs items degradados T246 (2026-10-26, Reflection-Beam-1.0)
- **L105 (agregar paso de validación de modelos en build_script.gd):** REVERTIDO por re-auditoría H2-estricta BUG-070 (atria-dawn s2 #150, 2026-10-08): artefacto inexistente + autocontradicción en 05-Checklist.md L150-158. Ver msg s2 #150.
- **L106 (build falla si hay licencia de modelo inválida):** BUG-070 lote 10 re-verif (atria-dawn, evidencia s3 #98): Patrón D con L105 [?] — build_script.gd revertido por s2, no existe.
