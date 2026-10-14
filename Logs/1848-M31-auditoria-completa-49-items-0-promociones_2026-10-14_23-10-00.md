# Log 1848: M31-Ciclo-Día-Noche — auditoría completa de 49 `[?]` (0 promociones)

**Fecha:** 2026-10-14
**Hora:** 23:10
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 49 `[?]` de M31-Ciclo-Día-Noche (encargo del director mimo, msgs 365/367).
Método Patrón D: verificación contra disco (grep + existencia de archivo/dato). Commits
`c81a8ee` (b1), `d501a54` (b2), `bb36dcc` (cierre).

## Resultado: 0 promociones, 49 anotados

Ningún `[?]` tiene respaldo completo. Todos son deuda externa con datos parciales:

| Bloque | Items | Respaldo encontrado | Deuda |
|---|---|---|---|
| Estrellas (P6) | 1 | fase_umbral.json §estrellas (alpha 20-22h) | canvas procedural de M45 |
| Luna (P7) | 2 | moon_curve.tres (Curva para luz) | esfera con textura de M45 |
| Nubes (P8) | 2 | ninguno | M45/K.2 |
| Niebla (P11) | 2 | fog_curve.tres (Curva) | nodo FogVolume ausente en escenas |
| Recursos nocturnos (P17) | 1 | temporada_respawn en M15 | ventana horaria de M15 |
| Eventos nocturnos (P19/P20) | 2 | datos de estrellas en JSON | calendario M74 + partículas M52 + flora M15/M148 |
| Faroles | 3 | puzzle farol_cargado en M23 data | prefab de M18/M45 (WorkBuddy en M18-BIS) |
| Minimapa (M12) | 1 | mapa_manager.gd EXISTE | modo nocturno de M12 |
| Accesibilidad (M58) | 2 | ninguno | M58 sin implementar |
| QA visual (M114) | 2 | ninguno | requiere visión (usuario o agente con visión) |
| Sky/escénico | 3 | curvas de sol/luna/cielo en JSON | Sky procedural de M45 |
| Fauna/flora especial | 3 | catalog.json 7 especies base | lince/flora de M36/M93 |
| Hooks futuros | 3 | es_de_dia() en 3 scripts | bonus de M15/M93 |

## Hallazgo de coherencia

El módulo M31 está **bien implementado en su núcleo** (day_night_cycle.gd, curvas data-driven,
game_clock, time_calendar, es_de_dia). Los 49 `[?]` son todos de **capa escénica y de contenido
de otros módulos** — no hay deuda de implementación del ciclo día/noche en sí.

Un ítem ("Compatible con M12 minimapa") tenía texto desactualizado: decía "sin implementar"
pero M12 sí existe en disco (`mapa_manager.gd`, `mapa_markers.gd`, `test_mapa_m54.gd`). Anotado
como error de texto, no como degradación.

## Archivos Modificados

- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md` (49 `[?]` anotados con evidencia;
  commits `c81a8ee`, `d501a54`, `bb36dcc`)
