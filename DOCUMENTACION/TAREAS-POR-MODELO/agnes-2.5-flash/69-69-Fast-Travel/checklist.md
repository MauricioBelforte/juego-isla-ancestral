# Tareas módulo 69 69-Fast-Travel

**Estado:** 🟡 Con dudas

**Items pendientes:** 132

[ ] T-69-001: Definir el problema: desplazamiento rápido sin fatiga ni bypass
[ ] T-69-002: Registrar dependencias: M28, M29, M31
[ ] T-69-003: Catalogar los 13 puntos de la sección 68
[ ] T-69-004: RF1: viajes rápidos disponibles progresivamente
[ ] T-69-005: RF2: punto de viaje marcable
[ ] T-69-006: RF3: restricciones de acceso por estado
[ ] T-69-007: RF4: costo de viaje (recursos o tiempo)
[ ] T-69-008: RF5: teletransporte a deidades
[ ] T-69-009: RF6: cancelación por parte del jugador
[ ] T-69-010: RF7: guardado automático del último punto
[ ] T-69-011: RF8: interfaz clara y tranquila
[ ] T-69-012: RF9: pausa automática en single-player
[ ] T-69-013: RF10: integración con ciclo día/noche
[ ] T-69-014: RF10: accesibilidad (ataljo teclado, menú intuitivo)
[ ] T-69-015: P2: puntos de viaje desbloqueados al descubrir ubicaciones
[ ] T-69-016: P3: costo en recursos o tiempo por viaje
[ ] T-69-017: P4: transición visual suave (bruma/desvanecimiento)
[ ] T-69-018: P5: pantalla de carga minimalista con nombre destino
[ ] T-69-019: P6: tiempos de viaje instantáneo con tiempo simulado opcional
[ ] T-69-020: P7: cancelación a mitad de animación
[ ] T-69-021: P8: bloqueado durante combate/eventos críticos
[ ] T-69-022: P9: guardado del último punto por sesión
[ ] T-69-023: P10: evitación de bypass de eventos críticos
[ ] T-69-024: P11: evitación de ruptura de misiones activas
[ ] T-69-025: P12: prueba de navegación a todos los destinos
[ ] T-69-026: SFX coherente con M41/M42/M43 (familia tonal compartida)
[ ] T-69-027: Confirmación de viaje: tono ascendente cálido
[ ] T-69-028: Error en viaje: tono descendente suave, no agresivo
[ ] T-69-029: Interfaz con family tones M45
[ ] T-69-030: Lógica O(1) para lookup de destinos
[ ] T-69-031: Sin cálculos complejos por frame
[ ] T-69-032: Pool de estados (disponible/bloqueado/cooldown)
[ ] T-69-033: Integración con M29/M31 sin conflictos
[ ] T-69-034: Test de pool: estados máx sin memory leak
[ ] T-69-035: Test de rendimiento: < 16ms por operación de viaje
[ ] T-69-036: Test de integración: día/noche y calendario
[ ] T-69-037: Test de costo: recursos descontados correctamente
[ ] T-69-038: Test de restricciones: bloqueo durante estados prohibidos
[ ] T-69-039: Test de transición: animación sin jumps visuales
[ ] T-69-040: Pueblo: desbloqueado tras área inicial
[ ] T-69-041: Santuario: desbloqueado tras visitar a pie
[ ] T-69-042: Isla: desbloqueado tras explorar
[ ] T-69-043: Bosque: desbloqueado al descubrir 3+ puntos bioma
[ ] T-69-044: Montaña: desbloqueado al alcanzar cumbres
[ ] T-69-045: Desierto: desbloqueado al descubrir oasis
[ ] T-69-046: Cueva: desbloqueado al explorar primeras cuevas
[ ] T-69-047: Playa: desbloqueado al descubrir costa
[ ] T-69-048: Valle: desbloqueado en zonas bajas del mapa
[ ] T-69-049: Ciudadela: punto final/late-game
[ ] T-69-050: Lista completa ordenada alfabéticamente
[ ] T-69-051: Buscar por nombre en el menú
[ ] T-69-052: Acceso por atajo de teclado rápido
[ ] T-69-053: Prioridad por proximidad/costo
[ ] T-69-054: SFX -6 dB durante diálogos (M21) si se cancela viaje
[ ] T-69-055: Correr +3 dB sobre paso normal
[ ] T-69-056: SFX por debajo de diálogo en jerarquía
[ ] T-69-057: Error 0.4 s no punitivo
[ ] T-69-058: Ningún SFX estridente (cozy)
[ ] T-69-059: Pausa con GameClock sin residuos (M29)
[ ] T-69-060: catálogo puntos de viaje.tres (nombres, posiciones, costos)
[ ] T-69-061: API: viajar_a(destino)
[ ] T-69-062: API: esta_disponible(destino)
[ ] T-69-063: API: agregar_punto_viaje(nombre, pos)
[ ] T-69-064: API: obtener_puntos_disponibles()
[ ] T-69-065: API: establecer_ultimo_punto(nombre)
[ ] T-69-066: API: obtener_ultimo_punto()
[ ] T-69-067: Cooldown real: 1 uso cada 2 horas
[ ] T-69-068: Test: menú accesible desde mapa y atajo M
[ ] T-69-069: Test: verificación de costo de recursos
[ ] T-69-070: Test: cooldown real de 1 cada 2 horas
[ ] T-69-071: Test: animación suave sin jumps visuales
[ ] T-69-072: Test: respeto a ciclo día/noche
[ ] T-69-073: Test: restricción durante estados especiales
[ ] T-69-074: Test: guardado/recarga del último punto
[ ] T-69-075: Test: recorrido M114 sin ruptura de misiones
[ ] T-69-076: Módulo marcado delegable
[ ] T-69-077: 3 alternativas descartadas documentadas
[ ] T-69-078: API estable definida
[ ] T-69-079: Assets ? specs con family tonal
[ ] T-69-080: 01-Requerimientos creado y firmado
[ ] T-69-081: 02-Analisis creado y firmado
[ ] T-69-082: 03-Diseno creado y firmado
[ ] T-69-083: 04-Codigo creado y firmado (Notas del Agente)
[ ] T-69-084: 05-Checklist creado y firmado (este archivo)
[ ] T-69-085: Manejo de cancelacion mid-casting (ESC, cerrar menu)
[ ] T-69-086: Recuperacion si destino queda bloqueado por evento dinamico
[ ] T-69-087: Manejo de save corrupto punto_destino invalido
[ ] T-69-088: Validar cooldown al cargar partida guardada
[ ] T-69-089: No permitir destinos no descubiertos (anti-trampa)
[ ] T-69-090: Manejo de sobrecarga de slots descubiertos (>100)
[ ] T-69-091: Reset de cooldown al cargar partida con marca temporal
[ ] T-69-092: Transición de desvanecimiento con curva cozy
[ ] T-69-093: Efectos de partículas coherentes con M41
[ ] T-69-094: Flash sutil al aparecer en destino
[ ] T-69-095: Indicador de carga 0.5-1.5s mínimo
[ ] T-69-096: Sin huecos negros en transición
[ ] T-69-097: Compatible con modo foto pausado
[ ] T-69-098: HUD visible durante toda la transición
[ ] T-69-099: Sin parpadeos por baja luz
[ ] T-69-100: Ilumincación de destino respeta hora del mundo
[ ] T-69-101: Transición no afecta gameplay (tablas de delta)
[ ] T-69-102: Subtitulos de feedback de acción
[ ] T-69-103: Tamaño de texto escalable para menu (M62)
[ ] T-69-104: Confirmación háptica opcional
[ ] T-69-105: Contraste alto para menu de selección
[ ] T-69-106: Iconos de apoyo visual al nombre del destino
[ ] T-69-107: Alt text para thumbnails de destino
[ ] T-69-108: Modo cronológico para historiales
[ ] T-69-109: Filtros por tipo de lugar (bioma, servicios)
[ ] T-69-110: Sin dependencia solo de color para estado
[ ] T-69-111: M28: integración con waypoints descubiertos
[ ] T-69-112: M29-M31: restricción temporal (noche, tormenta)
[ ] T-69-113: M110: debug menu con listado de anchors
[ ] T-69-114: M122: captura de crash si portal falla
[ ] T-69-115: M124: balance económico según distancia
[ ] T-69-116: M32: anulación del portal en clima extremo
[ ] T-69-117: M68: respetar desactivación de hápticos
[ ] T-69-118: M91: respetar volumen de feedback de viaje
[ ] T-69-119: Test de carga: 100 anchors en mapa
[ ] T-69-120: Test de coherencia: 1000 teleports consecutivos
[ ] T-69-121: Test de día/noche: comportamiento en diferentes horas
[ ] T-69-122: Test de desconexión: recuperar estado sin perder progreso
[ ] T-69-123: Test de stress concurrentes: 50 anchors ACTIVOS
[ ] T-69-124: Test de recuperación: archivo corrupto ? resync
[ ] T-69-125: Test de batería: consumo por viaje a larga distancia
[ ] T-69-126: Test multidioma: búsqueda en distintos alfabetos
[ ] T-69-127: Test de aceso: atajos disponibles sin teclado
[ ] T-69-128: Test de localización: posicionamiento visual ajustado
[ ] T-69-129: Test de fallback: 3 fallos seguidos ? modo seguro
[ ] T-69-130: Test de perfilado: sin allocs en frame
[ ] T-69-131: UI del viaje (mapa M54 + atajo M57) y ejecución del viaje (M28) — iter 2 (dueño: deepseek-v4-flash-vision-exp)
[ ] T-69-132: Anclas de COR/CEN/AUR cuando su acceso esté implementado (iter 3, dueño: deepseek-v4-flash-vision-exp)
