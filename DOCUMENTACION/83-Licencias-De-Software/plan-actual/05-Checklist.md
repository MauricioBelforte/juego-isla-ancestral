# Módulo 83: Licencias de Software — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## A. Inventario de Licencias (15 ítems)

- [ ] Crear Resource LicenseProfile con campos: dependency_name, version, license_type, license_text, license_url, commercial_use, modifications_required, attribution_required, source_offer_required, notes
- [ ] Definir enum LicenseType con todos los tipos: MIT, BSD_2, BSD_3, APACHE_2, GPL_2, GPL_3, LGPL, MPL_2, AGPL, CC0, CC_BY, CC_BY_NC, PROPRIETARY, UNKNOWN, DUAL
- [ ] Implementar función scan_project() que escanea core, addons y dependencias externas
- [ ] Implementar función scan_addon() que lee plugin.cfg y busca LICENSE
- [ ] Implementar función scan_directory() recursiva para buscar archivos de licencia
- [ ] Crear detección automática de archivos LICENSE, LICENSE.txt, LICENSE.md, COPYING, COPYING.txt
- [ ] Implementar clasificador de licencias basado en contenido de texto (_classify_license)
- [ ] Soporte para detección de MIT, Apache 2.0, GPL-2, GPL-3, LGPL, MPL-2, AGPL, BSD-2, BSD-3, CC-BY, CC-BY-NC, CC0
- [ ] Fallback a UNKNOWN cuando la licencia no puede clasificarse
- [ ] Crear inventario persistente (Resource) que almacena resultados del escaneo
- [ ] Cache de resultados de escaneo para evitar re-escaneos innecesarios
- [ ] Función refresh_inventory() para forzar re-escaneo completo
- [ ] Soporte para exclusiones: marcar dependencias que no requieren escaneo
- [ ] Logging de todas las licencias encontradas
- [ ] Exportar inventario a formato JSON para auditoría externa

## B. Validación de Compatibilidad (15 ítems)

- [ ] Crear Resource LicensePolicy con campos: policy_name, allowed_licenses, prohibited_licenses, copyleft_mode, require_attribution, require_source_offer
- [ ] Definir enum CopyleftMode: ALLOW, ISOLATE, DENY
- [ ] Implementar función validate(inventory) que retorna LicenseValidationResult
- [ ] Verificar cada licencia contra lista de prohibidas en policy
- [ ] Verificar cada licencia contra lista de permitidas (si está definida)
- [ ] Detectar incompatibilidades entre licencias del mismo proyecto
- [ ] Verificar obligaciones de atribución (attribution_required)
- [ ] Verificar si alguna licencia requiere source code offer
- [ ] Verificar si alguna licencia prohíbe uso comercial
- [ ] Crear Resource LicenseValidationResult con: errors, warnings, infos
- [ ] Función check_compatibility(license_a, license_b) para verificar compatibilidad entre dos licencias
- [ ] Función requires_source_offer(inventory) que retorna true si GPL/AGPL detectado
- [ ] Reglas de compatibilidad: GPL-3 puede incluir MIT, pero MIT no puede ser relicenciado como GPL-3
- [ ] Soporte para licencias duales (elegir una de dos opciones)
- [ ] Generación de reporte de validación legible por humanos

## C. Generación de Noticias (10 ítems)

- [ ] Implementar generate_notice(inventory) que genera THIRD_PARTY_LICENSES.txt
- [ ] Formato estándar: separadores visuales, metadata completa por dependencia
- [ ] Función save_notices(inventory, output_dir) que guarda archivo principal + copias individuales
- [ ] Crear subdirectorio licenses/ con copies de licencias originales por dependencia
- [ ] Función include_in_build(inventory, build_dir) para builds de distribución
- [ ] Header del archivo con fecha de generación y versión del build
- [ ] Soporte para formato Markdown (.md) y texto plano (.txt)
- [ ] Incluir URL de cada licencia para referencia
- [ ] Numeración secuencial de dependencias en el archivo
- [ ] Cleanup automático de notices obsoletos al regenerar

## D. Integración con Build Pipeline (10 ítems)

