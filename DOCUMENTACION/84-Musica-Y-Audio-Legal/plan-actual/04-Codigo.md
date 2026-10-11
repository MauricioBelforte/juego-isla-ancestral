# Módulo 84: Música y Audio — Legal — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

**Estado:** 🟡 Con dudas (98 [x] / 0 [ ] / 1 [?] = 99). El código está genuinamente respaldado: 5 scripts en `scripts/legal/` (audio_legal_manager.gd 259 L, audio_license.gd 130 L, audio_license_validator.gd 38 L, audio_credit.gd 85 L, audio_credits_generator.gd 116 L) + suite `test_audio_licenses_m84.gd` **15 checks / 0 fallos / rc=0 / 0 SCRIPT ERROR** (re-verificado 2026-10-10 por mimo-v2.6-flash-free). BUG-062 corregido (Log 1085). BUG-081 corregido (commit 6b7fdf1, 3 anotaciones de tipo). El único `[?]` (L117) es la generación de reporte de licencias por build — **no implementado**, flipado a `[?]` por atria-dawn-s2 #152 (2026-10-08). Sello §21.8: hy3 ≠ autor (Log 1085). Pendiente para ✅: cerrar L117 (implementar o delegar con dueño).

## Archivos a Crear

### 1. `scripts/legal/audio_legal_manager.gd` — Gestor legal de audio

```gdscript
class_name AudioLegalManager
extends Node

## Gestiona todos los aspectos legales del audio del juego.
## Licencias, créditos, validación y clearances.

signal license_added(license: AudioLicense)
signal credit_added(credit: AudioCredit)
signal validation_complete(result: AudioLegalValidationResult)

var licenses: Array[AudioLicense] = []
var credits: Array[AudioCredit] = []

## Valida que todo el audio tenga licencias y créditos
func validate_all_audio() -> AudioLegalValidationResult:
    var result = AudioLegalValidationResult.new()
    
    # Verificar que haya al menos una banda sonora
    if licenses.is_empty():
        result.add_error("No hay licencias de audio registradas")
    
    # Verificar que cada licencia sea válida
    for license in licenses:
        var validator = AudioLicenseValidator.new()
        var license_result = validator.validate_license(license)
        if not license_result.is_valid:
            for error in license_result.errors:
                result.add_error("Licencia '%s': %s" % [license.audio_name, error])
    
    # Verificar que cada artista tenga crédito
    for credit in credits:
        if credit.person_name.is_empty():
            result.add_error("Crédito con nombre vacío encontrado")
    
    validation_complete.emit(result)
    return result

## Agrega una licencia al inventario
func add_license(license: AudioLicense) -> void:
    licenses.append(license)
    license_added.emit(license)

## Agrega un crédito al registro
func add_credit(credit: AudioCredit) -> void:
    credits.append(credit)
    credit_added.emit(credit)

## Genera texto de créditos compacto para el juego
func generate_game_credits() -> String:
    var text := "MÚSICA Y AUDIO\n"
    text += "=".repeat(30) + "\n\n"
    
    # Agrupar por rol
    var composers: Array[String] = []
    var musicians: Array[String] = []
    var sound_designers: Array[String] = []
    
    for credit in credits:
        match credit.role.to_lower():
            "composer":
                composers.append(credit.person_name)
            "musician":
                musicians.append(credit.person_name)
            "sound designer":
                sound_designers.append(credit.person_name)
    
    if composers.size() > 0:
        text += "Banda Sonora: %s\n" % ", ".join(composers)
    if musicians.size() > 0:
        text += "Músicos: %s\n" % ", ".join(musicians)
    if sound_designers.size() > 0:
        text += "Sonido: %s\n" % ", ".join(sound_designers)
    
    return text

## Genera créditos detallados para archivo web
func generate_web_credits() -> String:
    var text := "# Créditos de Audio — Isla Ancestral\n\n"
    
    for credit in credits:
        text += "## %s\n" % credit.person_name
        text += "- **Rol:** %s\n" % credit.role
        text += "- **Contribución:** %s\n" % credit.contribution
        text += "- **Pistas:** %s\n" % ", ".join(credit.track_list)
        text += "- **Contrato:** %s\n" % credit.contract_reference
        text += "- **Estado de pago:** %s\n\n" % credit.payment_status
    
    return text

## Guarda créditos en archivo para build
func save_build_credits(output_path: String) -> void:
    DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
    
    var file = FileAccess.open(output_path, FileAccess.WRITE)
    if file:
        file.store_string(generate_game_credits())
        file.close()
```

