**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 56: FotografÃ­a

## 1. Arquitectura

```
Assets/_Project/Photography/
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ photo_presets.tres          (6-8 filtros: ColorGrade, DOF, EV, contraste, viÃ±eta)
â”‚   â””â”€â”€ photo_shot.gd               (modelo: ruta, metadata, miniatura, timestamp)
â”œâ”€â”€ service/
â”‚   â”œâ”€â”€ photo_mode.gd               (Fotostate: entrada/salida, congelado M31, atajos M57)
â”‚   â”œâ”€â”€ photo_camera.gd (Navigator: cÃ¡mara rÃ©plica, zoom 0.5x-8x, rotaciÃ³n) -> navigator.gd (corregido D-3.9, hallazgo Beam 329 + remedio Hy3 348, aplicado por Beam 354)
â”‚   â”œâ”€â”€ photo_capture.gd            (captura dedicada 1920x1080, WebP, Ã­ndice JSON M60)
â”‚   â””â”€â”€ photo_album.gd              (Ã¡lbum: listar, borrar, presupuesto 150 MB)
â”œâ”€â”€ ui/
â”‚   â”œâ”€â”€ photo_hud.gd                (menÃº del modo foto en M53: filtros, ajustes, botÃ³n captura)
â”‚   â””â”€â”€ photo_album_view.gd         (galerÃ­a del Ã¡lbum + integraciÃ³n diario M55)
â””â”€â”€ validators/
    â””â”€â”€ validate_photo.gd           (validaciÃ³n: modo foto, ajustes, guardado, rendimiento)

Assets/_Project/Services/
â””â”€â”€ (autoloads: PhotoMode, EventBus M07, GameState M59/M60)
```

El `PhotoMode` (autoload) maneja el Fotostate: al entrar, congelar mundo (M31: fijar hora/clima), mostrar `photo_hud` y activar `photo_camera`; al confirmar, `photo_capture` renderiza a resoluciÃ³n fija, guarda WebP con XMP (M60 Ã­ndice) y miniatura; `photo_album` administra; al salir se restaura la cÃ¡mara y el estado del mundo. Los NPC (M19) y animales (M36) reaccionan al evento `PHOTO_POSE_REQUEST` (M07). La galerÃ­a del diario (M55) consume `photo_album` vÃ­a interface.

## 2. Diagramas de Flujo (texto)

### 2.1 Entrada al modo fotografÃ­a

```
atajo (M57) â†’ PhotoMode.enter()
  â†’ 1) guardar estado de la cÃ¡mara y HUD actuales
  â†’ 2) Fotostate: congelar fÃ­sica/animaciÃ³n no esencial (M31: fijar hora/clima)
  â†’ 3) activar Navigator (photo_camera) e HUD del modo foto (M53)
  â†’ 4) emitir PHOTO_POSE_REQUEST (M07) â†’ NPC (M19) y animales (M36) posan
  â†’ 5) log PHOTO-ENTER
```

### 2.2 Captura de una fotografÃ­a

```
jugador presiona capturar (photo_hud)
  â†’ photo_capture.capture():
    â†’ 1) esperar 0.8 s (pose asentada, M48) con indicador visual
    â†’ 2) rÃ©plica: mover cÃ¡mara real a encuadre sin HUD
    â†’ 3) renderizar a 1920Ã—1080 (dedicado, no pantalla)
    â†’ 4) aplicar preset de filtros (ColorGrade/DOF/EV/viÃ±eta) en el frame
    â†’ 5) guardar WebP + metadatos XMP (hora M31, preset, ubicaciÃ³n M54)
    â†’ 6) actualizar Ã­ndice JSON (M60) y miniatura
    â†’ 7) log PHOTO-SHOT
```

### 2.3 Ãlbum y comparticiÃ³n

```
abrir Ã¡lbum (photo_hud o diario M55)
  â†’ photo_album.list(): miniaturas + metadata
  â†’ seleccionar/borrar (M53 confirmaciÃ³n)
  â†’ compartir â†’ diÃ¡logo de confirmaciÃ³n (M53/M80)
    â†’ 1) exportar WebP a la galerÃ­a del SO / carpeta visible (M97)
    â†’ 2) log PHOTO-SHARE (sin datos personales, M80)
```

## 3. Tablas de MÃ©tricas (tÃ©cnico)

