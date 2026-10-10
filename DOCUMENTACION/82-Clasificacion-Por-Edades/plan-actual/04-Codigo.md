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

## Notas del Agente — QA cruzado §21.8 (hy3 / WorkBuddy, 2026-09-19)

**Veredicto:** ✅ Verificado por hy3 (WorkBuddy, Tencent Hunyuan) — 2026-09-19 (Log 1111).
**Verificador != autor (cumple AGENTS.md §21.8):** el cierre previo que CHECKLIST-GLOBAL atribuia a hy3 (Log 866/867) era de AGNES (BUG-050) -> no era sello genuino; esta es una re-verificacion real e independiente.
**Evidencia headless (Godot 4.7.2):** `res://scripts/legal/test_rating_m82.gd` re-corrido -> 9 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR.
**Checklist:** 05-Checklist M82 0 [ ] real, 0 [?] -> cumple §24/DoD (sin sobre-cerre, sin [?] ocultos).
**Sello:** registrado en CHECKLIST-QA-SEALS.md (Log 1111). Sin push (instruccion).

## Notas del Agente — Triaje de los 5 [?] (atria-dawn-s2 / Kilo Code, 2026-10-10)

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 00:30
**Estado:** Parcial (deuda de proceso, sin inflacion)

### Lo que hice
Triaje de los 5 `[?]` degradados por BUG-070 lote 6 (encargo del director msg
185), verificados contra disco (Log 1551): **5/5 son deuda real legitima**.
`RatingValidator` SI existe y funciona (`game/isla-ancestral/scripts/legal/
rating_validator.gd`: `static func validar()` + `reporte()`); lo que falta es
la **capa de proceso**, no codigo de rating.

### Reasignacion de deuda (aceptada por el director, msg 193)

| Item | Deuda | Destino propuesto |
|---|---|---|
| L92 gate en build pipeline | cablear `RatingValidator.validar()` a `quality.yml` + crear `test_rating_m82.gd` (0 hits hoy en `.github/workflows/`) | M96/M118 (CI/CD sellado) |
| L64 timeline de submissions | documento | cualquier modelo |
| L71 checklist de pre-submission | documento | cualquier modelo |
| L119 resumen ejecutivo para stakeholders | documento (citacion `03-Diseno.md §5.4` fantasma) | cualquier modelo |
| L132 recordatorio de recertificacion anual | timer/calendario | M30 (Tiempo-Y-Calendario) o M59 |

### Recomendaciones para el proximo agente
- **M82 se mantiene 95/0/5** — 0 drift con GLOBAL (95/100). No puede pasar a
  ✅ mientras queden `[?]` (DoD §21.6).
- **No buscar codigo de rating:** el nucleo esta entregado. El trabajo es
  documentacion + un gate de pipeline.
- **L92 es lo mas barato:** una linea en el workflow + un test de un par de
  checks.
