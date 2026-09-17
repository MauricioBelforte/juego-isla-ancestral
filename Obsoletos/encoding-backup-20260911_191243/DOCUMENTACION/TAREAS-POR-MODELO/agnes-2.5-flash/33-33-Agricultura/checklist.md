# Tareas módulo 33 33-Agricultura

**Estado:** ðŸŸ¡ Con dudas (nÃºcleo + lluvia)

**Items pendientes:** 86

[ ] T-33-001: Definir el problema: agricultura cozy opcional sin hambre castigadora, con ritmo diario del calendario
[ ] T-33-002: Registrar dependencias: M17, M29; relaciones M08, M14, M15, M16, M13, M31, M32, M64, M61, M53, M59, M52
[ ] T-33-003: Catalogar los 25 puntos de la sección 32 del plan maestro
[ ] T-33-004: RF1: tierra cultivable y arada con pala (M13)
[ ] T-33-005: RF3: semillas como ítem de inventario (M14/M15)
[ ] T-33-006: RF5: ciclos por día del GameClock (M29)
[ ] T-33-007: P1: parcelas — reserva por jugador con `reserve_plot()`
[ ] T-33-008: P2: tierra cultivable — bloque TIERRA_ARADA del catálogo M08
[ ] T-33-009: P3: semillas — catálogo M15 con consumo en M14
[ ] T-33-010: P7: fertilizantes — bono benigno que reduce días o mejora calidad
[ ] T-33-011: P11: cultivos especiales — trigo invernal, higos, ancestrales de desbloqueo M22
[ ] T-33-012: P13: flores — decorativas y sujetas a cruce
[ ] T-33-013: P15: híbridos — cruce de flores con reglas legibles (sin RNG oculto)
[ ] T-33-014: P16: calidad — 3 niveles (COMUN/BUENA/EXCELENTE)
[ ] T-33-015: P17: rendimiento — yields por cultivo con bonificación de calidad
[ ] T-33-016: P18: enfermedades — descartadas; el único estado reversible posible es el marchitado experimental
[ ] T-33-017: P21: recetas con cultivos — catálogo M16 (ensaladas, pan, tintes, ofrendas)
[ ] T-33-018: P22: venta — integración M38/M39 con precios por calidad
[ ] T-33-019: P23: semillas raras — reproducibles y con desbloqueo de progresión
[ ] T-33-020: P24: cultivos de isla — palma de coco y flor de coral exclusivas
[ ] T-33-021: P25: agricultura decorativa — helecho ornamental sin rendimiento
[ ] T-33-022: Definir yields y yield_seeds como diccionarios de ítems
[ ] T-33-023: Definir flags is_tree, is_flower, is_ancestral, decorative_only
[ ] T-33-024: Estado SEMILLA inicial con water 0
[ ] T-33-025: Estado LISTA estable sin requerir agua
[ ] T-33-026: transición de árboles frutales LISTA→MADURA con cooldown
[ ] T-33-027: Emitir las 8 señales del contrato en los puntos correctos
[ ] T-33-028: Aplicar -1 de agua por día a cada cultivo
[ ] T-33-029: Detectar SIN_AGUA cuando water_level < water_need
[ ] T-33-030: Detectar DORMANTE cuando la estación no es apta
[ ] T-33-031: Nivel de agua 0..2 persistente por cultivo
[ ] T-33-032: Regadera (M13) suma 1 con feedback visual y sonoro
[ ] T-33-033: Exceso de riego sin castigo (feedback juguetón)
[ ] T-33-034: Visual de suelo húmedo (variante húmeda del bloque TIERRA_ARADA)
[ ] T-33-035: Tooltip "Echó de menos el agua" cuando SIN_AGUA
[ ] T-33-036: Sin muerte por falta de agua (regla innegociable M152)
[ ] T-33-037: VFX de gotas (M52) de bajo costo al regar
[ ] T-33-038: Pala (M13) convierte TIERRA en TIERRA_ARADA
[ ] T-33-039: Interacción F sobre tierra arada abre selector de semillas (M70/M53)
[ ] T-33-040: Interacción sobre cultivo en LISTA cosecha
[ ] T-33-041: Interacción sobre cultivo en otros estados muestra hint contextual
[ ] T-33-042: Animación de la herramienta sincronizada con el evento (M44)
[ ] T-33-043: Cancelación segura del selector sin consumir semillas
[ ] T-33-044: Rango de uso limitado al alcance del jugador (M11)
[ ] T-33-045: Añadir bloque TIERRA_ARADA al catálogo de bloques
[ ] T-33-046: Añadir variante húmeda de tierra arada
[ ] T-33-047: Aplicar dif de chunk al convertir tierra
[ ] T-33-048: Colisión correcta de la tierra arada (no es un hueco)
[ ] T-33-049: Actualización parcial del chunk al cosechar (vuelve a tierra arada)
[ ] T-33-050: Nieve (M32/M08) sobre tierra arada no borra el estado
[ ] T-33-051: Notificación de objetos obtenidos al cosechar (M53)
[ ] T-33-052: Iconos de cultivos y semillas definidos en M45/M46
[ ] T-33-053: Venta de cosechas con precios por calidad (M38/M39)
[ ] T-33-054: Cultivo en DORMANTE al pasar a estación apta: retoma sin pérdida
[ ] T-33-055: Sequía prolongada: pausa indefinida sin muerte
[ ] T-33-056: Pisoteo de NPC: agitación visual sin pérdida de progreso
[ ] T-33-057: Navegación M64 evita celdas cultivadas cuando hay ruta alternativa
[ ] T-33-058: Cosecha con inventario lleno: sobrante devuelto con notificación
[ ] T-33-059: Árbol frutal en invierno: entra en DORMANTE y conserva cooldown
[ ] T-33-060: Borrado de parcela (M17) con cultivos activos: aviso previo y devolución de semillas
[ ] T-33-061: Guardado a mitad del avance de día: el tick es idempotente
[ ] T-33-062: Evaluación diaria ≤ 2 ms con 400 cultivos
[ ] T-33-063: Visual por MultiMesh agrupado por especie/etapa
[ ] T-33-064: LOD de 2 niveles para instancias
[ ] T-33-065: Sin procesamiento por frame en estados pausados
[ ] T-33-066: Prueba de stress: 400 cultivos + lluvia global en 1 tick
[ ] T-33-067: HUD agrícola: indicador de estado por cultivo apuntado (M53)
[ ] T-33-068: Notificación cozy al madurar cultivos
[ ] T-33-069: Tooltip con hints legibles y cálidos
[ ] T-33-070: Tutorial amable: "La comida es opcional aqui" (M92, M152)
[ ] T-33-071: Sonido de arar (M43/M44) con capa ASMR de tierra
[ ] T-33-072: Sonido de regar con goteo suave
[ ] T-33-073: Sonido de cosecha satisfactoria
[ ] T-33-074: VFX de polvo al arar y brillo al madurar (M52)
[ ] T-33-075: Animación de sway según el viento del clima (M31/M32)
[ ] T-33-076: Test: determinismo entre guardado y recarga (mismo día, mismo estado)
[ ] T-33-077: Test: 4 estaciones con cultivo de ventana parcial
[ ] T-33-078: Test: 30 días sin agua: pausa, nunca muerte
[ ] T-33-079: Test: pisoteo de NPC sobre campo con ruta y sin ruta
[ ] T-33-080: Test: invierno con nieve sobre tierra arada
[ ] T-33-081: Test: inventario lleno al cosechar
[ ] T-33-082: 5 alternativas descartadas documentadas en 02-Analisis
[ ] T-33-083: Prototipo sugerido: 3 cultivos + riego manual + avance diario
[ ] T-33-084: 01-Requerimientos creado y firmado
[ ] T-33-085: 02-Analisis, 03-Diseno y 04-Codigo creados y firmados
[ ] T-33-086: 05-Checklist creado y firmado (este archivo)
