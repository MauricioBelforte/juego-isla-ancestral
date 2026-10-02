**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 131: Créditos

## 1. Archivos — estado REAL del código (2026-10-02)

| Archivo | Descripción | Estado |
|---|---|---|
| `res://scripts/legal/credits_manager.gd` | Autoload `credits_manager`: catálogo data-driven, idioma, navegación, easter eggs | Implementado (329 líneas, 27 funciones) |
| `res://scripts/legal/credits_validator.gd` | Validador del catálogo de créditos | Implementado |
| `res://data/legal/creditos.json` | Catálogo: 7 secciones + políticas (`year_display: auto`) | Implementado |
| `res://scripts/ui/layers/credits_layer.gd` | **CreditsLayer** (`UILayer`, `MODAL_FULL`): la pantalla de créditos | **Implementado 2026-10-02** |
| `res://scripts/legal/test_credits_m131.gd` | Test headless del validador y del catálogo | Implementado — 8 checks / 0 fallos |
| `res://scripts/legal/test_credits_layer_m131.gd` | Test headless de la pantalla (Sección D completa) | Implementado 2026-10-02 — **42 checks / 0 fallos** |
| `res://credits/director.gd`, `catalog.tres`, `scene.tscn`, `credits-canvas.tscn`, `data.tres` | Diseño original (Nemotron/Cline) | **No usado**: se resolvió con JSON data-driven + capa runtime, siguiendo el patrón de `scripts/ui/layers/` (sin `.tscn`, §9.47) |

**Montaje:** `ui_root.gd` instancia `credits_layer.gd` en `_build_layers()` y conecta
`menus_layer.creditos_pedido → credits_layer.open()`. Se usa `open()` y **no** `push_layer()`
porque las capas montadas ya están registradas y `push_layer` es no-op para ellas
(`ui_manager.gd` L457-459). La visibilidad `MODAL_FULL` pausa el mundo vía
`UILayer._notification` (§9.50).

## 2. API pública real (la sección "prevista" de abajo era diseño, no código)

Funciones implementadas en `credits_manager.gd`: `cargar_catalogo()`, `obtener_secciones()`,
`obtener_seccion(idx)`, `cantidad_secciones()`, `obtener_seccion_actual()`, `ir_a_seccion(idx)`,
`siguiente_seccion()`, `seccion_anterior()`, `buscar(query)`, `scroll_automatico(velocidad_s)`,
`color_contraste_accesible(fondo)`, `tamano_fuente_base(escala)`, `obtener_idioma()`,
`obtener_idioma_actual()`, `obtener_contribuyentes()`, `obtener_assets_terceros()`,
`cambiar_idioma(nuevo)`, `obtener_year()`, `obtener_copyright()`, `obtener_politicas()`,
`validar_catalogo()`, `saltar_seccion_tecla(keycode)`, `es_extension_desbloqueada()`,
`obtener_farewell()`, `tiene_ducking()`, `get_section_name()`, `get_save_data()`.

**API del plan que NO existe con ese nombre** (discrepancia preexistente, ver Notas del Agente):
`cargar_creditos()` → real `cargar_catalogo()`; `obtener_creditos_idioma(idioma)` → se logra con
`cambiar_idioma(idioma)` + `obtener_secciones()`; `detener_animacion()` → ahora vive en
`CreditsLayer._alternar_anim()`; `obtener_equipos()` / `establecer_idioma()` → no existen.


```gdscript
# Singleton CreditsDirector

func cargar_creditos() -> Dictionary:
    """Carga todos los datos de créditos desde el catálogo."""
    pass

func obtener_equipos() -> Array:
    """Retorna la lista de equipos principales."""
    pass

func obtener_contribuyentes() -> Array:
    """Retorna la lista de contribuyentes voluntarios."""
    pass

func obtener_assets_terceros() -> Array:
    """Retorna la lista de assets de terceros con licencias."""
    pass

func obtener_creditos_idioma(idioma: String) -> Array:
    """Retorna créditos traducidos al idioma especificado."""
    pass

func siguiente_seccion() -> void:
    """Avanza a la siguiente sección de créditos."""
    pass

func detener_animacion() -> void:
    """Detiene la animación automática de desplazamiento."""
    pass

func establecer_idioma(idioma: String) -> void:
    """Cambia el idioma de displayed créditos."""
    pass

func obtener_idioma_actual() -> String:
    """Retorna el idioma actual de displayed créditos."""
    pass
```