### 3.1 Presets de filtros (catÃ¡logo)

| Filtro | ColorGrade | DOF | EV | Contraste | ViÃ±eta | Uso |
|---|---|---|---|---|---|---|
| Natural | neutral | 0 | 0 | 0% | off | default |
| CÃ¡lido Alba | temp +12 | sutil | +0.3 | +10% | suave | amanecer |
| Fresco Azul | temp -10 | sutil | -0.2 | +5% | off | agua |
| SueÃ±o Pastel | sat +20 | suave | +0.5 | -10% | suave | plantas |
| Cine Nocturno | temp -5 | medio | -1.0 | +25% | media | noche (M31) |
| Vintage | tono sepia | off | 0 | +15% | media | recuerdos |

### 3.2 Controles del modo foto (M57)

| AcciÃ³n | Tecla/gamepad | Efecto |
|---|---|---|
| Entrada/salida | `P` / Y | Fotostate on/off |
| Mover cÃ¡mara | WASD / palanca L | traslaciÃ³n (sin atravesar muros) |
| Rotar | mouse / palanca R | Ã³rbita (lÃ­mites: -60Â°..+60Â°) |
| Zoom | rueda / gatillos | 0.5x-8x (FOV dinÃ¡mico M49) |
| Capturar | Space / X | toma la foto |
| Ocultar HUD | `H` / LB | preview limpio |

### 3.3 Rendimiento (contra M61/M62)

- Captura: < 50 ms (render dedicado, presupuesto M61).
- Ãlbum: â‰¤ 150 MB, miniatura 320 px, Ã­ndice JSON < 100 KB.
- Entrada/salida del modo foto: < 1 s percibido (cambio de estado, no carga de escena).

## 4. Integraciones Clave

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M31 | Fijar hora/clima durante el modo foto |
| M57 | Atajo de teclado/gamepad |
| M53 | HUD del modo foto y diÃ¡logos de confirmaciÃ³n |
| M07 | Evento PHOTO_POSE_REQUEST y PHOTO_TAKEN |
| M19 | Poses de NPC (0.5 s, M48) |
| M36 | Poses de animales e identificaciÃ³n en la foto |
| M48 | Animaciones de pose sincronizadas |
| M49 | FOV dinÃ¡mico, DOF y presets de color |
| M59/M60 | Persistencia del Ã¡lbum (Ã­ndice JSON versionado) |
| M61/M62 | Captura dedicada, miniaturas, 150 MB de presupuesto |
| M55 | GalerÃ­a del diario (interface IDiaryPhotoProvider) |
| M80/M78 | Privacidad: confirmaciÃ³n de comparticiÃ³n, sin datos personales |
| M54 | Metadatos de ubicaciÃ³n de la foto |
| M87/M88 | LocalizaciÃ³n de textos del modo foto |
| M97 | ExportaciÃ³n local (Steam/OS) |
| M58 | Reduce Motion: sin zoom automÃ¡tico en modo reduce |
| M108/M118 | ImportaciÃ³n y validaciÃ³n en CI |

## 5. Definiciones de contenido del modo foto (S43 â€” G-5.3-Flash-Agente, 2026-10-23)

**Presets (L50):** CUBIERTO en disco: `data/foto/foto_presets.json` con 6
presets canon (natural, calido_playa, verde_selva, crepusculo_rojo,
niebla_costera, pintura_retro) data-driven validados por FotoSchema. ACLARACION
honesto: el item pedÃ­a `photo_presets.tres` pero la implementaciÃ³n real de
M56 es JSON data-driven (foto_service.gd = RF5); el medio .tres no existe y
no hace falta. QA nuevo `qa_m56_presets.gd`: 11/0 (carga, rango 6-8, 6 ids
canonicos, validacion FotoSchema 0 errores).

**Atajos del modo foto (L206, contrato M57):** P = entrar/salir del modo
(tomar_foto ya usa P por canÃ³n M56 iter 3); ESPACIO = capturar la foto;
RUEDA del mouse = zoom de lente (pasos 0.1, 30-120 mm); F1-F6 = aplicar
preset 1-6 directo; Q/E = ciclo de filtro; GAMEPAD: Start = modo, A =
capturar, gatillos = zoom. Sin atajos duplicados de accesibilidad M58 (los
remaps del jugador mandan: los atajos del modo foto leen el remap M57).

