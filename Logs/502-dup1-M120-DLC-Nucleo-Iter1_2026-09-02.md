# Log 422: M120 DLC y Expansiones — nucleo iter. 1

**Fecha:** 2026-09-02
**Hora:** 02:16
**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

## Resumen
M120 iter 1: DlcManager autoload (manifest data-driven, compatibilidad version, activacion/desactivacion, bundles) + test headless 16/0 OK. Sin integration real con Steam/Itch (requiere SDKs externos).

## Cambios Realizados

### Archivos verificados
- scripts/dlc/dlc_manager.gd — autoload dlc
- scripts/dlc/test_dlc_m120.gd — 16 checks OK
- data/dlc/dlc_manifest.json — 2 DLC, compatibilidad version
- data/dlc/bundles.json — 1 bundle con descuento

### Funcionalidades implementadas
- Carga de manifiesto DLC desde JSON
- Verificacion de compatibilidad con version base (semver)
- Activacion/desactivacion de DLC con persistencia
- Gestion de bundles con descuento porcentual
- Senales: dlc_activado, dlc_desactivado, bundle_comprado

### Tests
- **M120 test:** 16/0 OK
- **Boot runtime:** OK, ServiceRegistry completo

## Pendientes
- Integration con Steamworks API (DLC unlock)
- Integration con Itch.io (key validation)
- UI de tienda de DLC (M53)
- Desbloqueo de contenido por DLC (M17 islas, M26 templos)
