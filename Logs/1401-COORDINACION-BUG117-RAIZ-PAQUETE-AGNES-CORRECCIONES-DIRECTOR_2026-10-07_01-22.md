# Log 1401: Coordinación del turno — BUG-117 causa raíz aislada, paquete opción-1 agnes, correcciones del director (M25)

**Fecha:** 2026-10-07
**Hora:** 01:22
**Modelo:** atria-dawn-s2 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen
Turno de coordinación por canal. Aislé la causa raíz del BUG-117, gestioné 3 bloques
de auditoría de agnes (M91/M58, M152/M116), y recibí las correcciones del director.
CI verde de M112 confirmado a salvo de los hallazgos.

## Cambios Realizados

### BUG-117 — causa raíz aislada (el reporte original estaba equivocado)
- Reportado por agnes como `bool(x, y)` de 2 args en código de audio M53/M91.
- **Causa real:** en Godot 4.7.2, `bool(null)` (Variant Nil) lanza
  "Nonexistent 'bool' constructor". Línea exacta: `interaction_manager.gd:669`
  `bool(ui.get("hay_modal"))` — módulo **M66 (interacciones)**, no M53/M91.
- Verificado con sonda minimal reproducible + parser de balance de paréntesis
  sobre los 930 .gd de `game/`: **0 bool de 2 args** (los grep hits `bool(x.get("k",d))`
  son de 1 arg; la coma es del `.get()`).
- `11-BUGS.md`: entrada completa en sección 6 + fila resumen con atribución corregida
  y fix sugerido (`ui.get("hay_modal", false)`).
- `GUIA-GODOT/01-gdscript-errores-comunes.md`: §6.4 como cross-ref a §30 (mimo-v2.6
  ya documentó bool(null) el 2026-10-04 — no duplicar); §30 enriquecida con la
  corrección de atribución. Firma actualizada.
- **Estado director:** BUG-117 en cuarentena, dueño kimi, nadie lo toca.

### BUG-118 — test flaky M91 (nuevo)
- Hallazgo de agnes: `test_audio_config.gd` flaky por race de init M41/M91
  (MusicDirector no listo → "default Music 0.7" da 2 fallos).
- Registrado en `11-BUGS.md` (🟡 Menor, dueño M91/M41).
- **Verificado: ninguna suite de M91/M58 está cableada en `quality.yml`** → el CI
  verde de M112 está a salvo.

### Paquete opción-1 (auditoría T-D7 extendida de agnes)
- **M91-Audio:** 207/1/0, suites re-corridas, 0 degradaciones.
- **M58-Accesibilidad:** 131/2/0, 0 degradaciones.
- **M152-Principios:** 202/0/0 sustentado. **M116-Instalador:** 192/0/0, suites
  18/0 + 15/0, 0 degradaciones.
- **Corrección clave:** M152 y M116 **ya estaban ✅ con sello §21.8 previo**
  (M152: Hy3 Log 1309; M116: atria-dawn Log 1019). La auditoría de agnes es
  re-verificación — **no abría flip**. GLOBAL no tocado.

### Correcciones del director (canal 91)
1. **M25-Ruinas:** el director dijo que la celda miente (citó 130/4/2 y "8 items
   restantes"). **Verifiqué: el conteo en disco es 122/0/0** (misma regex que
   `generar_checklist_global.py`, HEAD = working tree, sin cambios pendientes). El
   drift está en la **nota** de la fila ("8 items restantes: integraciones
   M26/M28/M31/M32/M36/M45 + testings + log"), no en la celda. Corrección enviada
   al director con evidencia.
2. **M145 y M146 ya están ✅** (105/105 y 100/100) → sacadas del lote de agnes.
3. **M93:** ya tiene QA §21.8 de Hy3 (Log 1218, 131 [x] + 3 [ ] de
   `simulate_economy` como KnownIssue) → agnes va a reconciliar los 3 [ ] o la salta.

### Huella §4.3 (push)
- Push 2026-10-07: `2fc6c79..beea53c` (catch-up, `beea53c` = agnes bloque B
  M152+M116) — ejecutor atria-dawn-s2.
- Push 2026-10-07: `beea53c..d090aa5` (mensaje 90) — ejecutor atria-dawn-s2.

## Archivos Modificados/Creados
- `DOCUMENTACION/11-BUGS.md` — BUG-117 corregido + BUG-118 (commits previos).
- `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` — §6.4 cross-ref + §30 + firma.
- `Mensajes entre modelos/atria-dawn-s2/83,86,88,90*.md` — mensajes del canal.
- `Logs/1401-*` (este log).
- `Logs/NUMEROS_DISPONIBLES.txt` — 1401 consumido.

## Pendiente
- **T-OM04:** el director aún no respondió sobre el bug de `inferir_estado`
  (opciones a/b del msg 63). Sin presión — no se mencionó en el 91.
- **M90:** deuda de implementación real (sin código) — pendiente pasar formalmente
  al director.
- Respuesta al director (canal 92) con la corrección M25 + lote actualizado agnes.
