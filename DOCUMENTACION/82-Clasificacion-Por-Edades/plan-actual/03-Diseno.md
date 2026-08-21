**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 82: Clasificación por Edades

## Arquitectura de Clasificación por Edades

### 1. Flujo General de Obtención de Rating

```
DESARROLLO → Contenido del Juego →
  Verificar descriptores de contenido →
    SI contenido cambió desde última submission:
      → Actualizar submission IARC
      → Re-evaluar ratings regionales
    SI contenido estable:
      → Mantener ratings actuales
  → Generar submission data para cada plataforma →
    IARC (global) → Ratings automáticos para Steam, Google Play, Microsoft Store, Nintendo eShop
    ESRB (EE.UU./Canadá) → Para PlayStation
    PEGI (Europa) → Para Steam, PlayStation, Xbox, Nintendo en Europa
    CERO (Japón) → Para Nintendo Japón
    GRAC (Corea) → Para Steam Corea
    ACB (Australia) → Para Steam Australia
    USK (Alemania) → Para Steam Alemania
    ClassInd (Brasil) → Para Steam Brasil
  → Aplicar ratings a store pages y materials →
    Steam Store Page (M97)
    Trailer (M98)
    Marketing materials (M99)
    Build metadata (M117)
```

### 2. Estructura de Datos: Rating Profile

```gdscript
# res://scripts/core/legal/rating_profile.gd
class_name RatingProfile
extends Resource

## Perfil de clasificación por edades del juego
@export var game_title: String = "Isla Ancestral"
@export var last_updated: String = ""  # ISO 8601

## Ratings obtenidos
@export var iarc_rating: int = 0  # IARCRating enum
@export var esrb_rating: int = 0  # ESRBRating enum
@export var pegi_rating: int = 0  # PEGIRating enum
@export var cero_rating: int = 0  # CERORating enum
@export var grac_rating: int = 0  # GRACRating enum
@export var acb_rating: int = 0  # ACBRating enum
@export var usk_rating: int = 0  # USKRating enum
@export var classind_rating: int = 0  # ClassIndRating enum

## Descriptores de contenido
@export var content_descriptors: PackedStringArray = []

## Estado de submission
@export var iarc_submitted: bool = false
@export var iarc_submission_date: String = ""
@export var iarc_submission_id: String = ""

enum IARCRating { NONE=0, EVERYONE=1, EVERYONE_10_PLUS=2, TEEN=3, MATURE=4, ADULTS_ONLY=5 }
enum ESRBRating { UNKNOWN=0, E=1, E10=2, T=3, M=4, AO=5 }
enum PEGIRating { UNKNOWN=0, PEGI_3=1, PEGI_7=2, PEGI_12=3, PEGI_16=4, PEGI_18=5 }
enum CERORating { UNKNOWN=0, A=1, B=2, C=3, D=4, Z=5 }
enum GRACRating { UNKNOWN=0, ALL=1, TWELVE=2, FIFTEEN=3, EIGHTEEN=4, RESTRICTED=5 }
enum ACBRating { UNKNOWN=0, G=1, PG=2, M=3, MA15=4, R18=5, X18=5 }
enum USKRating { UNKNOWN=0, ZERO=1, SIX=2, TWELVE=3, SIXTEEN=4, EIGHTEEN=5 }
enum ClassIndRating { UNKNOWN=0, L=1, TEN=2, TWELVE=3, FOURTEEN=4, SIXTEEN=5, EIGHTEEN=6 }
```

### 3. Validación Automática de Contenido

```gdscript
# res://scripts/core/legal/content_validator.gd
class_name ContentValidator
extends Node

## Valida que el contenido del juego sea consistente con el rating objetivo
func validate_content_against_rating(rating: int, content: Dictionary) -> ValidationResult:
    var result = ValidationResult.new()

    # Verificar descriptores prohibidos para el rating
    if rating <= RatingProfile.IARCRating.EVERYONE:
        # Everyone: sin violencia, sin miedo, sin contenido sugestivo
        if content.has("violence") and content.violence > 0:
            result.add_error("Violence not allowed for Everyone rating")
        if content.has("fear") and content.fear > 2:
            result.add_error("Excessive fear content for Everyone rating")
        if content.has("language") and content.language > 0:
            result.add_error("Strong language not allowed for Everyone rating")

    if rating <= RatingProfile.IARCRating.EVERYONE_10_PLUS:
        # Everyone 10+: violencia mínima, miedo leve
        if content.has("violence") and content.violence > 2:
            result.add_error("Excessive violence for Everyone 10+ rating")
        if content.has("fear") and content.fear > 3:
            result.add_error("Excessive fear for Everyone 10+ rating")

    # Teen: permite más, pero con límites
    if rating <= RatingProfile.IARCRating.TEEN:
        if content.has("violence") and content.violence > 4:
            result.add_error("Excessive violence for Teen rating")
        if content.has("blood") and content.blood > 2:
            result.add_error("Excessive blood for Teen rating")

    result.is_valid = result.errors.size() == 0
    return result
```

### 4. Integración con Plataformas

| Plataforma | Rating Aceptado | Fuente |
|------------|-----------------|--------|
| Steam (global) | IARC, PEGI, ESRB, USK, ACB, ClassInd | IARC auto-genera |
| PlayStation (EE.UU.) | ESRB | Submission directa |
| PlayStation (Europa) | PEGI | Submission directa |
| Xbox (global) | IARC, ESRB, PEGI | IARC o submission directa |
| Nintendo (global) | IARC, CERO, GRAC | IARC o submission directa |
| Google Play | IARC | IARC auto-genera |
| Apple App Store | IARC | IARC auto-genera |
| Microsoft Store | IARC | IARC auto-genera |

### 5. Checklist de Diseño

Ver `05-Checklist.md` para checklist completo de 100+ items (secciones A-G).