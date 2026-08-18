**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 56: Fotografía

## ID del Módulo
- **Código:** M56 (CHECKLIST-GLOBAL: ID 56 — Fotografía; plan maestro: sección 55 "FOTOGRAFÍA")
- **Carpeta:** `DOCUMENTACION/56-Fotografia/`
- **Dependencias:** M53 (UI/UX — menús y notificaciones), M07 (EventBus), M60 (Datos y Serialización — persistencia de álbum). Relaciones: M55 (Diario — galería), M36 (Fauna — captura de animales), M19 (NPC — poses), M57 (Interfaz de Control), M61 (Rendimiento), M62 (Memoria), M58 (Accesibilidad), M87 (Localización), M45/M49 (Arte 3D/Iluminación — contexto visual)
- **Delegable desde:** M53 (UI/UX), M60 (datos)

## 1. Problema

Aurora es una isla fotogénica: paisajes, criaturas, plantas, NPC y festivales merecen ser inmortalizados. Sin un modo fotografía, el proyecto perdería: una mecánica de captura de la vida silvestre (crítico para coleccionistas de M37/M36), una fuente de entrada para el diario (M55), y una herramienta de storytelling automática para los jugadores. Pero un modo fotografía mal implementado rompe la experiencia: cámara libre con física rota, filtros que ocultan la estética cozy del proyecto, fotografías que degradan el rendimiento (M61/M62) o comparten datos privados sin consentimiento. El plan maestro lista 20 exigencias: modo fotografía, cámara libre, zoom, rotación, filtros, profundidad de campo, exposición, contraste, viñeta, hora del día, ocultar interfaz, posar NPC, capturar animales, capturar paisajes, álbum, guardar fotografías, galería, compartir imágenes, privacidad y rendimiento. El objetivo es que el jugador tenga un modo fotografía completo, cozy y responsable: accesible en 1 segundo, sin romper la inmersión, sin riesgo a la privacidad y sin impacto en la performance.

## 2. Objetivo

Definir el sistema de fotografía de la isla: modo fotográfico con cámara libre (movimiento 3DOF, zoom, rotación), ajustes artísticos (filtros, profundidad de campo, exposición, contraste, viñeta), control de hora del día (M31), ocultamiento de la interfaz, captura de animales (M36), poses de NPC (M19), álbum con guardado en disco (M59/M60), galería (integrada al diario M55), compartición opcional con confirmación de privacidad (M80) y validación de rendimiento (M61). El resultado debe ser un modo fotográfico marca de la casa: 1 acceso, UI mínima, sin pausa extraña del mundo (tiempo libre solo en modo foto) y 100% opt-in para compartir.

## 3. Alcance

### 3.1 Dentro del alcance
- Modo fotografía: entrada/salida rápida (M57), mundo congelado o en pausa fotográfica (M31).
- Cámara libre: navegación 3D suave (WASD + mouse, gamepad M57), sin atravesar geometría.
- Zoom: rango 0.5x-8x con campo de visión dinámico (M49).
- Rotación: cámara orbital completa en 3 ejes.
- Ajustes artísticos: filtros (6-8 presets estéticos), profundidad de campo (DOF), exposición, contraste, viñeta; sin post-process invasivo (M49).
- Hora del día: fijación de hora para la foto (M31) con preview del sol/luna.
- Ocultar interfaz: HUD (M53) y jugador ocultables por atajo.
- Captura: animal (M36): animales posan y se congelan en cámara; NPC (M19): poses de NPC; paisaje: escena completa con M45/M46.
- Álbum: persistencia de fotografías (M59/M60) con miniaturas y metadatos; galería en el diario (M55) y visualización.
- Compartir: exportación de imagen opcional (aplicaciones del sistema, nada automático).
- Privacidad: nunca compartir sin confirmación; sin datos del perfil en el archivo (M80/M78).
- Rendimiento: presupuesto de captura (cámara réplica, no screencapture de pantalla), y métricas (M61).
- Validación: `validate_photo.gd` (modo foto, ajustes, guardado, rendimiento).

