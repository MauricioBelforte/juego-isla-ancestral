# Log 836: M93-Balance Iter4 Relevo Auditoria Y Brechas Data

**Fecha:** 2026-09-12
**Hora:** 04:18
**Modelo:** GLM-5.3
**Plataforma:** Kilo Code

## Resumen

Iteración 4 de M93-Balance por **relevo §21.4.7** (reserva de glm-5.3-flash del 2026-09-01 sin log ni liberación por 11 días, reclamo verificado). Hallazgo central del relevo: la **iter. 3 "perdida" de flash SÍ aterrizó en disco sin log** (tablas v2 + test_iter3, 0 fallos) — asimilada en esta auditoría. Se cerraron 64 [ ] → 112 [x] / 22 [?] con evidencia, y **5 brechas V0 de DATA** con test nuevo (0 fallos): tiempo de minado, curvas de progresión no exponenciales, reglas anti-grind, reglas anti-exploit, rutinas/estaciones.

## Cambios Realizados

### 1. Relevo §21.4.7 (proceso)
- Verificación previa completa: sin logs M93 desde el 333 (2026-09-01), sin reserva activa, CHECKLIST-GLOBAL 2026-08-30, ESTADO-PARALELO sin actividad de flash sobre M93.
- Bloqueo en los 4 registros sincronizados + reserva 836 (bucle §6.1.a completo).

### 2. Hallazgo — iter. 3 fantasma materializada
- `data/balance/{friendship,quests,puzzles,unlocks}.json` v2 + `meta.json` (rareza/pity/rendimiento/viajes) + `scripts/balance/test_balance_m93_iter3.gd` (6 bloques, 0 fallos) = el trabajo de la reserva del 2026-09-01 existe, solo le faltó el log y la liberación.
- ~20 ítems del checklist ya estaban cubiertos por esas tablas sin marcar (gap de marcado).

### 3. Brechas V0 de DATA cerradas (4 tablas JSON evolucionadas)
- **mining.json v2 (D.4):** `golpes_para_extraer` por mineral (3/5/8) + `reglas_minado` (golpes_base_por_dureza, 1.5 s/golpe, duración máx 2 min, coherencia M35 documentada).
- **progression.json v2 (L.2-L.5):** `curvas_recursos_acumulados` (día 1/7/28/90, tope soft 28+), `curva_amistad_total` (semana 1/4/12: 6/20/45), `curva_colecciones` (10%/35%/70%), `reglas_curvas.no_exponencial`.
- **meta.json v3 (M/N):** `reglas_anti_grind` (repetición máx 4, tope ventas 600 AO/día, temporada cíclica sin FOMO, colección sin día único, bonus_retorno +5 AO/día tope 150) + `reglas_anti_exploit` (3 bucles con contramedidas, techo 115%, reloj interno independiente C56, límite 20 ventas/día/categoría).
- **timing.json v2 (K.1-K.5):** `rutinas` — rutina óptima 30 min (5 pasos, progreso garantizado), sesión libre [60,120] min, cultivos_sin_muerte, estaciones_rotativas (28 días, contenido rotativo).
- balance_version **1.1.0 → 1.2.0** (regla U.3).

### 4. Test nuevo: test_balance_m93_iter4.gd
7 bloques: minado D.4, curvas no exponenciales (verificación MATEMÁTICA de pendientes por tramo), anti-grind, anti-exploit, rutinas K, versión 1.2.0, integraciones Q (tablas legibles para M16/M33/M34). **0 fallos.**

### 5. Auditoría doc↔código de los 64 [ ] (66 → 112 [x] / 22 [?])
Cierres por gap de marcado con evidencia: H (items exclusivos, quests v2), P.2-P.4 (reglas R7/R8/R8b ya en validate), X.1/X.3 (márgenes/sellos cobertura total), W.3/W.5 (arquitectura O(1) sin FileAccess por lookup + medición de facto), Q.2/Q.3 (grep REAL: crafting_service.gd L67-69 y farm_service.gd L67-69 consumen /root/Balance), Q.4 (M34 lee fishing.json directo — contrato = formato JSON), Z.1-Z.4 (coordinaciones con evidencia: T7 amistad M38 consume umbrales M93, test iter3 ejecuta servicio M20 real, M94 consume las 3 reglas de ausencia, M153 contrato de sellos), V.3/V.4 (ausencia benigna + rareza/pity con caso real M34), R.1-R.5 (verificaciones contra progression/seals/construction/tools/prices).

