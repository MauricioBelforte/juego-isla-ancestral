**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 56: Fotografía (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Modo Fotografía (Fotostate)

- [ ] Definir PhotoMode (autoload) como único administrador del modo foto [M]
- [ ] Entrada/salida por atajo (M57) en < 1 s, mundo congelado (M31) [M]
- [ ] Restaurar cámara y HUD exactos al salir [M]
- [ ] Bloquear acciones de juego durante el modo foto [M]
- [ ] Registrar logs PHOTO-ENTER y PHOTO-EXIT [S]

## B. Cámara Libre (Navigator)

- [ ] Definir Navigator como réplica lógica de la cámara real (un render, M61) [C]
- [ ] Traslación libre con WASD/gamepad (M57) y colisión suave (raycast) [C]
- [ ] Restaurar FOV y posición originales al salir [S]
- [ ] Manejar colisión con agua (no sumergir la cámara, M51) [M]
- [ ] Probar en interiores (M18/M25), playa y escenas densas [C]

## C. Zoom y Rotación

- [ ] Zoom 0.5x-8x con FOV dinámico (M49) [M]
- [ ] Zoom con rueda del mouse y gatillos de gamepad [M]
- [ ] Rotación orbital completa en 3 ejes [M]
- [ ] Límites de inclinación -60°..+60° [S]
- [ ] Probar zoom máximo en escenas con vegetación densa (M50) [M]

## D. Presets de Filtros

- [ ] Definir 6-8 presets en `photo_presets.tres` [M]
- [ ] Definir preset default "Natural" y aplicar preview en vivo [C]
- [ ] No modificar la paleta global del juego (M49) [M]
- [ ] Guardar preset elegido en los metadatos de la foto [S]
- [ ] Validar que los filtros no destruyan la estética cozy [M]

## E. DOF, Exposición, Contraste y Viñeta

- [ ] Implementar profundidad de campo (DOF) ajustable y sutil [C]
- [ ] Implementar exposición (EV) con preview [M]
- [ ] Implementar contraste con slider [M]
- [ ] Implementar viñeta opcional [S]
- [ ] Restaurar ajustes por defecto al salir del modo foto [S]

## F. Hora del Día y Clima

- [ ] Permitir fijar la hora del día para la foto (M31) [C]
- [ ] Mostrar preview del sol/luna y del clima con la hora fijada [M]
- [ ] Restaurar hora/clima reales al salir [M]
- [ ] No permitir fijar hora durante eventos cinemáticos (M74) [M]
- [ ] Guardar hora en los metadatos de la foto [S]

## G. Ocultar Interfaz

- [ ] Ocultar HUD completo (M53) con una tecla [S]
- [ ] Ocultar jugador (cuerpo invisible) y prompts de interacción (M70) [M]
- [ ] Mostrar indicador mínimo de "HUD oculto" [S]
- [ ] Restaurar HUD al salir del modo foto [S]
- [ ] Testear ocultamiento con Reduce Motion activo (M58) [M]

## H. Poses de NPC (M19)

- [ ] Emitir PHOTO_POSE_REQUEST (M07) al entrar al modo foto [S]
- [ ] NPC posa 0.5 s con animación M48 sin bugs [M]
- [ ] Retardo de 0.8 s entre pose y captura (evitar tween) [M]
- [ ] No posar NPC en medio de diálogo (M21) [M]
- [ ] Restaurar animación del NPC al salir; testear poses en grupo (M19) [C]

## I. Captura de Animales (M36)

- [ ] Animales posan/congelan en cámara y no huyen [C]
- [ ] Animales reanudan su IA (M64) al salir [M]
- [ ] Capturar voladores y acuáticos (M51) sin romper trayectoria [C]
- [ ] Identificar la especie al capturarla (bestiario M36/M37) [M]
- [ ] Testear captura nocturna y de manadas (M31/M36) [C]

## J. Captura de Paisajes

- [ ] Capturar escenas completas sin HUD [S]
- [ ] Capturar vegetación densa (M50) y agua (M51) sin popping [C]
- [ ] Capturar ruinas (M25), templos (M26) e interiores (M49) [M]
- [ ] Vincular la foto con el lugar del mapa (M54) [M]
- [ ] Capturar festivales (M74) con NPC posando [M]

## K. Captura Técnica

- [ ] Capturar a resolución fija 1920×1080 (no screencapture) [C]
- [ ] Presupuesto de captura: < 50 ms (M61) [C]
- [ ] Aplicar preset de filtros en el frame capturado [M]
- [ ] Esperar 0.8 s tras la pose con indicador visual [M]
- [ ] Evitar capturas simultáneas (doble click protegido) [M]

## L. Álbum y Guardado

- [ ] Guardar en `user://photos/` en WebP con metadatos XMP [M]
- [ ] Nombrar archivos de forma única (timestamp) [S]
- [ ] Manejar disco lleno y permisos denegados (M59) con aviso amigable [M]
- [ ] Manejar corrupción de fotos (archivo inválido) [M]
- [ ] Exportar a carpeta visible del SO (M97) [M]

## M. Índice y Miniaturas

- [ ] Mantener índice JSON versionado (M59/M60) [M]
- [ ] Generar miniatura de 320 px por foto [M]
- [ ] LazyLoad de miniaturas en la galería (solo visibles, M61) [C]
- [ ] No duplicar texturas en memoria al abrir la galería [M]
- [ ] Listar fotos ordenadas por fecha [S]

## N. Galería y Diario (M55)

- [ ] Definir interface IDiaryPhotoProvider (desacople M55) [M]
- [ ] Mostrar galería del álbum en el diario [M]
- [ ] Abrir foto en pantalla completa sin recargar la escena [M]
- [ ] Borrar foto desde el diario [S]
- [ ] Testear galería con 200+ fotos en 3 idiomas (M61/M87) [C]

## O. Compartir Imágenes

- [ ] Definir "compartir" como exportación local (M97) con confirmación (M53) [M]
- [ ] Explicar en el diálogo qué se exporta y adónde [S]
- [ ] Compartir desde el álbum y desde el diario [S]
- [ ] Indicar visualmente la ruta de exportación [S]
- [ ] Testear compartición en Steam y Windows [M]

## P. Privacidad (M80/M78)

- [ ] No incluir datos de perfil en el archivo exportado [M]
- [ ] No incluir coordenadas del mundo ni datos de red [M]
- [ ] No incluir metadatos de sesión [M]
- [ ] Nunca compartir nada sin confirmación [M]
- [ ] Validar con política de privacidad (M80) [M]

## Q. Control de Entradas (M57)

- [ ] Definir atajos de teclado y gamepad del modo foto [S]
- [ ] Bloquear atajos de juego durante el modo foto y viceversa [M]
- [ ] Permitir salida con ESC y entrada desde inventario (M14) [S]
- [ ] Publicar atajos en el menú de ayuda (M92) [S]
- [ ] Testear todos los atajos con teclado y gamepad [C]

## R. Rendimiento y Memoria (M61/M62)

- [ ] Mover la cámara real (réplica) en lugar de render extra [C]
- [ ] Presupuesto del álbum: ≤ 150 MB con aviso PHOTO-WARN [M]
- [ ] Implementar utilidades de medición de memoria del álbum [M]
- [ ] Probar con profiler (M116) y en baja calidad gráfica (M90) [C]
- [ ] Testear estabilidad en 30 min de sesión de fotos [C]

## S. Edge Cases

- [ ] Entrar al modo foto con inventario abierto o en transición de escena [M]
- [ ] Entrada durante diálogo (M21): bloqueada correctamente [M]
- [ ] Salida con cámara dentro de un muro (colisión) [M]
- [ ] Salida con cámara muy lejos del jugador [M]
- [ ] Foto borrada mientras está abierta (referencia inválida) [M]

## T. Robustez

- [ ] Manejar álbum vacío con mensaje amistoso [S]
- [ ] Manejar fecha inválida del sistema al nombrar archivos [S]
- [ ] Manejar preset faltante en metadatos [S]
- [ ] Manejar cámara en agua profunda (M51) [M]
- [ ] Manejar álbum corrupto con defaults (M60) [C]

## U. Localización (M87/M88)

- [ ] Localizar todos los textos del modo foto por claves i18n [M]
- [ ] Localizar nombres de presets y mensajes de confirmación [S]
- [ ] Localizar metadatos mostrados (fecha/hora/lugar) [M]
- [ ] Respetar plurales (fotos restantes) [M]
- [ ] Testear HUD en 3 idiomas sin desbordes y nombres de archivo invariantes [M]

## V. Accesibilidad (M58)

- [ ] Asegurar lectura del HUD con alto contraste opcional [M]
- [ ] Ofrecer tamaño de texto configurable [M]
- [ ] Reducir zoom automático con Reduce Motion activo [M]
- [ ] Ofrecer subtítulos en notificaciones [S]
- [ ] Evitar estroboscopios en la UI y testear colorblind mode [M]

## W. Arte y Sonido

- [ ] Definir iconos de controles del modo foto (M46) [M]
- [ ] Definir marcadores de encuadre (rejilla de tercios) con toggle [M]
- [ ] Añadir guía de horizonte opcional [S]
- [ ] Definir sonido de obturador (M43) y vibración sutil (M57) [S]
- [ ] Definir el ícono de la cámara en la barra de accesos (M53) [S]

## X. Validación y QA

- [ ] Crear validate_photo.gd (modo foto, presets, guardado, rendimiento) [C]
- [ ] Probar ciclo completo: entrar → ajustar → posar → capturar → ver álbum [C]
- [ ] Probar ciclo de compartición con confirmación [C]
- [ ] Probar salida del modo foto restaurando TODO el estado [C]
- [ ] Revisar logs PHOTO-* en consola sin errores [S]

## Y. Integraciones Restantes

- [ ] Registrar PHOTO_TAKEN en el diario (M55) [M]
- [ ] Asociar foto a entrada del diario al tomarla [M]
- [ ] Alimentar logros de coleccionista (M72) [M]
- [ ] Probar compatibilidad con guardados antiguos (M60) [C]
- [ ] Documentar plan de testings automáticos del modo foto [M]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Push del módulo y reporte al usuario [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Núcleo data-driven: `data/foto/foto_presets.json` (6 presets RF5) + `scripts/foto/foto_schema.gd` (validación de preset: sat/contraste>0, vineta/temp/dof en rango)
- [x] `scripts/foto/photo_service.gd` — PhotoService (núcleo del modo: activación con señal, presets cargados, aplicar preset con fallback a natural, preset actual)
- [x] Test headless: 10/10 checks OK (schema 4 + service 6; presets 6, señal, fallback) — exit 0
- [x] **Verificación VISUAL de los 6 presets** (pipeline PIL aplicado a captura real del juego → comparativo analizado con visión): estética cozy/no invasiva cumplida (RF5); calido_playa/verde_selva/crepusculo_rojo/pintura_retro/natural excelentes; niebla_costera con dof global perceptible
- [?] DoF selectivo (foco claro, RF6) y cámara libre/zoom/filtros en vivo (RF1-RF4) — iteración 2 con M49/M31 (dueño: deepseek-v4-flash-vision-exp)
- [?] Integración del atajo con M57 — iter 2