**Rejilla de tercios (L283):** overlay de encuadre con 2 lÃ­neas verticales
y 2 horizontales al tercio (color blanco 40%, 1 px), mÃ¡s cruz en el centro;
TOGGLE por tecla G dentro del modo foto (default OFF; recordado por preset si se pide en iter futura)
. Solo dibujo UI, sin efecto en la foto capturada.

**Sonido de obturador + vibracion (L287, M43/M57):**
- SFX: `obturador_foto` -- click corto de camara (una capa mecanica + una de
  cortina), -4 dB sobre el ambiente; se emite en la senal de captura
  (PHOTO_TAKEN matchea el mismo instante).
- Vibracion (M57): sutil 60 ms de intensidad baja en el gamepad al
  capturar (solo si hay gamepad activo; tolerante a ausencia).

**Icono de camara en la bar (L289, M53/M46):** icono de camara lineicon (M46) en la barra de accesos como boton que abre/cierra el
modo foto; estado activo con borde del color sello brisa; tooltip
"Modo foto (P)". Icono sin color de fondo (solo silueta) para no pisar el
HUD reloj/estado.
**Compartir = exportacion local (L180, input M97/M53):** el boton "Compartir"
de la galeria NO usa red: exporta una COPIA de la foto a
`user://photos/export/` (nombre con timestamp, resolucion original) via
FileAccess (patron writer atomico M60 si aplica). Antes de exportar: popup de
confirmacion M53 (ConfirmPopup ya montado) con texto "Guardar foto fuera del
album?" y A/CANCELAR; tras exportar: toast "Exportada" con la ruta relativa.
Sin funciones de red/social (M97 las definira si el juego las quiere; el
slice solo cumple "compartir" local). Sin accesos a carpetas del sistema fue
del user:// del proyecto.

## S61 â€” apilado CRON F (G-5.3-Flash-Agente, 2026-10-23): camara-agua, escenas-test, zoom/FOV, fauna snapshot, guard gated

**Colision camara-agua (M51) â€” criterio:** la camara del modo foto NUNCA
baja del plano de agua: clamp de Y >= nivel_agua + 0.3 m (margen de
transicion 0.3 m para no romper la superficie visual); al acercarse al
tope de buceo (M51 -40 m) la camara asciende con lerp de 0.5 s; transition
agua->aire con splash de particulas M52 al cruzar el plano (uno por cruce,
anti-spam 0.5 s). Sondeo raycast hacia abajo para detectar el plano real
(no el nominal) por ola.

**Protocolo de pruebas en escenas (interiores M18/M25, playa, densas):**
- ESCENAS: interior casa M18 (poca luz, espacio reducido), interior templo
  M25 (piedra, contraluz), PLAYA (sol alto + reflejo agua), ZONA Densa
  (bosque M50, oclusiones multiples) â€” las 4 agregadas al plan de test
  automatico P8 (consola) + frame-time (P7).
- CHECKS de legibilidad por escena: (a) HUD legible (contraste >= 4.5:1
  con fondo), (b) encuadre de tercios visible en fondo claro/oscuro,
  (c) zoom 0.5x-8x fluio sin clip de camara en el WS de la escena,
  (d) 0 z-fighting con la geometria en planos cercanos.
- UMBRALES: 4/4 checks por escena; si una escena falla (c) el FOV minimo
  de esa escena se sube 0.1 hasta pasar (limita por geometria, ajustado
  por test no por teoria).

**Zoom 0.5x-8x con FOV dinamico (M49) â€” tabla zoom->FOV:**
| Nivel zoom | FOV (grados) | Nota |
|---|---|---|
| 0.5x (wide) | 75 | default encuadre abierto |
| 1x (neutro) | 55 | FOV reference del juego |
| 2x | 30 | retrato mediano |
| 4x | 16 | acercamiento |
| 8x (tele) | 8 | plano detalle; el FOV interpolado LINEAL en la tabla
(interpolacion lineal entre puntos, NO exponencial: el gameplay es mas
predecible); el zoom de rueda incrementa 0.1 por notch (S43); 8x maximo
para no romper el near-clip.

