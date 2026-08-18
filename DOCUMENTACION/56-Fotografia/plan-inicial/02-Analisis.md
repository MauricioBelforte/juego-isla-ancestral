**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 56: Fotografía

## 1. Análisis del Dominio

El dominio del modo fotografía de Aurora se descompone en seis subsistemas:

### 1.1 Modo fotografía y estado del mundo
- **Dominio:** un atajo (M57) entra al modo foto; el mundo se congela (M31 como "modo foto" en vez de pausa dura): NPC y animales posan, el clima se estabiliza, el tiempo se fija.
- **Clave:** el modo foto NO es una pausa de menú: es un estado del juego (Fotostate) que solo congela lo necesario (física/animación) para que la escena sea fotoperfecta.

### 1.2 Cámara réplica (Navigator)
- **Dominio:** la cámara del modo foto es una réplica lógica de la cámara del juego (posición, rotación, FOV) que se controla libremente: traslación (WASD/gamepad), zoom (FOV 0.5x-8x), rotación orbital con límites de inclinación.
- **Clave (rendimiento):** la réplica NO duplica el render: se mueve la cámara real del juego (sin HUD) y se restaura la posición al salir.

### 1.3 Ajustes artísticos
- **Dominio:** filtros (6-8 presets por `ColorGrading`), DOF, exposición (EV), contraste y viñeta. Todos en preview en vivo y guardados por al foto como metadatos.
- **Clave (M49/M91):** los filtros del modo foto no reemplazan la paleta global; el DOF es sutil (no rompe la estética cozy) y los ajustes respetan la franja de M31 (hora fijada).

### 1.4 Captura y poses
- **Dominio:** al activar "posar" se emite un evento (M07) `PHOTO_POSE_REQUEST` que NPC (M19) y animales (M36) responden con una pose de fotografía (0.5 s). La foto se toma después de la pose (retardo de 0.8 s para no capturar tween de pose).
- **Clave:** la captura es una réplica de cámara: se renderiza el frame solo cuando se confirma (botón), con resolución fija de captura (ej: 1920×1080) independiente de la resolución de pantalla.

### 1.5 Álbum y persistencia
- **Dominio:** las fotos se guardan como archivos (WebP con metadatos EXIF en XMP) en `user://photos/` con un índice JSON (M60) versionado; miniatura con resolución baja para la galería (M61).
- **Clave (M62):** presupuesto de 150 MB de disco; si se excede, aviso y opción de limpiar; el índice nunca contiene datos del frame (ninguna referencia a memoria).

### 1.6 Compartición y privacidad
- **Dominio:** "compartir" exporta el archivo a la galería del SO (o abre la carpeta), SIEMPRE con confirmación (diálogo M53); el archivo no contiene nombres de perfil, coordenadas ni metadatos de red (M80/M78).
- **Clave:** sin integraciones de redes sociales; la compartición es local (Steam/OS), sin account linking (M97).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Pausa dura del mundo con menú | **Descartado** | Rompe la inmersión; modo foto = Fotostate ligero |
| Cámara duplicada con render extra | **Descartado** | Doble costo de render; réplica que mueve la cámara real |
| Screencapture de pantalla | **Descartado** | Depende de la resolución; captura debe ser dedicada |
| Captura con resolución de pantalla | **Descartado** | Resolución fija (1920×1080) para consistencia |
| Carpetas de fotos sin índice | **Descartado** | Índice JSON versionado (M60) para migrar y listar |
| Compartir automático a redes | **Descartado** | Privacidad (M80): siempre confirmación; exportación local |
| Filtros globales del juego (M49) | **Descartado** | Los filtros del modo foto son presets de post-proceso del modo |

## 3. Decisiones del Módulo

1. **Fotostate:** estado ligero que congela lo necesario (M31) y permite poses.
2. **Réplica de cámara (Navigator):** mueve la cámara real; captura dedicada a resolución fija.
3. **Ajustes artísticos** en preview en vivo (ColorGrading, DOF, EV, contraste, viñeta).
4. **Poses por eventos (M07):** NPC (M19) y animales (M36) responden a `PHOTO_POSE_REQUEST`.
5. **Álbum persistente** en `user://photos/` con índice JSON (M60) y miniaturas.
6. **Compartir local con confirmación** (M53/M80) sin datos personales.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Modo foto que rompe la inmersión | Media | Medio | Fotostate suave + salida en 1 atajo |
| Captura que degrada el rendimiento (M61) | Media | Alto | Captura dedicada, miniaturas, presupuesto de álbum |
| Fotos con metadatos sensibles | Baja | Alto | Solo XMP de juego; sin perfil/coordenadas (M80) |
| Poses de NPC/animales con bugs | Media | Medio | Evento de pose + retardo 0.8 s + validación de animación (M48) |
| Álbum que crece indefinidamente | Media | Medio | Presupuesto 150 MB con aviso y limpieza |
| Filtros que degradan la estética | Media | Medio | Presets revisados por diseño (cozy, no invasivos) |