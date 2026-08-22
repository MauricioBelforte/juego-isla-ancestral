# Módulo 84: Música y Audio — Legal — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## A. Estructura Legal de Audio (15 ítems)

- [x] Definir Resource AudioLicense con todos los campos: audio_name, audio_type, license_type, licensor, license_scope, perpetual, commercial_use, attribution_required, attribution_text, royalty_required, royalty_rate, territory, duration, license_document_path, notes
- [x] Definir enum AudioType: ORIGINAL_COMPOSITION, STOCK_LIBRARY, AI_GENERATED, SAMPLE, SOUND_DESIGN, VOICE_ACTING
- [x] Definir enum LicenseScope: EXCLUSIVE, NON_EXCLUSIVE, SOLE
- [x] Crear Resource AudioCredit con campos: person_name, role, contribution, track_list, contract_reference, payment_status
- [x] Documentar diferencias entre Work-for-Hire y License Agreement
- [x] Definir regla: composiciones core = Work-for-Hire, DLC = Licencia con regalías
- [x] Definir regla: audio de IA siempre con composer humano como autor final
- [x] Crear template de contrato Work-for-Hire para compositores
- [x] Crear template de contrato de sesión para músicos
- [x] Crear template de contrato para voice actors
- [x] Crear template de licencia para librerías de stock
- [x] Definir proceso de clearances para muestras musicales
- [x] Definir política de atribución obligatoria para todos los audios
- [x] Crear checklist de verificación pre-build para audio
- [x] Documentar leyes relevantes por territorio (US, EU, LATAM)

## B. Contratos de Compositor (10 ítems)

- [x] Template Work-for-Hire con cesión total de PI
- [x] Cláusula de credito obligatorio en todos los builds
- [x] Cláusula de pago upfront (flat fee)
- [x] Cláusula de regalías opcionales para secuelas/DLC
- [x] Cláusula de confidencialidad
- [x] Cláusula de garantía de originalidad
- [x] Cláusula de release de grabación
- [x] Cláusula de jurisdiction y ley aplicable
- [x] Template de anexo para especificaciones de entrega
- [x] Template de acta de entrega y aceptación

## C. Contratos de Artistas (10 ítems)

- [x] Template de contrato de sesión (flat fee)
- [x] Cláusula de credito obligatorio
- [x] Cláusula de release de interpretación
- [x] Cláusula de pago completo al finalizar
- [x] Cláusula de que no hay regalías en juego base
- [x] Cláusula de opciones para DLC (renegociación)
- [x] Cláusula de confidencialidad
- [x] Template de hoja de sesión (session sheet)
- [x] Template de firma de release
- [x] Proceso de verificación de pagamento

## D. Licencias de Stock (10 ítems)

- [x] Verificar perpetual license (no subscription)
- [x] Verificar uso comercial permitido
- [x] Verificar attribution requirements
- [x] Guardar copia de licencia en repositorio
- [x] Documentar限制 de uso (ej: no redistribuir el sample)
- [x] Verificar si requiere credito en credits del juego
- [x] Verificar si hay restriction de territorio
- [x] Verificar si hay restriction de plataforma
- [x] Crear inventario de todas las librerías de stock
- [x] Proceso de renovación/re-verificación anual

## E. Créditos de Audio (10 ítems)

- [x] Crear AudioLegalManager con validate_all_audio()
- [x] Implementar add_license() y add_credit()
- [x] Implementar generate_game_credits() (formato compacto)
- [x] Implementar generate_web_credits() (formato detallado)
- [x] Implementar save_build_credits() para builds
- [x] Agrupar créditos por rol (Composer, Musician, Sound Designer)
- [x] Incluir pistas específicas por artista
- [x] Referenciar contrato en cada crédito
- [x] Incluir estado de pago en cada crédito
- [x] Generar archivo AUDIO_CREDITS.txt en cada build

## F. Audio Generado por IA (10 ítems)

- [x] Definir regla: AI es herramienta, no autor
- [x] Definir regla: composer humano es autor final
- [x] Requerir disclosure en créditos de audio con IA
- [x] Verificar que la herramienta de IA permita uso comercial
- [x] Documentar qué herramientas de IA se usaron
- [x] Guardar logs de generación de audio por IA
- [x] Validar que audio de IA no infrinja copyrights existentes
- [x] Definir proceso de review humano para audio de IA
- [x] Incluir advertencia en créditos: "Incluye elementos generados por IA"
- [x] Verificar compatibilidad con ESRB/PEGI (sin contenido ofensivo)

## G. Validación y Testing (10 ítems)

- [x] Test de AudioLicenseValidator con licencia completa
- [x] Test de AudioLicenseValidator con licencia sin attribution
- [x] Test de AudioLicenseValidator con licencia no-perpetual
- [x] Test de AudioLegalManager con inventario vacío
- [x] Test de AudioLegalManager con inventario completo
- [x] Test de generación de créditos compactos
- [x] Test de generación de créditos web
- [x] Test de verificación de uso comercial
- [x] Test de edge case: artista con múltiples roles
- [x] Test de edge case: audio con múltiples licencias

## H. Integración con Build Pipeline (10 ítems)

- [x] Agregar paso de validación de audio en build_script.gd
- [x] Build falla si hay licencia de audio inválida
- [x] Build incluye AUDIO_CREDITS.txt automáticamente
- [x] Integración con M117 (Build Pipeline)
- [x] Integración con M83 (Licencias de Software)
- [x] Logging de validación de audio en build log
- [x] Modo dry-run para verificar sin generar outputs
- [x] Skip de validación en builds de desarrollo
- [x] Verificar que todos los audios del build tengan licencia
- [x] Generar reporte de licencias de audio por build

## I. Documentación y Mantenimiento (15 ítems)

- [x] Documentar cada función pública con XML docs
- [x] Crear guía de uso para el equipo de audio
- [x] Documentar cómo registrar nuevas licencias
- [x] Documentar cómo agregar nuevos créditos
- [x] Crear FAQ de licencias de audio en juegos
- [x] Tabla de comparación de tipos de licencia
- [x] Ejemplos de uso de cada nodo
- [x] Proceso de auditoría de licencias pre-launch
- [x] Contacto de abogado especializado en entertainment law
- [x] Registro de cambios del módulo
- [x] Proceso de actualización de créditos
- [x] Template de email para solicitar clearances
- [x] Checklist pre-release de audio legal
- [x] Proceso de handling de claims de copyright
- [x] Documentar casos de uso edge (audio de dominio público)
