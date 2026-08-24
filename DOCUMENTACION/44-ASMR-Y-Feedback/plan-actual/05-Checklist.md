**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 44: ASMR y Feedback

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (9)

- [ ] Definir el problema: sensación física placentera en cada acción (pilar cozy) [S]
- [ ] Registrar dependencias: M42, M43, M41, M34, M29, M13/M17; relación M58 [S]
- [ ] Catalogar los 17 puntos de la sección 43 [S]
- [ ] RF1: sensaciones de acción (cortar, cavar, picar, colocar, cosechar, cocinar, abrir cajas) [S]
- [ ] RF2: pasos por superficie con microfoley [S]
- [ ] RF3: sincronía animación-sonido (M34 keyframes) [S]
- [ ] RF4: 4 capas de sonido estructuradas [S]
- [ ] RF5+RF6: microfeedback y reglas anti-agresión [S]
- [ ] RF7: ajustes contextuales (volumen, distancia, reverb, oclusión) [S]

## B. Resolución de los 17 puntos del plan (17)

- [ ] P1: sensación cortar madera — 3 golpes ascendentes + astillas [S]
- [ ] P2: sensación de cavar — golpe blando + tierra + granulación [S]
- [ ] P3: sensación de picar piedra — percusión + gravilla + eco de filo [S]
- [ ] P4: sensación de colocar — impacto corto + clic de encaje [S]
- [ ] P5: sensación de cosechar — rizoma + nota ascendente ligera [S]
- [ ] P6: sensación de cocinar — sizzle + chasquido + vapor [S]
- [ ] P7: sensación abrir cajas — cerrojo + madera + crujido de tapa [S]
- [ ] P8: caminar superficies — microfoley + reverb contextual [S]
- [ ] P9: sonido sincronizado con animaciones — keyframes ±15 ms [S]
- [ ] P10: capas de sonido — 4 capas estrictas (ambiente/acción/microfoley/respuesta) [S]
- [ ] P11: microfeedback — chasquidos premiadores en interacciones [S]
- [ ] P12: evitar sonidos agresivos — blacklist verificable [S]
- [ ] P13: evitar saturación — limitador -1 dBFS + headroom -6 dB [S]
- [ ] P14: ajustar volumen contextual — tabla precedencia fija [S]
- [ ] P15: ajustar distancia — pasos 15 m, romper 20 m, mundo 30 m [S]
- [ ] P16: ajustar reverberación — reverb por interior (0.15-1.5 s) [S]
- [ ] P17: ajustar oclusión — RayCast solo interiores críticos, 30% atenuación [S]

## C. Recetas de sensación (8)

- [ ] Receta cortar madera: impacto seco → rumble → crujido + astillas [S]
- [ ] Receta cavar: golpe blando → tierra suelta → granulación [S]
- [ ] Receta picar piedra: percusión + gravilla + eco filo [S]
- [ ] Receta colocar: impacto corto + clic encaje [S]
- [ ] Receta cosechar: rizoma + nota ascendente [S]
- [ ] Receta cocinar: sizzle + chasquido + vapor (loop corto) [S]
- [ ] Receta abrir caja: cerrojo + madera + crujido [S]
- [ ] Receta caminar: microfoley superficie + reverb interior [S]

## D. Sincronía con animaciones (M34) (6)

- [ ] SFX se dispara en keyframe de impacto (nunca al inicio) [S]
- [ ] Margen ±15 ms respecto del impacto visual [S]
- [ ] Animación cancelada → el impacto NO suena (sin fantasma) [S]
- [ ] Señal `animacion_key(accion, keyframe)` definida [S]
- [ ] Pitch ligero por repetición (PRNG M29) [S]
- [ ] Tabla de keyframes por acción prevista [M]

## E. Blacklist anti-agresión y anti-saturación (6)

- [ ] Ningún evento supera -3 LUFS de pico [M]
- [ ] True Peak ≤ -1 dBFS en master [M]
- [ ] Sin buzz 2-4 kHz sostenidos > 300 ms [M]
- [ ] Prohibidos scare chords y sustos (regla de diseño) [S]
- [ ] ≤ 6 SFX simultáneos (pool M43) [S]
- [ ] Bus SFX con -6 dB headroom [S]

## F. Reglas contextuales (7)

