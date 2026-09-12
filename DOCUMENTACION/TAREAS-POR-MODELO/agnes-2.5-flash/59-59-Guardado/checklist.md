# Tareas módulo 59 59-Guardado

**Estado:** 🟡 Con dudas (núcleo + auto-save)

**Items pendientes:** 75

[ ] T-59-001: Botón "Guardar" en pausa con confirmación y feedback (M44)
[ ] T-59-002: Mostrar hora/fecha del último guardado por slot
[ ] T-59-003: Impedir guardado manual durante carga de escena/diálogo
[ ] T-59-004: Deshabilitar botón si no hay cambios (no dirty)
[ ] T-59-005: Guardar manualmente desde el menú principal
[ ] T-59-006: Definir 3+ slots con UI de selección en el menú principal
[ ] T-59-007: Mostrar metadatos por slot (hora, día, progreso)
[ ] T-59-008: Borrar y sobrescribir slot con confirmación
[ ] T-59-009: Id de perfil en el archivo, validado al cargar (sin cruzamiento)
[ ] T-59-010: Probar 3 perfiles sin mezcla y cambio de slot en plena sesión
[ ] T-59-011: Probar apagado (kill) durante escritura y en el rename
[ ] T-59-012: Probar en Windows/macOS/Linux (rename atómico varía por SO)
[ ] T-59-013: Testear migración de 2 versiones atrás y versión futura [C] — *versión futura testeada implícitamente; 2 versiones atrás no aplica en v1*
[ ] T-59-014: Guardar islas, POI, exploración y niebla (M54)
[ ] T-59-015: Guardar estado de ruinas (M25) y templos (M26)
[ ] T-59-016: Guardar modificaciones del mundo (tala M50, minado M35)
[ ] T-59-017: Testear carga del mundo sin duplicar objetos
[ ] T-59-018: Guardar ítems, cantidades, recursos (M15) y dinero (M38)
[ ] T-59-019: Guardar equipamiento, hotbar y objetos colocados (M17)
[ ] T-59-020: Guardar semillas y cultivos en proceso (M33)
[ ] T-59-021: Guardar trampas y redes de pesca (M34)
[ ] T-59-022: Testear carga sin duplicados y límites de cantidad (M60)
[ ] T-59-023: Guardar casas/edificios, fase de construcción y mejoras
[ ] T-59-024: Guardar decoración, muebles y cofres con contenido
[ ] T-59-025: Guardar estado de puertas y ventanas
[ ] T-59-026: Testear carga con casas parcialmente construidas
[ ] T-59-027: Testear carga con muebles inexistentes (fallback)
[ ] T-59-028: Guardar posición, estado y rutinas de NPC (M64)
[ ] T-59-029: Guardar diálogos vistos y elecciones tomadas
[ ] T-59-030: Guardar amistad (M20) y regalos entregados
[ ] T-59-031: Guardar encargos activos (M23)
[ ] T-59-032: Testear carga con NPC en movimiento y regalos duplicados
[ ] T-59-033: Guardar misiones activas con progreso y completadas
[ ] T-59-034: Guardar historia principal (capítulo, final elegido)
[ ] T-59-035: Guardar descubrimientos y hitos de progresión (M71)
[ ] T-59-036: Testear carga con misión a medias (objetivo coherente)
[ ] T-59-037: Testear carga tras completar misión y reabrir
[ ] T-59-038: Guardar eventos pasados y futuros programados (M74)
[ ] T-59-039: Guardar festivales celebrados y calendario
[ ] T-59-040: Testear carga en una fecha distinta a la del guardado
[ ] T-59-041: Testear eventos no duplicados al recargar
[ ] T-59-042: Guardar museo, bestiario y colecciones (M37/M36)
[ ] T-59-043: Guardar diario del jugador (M55)
[ ] T-59-044: Guardar fotos por referencia (ids, no bytes — M56)
[ ] T-59-045: Guardar Sellos y ruinas coleccionables
[ ] T-59-046: Testear diario 500+ entradas y fotos faltantes (fallback)
[ ] T-59-047: Guardar opciones gráficas (M90), audio (M91), accesibilidad (M58) e idioma (M87)
[ ] T-59-048: Probar apagado a mitad de guardado y al iniciar la carga
[ ] T-59-049: Probar múltiples perfiles sin cruzamiento
[ ] T-59-050: Probar archivos con permisos de solo lectura
[ ] T-59-051: Guardado en background thread (< 80 ms)
[ ] T-59-052: Sin GC pesado ni hitching al encolar
[ ] T-59-053: Reutilizar buffers de serialización (M62) y probar con profiler (M116)
[ ] T-59-054: Localizar textos del menú de guardado
[ ] T-59-055: Localizar mensajes de corrupción, recuperación y disco lleno
[ ] T-59-056: Localizar feedback de guardado (M44)
[ ] T-59-057: Respetar plurales (horas, minutos)
[ ] T-59-058: Testear menú de guardado en 3 idiomas
[ ] T-59-059: Definir contrato con M107 (3-2-1 externo)
[ ] T-59-060: Verificar la restauración desde la nube
[ ] T-59-061: Documentar el flujo de recuperación completo
[ ] T-59-062: Guardar con inventario vacío, mundo sin explorar o en el primer minuto
[ ] T-59-063: Cargar con versión futura (aviso claro)
[ ] T-59-064: Guardar durante un festival con estado consistente (M74)
[ ] T-59-065: Testear doble guardado simultáneo (cola)
[ ] T-59-066: Feedback de guardado visible y legible
[ ] T-59-067: Confirmaciones accesibles por gamepad (M57)
[ ] T-59-068: Diálogos de aviso con opciones claras
[ ] T-59-069: Testear menú con Reduce Motion (M58)
[ ] T-59-070: Testear con texto grande (M58)
[ ] T-59-071: Verificar con verificar_checklist.py (sin alertas nuevas)
[ ] T-59-072: Push del módulo y reporte al usuario
[ ] T-59-073: Marcar ítems solo al cumplir la DoD (sección 21.6)
[ ] T-59-074: Revisar que plan-inicial == plan-actual (SHA-256)
[ ] T-59-075: Confirmar 130 ítems exactos
