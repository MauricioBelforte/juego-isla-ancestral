# Checklist del Hito M142 — Release Candidate

**Modelo:** GLM · **Plataforma:** Kilo · **Fecha de apertura:** sin abrir
**Estado:** ⬜ · **Fase:** 6 (candidatos de release) · **Etiqueta de build:** `rc-1`

## Criterios de entrada
- [ ] Beta estable
- [ ] Lista de bugs conocidos documentada (M102)
- [ ] Build de prensa planificado

## Criterios de salida (todos verificables)
- [ ] RC probado en hardware objetivo (M115)
- [ ] Rendimiento dentro de presupuesto (M61/M62/M63)
- [ ] Crash reporting (M122) sin errores críticos
- [ ] Logros (M72) y configuraciones de plataforma verificados
- [ ] Saves compatibles (M59/M119)
- [ ] Build de release `rc-1` etiquetado + notas de parche

## Módulos incluidos (vinculados a CHECKLIST-GLOBAL.md)
| ID | Módulo | MoSCoW | Estado |
|----|--------|--------|--------|
| 61 | Rendimiento | Must | 🟢 |
| 62 | Memoria | Must | 🟢 |
| 63 | Cargas y Streaming | Must | 🟢 |
| 115 | Hardware | Must | 🟢 |
| 122 | Crash Reporting | Must | 🟢 |
| 72 | Sistema de Logros | Must | 🟢 |
| 117 | Build System | Must | 🟢 |
| 118 | CI/CD | Should | 🟢 |
| 104 | Analytics | Should | 🟢 |

**Won't en esta fase:** features nuevas (freeze según M142).

## Retrasos y cortes aplicados
| Fecha | Decisión | Impacto | Autor |
|-------|----------|---------|-------|

## Cierre del hito (checklist de cierre)
- [ ] Build etiquetado creado y jugable
- [ ] Playtest realizado y feedback registrado
- [ ] DoD verificada en todos los módulos del hito
- [ ] Log generado y roadmap actualizado
- [ ] Cierre firmado por el agente/fundador