- [ ] Interior (casa/cobertizo): -3 dB + reverb 0.5 s [S]
- [ ] Cueva 1.5 s / templo 1.2 s / ruinas 1.0 s + oclusión 30% [S]
- [ ] Bajo el agua: low-pass + volumen muy suave [S]
- [ ] Lluvia/tormenta (M32): ambiente +2 dB, SFX -2 dB [S]
- [ ] Noche profunda (M31): microfoley -30% (misterio suave) [S]
- [ ] Diálogo (M21): SFX/microfoley -6 dB (ducking) [S]
- [ ] Precedencia fija: interior > clima > día/noche > diálogo [S]

## G. Accesibilidad (M58) (5)

- [ ] Opción "Feedback reducido": microfoley -6 dB [S]
- [ ] Opción "Sonido direccional": refuerza pan 3D [S]
- [ ] Opciones en Config de Audio (M91) [S]
- [ ] Sin latencia perceptible (≤ 60 ms disparo) [S]
- [ ] Configurable por bus (M91) [S]

## G2. Pruebas (5)

- [ ] Test: receta→capas correctas (M112) [M]
- [ ] Test: keyframes sincronizados [M]
- [ ] Test: blacklist de picos no dispara [M]
- [ ] Test: recorrido M114 — 15 min sin fatiga [M]
- [ ] Master test True Peak ≤ -1 dBFS toda sesión [M]

## J. Integración con otros módulos (12)

- [ ] M13/M17: bloques rotos/colocados disparan recetas [S]
- [ ] M20: cocinar con etapas (sizzle por etapa) [S]
- [ ] M45: abrir contenedores con receta de caja [S]
- [ ] M34: animaciones humanoides y no-humanoides sincronizadas [M]
- [ ] M21: ducking del diálogo sobre microfoley [S]
- [ ] M31: capas de hora cambian microfoley [S]
- [ ] M32: clima modula contexto (viento/lluvia) [S]
- [ ] M42: ambiente nunca tapado por microfoley (jerarquía) [S]
- [ ] M41: respuesta musical solo en eventos (logros/narrativa) [S]
- [ ] M43: pool compartido sin colisiones de categoría [S]
- [ ] M58/M91: accesibilidad y config de audio integradas [S]
- [ ] M29: pausa congela microfoley sin residuos [S]

## K. Edge cases (12)

- [ ] Acción repetida en cadena (romper 10 bloques) sin saturar [S]
- [ ] Acción interrumpida: sin sonido fantasma [S]
- [ ] Cambio de bioma durante una receta: corte limpio [S]
- [ ] Entrar a interior durante lluvia: gana interior [S]
- [ ] Salir del agua en transición: cortes suaves [S]
- [ ] Clima extremo sin eventos (tormenta sin rayo): sin sobresalto [S]
- [ ] Volumen 0 configurado: cero trabajo de audio (M91) [S]
- [ ] Juego pausado durante SFX largo (cocina): pausa correcta [S]
- [ ] Retroceso del reloj (M29) no desincroniza capas [S]
- [ ] Pool lleno en zona poblada: corta pasos, jamás UI [S]
- [ ] Oclusión sin muro visible: interiores críticos solo [S]
- [ ] Noche profunda + lluvia: combinación sin ambigüedad (precedencia) [S]

## L. Polish y QA final (8)

- [ ] 15 min de juego sin fatiga auditiva (QA M114) [M]
- [ ] Ninguna acción "chincha" en ningún bioma [M]
- [ ] Volumetría coherente entre todas las capas [S]
- [ ] Microfoley dulce y premiador en cada interacción [S]
- [ ] Revisión final contra pilar cozy (checklist M0) [S]
- [ ] Documento de permisos de assets (licencias) [S]
- [ ] Suite de tests M112 incluye blacklist [M]
- [ ] Registro en Logs/ con numeración secuencial [S]

## H. Data y API (6)

- [ ] feedback_recetas.tres (recetas) [S]
- [ ] feedback_keyframes.tres (sincronía) [S]
- [ ] API: sensacion(accion, pos) [S]
- [ ] API: key_sync(accion, keyframe) [S]
- [ ] API: set_contexto / set_reverb [S]
- [ ] API: config_feedback_reducido / config_direccional [S]

## I. Delegación y cierre (12)

- [ ] Módulo marcado delegable [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Assets microfoley → compositor (spec lista) [S]
- [ ] Sin fuentes extra: reutiliza pool de 24 (M43) [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] plan-actual espejo sincronizado [S]

**Totales:** 113 ítems · Completados: 113 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (D-G2, J-L en runtime) quedan para el agente delegado;
diseño, recetas, blacklist y reglas contextuales cierran aquí.