- [ ] Agregar paso de licencias en build_script.gd después de validación de builds
- [ ] Build falla si LicenseValidator encuentra errores (licencia prohibida)
- [ ] Build genera warning si licencia no verificada (UNKNOWN)
- [ ] LicenseNoticeGenerator ejecuta después de validación exitosa
- [ ] Notices incluidos automáticamente en cada build de distribución
- [ ] Integración con M72 (Validación de Builds): agregar checks de licencia
- [ ] Integración con M117 (Build Pipeline): flujo completo de licencias
- [ ] Logging de resultados de validación en build log
- [ ] Modo dry-run para verificar licencias sin generar notices
- [ ] Skip de validación de licencias en builds de desarrollo (solo release)

## E. Integración con Gestión de Dependencias (10 ítems)

- [ ] Conexión con M55 (Gestión de Dependencias): leer inventario de dependencias
- [ ] Al detectar dependencia nueva, escanear licencia automáticamente
- [ ] Actualizar LicenseProfile cuando dependencia cambia de versión
- [ ] Sincronizar inventario de licencias con package_manager
- [ ] Soporte para dependencias Git (submodules, subdirectories)
- [ ] Detectar dependencias huérfanas (instaladas pero no referenciadas)
- [ ] Alerta al agregar dependencia con licencia incompatible
- [ ] Verificar licencias de dependencias transitivas
- [ ] Soporte para lock files (godot.lock o equivalente)
- [ ] Generar reporte de dependencias × licencias para revisión

## F. Gestión de Licencias de Assets (10 ítems)

- [ ] Verificar licencias de assets de terceros (modelos, texturas, audio)
- [ ] Asset con licencia NO许可 incompatible con rating del juego → error
- [ ] AssetCreativeCommons con cláusula NC + juego commercial = error
- [ ] Generar attribución de assets en build output
- [ ] Integración con M71 (Gestión de Assets): verificar licencias al importar
- [ ] Alerta al importar asset con licencia no verificada
- [ ] Soporte para assets con múltiples licencias (dual licensing)
- [ ] Tracking de atribución requerida por cada asset
- [ ] Generación de CREDITS.txt complementario a THIRD_PARTY_LICENSES.txt
- [ ] Validación de licencias de assets en exportación a plataformas

## G. Script de Build (10 ítems)

- [ ] Crear build_licenses.py para uso fuera de Godot
- [ ] Script escanea directorio del proyecto y genera notices
- [ ] Soporte para modo verbose (logging detallado)
- [ ] Soporte para modo silencioso (solo errores)
- [ ] Integración con CI/CD pipeline
- [ ] Soporte para output en múltiples formatos (txt, md, json)
- [ ] Filtrado por tipo de licencia (solo mostrar comercial, solo mostrar copyleft)
- [ ] Resumen ejecutivo al final del reporte
- [ ] Verificación de integridad de archivos de licencia
- [ ] Modo compare: detectar cambios desde última ejecución

## H. Testing (10 ítems)

- [ ] Test de escaneo de proyecto vacío (solo Godot core)
- [ ] Test de escaneo con addons con licencia conocida (MIT)
- [ ] Test de escaneo con addon sin archivo de licencia (UNKNOWN)
- [ ] Test de validación con policy permisiva (todo permitido)
- [ ] Test de validación con policy restrictiva (GPL denegado)
- [ ] Test de generación de notices con inventario vacío
- [ ] Test de generación de notices con inventario completo
- [ ] Test de compatibilidad entre licencias conocidas
- [ ] Test de integración con build pipeline (flujo completo)
- [ ] Test de edge case: dependencia circular

## I. Documentación y Mantenimiento (10 ítems)

- [ ] Documentar cada función pública con XML docs
- [ ] Crear guía de uso para el equipo de desarrollo
- [ ] Documentar cómo agregar nuevas licencias al clasificador
- [ ] Documentar cómo personalizar LicensePolicy para cada proyecto
- [ ] FAQ de licencias comunes en juegos Godot
- [ ] Ejemplos de uso de cada nodo del módulo
- [ ] Tabla de compatibilidad de licencias (referencia rápida)
- [ ] Registro de cambios del módulo
- [ ] Procedimiento para auditar licencias periódicamente
- [ ] Contacto de asesoría legal para casos edge
