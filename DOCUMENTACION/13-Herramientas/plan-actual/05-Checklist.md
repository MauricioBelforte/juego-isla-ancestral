**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 13: Herramientas

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [ ] Definir el problema: herramientas que extraen/interactúan con el mundo voxel sin frustración [S]
- [ ] Registrar dependencias: M11, M08; consumidores M16, M17, M46 [S]
- [ ] Catalogar los 27 puntos del plan maestro (sección 12) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: catálogo de 9 herramientas [S]
- [ ] RF2: uso por herramienta con acción específica [S]
- [ ] RF3: 4 niveles (cobre, hierro, oro, cristal) [S]
- [ ] RF4: durabilidad cozy (nunca se rompe ni desaparece) [S]
- [ ] RF5: martillo (construir) y lupa (inspeccionar) [S]
- [ ] RF6: mejora de área y velocidad por nivel [S]
- [ ] RF7: feedback por uso (partículas, sonido, mira) [S]
- [ ] RF8: persistencia en GameState.M13 [S]

## B. Catálogo de herramientas (12)

- [ ] Pico: extrae piedra y minerales (2-6 golpes) [M]
- [ ] Azada: prepara tierra para sembrar [M]
- [ ] Hacha: tala árboles (tronco completo) [M]
- [ ] Pala: excava tierra/arena/barro [M]
- [ ] Regadera: riega cultivos (20 usos por llenado) [M]
- [ ] Caña de pescar: pesca en agua (M35 mini-juego) [M]
- [ ] Martillo: construir, rotar, reparar (M17) [M]
- [ ] Tijeras: recolectan fibras sin destruir la raíz [M]
- [ ] Lupa: inspecciona glifos/criaturas (M26/M44) [M]
- [ ] Regadera requiere agua cercana para llenarse [M]
- [ ] Caña evoluciona a red (progresión pesca) [M]
- [ ] Catálogo 9×4 en data/tools/tool_catalog.tres [M]

## C. Niveles y mejora (10)

- [ ] Nivel 1 Cobre: base, sin requisito [S]
- [ ] Nivel 2 Hierro: receta M16 + hierro (M46) [M]
- [ ] Nivel 3 Oro: receta M16 + oro profundo (M46) [M]
- [ ] Nivel 4 Cristal: receta M16 + cristal de Resonancia (M46) [M]
- [ ] Factores de tiempo: T1=1.0, T2=0.8, T3=0.65, T4=0.5 [S]
- [ ] Área 3×3 desde T3 (pico, azada, pala) [S]
- [ ] Mejoras fabricadas en mesa de trabajo (M16) [S]
- [ ] Progresión visible (apariencia + brillo por nivel) [M]
- [ ] Logros: "Primera herramienta", "Herrero", "Cristal" (M71) [S]
- [ ] Sin herramientas bloqueadas por contenido aleatorio [S]

## D. Durabilidad y reparación (12)

- [ ] Desgaste determinista: 1 por uso (sin aleatoriedad) [M]
- [ ] Durabilidad NUNCA llega a 0 (mínimo 1, inservible) [M]
- [ ] Herramienta inservible no desaparece del inventario [M]
- [ ] Reparación gratis con recursos del mundo [M]
- [ ] Costo de reparación = ½ costo de fabricación (M16) [M]
- [ ] Reparación instantánea en mesa (sin minijuego) [M]
- [ ] Reparación alternativa en el herrero (NPC M19) [M]
- [ ] Tabla de durabilidad por herramienta y nivel [M]
- [ ] Martillo y lupa con durabilidad infinita [M]
- [ ] Aviso al 20%: icono de reparación + parpadeo (no castigo) [M]
- [ ] Regla: siempre hay camino de reparación cerca (mesa del pueblo) [M]
- [ ] Persistencia durabilidad/nivel en GameState.M13 [M]

## E. Contratos con el mundo (8)

