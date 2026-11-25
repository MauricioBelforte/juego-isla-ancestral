# LOG 2449 - M56 tanda GLM-5.3-Flash: L95/L97 verificados + L275/L286 implementados (130→134/138) + revisión censo b01

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25
**Hora:** 10:53

## Resumen

Segunda tanda de la reintegración: M56-Fotografía (módulo 🟢, reclamo §21.3) — 4 ítems cerrados (130 → 134/138). Además, revisión acotada read-only del censo b01 de GPT-6-Luna (solicitada por mensaje peer, respondida con rutas/líneas).

## Cambios Realizados

### M56-Fotografia (tanda 4 ítems)
1. **L95 "NPC posa 0.5 s con animación M48 sin bugs"** — verificado: ya en disco (`scripts/ia_npc/npc_agent.gd::pose_foto_en(0.5)`: AnimationPlayer "pose_foto" contrato M48/M44, congela IA/necesidades, placeholder headless-safe; receptor conectado en NPCManager). Flip con check nombrado.
2. **L97 "Retardo de 0.8 s entre pose y captura (evitar tween)"** — verificado: ya en disco (`photo_service.gd::posar()` espera `create_timer(0.8)`, sin Tween, luego `tomar_foto()`). Flip con check nombrado.
3. **L275 "Ofrecer subtítulos en notificaciones"** — implementación REAL (dos flips previos por spec-only fueron revertidos correctamente): `notification_service.gd` — `push()` acepta clave opcional "subtitle"; `_spawn_node` renderiza segunda línea (Label "Subtitle", 12 px, alpha 0.8) bajo el texto principal.
4. **L286 "Añadir guía de horizonte opcional"** — implementación REAL: `photo_service.gd` — `set_guia_horizonte()`/`guia_horizonte()` + overlay perezoso (CanvasLayer capa 90 + ColorRect línea horizontal centrada 2 px, alpha 0.35, mouse ignore); visible SOLO en modo foto con guía activa; se oculta al salir (preferencia persiste).

### Verificación (§12/§14)
- `scripts/foto/qa_m56_photopose.gd` (headless godot472): **16 checks / 0 fallos / EXIT 0** (8 nuevos).
- Regresión: `test_photomode` 0 fallos; `test_photo_service_headless` 10/0; `qa_m56_presets` 11/0.
- `validate_photo` reporta 2 FALLOS **preexistentes** (presets niebla_costera/pintura_retro declaran filtros/color_grading que M49 aún no implementa; mis cambios no tocan presets — verificado por `git diff`).

### Documentación de conteos
- Línea Totales interna del 05 de M56 estaba **stale** (decía 26/109/2; la fila GLOBAL ya decía 130/138): corregida a 134/3/1 = 138, con nota del recontado.
- Fila 56 del GLOBAL: 🔵 → 🟡 Liberado (134/138) con nota de la tanda.

### Revisión censo b01 (GPT-6-Luna, read-only)
- Veredicto entregado por mensaje peer + respuesta de guardado en su canal: conteo defendible (mi recuento estricto 22822/871/813 = 24506 vs censo 24507, delta ≤3); filas duplicadas del GLOBAL CONFIRMADAS reales (115 L52/53, 127 L66/67, 139 L81/83, 148 L93/94, 48 L151/152); 49-Iluminacion = drift real +8 (fila stale); 94 = discrepancia definicional (Patrón D duplicados); 169-Crucero = el censo está BIEN (ítem numerado real L248 que el contador de filas no ve).
- Los 5 duplicados del GLOBAL quedan para saneo de la directora (solo reportados, sin tocar).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/foto/photo_service.gd` (+42: guia de horizonte)
- `game/isla-ancestral/scripts/ui/services/notification_service.gd` (+24: subtitle)
- `game/isla-ancestral/scripts/foto/qa_m56_photopose.gd` (+50: 8 checks)
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md` (4 flips + Totales corregido + reserva/cierre)
- `CHECKLIST-GLOBAL.md` (fila 56), `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`
- `Mensajes entre modelos/agnes-3-flash/994-*` (reporte), `Mensajes entre modelos/GPT-6-Luna/002-*` (rúbrica), `Mensajes entre modelos/MiniMax-M3.1-Flash/068-*` (cierre M20 + consulta)

## Pendientes / Deuda (honestidad)
- Los 3 [ ] de M56 (L112 bestiario M36/M37, L135 filtros en frame capturado, L161 texturas galería) y el [?] (L341, dueño deepseek-v4-flash-vision-exp) no se tocaron.
- validate_photo 2 fallos preexistentes → deuda de L135 (dueño: quien implemente filtros M49).
- 5 filas duplicadas del GLOBAL (115/127/139/148/48) → saneo de la directora.
- QA cruzado §21.8 de ambas tandas (M20 y M56) pendiente de modelo distinto.

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
