# Log 582: M72 Logros — iter. 6 (RF2 CondicionPesca vía M34)

**Fecha:** 2026-09-03
**Hora:** 05:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 6 de M72 Logros: CondicionPesca (RF2) usando la señal real de M34. captura_exitosa alimenta estadísticas de pesca; 2 logros de pesca nuevos en el catálogo. Con esto RF2 completa amistad (iter. 4) + pesca (iter. 6). 5 ítems marcados [x] → 77/190.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/logros/achievement_service.gd` | +_on_captura_pesca(pez, tamano): suscripción a Fishing.captura_exitosa (M34); stat dinámica `peces_capturados` (total monótona) + `pescar_<pez_id>` (primera vez por especie); evaluar_todos tras captura |
| `data/logros/logros.json` | +2 logros de pesca: Pescador Principiante (1 captura, progreso parcial), Diez en el Anzuelo (10 capturas) — 11 total |
| `scripts/logros/test_logros.gd` | +_test_pesca_rf2 (5 checks con pez real del catálogo M34); conteos 9→11 |
| `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` | 5 ítems [x] + nota iter. 6 |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M72 iter. 6 Liberado (77/190) |

## Tests (headless Godot 4.7.2)
- `test_logros.gd`: **0 fallos** (pesca: catálogo con especies, +1 stat, primera vez por especie, logro principiante; amistad intacta; API/fechas/retroactividad OK)
- Regresión: test_progresion M71 **0 fallos**
- Boot: `[M72] Logros cargados: 11`, RF14 0 problemas

## Hallazgos Godot (para 07-GUIA §8)
1. **`Object.get("id", "default")` NO acepta segundo argumento** en Godot 4.7.2 — parser error "Too many arguments for get() call". Obtener con get("id") + null-check, o validar con `"id" in obj`.
2. **`Resource.new()` genérico no retiene propiedades dinámicas**: `set("id", v)` sobre una propiedad inexistente falla silenciosamente — para tests usar instancias reales del catálogo (duck-typing a `fishing._peces[0]`).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/logros/achievement_service.gd` *(modificado)*
- `game/isla-ancestral/data/logros/logros.json` *(modificado)*
- `game/isla-ancestral/scripts/logros/test_logros.gd` *(modificado)*
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 582)*
- `Logs/reservas/582-...txt` *(creado y borrado)*

## Notas técnicas
- RF2 queda completa con señales REALES de los módulos dueños (M20 amistad, M34 pesca) — sin duplicar evaluadores (§vocabulary M71 stat_min).
- `pescar_todas_las_especies` = compuesta AND de stat_min por especie — se declara en catálogo cuando el contenido lo curado lo pida (las especies ya son stats automáticas).
- El provider Fishing fue refactorizado por su agente concurrente con helper `_conectar()` — mi iteración se adaptó al patrón vigente (colaboración sin pisado).
