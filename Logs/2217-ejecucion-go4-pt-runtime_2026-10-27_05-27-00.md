# Log 2217: Ejecución GO #4 — PT habilitado en runtime (pt.po + 5 parches + QA)

**Fecha:** 2026-10-27
**Hora:** 05:27 (local UTC-3) / 08:27Z
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
GO #4 del fundador (chat 2026-10-27: ~06:40Z "si lo hacemos", 06:48Z "hacelo", 08:19Z "bueno hacelo") ejecutado en producción en UNA vuelta: el portugués pasó de NO ser locale de runtime (ES/EN únicamente) a estar habilitado completo. Plan de 7 pasos aprobado por el director (msg 243) y ratificado por agnes (287/295/297); ensayo general en sandbox 23/23 PASS previo (msg 296); blindaje 7 capas.

## Cambios Realizados
1. **pt.po creado** (`game/isla-ancestral/locales/pt.po`): cp byte a byte del esqueleto QA'd 15/15 — 21.156 B, sha1 `95ee2ce0d1df`, 274 entradas (270 simples + 4 plurales con msgstr[0]+[1] canónicos PT), 61 marcadores `#. no-traducir`, header PT (Language: pt; Plural-Forms nplurals=2; plural=(n > 1)), UTF-8 sin BOM/CR.
2. **localization_manager.gd L15**: `LOCALES_SOPORTADOS ["es","en"] → ["es","en","pt"]`.
3. **localization_manager.gd L357+L359 (K2)**: `_indice_plural` incluye "pt" — sin esto PT mostraba "Oferecendo 2 item" (forma [0] siempre); ahora n>1 usa forma [1] ("Oferecendo 2 itens").
4. **locale_utils.gd L15 (K3)**: TABLAS pt (decimal ",", miles ".", fecha d/m/Y, reloj 24h).
5. **locale_utils.gd L21 (K4)**: NOMBRES_NATIVOS "pt": "Português" — el selector de idioma lo lista.
6. **QA (paso 5)**: réplica fiel de ValidadorPO (validador_po.gd 467L) `validar_par(es.po, pt.po)` sobre los archivos REALES del repo = **OK, 0 errores, 0 avisos**; P1=P2=P3=P5=0; exentas_p5=62; no_traducibles=61. Ejecutor `Temp/ejecutor_go_pt_runtime.py`: **40/40 PASS** (precondiciones duras con aborto limpio → backup §5 → parches en memoria verificados antes de escribir → escritura → QA post + diff controlado difflib: LM exactamente 3 reemplazos L15/L357/L359, LU exactamente 2 inserciones; tabs/BOM/CR verificados; git riel post = exactamente 3 archivos).
7. **Doc M87 (paso 6)**: `DOCUMENTACION/87-Localizacion/plan-actual/` actualizado (04-Codigo sec 8b + nueva 8c; 03-Diseno L489; 05-Checklist L68 evidencia; 02-Analisis L166) + CHECKLIST-GLOBAL fila 87 Notas + este Log + msg 298 al director (paso 7).

## Archivos Modificados/Creados
- **Creado:** `game/isla-ancestral/locales/pt.po`
- **Modificados:** `game/isla-ancestral/scripts/localization/localization_manager.gd` (L15, L357, L359); `game/isla-ancestral/scripts/localization/locale_utils.gd` (L15, L21)
- **INTACTOS (verificado por sha1):** es.po (8e326b00e0f6), en.po (14d379756a2b), strings_pt.json (b208c6bcc00a)
- **Backups §5 (rollback):** `Obsoletos/2026-10-27_05-23-25_localization_manager.gd`, `Obsoletos/2026-10-27_05-23-25_locale_utils.gd`
- **Docs:** DOCUMENTACION/87-Localizacion/plan-actual/{04-Codigo,03-Diseno,05-Checklist,02-Analisis}.md; CHECKLIST-GLOBAL.md fila 87; BACKLOG-MASTER Ling (tarea 59 + ESTADO + anexo); Mensajes canal 298
- **Numeración:** Log 2217 (pool Logs consumido); msg canal 298 (pool canal consumido vía proximo_numero.py --consume)

## Pendiente (honesto)
- Verificación runtime VISUAL en Godot (sin MCP Godot en esta sesión): `obtener_estado_catalogos()` pt ok=true; selector muestra "Português"; plurales PT n=2 → "Oferecendo {n} itens". QA cruzada §21.8 solicitada al director (msg 298) para Hy3/agnes en editor.
- Deuda cruzada saldada: M68 L214 "testear panel y carteles en 3 idiomas — dueño M87" (Reflection-Beam T196-68) — PT ya es locale de runtime.
- No se flippearon ítems de M87 (anti-inflación §21.8.2.b): el GO cierra la deuda PT-runtime escalada (tarea 59 del backlog Ling), no crea ítems nuevos; los 5 [?] de M87 siguen con dueño externo.
