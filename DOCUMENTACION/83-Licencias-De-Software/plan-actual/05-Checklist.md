# Módulo 83: Licencias de Software — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## A. Inventario de Licencias (15 ítems)

- [x] Crear Resource LicenseProfile con campos: dependency_name, version, license_type, license_text, license_url, commercial_use, modifications_required, attribution_required, source_offer_required, notes
- [x] Definir enum LicenseType con todos los tipos: MIT, BSD_2, BSD_3, APACHE_2, GPL_2, GPL_3, LGPL, MPL_2, AGPL, CC0, CC_BY, CC_BY_NC, PROPRIETARY, UNKNOWN, DUAL
- [x] Implementar función scan_project() que escanea core, addons y dependencias externas
- [x] Implementar función scan_addon() que lee plugin.cfg y busca LICENSE
- [x] Implementar función scan_directory() recursiva para buscar archivos de licencia
- [x] Crear detección automática de archivos LICENSE, LICENSE.txt, LICENSE.md, COPYING, COPYING.txt
- [x] Implementar clasificador de licencias basado en contenido de texto (_classify_license)
- [x] Soporte para detección de MIT, Apache 2.0, GPL-2, GPL-3, LGPL, MPL-2, AGPL, BSD-2, BSD-3, CC-BY, CC-BY-NC, CC0
- [x] Fallback a UNKNOWN cuando la licencia no puede clasificarse
- [x] Crear inventario persistente (Resource) que almacena resultados del escaneo
- [x] Cache de resultados de escaneo para evitar re-escaneos innecesarios
- [x] Función refresh_inventory() para forzar re-escaneo completo
- [x] Soporte para exclusiones: marcar dependencias que no requieren escaneo
- [x] Logging de todas las licencias encontradas
- [x] Exportar inventario a formato JSON para auditoría externa

## B. Validación de Compatibilidad (15 ítems)

- [x] Crear Resource LicensePolicy con campos: policy_name, allowed_licenses, prohibited_licenses, copyleft_mode, require_attribution, require_source_offer
- [x] Definir enum CopyleftMode: ALLOW, ISOLATE, DENY
- [x] Implementar función validate(inventory) que retorna LicenseValidationResult
- [x] Verificar cada licencia contra lista de prohibidas en policy
- [x] Verificar cada licencia contra lista de permitidas (si está definida)
- [x] Detectar incompatibilidades entre licencias del mismo proyecto
- [x] Verificar obligaciones de atribución (attribution_required)
- [x] Verificar si alguna licencia requiere source code offer
- [x] Verificar si alguna licencia prohíbe uso comercial
- [x] Crear Resource LicenseValidationResult con: errors, warnings, infos
- [x] Función check_compatibility(license_a, license_b) para verificar compatibilidad entre dos licencias
- [x] Función requires_source_offer(inventory) que retorna true si GPL/AGPL detectado
- [x] Reglas de compatibilidad: GPL-3 puede incluir MIT, pero MIT no puede ser relicenciado como GPL-3
- [x] Soporte para licencias duales (elegir una de dos opciones)
- [x] Generación de reporte de validación legible por humanos

## C. Generación de Noticias (10 ítems)

- [x] Implementar generate_notice(inventory) que genera THIRD_PARTY_LICENSES.txt
- [x] Formato estándar: separadores visuales, metadata completa por dependencia
- [x] Función save_notices(inventory, output_dir) que guarda archivo principal + copias individuales
- [x] Crear subdirectorio licenses/ con copies de licencias originales por dependencia
- [x] Función include_in_build(inventory, build_dir) para builds de distribución
- [x] Header del archivo con fecha de generación y versión del build
- [x] Soporte para formato Markdown (.md) y texto plano (.txt)
- [x] Incluir URL de cada licencia para referencia
- [x] Numeración secuencial de dependencias en el archivo
- [x] Cleanup automático de notices obsoletos al regenerar

## D. Integración con Build Pipeline (10 ítems)

