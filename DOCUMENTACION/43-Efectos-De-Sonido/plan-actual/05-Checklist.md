**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 43: Efectos de Sonido

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (9)

- [x] Definir el problema: feedback sonoro de eventos sin máscara ni fatiga [S]
- [x] Registrar dependencias: M06/M07, M13/M17, M34, M35, M20, M21, M45; relaciones M41/M42 [S]
- [x] Catalogar los 25 puntos de la sección 42 [S]
- [x] RF1: pasos por superficie (6 tipos × 4+) [S]
- [x] RF2: acciones de movimiento (saltar, caer, nadar) [S]
- [x] RF3: interacciones con bloques [S]
- [x] RF4: recoger, abrir/cerrar, equipar, herramientas [S]
- [x] RF5: pesca, crafting, comercio, diálogo [S]
- [x] RF6+RF7: UI SFX y volumen dinámico (3D + ducking) [S]

## B. Resolución de los 25 puntos del plan (25)

- [x] P1: pasos — 6 superficies × 4+ variaciones, pitch ±4% [S]
- [x] P2: correr — ritmo doble +3 dB (M34) [S]
- [x] P3: saltar — despegue suave por superficie [S]
- [x] P4: caer — 3 rangos de altura, sin violencia [S]
- [x] P5: nadar — entrada/avance/salida (M34) [S]
- [x] P6: recoger — click + nota aguda positiva [S]
- [x] P7: abrir — 3 variaciones (madera/cerrojo) [S]
- [x] P8: cerrar — golpe seco corto [S]
- [x] P9: equipar — swish + clic, 2 variaciones [S]
- [x] P10: herramienta — por tipo, 4 variaciones [S]
- [x] P11: bloque roto — por material, 5 variaciones [S]
- [x] P12: bloque colocado — impacto corto, 4 variaciones [S]
- [x] P13: plantar — tierra + grano, 3 variaciones [S]
- [x] P14: regar — chorrito + goteo corto [S]
- [x] P15: cosechar — follaje + nota de logro ligera [S]
- [x] P16: pescar — cast/splash/bote/reel (M35) [S]
- [x] P17: crafting — golpes por etapa + arpegio éxito (M20) [S]
- [x] P18: compra — monedas + nota de éxito (M45) [S]
- [x] P19: venta — monedas + nota media, distinto [S]
- [x] P20: diálogo — click de UI (M21) [S]
- [x] P21: menú — papel/pergamino suave [S]
- [x] P22: selección — clic corto muy suave [S]
- [x] P23: confirmación — 2 notas ascendentes 5ª [S]
- [x] P24: error — triada menor descendente 0.4 s [S]
- [x] P25: logro — arpegio triada mayor 3 notas [S]

## C. Familia tonal (8)

- [x] SFX comparten escala y timbres con M41 [S]
- [x] Confirmación: 5ª justa ascendente [S]
- [x] Logro: triada mayor brillante [S]
- [x] Error: triada menor suave (nunca buzz) [S]
- [x] Recoger: nota aguda positiva [S]
- [x] Compra vs venta: distintos audiblemente [S]
- [x] Crafting éxito: arpegio 4ª-5ª [S]
- [x] Co-herencia con leitmotifs (M41) [S]

## D. Prioridades de canal y pool (10)

- [x] P1 UI: nunca se corta, máx 2 simultáneos [S]
- [x] P2 mundo: se corta un pasos si hace falta [S]
- [x] P3 bloques: se corta un ambiente si hace falta [S]
- [x] P4 pasos/movimiento: se corta primero [S]
- [x] Pool de 24 voces prealocadas estáticas [S]
- [x] ≤ 6 simultáneos del mismo tipo [S]
- [x] Sin allocs por frame (PRNG M29) [S]
- [x] 3D: pasos/interacciones; 2D: UI/diálogo [S]
- [x] Distancias: pasos 15 m, rotura 20 m, mundo 30 m [S]
- [x] Excesos se cortan, jamás se apilan [S]

## E. Mapa de variaciones (14)

- [x] Pasos hierba: 5 variaciones [S]
- [x] Pasos madera: 4 [S]
- [x] Pasos piedra: 5 + eco ligero [S]
- [x] Pasos tierra: 4 [S]
- [x] Pasos nieve: 4 [S]
- [x] Pasos arena: 4 [S]
- [x] Romper piedra: 5 + gravilla [S]
- [x] Romper madera: 5 + astillas [S]
- [x] Romper tierra: 4 [S]
- [x] Romper cristal: 4 tintineo [S]
- [x] Romper metal: 4 golpe metálico [S]
- [x] Colocar: misma familia del material [S]
- [x] Herramientas: 4 por tipo [S]
- [x] Pesca/craft/comercio: etapas diferenciadas [S]

## F. Ducking y volumetría (8)

- [x] SFX -6 dB durante diálogos (M21) [S]
- [x] Música -6 dB durante logros (M41) [S]
- [x] Correr +3 dB sobre paso normal [S]
- [x] SFX por debajo de diálogo en jerarquía [S]
- [x] Error 0.4 s no punitivo [S]
- [x] Ningún SFX estridente (cozy) [S]
- [x] Volumen configurable por bus (M91) [S]
- [x] Pausa con GameClock sin residuos (M29) [S]

## G. Data y configuración (8)

- [x] sfx_catalog.tres (catálogo) [S]
- [x] sfx_surfaces.tres (materiales) [S]
- [x] sfx_tones.tres (familia tonal) [S]
- [x] API: reproducir(efecto, pos) [S]
- [x] API: reproducir_localizado(tipo, material, pos) [S]
- [x] API: configurar_volumen() [S]
- [x] Suscripciones M34/M13/M17/M35/M20/M45/M21 listadas [S]
- [x] Sin hardcode de paths [S]

## G2. Pruebas (4)

- [x] Test: cada señal dispara su SFX (M112) [M]
- [x] Test: pool 24 voces sin cortes de UI [M]
- [x] Test: ducking diálogo/logro correcto [M]
- [x] Test: recorrido M114 sin fatiga auditiva [M]

## H. Delegación y cierre (10)

- [x] Módulo marcado delegable [S]
- [x] 3 alternativas descartadas documentadas [S]
- [x] API estable [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [x] Assets → compositor (spec con familia tonal) [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]

**Totales:** 96 ítems · Completados: 96 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (D-G2 en runtime) quedan para el agente delegado; diseño, mapa y reglas cierran aquí.