**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 131: Créditos

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `res://credits/director.gd` | CreditsDirector: autoload, gestión de datos, lógica de idioma | Pendiente de implementación |
| `res://credits/catalog.tres` | Catálogo de créditos: equipos, contribuyentes, assets, licencias | Pendiente de implementación |
| `res://credits/scene.tscn` | CreditsScene: nodo raíz con UI completa | Pendiente de implementación |
| `res://credits/ui/credits-canvas.tscn` | CreditsCanvas: CanvasLayer con interfaz completa | Pendiente de implementación |
| `res://credits/data.tres` | Datos de créditos: lista estructurada por categorías | Pendiente de implementación |

## 2. API pública prevista

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

## 3. Pendientes de implementación

- Base de datos completa de contribuyentes y sus roles
- Sistema de traducción automática o manual para 2 idiomas
- Interfaz de búsqueda en tiempo real con filtrado
- Configuración de tamaño de texto y velocidad de animación
- Integración con M91 (Configuración de Audio) para control de velocidad
- Integración con M90 (Configuración Gráfica) para fuentes y contraste

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
