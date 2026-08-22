**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 81: Legal — Menores

## Archivos Involucrados

### 1. Archivos Principales (Nuevos - Por Crear)

| Ruta | Descripción | Responsabilidad |
|------|-------------|-----------------|
| `scripts/core/legal/legal_config.gd` | Resource central de configuración legal | Punto único de verdad para configuración legal, edad, consentimiento |
| `scripts/core/legal/age_gate_system.gd` | Sistema de age gating en arranque | Pantalla de age gate, flujo de verificación |
| `scripts/core/legal/parental_consent_service.gd` | Servicio de consentimiento parental | Email verification, ID document, verbal consent |
| `scripts/core/legal/data_sanitizer.gd` | Sanitizador de datos por edad | Anonimización, stripping PII, hashing |
| `scripts/core/legal/iarc_validator.gd` | Validador de rating IARC por build | Verificación rating correcto antes de build |
| `scripts/core/legal/legal_events.gd` | EventBus para eventos legales | Eventos: on_age_group_changed, on_consent_verified, on_age_gate_completed |
| `scripts/core/legal/i_legal_service.gd` | Interfaz pública del servicio legal | Contrato para inyección de dependencias |
| `scripts/ui/age_gate/age_gate_screen.gd` | UI de age gate | Pantalla inicial, opciones visitante/consentimiento |
| `scripts/ui/age_gate/parental_consent_ui.gd` | UI de consentimiento parental | Formularios, validación, estados |
| `scripts/editor/legal/legal_config_validator.gd` | Validador en Editor | Validación CI/CD de configuración legal |

### 2. Archivos Existentes a Modificar

| Ruta | Modificación Requerida |
|------|------------------------|
| `scripts/core/architecture/service_locator.gd` | Registrar `ILegalService` / `LegalConfig` |
| `scripts/core/save/save_system.gd` | Serializar `PlayerAgeData` en save |
| `scripts/core/save/save_data.gd` | Añadir campo `legal_data` al GameState |
| `scripts/core/logging/logger.gd` | Llamar a `DataSanitizer.sanitize_for_logging()` antes de log |
| `scripts/core/analytics/analytics_service.gd` | Llamar a `DataSanitizer.sanitize_for_telemetry()` antes de enviar |
| `scripts/core/crash_reporting/crash_reporter.gd` | Llamar a `DataSanitizer.sanitize_for_crash_report()` antes de enviar |
| `scripts/core/telemetry/telemetry_service.gd` | Llamar a `DataSanitizer.sanitize_for_telemetry()` antes de enviar |
| `scripts/ui/settings/legal_settings_panel.gd` | Añadir panel de configuración legal/edad (si existe) |
| `scripts/core/build/build_script.gd` | Integrar `IARCValidator` como gate pre-build |

### 3. Archivos de Configuración y Datos

| Ruta | Descripción |
|------|-------------|
| `resources/legal/legal_config.tres` | Instancia del Resource LegalConfig (crear en editor) |
| `streaming_assets/legal/privacy_policy_es.txt` | Política de privacidad en español (con sección menores) |
| `streaming_assets/legal/privacy_policy_en.txt` | Política de privacidad en inglés |
| `streaming_assets/legal/terms_of_service_es.txt` | Términos de servicio en español |
| `streaming_assets/legal/terms_of_service_en.txt` | Términos de servicio en inglés |
| `streaming_assets/legal/parental_consent_email_template.html` | Template email verificación parental |

### 4. Funciones Clave por Archivo

#### legal_config.gd
```gdscript
func get_player_age_group(player_id: String) -> AgeGroup
func can_log_event(event_type: String, player_id: String) -> bool
func sanitize_for_telemetry(data: Dictionary, player_id: String) -> Dictionary
func sanitize_for_crash_report(data: Dictionary, player_id: String) -> Dictionary
func sanitize_for_logging(data: Dictionary, player_id: String) -> Dictionary
func is_parental_consent_verified(player_id: String) -> bool
func get_applicable_iarc_rating() -> IARCRating
func update_after_parental_consent(player_id: String, age_group: AgeGroup, consent_method: String) -> void
func set_default_age_group(group: AgeGroup) -> void  # Solo en Editor/Dev
```

#### age_gate_system.gd
```gdscript
func initialize()  # Llamado en bootstrap
func show_age_gate_screen()  # Muestra UI
func process_visitor_mode()  # Jugar sin features online
func start_parental_consent_flow(method: ConsentMethod)  # Inicia flujo
func on_consent_verified(player_id: String, age_group: AgeGroup, method: String)  # Callback éxito
func on_consent_failed(error: String)  # Callback fallo
```

#### parental_consent_service.gd
```gdscript
func request_email_verification(parent_email: String, player_id: String)
func request_id_document_verification(player_id: String, callback: Callable)
func request_verbal_consent(player_id: String, statement_hash: String)
func validate_consent_token(token: String) -> bool  # Verifica token email
```

