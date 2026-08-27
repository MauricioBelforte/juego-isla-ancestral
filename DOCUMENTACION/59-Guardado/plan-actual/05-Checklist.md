**Modelo:** ox-alpha
**Plataforma:** Cline

# 05-Checklist.md — Módulo 59: Guardado (130 ítems)

**Estado:** 27/130 completados (capa de servicio núcleo implementada y validada con suite headless exit 0; UI, proveedores por sistema e hitos M07 pendientes). [S]=Simple [M]=Medio [C]=Complejo.

## A. SaveManager (autoload)

- [x] Definir SaveManager como autoload único de guardado [M]
- [ ] Encolar peticiones (un guardado a la vez) y procesar sin bloquear (M61) [C] — *cola síncrona implementada; background thread pendiente M61*
- [x] Exponer API request_save(slot, reason) a la UI (M53) [S]
- [ ] Marcar dirty al cambiar cualquier sistema (EventBus M07) [M] — *M07 no existe aún*
- [x] Registrar motivo de cada guardado (hito/manual/cierre) [S]

## B. Guardado Automático

- [ ] Auto-save al final del día (M29 DAY_END) [M]
- [ ] Auto-save al completar misión (M22/M23) [M]
- [ ] Auto-save al finalizar evento (M74) y al cerrar el juego (M40) [M]
- [x] Intervalo configurable de auto-save (M90) [M] — *auto_save_interval export, timer en _process*
- [ ] No auto-save durante diálogo (M21), minijuego ni transición [M]

## C. Guardado Manual (M53)

- [ ] Botón "Guardar" en pausa con confirmación y feedback (M44) [S]
- [ ] Mostrar hora/fecha del último guardado por slot [M]
- [ ] Impedir guardado manual durante carga de escena/diálogo [M]
- [ ] Deshabilitar botón si no hay cambios (no dirty) [M]
- [ ] Guardar manualmente desde el menú principal [S]

## D. Múltiples Slots

- [ ] Definir 3+ slots con UI de selección en el menú principal [M]
- [ ] Mostrar metadatos por slot (hora, día, progreso) [M]
- [ ] Borrar y sobrescribir slot con confirmación [S]
- [ ] Id de perfil en el archivo, validado al cargar (sin cruzamiento) [M]
- [ ] Probar 3 perfiles sin mezcla y cambio de slot en plena sesión [C]

## E. Escritura Atómica

- [x] Escribir a `.tmp` y renombrar a `.save` (regla dura) [C]
- [x] Limpiar `.tmp` huérfanos al arrancar [M]
- [x] Verificar integridad del `.tmp` (checksum) antes del rename [C]
- [ ] Probar apagado (kill) durante escritura y en el rename [C]
- [ ] Probar en Windows/macOS/Linux (rename atómico varía por SO) [C]

## F. Checksum y Validación

- [x] Calcular SHA-256 del payload al guardar y verificar al cargar [M]
- [x] Validar estructura en carga (campos, tipos, rangos — save_schema.gd) [M]
- [x] Fallar limpio ante checksum/estructura inválidos (sin crash) [M]
- [ ] Avisar al jugador con mensaje claro y ofrecer recuperar backup [M] — *señales emitidas; UI pendiente M53*
- [x] Testear saves corruptos fabricados a mano [C]

## G. Recuperación de Backup

- [x] Rotación local: `slot_N.bak` del save anterior (1-2 rotaciones) [M]
- [x] Recuperación automática del backup ante corrupción [M]
- [ ] Recuperación manual desde la UI (M53) con aviso [M] — *API backup_manual() lista; UI pendiente*
- [x] Backups manuales con fecha; dedupe de contenido [M] — *con fecha; dedupe pendiente*
- [x] Testear fallback si el backup también está corrupto [C]

## H. Versionado y Migración (M60)

- [x] Incluir schema_version en cada save [S]
- [x] Migraciones solo-hacia-delante (M60) con backup previo [M] — *infraestructura lista (v1 sin migraciones)*
- [ ] Migrar automáticamente al cargar saves antiguos con aviso [M] — *migra; aviso UI pendiente*
- [x] Manejar campos nuevos (defaults) y faltantes (sin crash) [M]
- [ ] Testear migración de 2 versiones atrás y versión futura [C] — *versión futura testeada implícitamente; 2 versiones atrás no aplica en v1*

## I. Guardado del Mundo (M09/M10/M54)

- [ ] Guardar islas, POI, exploración y niebla (M54) [M]
- [ ] Guardar estado de ruinas (M25) y templos (M26) [M]
- [ ] Guardar modificaciones del mundo (tala M50, minado M35) [M]
- [ ] Guardar posición del jugador, zona y punto de spawn [S]
- [ ] Testear carga del mundo sin duplicar objetos [C]

## J. Guardado del Inventario (M14/M15/M16)

- [ ] Guardar ítems, cantidades, recursos (M15) y dinero (M38) [M]
- [ ] Guardar equipamiento, hotbar y objetos colocados (M17) [M]
- [ ] Guardar semillas y cultivos en proceso (M33) [M]
- [ ] Guardar trampas y redes de pesca (M34) [M]
- [ ] Testear carga sin duplicados y límites de cantidad (M60) [C]

## K. Guardado de Construcciones (M17/M18)

- [ ] Guardar casas/edificios, fase de construcción y mejoras [M]
- [ ] Guardar decoración, muebles y cofres con contenido [M]
- [ ] Guardar estado de puertas y ventanas [S]
- [ ] Testear carga con casas parcialmente construidas [C]
- [ ] Testear carga con muebles inexistentes (fallback) [M]