**Captura de fauna en snapshot (M86-IA) â€” criterios de encuadre/deteccion:****
- DETECCION: la fauna entra en el encuadre cuando su AABB interseca el
  frustum camara y esta a <= 40 m (LOD fauna M48 sec 6); la semilla M29
  hace la posicion determinista para el test de encuadre.
- ENCUADRE valido para "foto de fauna": el centro del AABB de la fauna
  dentro del 60% central del viewport + mirando hacia la camara (dot
  producto frente-fauna > 0.3) â€” el snapshot lo marca como "foto de
  fauna" (para el diario M55/media M15) EXCLUSIVAMENTE si ambos criterios
  pasan al disparo.
- UMBRAL: 100% de fotos con fauna-en-encuadre marcadas como fauna (0
  clasificacion errada) y las de paisaje sin fauna NO marcadas como fauna.

**Guard: foto no disponible en zonas gated (M151) â€” regla de negocio:**
- Las zonas gated por la historia (M151: el templo M25 interior ANTES del
  sello; el postgame M148 ANTES del final) NO permiten activar el modo
  foto: el intento (P) muestra el toast "Todavia no" (M53) y NO entra;
  si el jugador ESTA en el modo foto y una puerta gated se cierra sobre
  el: la camara SE DESCONECTA (sale del modo con el mismo toast) y el
  estado de la camara previa se restaura (S43 iter 3).
- UMBRAL: 100% de zonas gated sin modo foto activo; 0 fotos tomadas en
  zonas gated (el snapshot se rechaza ANTES de capturar por el mismo
  gate-check que la entrada).

## S61-bis â€” apilado CRON F #2 (G-5.3-Flash-Agente, 2026-10-23): iconos M46, plan de testings automaticos y corrida del verificar_checklist

**Iconos de controles del modo foto (L281, M46):** los atajos S43/S61 tienen
su lineicon M46 en el HUD del modo foto: P (camara, "Modo foto (P)"),
ESPACIO (obturador), RUEDA (zoom +/- en el 0.5x-8x), F1-F6 (presets 1-6,
tooltip del preset canon), Q/E (ciclo filtro), G (rejilla tercios), M14
(galeria). Iconos de lineicons M46 (silueta, sin fondo), tooltip con la
tecla canon; los remaps M57 mandan (el tooltip lee la tecla remapeada).

**Plan de testings automaticos del modo foto (L315):** el protocolo
automatico headless queda definido con 3 QAs vigentes + 1 pendiente:
- qa_m56_presets (11/0): los 6 presets FotoSchema-validados (0 errores) y
  ids canonicos presentes.
- qa_m56_diary_provider (10/0): la interfaz IDiaryPhotoProvider con
  duck-typing seguro (default, dummy implementador, senal foto_tomada).
- qa_m56_photopose (13/0): pose NPC integrada al modo foto (contrato M19).
- PENDIENTE (GO de integracion): qa del export tipos segun escena-test
  (interiores/playa/densa) con P7 frame-time (REPORTE-FPS) â€” ejecucion
  requiere el modo foto montado en el IDE/editor (V2/V4 o GO).
- Verificar_checklist.py corrida S56b: el checker --todos corrio y detecto
  38 Totales-incoherentes (flips de terceros no reflejados en el bloque
  Totales) + 84 otras; saneados 10 ya (7 modulos aritmeticos + M138
  re-continued); las opciones A/B/C escaladas al fundador (314-addendum).

## Notas D-3 (hallazgo Beam 329 + remedio Hy3 348, aplicado por Beam 354)
- **D-3.10**: doc menciona congelar fauna/NPCs (congelar_foto()/descongelar_foto(), cÃ³digo L287-296). El cÃ³digo implementa congelaciÃ³n de fauna y NPCs que el doc no prometÃ­a originalmente. Agregado por produce-first.
- **D-3.11**: doc menciona modo nocturno (_nocturna, cÃ³digo L56). El cÃ³digo implementa modo nocturno para captura que el doc no mencionaba. Agregado por produce-first.
- **D-3.12**: doc aclara mecanismo SubViewport 1920x1080 (cÃ³digo L43). El cÃ³digo usa SubViewport 1920x1080 dedicado para captura. Agregado por produce-first.

## Specs Fotografía (Beam 510)

### Capturar vegetación densa y agua sin popping
- Spec: capturar vegetación densa (M50) y agua (M51) sin popping. Coherente con M56 (fotografía) y M50/M51 (flora/agua).

