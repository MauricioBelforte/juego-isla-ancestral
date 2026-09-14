# Log 833: M34-Pesca Iter2 Auditoria Doc-Codigo Y Brechas V0

**Fecha:** 2026-09-12
**Hora:** 03:12
**Modelo:** GLM-5.3
**Plataforma:** Kilo Code

## Resumen

Iteración 2 de M34-Pesca: auditoría doc↔código completa (patrón M29/M31/M32) con evidencia por ítem + cierre de 3 brechas V0 reales con tests, incluida la corrección de un bug crítico no documentado en el filtro de estaciones. Además: saneamiento de mojibake masivo en CHECKLIST-GLOBAL.md (810 runs, escritura cp1252 doble-codificada de otro agente) con script nuevo reutilizable, y 3 BOM eliminados de .gd preexistentes.

## Cambios Realizados

### 1. Brechas V0 cerradas en `fishing_manager.gd`
- **Bug crítico `temporadas: ["todas"]`:** `_estacion_numero("todas")` devolvía -1 → `pez.estaciones=[-1]` nunca matcheaba estación real 0-3 → TODOS los peces "todas" caían SIEMPRE al fallback "todas las especies" (filtro de estación ROTO; cozy de accidente). Fix: "todas" → estaciones VACÍAS (contrato FishDefinition L14: vacío = todas).
- **Bug `horas` de 2 valores:** solo se usaba la PRIMERA hora ( `[4, 20]` perdía la 20). Fix: cada hora mapea a su franja sin duplicados.
- **PRNG semilla M29 H120:** `hash(Time.get_ticks_usec())` (entropía runtime, indeterminista por partida) → `GameTime.rng_diario("m34")` (semilla de partida+día+namespace, patrón canónico Log 824). Fallback: semilla 0 estable sin GameTime.
- **Extracción `_candidatas_de_estacion(estacion, hora)`:** filtro de resolver_especie extraído a función testeable (patrón `_peso_efectivo` Log 310). El clima NUNCA filtra (§6 M32).

### 2. Tests (test_fishing.gd: 4 bloques nuevos)
- `_test_iter2_estaciones_todas`: sardina estaciones vacías + candidata en las 4 estaciones POR REGLA.
- `_test_iter2_franjas_horas`: 4→NOCHE + 20→ATARDECER (2 franjas exactas); luna [21,3]→[NOCHE] sin dupes.
- `_test_iter2_prng_semilla_m29`: rng_diario("m34") reproducible + namespace aislado.
- `_test_iter2_filtro_estacion_verano`: E2E — sardina en las 4 estaciones, luna SOLO verano (filtro real discrimina).

### 3. Auditoría 05-Checklist.md: 4 → 84 [x] / 69 [?] / 0 [ ]
Con evidencia por ítem (líneas de código/tests/diseño). 69 [?] con dueño identificado: M51 (voxels), M52 (VFX/flotador), M53 (UI), M42 (audio), M93 (data: 2/25 peces, 0 cebos/cañas — NO expandido por regla de dueño), M14 (item pez), M15 (recetas), M105 (telemetría), M57 (accesibilidad), M37 (catálogo museo).

### 4. 04-Codigo.md: §0 rutas/firmas REALES (las §1/§2 eran aspiracionales del diseño — FishingMinigameUI.gd/FishCollectionData.gd NO existen) + Notas del Agente iter. 2.

### 5. Saneamiento de infraestructura (§28)
- **CHECKLIST-GLOBAL.md: 810 runs mojibake revertidos** (doble codificación UTF-8→cp1252→UTF-8 de emojis/acentos en 40+ filas de la tabla — escritura de otro agente). Script nuevo reutilizable: `scripts/saneamiento_utf8.py` (--dry-run, --backup, selectivo: solo runs que decodifican limpio). Fila 34 verificada legible post-fix.
- **3 BOM UTF-8 eliminados** de .gd preexistentes: `scripts/logros/achievement_service.gd`, `scripts/progresion/player_profile.gd`, `scripts/progresion/progression_manager.gd` (se colaron en la sesión de otro agente; detectados por git diff durante la regresión).

## Verificación (QA numérico, Godot 4.7.2 headless)

| Suite | Resultado |
|---|---|
| `scripts/fishing/test_fishing.gd` | 0 fallos (7 bloques) |
| `scripts/fishing/test_fishing_clima.gd` | 0 fallos (regresión bonos) |
| `scripts/time/test_semilla_iter1.gd` (M29) | 25/25 |
| `scripts/time/test_consumidores_tiempo.gd` (M29) | 12/0 |
| `scripts/logros/test_logros.gd` (M72 consume captura_exitosa) | 0 fallos |
| `scripts/clima/test_clima.gd` (M32) | 0 fallos |

Hallazgo preexistente (NO de M34, no tocado): 10 push_error `[VAL-DGV] nodo 'inicio': condición usa clave de mundo desconocida 'new_level'` — `data/dialogues/reaccion_nivel.json` (M22/M71) usa clave que el validador de diálogos no reconoce. Registrar como bug si otro agente lo toma.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/fishing/fishing_manager.gd` (fix ×3 + extracción)
- `game/isla-ancestral/scripts/fishing/test_fishing.gd` (4 bloques nuevos)
- `DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md` (auditoría completa)
- `DOCUMENTACION/34-Pesca/plan-actual/04-Codigo.md` (§0 real + notas)
- `CHECKLIST-GLOBAL.md` (saneamiento mojibake + fila 34 → 🟡 liberado con 84/153)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M34 liberado)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada liberación)
- `scripts/saneamiento_utf8.py` (NUEVO — reutilizable, §28)
- `game/isla-ancestral/scripts/logros/achievement_service.gd` (BOM saneado — sin cambios de código)
- `game/isla-ancestral/scripts/progresion/player_profile.gd` (BOM saneado)
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` (BOM saneado)
- `CHECKLIST-GLOBAL.md.bak_2026-09-11_23-21-57` (backup del saneamiento)

## Estado del módulo

M34 queda 🟡 Con dudas 84/153 (0 [ ]): el núcleo + integraciones M29/M31/M32/M32-bonos/persistencia/colección/anti-frustración están completos y testeados; los 69 [?] son dependencias con dueño identificado (mayoría: data M93 y visual M52/M53/M42). QA cruzado §21.8 pendiente (verificador: Hy3 — puntos verificables en 04-Codigo.md Notas iter. 2).

## Colisiones de log

Verificadas ANTES de reservar (bucle §6.1.a completo): ULTIMO_NUMERO=832 (WorkBuddy consumió 830→831-M27, Hy3 escribió 832-M09), 833 libre sin archivo NI reserva. Reserva `Logs/reservas/833-glm-5.3-M34.txt` creada 02:15 y BORRADA al consumir (este log). Sin colisiones en esta sesión.
