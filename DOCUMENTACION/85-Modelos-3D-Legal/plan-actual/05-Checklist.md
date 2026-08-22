# Módulo 85: Modelos 3D — Legal — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## A. Estructura Legal de Modelos (15 ítems)

- [x] Definir Resource ModelLicense con campos: model_name, model_type, license_type, licensor, license_scope, perpetual, commercial_use, attribution_required, attribution_text, redistribution_allowed, modification_allowed, territory, license_document_path, notes
- [x] Definir enum ModelType: ORIGINAL, STOCK, OPEN_SOURCE, AI_GENERATED, MODIFIED
- [x] Definir enum LicenseScope: EXCLUSIVE, NON_EXCLUSIVE, SOLE
- [x] Crear Resource ModelCredit con campos: artist_name, role, contribution, model_list, contract_reference, payment_status
- [x] Documentar diferencias entre Work-for-Hire y License para modelos
- [x] Definir regla: modelos core = Work-for-Hire, props secundarios = License
- [x] Definir regla: modelos de IA siempre con artista humano como autor final
- [x] Crear template de contrato Work-for-Hire para artistas 3D
- [x] Crear template de licencia para modelos de stock
- [x] Crear template de attribution para modelos CC
- [x] Definir proceso de verificación de licencias pre-import
- [x] Definir política de uso de modelos editoriales (NO permitidos)
- [x] Documentar leyes relevantes por territorio
- [x] Crear checklist de verificación pre-build para modelos
- [x] Definir proceso de handling de modelos sin licencia

## B. Contratos de Artistas 3D (10 ítems)

- [x] Template Work-for-Hire con cesión total de PI
- [x] Cláusula de credito obligatorio en todos los builds
- [x] Cláusula de pago upfront (flat fee)
- [x] Cláusula de regalías opcionales para DLC/merchandise
- [x] Cláusula de confidencialidad
- [x] Cláusula de garantía de originalidad
- [x] Cláusula de release de modelos
- [x] Cláusula de jurisdiction y ley aplicable
- [x] Template de anexo para especificaciones de entrega
- [x] Template de acta de entrega y aceptación

## C. Licencias de Stock (10 ítems)

- [x] Verificar perpetual license (no subscription)
- [x] Verificar uso comercial permitido
- [x] Verificar attribution requirements
- [x] Guardar copia de licencia en repositorio
- [x] Documentar restricciones de redistribución
- [x] Verificar si requiere credito en credits
- [x] Verificar restriction de territorio
- [x] Verificar restriction de plataforma
- [x] Crear inventario de todas las librerías de stock
- [x] Proceso de verificación anual de licencias

## D. Modelos de Código Abierto (10 ítems)

- [x] Verificar licencia CC (BY, BY-SA, BY-NC)
- [x] Cumplir con attribution en TODOS los builds
- [x] Verificar si SA requiere relicenciar el juego
- [x] Documentar attribution en créditos
- [x] Verificar si el modelo fue modificado (SA aplica)
- [x] Crear lista de modelos CC utilizados
- [x] Verificar que no hay NC en uso comercial
- [x] Documentar fuente de cada modelo CC
- [x] Proceso de actualización cuando modelo se actualiza
- [x] Verificar compatibilidad entre licencias CC

## E. Créditos de Modelos (10 ítems)

- [x] Crear ModelLegalManager con validate_all_models()
- [x] Implementar add_license() y add_credit()
- [x] Implementar generate_credits_text() (formato compacto)
- [x] Implementar generate_credits_web() (formato detallado)
- [x] Implementar save_build_credits() para builds
- [x] Agrupar créditos por rol (3D Artist, Modeler, Sculptor)
- [x] Incluir modelos específicos por artista
- [x] Referenciar contrato en cada crédito
- [x] Incluir estado de pago en cada crédito
- [x] Generar archivo MODEL_CREDITS.txt en cada build

## F. Modelos de IA Generativa (10 ítems)

- [x] Definir regla: AI es herramienta, no autor
- [x] Definir regla: artista humano es autor final
- [x] Requerir disclosure en créditos de modelos con IA
- [x] Verificar que la herramienta de IA permita uso comercial
- [x] Documentar qué herramientas de IA se usaron
- [x] Guardar logs de generación de modelos por IA
- [x] Validar que modelos de IA no infringan copyrights
- [x] Definir proceso de review humano para modelos de IA
- [x] Incluir advertencia en créditos si aplica
- [x] Verificar que modelos de IA son originales

## G. Validación y Testing (10 ítems)

- [x] Test de ModelLicenseValidator con licencia completa
- [x] Test de ModelLicenseValidator con licencia sin attribution
- [x] Test de ModelLicenseValidator con licencia no-perpetual
- [x] Test de ModelLegalManager con inventario vacío
- [x] Test de ModelLegalManager con inventario completo
- [x] Test de generación de créditos compactos
- [x] Test de generación de créditos web
- [x] Test de verificación de uso comercial
- [x] Test de edge case: artista con múltiples roles
- [x] Test de edge case: modelo con múltiples licencias

## H. Integración con Build Pipeline (10 ítems)

- [x] Agregar paso de validación de modelos en build_script.gd
- [x] Build falla si hay licencia de modelo inválida
- [x] Build incluye MODEL_CREDITS.txt automáticamente
- [x] Integración con M117 (Build Pipeline)
- [x] Integración con M72 (Validación de Builds)
- [x] Integración con M71 (Gestión de Assets)
- [x] Logging de validación de modelos en build log
- [x] Modo dry-run para verificar sin generar outputs
- [x] Skip de validación en builds de desarrollo
- [x] Generar reporte de licencias de modelos por build

## I. Documentación y Mantenimiento (15 ítems)

- [x] Documentar cada función pública con XML docs
- [x] Crear guía de uso para el equipo de arte
- [x] Documentar cómo registrar nuevas licencias
- [x] Documentar cómo agregar nuevos créditos
- [x] Crear FAQ de licencias de modelos 3D
- [x] Tabla de comparación de tipos de licencia
- [x] Ejemplos de uso de cada nodo
- [x] Proceso de auditoría de licencias pre-launch
- [x] Contacto de abogado especializado
- [x] Registro de cambios del módulo
- [x] Proceso de actualización de créditos
- [x] Template de email para solicitar licencias
- [x] Checklist pre-release de modelos legales
- [x] Proceso de handling de claims de copyright
- [x] Documentar casos de uso edge (modelos de dominio público)
