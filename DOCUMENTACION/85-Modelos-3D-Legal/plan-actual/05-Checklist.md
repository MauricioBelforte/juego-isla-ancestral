# Módulo 85: Modelos 3D — Legal — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## A. Estructura Legal de Modelos (15 ítems)

- [ ] Definir Resource ModelLicense con campos: model_name, model_type, license_type, licensor, license_scope, perpetual, commercial_use, attribution_required, attribution_text, redistribution_allowed, modification_allowed, territory, license_document_path, notes
- [ ] Definir enum ModelType: ORIGINAL, STOCK, OPEN_SOURCE, AI_GENERATED, MODIFIED
- [ ] Definir enum LicenseScope: EXCLUSIVE, NON_EXCLUSIVE, SOLE
- [ ] Crear Resource ModelCredit con campos: artist_name, role, contribution, model_list, contract_reference, payment_status
- [ ] Documentar diferencias entre Work-for-Hire y License para modelos
- [ ] Definir regla: modelos core = Work-for-Hire, props secundarios = License
- [ ] Definir regla: modelos de IA siempre con artista humano como autor final
- [ ] Crear template de contrato Work-for-Hire para artistas 3D
- [ ] Crear template de licencia para modelos de stock
- [ ] Crear template de attribution para modelos CC
- [ ] Definir proceso de verificación de licencias pre-import
- [ ] Definir política de uso de modelos editoriales (NO permitidos)
- [ ] Documentar leyes relevantes por territorio
- [ ] Crear checklist de verificación pre-build para modelos
- [ ] Definir proceso de handling de modelos sin licencia

## B. Contratos de Artistas 3D (10 ítems)

- [ ] Template Work-for-Hire con cesión total de PI
- [ ] Cláusula de credito obligatorio en todos los builds
- [ ] Cláusula de pago upfront (flat fee)
- [ ] Cláusula de regalías opcionales para DLC/merchandise
- [ ] Cláusula de confidencialidad
- [ ] Cláusula de garantía de originalidad
- [ ] Cláusula de release de modelos
- [ ] Cláusula de jurisdiction y ley aplicable
- [ ] Template de anexo para especificaciones de entrega
- [ ] Template de acta de entrega y aceptación

## C. Licencias de Stock (10 ítems)

- [ ] Verificar perpetual license (no subscription)
- [ ] Verificar uso comercial permitido
- [ ] Verificar attribution requirements
- [ ] Guardar copia de licencia en repositorio
- [ ] Documentar restricciones de redistribución
- [ ] Verificar si requiere credito en credits
- [ ] Verificar restriction de territorio
- [ ] Verificar restriction de plataforma
- [ ] Crear inventario de todas las librerías de stock
- [ ] Proceso de verificación anual de licencias

## D. Modelos de Código Abierto (10 ítems)

- [ ] Verificar licencia CC (BY, BY-SA, BY-NC)
- [ ] Cumplir con attribution en TODOS los builds
- [ ] Verificar si SA requiere relicenciar el juego
- [ ] Documentar attribution en créditos
- [ ] Verificar si el modelo fue modificado (SA aplica)
- [ ] Crear lista de modelos CC utilizados
- [ ] Verificar que no hay NC en uso comercial
- [ ] Documentar fuente de cada modelo CC
- [ ] Proceso de actualización cuando modelo se actualiza
- [ ] Verificar compatibilidad entre licencias CC

## E. Créditos de Modelos (10 ítems)

- [ ] Crear ModelLegalManager con validate_all_models()
- [ ] Implementar add_license() y add_credit()
- [ ] Implementar generate_credits_text() (formato compacto)
- [ ] Implementar generate_credits_web() (formato detallado)
- [ ] Implementar save_build_credits() para builds
- [ ] Agrupar créditos por rol (3D Artist, Modeler, Sculptor)
- [ ] Incluir modelos específicos por artista
- [ ] Referenciar contrato en cada crédito
- [ ] Incluir estado de pago en cada crédito
- [ ] Generar archivo MODEL_CREDITS.txt en cada build

## F. Modelos de IA Generativa (10 ítems)

- [ ] Definir regla: AI es herramienta, no autor
- [ ] Definir regla: artista humano es autor final
- [ ] Requerir disclosure en créditos de modelos con IA
- [ ] Verificar que la herramienta de IA permita uso comercial
- [ ] Documentar qué herramientas de IA se usaron
- [ ] Guardar logs de generación de modelos por IA
- [ ] Validar que modelos de IA no infringan copyrights
- [ ] Definir proceso de review humano para modelos de IA
- [ ] Incluir advertencia en créditos si aplica
- [ ] Verificar que modelos de IA son originales

## G. Validación y Testing (10 ítems)

- [ ] Test de ModelLicenseValidator con licencia completa
- [ ] Test de ModelLicenseValidator con licencia sin attribution
- [ ] Test de ModelLicenseValidator con licencia no-perpetual
- [ ] Test de ModelLegalManager con inventario vacío
- [ ] Test de ModelLegalManager con inventario completo
- [ ] Test de generación de créditos compactos
- [ ] Test de generación de créditos web
- [ ] Test de verificación de uso comercial
- [ ] Test de edge case: artista con múltiples roles
- [ ] Test de edge case: modelo con múltiples licencias

## H. Integración con Build Pipeline (10 ítems)

- [ ] Agregar paso de validación de modelos en build_script.gd
- [ ] Build falla si hay licencia de modelo inválida
- [ ] Build incluye MODEL_CREDITS.txt automáticamente
- [ ] Integración con M117 (Build Pipeline)
- [ ] Integración con M72 (Validación de Builds)
- [ ] Integración con M71 (Gestión de Assets)
- [ ] Logging de validación de modelos en build log
- [ ] Modo dry-run para verificar sin generar outputs
- [ ] Skip de validación en builds de desarrollo
- [ ] Generar reporte de licencias de modelos por build

## I. Documentación y Mantenimiento (15 ítems)

- [ ] Documentar cada función pública con XML docs
- [ ] Crear guía de uso para el equipo de arte
- [ ] Documentar cómo registrar nuevas licencias
- [ ] Documentar cómo agregar nuevos créditos
- [ ] Crear FAQ de licencias de modelos 3D
- [ ] Tabla de comparación de tipos de licencia
- [ ] Ejemplos de uso de cada nodo
- [ ] Proceso de auditoría de licencias pre-launch
- [ ] Contacto de abogado especializado
- [ ] Registro de cambios del módulo
- [ ] Proceso de actualización de créditos
- [ ] Template de email para solicitar licencias
- [ ] Checklist pre-release de modelos legales
- [ ] Proceso de handling de claims de copyright
- [ ] Documentar casos de uso edge (modelos de dominio público)
