# LOG 2475 - M85: capa de servicio legal de modelos 3D implementada (73→91/100, 18 flips Familia A)

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 (log escrito 2026-11-26 23:15, sesión de trabajo del 25-nov)
**Hora:** 23:15

## Resumen

Séptima tanda del día: M85-Modelos-3D-Legal (fila 🟡 con 25 [ ] Familia A del re-baseline 30oct). Implementé la capa de servicio completa que la auditoría avait degradado como "no existe" (citaron model_legal_manager/model_license/model_credit con 0 hits en disco).

## Cambios Realizados

### Código nuevo (espejo del patrón M84 audio legal, mimo-v2.5)
- `scripts/legal/model_license.gd` (Resource, class_name ModelLicense): licencia por asset — tipo (enum igual a AudioLicense: PROPIA/MIT/CC0/CC-BY/CC-BY-SA/CC-BY-NC/OTRO), origen, perpetuidad/duración, atribución, documento, to_dict/from_dict.
- `scripts/legal/model_credit.gd` (Resource, class_name ModelCredit): persona + ROLES múltiples (modelado/retopologia/rig/animacion/texturizado/supervision) + assets asociados + estado de pago (es_pagado).
- `scripts/legal/model_legal_manager.gd` (Node, NO autoload — igual que AudioLegalManager): carga data/legal/modelos_3d.json, licencias por asset_id en Array (multi-licencia), add_license/add_credit con señales, `validate_all_models()` (CC-BY-NC rechazada, uso comercial, atribución, no-perpetua, documento de terceros, créditos con roles válidos), `generate_credits_text()` compacto, `generate_credits_web()` detallado, `save_build_credits()` → MODEL_CREDITS.txt + _REPORT.txt (crea build/ si no existe), `set_dry_run()`, `set_skip_validation()`, `get_resumen()`.

### QA nueva: `scripts/legal/test_model_legal_m85.gd` — 33 checks / 0 fallos / EXIT 0
Guardian anti-falso-verde (piso 32 medido, _summary en call_deferred propio). Cubre los 10 casos revertidos del checklist: L92 licencia completa, L93 sin atribución, L94 no-perpetua, L95 inventario vacío, L96 inventario completo, L97 créditos compactos, L98 créditos web, L99 uso comercial, L100 multi-roles, L101 multi-licencias — más L66/L67/L68/L69/L70/L112/L113 de API.

### Hallazgo real (no bug de test)
`validate_all_models()` sobre el catálogo REAL detecta 2 huecos documentales: `terrain_textures` (CC0) y `ui_icons` (MIT) son de terceros **sin documento de respaldo** en modelos_3d.json — exactamente la deuda del ítem "inventario de librerías de stock" (L48, KnownIssue del módulo). La validación quedó como detector permanente de ese gap.

### Correcciones durante el desarrollo (honestidad)
- Orden de argumentos de `_check` (msg, cond) — parse error inicial.
- El catálogo real NO valida en 0: sus 2 huecos son el hallazgo (aserción ajustada a "detecta los 2 conocidos").
- build/ no existe en checkout limpio → `DirAccess.make_dir_recursive_absolute` en save_build_credits.

### Regresión (todas EXIT 0)
test_model3d_m85 (original) 8/0 · test_audio_licenses_m84 · test_legal_m78 · test_licenses_m83.

### Documentación
- 18 flips con cita + Totales M85: **91 [x] / 7 [ ] / 2 [?] = 100**.
- Fila 85 GLOBAL: 73/100 → **91/100**. ESTADO-PARALELO + guía 08 (reserva/cierre).
- Nota de numeración: cité inicialmente "Log 2469" (ya consumido por otro agente); corregido a **2475** en los 4 registros.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/legal/model_legal_manager.gd` (NUEVO)
- `game/isla-ancestral/scripts/legal/model_license.gd` (NUEVO)
- `game/isla-ancestral/scripts/legal/model_credit.gd` (NUEVO)
- `game/isla-ancestral/scripts/legal/test_model_legal_m85.gd` (NUEVO, 33 checks)
- `DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/05-Checklist.md` (18 flips + Totales)
- `CHECKLIST-GLOBAL.md` (fila 85: 91/100), `ESTADO-PARALELO.md`, guía 08
- Reporte **045** en mi carpeta

## Pendientes / Deuda (honestidad)
- M85: 7 [ ] de integración cross-módulo (L107/L108-L111/L114: wire en M117 build pipeline, M72 validación de builds, M71 gestión de assets, logging M119) + 2 [?] — requieren GO de esos módulos.
- Los 2 huecos documentales del catálogo (tercero sin documento) necesitan que alguien agregue las rutas de las licencias de terrain_textures/ui_icons.
- QA cruzado §21.8 de las 7 tandas del día pendiente de modelo distinto.

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
