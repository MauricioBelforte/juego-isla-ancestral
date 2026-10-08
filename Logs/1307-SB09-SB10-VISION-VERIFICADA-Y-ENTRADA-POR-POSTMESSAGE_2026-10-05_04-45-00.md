# Log 1307: SB-09 + SB-10 — MI VISIÓN FUNCIONA, y la entrada funciona por `PostMessage`

**Fecha:** 2026-10-05
**Hora:** 04:45:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

## Resumen

**Respuesta a la pregunta del director: SÍ, mi visión funciona.** Y de paso comprobe que
**puedo entregar teclado al juego** — pero solo por una vía concreta.

| Ítem | Veredicto |
|---|---|
| **SB-09** — ¿funciona mi visión? | **SÍ.** Capturé y analisé el viewport del juego corriendo |
| **SB-09** — ¿el diario se abre con J? | **SÍ, se abre.** Layout de 3 columnas completo |
| **SB-10** — comparativa antes/después | **ENTREGADA** (2 capturas + reporte de diferencias) |
| Entrada de teclado | **Funciona por `PostMessage`**, NO por `SetForegroundWindow`+`keybd_event` |
| Click de ratón | **NO tengo herramienta.** No puedo pulsar «Cerrar» |

**Este era el test que pediste para decidir si la visión es usable para QA. Lo es: puedo ver y
describir el estado real de la pantalla, y distinguir cambios entre capturas.**

## Cómo lo hice (V2/V3 de la guía de visión)

1. **Lancé el juego en modo ventana** (no headless — el viewport no existe en headless):
   `Godot_v4.7.2-stable_win64.exe --path game/isla-ancestral` → PID 46044.
2. **Listé ventanas** (`screen_list_windows`) → encontré `isla-ancestral (DEBUG)` (936×556).
3. **Capturé el viewport** (`screen_capture_window`).
4. **Entregué la tecla J** y volví a capturar.

## Qué veo — ANTES (captura `sb09_01_viewport_inicial.png`)

- **FPS: 59** (en verde, arriba a la izquierda).
- **Leyenda de controles**renderizada, semi-transparente, arriba a la izquierda:
  `WASD - Mover` · `Scroll - Zoom in/out` · `Escape - Liberar mouse` · `F - Hablar con NPC`.
- **Terreno voxel**: pradera verde claro, bloques de verde oscuro formando bordes/mesetas,
  franja de arena, y **zonas blancas** en el borde superior izquierdo.
- **Personaje jugador** en el centro-abajo: camisa clara, pantalón azul, con sombrero.
- **Triángulos verde oscuro** dispersos sobre la pradera (docenas).
- **Barra roja y barra verde** abajo a la izquierda (HUD de vida/energía).
- **Objetos a la derecha**: bloques naranjas/marrón y una **cristal azul** (mineral).

## Qué veo — DESPUÉS de J (captura `sb10_02_diario_abierto.png`)

**El diario abre.** Contenido exacto que observo:

- Título **«Diario»** (arriba a la izquierda) y una **barra de progreso vacía** al centro.
- **«Progreso del diario: 0%»** (arriba a la derecha) + botón **«Cerrar»**.
- **Layout de 3 columnas**, confirmado:
  - **Columna 1 — «Categorías»**: `Personajes` (resaltado en naranja), `Lugares`, `Criaturas`,
    `Plantas`, `Minerales`, `Recetas`, `Pistas`, `Sellos`, `Ruinas`, `Cartas`.
  - **Columna 2 — «Buscar en»** (campo de texto) + **«Filtro»** con desplegable en **«Todos»**.
  - **Columna 3 — «Detalle»**: botón **«Favorito»** (deshabilitado) y el texto
    **«Elegí una entrada para ver su detalle.»**
- FPS baja a ~59-60 (no se midió con precisión, la captura es estática).

**Conclusión de SB-10:** el layout de 3 columnas de mimo **está implementado y es visible**. Las 10
categorías del diario renderizan. El `0%` es coherente con que el diario esté vacío en una partida
nueva.

## Lo que NO pude hacer (y por qué importa)

### 1. `SetForegroundWindow` + `keybd_event` NO funciona

**Primero intenté esto y falló.** Presioné J → el diario no abrió. Presioné B (`inventario`, misma
clase de acción) → **tampoco abrió nada**.

Ese control fue la decisión clave: **si B tampoco funcionaba, el problema era mi método de
inyección, no el diario.** Si no lo hubiera hecho, habría reportado «el diario está roto» — un
bug inventado.

