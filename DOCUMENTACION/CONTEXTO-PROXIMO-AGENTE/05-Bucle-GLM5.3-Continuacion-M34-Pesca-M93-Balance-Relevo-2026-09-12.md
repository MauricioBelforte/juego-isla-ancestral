# 05-Bucle-GLM5.3-Continuacion-M34-Pesca-M93-Balance-Relevo-2026-09-12

## Fecha
2026-09-12 (sesión de continuación 4, 2 ciclos: ~02:00 → ~04:30)

## Identidad del agente que escribió esto

**Modelo:** GLM-5.3 (flagship de Z.ai, 743B, **NO la variante flash**)
**Plataforma:** Kilo Code
**Firma definida por el usuario:** "GLM-5.3 / Kilo Code" — con ese nombre firmá todo.

⚠️ **CRÍTICO para vos (próximo agente):** si sos GLM-5.3 flagship en Kilo Code, continuás ESTA línea con ESTE backlog (`DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3/BACKLOG-MASTER.md`, actualizado 2026-09-12 ~04:30). Si sos OTRO modelo, NO tomes estos módulos — usá tu propio backlog.

## Contexto de la sesión anterior (leer los 4 previos: 01, 02, 03, 04)

- `01-...` — creación del backlog propio, perfil de capacidades, **límite solo-texto verificado** (QA numérico SIEMPRE).
- `02-...` — 4 ciclos (M15 iter 5, M38 iter 5+5b COMPLETADO 163/163, M29 iter 1 194/195). 18 lecciones.
- `03-...` — 3 ciclos (M30 iter 4 fix C56 29/29 Log 845, M31 iter 3 115/169 Log 829, M32 iter 2 96/121 Log 830). Lecciones 19-25 (uid_cache, backticks PS, colisión 827).
- `04-...` — archivo de relevo escrito al cierre por pedido del usuario: reconocimiento M34 ya hecho, plan M93 relevo. ESTA sesión ejecutó ese plan.

## TU MISIÓN (directiva del usuario en esta sesión)

1. **M34-Pesca** (144 pend) — CUMPLIDA: iter. 2 cerrada, Log 833.
2. **M93-Balance** (64 pend) — CUMPLIDA: iter. 4 por relevo §21.4.7 cerrada, Log 836.
3. Al cerrar: escribir este archivo 05 + actualizar BACKLOG-MASTER. — CUMPLIDO.

| # | Módulo | Iteración | Log | Resultado |
|---|--------|-----------|-----|-----------|
| 1 | M34-Pesca | iter. 2 | 833 | ✅ CERRADA — auditoría 4→84 [x] + 3 brechas V0 (bug crítico estaciones, horas, PRNG M29) + 69 [?] con dueño |
| 2 | M93-Balance | iter. 4 (relevo) | 836 | ✅ CERRADA — iter. 3 fantasma asimilada + auditoría 66→112 [x] + 5 brechas data + versión 1.2.0 |

## ⚠️ Estado de colisiones AL MOMENTO de escribir esto (2026-09-12 ~04:30)

- **ULTIMO_NUMERO.txt = 836** (yo lo dejé ahí; sin BOM — el archivo tenía BOM de otra sesión y lo saneé al escribir 836).
- **WorkBuddy (DeepSeek-V4.1-Flash) SIGUIÓ ACTIVO:** escribió 831-M27 (23:05), 832-HY3-M09-REGRESSION, 834-HY3-M10-QA-CRUZADO, 835-HY3-M11-QA-CRUZADO (23:28). **Su reserva `Logs/reservas/835-HY3-M11.txt` sigue SIN BORRAR** (su log 835 ya existe) — es residuo inofensivo de SU lado, NO la toques ni la cuentes como bloqueo activo. El próximo número libre es **837** (verificalo con el bucle §6.1.a igual — WorkBuddy puede escribir en cualquier momento; escribió logs 834/835 SIN pasar por el contador: ULTIMO_NUMERO decía 835 pero él nunca lo actualizó de 830 por su cuenta — yo actualicé 832→833→836 con mis reservas; SIEMPRE verificar archivo+reserva+contador antes de reservar).
- **QA cruzado §21.8 en marcha por Hy3 (WorkBuddy):** hizo QA de M10 y M11 (logs 834/835). Los QA pendientes DE MI LÍNEA (M38/M29/M30/M31/M32/M34/M93) siguen esperando que el usuario le abra sesión a Hy3.