## 3. Pendientes de implementación (estado 2026-10-02)

- **Contenido de audio** (los 9 `[ ]` KnownIssue de la sección I del checklist): el proyecto
  **no tiene ni un solo archivo de audio** (0 `.ogg`/`.wav`/`.mp3`/`.opus`), `UIFeedback` crea 4
  `AudioStreamPlayer` pero no les asigna streams, y `sfx_surfaces.json` solo define superficies de
  terreno. Los **motores sí existen** (M41 `MusicDirector` con tema `flow_creditos` ya en la
  matriz, M42 `SFXManager`, M43, M91 `AudioConfigService`) y pasan sus tests.
- Catálogo `.tres` (alternativa al JSON, item E56) — decisión de diseño, no bloquea.
- Búsqueda en tiempo real en la pantalla: la API `buscar(query)` de `credits_manager` existe y
  está probada, pero **la UI no expone el campo de búsqueda** (no era item de la Sección D).

## 4. Notas del Agente

**Modelo:** Nemotron 3.5 Lightning  
**Plataforma:** Cline  
**Fecha:** 2026-08-16 20:12:31  
**Estado:** Diseño completado, documentación lista para agente delegado

### Lo que hice
- Definí la arquitectura completa del sistema de créditos
- Establecí 7 criterios de aceptación basados en requisitos de reconocimiento
- Diseñé la estructura de categorías y configuración de interfaz
- Definí la API pública y archivos previstos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé la base de datos de contribuyentes (pendiente de recopilación real)
- No conecté con los sistemas de configuración M90/M91/M91 (pending)

### Recomendaciones para el próximo agente
- Implementar CreditsDirector.gd con carga de datos y gestión de idioma
- Crear la interfaz UI en Godot CanvasLayer con RichTextLabel
- Integrar sistema de búsqueda y filtrado por nombre/rol/equipo
- Conectar con M90/M91 para configuración de texto y animación

### QA Cruzado P-56 (§21.8) — agnes-3-flash / Kilo Code, 2026-10-02

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-02
**Veredicto:** **M131 NO es sellable a ✅** — queda **🟡 Con dudas**. (audit-only; no se toco codigo)

**Lo que SI verifica (BUG-081 bien resuelto):**
- Los 4 fixes de inferencia están en el código real: `credits_manager.gd:229`
  (`obtener_assets_terceros() -> Array[String]`), `audio_credit.gd:50` (`: String`),
  `audio_credits_generator.gd:33` y `:98` (`: String`).
- Suites re-ejecutadas (binario real Godot 4.7.2, `C:\Temp\godot\godot472.exe`):
  M131 = 8 checks / 0 fallos (exit 0); M84 = 15 checks / 0 fallos (exit 0) — coincide con el brief.
- Log 1178 existe, firmado (mimo-v2.6-flash-free/opencode) y commiteado (`7f00e04`).
- Fila 131 de CHECKLIST-GLOBAL: diff de 1 sola línea, numstat `1 1`, sin normalización CRLF→LF.

**Por qué NO es ✅ (hallazgo central):**
- `05-Checklist.md` de M131 tiene **9 `[?]`** (sección audio SFX/música, todas bloqueadas por
  M41/M42/M43/M91 — el motor de audio aún no existe) + **2 `[ ]`** (.tres catalog, counter).
- DoD §21.6 exige "ningún `[?]`" para sellar ✅. Con 9 `[?]`, M131 **no cumple** y queda correctamente
  en **🟡 Con dudas** (la fila 131 está en 84/95, no en ✅ — el brief había dicho "quedó ✅",
  lo cual no se ajusta al estado real del GLOBAL).
- Los 9 `[?]` son **bloqueos externos documentados** (no fallos del agente): mismo carácter que el
  KnownIssue de M36/M65, pero anotados como `[?]` en vez de `[ ]`.

**Para sellar ✅ (decisión del dueño/coordinador, NO de QA):** reclasificar los 9 `[?]` de audio
a `[ ]` KnownIssue (dueño externo M41/M42/M43/M91) siguiendo el precedente M36/M65 — eso dejaría
"84 `[x]` / 0 `[?]` / 11 `[ ]`" y sí sería sellable. Así como está (9 `[?]`), no.

