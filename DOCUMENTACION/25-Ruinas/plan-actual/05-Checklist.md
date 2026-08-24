# 05 — Checklist — M25: Ruinas (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Kit modular

- [ ] Definir el kit base de ≤ 40 piezas reutilizables [M]
- [ ] Definir pivote en esquina inferior izquierda por pieza [S]
- [ ] Definir snaps por cara en cada pieza [M]
- [ ] Implementar validación de pivotes en Editor [M]
- [ ] Implementar validación de snaps en Editor [M]
- [ ] Implementar validación de traslapes en Editor [M]
- [ ] Implementar fallo de build si la validación falla [S]
- [ ] Definir grupo de suelos (losa, rota, intermedia, umbral) [S]
- [ ] Definir grupo de muros (recto, esquina, roto, vano, alto) [S]
- [ ] Definir grupo de aperturas (arco, puerta, ventana, pasaje) [S]
- [ ] Definir grupo de soportes (columna, pilar roto, contrafuerte) [S]
- [ ] Definir grupo de techos (a 2 aguas, plano, crestería) [S]
- [ ] Definir grupo de escaleras (recta, L, rampa) [S]
- [ ] Definir grupo de decoración (balaustrada, cornisa, estela, altar, banco) [S]
- [ ] Definir grupo de canal (canal de agua, compuerta seca) [S]
- [ ] Documentar el kit modular en el plan-actual [S]

## Ruinas pequeñas y medianas

- [ ] Diseñar chozas/ermitas (3-5 piezas, 1 puzzle Exploración) [S]
- [ ] Diseñar caseríos (8-15 piezas, 1-2 puzzles Ritual) [M]
- [ ] Diseñar atalayas con vista de bioma [S]
- [ ] Definir 2-4 ruinas por bioma [S]
- [ ] Documentar ruinas pequeñas y medianas [S]

## Ruinas grandes y templos

- [ ] Diseñar templos con plan en cruz [M]
- [ ] Definir vestíbulo y sancta del templo [S]
- [ ] Definir 1 puzzle de luz obligatorio por templo (M24) [S]
- [ ] Diseñar fortines medianos [S]
- [ ] Diseñar templos/fortines grandes (25-60 piezas) [M]
- [ ] Definir 2-3 puzzles + 1 multilateral en templos grandes [M]
- [ ] Documentar ruinas grandes y templos [S]

## Ciudades antiguas

- [ ] Diseñar ciudades antiguas en 3-5 bloques urbanos [M]
- [ ] Definir calles perimetrales jugables [S]
- [ ] Definir plaza central con acueducto [S]
- [ ] Definir 1 puzzle central en la plaza [S]
- [ ] Documentar ciudades antiguas [S]

## Observatorios, estaciones, faros y puentes

- [ ] Diseñar observatorio con domo y agujero cenital [S]
- [ ] Definir anillos de piedra con alineación solar (M31) [M]
- [ ] Diseñar estaciones como amarre de vehículos (M66) [S]
- [ ] Diseñar faro con haz fisicalizable (luz M24) [M]
- [ ] Definir linterna de memoria en el faro (narrativa M22) [S]
- [ ] Diseñar puente de arco con validación estructural [S]
- [ ] Diseñar puente colgante de 3 cables [S]
- [ ] Documentar observatorios, estaciones, faros y puentes [S]

## Jardines, edificios, bibliotecas y talleres

- [ ] Diseñar jardines en terrazas con canales de agua [M]
- [ ] Definir puzzle de agua suave en el jardín (M24) [S]
- [ ] Diseñar edificios abandonados de 2 plantas [S]
- [ ] Definir balcón roto del edificio [S]
- [ ] Definir interiores solo donde necesarios [S]
- [ ] Diseñar biblioteca como cofre de lore [S]
- [ ] Definir mural del mapa en la biblioteca [S]
- [ ] Diseñar taller con hornos y yunques rotos [S]
- [ ] Definir clues de herramientas del inventario (M24) [S]
- [ ] Documentar jardines, edificios, bibliotecas y talleres [S]

## Cámaras secretas y pasajes ocultos

- [ ] Diseñar cámaras secretas bajo placas/estatuas [M]
- [ ] Definir 2+ caminos de acceso a cada cámara (M66) [M]
- [ ] Diseñar pasajes ocultos tras puertas falsas [S]
- [ ] Definir pista ambiental para pasajes (viento M32) [S]
- [ ] Diseñar soterrados en ruinas grandes [S]
- [ ] Documentar cámaras secretas y pasajes ocultos [S]