## CICLO 1: M34-Pesca iter. 2 (Log 833) — CERRADA ✅ 84/153

### Qué se hizo (resumen ejecutivo — detalle en Log 833 y 04-Codigo M34)

1. **Auditoría doc↔código (patrón M29/M31/M32):** 05-Checklist 4 → **84 [x] / 69 [?] / 0 [ ]** con evidencia por ítem. El 04-Codigo ganó §0 con rutas/firmas REALES (las §1/§2 eran aspiracionales del diseño).
2. **3 brechas V0 cerradas con tests:**
   - **Bug crítico `temporadas: ["todas"]`:** `_estacion_numero("todas")` → -1 → `estaciones=[-1]` NUNCA matcheaba estación real → TODOS los peces "todas" caían SIEMPRE al fallback (filtro de estación ROTO; cozy de accidente). Fix: "todas" → estaciones VACÍAS (contrato FishDefinition L14).
   - **Bug `horas` 2 valores:** solo se usaba la primera hora ([4,20] perdía la 20). Fix: cada hora mapea a su franja sin dupes.
   - **PRNG:** `hash(Time.get_ticks_usec())` → `GameTime.rng_diario("m34")` (semilla de partida M29 H120). Fallback semilla 0.
3. **Extracción `_candidatas_de_estacion(estacion, hora)`:** filtro testeable (patrón `_peso_efectivo` Log 310).
4. **Tests:** test_fishing 0 fallos (4 bloques nuevos) + test_fishing_clima 0 + 4 regresiones 0 (M29 semilla 25/25, M29 consumidores 12/0, M72 logros 0, M32 clima 0).

### Hallazgos de datos M93 críticos para el relevo (los usé en el ciclo 2)

- **fishing.json tiene SOLO 2 peces** (sardina + luna), 0 cebos, 0 cañas — el data M93 estaba incompleto de nacimiento (el núcleo M34 se escribió contra 2 peces de prueba). `precio_compra` se carga y se descarta (FishDefinition no tiene campo).
- La auditoría M34 dejó 69 [?] con dueño: M51 (voxels), M52 (VFX/flotador), M53 (UI), M42 (audio), M93 (data), M14 (item pez), M15 (recetas), M105 (telemetría), M57 (accesibilidad), M37 (catálogo).

### ⚠️ Corrección al archivo 04 que me pasó el contexto

El archivo 04 decía que `_franja_de_hora(4)` = ALBA. **ERROR:** es **NOCHE** (`hora < 5` → NOCHE; ALBA solo 5-6; ATARDECER 17-20). Mi primer test falló 4 veces por confiar en esa nota — lo corregí en el test y lo documenté en 04-Codigo M34 (Recomendaciones). **Verificá siempre el código, no las notas de contexto.**

## CICLO 2: M93-Balance iter. 4 por relevo §21.4.7 (Log 836) — CERRADA ✅ 112/134

### El relevo (proceso verificado)

- Reserva de glm-5.3-flash del 2026-09-01 (iter. 3: tablas friendship/quests/puzzles/unlocks/meta-rareza) **sin log ni liberación por 11 días**. Re-verifiqué ANTES de reclamar: sin logs M93 nuevos (último: 333 del 2026-09-01), sin reserva activa, CHECKLIST-GLOBAL 2026-08-30. Relevo legítimo.

### Hallazgo central: la iter. 3 "perdida" SÍ aterrizó

**El trabajo de flash EXISTE en disco sin log:** tablas v2 (friendship con generosidad ×3 y umbrales verificados contra M20 REAL, quests con regla 5-15%, puzzles 20/45 min, unlocks orden_global, meta rareza/pity/rendimiento/viajes) + `test_balance_m93_iter3.gd` (6 bloques, 0 fallos). ~20 ítems del checklist ya estaban cubiertos sin marcar. **Lección: "sin log" ≠ "sin trabajo" — verificar DISCO, no logs, al reclamar un relevo.**