### 6. Fix de test iter3
Expectativa de versión desacoplada del bump (acepta >=1.1.0 semántico) para que el test no se rompa en cada bump de versión futuro.

## Verificación (QA numérico, Godot 4.7.2 headless)

| Suite | Resultado |
|---|---|
| `scripts/balance/test_balance_m93_iter4.gd` (NUEVO) | 0 fallos (7 bloques) |
| `scripts/balance/test_balance.gd` | 0 fallos |
| `scripts/balance/test_balance_m93_iter3.gd` | 0 fallos |
| `scripts/balance/validate_balance.gd` | 0 fallos (10 reglas) |
| `scripts/crafting/test_crafting.gd` (M16 consumidor) | 0 fallos |
| `scripts/crafting/test_pergaminos_tienda.gd` (M16) | 0 fallos |
| `scripts/farm/test_farm.gd` (M33 consumidor) | 0 fallos |
| `scripts/farm/test_farm_clima.gd` (M33) | 0 fallos |
| `scripts/mineria/test_mineria.gd` (M35) | 0 fallos |
| `scripts/fishing/test_fishing.gd` + clima (M34, del ciclo 1) | 0 fallos |

Los 4 JSON editados validados con el parser REAL de Godot (script headless de diagnóstico).

## Archivos Modificados/Creados

- `game/isla-ancestral/data/balance/mining.json` (v2, D.4)
- `game/isla-ancestral/data/balance/progression.json` (v2, L.2-L.5 — +fix de `}` extra que rompía el parse)
- `game/isla-ancestral/data/balance/meta.json` (v3, M/N, version 1.2.0)
- `game/isla-ancestral/data/balance/timing.json` (v2, K.1-K.5)
- `game/isla-ancestral/scripts/balance/test_balance_m93_iter4.gd` (NUEVO)
- `game/isla-ancestral/scripts/balance/test_balance_m93_iter3.gd` (fix expectativa versión)
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md` (auditoría 64 [ ])
- `DOCUMENTACION/93-Balance/plan-actual/04-Codigo.md` (Notas del Agente iter. 4 + firma)
- `CHECKLIST-GLOBAL.md` (fila 93 → 🟡 112/134 liberado)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M93 liberado)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (liberación)

## Estado del módulo

M93 queda **🟡 Con dudas 112/134** (0 [ ]): el núcleo + las 19 tablas + reglas anti-grind/anti-exploit + curvas + validador + 3 suites están completos y testeados. Los 22 [?] con dueño: **O.1-O.3+X.5 simulación económica (la brecha grande restante — próxima iter natural, ahora tiene todo el input)**, S telemetría (M105), T playtest (M114 fase jugable), Q.1 (M38 catálogo propio), Y.1-Y.5 (polish UI M53/M74/M94/M88/M43), V.1/V.2 (simulación), O.5 (CI M118). QA cruzado §21.8 pendiente (verificador: Hy3 — puntos en 04-Codigo Notas iter. 4).

## Lección nueva (para el archivo de contexto 05)

- **PowerShell ConvertFrom-Json reporta mal los JSON con TABs** (falso "Primitivo JSON no válido") — el `}` extra del progression.json solo lo detectó el parser REAL de Godot ("Expected 'EOF' at line 39"). REGLA: validar JSON de data con script headless de Godot de 5 líneas, NUNCA confiar en el parser de PowerShell.
- El rg con `--glob "!balance"` no excluye el DIRECTORIO así (excluye el pattern) — usar `-g "!scripts/balance/*"` o la ruta completa. Su output truncado ("_bal.n()") fue artefacto del highlight, los archivos estaban intactos.

## Colisiones de log

Verificadas ANTES de reservar: ULTIMO_NUMERO=835 (BOM saneado al escribir 836), reserva activa `835-HY3-M11.txt` de WorkBuddy (M11 QA cruzado — su log 835 ya escrito, reserva sin borrar de su lado, NO la toqué), logs 834/835-M10/M11 de Hy3 en disco. 836 libre verificado sin archivo NI reserva. Reserva `Logs/reservas/836-glm-5.3-M93.txt` creada 03:20 y BORRADA al consumir. Sin colisiones en esta sesión.
