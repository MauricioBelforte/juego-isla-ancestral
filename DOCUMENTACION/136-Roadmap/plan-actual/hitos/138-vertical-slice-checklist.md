# Checklist del Hito M138 — Vertical Slice

**Modelo:** GLM · **Plataforma:** Kilo · **Fecha de apertura:** sin abrir
**Estado:** ⬜ · **Fase:** 2 (validación de visión) · **Etiqueta de build:** `slice-1`

## Criterios de entrada
- [ ] Prototipo M137 aprobado (GO/NO-GO)
- [ ] Decisión de scope del slice tomada (zona de Aurora incluida)
- [ ] Assets mínimos disponibles (M45/M46)

## Criterios de salida (todos verificables)
- [ ] Escena completa del slice navegable sin errores
- [ ] El jugador camina, corre y salta con cámara cómoda
- [ ] Interacción básica con ≥3 objetos del mundo (M70)
- [ ] Un objetivo corto del GDD cumplible de punta a punta
- [ ] Progreso se guarda y carga entre sesiones (guardado continuo)
- [ ] UI mínima del slice funcional (M53: inventario + pistas)
- [ ] Rendimiento objetivo demostrado en hardware de prueba (M61)
- [ ] Playtest interno (M114) con feedback registrado
- [ ] Build `slice-1` etiquetado + video corto

## Módulos incluidos (vinculados a CHECKLIST-GLOBAL.md)
| ID | Módulo | MoSCoW | Estado |
|----|--------|--------|--------|
| 27 | Islas del Mundo (zona del slice) | Must | 🟢 |
| 70 | Interacciones | Must | 🟢 |
| 53 | UI/UX (mínima del slice) | Must | 🔵 (core UI) |
| 14 | Inventario | Must | 🔵 |
| 63 | Cargas y Streaming (mínimo) | Must | 🟢 |
| 19 | NPC básico | Should | 🔵 (primer NPC visible) |
| 41 | Música base | Should | 🟢 |
| 138 | Vertical Slice (integrador) | Must | 🟢 |

## Retrasos y cortes aplicados
| Fecha | Decisión | Impacto | Autor |
|-------|----------|---------|-------|

## Cierre del hito (checklist de cierre)
- [ ] Build etiquetado creado y jugable
- [ ] Playtest realizado y feedback registrado
- [ ] DoD verificada en todos los módulos del hito
- [ ] Log generado y roadmap actualizado
- [ ] Cierre firmado por el agente/fundador