### Qué se hizo

1. **Auditoría 64 [ ]:** 66 → **112 [x] / 22 [?] / 0 [ ]**. Cierres por gap con evidencia (H, P.2-P.4, X.1/X.3, W.3/W.5, Q.2/Q.3 por grep REAL: crafting_service L67-69 y farm_service L67-69 consumen /root/Balance; Q.4: M34 lee fishing.json directo; Z.1-Z.4 coordinaciones con evidencia de consumidores).
2. **5 brechas V0 de DATA** (evolución de 4 tablas + tests):
   - mining.json v2: `golpes_para_extraer` + `reglas_minado` (D.4).
   - progression.json v2: `curvas_recursos_acumulados` + `curva_amistad_total` + `curva_colecciones` + `reglas_curvas.no_exponencial` (L.2-L.5).
   - meta.json v3: `reglas_anti_grind` (5 reglas M) + `reglas_anti_exploit` (5 reglas N: 3 bucles con contramedidas, techo 115%, reloj C56, límite 20 ventas/día/categoría).
   - timing.json v2: `rutinas` (rutina 30 min, sesión libre [60,120], cultivos_sin_muerte, estaciones_rotativas) (K.1-K.5).
   - balance_version 1.1.0 → **1.2.0** (U.3) + test iter3 desacoplado del bump (ahora >=1.1.0 semántico).
3. **Test nuevo `test_balance_m93_iter4.gd`:** 7 bloques, **0 fallos** (incluye verificación MATEMÁTICA de curvas no exponenciales: pendientes por tramo decrecientes).
4. **Regresión total:** 10 suites 0 fallos (M93 ×4, M16 ×2, M33 ×2, M35, M34 del ciclo 1).

### La brecha grande restante (para el próximo agente de M93)

**Simulación económica (O.1-O.3 + X.5):** `simulate_economy.gd` NO existe (figuraba en el §1 del 04-Codigo como aspiracional). Con TODO el input ya listo (curvas, topes, reglas, techo 115%), la **iter. 5 natural de M93** = simulador con 3 perfiles (rutinario/diligente/minimalista) × 60/180/365 días + completar el catálogo de pesca (25 peces/4 cebos/3 cañas — el simulador del pipeline pescar+vender necesita el catálogo real). Ver "Decisiones" en Log 836.

## Saneamiento de infraestructura de esta sesión (§28) — IMPORTANTE para todos

1. **CHECKLIST-GLOBAL.md tenía 810 runs de mojibake REAL** (doble codificación UTF-8→cp1252→UTF-8: emojis del protocolo como `🟡`, acentos como `nÃºcleo` en 40+ filas — escritura de otro agente con codificación rota). Lo saneé completo con script nuevo reutilizable:
   - **`scripts/saneamiento_utf8.py`** (NUEVO): selectivo (solo runs no-ASCII que decodifican limpio vía cp1252), con `--dry-run`/`--backup`, safe (aborta si el run no es reversible). Backup: `CHECKLIST-GLOBAL.md.bak_2026-09-11_23-21-57`.
2. **4 BOM UTF-8 eliminados** de .gd: achievement_service, player_profile, progression_manager (preexistentes de otra sesión, detectados por git diff) + fishing_manager.gd (mío — la edit tool a veces lo introduce; byte-scan SIEMPRE).
3. **Bug preexistente documentado (NO mío, NO tocado):** 10 push_error `[VAL-DGV] ... clave de mundo desconocida 'new_level'` en test_logros — `data/dialogues/reaccion_nivel.json` (M22/M71) usa clave que el validador de diálogos no reconoce. Registrar en 11-BUGS.md si lo toma otro agente.

## Lecciones NUEVAS de esta sesión (suman a las 25 del archivo 03)

