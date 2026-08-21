# Módulo 83: Licencias de Software — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## 1. Flujo de Obtención de Licencias

```
[Build Iniciado]
       │
       ▼
[LicenseScanner] ──► Escanea project.godot + addons/ + scripts/
       │
       ▼
[Detectar Dependencias] ──► Lista de paquetes + versiones
       │
       ▼
[LicenseExtractor] ──► Para cada dependencia, extraer licencia:
       │                  - Buscar archivo LICENSE/COPYING
       │                  - Leer metadata del addon (plugin.cfg)
       │                  - Query API de registro (npm, PyPI, etc.)
       │                  - Fallback: "unknown"
       │
       ▼
[LicenseValidator] ──► Validar compatibilidad:
       │                  - ¿Hay GPL/AGPL? → Source code offer
       │                  - ¿Hay incompatibilidades? → Build FAIL
       │                  - ¿Hay no-comercial? → Warning
       │
       ▼
[LicenseNoticeGenerator] ──► Generar THIRD_PARTY_LICENSES.txt
       │                       + copies en licenses/
       │
       ▼
[Build Continúa] ──► License notice incluido en output
```

## 2. Recursos de Datos

### LicenseProfile (Resource)

```gdscript
class_name LicenseProfile
extends Resource

@export var dependency_name: String          # Nombre de la dependencia
@export var version: String                  # Versión instalada
@export var license_type: LicenseType        # Tipo de licencia
@export var license_text: String             # Texto completo de la licencia
@export var license_url: String              # URL del archivo de licencia
@export var commercial_use: bool             # ¿Permite uso comercial?
@export var modifications_required: bool     # ¿Requiere compartir modificaciones?
@export var attribution_required: bool       # ¿Requiere atribución?
@export var source_offer_required: bool      # ¿Requiere ofrecer source code?
@export var notes: String                    # Notas adicionales
```

### LicenseType (Enum)

```gdscript
enum LicenseType {
    MIT,            # Permisiva, sin restricciones
    BSD_2,          # Permisiva, 2 cláusulas
    BSD_3,          # Permisiva, 3 cláusulas
    APACHE_2,       # Permisiva, con patentes
    GPL_2,          # Copyleft fuerte
    GPL_3,          # Copyleft fuerte, más moderno
    LGPL,           # Copyleft débil
    MPL_2,          # Copyleft débil, archivo por archivo
    AGPL,           # Copyleft fuerte, incluye red
    CC0,            # Dominio público
    CC_BY,          # Requiere atribución
    CC_BY_NC,       # Requiere atribución, no comercial
    PROPRIETARY,    # Licencia propietaria
    UNKNOWN,        # Licencia no determinada
    DUAL            # Doble licencia (elegir una)
}
```

### LicensePolicy (Resource)

```gdscript
class_name LicensePolicy
extends Resource

@export var policy_name: String
@export var allowed_licenses: Array[LicenseType]
@export var prohibited_licenses: Array[LicenseType]
@export var copyleft_mode: CopyleftMode  # ALLOW, ISOLATE, DENY
@export var require_attribution: bool
@export var require_source_offer: bool
```

## 3. Nodos Principales

### LicenseScanner (Node)

```gdscript
class_name LicenseScanner
extends Node

signal scan_complete(inventory: Array[LicenseProfile])
signal scan_error(error: String)

func scan_project() -> Array[LicenseProfile]:
    # Escanear project.godot para dependencias del core
    # Escanear addons/ para plugins instalados
    # Escanear scripts/ para imports directos
    # Retornar inventario completo

func scan_addon(addon_path: String) -> LicenseProfile:
    # Leer plugin.cfg
    # Buscar LICENSE/COPYING en directorio del addon
    # Retornar LicenseProfile

func scan_dependency(dep_name: String) -> LicenseProfile:
    # Query API de registro (npm, pip, etc.)
    # Buscar archivo de licencia
    # Retornar LicenseProfile
```

### LicenseValidator (Node)

```gdscript
class_name LicenseValidator
extends Node

var policy: LicensePolicy

func validate(inventory: Array[LicenseProfile]) -> LicenseValidationResult:
    # Verificar cada licencia contra policy
    # Detectar incompatibilidades
    # Retornar resultado con errores y warnings

func check_compatibility(license_a: LicenseType, license_b: LicenseType) -> bool:
    # Verificar si dos licencias son compatibles

func requires_source_offer(inventory: Array[LicenseProfile]) -> bool:
    # Verificar si alguna licencia requiere source code offer
```

### LicenseNoticeGenerator (Node)

```gdscript
class_name LicenseNoticeGenerator
extends Node

func generate_notice(inventory: Array[LicenseProfile]) -> String:
    # Generar THIRD_PARTY_LICENSES.txt con formato:
    # [Nombre] [Versión] [Licencia]
    # [Texto de licencia]

func save_notices(output_dir: String) -> void:
    # Guardar notices en directorio de output
    # Copiar licencias originales a licenses/

func include_in_build(build_dir: String) -> void:
    # Copiar notices al directorio del build
```

## 4. Integración con Build Pipeline (M117)

```
[BuildScript] → LicenseScanner → LicenseValidator
                                    │
                                    ├─ ❌ Incompatible → Build FAIL + Error Message
                                    ├─ ⚠️ No verificado → Warning
                                    └─ ✅ Válido → LicenseNoticeGenerator → Build output
```

## 5. Estructura de Archivos en Build Output

```
Build/
├── IslaAncestral.exe
├── IslaAncestral_Data/
│   ├── ...
├── THIRD_PARTY_LICENSES.txt      ← Generado automáticamente
└── licenses/                     ← Copias de licencias originales
    ├── godot-engine.txt
    ├── addon-1.txt
    └── ...
```

## 6. Integración con Inventario de Dependencias (M55)

```
[PackageScanner] → [DependencyInventory] → [LicenseScanner]
                                                    │
                                                    ▼
                                            [LicenseProfile por dependencia]
                                                    │
                                                    ▼
                                            [LicenseValidator]
```

El módulo 55 gestiona QUÉ dependencias hay. El módulo 83 gestiona QUÉ LICENCIAS tienen esas dependencias.