### 2. `PostMessage` SÍ funciona

Cambié a `PostMessageW(hwnd, WM_KEYDOWN/WM_CHAR/WM_KEYUP)` apuntando al HWND de la ventana, con
el scancode set-1 correcto (`J` = VK `0x4A`, scan `0x24`). **El diario abrió al primer
`PostMessage`.** Es la vía que usan los testers automáticos de Windows.

### 3. El diario **no se cierra con J ni con ESC**

- J de nuevo → sigue abierto (no es toggle).
- ESC → sigue abierto.
- El único cierre visible es el botón **«Cerrar»**, al que **no puedo llegar**: **no tengo
  herramienta de click de ratón**.

**Esto es un hallazgo, no una limitación mía solamente:** si el diseño pretendía que J alternara
(abriera/cerrara), hay un bug. Si el diseno intencionado es «J abre, se cierra con el botón»,
entonces está bien pero es un detalle de UX que **no puedo verificar** por falta de click.

### 4. Limitación de capacidad que declaro

| Capacidad | Estado |
|---|---|
| Capturar pantalla completa | ✅ |
| Capturar ventana por título | ✅ |
| Guardar captura a archivo | ✅ |
| Analizar lo que veo | ✅ |
| Entregar teclado (`PostMessage`) | ✅ |
| **Click de ratón** | ❌ **no tengo** |
| Redimensionar la ventana | ❌ no tengo |

**Para QA visual soy útil en: antes/después, regresión de render, y detectar「se ve roto».**
**No soy útil en: interactuar con la UI (clics), ni en pruebas que requieran pulsar botones.**

## Observaciones del render (sin afirmar bugs)

Las reporto como **observación**, no como diagnóstico — no tengo el código de voxelización a mano
y no voy a inventar la causa:

1. **Las zonas de agua se ven blancas**, no azules. El borde superior izquierdo y la franja
   izquierda son blancos/grisáceo. Puede ser agua sin texturizar, o niebla, o snow. **No lo se.**
2. **Los «triángulos verde oscuro»** sobre la pradera: decenas de objetos planos con forma de cono. Puede
   ser vegetación impostor, arbustos, o placeholder. Se ven **planos** (sin volumen), lo que
   sugiere que son **quads orientadas al cámara** o geometría sin grosor.
3. El **FPS 59-60** es bueno para el presupuesto de 60.

**Las tres son hipotesis de lectura de pantalla, no verificaciones.** Para confirmarlas hace falta
el código de esos sistemas.

## Artefactos

### Capturas (fuera del repo, en temp)
- `%TEMP%\sb09_01_viewport_inicial.png` (111.386 bytes) — antes.
- `%TEMP%\sb10_02_diario_abierto.png` (69.350 bytes) — diario abierto.

**No las metí al repo:** `tools/mcp/godot-mcp/capturas/` es de otra vía (M154/V2) y el director no me
pidió guardarlas ahí. Si las querés versionadas, decime la ruta y las copio.

### Archivos de este log
- `Logs/1307-SB09-SB10-VISION-VERIFICADA-Y-ENTRADA-POR-POSTMESSAGE_2026-10-05_04-45-00.md` — este.
- `Mensajes entre modelos/space-bunny-alpha/17-...` — informe al director.

**En el temp de Kilo** (fuera del repo, se borra solo): `postmessage.py` (inyección por
`PostMessage`) y `enviar_tecla.py` (la variante con `SetForegroundWindow`, que **no** funciona —
la dejo para que quede documentado que se probó).

## Mis errores (4)

| # | Error | Detección |
|---|---|---|
| 1 | **`keybd_event` no llega al juego** | Lo probé con **dos** teclas (J y B) antes de culpar al diario |
| 2 | Regex `"physical_keycode"` con comillas → «0 teclas de 18» | El dato me contradijo: el diario **sí** tiene tecla 74 |
| 3 | `ord("ESC")` → `TypeError` | traceback |
| 4 | Desempaquetado 3→2 valores → `ValueError` | traceback |

**E1 es la lección:** el primer intento dio «el diario no abre». Podía haberlo reportado como bug
del diario y habría sido **falso**. Lo impidió un **control** (probé otra tecla y falló igual).
**Un control negativo vale mas que una medicion aislada.**

## Recomendación sobre mi perfil

**Mi visión es usable para QA visual de antes/después y regresión de render.** No lo es para
interacción con UI (sin click). Con eso creo que tengo material para **C3** (visión + GDScript
juntos) — pero eso lo decidís vos.

---

**Firma:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-05 04:45:00