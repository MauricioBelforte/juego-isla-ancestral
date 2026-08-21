**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 82: Clasificación por Edades

## Archivos Involucrados

### 1. Archivos Principales (Nuevos - Por Crear)

| Ruta | Descripción | Responsabilidad |
|------|-------------|-----------------|
| `scripts/core/legal/rating_profile.gd` | Resource de perfil de rating | Almacenar ratings obtenidos por plataforma |
| `scripts/core/legal/content_validator.gd` | Validador de contenido vs. rating | Verificar consistencia automática |
| `scripts/core/legal/iarc_submission.gd` | Generador de datos para IARC | Preparar submission data |
| `scripts/core/legal/rating_display.gd` | Widget de visualización de rating | Mostrar rating en UI/store |

### 2. Archivos Existentes a Modificar

| Ruta | Modificación Requerida |
|------|------------------------|
| `scripts/core/legal/legal_config.gd` | Referenciar `RatingProfile` para ratings activos |
| `scripts/core/build/build_script.gd` | Integrar `ContentValidator` como gate pre-build |
| `scripts/ui/store/store_page.gd` | Mostrar rating en store page |

### 3. Archivos de Configuración

| Ruta | Descripción |
|------|-------------|
| `resources/legal/rating_profile.tres` | Instancia del Resource RatingProfile |
| `resources/legal/content_descriptors.json` | Descriptores de contenido del juego |

### 4. Funciones Clave

#### rating_profile.gd
```gdscript
func get_iarc_rating() -> int
func get_esrb_rating() -> int
func get_pegi_rating() -> int
func get_cero_rating() -> int
func get_grac_rating() -> int
func get_acb_rating() -> int
func get_usk_rating() -> int
func get_classind_rating() -> int
func get_rating_for_platform(platform: String) -> int
func get_content_descriptors() -> PackedStringArray
func update_from_iarc_submission(submission_data: Dictionary) -> void
```

#### content_validator.gd
```gdscript
func validate_content_against_rating(rating: int, content: Dictionary) -> ValidationResult
func get_descriptors_for_rating(rating: int) -> PackedStringArray
func check_content_consistency() -> bool
```

#### iarc_submission.gd
```gdscript
func generate_submission_data(profile: RatingProfile) -> Dictionary
func get_required_descriptors() -> PackedStringArray
func estimate_rating() -> int
```

### 5. Logs Relacionados

| Log ID | Descripción | Módulo |
|--------|-------------|--------|
| Log 92 | M96 Plataformas | M96 |
| Log 93 | M99 Marketing | M99 |
| Log 100 | M98 Trailer | M98 |
| Log 101 | M79 Legal-Contratos | M79 |

### 6. Integración con Sistemas Existentes

```gdscript
# En build_script.gd - pre_build_step()
var rating_profile = load("res://resources/legal/rating_profile.tres")
var validator = ContentValidator.new()
var result = validator.validate_content_against_rating(
    rating_profile.get_iarc_rating(),
    get_current_content_descriptors()
)
if not result.is_valid:
    push_error("Content validation failed: " + str(result.errors))
    return FAILED
```

### 7. Consideraciones

- **Rating_profile**: Resource → cargado una vez, cacheado
- **ContentValidator**: Validación por eventos (no cada frame)
- **Performance**: Overhead mínimo, solo en build pipeline