#### data_sanitizer.gd
```gdscript
func sanitize_for_telemetry(raw_data: Dictionary, player_id: String) -> Dictionary
func sanitize_for_crash_report(raw_data: Dictionary, player_id: String) -> Dictionary
func sanitize_for_logging(raw_data: Dictionary, player_id: String) -> Dictionary
func sanitize_for_analytics(raw_data: Dictionary, player_id: String) -> Dictionary
func _hash_identifier(identifier: String) -> String  # SHA-256 truncado
func _strip_pii(value: Variant) -> Variant  # Recursivo sobre diccionarios
```

#### iarc_validator.gd
```gdscript
func validate_before_build(target: int, config: LegalConfig) -> ValidationResult
func is_rating_compatible_with_content(rating: IARCRating, content_descriptors: PackedStringArray) -> bool
func generate_iarc_submission_data(config: LegalConfig) -> Dictionary  # Para portal IARC
```

### 5. Logs Relacionados

| Log ID | Descripción | Módulo Referencia |
|--------|-------------|-------------------|
| Log 92 | Documentación M96 Plataformas | M96 |
| Log 93 | Documentación M99 Marketing | M99 |
| Log 94 | Documentación M109 Herramientas Internas | M109 |
| Log 95 | Documentación M113 Pruebas De Stress | M113 |
| Log 96 | Documentación M117 Build System | M117 |
| Log 97 | Documentación M123 Modding | M123 |
| Log 98 | Documentación M124 Contenido-Generado-Por-Usuarios | M124 |
| Log 99 | Documentación M144 Despues-Del-Lanzamiento | M144 |
| Log 100 | Documentación M98 Trailer | M98 |
| Log 101 | Documentación M79 Legal-Contratos | M79 |

### 6. Integración con Sistemas Existentes

#### Service Locator Registration (Bootstrap)
```gdscript
# En game_bootstrap.gd o similar
var legal_config = load("res://resources/legal/legal_config.tres")
ServiceLocator.register("legal_config", legal_config)
```

#### Save System Integration
```gdscript
# En save_data.gd
class LegalSaveData:
    var player_age_data: Dictionary = {}  # {player_id: PlayerAgeData}
    var last_iarc_submission: String = ""
    var age_gate_completed: bool = false

# En save_system.gd - guardar()
save_data.legal = legal_config.get_save_data()

# En save_system.gd - cargar()
legal_config.load_save_data(save_data.legal)
```

#### Build Pipeline Integration
```gdscript
# En build_script.gd - pre_build_step()
var legal_config = load("res://resources/legal/legal_config.tres")
var validator = IARCValidator.new()
var result = validator.validate_before_build(build_target, legal_config)
if not result.is_valid:
    push_error("IARC Validation failed: " + str(result.errors))
    return FAILED
```

### 7. Consideraciones de Rendimiento

- **LegalConfig**: Resource → cargado una vez en resources, cacheado en ServiceLocator
- **DataSanitizer**: Métodos estáticos/pure functions → overhead mínimo (hashing SHA-256 solo para menores)
- **AgeGateSystem**: Solo en startup → cero overhead en gameplay
- **ParentalConsentService**: Solo cuando usuario inicia flujo → lazy initialization
- **Memory**: LegalConfig + cache de PlayerAgeData (máx ~100 perfiles = <10KB)

### 8. Tests Requeridos (Plan de Testing - 06-Plan-Testings.md)

| Test | Tipo | Descripción |
|------|------|-------------|
| LegalConfig_GetPlayerAgeGroup_ReturnsCorrectGroup | Unit | Verifica asignación correcta por player_id |
| LegalConfig_CanLogEvent_ReturnsFalseForChildren | Unit | Events bloqueados para <13 sin consent |
| DataSanitizer_SanitizeForTelemetry_RemovesPII | Unit | player_id, session_id removidos para menores |
| DataSanitizer_SanitizeForCrashReport_NoPlayerId | Unit | Crash reports anónimos para menores |
| AgeGateSystem_ShowAgeGateScreen_DisplaysOptions | Integration | UI muestra 3 opciones correctamente |
| ParentalConsentService_EmailVerification_UpdatesConfig | Integration | Email válido → config actualizada |
| IARCValidator_ValidateBeforeBuild_FailsIfNoRating | Integration | Build falla sin rating IARC válido |
| SaveSystem_LegalData_PersistsAcrossSessions | Integration | Age data sobrevive save/load |
| FullFlow_StartupToGameplay_WithMinorAccount | E2E | Arranque completo con cuenta menor |

### 9. Constantes y Enums Compartidos

```gdscript
# res://scripts/core/legal/legal_constants.gd
class_name LegalConstants

const LEGAL_CONFIG_RESOURCE_PATH = "res://resources/legal/legal_config.tres"
const MAX_EVENTS_PER_SESSION_CHILDREN = 50
const MAX_RETENTION_DAYS_CHILDREN = 30
const MAX_RETENTION_DAYS_TEENS = 365
```

### 10. Checklist de Código

Ver `05-Checklist.md` para checklist completo de 110 items (secciones E, H, J contienen ítems específicos de código e integración).