### 3.2 Fuera del alcance
- La galería completa del diario: M55 (aquí solo el álbum propio).
- La captura de contenido de pantalla del sistema: solo captura de la cámara del juego.
- La compartición en redes sociales: exportación local (Steam/OS) sin account linking.
- Los filtros de color globales del juego: M49/M91 (aquí solo filtros del modo foto).

## 4. Restricciones

- **UI Godot 4 (Control):** sin templates HTML; menú del modo foto en M53.
- **Sin interrumpir la inmersión:** la foto no pausa con diálogo; 1 atajo para entrar (M57) y preview en vivo.
- **Rendimiento:** el modo foto usa una réplica de cámara lógica (Navigator) sin duplicar render; captura < 50 ms (M61); el álbum no excede 150 MB en disco (M62) y usa miniaturas.
- **Persistencia (M59/M60):** álbum versionado; sin dependencias del frame en el save.
- **Privacidad (M80):** compartir siempre con confirmación; sin datos personales ni metadatos de red (sección 21.5 del plan ene).
- **Cozy:** filtros que realzan la estética, nunca la degradan; el DOF es sutil.
- **Validable:** cada funciones pasa `validate_photo.gd` (sin fallos en consola).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Modo fotografía | Entrada/salida por atajo (M57) en < 1 s; mundo pausado fotográficamente (M31) |
| RF2 | Cámara libre | Navegación 3D suave (WASD/mouse/gamepad), con colisión suave y sin atravesar muros |
| RF3 | Zoom | 0.5x-8x con FOV dinámico (M49) y preview del encuadre |
| RF4 | Rotación | Orbita completa en 3 ejes con límites de inclinación |
| RF5 | Filtros | 6-8 presets estéticos no invasivos (cozy) |
| RF6 | Profundidad de campo | DoF ajustable (suave, siempre con foco claro) |
| RF7 | Exposición | Nivel de exposición con preview (EV) |
| RF8 | Contraste | Slider de contraste |
| RF9 | Viñeta | Viñeta opcional (estética cine) |
| RF10 | Hora del día | Fijar hora para la foto (M31) con preview del sol/luna |
| RF11 | Ocultar interfaz | HUD (M53) y jugador ocultables por atajo |
| RF12 | Posar NPC | NPC (M19) posa al recibir el evento de foto (0.5 s) |
| RF13 | Capturar animales | Animales (M36) posan/congelan en cámara; captura sin huir |
| RF14 | Capturar paisajes | Escena completa con M45/M46 y sin HUD |
| RF15 | Álbum | Persistencia del álbum con miniaturas y metadatos |
| RF16 | Guardar fotografías | Guardado en disco con formato comprimido (WebP/PNG) |
| RF17 | Galería | Visualización y borrado desde el álbum y el diario (M55) |
| RF18 | Compartir imágenes | Exportación local opcional (OS) con confirmación |
| RF19 | Privacidad | Nunca compartir sin confirmación; sin datos de perfil en el archivo |
| RF20 | Rendimiento | Captura < 50 ms; álbum ≤ 150 MB; sin impacto en el frame |

## 6. Criterios de Aceptación (Verificables)

1. El modo fotografía se abre/cierra con 1 atajo en < 1 s y pausa el mundo (M31).
2. La cámara libre navega sin atravesar geometría y con zoom 0.5x-8x fluido.
3. Los 6-8 filtros se aplican en vivo (preview) sin modificar el render del juego.
4. Las criaturas (M36) y NPC (M19) posan/congelan durante la foto sin bugs de animación.
5. La captura guarda en el álbum con metadatos y miniatura; el álbum no supera 150 MB.
6. La galería del diario (M55) muestra las fotos del álbum sin recargar la escena.
7. Compartir requiere confirmación y el archivo no contiene datos personales.
8. El modo foto y la captura no degradan el rendimiento (M61) mediblemente.