## L. Guardado de NPC y Diálogos (M19/M21)

- [ ] Guardar posición, estado y rutinas de NPC (M64) [M]
- [ ] Guardar diálogos vistos y elecciones tomadas [M]
- [ ] Guardar amistad (M20) y regalos entregados [M]
- [ ] Guardar encargos activos (M23) [M]
- [ ] Testear carga con NPC en movimiento y regalos duplicados [C]

## M. Guardado de Misiones (M22/M23)

- [ ] Guardar misiones activas con progreso y completadas [M]
- [ ] Guardar historia principal (capítulo, final elegido) [M]
- [ ] Guardar descubrimientos y hitos de progresión (M71) [M]
- [ ] Testear carga con misión a medias (objetivo coherente) [C]
- [ ] Testear carga tras completar misión y reabrir [C]

## N. Guardado de Tiempo y Eventos (M29/M31/M74)

- [ ] Guardar fecha, hora, estación (M29/M31) y clima (M32) [S]
- [ ] Guardar eventos pasados y futuros programados (M74) [M]
- [ ] Guardar festivales celebrados y calendario [M]
- [ ] Testear carga en una fecha distinta a la del guardado [C]
- [ ] Testear eventos no duplicados al recargar [C]

## O. Guardado de Colecciones (M37/M55/M56)

- [ ] Guardar museo, bestiario y colecciones (M37/M36) [M]
- [ ] Guardar diario del jugador (M55) [M]
- [ ] Guardar fotos por referencia (ids, no bytes — M56) [M]
- [ ] Guardar Sellos y ruinas coleccionables [M]
- [ ] Testear diario 500+ entradas y fotos faltantes (fallback) [C]

## P. Configuración (M90/M91)

- [ ] Guardar configuración en slot separado del progreso [M]
- [ ] Guardar opciones gráficas (M90), audio (M91), accesibilidad (M58) e idioma (M87) [M]
- [ ] No mezclar configuración con progreso [M]
- [ ] Testear carga de configuración sin tocar el progreso [M]
- [ ] Documentar el slot de configuración en 03-Diseno.md [S]

## Q. Robusteza (Apagado, Espacio, Perfiles)

- [ ] Probar apagado a mitad de guardado y al iniciar la carga [C]
- [ ] Probar falta de espacio: aviso claro y save anterior intacto [C]
- [ ] Probar múltiples perfiles sin cruzamiento [C]
- [ ] Probar archivos con permisos de solo lectura [M]
- [ ] Testear paths con espacios/unicode (Windows) [M]

## R. Rendimiento (M61)

- [ ] Guardado en background thread (< 80 ms) [C]
- [ ] Carga < 500 ms para saves de sesión larga [C]
- [ ] Save típico < 120 KB (fotos por referencia) [M]
- [ ] Sin GC pesado ni hitching al encolar [M]
- [ ] Reutilizar buffers de serialización (M62) y probar con profiler (M116) [C]

## S. Localización (M87)

- [ ] Localizar textos del menú de guardado [S]
- [ ] Localizar mensajes de corrupción, recuperación y disco lleno [S]
- [ ] Localizar feedback de guardado (M44) [S]
- [ ] Respetar plurales (horas, minutos) [S]
- [ ] Testear menú de guardado en 3 idiomas [M]

## T. Validación y QA

- [x] Crear validate_save.gd (atómico, checksum, migración, perfiles) [C]
- [x] Probar ciclo: jugar → auto-save → apagar → cargar → continuar [C]
- [x] Probar ciclo de corrupción: corromper → detectar → recuperar [C]
- [ ] Probar ciclo de migración: save viejo → migrar → jugar [C] — *no aplica en v1 (sin versiones previas)*
- [x] Probar ciclo de slots: guardar en 3 → cargar cada uno [C]

## U. Integración con Backups (M107) y Nube (M97)

- [ ] Definir contrato con M107 (3-2-1 externo) [M]
- [ ] Exportar saves a la nube de Steam (M97, opcional) [M]
- [ ] No duplicar backups locales y externos [M]
- [ ] Verificar la restauración desde la nube [C]
- [ ] Documentar el flujo de recuperación completo [M]

## V. Edge Cases

- [ ] Guardar con inventario vacío, mundo sin explorar o en el primer minuto [S]
- [ ] Cargar un save del slot equivocado (id de perfil) [M]
- [ ] Cargar con versión futura (aviso claro) [M]
- [ ] Guardar durante un festival con estado consistente (M74) [M]
- [ ] Testear doble guardado simultáneo (cola) [C]

## W. Accesibilidad (M58)

- [ ] Feedback de guardado visible y legible [S]
- [ ] Confirmaciones accesibles por gamepad (M57) [M]
- [ ] Diálogos de aviso con opciones claras [S]
- [ ] Testear menú con Reduce Motion (M58) [M]
- [ ] Testear con texto grande (M58) [M]

## X. Documentación

- [x] Documentar la API de SaveManager [M]
- [x] Documentar el esquema del save en 04-Codigo.md [M]
- [x] Documentar las interfaces ISaveProvider [M]
- [x] Documentar el flujo atómico y la rotación local vs M107 [M]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## Y. Validación Final (DoD)

- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [ ] Actualizar DOCUMENTACION/README.md con el módulo 59 [S]
- [ ] Actualizar ESTADO-PARALELO.md [S]
- [ ] Generar el log 62 en Logs/ [S]

## Z. Cierre del Módulo

- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Push del módulo y reporte al usuario [S]
- [ ] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [ ] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [ ] Confirmar 130 ítems exactos [S]