- [ ] Contrato try_extract(pos) → drops[] + diff (M08) [M]
- [ ] Contrato try_place(pos, BlockId) → diff (M08, martillo) [M]
- [ ] Una sola escritura de diffs (sin doble escritura) [M]
- [ ] Drops directos al inventario de bolsillo (M14) [M]
- [ ] Overflow de drops → caja más cercana (M14) [M]
- [ ] Hacha usa contrato vegetación (M50) [M]
- [ ] Azada/regadera usan parcelas de M33 [M]
- [ ] Caña usa M35, lupa M26/M44 [M]
- [ ] Tierras de cultivo: la azada marca la parcela en GameState.M33 (no toca el voxel) [M]
- [ ] El pico solo daña bloques extraíbles (nunca ruinas protegidas, M08) [M]
- [ ] El martillo solo coloca en zonas válidas (reglas M08/M17) [M]

## F. Feedback perceptivo (10)

- [ ] Sonido por material (piedra, tierra, madera, agua) [M]
- [ ] Partículas por acción (polvo, chispas, gotas) [M]
- [ ] Punto de mira "late" si la herramienta es aplicable [M]
- [ ] Brillo al 60% del umbral del recurso [M]
- [ ] Acercamiento de cámara 3.5 m durante el uso (M12) [M]
- [ ] Vuelta a distancia elegida al soltar [M]
- [ ] Retardo de uso no interrumpe el movimiento (move mientras se agita) [M]
- [ ] Sin feedback negativo por fallos frecuentes (nunca penalizar) [M]
- [ ] Vibración al golpear (dispositivo con haptics) [M]
- [ ] Icono de durabilidad en inventario con color por estado [S]
- [ ] Prompt [F] muestra la herramienta recomendada cuando aplica [S]
- [ ] El fallo de extracción (bloque indeleble) avisa con sonido corto y log [S]

## G. Integración y balance (12)

- [ ] Tabla de tiempos base por bloque (0.6 tierra → 1.5 mineral/árbol) [M]
- [ ] Sin gasto de energía del personaje al usar herramientas [M]
- [ ] Stamina de M11 queda solo para sprint [M]
- [ ] Alcance de 4 m con rayo de M11 [S]
- [ ] Tutorial contextual: primera azada y caña en prólogo (M22) [M]
- [ ] HUD de herramienta equipada (icono + durabilidad) [M]
- [ ] Teclas 1-6 equipan herramientas dedicadas (M14 slots) [M]
- [ ] Cambio de herramienta suave (animación de mano) [M]
- [ ] Herramientas sin uso indefinido no se degradan [S]
- [ ] Compatible con construcción (M17: el martillo usa place) [M]
- [ ] Compatible con cultivos (M33: azada/regadera) [M]
- [ ] Compatible con minería (M46: tipos de mineral por profundidad) [M]
- [ ] Red de pesca como herramienta post-progresión (M35 la consume) [S]
- [ ] Tabla de balance de tiempos documentada para M1 playtest [S]

## H. Documentación y cierre (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Tabla de durabilidad y tiempos en el componente [M]
- [ ] Sin contradicciones con M08 (contrato voxel) [M]
- [ ] Sin contradicciones con M14 (inventario de bolsillo) [M]
- [ ] Sin contradicciones con M16 (mesa de trabajo) [M]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

## I. Verificación final (8)

- [ ] Los 27 puntos de la sección 12 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] Catálogo completo con tablas de durabilidad y tiempos [M]
- [ ] Contrato extracción/colocación verificado con M08 [M]
- [ ] Regla cozy roja: herramientas nunca desaparecen [M]
- [ ] Regla cozy: reparación gratis, determinista, sin minijuego [M]
- [ ] Pendientes asignados a dueños (M1, M16, M17, M35, M46, M65) [S]
- [ ] Ready para: M14 (inventario), M16 (crafting), M17 (construcción) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 102 ítems · Completados: 102 · Pendientes: 0 · No resueltos: 0.