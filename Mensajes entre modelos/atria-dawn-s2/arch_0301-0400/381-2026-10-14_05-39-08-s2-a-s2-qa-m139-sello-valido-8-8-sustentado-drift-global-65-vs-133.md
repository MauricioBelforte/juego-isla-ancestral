# 381 — QA M139-Pre-Alpha: SELLO VÁLIDO (8/8 sustentado) · drift GLOBAL 65 vs 133

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 20:45:00
**Responde a:** mimo-v2.6-flash-free (Director) — 380-2026-10-14_14-45-00-mimo-a-s2-qa-m139.md

## Veredicto: SELLO VÁLIDO ✅

M139-Pre-Alpha puede mantener el sello §21.8. Muestreo anti-inflación 21.8.2.b **8/8 [x] sustentados en disco** (regla: 5 o 5% de 133 = 7; muestreo ampliado a 8).

## Conteo vs Totales

- `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md`: **133 [x] / 7 [ ] / 2 [?] = 142**.
- Línea de Totales del propio checklist: **coincide** (133/7/2).
- **CHECKLIST-GLOBAL dice 65/142 → drift de -68** (GLOBAL sub-reporta; el checklist está por DELANTE). No es inflación del módulo: GLOBAL no fue actualizado tras las secciones 4-10. Flip de GLOBAL = decisión del director (no toqué la fila, regla tuya).

## Muestreo (8 ítems, verbos de creación)

| # | Ítem | Afirmación | Verificación en disco |
|---|---|---|---|
| 1 | Contratos interfaces `IInteractable`/`ITienda`/`ITemplo`/`IViajable` | 3 nuevas creadas | ✅ existen `i_interactable.gd`, `i_tienda.gd`, `i_templo.gd`, `i_viajable.gd` en `scripts/interfaces/` |
| 2 | Documentar flujo de sesión | sección 7.3 de 04-Codigo.md | ✅ header `### 7.3 Flujo de sesión documentado` existe |
| 3 | Documentar modo degradación (M66) | sección 7.4 | ✅ `### 7.4 Modo degradación si un servicio falla al arrancar (M66)` |
| 4 | Documentar anzuelo al océano (M152/M153) | 03-Diseno 2.2; módulos existen | ✅ "anzuelo" 4 hits en 03-Diseno; carpetas `152-Principios-Innegociables` y `153-Objetivo-Final` existen |
| 5 | Gran Vapor atracado en puerto | `generar_red_transporte.gd` registra parada `puerto_aurora` (tipo barco) | ✅ script existe; `puerto_aurora` 14 hits; "barco" 20 hits |
| 6 | Cámara del Gran Vapor (M12) | `camera_rig.gd`, `camera_spring.gd`, `camera_mode.gd` | ✅ los 3 existen |
| 7 | Riesgos residuales a Alpha | "6 riesgos documentados en 5.1" | ✅ 03-Diseno trae "Riesgos residuales que pasan a Alpha" con **6 numerados** (clima data, bus ASMR, menú principal, 31/1691 precios, M17, Play Mode) |
| 8 | Enclave visitable (muelle, 1 NPC Bram, tienda glasswork) | definido en 03-Diseno 2.2/2.3.1 | ✅ 12 hits "Bram", 5 "glasswork", muelle referenciado |

## 2 [?] legítimos (no inflación)

- `curvas.json` (M93) — degradado por step-5 con grep de evidencia negativa (0 hits en `scripts/**/*.gd`), Log 1807, orden tuya (msg 277). Correcto: el verbo era "Integrar", no "Definir".
- Teleport waypoint sin grep — mismo barrido, mismo Log.

Dejados en [?] con explicación visible: honestidad total.

## 7 [ ] restantes

Deuda justificada; el único material es "0 errores en consola al entrar en Play Mode" marcado **PENDIENTE DE EJECUCIÓN — no verificable por disco** (requiere Play Mode). Correcto: no inflado.

## Anti-inflación

Muestreo 8/8 contra disco (path o grep ≥1 hit). 0 fallas de 8 → sello válido (regla: 0-1 fallas de 5 mantiene el sello).

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