→ Se delega de vuelta al coordinador con este veredicto.

### Notas del Agente (2026-10-02) - sellado M131

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02 04:27
**Estado:** Seccion D implementada y testeada; seccion de audio reclasificada (no resuelta)

#### Lo que hice
- Implemente `CreditsLayer` (`scripts/ui/layers/credits_layer.gd`): **la pantalla de creditos no
  existia**. `ui_root.gd` solo imprimia `"[M89] Credito -> pendiente de implementar"` y no habia
  ninguna escena `.tscn` de creditos en el repo.
- Lo monte en `ui_root._build_layers()` y cablee `menus_layer.creditos_pedido -> credits_layer.open()`
  (con `open()` y no `push_layer()`, ver razon arriba).
- Test nuevo `scripts/legal/test_credits_layer_m131.gd`: **42 checks / 0 fallos**, cubre los 10
  items de la Seccion D + C38 (contador) + J103/J104/J106.
- Reclasifique los 9 `[?]` de audio a `[ ]` KnownIssue con causa verdadera, cierre C38
  (`[ ]` -> `[x]`) y deje Totales en **95 items / 85 [x] / 10 [ ] / 0 [?]**.

#### Lo que NO pude hacer (honestidad obligatoria)
- **Los 9 items de audio NO estan implementados**: solo se reclasificaron. El bloqueo real es que
  el proyecto no tiene NI UN archivo de audio (0 `.ogg`/`.wav`/`.mp3`/`.opus`), `UIFeedback` no
  asigna streams y `sfx_surfaces.json` solo define superficies de terreno. Los motores M41/M42/M43/M91
  si existen y pasan tests (la causa que constaba en el checklist era falsa).
- **No verifique en runtime el flujo menu -> credito**: la conexion vive en
  `ui_root._conectar_menu_señales()` y exige el autoload `GameFlowManager`
  (`project.godot:89`, confirmado). Si lo que se verifico fue: montaje en boot real
  (`CreditsLayer (pila=11)`, `creditos=true`), `open()`/`close()` unitario y **0 `SCRIPT ERROR`**
  en arranque completo. Falta simular el click del menu.
- **No audite los 85 `[x]`**: encontre 3 APIs citadas en el plan que no existen con ese nombre
  (ver seccion 2) y las deje documentadas en vez de cambiar marcadores puestos por otro agente.
- **No toque `CHECKLIST-GLOBAL.md`**: bloqueado por otro agente (61/61 staged).

#### Intentos fallidos / decisiones
- **`get_vscroll_bar()` NO existe**: compila con `--check-only` (EXIT=0) pero revienta en runtime
  con `Nonexistent function`. El nombre real es **`get_v_scroll_bar()`**. Corregido en 3 sitios y
  anadida una asercion de regresion en el test. Leccion: **`--check-only` no valida nombres de
  metodos**, hay que EJECUTAR el codigo (seccion 12).
- Decidido rodillo continuo de todas las secciones (no una pantalla por seccion) con salto suave
  PageUp/PageDown: satisface D1 (scroll suave) + C37 (transicion suave) + J104 (salto por tecla).
- Decidido seguir el patron `pause_layer.gd`/`menus_layer.gd` (UI en runtime, sin `.tscn`, §9.47)
  en vez del diseno original `.tres`/`.tscn` del plan inicial.

#### Recomendaciones para el proximo agente
- Exponer `credits_manager.buscar(query)` en la pantalla: la API existe y esta probada, pero la UI
  no muestra campo de busqueda.
- Revisar `ui_root.gd:152` (`ui_mgr.push_layer(pause_layer)`): es no-op segun `ui_manager.gd`
  L457-459, asi que el path "Ajustes -> PauseLayer" puede no abrirse nunca.
- Si un dia hay audio: `MusicDirector` ya tiene el tema **`flow_creditos`** definido en
  `data/audio/music_context_matrix.json`; solo faltan las pistas.
- E57/E60/E62 del checklist citan APIs inexistentes: o se renombran en el checklist o se anaden
  alias en `credits_manager.gd`.
