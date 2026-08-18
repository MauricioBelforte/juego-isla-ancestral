**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 56: Fotografía

## 1. Arquitectura

```
Assets/_Project/Photography/
├── data/
│   ├── photo_presets.tres          (6-8 filtros: ColorGrade, DOF, EV, contraste, viñeta)
│   └── photo_shot.gd               (modelo: ruta, metadata, miniatura, timestamp)
├── service/
│   ├── photo_mode.gd               (Fotostate: entrada/salida, congelado M31, atajos M57)
│   ├── photo_camera.gd             (Navigator: cámara réplica, zoom 0.5x-8x, rotación)
│   ├── photo_capture.gd            (captura dedicada 1920x1080, WebP, índice JSON M60)
│   └── photo_album.gd              (álbum: listar, borrar, presupuesto 150 MB)
├── ui/
│   ├── photo_hud.gd                (menú del modo foto en M53: filtros, ajustes, botón captura)
│   └── photo_album_view.gd         (galería del álbum + integración diario M55)
└── validators/
    └── validate_photo.gd           (validación: modo foto, ajustes, guardado, rendimiento)

Assets/_Project/Services/
└── (autoloads: PhotoMode, EventBus M07, GameState M59/M60)
```

El `PhotoMode` (autoload) maneja el Fotostate: al entrar, congelar mundo (M31: fijar hora/clima), mostrar `photo_hud` y activar `photo_camera`; al confirmar, `photo_capture` renderiza a resolución fija, guarda WebP con XMP (M60 índice) y miniatura; `photo_album` administra; al salir se restaura la cámara y el estado del mundo. Los NPC (M19) y animales (M36) reaccionan al evento `PHOTO_POSE_REQUEST` (M07). La galería del diario (M55) consume `photo_album` vía interface.

## 2. Diagramas de Flujo (texto)

### 2.1 Entrada al modo fotografía

```
atajo (M57) → PhotoMode.enter()
  → 1) guardar estado de la cámara y HUD actuales
  → 2) Fotostate: congelar física/animación no esencial (M31: fijar hora/clima)
  → 3) activar Navigator (photo_camera) e HUD del modo foto (M53)
  → 4) emitir PHOTO_POSE_REQUEST (M07) → NPC (M19) y animales (M36) posan
  → 5) log PHOTO-ENTER
```

### 2.2 Captura de una fotografía

```
jugador presiona capturar (photo_hud)
  → photo_capture.capture():
    → 1) esperar 0.8 s (pose asentada, M48) con indicador visual
    → 2) réplica: mover cámara real a encuadre sin HUD
    → 3) renderizar a 1920×1080 (dedicado, no pantalla)
    → 4) aplicar preset de filtros (ColorGrade/DOF/EV/viñeta) en el frame
    → 5) guardar WebP + metadatos XMP (hora M31, preset, ubicación M54)
    → 6) actualizar índice JSON (M60) y miniatura
    → 7) log PHOTO-SHOT
```

### 2.3 Álbum y compartición

```
abrir álbum (photo_hud o diario M55)
  → photo_album.list(): miniaturas + metadata
  → seleccionar/borrar (M53 confirmación)
  → compartir → diálogo de confirmación (M53/M80)
    → 1) exportar WebP a la galería del SO / carpeta visible (M97)
    → 2) log PHOTO-SHARE (sin datos personales, M80)
```

## 3. Tablas de Métricas (técnico)

### 3.1 Presets de filtros (catálogo)

| Filtro | ColorGrade | DOF | EV | Contraste | Viñeta | Uso |
|---|---|---|---|---|---|---|
| Natural | neutral | 0 | 0 | 0% | off | default |
| Cálido Alba | temp +12 | sutil | +0.3 | +10% | suave | amanecer |
| Fresco Azul | temp -10 | sutil | -0.2 | +5% | off | agua |
| Sueño Pastel | sat +20 | suave | +0.5 | -10% | suave | plantas |
| Cine Nocturno | temp -5 | medio | -1.0 | +25% | media | noche (M31) |
| Vintage | tono sepia | off | 0 | +15% | media | recuerdos |

### 3.2 Controles del modo foto (M57)

| Acción | Tecla/gamepad | Efecto |
|---|---|---|
| Entrada/salida | `P` / Y | Fotostate on/off |
| Mover cámara | WASD / palanca L | traslación (sin atravesar muros) |
| Rotar | mouse / palanca R | órbita (límites: -60°..+60°) |
| Zoom | rueda / gatillos | 0.5x-8x (FOV dinámico M49) |
| Capturar | Space / X | toma la foto |
| Ocultar HUD | `H` / LB | preview limpio |

### 3.3 Rendimiento (contra M61/M62)

- Captura: < 50 ms (render dedicado, presupuesto M61).
- Álbum: ≤ 150 MB, miniatura 320 px, índice JSON < 100 KB.
- Entrada/salida del modo foto: < 1 s percibido (cambio de estado, no carga de escena).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M31 | Fijar hora/clima durante el modo foto |
| M57 | Atajo de teclado/gamepad |
| M53 | HUD del modo foto y diálogos de confirmación |
| M07 | Evento PHOTO_POSE_REQUEST y PHOTO_TAKEN |
| M19 | Poses de NPC (0.5 s, M48) |
| M36 | Poses de animales e identificación en la foto |
| M48 | Animaciones de pose sincronizadas |
| M49 | FOV dinámico, DOF y presets de color |
| M59/M60 | Persistencia del álbum (índice JSON versionado) |
| M61/M62 | Captura dedicada, miniaturas, 150 MB de presupuesto |
| M55 | Galería del diario (interface IDiaryPhotoProvider) |
| M80/M78 | Privacidad: confirmación de compartición, sin datos personales |
| M54 | Metadatos de ubicación de la foto |
| M87/M88 | Localización de textos del modo foto |
| M97 | Exportación local (Steam/OS) |
| M58 | Reduce Motion: sin zoom automático en modo reduce |
| M108/M118 | Importación y validación en CI |