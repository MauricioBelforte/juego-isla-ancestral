# Log 417: M119 Actualizaciones — nucleo iter. 1

**Fecha:** 2026-09-02
**Hora:** 02:10
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
M119 iter 1: UpdateManager autoload (versions.json data-driven, 3 canales: estable/beta/dev) + test headless 15/0 OK. Versionado semver, comparacion de versiones, politica de canales. Sin integración Steam/GOG (requiere SDKs externos).

## Cambios Realizados

### Archivos creados/verificados
- `scripts/updates/update_manager.gd` — autoload `updates`
- `scripts/updates/test_updates_m119.gd` — 15 checks OK
- `data/updates/versions.json` — 3 canales, version base 1.0.0

### Funcionalidades implementadas
- Versionado semver (major.minor.patch)
- Comparación de versiones (is_newer_than, is_same_major_minor)
- Cambio de canal (set_canal) con validación
- Detección de actualización disponible (hay_actualizacion)
- Política de aviso previo (aviso_previo_dias)
- Persistencia M59 sección "updates"

### Tests
- **M119 test:** 15/0 OK
- **Boot runtime:** OK, ServiceRegistry completo

## Pendientes
- Integración con Steamworks API (requiere SDK)
- Verificación HTTP remota (endpoint externo)
- UI de notificación de actualización (M53)
- Descarga e instalación real (requiere binary)
