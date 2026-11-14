# ERNIE-5.5 RIEL 1 - Blender + Docs (12 tareas)

**Fuente:** agnes-3-flash (fundador: ERNIE se une a la flota 13nov)
**Fecha:** 2026-11-13 06:00
**Nicho:** 3D Blender + analisis visual + documentacion

## Tareas (12)

### Bloque 1: Blender - pendientes restantes (5)
> ✅ CERRADO 2026-11-13 19:08: **los 5 ya existian en disco, 3 LOD cada uno, z_min = +0,045 exacto. 0 trabajo pendiente.**
> La lista nacio del backlog B11 de HY4, ya refutado por el propio HY4 (`11-Backlog-D03-Flips-Evidencia-Positiva.md` L27).
- [x] Columna rota M25: 2 variantes de altura (GLB alta/media/baja) → `25-Ruinas-Templos_columna_rota_alta/_baja`, 1,45×1,02×2,15 m y 1,45×1,02×1,45 m
- [x] Palanca de puzzle: interactuable, low-poly → `70-Interacciones_palanca_madera`, 1,20×0,34×0,57 m
- [x] Semillero brotando (etapa 1): M35 → `33-Agricultura_cultivo_brote` (×3 LOD + `.blend` + 6 capturas), 0,28×0,28×0,15 m
- [x] Mansion 14x10 m: revisar lo que ERNIE ya hizo (logs 2403-2405/2407) + completar si falta → `18-Casas_casa_mansion` 14,34×10,94×4,95 m
- [x] Casa vecino cozy: M19 RF12 (revisar estado actual) → `18-Casas_casa_vecino` 7,60×7,10×3,52 m

### Bloque 2: Analisis visual + docs (4)
- [x] Verificar los GLB en assets/3d (escala/normales/pivotes) — SONdeo batch 2026-11-13 (msg 003 + corrección 004).
      **Dato corregido: son 490 GLB, no 167.** Escala 0/490 fuera de rango (0,208–16,3 m); normales 0/490 no unitarias;
      pivotes 442/490 (90,2 %) cumplen `Z_APOYO=0.045 ±0,020`. Solo 5 assets reales a fixear (perla, globo, roca_pedernal, roca_comun, conejo).
- [x] Revisar AGENTS.md: seccion 24 sigue diciendo Unity/C# -> **APLICADO 2026-11-13 19:58** (msg 008 §1.a).
      183 lineas: §18 → `GameLogger` (`res://scripts/logging/logger.gd`, `user://logs/game.log`, rotacion 10 MB/5 files);
      §22 → `godot --headless --export-release`, `export_presets.cfg`, `build/[plataforma]/`;
      §24 → Godot 4.7 Forward Plus, GDScript, arbol real, GdUnit4; + §9/§14/§15/§23 sueltos.
      Respaldo: `Obsoletos/2026-11-13_19-52-31_AGENTS.md`. Verificado: 0 Unity/C# restantes salvo 3 menciones intencionales (1181, 1213, 1227).
- [x] Verificar que GUIA-COMPARATIVA-MODELOS-V1.md refleje los modelos nuevos — **HECHO 2026-11-13 19:58** (msg 008 §1.b):
      ERNIE "en prueba — supervisado por Nemotron" → "en flota (2026-11-13)"; seccion nueva "Verificado en ejecucion"
      (limitacion de vision + 490 GLB, 0/490 escala, 0/490 normales, 442/490 Z_APOYO); regla de uso #6 actualizada.
- [x] Identificar 5 modulos con drift de Totales mas severo en 05-Checklist — 2026-11-13 (msg 003 §4):
      74-Eventos (+58), 71-Progresion (+44), 27-Islas-Del-Mundo (+37), 63-Cargas-Y-Streaming (−26), 25-Ruinas (−16).
      + 2 `✅` sin DoD: 73-Coleccionables (56 [?] + 3 [ ]) y 75-Postgame (87 [?]).

### Bloque 3: M18/M45 avance (3)
- [x] M18: verificar que las casas ya construidas no tengan solapes (log 2404 dice 'Sin Solapes') — **VERIFICADO EN DISCO 2026-11-13 20:10** (msg 010 §1), con 3 hallazgos:
      (1) conteo de ventanas: **disco 65** (Agricultor 14, Mercader 12, Casona **19**, Mansion 20) vs desglose del log 2408 = **64** vs titular **68** → tres numeros distintos, el 68 no se sostiene;
      (2) **"0 solapes AABB" NO reproducible**: mi barrido da 122k-441k pares por casa (7k-68k filtrando mobiliario) por AABB de piezas planas (alfombras) — es la trampa E-24. Ni confirmo ni desmiento: **falta el script del 2408** (`18-Casas/scripts/auditar_mobiliario.py` o `scripts-prueba/`); sin artefacto el QA no es auditable;
      (3) **faltan los GLB de Agricultor y Mercader** (solo casona/mansion/vecino exportados) → bloqueo real de M18 en Godot. Es exportar, no medir.
- [ ] M45: revisar artbook_specs_m47.md por consistencia con assets reales — 🔴 **BLOQUEADO**: 62/221 lineas (28 %) con mojibake cp1252.
      `fix_encoding.py --dry-run` corrido: reporta ~20 mensajes irrecuperables + varios parciales. **Requiere OK del dueno para aplicar** (corre sobre todo el repo, con backup en `Obsoletos/`).
      Barrido propio: 8+ `03-Diseno.md` afectados (top: 110-Debug-Menu 83 lineas, 01-Fundamentos 58, 92-Tutorial 43).
- [x] M18: agregar ventanas/chimeneas si faltan en casas existentes (log 2407) — **ya cubierto por el log 2408** (68 huecos Boolean declarados; disco: 65 vidrios reales, 21 chimeneas). Resta exportar GLB de Agricultor/Mercader.

> ⚠️ **Autocorreccion 2026-11-13 20:10:** el msg 008 citaba bytes corruptos del artbook como ejemplo; el detector `fix_encoding.py` lo marco (`mojibake parcial`). **Citar mojibake lo re-siembra.** 008 quedo saneado (0 caracteres corruptos, verificado). Regla: describir el mojibake, no reproducirlo.

**Total: 12. Prioridad: Bloque 1 (assets pendientes) -> Bloque 2 (docs) -> Bloque 3 (verificacion).**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code - 2026-11-13 06:00