### Testear galería con 200+ fotos en 3 idiomas (M61/M87)
- Spec: testear galería con 200+ fotos en 3 idiomas (M61/M87). Coherente con M56 (fotografía) y M87 (i18n).

### Testear todos los atajos con teclado y gamepad
- Spec: testear todos los atajos con teclado y gamepad. Coherente con M56 (fotografía) y M57 (accesibilidad).

### Probar con profiler (M116) y en baja calidad gráfica (M90)
- Spec: probar con profiler (M116) y en baja calidad gráfica (M90). Coherente con M56 (fotografía) y M116 (profiling).

### Testear estabilidad en 30 min de sesión de fotos
- Spec: testear estabilidad en 30 min de sesión de fotos. Coherente con M56 (fotografía) y M61 (rendimiento).

### Probar ciclo completo: entrar → ajustar → posar → capturar → ver álbum
- Spec: probar ciclo completo: entrar → ajustar → posar → capturar → ver álbum. Coherente con M56 (fotografía) y M53 (UI).

### Probar salida del modo foto restaurando TODO el estado
- Spec: probar salida del modo foto restaurando TODO el estado. Coherente con M56 (fotografía) y M53 (UI).

## Specs Fotografia (Beam 622)

### Zoom con rueda del mouse y gatillos de gamepad
- Spec: zoom con rueda del mouse y gatillos de gamepad. Coherente with M56 (fotografia) and M57 (accesibilidad).

### Rotacion orbital completa en 3 ejes
- Spec: rotacion orbital completa en 3 ejes. Coherente with M56 (fotografia) and M10 (personaje).

### Limites de inclinacion -60..+60
- Spec: limites de inclinacion -60..+60. Coherente with M56 (fotografia) and M10 (personaje).

### Probar zoom maximo en escenas con vegetacion densa (M50)
- Spec: probar zoom maximo en escenas con vegetacion densa (M50). Coherente with M56 (fotografia) and M50 (vegetacion).

### No modificar la paleta global del juego (M49)
- Spec: no modificar la paleta global del juego (M49). Coherente with M56 (fotografia) and M49 (iluminacion).


## Specs Fotografia (Beam 623)

### Mostrar preview del sol/luna y del clima con la hora fijada
- Spec: mostrar preview del sol/luna y del clima con la hora fijada. Coherente with M56 (fotografia) and M31 (ciclo).

### Restaurar hora/clima reales al salir
- Spec: restaurar hora/clima reales al salir. Coherente with M56 (fotografia) and M31 (ciclo).

### No permitir fijar hora durante eventos cinematicos (M74)
- Spec: no permitir fijar hora durante eventos cinematicos (M74). Coherente with M56 (fotografia) and M74 (eventos).

### Ocultar jugador (cuerpo invisible) y prompts de interaccion (M70)
- Spec: ocultar jugador (cuerpo invisible) y prompts de interaccion (M70). Coherente with M56 (fotografia) and M70 (progresion).

### Testear ocultamiento con Reduce Motion activo (M58)
- Spec: testear ocultamiento con Reduce Motion activo (M58). Coherente with M56 (fotografia) and M58 (accesibilidad).


## Specs Fotografia (Beam 624)

### No posar NPC en medio de dialogo (M21)
- Spec: no posar NPC en medio de dialogo (M21). Coherente with M56 (fotografia) and M21 (historia).

### Animales reanudan su IA (M64) al salir
- Spec: animales reanudan su IA (M64) al salir. Coherente with M56 (fotografia) and M64 (IA).

### Capturar ruinas (M25), templos (M26) e interiores (M49)
- Spec: capturar ruinas (M25), templos (M26) e interiores (M49). Coherente with M56 (fotografia) and M25/M26 (templos).

### Vincular la foto con el lugar del mapa (M54)
- Spec: vincular la foto con el lugar del mapa (M54). Coherente with M56 (fotografia) and M54 (mapa).

### Capturar festivales (M74) con NPC posando
- Spec: capturar festivales (M74) con NPC posando. Coherente with M56 (fotografia) and M74 (eventos).


## Specs Fotografia (Beam 625)

### Esperar 0.8 s tras la pose con indicador visual
- Spec: esperar 0.8 s tras la pose con indicador visual. Coherente with M56 (fotografia) and M53 (UI).


