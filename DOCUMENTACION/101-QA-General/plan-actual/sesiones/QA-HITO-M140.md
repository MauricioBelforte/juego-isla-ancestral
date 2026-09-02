**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# SESIÓN DE HITO — M140 Alpha (definida + plantilla)

## Contexto del hito

- **Objetivo:** historia jugable (6 Sellos, actos 1-3), mecánicas principales completas, 6 integraciones cruzadas, balance triple red, 4 islas, 2 templos nuevos, QA intensivo.
- **Módulos esperados operativos:** todos los de producción + contenido de historia/side quests + al menos 4 islas.
- **Áreas del QA-CHECKLIST:** regresión + **exploratorio intensivo** + primera tanda M114.

## Criterios de entrada

1. Build M140 etiquetada con smoke aprobado.
2. Suite M112 en verde.
3. M139 con su DoD de QA cumplido.

## Sesión a ejecutar

1. **Smoke:** QA-SMOKE.md.
2. **Regresión por áreas:** QA-CHECKLIST completo (01-27) en 3-4 subsesiones.
3. **Exploratorio (2-3 h):** jugar la historia completa (6 sellos, actos 1-3) sin guides; cada tester cierra el juego a mitad y relojea el progreso.
4. **M114 primera tanda:** reglas QA-PLAYTEST-BRIDGE.md (EA.1-EA.5) — los hallazgos de diseño agregan ítems al QA-CHECKLIST.
5. **Fronteras:** viajes/4 islas/2 templos → áreas 12-13 obligatorias completas.

## Criterios de salida

- [ ] **100% de áreas** del QA-CHECKLIST con checklist verde (`[x]`, sin `[?]` sin dueño).
- [ ] Feature-complete estable: agregar la misión al 100% sin repetir.
- [ ] 0 críticos; altos con fix planificado en el hito siguiente.
- [ ] M114 ejecutó su tanda con build saneada (EA.1).
- [ ] Playtesting con señal de "la historia se entiende" (si no, no hay cierre Alpha).

## Plantilla de la sesión

```markdown
**Sesión QA #NN — Hito M140 (Alpha)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** {commit} — 0.4.0-alpha
**Tester:** {Agente/Modelo/Plataforma}
**Semilla del mundo (M10):** 42 + aleatoria
**Versión Godot:** 4.7.2
**Áreas cubiertas:** 01-27 (subsesión NN de NN)
**Smoke test:** Aprobado / Rechazado

## Resultados por ítem (tabla estándar)
## Bugs encontrados
| Issue | Severidad | Categoría | Reproducible | Estado | Dueño |
## Conversión a M112
## Resultado M114 (si aplica)
| Sesión M114 | N jugadores | Señales de diseño | Issues técnicos |
## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE
- Bloqueos: ...
- Métricas: ...
**Firma:** {Modelo} / {Plataforma} — {fecha}
```
