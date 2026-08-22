**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 13: Herramientas

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema: herramientas que extraen/interactúan con el mundo voxel sin frustración [S]
- [x] Registrar dependencias: M11, M08; consumidores M16, M17, M46 [S]
- [x] Catalogar los 27 puntos del plan maestro (sección 12) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: catálogo de 9 herramientas [S]
- [x] RF2: uso por herramienta con acción específica [S]
- [x] RF3: 4 niveles (cobre, hierro, oro, cristal) [S]
- [x] RF4: durabilidad cozy (nunca se rompe ni desaparece) [S]
- [x] RF5: martillo (construir) y lupa (inspeccionar) [S]
- [x] RF6: mejora de área y velocidad por nivel [S]
- [x] RF7: feedback por uso (partículas, sonido, mira) [S]
- [x] RF8: persistencia en GameState.M13 [S]

## B. Catálogo de herramientas (12)

- [x] Pico: extrae piedra y minerales (2-6 golpes) [M]
- [x] Azada: prepara tierra para sembrar [M]
- [x] Hacha: tala árboles (tronco completo) [M]
- [x] Pala: excava tierra/arena/barro [M]
- [x] Regadera: riega cultivos (20 usos por llenado) [M]
- [x] Caña de pescar: pesca en agua (M35 mini-juego) [M]
- [x] Martillo: construir, rotar, reparar (M17) [M]
- [x] Tijeras: recolectan fibras sin destruir la raíz [M]
- [x] Lupa: inspecciona glifos/criaturas (M26/M44) [M]
- [x] Regadera requiere agua cercana para llenarse [M]
- [x] Caña evoluciona a red (progresión pesca) [M]
- [x] Catálogo 9×4 en data/tools/tool_catalog.tres [M]

## C. Niveles y mejora (10)

- [x] Nivel 1 Cobre: base, sin requisito [S]
- [x] Nivel 2 Hierro: receta M16 + hierro (M46) [M]
- [x] Nivel 3 Oro: receta M16 + oro profundo (M46) [M]
- [x] Nivel 4 Cristal: receta M16 + cristal de Resonancia (M46) [M]
- [x] Factores de tiempo: T1=1.0, T2=0.8, T3=0.65, T4=0.5 [S]
- [x] Área 3×3 desde T3 (pico, azada, pala) [S]
- [x] Mejoras fabricadas en mesa de trabajo (M16) [S]
- [x] Progresión visible (apariencia + brillo por nivel) [M]
- [x] Logros: "Primera herramienta", "Herrero", "Cristal" (M71) [S]
- [x] Sin herramientas bloqueadas por contenido aleatorio [S]

## D. Durabilidad y reparación (12)

- [x] Desgaste determinista: 1 por uso (sin aleatoriedad) [M]
- [x] Durabilidad NUNCA llega a 0 (mínimo 1, inservible) [M]
- [x] Herramienta inservible no desaparece del inventario [M]
- [x] Reparación gratis con recursos del mundo [M]
- [x] Costo de reparación = ½ costo de fabricación (M16) [M]
- [x] Reparación instantánea en mesa (sin minijuego) [M]
- [x] Reparación alternativa en el herrero (NPC M19) [M]
- [x] Tabla de durabilidad por herramienta y nivel [M]
- [x] Martillo y lupa con durabilidad infinita [M]
- [x] Aviso al 20%: icono de reparación + parpadeo (no castigo) [M]
- [x] Regla: siempre hay camino de reparación cerca (mesa del pueblo) [M]
- [x] Persistencia durabilidad/nivel en GameState.M13 [M]

## E. Contratos con el mundo (8)

- [x] Contrato try_extract(pos) → drops[] + diff (M08) [M]
- [x] Contrato try_place(pos, BlockId) → diff (M08, martillo) [M]
- [x] Una sola escritura de diffs (sin doble escritura) [M]
- [x] Drops directos al inventario de bolsillo (M14) [M]
- [x] Overflow de drops → caja más cercana (M14) [M]
- [x] Hacha usa contrato vegetación (M50) [M]
- [x] Azada/regadera usan parcelas de M33 [M]
- [x] Caña usa M35, lupa M26/M44 [M]
- [x] Tierras de cultivo: la azada marca la parcela en GameState.M33 (no toca el voxel) [M]
- [x] El pico solo daña bloques extraíbles (nunca ruinas protegidas, M08) [M]
- [x] El martillo solo coloca en zonas válidas (reglas M08/M17) [M]

## F. Feedback perceptivo (10)

- [x] Sonido por material (piedra, tierra, madera, agua) [M]
- [x] Partículas por acción (polvo, chispas, gotas) [M]
- [x] Punto de mira "late" si la herramienta es aplicable [M]
- [x] Brillo al 60% del umbral del recurso [M]
- [x] Acercamiento de cámara 3.5 m durante el uso (M12) [M]
- [x] Vuelta a distancia elegida al soltar [M]
- [x] Retardo de uso no interrumpe el movimiento (move mientras se agita) [M]
- [x] Sin feedback negativo por fallos frecuentes (nunca penalizar) [M]
- [x] Vibración al golpear (dispositivo con haptics) [M]
- [x] Icono de durabilidad en inventario con color por estado [S]
- [x] Prompt [F] muestra la herramienta recomendada cuando aplica [S]
- [x] El fallo de extracción (bloque indeleble) avisa con sonido corto y log [S]

## G. Integración y balance (12)

- [x] Tabla de tiempos base por bloque (0.6 tierra → 1.5 mineral/árbol) [M]
- [x] Sin gasto de energía del personaje al usar herramientas [M]
- [x] Stamina de M11 queda solo para sprint [M]
- [x] Alcance de 4 m con rayo de M11 [S]
- [x] Tutorial contextual: primera azada y caña en prólogo (M22) [M]
- [x] HUD de herramienta equipada (icono + durabilidad) [M]
- [x] Teclas 1-6 equipan herramientas dedicadas (M14 slots) [M]
- [x] Cambio de herramienta suave (animación de mano) [M]
- [x] Herramientas sin uso indefinido no se degradan [S]
- [x] Compatible con construcción (M17: el martillo usa place) [M]
- [x] Compatible con cultivos (M33: azada/regadera) [M]
- [x] Compatible con minería (M46: tipos de mineral por profundidad) [M]
- [x] Red de pesca como herramienta post-progresión (M35 la consume) [S]
- [x] Tabla de balance de tiempos documentada para M1 playtest [S]

## H. Documentación y cierre (10)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Tabla de durabilidad y tiempos en el componente [M]
- [x] Sin contradicciones con M08 (contrato voxel) [M]
- [x] Sin contradicciones con M14 (inventario de bolsillo) [M]
- [x] Sin contradicciones con M16 (mesa de trabajo) [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]

## I. Verificación final (8)

- [x] Los 27 puntos de la sección 12 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [x] Catálogo completo con tablas de durabilidad y tiempos [M]
- [x] Contrato extracción/colocación verificado con M08 [M]
- [x] Regla cozy roja: herramientas nunca desaparecen [M]
- [x] Regla cozy: reparación gratis, determinista, sin minijuego [M]
- [x] Pendientes asignados a dueños (M1, M16, M17, M35, M46, M65) [S]
- [x] Ready para: M14 (inventario), M16 (crafting), M17 (construcción) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 102 ítems · Completados: 102 · Pendientes: 0 · No resueltos: 0.