### 2. `scripts/legal/audio_license_validator.gd` — Validador de licencias de audio

```gdscript
class_name AudioLicenseValidator
extends Node

## Valida licencias de audio contra requisitos del juego.

func validate_license(license: AudioLicense) -> AudioLicenseValidationResult:
    var result = AudioLicenseValidationResult.new()
    
    # Verificar que tenga nombre
    if license.audio_name.is_empty():
        result.add_error("Nombre de audio vacío")
    
    # Verificar tipo de licencia
    if license.license_type == LicenseType.UNKNOWN:
        result.add_warning("Tipo de licencia desconocido: %s" % license.audio_name)
    
    # Verificar uso comercial
    if not license.commercial_use:
        result.add_error("Licencia no permite uso comercial: %s" % license.audio_name)
    
    # Verificar perpetual vs subscription
    if not license.perpetual:
        result.add_warning("Licencia no perpetua (subscription): %s" % license.audio_name)
    
    # Verificar attribution
    if license.attribution_required and license.attribution_text.is_empty():
        result.add_error("Requiere attribution pero texto está vacío: %s" % license.audio_name)
    
    return result

## Verifica si una licencia permite uso comercial
func check_commercial_use(license: AudioLicense) -> bool:
    return license.commercial_use

## Genera crédito basado en la licencia
func generate_credit_from_license(license: AudioLicense) -> AudioCredit:
    var credit = AudioCredit.new()
    credit.person_name = license.licensor
    credit.role = "Licensor"
    credit.contribution = "Licencia de audio: %s" % license.audio_name
    credit.contract_reference = license.license_document_path
    return credit
```

### 3. `scripts/legal/audio_credits_generator.gd` — Generador de créditos

```gdscript
class_name AudioCreditsGenerator
extends Node

## Genera archivos de créditos de audio para builds y web.

const CREDITS_FILENAME := "AUDIO_CREDITS.txt"

## Genera créditos compactos para el menú del juego
func generate_game_credits(credits: Array[AudioCredit]) -> String:
    var text := ""
    var roles: Dictionary = {}
    
    for credit in credits:
        if not roles.has(credit.role):
            roles[credit.role] = []
        roles[credit.role].append(credit.person_name)
    
    for role in roles.keys():
        text += "%s: %s\n" % [role.to_upper(), ", ".join(roles[role])]
    
    return text

## Genera créditos detallados para archivo web
func generate_web_credits(credits: Array[AudioCredit]) -> String:
    var text := "# Créditos de Audio — Isla Ancestral\n\n"
    text += "Fecha de generación: %s\n\n" % Time.get_datetime_string_from_system()
    
    for credit in credits:
        text += "---\n"
        text += "## %s\n" % credit.person_name
        text += "- **Rol:** %s\n" % credit.role
        text += "- **Contribución:** %s\n" % credit.contribution
        if credit.track_list.size() > 0:
            text += "- **Pistas:** %s\n" % ", ".join(credit.track_list)
        text += "- **Contrato:** %s\n" % credit.contract_reference
        text += "- **Estado:** %s\n\n" % credit.payment_status
    
    return text

## Guarda créditos en directorio de build
func save_build_credits(credits: Array[AudioCredit], build_dir: String) -> void:
    DirAccess.make_dir_recursive_absolute(build_dir)
    var file = FileAccess.open(
        build_dir.path_join(CREDITS_FILENAME),
        FileAccess.WRITE
    )
    if file:
        file.store_string(generate_game_credits(credits))
        file.close()
```

### 4. `scripts/legal/audio_license.gd` — Resource de licencia de audio

```gdscript
class_name AudioLicense
extends Resource

## Resource que representa una licencia de audio.

@export var audio_name: String
@export var audio_type: AudioType
@export var license_type: LicenseType
@export var licensor: String
@export var license_scope: LicenseScope
@export var perpetual: bool
@export var commercial_use: bool
@export var attribution_required: bool
@export var attribution_text: String
@export var royalty_required: bool
@export var royalty_rate: float
@export var territory: String
@export var duration: String
@export var license_document_path: String
@export var notes: String

enum AudioType {
    ORIGINAL_COMPOSITION,
    STOCK_LIBRARY,
    AI_GENERATED,
    SAMPLE,
    SOUND_DESIGN,
    VOICE_ACTING
}

enum LicenseScope {
    EXCLUSIVE,
    NON_EXCLUSIVE,
    SOLE
}
```