26. **"Sin log" ≠ "sin trabajo":** al reclamar un relevo §21.4.7, verificar DISCO (tablas, tests, scripts) además de logs — la iter. 3 fantasma de M93 estaba materializada completa. La ausencia de log solo significa ausencia de TRAZABILIDAD.
27. **PowerShell ConvertFrom-Json reporta mal JSON con TABs** (falso "Primitivo JSON no válido"): el `}` extra del progression.json SOLO lo detectó el parser REAL de Godot ("Expected 'EOF' at line 39"). REGLA: validar JSON de data con script headless de Godot de 5 líneas, NUNCA con el parser de PowerShell. (Tuve un ida-y-vuelta de 15 min por esto.)
28. **El rg con `--glob "!balance"` NO excluye el directorio** (excluye el pattern): usar `-g "!scripts/balance/*"`. Y su output recortado ("_bal.n()" en vez de `_bal.get_progression()`) fue ARTEFACTO del highlight, no corrupción — verificar con Select-String antes de "arreglar" archivos sanos.
29. **La edit tool puede introducir BOM en .gd** (me pasó con fishing_manager.gd — quizás por el archivo que ya lo tenía): byte-scan EF BB BF después de CADA edit de código, no solo de docs.
30. **Verificar el código, no las notas de contexto:** la nota del archivo 04 sobre `_franja_de_hora(4)`=ALBA estaba MAL (es NOCHE, `<5`). Me costó 4 fallos de test. Las notas de contexto son pistas, no contratos.
31. **PowerShell dobles comillas dentro de strings con `""` se rompen** con el encoding de consola: para editar registros con `["todas"]`/`→` usar la edit tool SIEMPRE, o single-quotes con chars por bytes (patrón `[System.Text.Encoding]::UTF8.GetString([byte[]](0xF0,0x9F,...))` para emojis).

## Estado de la línea al cerrar esta sesión

| Módulo | Estado | Progreso | Qué falta | Log |
|---|---|---|---|---|
| M38-Economía | ✅ COMPLETADO | 163/163 | SOLO QA cruzado §21.8 (Hy3) | 823 |
| M29-Tiempo | 🟡 | 194/195 | 1 [?] flecha HUD (M53) | 824 |
| M30-Reloj | 🟡 | 98/104 | 2 [?] externos | 827 |
| M31-Ciclo-Día-Noche | 🟡 | 115/169 | 54 [?] con dueño | 829 |
| M32-Clima | 🟡 | 96/121 | 25 [?] con dueño V2 | 830 |
| M34-Pesca | 🟡 | 84/153 | 69 [?] con dueño (M93 data, M52/M53/M51 visual/voxels) | 833 |
| M93-Balance | 🟡 | 112/134 | 22 [?] (simulación O = brecha grande; M105/M114/M53) | 836 |
| M15-Recursos | 🟡 | 75/222 | 2 [?] externos | 821 |
| M13-Herramientas | 🟡 | 84/120 | Verificación in-game V1 (USUARIO) | 815 |

**0 bloqueos 🔵 huérfanos.** QA cruzado §21.8 pendiente de la línea (verificador: Hy3 por regla): M38 (823), M29 (824), M30 (827), M31 (829), M32 (830), M34 (833), M93 (836).

## M145/M146/M149 — verificados y DESCARTADOS con honestidad

Los verifiqué como pedía el archivo 04: **TODOS sus pendientes son [?] de fase jugable** (M145: 15 [?] de testing con jugadores/build; M146: 10 [?] de playtesting emocional; M149: 3 [?] de hablantes nativos + hook M111). No hay NADA V0 tomable — cerrarlos sería "por hacer" prematuro. NO tomar hasta fase jugable.

## Por dónde seguir (próximo agente GLM-5.3 — en este orden)

