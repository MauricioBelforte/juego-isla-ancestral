# Módulo 84: Música y Audio — Legal — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## A. Estructura Legal de Audio (15 ítems)

- [ ] Definir Resource AudioLicense con todos los campos: audio_name, audio_type, license_type, licensor, license_scope, perpetual, commercial_use, attribution_required, attribution_text, royalty_required, royalty_rate, territory, duration, license_document_path, notes
- [ ] Definir enum AudioType: ORIGINAL_COMPOSITION, STOCK_LIBRARY, AI_GENERATED, SAMPLE, SOUND_DESIGN, VOICE_ACTING
- [ ] Definir enum LicenseScope: EXCLUSIVE, NON_EXCLUSIVE, SOLE
- [ ] Crear Resource AudioCredit con campos: person_name, role, contribution, track_list, contract_reference, payment_status
- [ ] Documentar diferencias entre Work-for-Hire y License Agreement
- [ ] Definir regla: composiciones core = Work-for-Hire, DLC = Licencia con regalías
- [ ] Definir regla: audio de IA siempre con composer humano como autor final
- [ ] Crear template de contrato Work-for-Hire para compositores
- [ ] Crear template de contrato de sesión para músicos
- [ ] Crear template de contrato para voice actors
- [ ] Crear template de licencia para librerías de stock
- [ ] Definir proceso de clearances para muestras musicales
- [ ] Definir política de atribución obligatoria para todos los audios
- [ ] Crear checklist de verificación pre-build para audio
- [ ] Documentar leyes relevantes por territorio (US, EU, LATAM)

## B. Contratos de Compositor (10 ítems)

- [ ] Template Work-for-Hire con cesión total de PI
- [ ] Cláusula de credito obligatorio en todos los builds
- [ ] Cláusula de pago upfront (flat fee)
- [ ] Cláusula de regalías opcionales para secuelas/DLC
- [ ] Cláusula de confidencialidad
- [ ] Cláusula de garantía de originalidad
- [ ] Cláusula de release de grabación
- [ ] Cláusula de jurisdiction y ley aplicable
- [ ] Template de anexo para especificaciones de entrega
- [ ] Template de acta de entrega y aceptación

## C. Contratos de Artistas (10 ítems)

- [ ] Template de contrato de sesión (flat fee)
- [ ] Cláusula de credito obligatorio
- [ ] Cláusula de release de interpretación
- [ ] Cláusula de pago completo al finalizar
- [ ] Cláusula de que no hay regalías en juego base
- [ ] Cláusula de opciones para DLC (renegociación)
- [ ] Cláusula de confidencialidad
- [ ] Template de hoja de sesión (session sheet)
- [ ] Template de firma de release
- [ ] Proceso de verificación de pagamento

## D. Licencias de Stock (10 ítems)

- [ ] Verificar perpetual license (no subscription)
- [ ] Verificar uso comercial permitido
- [ ] Verificar attribution requirements
- [ ] Guardar copia de licencia en repositorio
- [ ] Documentar限制 de uso (ej: no redistribuir el sample)
- [ ] Verificar si requiere credito en credits del juego
- [ ] Verificar si hay restriction de territorio
- [ ] Verificar si hay restriction de plataforma
- [ ] Crear inventario de todas las librerías de stock
- [ ] Proceso de renovación/re-verificación anual

## E. Créditos de Audio (10 ítems)

- [ ] Crear AudioLegalManager con validate_all_audio()
- [ ] Implementar add_license() y add_credit()
- [ ] Implementar generate_game_credits() (formato compacto)
- [ ] Implementar generate_web_credits() (formato detallado)
- [ ] Implementar save_build_credits() para builds
- [ ] Agrupar créditos por rol (Composer, Musician, Sound Designer)
- [ ] Incluir pistas específicas por artista
- [ ] Referenciar contrato en cada crédito
- [ ] Incluir estado de pago en cada crédito
- [ ] Generar archivo AUDIO_CREDITS.txt en cada build

## F. Audio Generado por IA (10 ítems)

- [ ] Definir regla: AI es herramienta, no autor
- [ ] Definir regla: composer humano es autor final
- [ ] Requerir disclosure en créditos de audio con IA
- [ ] Verificar que la herramienta de IA permita uso comercial
- [ ] Documentar qué herramientas de IA se usaron
- [ ] Guardar logs de generación de audio por IA
- [ ] Validar que audio de IA no infrinja copyrights existentes
- [ ] Definir proceso de review humano para audio de IA
- [ ] Incluir advertencia en créditos: "Incluye elementos generados por IA"
- [ ] Verificar compatibilidad con ESRB/PEGI (sin contenido ofensivo)

## G. Validación y Testing (10 ítems)

- [ ] Test de AudioLicenseValidator con licencia completa
- [ ] Test de AudioLicenseValidator con licencia sin attribution
- [ ] Test de AudioLicenseValidator con licencia no-perpetual
- [ ] Test de AudioLegalManager con inventario vacío
- [ ] Test de AudioLegalManager con inventario completo
- [ ] Test de generación de créditos compactos
- [ ] Test de generación de créditos web
- [ ] Test de verificación de uso comercial
- [ ] Test de edge case: artista con múltiples roles
- [ ] Test de edge case: audio con múltiples licencias

## H. Integración con Build Pipeline (10 ítems)

- [ ] Agregar paso de validación de audio en build_script.gd
- [ ] Build falla si hay licencia de audio inválida
- [ ] Build incluye AUDIO_CREDITS.txt automáticamente
- [ ] Integración con M117 (Build Pipeline)
- [ ] Integración con M83 (Licencias de Software)
- [ ] Logging de validación de audio en build log
- [ ] Modo dry-run para verificar sin generar outputs
- [ ] Skip de validación en builds de desarrollo
- [ ] Verificar que todos los audios del build tengan licencia
- [ ] Generar reporte de licencias de audio por build

## I. Documentación y Mantenimiento (15 ítems)

- [ ] Documentar cada función pública con XML docs
- [ ] Crear guía de uso para el equipo de audio
- [ ] Documentar cómo registrar nuevas licencias
- [ ] Documentar cómo agregar nuevos créditos
- [ ] Crear FAQ de licencias de audio en juegos
- [ ] Tabla de comparación de tipos de licencia
- [ ] Ejemplos de uso de cada nodo
- [ ] Proceso de auditoría de licencias pre-launch
- [ ] Contacto de abogado especializado en entertainment law
- [ ] Registro de cambios del módulo
- [ ] Proceso de actualización de créditos
- [ ] Template de email para solicitar clearances
- [ ] Checklist pre-release de audio legal
- [ ] Proceso de handling de claims de copyright
- [ ] Documentar casos de uso edge (audio de dominio público)
