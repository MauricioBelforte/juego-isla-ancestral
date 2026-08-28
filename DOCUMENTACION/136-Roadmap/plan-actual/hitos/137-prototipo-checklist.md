# Checklist del Hito M137 — Prototipo

**Modelo:** GLM · **Plataforma:** Kilo · **Fecha de apertura:** sin abrir (en preparación 2026-08-28)
**Estado:** ⬜ · **Fase:** 1 (protección de riesgo) · **Etiqueta de build:** `prototype-1`

## Criterios de entrada
- [ ] M01/M02 decididos (✅ documentados; confirmación del fundador)
- [ ] Godot 4.7.2 + Voxel Tools instalados y funcionales (✅ verificado 2026-08-26)
- [ ] Módulos base documentados (✅)
- [ ] M13 Herramientas conectadas al voxel real (🔵 en curso)
- [ ] Núcleo M14 Inventario operativo (🔵 68/140)

## Criterios de salida (todos verificables)
- [ ] Mundo voxel generado proceduralmente con rendimiento aceptable (base ✅ M08/M10; medir presupuesto M61)
- [ ] Cavar/colocar operativo con herramienta sobre terreno real (M13)
- [ ] Recurso recolectable visible en inventario (M14/M15)
- [ ] Guardado/carga funcional del estado mínimo (M59 núcleo + M60)
- [ ] Build `prototype-1` etiquetado y jugable
- [ ] Prototipo probado por el fundador (feedback registrado)

## Módulos incluidos (vinculados a CHECKLIST-GLOBAL.md)
| ID | Módulo | MoSCoW | Estado |
|----|--------|--------|--------|
| 08 | Mundo Voxel | Must | ✅ |
| 10 | Generación del Mundo | Must | ✅ |
| 11 | Personaje del Jugador | Must | ✅ |
| 12 | Cámara | Must | ✅ |
| 13 | Herramientas | Must | 🔵 |
| 14 | Inventario | Must | 🔵 |
| 15 | Recursos | Must | 🟢 (bloqueado por M14) |
| 59 | Guardado | Must | 🟡 (núcleo implementado) |
| 60 | Datos y Serialización | Must (marco) | 🟢 |
| 137 | Prototipo (integrador GO/NO-GO) | Must | 🟢 |

## Retrasos y cortes aplicados
| Fecha | Decisión | Impacto | Autor |
|-------|----------|---------|-------|

## Cierre del hito (checklist de cierre)
- [ ] Build etiquetado creado y jugable
- [ ] Playtest realizado y feedback registrado (M114)
- [ ] DoD verificada en todos los módulos del hito
- [ ] Log generado y roadmap actualizado (recalibración del calendario)
- [ ] Cierre firmado por el agente/fundador
