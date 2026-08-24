**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 151: Control Final

## 1. Problema
Tras el Lanzamiento (M143) y con la build RC ya publicada, el **Control Final** es la auditoría de calidad global del producto terminado: verifica que el juego tenga identidad propia, sea divertido, esté completo en gameplay (construir, explorar, puzzles, NPC, economía, progresión, mundo vivo, estaciones, clima), tenga audio/gráficos/voxels coherentes, guardado confiable, rendimiento aceptable, accesibilidad y localización contempladas, y esté documentado administrativamente (contratos, licencias, PI, tienda, soporte, actualización y plan post-lanzamiento).

## 2. Objetivo del módulo
Auditar y certificar que "Isla Ancestral" como producto está **listo, completo y sin deudas residuales graves** en el momento del lanzamiento, cerrando la fase de desarrollo con un acta de Control Final que deje documentado el estado de los 26 puntos maestros.

## 3. Alcance (derivado del plan maestro: sección 150 "CONTROL FINAL")
1. **Identidad propia** — el juego se distingue en propuesta, arte y tono.
2. **Bucle principal divertido** — jugabilidad núcleo validada por playtests.
3. **Construir divertido** — sistema de construcción gratificante (M17/M65).
4. **Explorar divertido** — mundo interesante de descubrir (M28/M50).
5. **Resolver puzzles divertido** — puzzles justos y variados (M24/M26).
6. **Hablar con NPC interesante** — diálogos con personalidad (M20/M21/M23).
7. **Economía funciona** — curva sana sin roturas (M38/M93).
8. **Progresión funciona** — sellos/habilidades/herramientas avanzan bien (M71).
9. **Mundo se siente vivo** — rutinas y eventos sostienen la ilusión (M25/M74).
10. **Estaciones con propósito** — ciclo estacional relevante (M33/M74).
11. **Clima con propósito** — clima afecta gameplay real (M32).
12. **Música refuerza zonas** — dirección musical coherente (M41).
13. **Audio refuerza acciones** — feedback sonoro nítido (M42/M44).
14. **Gráficos coherentes** — estilo visual unificado (M06/M49).
15. **Voxels técnicamente eficientes** — rendimiento al nivel comercial (M08/M11).
16. **Guardado confiable** — sin pérdidas en rutas críticas (M59/M60/M66).
17. **Rendimiento aceptable** — presupuestos cumplidos (M61-M63).
18. **Accesibilidad contemplada** — M58 completo.
19. **Localización contemplada** — M87 completo.
20. **Contratos documentados** — acuerdos del equipo/terceros archivados.
21. **Licencias documentadas** — licencias de assets y herramientas archivadas.
22. **Propiedad intelectual documentada** — registros de PI (marca, nombre).
23. **Página de tienda preparada** — store final lista (M149).
24. **Soporte preparado** — canales activos (M152).
25. **Sistema de actualización preparado** — pipeline de parches/hotfixes (M142/M143).
26. **Plan post-lanzamiento preparado** — hoja de ruta para M144 y futuras mejoras.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Auditoría de jugabilidad: bucle, construir, explorar, puzzles y NPC con criterios medibles y playtest de respaldo |
| RF2 | Auditoría de sistemas: economía, progresión, mundo vivo, estaciones, clima con checks objetivos |
| RF3 | Auditoría audiovisual: música, SFX, gráficos y voxels con criterios y números (perf) |
| RF4 | Auditoría técnica: guardado confiable (30 ciclos), rendimiento aceptable (M61-M63) |
| RF5 | Auditoría de inclusividad: accesibilidad (M58) y localización (M87) al 100% |
| RF6 | Auditoría administrativa: contratos, licencias, PI documentados y archivados |
| RF7 | Auditoría comercial: store, soporte, actualización y plan post-lanzamiento listos |
| RF8 | Acta de Control Final firmada con el estado de los 26 puntos (✔/⚠/✖) |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 26 puntos del plan maestro evaluados con evidencia (playtest, métricas, documentos).
2. Puntos en ✖ = 0; ⚠ permitidos solo con plan de acción fechado.
3. Auditoría de jugabilidad respaldada por encuestas (≥ 10 jugadores, diversión ≥ 4/5).
4. Auditoría técnica con números (crash, fps, memoria, saves) desde telemetría real.
5. Documentos administrativos (contratos, licencias, PI) listados con ubicación segura.
6. Acta de Control Final archivada en el repo (plan-actual) y firmada.
7. Traspaso del acta a M144 (post-lanzamiento) para seguimiento de ⚠.

## 6. Restricciones
- **Aplican:** M93 (balance/diversión), M112 (tests), M101/M102 (bugs), M58, M87, M149, M152, M142/M143 (pipeline), M144 (post-launch), M147 (biblia).
- El Control Final es **auditoría**: no se implementa nada, solo se certifica o se abre plan de acción.
- No se permite aprobar puntos con "informes parecen estar bien": toda evidencia es verificable.

## 7. Dependencias
- M143 (Lanzamiento ✅), M144 (post-lanzamiento — recibe el acta), M142 (RC), M149, M152, M58, M87, M93, M112, M147.
- Dependencias de juego: todos los módulos de gameplay (M13, M16, M17, M20-M26, M28, M32-M38, M41-M44, M49-M50, M59-M63, M65-M66, M71, M74, M87, M93).

## 8. Entregables del módulo
1. Acta de Control Final (26 puntos con evidencia y firma).
2. Informe de playtest de control (encuestas de diversión).
3. Inventario de ⚠ con plan de acción fechado.
4. Documentos administrativos indexados (contratos, licencias, PI).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M143** — Lanzamiento | Control final post-lanzamiento |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M153** — Objetivo Final del Proyecto | Usado por objetivo final del proyecto |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M143** — Lanzamiento | Depende de este módulo |
| **M153** — Objetivo Final del Proyecto | Este módulo lo necesita |

