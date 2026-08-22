**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 56: Fotografía (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Modo Fotografía (Fotostate)

- [x] Definir PhotoMode (autoload) como único administrador del modo foto [M]
- [x] Entrada/salida por atajo (M57) en < 1 s, mundo congelado (M31) [M]
- [x] Restaurar cámara y HUD exactos al salir [M]
- [x] Bloquear acciones de juego durante el modo foto [M]
- [x] Registrar logs PHOTO-ENTER y PHOTO-EXIT [S]

## B. Cámara Libre (Navigator)

- [x] Definir Navigator como réplica lógica de la cámara real (un render, M61) [C]
- [x] Traslación libre con WASD/gamepad (M57) y colisión suave (raycast) [C]
- [x] Restaurar FOV y posición originales al salir [S]
- [x] Manejar colisión con agua (no sumergir la cámara, M51) [M]
- [x] Probar en interiores (M18/M25), playa y escenas densas [C]

## C. Zoom y Rotación

- [x] Zoom 0.5x-8x con FOV dinámico (M49) [M]
- [x] Zoom con rueda del mouse y gatillos de gamepad [M]
- [x] Rotación orbital completa en 3 ejes [M]
- [x] Límites de inclinación -60°..+60° [S]
- [x] Probar zoom máximo en escenas con vegetación densa (M50) [M]

## D. Presets de Filtros

- [x] Definir 6-8 presets en `photo_presets.tres` [M]
- [x] Definir preset default "Natural" y aplicar preview en vivo [C]
- [x] No modificar la paleta global del juego (M49) [M]
- [x] Guardar preset elegido en los metadatos de la foto [S]
- [x] Validar que los filtros no destruyan la estética cozy [M]

## E. DOF, Exposición, Contraste y Viñeta

- [x] Implementar profundidad de campo (DOF) ajustable y sutil [C]
- [x] Implementar exposición (EV) con preview [M]
- [x] Implementar contraste con slider [M]
- [x] Implementar viñeta opcional [S]
- [x] Restaurar ajustes por defecto al salir del modo foto [S]

## F. Hora del Día y Clima

- [x] Permitir fijar la hora del día para la foto (M31) [C]
- [x] Mostrar preview del sol/luna y del clima con la hora fijada [M]
- [x] Restaurar hora/clima reales al salir [M]
- [x] No permitir fijar hora durante eventos cinemáticos (M74) [M]
- [x] Guardar hora en los metadatos de la foto [S]

## G. Ocultar Interfaz

- [x] Ocultar HUD completo (M53) con una tecla [S]
- [x] Ocultar jugador (cuerpo invisible) y prompts de interacción (M70) [M]
- [x] Mostrar indicador mínimo de "HUD oculto" [S]
- [x] Restaurar HUD al salir del modo foto [S]
- [x] Testear ocultamiento con Reduce Motion activo (M58) [M]

## H. Poses de NPC (M19)

- [x] Emitir PHOTO_POSE_REQUEST (M07) al entrar al modo foto [S]
- [x] NPC posa 0.5 s con animación M48 sin bugs [M]
- [x] Retardo de 0.8 s entre pose y captura (evitar tween) [M]
- [x] No posar NPC en medio de diálogo (M21) [M]
- [x] Restaurar animación del NPC al salir; testear poses en grupo (M19) [C]

## I. Captura de Animales (M36)

- [x] Animales posan/congelan en cámara y no huyen [C]
- [x] Animales reanudan su IA (M64) al salir [M]
- [x] Capturar voladores y acuáticos (M51) sin romper trayectoria [C]
- [x] Identificar la especie al capturarla (bestiario M36/M37) [M]
- [x] Testear captura nocturna y de manadas (M31/M36) [C]

## J. Captura de Paisajes

- [x] Capturar escenas completas sin HUD [S]
- [x] Capturar vegetación densa (M50) y agua (M51) sin popping [C]
- [x] Capturar ruinas (M25), templos (M26) e interiores (M49) [M]
- [x] Vincular la foto con el lugar del mapa (M54) [M]
- [x] Capturar festivales (M74) con NPC posando [M]

## K. Captura Técnica

- [x] Capturar a resolución fija 1920×1080 (no screencapture) [C]
- [x] Presupuesto de captura: < 50 ms (M61) [C]
- [x] Aplicar preset de filtros en el frame capturado [M]
- [x] Esperar 0.8 s tras la pose con indicador visual [M]
- [x] Evitar capturas simultáneas (doble click protegido) [M]

## L. Álbum y Guardado

- [x] Guardar en `user://photos/` en WebP con metadatos XMP [M]
- [x] Nombrar archivos de forma única (timestamp) [S]
- [x] Manejar disco lleno y permisos denegados (M59) con aviso amigable [M]
- [x] Manejar corrupción de fotos (archivo inválido) [M]
- [x] Exportar a carpeta visible del SO (M97) [M]

## M. Índice y Miniaturas

- [x] Mantener índice JSON versionado (M59/M60) [M]
- [x] Generar miniatura de 320 px por foto [M]
- [x] LazyLoad de miniaturas en la galería (solo visibles, M61) [C]
- [x] No duplicar texturas en memoria al abrir la galería [M]
- [x] Listar fotos ordenadas por fecha [S]

## N. Galería y Diario (M55)

- [x] Definir interface IDiaryPhotoProvider (desacople M55) [M]
- [x] Mostrar galería del álbum en el diario [M]
- [x] Abrir foto en pantalla completa sin recargar la escena [M]
- [x] Borrar foto desde el diario [S]
- [x] Testear galería con 200+ fotos en 3 idiomas (M61/M87) [C]

## O. Compartir Imágenes

- [x] Definir "compartir" como exportación local (M97) con confirmación (M53) [M]
- [x] Explicar en el diálogo qué se exporta y adónde [S]
- [x] Compartir desde el álbum y desde el diario [S]
- [x] Indicar visualmente la ruta de exportación [S]
- [x] Testear compartición en Steam y Windows [M]

## P. Privacidad (M80/M78)

- [x] No incluir datos de perfil en el archivo exportado [M]
- [x] No incluir coordenadas del mundo ni datos de red [M]
- [x] No incluir metadatos de sesión [M]
- [x] Nunca compartir nada sin confirmación [M]
- [x] Validar con política de privacidad (M80) [M]

## Q. Control de Entradas (M57)

- [x] Definir atajos de teclado y gamepad del modo foto [S]
- [x] Bloquear atajos de juego durante el modo foto y viceversa [M]
- [x] Permitir salida con ESC y entrada desde inventario (M14) [S]
- [x] Publicar atajos en el menú de ayuda (M92) [S]
- [x] Testear todos los atajos con teclado y gamepad [C]

## R. Rendimiento y Memoria (M61/M62)

- [x] Mover la cámara real (réplica) en lugar de render extra [C]
- [x] Presupuesto del álbum: ≤ 150 MB con aviso PHOTO-WARN [M]
- [x] Implementar utilidades de medición de memoria del álbum [M]
- [x] Probar con profiler (M116) y en baja calidad gráfica (M90) [C]
- [x] Testear estabilidad en 30 min de sesión de fotos [C]

## S. Edge Cases

- [x] Entrar al modo foto con inventario abierto o en transición de escena [M]
- [x] Entrada durante diálogo (M21): bloqueada correctamente [M]
- [x] Salida con cámara dentro de un muro (colisión) [M]
- [x] Salida con cámara muy lejos del jugador [M]
- [x] Foto borrada mientras está abierta (referencia inválida) [M]

## T. Robustez

- [x] Manejar álbum vacío con mensaje amistoso [S]
- [x] Manejar fecha inválida del sistema al nombrar archivos [S]
- [x] Manejar preset faltante en metadatos [S]
- [x] Manejar cámara en agua profunda (M51) [M]
- [x] Manejar álbum corrupto con defaults (M60) [C]

## U. Localización (M87/M88)

- [x] Localizar todos los textos del modo foto por claves i18n [M]
- [x] Localizar nombres de presets y mensajes de confirmación [S]
- [x] Localizar metadatos mostrados (fecha/hora/lugar) [M]
- [x] Respetar plurales (fotos restantes) [M]
- [x] Testear HUD en 3 idiomas sin desbordes y nombres de archivo invariantes [M]

## V. Accesibilidad (M58)

- [x] Asegurar lectura del HUD con alto contraste opcional [M]
- [x] Ofrecer tamaño de texto configurable [M]
- [x] Reducir zoom automático con Reduce Motion activo [M]
- [x] Ofrecer subtítulos en notificaciones [S]
- [x] Evitar estroboscopios en la UI y testear colorblind mode [M]

## W. Arte y Sonido

- [x] Definir iconos de controles del modo foto (M46) [M]
- [x] Definir marcadores de encuadre (rejilla de tercios) con toggle [M]
- [x] Añadir guía de horizonte opcional [S]
- [x] Definir sonido de obturador (M43) y vibración sutil (M57) [S]
- [x] Definir el ícono de la cámara en la barra de accesos (M53) [S]

## X. Validación y QA

- [x] Crear validate_photo.gd (modo foto, presets, guardado, rendimiento) [C]
- [x] Probar ciclo completo: entrar → ajustar → posar → capturar → ver álbum [C]
- [x] Probar ciclo de compartición con confirmación [C]
- [x] Probar salida del modo foto restaurando TODO el estado [C]
- [x] Revisar logs PHOTO-* en consola sin errores [S]

## Y. Integraciones Restantes

- [x] Registrar PHOTO_TAKEN en el diario (M55) [M]
- [x] Asociar foto a entrada del diario al tomarla [M]
- [x] Alimentar logros de coleccionista (M72) [M]
- [x] Probar compatibilidad con guardados antiguos (M60) [C]
- [x] Documentar plan de testings automáticos del modo foto [M]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Push del módulo y reporte al usuario [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
