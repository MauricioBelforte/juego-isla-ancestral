**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 59: Guardado (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. SaveManager (autoload)

- [x] Definir SaveManager como autoload único de guardado [M]
- [x] Encolar peticiones (un guardado a la vez) y procesar sin bloquear (M61) [C]
- [x] Exponer API request_save(slot, reason) a la UI (M53) [S]
- [x] Marcar dirty al cambiar cualquier sistema (EventBus M07) [M]
- [x] Registrar motivo de cada guardado (hito/manual/cierre) [S]

## B. Guardado Automático

- [x] Auto-save al final del día (M29 DAY_END) [M]
- [x] Auto-save al completar misión (M22/M23) [M]
- [x] Auto-save al finalizar evento (M74) y al cerrar el juego (M40) [M]
- [x] Intervalo configurable de auto-save (M90) [M]
- [x] No auto-save durante diálogo (M21), minijuego ni transición [M]

## C. Guardado Manual (M53)

- [x] Botón "Guardar" en pausa con confirmación y feedback (M44) [S]
- [x] Mostrar hora/fecha del último guardado por slot [M]
- [x] Impedir guardado manual durante carga de escena/diálogo [M]
- [x] Deshabilitar botón si no hay cambios (no dirty) [M]
- [x] Guardar manualmente desde el menú principal [S]

## D. Múltiples Slots

- [x] Definir 3+ slots con UI de selección en el menú principal [M]
- [x] Mostrar metadatos por slot (hora, día, progreso) [M]
- [x] Borrar y sobrescribir slot con confirmación [S]
- [x] Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M]
- [x] Probar 3 perfiles sin mezcla y cambio de slot en plena sesión [C]

## E. Escritura Atómica

- [x] Escribir a `.tmp` y renombrar a `.save` (regla dura) [C]
- [x] Limpiar `.tmp` huérfanos al arrancar [M]
- [x] Verificar integridad del `.tmp` (checksum) antes del rename [C]
- [x] Probar apagado (kill) durante escritura y en el rename [C]
- [x] Probar en Windows/macOS/Linux (rename atómico varía por SO) [C]

## F. Checksum y Validación

- [x] Calcular SHA-256 del payload al guardar y verificar al cargar [M]
- [x] Validar estructura en carga (campos, tipos, rangos — save_schema.gd) [M]
- [x] Fallar limpio ante checksum/estructura inválidos (sin crash) [M]
- [x] Avisar al jugador con mensaje claro y ofrecer recuperar backup [M]
- [x] Testear saves corruptos fabricados a mano [C]

## G. Recuperación de Backup

- [x] Rotación local: `slot_N.bak` del save anterior (1-2 rotaciones) [M]
- [x] Recuperación automática del backup ante corrupción [M]
- [x] Recuperación manual desde la UI (M53) con aviso [M]
- [x] Backups manuales con fecha; dedupe de contenido [M]
- [x] Testear fallback si el backup también está corrupto [C]

## H. Versionado y Migración (M60)

- [x] Incluir schema_version en cada save [S]
- [x] Migraciones solo-hacia-delante (M60) con backup previo [M]
- [x] Migrar automáticamente al cargar saves antiguos con aviso [M]
- [x] Manejar campos nuevos (defaults) y faltantes (sin crash) [M]
- [x] Testear migración de 2 versiones atrás y versión futura [C]

## I. Guardado del Mundo (M09/M10/M54)

- [x] Guardar islas, POI, exploración y niebla (M54) [M]
- [x] Guardar estado de ruinas (M25) y templos (M26) [M]
- [x] Guardar modificaciones del mundo (tala M50, minado M35) [M]
- [x] Guardar posición del jugador, zona y punto de spawn [S]
- [x] Testear carga del mundo sin duplicar objetos [C]

## J. Guardado del Inventario (M14/M15/M16)

- [x] Guardar ítems, cantidades, recursos (M15) y dinero (M38) [M]
- [x] Guardar equipamiento, hotbar y objetos colocados (M17) [M]
- [x] Guardar semillas y cultivos en proceso (M33) [M]
- [x] Guardar trampas y redes de pesca (M34) [M]
- [x] Testear carga sin duplicados y límites de cantidad (M60) [C]

## K. Guardado de Construcciones (M17/M18)

- [x] Guardar casas/edificios, fase de construcción y mejoras [M]
- [x] Guardar decoración, muebles y cofres con contenido [M]
- [x] Guardar estado de puertas y ventanas [S]
- [x] Testear carga con casas parcialmente construidas [C]
- [x] Testear carga con muebles inexistentes (fallback) [M]

## L. Guardado de NPC y Diálogos (M19/M21)

- [x] Guardar posición, estado y rutinas de NPC (M64) [M]
- [x] Guardar diálogos vistos y elecciones tomadas [M]
- [x] Guardar amistad (M20) y regalos entregados [M]
- [x] Guardar encargos activos (M23) [M]
- [x] Testear carga con NPC en movimiento y regalos duplicados [C]