## Murales, inscripciones y objetos arqueológicos

- [ ] Diseñar 12 murales icónicos de la civilización [M]
- [ ] Definir 3 épocas en los murales [S]
- [ ] Definir registro de murales en el diario [S]
- [ ] Diseñar 30-60 glifos de inscripciones [M]
- [ ] Definir catálogo/glosario de glifos para M24 [M]
- [ ] Diseñar 25 objetos arqueológicos [M]
- [ ] Definir 3 estados del objeto (enterrado→expuesto→museo) [M]
- [ ] Definir copia única de cada objeto (M66 cofre) [M]
- [ ] Documentar murales, inscripciones y objetos [S]

## Sistemas de activación

- [ ] Diseñar palanca (cerrojo de puerta) [S]
- [ ] Diseñar anillo giratorio (sello de cámara) [S]
- [ ] Diseñar estrella giradora (puerta de templo) [S]
- [ ] Diseñar llave-runa (inscripción que bebe glifo) [S]
- [ ] Diseñar timón de agua (compuertas) [S]
- [ ] Diseñar martillo de piedra (percutir pedestal) [S]
- [ ] Diseñar vela triple (orden de velas) [S]
- [ ] Diseñar puerta falsa (rodar a cámara) [S]
- [ ] Definir anclaje de activadores al framework M24 [M]
- [ ] Documentar sistemas de activación [S]

## Progresión de descubrimiento

- [ ] Definir estados: NoDescubierta → Descubierta → Explorada → Completada [M]
- [ ] Implementar detección de descubrimiento a 15 m [S]
- [ ] Implementar hint de horizonte al descubrir (M63) [S]
- [ ] Implementar transición a Explorada al 50% de puzzles [M]
- [ ] Implementar transición a Completada con relicto guardado [M]
- [ ] Implementar eventos de transición (diario, mapa M58, museo M36) [M]
- [ ] Implementar guardado atómico en cada transición [M]
- [ ] Implementar persistencia del estado por ruina [M]
- [ ] Documentar la progresión de descubrimiento [S]

## Variantes y conexiones entre ruinas

- [ ] Definir 3 paletas visuales (época temprana/media/tardía) [S]
- [ ] Implementar variantes de paleta sin geometría nueva [M]
- [ ] Definir 2-3 configuraciones de puzzle por ruina grande (seed) [M]
- [ ] Implementar variante de puzzle por seed de partida [M]
- [ ] Diseñar caminos de 2-4 tramos entre ruinas [M]
- [ ] Definir nodos de conexión con M28 (caminos) [M]
- [ ] Definir validación de caminos con NavigationServer3D [M]
- [ ] Diseñar conexión costera por faros y puentes [S]
- [ ] Documentar variantes y conexiones [S]

## Integración y presupuestos

- [ ] Integrar con M24 (puzzles y framework emisor→receptor) [M]
- [ ] Integrar con M26 (templo subterráneo, sin rozar) [S]
- [ ] Integrar con M28 (caminos) [M]
- [ ] Integrar con M31 (alineación solar en observatorios) [S]
- [ ] Integrar con M32 (viento/lluvia en pasajes y jardines) [S]
- [ ] Integrar con M36 (museo: vitrinas para objetos) [M]
- [ ] Integrar con M45/M47 (kit de referencia para assets) [M]
- [ ] Implementar LOD 0-2 vía M63 (culling por región) [M]
- [ ] Implementar sin Update por ruina (estática) [S]
- [ ] Implementar sin costos de simulación en ruinas [S]
- [ ] Documentar integración y presupuestos [S]

## Testings y documentación

- [ ] Diseñar 06-Plan-Testings.md: validación del kit (pivotes/snaps) [M]
- [ ] Diseñar 06-Plan-Testings.md: armado de los 13 tipos [M]
- [ ] Diseñar 06-Plan-Testings.md: progresión de descubrimiento [M]
- [ ] Diseñar 06-Plan-Testings.md: edge cases (ruina sin puzzle, cofre) [M]
- [ ] Diseñar 06-Plan-Testings.md: pruebas de rendimiento (LOD) [M]
- [ ] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [ ] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 25 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