- [x] Agregar paso de licencias en build_script.gd después de validación de builds
- [x] Build falla si LicenseValidator encuentra errores (licencia prohibida)
- [x] Build genera warning si licencia no verificada (UNKNOWN)
- [x] LicenseNoticeGenerator ejecuta después de validación exitosa
- [x] Notices incluidos automáticamente en cada build de distribución
- [x] Integración con M72 (Validación de Builds): agregar checks de licencia
- [x] Integración con M117 (Build Pipeline): flujo completo de licencias
- [x] Logging de resultados de validación en build log
- [x] Modo dry-run para verificar licencias sin generar notices
- [x] Skip de validación de licencias en builds de desarrollo (solo release)

## E. Integración con Gestión de Dependencias (10 ítems)

- [x] Conexión con M55 (Gestión de Dependencias): leer inventario de dependencias
- [x] Al detectar dependencia nueva, escanear licencia automáticamente
- [x] Actualizar LicenseProfile cuando dependencia cambia de versión
- [x] Sincronizar inventario de licencias con package_manager
- [x] Soporte para dependencias Git (submodules, subdirectories)
- [x] Detectar dependencias huérfanas (instaladas pero no referenciadas)
- [x] Alerta al agregar dependencia con licencia incompatible
- [x] Verificar licencias de dependencias transitivas
- [x] Soporte para lock files (godot.lock o equivalente)
- [x] Generar reporte de dependencias × licencias para revisión

## F. Gestión de Licencias de Assets (10 ítems)

- [x] Verificar licencias de assets de terceros (modelos, texturas, audio)
- [x] Asset con licencia NO许可 incompatible con rating del juego → error
- [x] AssetCreativeCommons con cláusula NC + juego commercial = error
- [x] Generar attribución de assets en build output
- [x] Integración con M71 (Gestión de Assets): verificar licencias al importar
- [x] Alerta al importar asset con licencia no verificada
- [x] Soporte para assets con múltiples licencias (dual licensing)
- [x] Tracking de atribución requerida por cada asset
- [x] Generación de CREDITS.txt complementario a THIRD_PARTY_LICENSES.txt
- [x] Validación de licencias de assets en exportación a plataformas

## G. Script de Build (10 ítems)

- [x] Crear build_licenses.py para uso fuera de Godot
- [x] Script escanea directorio del proyecto y genera notices
- [x] Soporte para modo verbose (logging detallado)
- [x] Soporte para modo silencioso (solo errores)
- [x] Integración con CI/CD pipeline
- [x] Soporte para output en múltiples formatos (txt, md, json)
- [x] Filtrado por tipo de licencia (solo mostrar comercial, solo mostrar copyleft)
- [x] Resumen ejecutivo al final del reporte
- [x] Verificación de integridad de archivos de licencia
- [x] Modo compare: detectar cambios desde última ejecución

## H. Testing (10 ítems)

- [x] Test de escaneo de proyecto vacío (solo Godot core)
- [x] Test de escaneo con addons con licencia conocida (MIT)
- [x] Test de escaneo con addon sin archivo de licencia (UNKNOWN)
- [x] Test de validación con policy permisiva (todo permitido)
- [x] Test de validación con policy restrictiva (GPL denegado)
- [x] Test de generación de notices con inventario vacío
- [x] Test de generación de notices con inventario completo
- [x] Test de compatibilidad entre licencias conocidas
- [x] Test de integración con build pipeline (flujo completo)
- [x] Test de edge case: dependencia circular

## I. Documentación y Mantenimiento (10 ítems)

- [x] Documentar cada función pública con XML docs
- [x] Crear guía de uso para el equipo de desarrollo
- [x] Documentar cómo agregar nuevas licencias al clasificador
- [x] Documentar cómo personalizar LicensePolicy para cada proyecto
- [x] FAQ de licencias comunes en juegos Godot
- [x] Ejemplos de uso de cada nodo del módulo
- [x] Tabla de compatibilidad de licencias (referencia rápida)
- [x] Registro de cambios del módulo
- [x] Procedimiento para auditar licencias periódicamente
- [x] Contacto de asesoría legal para casos edge

**Totales:** 100 ítems · Completados: 100 · Pendientes: 0 · No resueltos: 0.
**Nota:** documentación completa por Nemotron 3 Ultra; ítems verificados y marcados por MiMo V2.5 (OpenCode).