## M. Guardado de Misiones (M22/M23)

- [x] Guardar misiones activas con progreso y completadas [M]
- [x] Guardar historia principal (capítulo, final elegido) [M]
- [x] Guardar descubrimientos y hitos de progresión (M71) [M]
- [x] Testear carga con misión a medias (objetivo coherente) [C]
- [x] Testear carga tras completar misión y reabrir [C]

## N. Guardado de Tiempo y Eventos (M29/M31/M74)

- [x] Guardar fecha, hora, estación (M29/M31) y clima (M32) [S]
- [x] Guardar eventos pasados y futuros programados (M74) [M]
- [x] Guardar festivales celebrados y calendario [M]
- [x] Testear carga en una fecha distinta a la del guardado [C]
- [x] Testear eventos no duplicados al recargar [C]

## O. Guardado de Colecciones (M37/M55/M56)

- [x] Guardar museo, bestiario y colecciones (M37/M36) [M]
- [x] Guardar diario del jugador (M55) [M]
- [x] Guardar fotos por referencia (ids, no bytes — M56) [M]
- [x] Guardar Sellos y ruinas coleccionables [M]
- [x] Testear diario 500+ entradas y fotos faltantes (fallback) [C]

## P. Configuración (M90/M91)

- [x] Guardar configuración en slot separado del progreso [M]
- [x] Guardar opciones gráficas (M90), audio (M91), accesibilidad (M58) e idioma (M87) [M]
- [x] No mezclar configuración con progreso [M]
- [x] Testear carga de configuración sin tocar el progreso [M]
- [x] Documentar el slot de configuración en 03-Diseno.md [S]

## Q. Robusteza (Apagado, Espacio, Perfiles)

- [x] Probar apagado a mitad de guardado y al iniciar la carga [C]
- [x] Probar falta de espacio: aviso claro y save anterior intacto [C]
- [x] Probar múltiples perfiles sin cruzamiento [C]
- [x] Probar archivos con permisos de solo lectura [M]
- [x] Testear paths con espacios/unicode (Windows) [M]

## R. Rendimiento (M61)

- [x] Guardado en background thread (< 80 ms) [C]
- [x] Carga < 500 ms para saves de sesión larga [C]
- [x] Save típico < 120 KB (fotos por referencia) [M]
- [x] Sin GC pesado ni hitching al encolar [M]
- [x] Reutilizar buffers de serialización (M62) y probar con profiler (M116) [C]

## S. Localización (M87)

- [x] Localizar textos del menú de guardado [S]
- [x] Localizar mensajes de corrupción, recuperación y disco lleno [S]
- [x] Localizar feedback de guardado (M44) [S]
- [x] Respetar plurales (horas, minutos) [S]
- [x] Testear menú de guardado en 3 idiomas [M]

## T. Validación y QA

- [x] Crear validate_save.gd (atómico, checksum, migración, perfiles) [C]
- [x] Probar ciclo: jugar → auto-save → apagar → cargar → continuar [C]
- [x] Probar ciclo de corrupción: corromper → detectar → recuperar [C]
- [x] Probar ciclo de migración: save viejo → migrar → jugar [C]
- [x] Probar ciclo de slots: guardar en 3 → cargar cada uno [C]

## U. Integración con Backups (M107) y Nube (M97)

- [x] Definir contrato con M107 (3-2-1 externo) [M]
- [x] Exportar saves a la nube de Steam (M97, opcional) [M]
- [x] No duplicar backups locales y externos [M]
- [x] Verificar la restauración desde la nube [C]
- [x] Documentar el flujo de recuperación completo [M]

## V. Edge Cases

- [x] Guardar con inventario vacío, mundo sin explorar o en el primer minuto [S]
- [x] Cargar un save del slot equivocado (id de perfil) [M]
- [x] Cargar con versión futura (aviso claro) [M]
- [x] Guardar durante un festival con estado consistente (M74) [M]
- [x] Testear doble guardado simultáneo (cola) [C]

## W. Accesibilidad (M58)

- [x] Feedback de guardado visible y legible [S]
- [x] Confirmaciones accesibles por gamepad (M57) [M]
- [x] Diálogos de aviso con opciones claras [S]
- [x] Testear menú con Reduce Motion (M58) [M]
- [x] Testear con texto grande (M58) [M]

## X. Documentación

- [x] Documentar la API de SaveManager [M]
- [x] Documentar el esquema del save en 04-Codigo.md [M]
- [x] Documentar las interfaces ISaveProvider [M]
- [x] Documentar el flujo atómico y la rotación local vs M107 [M]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## Y. Validación Final (DoD)

- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [x] Actualizar DOCUMENTACION/README.md con el módulo 59 [S]
- [x] Actualizar ESTADO-PARALELO.md [S]
- [x] Generar el log 62 en Logs/ [S]

## Z. Cierre del Módulo

- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Push del módulo y reporte al usuario [S]
- [x] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [x] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [x] Confirmar 130 ítems exactos [S]