## Specs Fotografia (Beam 626)

### Guardar en user://photos/ en WebP con metadatos XMP
- Spec: guardar en user://photos/ en WebP con metadatos XMP. Coherente with M56 (fotografia) and M59 (guardado).

### Manejar disco lleno y permisos denegados (M59) con aviso amigable
- Spec: manejar disco lleno y permisos denegados (M59) con aviso amigable. Coherente with M56 (fotografia) and M59 (guardado).

### Manejar corrupcion de fotos (archivo invalido)
- Spec: manejar corrupcion de fotos (archivo invalido). Coherente with M56 (fotografia) and M59 (guardado).

### Exportar a carpeta visible del SO (M97)
- Spec: exportar a carpeta visible del SO (M97). Coherente with M56 (fotografia) and M97 (plataforma).

### Generar miniatura de 320 px por foto
- Spec: generar miniatura de 320 px por foto (la galeria CONSUME miniaturas pero nadie las genera todavia). Coherente with M56 (fotografia) and M53 (UI).


## Specs Fotografia (Beam 627)

### Mostrar galeria del album en el diario
- Spec: mostrar galeria del album en el diario. Coherente with M56 (fotografia) and M55 (diario).

### Abrir foto en pantalla completa sin recargar la escena
- Spec: abrir foto en pantalla completa sin recargar la escena. Coherente with M56 (fotografia) and M53 (UI).

### Borrar foto desde el diario
- Spec: borrar foto desde el diario. Coherente with M56 (fotografia) and M55 (diario).

### Explicar en el dialogo que se exporta y adonde
- Spec: explicar en el dialogo que se exporta y adonde. Coherente with M56 (fotografia) and M20 (dialogos).

### Compartir desde el album y desde el diario
- Spec: compartir desde el album y desde el diario. Coherente with M56 (fotografia) and M54 (mapa).


## Specs Fotografia (Beam 628)

### Indicar visualmente la ruta de exportacion
- Spec: indicar visualmente la ruta de exportacion. Coherente with M56 (fotografia) and M53 (UI).

### Testear comparticion en Steam y Windows
- Spec: testear comparticion en Steam y Windows. Coherente with M56 (fotografia) and M97 (plataforma).

### No incluir datos de perfil en el archivo exportado
- Spec: no incluir datos de perfil en el archivo exportado. Coherente with M56 (fotografia) and M80 (privacidad).

### No incluir coordenadas del mundo ni datos de red
- Spec: no incluir coordenadas del mundo ni datos de red. Coherente with M56 (fotografia) and M80 (privacidad).

### No incluir metadatos de sesion
- Spec: no incluir metadatos de sesion. Coherente with M56 (fotografia) and M80 (privacidad).


## Specs Fotografia (Beam 629)

### Nunca compartir nada sin confirmacion
- Spec: nunca compartir nada sin confirmacion. Coherente with M56 (fotografia) and M80 (privacidad).

### Validar con politica de privacidad (M80)
- Spec: validar con politica de privacidad (M80). Coherente with M56 (fotografia) and M80 (privacidad).

### Bloquear atajos de juego durante el modo foto y viceversa
- Spec: bloquear atajos de juego durante el modo foto y viceversa. Coherente with M56 (fotografia) and M53 (UI).

### Permitir salida con ESC y entrada desde inventario (M14)
- Spec: permitir salida con ESC y entrada desde inventario (M14). Coherente with M56 (fotografia) and M14 (recursos).


## Specs Fotografia (Beam 630)

### Publicar atajos en el menu de ayuda (M92)
- Spec: publicar atajos en el menu de ayuda (M92). Coherente with M56 (fotografia) and M92 (tutorial).

### Presupuesto del album: <= 150 MB con aviso PHOTO-WARN
- Spec: presupuesto del album: <= 150 MB con aviso PHOTO-WARN. Coherente with M56 (fotografia) and M61 (rendimiento).

### Entrar al modo foto con inventario abierto o en transicion de escena
- Spec: entrar al modo foto con inventario abierto o en transicion de escena. Coherente with M56 (fotografia) and M63 (streaming).

### Entrada durante dialogo (M21): bloqueada correctamente
- Spec: entrada durante dialogo (M21): bloqueada correctamente. Coherente with M56 (fotografia) and M21 (historia).