1. **Verificación anti-colisión SIEMPRE** (bucle §6.1.a completo; WorkBuddy escribe en tiempo real — mirá también sus reservas residuales como la 835-HY3-M11 que quedó sin borrar).
2. **M93-Balance iter. 5 (RECOMENDADO — contexto fresco):** simulador económico (O.1-O.3: 3 perfiles × 60/180/365 días contra las tablas reales, techo 115% como aserción, salida AO/pipelines/desvío) + catálogo de pesca (25 peces + 4 cebos + 3 cañas — formato en 04-Codigo M34 §0b: temporadas ["todas"|lista], horas array, clima nombres, probabilidad, pity, peso_kg [min,max], precio_venta). Es la brecha grande restante del módulo y ahora tiene TODO el input.
3. **M18-Casas SOLO si WorkBuddy liberó M18-BIS** (última actividad 2026-09-05, glm-5.3-free — verificar CHECKLIST-GLOBAL fila 18 + ESTADO-PARALELO + Logs).
4. **M35-Minería (82)** o relevo de M28/M37/M71/M72/M158 (flash/agnes) SOLO con 24h+ verificadas §21.4.7 (regla de siempre).
5. **NO tomar:** M153 (fase jugable), M145/M146/M149 (fase jugable, verificado arriba), M41/M42 (🔵 agnes).

## Cómo ejecutar los tests de esta sesión

```powershell
$godot = "D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
$game = "<raíz>\game\isla-ancestral"
# Ciclo 1 (M34):
& $godot --headless --path $game -s res://scripts/fishing/test_fishing.gd         # 0 fallos (7 bloques, 4 nuevos)
& $godot --headless --path $game -s res://scripts/fishing/test_fishing_clima.gd  # 0 fallos
# Ciclo 2 (M93):
& $godot --headless --path $game -s res://scripts/balance/test_balance_m93_iter4.gd  # NUEVO, 0 fallos
& $godot --headless --path $game -s res://scripts/balance/test_balance_m93_iter3.gd  # 0 fallos (fix expectativa versión)
& $godot --headless --path $game -s res://scripts/balance/test_balance.gd            # 0 fallos
& $godot --headless --path $game -s res://scripts/balance/validate_balance.gd        # 0 fallos (10 reglas)
# Consumidores M93:
& $godot --headless --path $game -s res://scripts/crafting/test_crafting.gd           # M16, 0 fallos
& $godot --headless --path $game -s res://scripts/farm/test_farm.gd                  # M33, 0 fallos
& $godot --headless --path $game -s res://scripts/mineria/test_mineria.gd             # M35, 0 fallos
# ⚠️ SI "file not found" fantasma: Remove-Item ".godot\uid_cache.bin" (lección 21)
# ⚠️ Validar JSON de data: script headless de Godot (lección 27), NO PowerShell
```

## Pendiente del USUARIO (no del agente)

- **Abrirle sesión a Hy3 (WorkBuddy) para el QA cruzado §21.8** de la línea: M38 (el más urgente, primer ✅), M29, M30, M31, M32, M34 (Log 833), M93 (Log 836). Hy3 YA está haciendo QAs (M10/M11, logs 834/835) — aprovechar que está activo.
- V1 verificación in-game del cableado M13→M15 (tecla 2 hacha → árbol → E) — de la sesión 01, sigue pendiente.
- **Bug VAL-DGV new_level** (M22/M71, detectado en regresión M72): decidir si se registra en 11-BUGS.md (yo lo documenté en Log 833 pero no lo registré por no ser mi módulo).
- Verificación visual opcional del respawn estacional M15 (print `[M15] estación cambió`).

---

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-12 04:30
**Estado:** Sesión cerrada con 2 ciclos completados (M34-Pesca iter. 2 ✅ Log 833 — auditoría 84/153 + bug crítico de estaciones corregido; M93-Balance iter. 4 por relevo §21.4.7 ✅ Log 836 — iter. 3 fantasma asimilada, 112/134, versión 1.2.0). 1 test nuevo (test_balance_m93_iter4) + 1 suite ampliada (test_fishing, 4 bloques), 14 suites de regresión 0 fallos, 810 runs de mojibake saneados de CHECKLIST-GLOBAL con script reutilizable nuevo, 4 BOM eliminados, 1 bug preexistente documentado (VAL-DGV), M145/M146/M149 verificados y descartados con honestidad, 0 bloqueos huérfanos, BACKLOG-MASTER actualizado, lecciones 26-31. **El próximo agente arranca con M93 iter. 5 (simulación económica) — contexto fresco del data — o M18 si WorkBuddy liberó.**
