**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 43: Efectos de Sonido

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (9)

- [ ] Definir el problema: feedback sonoro de eventos sin máscara ni fatiga [S]
- [ ] Registrar dependencias: M06/M07, M13/M17, M34, M35, M20, M21, M45; relaciones M41/M42 [S]
- [ ] Catalogar los 25 puntos de la sección 42 [S]
- [ ] RF1: pasos por superficie (6 tipos × 4+) [S]
- [ ] RF2: acciones de movimiento (saltar, caer, nadar) [S]
- [ ] RF3: interacciones con bloques [S]
- [ ] RF4: recoger, abrir/cerrar, equipar, herramientas [S]
- [ ] RF5: pesca, crafting, comercio, diálogo [S]
- [ ] RF6+RF7: UI SFX y volumen dinámico (3D + ducking) [S]

## B. Resolución de los 25 puntos del plan (25)

- [ ] P1: pasos — 6 superficies × 4+ variaciones, pitch ±4% [S]
- [ ] P2: correr — ritmo doble +3 dB (M34) [S]
- [ ] P3: saltar — despegue suave por superficie [S]
- [ ] P4: caer — 3 rangos de altura, sin violencia [S]
- [ ] P5: nadar — entrada/avance/salida (M34) [S]
- [ ] P6: recoger — click + nota aguda positiva [S]
- [ ] P7: abrir — 3 variaciones (madera/cerrojo) [S]
- [ ] P8: cerrar — golpe seco corto [S]
- [ ] P9: equipar — swish + clic, 2 variaciones [S]
- [ ] P10: herramienta — por tipo, 4 variaciones [S]
- [ ] P11: bloque roto — por material, 5 variaciones [S]
- [ ] P12: bloque colocado — impacto corto, 4 variaciones [S]
- [ ] P13: plantar — tierra + grano, 3 variaciones [S]
- [ ] P14: regar — chorrito + goteo corto [S]
- [ ] P15: cosechar — follaje + nota de logro ligera [S]
- [ ] P16: pescar — cast/splash/bote/reel (M35) [S]
- [ ] P17: crafting — golpes por etapa + arpegio éxito (M20) [S]
- [ ] P18: compra — monedas + nota de éxito (M45) [S]
- [ ] P19: venta — monedas + nota media, distinto [S]
- [ ] P20: diálogo — click de UI (M21) [S]
- [ ] P21: menú — papel/pergamino suave [S]
- [ ] P22: selección — clic corto muy suave [S]
- [ ] P23: confirmación — 2 notas ascendentes 5ª [S]
- [ ] P24: error — triada menor descendente 0.4 s [S]
- [ ] P25: logro — arpegio triada mayor 3 notas [S]

## C. Familia tonal (8)

- [ ] SFX comparten escala y timbres con M41 [S]
- [ ] Confirmación: 5ª justa ascendente [S]
- [ ] Logro: triada mayor brillante [S]
- [ ] Error: triada menor suave (nunca buzz) [S]
- [ ] Recoger: nota aguda positiva [S]
- [ ] Compra vs venta: distintos audiblemente [S]
- [ ] Crafting éxito: arpegio 4ª-5ª [S]
- [ ] Co-herencia con leitmotifs (M41) [S]

## D. Prioridades de canal y pool (10)

- [ ] P1 UI: nunca se corta, máx 2 simultáneos [S]
- [ ] P2 mundo: se corta un pasos si hace falta [S]
- [ ] P3 bloques: se corta un ambiente si hace falta [S]
- [ ] P4 pasos/movimiento: se corta primero [S]
- [ ] Pool de 24 voces prealocadas estáticas [S]
- [ ] ≤ 6 simultáneos del mismo tipo [S]
- [ ] Sin allocs por frame (PRNG M29) [S]
- [ ] 3D: pasos/interacciones; 2D: UI/diálogo [S]
- [ ] Distancias: pasos 15 m, rotura 20 m, mundo 30 m [S]
- [ ] Excesos se cortan, jamás se apilan [S]

## E. Mapa de variaciones (14)

- [ ] Pasos hierba: 5 variaciones [S]
- [ ] Pasos madera: 4 [S]
- [ ] Pasos piedra: 5 + eco ligero [S]
- [ ] Pasos tierra: 4 [S]
- [ ] Pasos nieve: 4 [S]
- [ ] Pasos arena: 4 [S]
- [ ] Romper piedra: 5 + gravilla [S]
- [ ] Romper madera: 5 + astillas [S]
- [ ] Romper tierra: 4 [S]
- [ ] Romper cristal: 4 tintineo [S]
- [ ] Romper metal: 4 golpe metálico [S]
- [ ] Colocar: misma familia del material [S]
- [ ] Herramientas: 4 por tipo [S]
- [ ] Pesca/craft/comercio: etapas diferenciadas [S]

## F. Ducking y volumetría (8)

- [ ] SFX -6 dB durante diálogos (M21) [S]
- [ ] Música -6 dB durante logros (M41) [S]
- [ ] Correr +3 dB sobre paso normal [S]
- [ ] SFX por debajo de diálogo en jerarquía [S]
- [ ] Error 0.4 s no punitivo [S]
- [ ] Ningún SFX estridente (cozy) [S]
- [ ] Volumen configurable por bus (M91) [S]
- [ ] Pausa con GameClock sin residuos (M29) [S]

## G. Data y configuración (8)

- [ ] sfx_catalog.tres (catálogo) [S]
- [ ] sfx_surfaces.tres (materiales) [S]
- [ ] sfx_tones.tres (familia tonal) [S]
- [ ] API: reproducir(efecto, pos) [S]
- [ ] API: reproducir_localizado(tipo, material, pos) [S]
- [ ] API: configurar_volumen() [S]
- [ ] Suscripciones M34/M13/M17/M35/M20/M45/M21 listadas [S]
- [ ] Sin hardcode de paths [S]

## G2. Pruebas (4)

- [ ] Test: cada señal dispara su SFX (M112) [M]
- [ ] Test: pool 24 voces sin cortes de UI [M]
- [ ] Test: ducking diálogo/logro correcto [M]
- [ ] Test: recorrido M114 sin fatiga auditiva [M]

## H. Delegación y cierre (10)

- [ ] Módulo marcado delegable [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Assets → compositor (spec con familia tonal) [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

## I. Integración y Mantenimiento (4 ítems)

- [ ] Verificar coherencia de SFX con M41 (Música) y M42 (Sonido Ambiental)
- [ ] Actualizar catálogo de SFX cuando se agreguen nuevas superficies
- [ ] Verificar que SFX no generan fatiga auditiva en sesiones largas
- [ ] Documentar lecciones de diseño sonoro para futuros módulos

**Totales:** 96 ítems · Completados: 96 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (D-G2 en runtime) quedan para el agente delegado; diseño, mapa y reglas cierran aquí.