### 5. `scripts/legal/audio_credit.gd` — Resource de crédito de audio

```gdscript
class_name AudioCredit
extends Resource

## Resource que representa un crédito de audio.

@export var person_name: String
@export var role: String
@export var contribution: String
@export var track_list: Array[String]
@export var contract_reference: String
@export var payment_status: String
```

## Archivos a Modificar

### 6. `export/build_script.gd` — Agregar paso de créditos de audio

**Cómo modificar:** Después del paso de licencias (M83), agregar:
```gdscript
# Audio credits step
var audio_legal = AudioLegalManager.new()
var audio_validation = audio_legal.validate_all_audio()

if audio_validation.has_errors():
    push_error("Audio legal validation failed:")
    for error in audio_validation.errors:
        push_error("  - " + error)
    return false  # Build fails

var credits_generator = AudioCreditsGenerator.new()
credits_generator.save_build_credits(audio_legal.credits, output_path)
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Música (M41) | Lee composiciones para licenciar |
| Legal Contratos (M79) | Referencia a contratos de artistas |
| IA Generativa (M86) | Valida audio generado por IA |
| Build Pipeline (M117) | Incluye créditos en builds |
| Legal PI (M78) | Verifica propiedad intelectual |

## Notas del Agente - QA cruzado §21.8 (hy3 / WorkBuddy, 2026-09-19)

**Veredicto:** 🟡 Hallazgos

### Evidencia (codigo respaldado)
- BUG-062 (atria-dawn, Log 1085, 2026-09-19): `test_audio_licenses_m84.gd` re-corrido -> **EXIT 0 - 15 checks, 0 fallos** (antes 38/5 -> corregido a 15/0). 0 SCRIPT ERROR. Binario 4.7.2.
- 05-Checklist: 99/99 [x], 0 [ ], 0 [?].

### Hallazgos (bloqueantes para ✅)
- **Over-mark (sobre-cierre):** L117 `- [x] Generar reporte de licencias de audio por build -> no implementado` - item marcado `[x]` pero su texto declara 'no implementado'. Debe flippearse a `[ ]` o corregirse el texto. Viola §24 (un modulo no cierra con `[x]` que el propio autor describe como no hecho).
- **Sello STALE:** CHECKLIST-QA-SEALS.md citaba Log 883 (8 checks, 2026-09-13) - anterior al fix BUG-062. Actualizado a Log 1085 (15 checks) en SEALS (nota 🟡).
- `04-Codigo.md` NO tiene linea `**Estado:**` ni cierre §21.8.

### Conclusion
El codigo esta genuinamente respaldado (15/0, EXIT 0), pero el cierre documental tiene defectos (over-mark L117 + Estado ausente). No se marca ✅ hasta sanear L117 y el Estado. Requiere accion del autor (MiMo) + re-verificacion.

---

## Notas del Agente — reapertura puntual por BUG-081

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-09-30 04:24

> ⚠️ **M84 NO se reabrió como módulo.** Sigue siendo `✅` sellado y **no debe** marcarse
> como `✅` nuevo ni resetearse su progreso. Esto es únicamente un **bugfix sobre un módulo
> cerrado**, registrado como **BUG-081** en `DOCUMENTACION/11-BUGS.md`.

### Qué se tocó (2 de los 4 sitios de BUG-081 viven en M84)

- `scripts/legal/audio_credit.gd:50` — `var rol_texto := AudioRole.keys()[rol].capitalize()`
  → `var rol_texto: String = ...` (`.keys()` devuelve `Array`; su indexado produce `Variant`
  y `:=` no infiere — lección §28 de `GUIA-GODOT/01-gdscript-errores-comunes.md`).
- `scripts/legal/audio_credits_generator.gd:33` — `var rol_key := AudioCredit.AudioRole.keys()[cred.rol]`
  → `var rol_key: String = ...`
- `scripts/legal/audio_credits_generator.gd:98` → `var tipo_key: String = AudioLicense.AudioType.keys()[lic.audio_type]`

No se modificó ninguna lógica: solo la anotación de tipo. El contrato público de las
funciones (`String`, `Dictionary`, retorno de texto) queda idéntico al de antes.

### Verificación

- `--check-only` sobre los 4 scripts: **4/4 OK**.
- `run_tests.py --module m84`: **1 OK, 0 FAIL** (`test-audio_licenses_m84`, exit=0) — sin
  regresión respecto del baseline.
- `run_tests.py --module m131`: **3 OK, 0 FAIL** (baseline: 2 OK, 1 FAIL).

**Commit:** `6b7fdf1` · **Log:** `Logs/1178-BUG-081_errores-inferencia-scripts-legales_2026-09-30_04-24-35.md`

## Archivos Creados (2026-10-11, Ling 3.1 Flash / Kilo Code — encargo mimo-v2.6 msg 22, L117)

> Implementación del `[?]` L117 "Generar reporte de licencias de audio por build".
> Tool de editor/build (**NO runtime**). Log 1629. Test: 13 checks / 0 fallos / EXIT 0.

### 7. `scripts/legal/audio_license_report_tool.gd` — Tool de reporte por build (nuevo)

`@tool class_name AudioLicenseReportTool extends RefCounted`, API estática (invocable
desde el editor, el pipeline de build de M112/M117 y headless):

- `escanear_assets_audio(raices: Array[String]) -> Array[String]` — escaneo recursivo
  de `.ogg/.wav/.mp3/.opus/.flac/.mid/.it/.xm`; raíces inexistentes se ignoran sin
  error (el proyecto aún no tiene audio en disco).
- `cargar_inventario(ruta_json) -> Dictionary` — **solo lectura** de
  `data/legal/audio_licenses.json` (el inventario NO se modifica).
- `construir_indice(inventario) -> Dictionary` — índice por `track_id` (minúsculas).
- `buscar_track(archivo_ruta, indice) -> Dictionary` — matching: stem del archivo
  (sin extensión, minúsculas) == `id` del track. `{}` si no hay registro.
- `formatear_tipo_licencia(licencia_str) -> String` — taxonomía: CC0 / CC-BY /
  CC-BY-SA / CC-BY-NC (rechazada para builds comerciales) / MIT / PROPIA / OTRO.
- `generar_reporte(assets, indice, plataforma, ruta_inventario) -> String` — markdown
  con **una sección por asset**: nombre de archivo, tipo de licencia, autor, fuente y
  URL de origen. Fuente/URL se derivan de `autor`/`attribution` del inventario (el
  JSON no tiene campos propios de fuente/URL; derivación documentada en el código).
- `generar_reporte_build(plataforma, dir_salida, ruta_inventario, raices_audio) -> Dictionary`
  — orquestador (hook de build): escanea → cruza → escribe `LICENCIAS-AUDIO.md` en
  `dir_salida` → `push_warning` por asset sin licencia → resumen
  `{"total", "con_licencia", "sin_licencia", "archivos_sin_licencia", "ruta_reporte", "error"}`.

**Regla clave (encargo):** todo asset de audio del build aparece en el reporte; el que
NO está en el inventario se marca **`SIN LICENCIA REGISTRADA`** (nunca se omite) y se
loguea como warning en la consola del editor.

### 8. `scripts/legal/audio_license_report_editor.gd` — Entry point de editor (nuevo)

`extends EditorScript` — **tool de editor invocable** (File → Run) y hook para el
pipeline de build (M117). Default: `Builds/<OS.get_name()>/LICENCIAS-AUDIO.md`
(raíz del repo, gitignoreada); raíces de audio: `res://assets/audio/`,
`assets/music/`, `assets/sfx/`, `audio/`. Si hay assets sin licencia → `push_error`
(el build debe corregirse antes del release).

### 9. `scripts/legal/test_audio_license_report_m84.gd` — Test headless (nuevo)

`extends SceneTree`. **Simulación determinista documentada** (criterio de cierre del
encargo — el proyecto aún no tiene archivos de audio en disco): crea 4 fixtures
temporales en `user://m84_report_test/` — 3 registrados en el inventario
(`aurora_main.ogg` PROPIA, `ost_piano_01.ogg` CC-BY, `sfx_ambiente_01.wav` CC0) +
**1 inyectado a propósito** (`sfx_no_registrado.wav`) para demostrar el caso
`SIN LICENCIA REGISTRADA`. **13 checks / 0 fallos / EXIT 0** (Godot 4.7.2 headless,
2026-10-11). Limpieza de fixtures al final. Sin regresión: `test_audio_licenses_m84.gd`
re-corrido → EXIT 0 (15 checks).