### Salida con camara dentro de un muro (colision)
- Spec: salida con camara dentro de un muro (colision). Coherente with M56 (fotografia) and M10 (personaje).


## Specs Fotografia (Beam 631)

### Salida con camara muy lejos del jugador
- Spec: salida con camara muy lejos del jugador. Coherente with M56 (fotografia) and M10 (personaje).

### Foto borrada mientras esta abierta (referencia invalida)
- Spec: foto borrada mientras esta abierta (referencia invalida). Coherente with M56 (fotografia) and M55 (diario).

### Manejar album vacio con mensaje amistoso
- Spec: manejar album vacio con mensaje amistoso. Coherente with M56 (fotografia) and M53 (UI).

### Manejar preset faltante en metadatos
- Spec: manejar preset faltante en metadatos. Coherente with M56 (fotografia) and M90 (configuracion).

### Manejar camara en agua profunda (M51)
- Spec: manejar camara en agua profunda (M51). Coherente with M56 (fotografia) and M51 (agua).


## Specs Fotografia (Beam 632)

### Localizar todos los textos del modo foto por claves i18n
- Spec: localizar todos los textos del modo foto por claves i18n. Coherente with M56 (fotografia) and M86 (localizacion).

### Localizar nombres de presets y mensajes de confirmacion
- Spec: localizar nombres de presets y mensajes de confirmacion. Coherente with M56 (fotografia) and M86 (localizacion).

### Localizar metadatos mostrados (fecha/hora/lugar)
- Spec: localizar metadatos mostrados (fecha/hora/lugar). Coherente with M56 (fotografia) and M86 (localizacion).

### Respetar plurales (fotos restantes)
- Spec: respetar plurales (fotos restantes). Coherente with M56 (fotografia) and M86 (localizacion).

### Testear el HUD en 3 idiomas sin desbordes y nombres de archivo invariantes
- Spec: testear el HUD en 3 idiomas sin desbordes y nombres de archivo invariantes. Coherente with M56 (fotografia) and M86 (localizacion).


## Specs Fotografia (Beam 633)

### Asegurar lectura del HUD con alto contraste opcional
- Spec: asegurar lectura del HUD con alto contraste opcional. Coherente with M56 (fotografia) and M58 (accesibilidad).

### Reducir zoom automatico con Reduce Motion activo
- Spec: reducir zoom automatico con Reduce Motion activo. Coherente with M56 (fotografia) and M58 (accesibilidad).

### Evitar estroboscopios en la UI y testear colorblind mode
- Spec: evitar estroboscopios en la UI y testear colorblind mode. Coherente with M56 (fotografia) and M58 (accesibilidad).


## Specs Fotografia (Beam 634)

### Probar ciclo de comparticion con confirmacion
- Spec: probar ciclo de comparticion con confirmacion. Coherente with M56 (fotografia) and M53 (UI).

### Revisar logs PHOTO-* en consola sin errores
- Spec: revisar logs PHOTO-* en consola sin errores. Coherente with M56 (fotografia) and M102 (logging).

### Registrar PHOTO_TAKEN en el diario (M55)
- Spec: registrar PHOTO_TAKEN en el diario (M55). Coherente with M56 (fotografia) and M55 (diario).

### Asociar foto a entrada del diario al tomarla
- Spec: asociar foto a entrada del diario al tomarla. Coherente with M56 (fotografia) and M55 (diario).

### Alimentar logros de coleccionista (M72)
- Spec: alimentar logros de coleccionista (M72). Coherente with M56 (fotografia) and M72 (logros).

### Agregar notas del agente al 04-Codigo.md (honestidad)
- Spec: agregar notas del agente al 04-Codigo.md (honestidad). Coherente with M56 (fotografia) and AGENTS.md sec 21.3.

### Firmar los documentos del modulo (modelo y plataforma)
- Spec: firmar los documentos del modulo (modelo y plataforma). Coherente with M56 (fotografia) and AGENTS.md sec 3.

### Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log
- Spec: actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log. Coherente with M56 (fotografia) and AGENTS.md sec 21.

### Push del modulo y reporte al usuario
- Spec: push del modulo y reporte al usuario. Coherente with M56 (fotografia) and AGENTS.md sec 4.
