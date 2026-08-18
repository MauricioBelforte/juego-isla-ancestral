**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 46: Arte 2D

## 1. Análisis del Dominio

El arte 2D de Aurora se descompone en ocho subsistemas interconectados:

### 1.1 Relación con el arte 3D (herencia de estilo)
- **Dominio:** el 2D no es un mundo aparte: es la *proyección* del 3D sobre superficies planas. Un icono de herramienta debe leerse como "esa herramienta 3D" y un retrato como "ese NPC 3D".
- **Mecánica de coherencia:** se proyecta el modelo 3D a un ángulo canónico (3/4 para objetos, frente para retratos) y se ilustra encima (línea de base). El retrato se basa en el modelo del NPC, no en un diseño paralelo.
- **Clave:** cada pieza 2D declara su `ref_3d_id` (id del asset 3D de referencia) en el catálogo (RF13 de M45 / RF15 de M46).

### 1.2 Banco de iconos
- **Dominio:** cientos de ítems en M14/M15/M16/M33/M34/M35. Se clasifican por familia:
  - Objetos (materiales, recursos, comida), herramientas (9×4 niveles M13), peces/cultivos, ítems de misión.
  - Cada familia tiene su "receta visual": sombra, brillo sutil, fondo de color de rareza (M38).
- **Escala de visualización mínima:** 32 px en UI; el icono de origen se diseña a 128 px y se prueba a 32 px.
- **Rareza por color:** borde/glow sutil por nivel de rareza (definido en M38), siempre dentro de una paleta pastel (sin rojos agresivos de alerta en objetos comunes).

### 1.3 Retratos (portraits)
- **Dominio:** los diálogos (M21) usan retratos con expresiones: base, alegre, triste, sorprendido, pensativo (5 por NPC mínimo; 8 para NPCs con romanticismo M20).
- **Coherencia 3D→2D:** ángulo de 3/4 o frente, iluminación suave, proporciones reducidas a la mitad del pecho. El retrato se genera con el modelo 3D como plantilla (render + repintado), nunca de memoria.
- **Variante MR (multi-resolution):** 256×256 fuente; Godot escala hacia abajo (con pruebas a 96 px en diálogos compactos).

### 1.4 Símbolos, insignias y emblemas
- **Dominio:** los símbolos ancestrales (M24/M25/M26) son *lenguaje gráfico* del juego: geometría suave, sin texto, reutilizables en superficies (ruinas, sellos, logros).
- **Insignias y emblemas:** logros (M72) y sellos de historia (M22) comparten marco y composición (círculo + figura + borde de rareza); las insignias grandes (100 px display) y pequeñas (48 px) comparten el mismo diseño.
- **Coleccionables (M37):** iconos con fondo de museo (base neutra) para que la colección se vea coherente en vitrina.

### 1.5 Atlas y empaquetado
- **Dominio:** cada superficie tiene su atlas: `ui_atlas` (botones, marcos, panes), `icons_atlas` (objetos/herramientas), `portraits_atlas` (retratos), `story_atlas` (ilustraciones).
- **Empaquetado:** se usa texture packer (o script propio M108) con `padding` ≥ 2 px, sin rotaciones, agrupando por categoría; se regenera por script al agregar piezas.
- **Tamaños:** atlas ≤ 2048×2048 (1K por defecto en UI móvil si aplica); piezas sueltas > 1024 prohibidas en atlas (van como textura individual).
- **Transparencia:** alfa limpio sin halos (premultiplied con blend según Material de Godot); prohibido el aliasing en bordes redondeados.

### 1.6 Ilustraciones narrativas
- **Dominio:** mapas antiguos (pergamino), textos de ruinas (glifos pintados — pero sin texto legible), pantallas de carga, presentaciones de capítulo (M22). Son piezas "de ambiente": gran tamaño (512 o 1024), baja saturación en zonas donde habrá texto UI, y un área de respiro (safe zone) central para no tapar contenido.

### 1.7 Formatos y herramientas
- **Dominio:** fuente editable = SVG (Inkscape gratuita, o AI), runtime = PNG (con pérdida con alfa no; WebP con alfa si M108 lo aprueba).
- **Herramientas:** Inkscape (gratuita), Krita (pintura), Blender solo como soporte 3D→2D (render de plantilla). Se evalúa IA generativa como base + repintado humano (M86).
- **Regla:** el texto y los números NUNCA se pintan en el arte (M87/M88 los superponen).

### 1.8 Validación y catálogo
- **Dominio:** `validate_2d.gd` verifica al importar: dimensión exacta (128/256/512...), resolución múltiplo de 4 (compresión), alfa sin halos (inspección de borde), duplicados de id, convenciones de nombres.
- **Catálogo** (`asset_catalog` compartido con M45): las piezas 2D entran como entradas con tipo `2d` y su `ref_3d_id` cuando aplica.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Iconos pintados "a mano libre" sin referencia 3D | **Descartado** | Incoherencia con el mundo 3D; retrabajo al juntar UI y modelo |
| Retratos generados solo por IA directa | **Descartado** | Inconstancia entre NPCs y legal M86/M85 |
| Un solo atlas gigante para todo | **Descartado** | Carga diferida imposible (M63) y memoria desperdiciada (M62) |
| Iconos con texto embebido (nombres pintados) | **Descartado** | Rompe M87 (localización) y M88 |
| Texturas PNG gigantes sin compresión | **Descartado** | Rompe presupuesto M61/M62 |
| Atlas por superficie + SVG fuente | **Adoptado** | Carga diferida, mantenibilidad y localización |

## 3. Decisiones del Módulo

1. **Estilo 2D heredado del 3D** (M45): paleta pastel, trazo redondeado, sombra plana.
2. **Iconos 128×128** de trabajo (legibles a 32 px); retratos 256×256; ilustraciones 512-1024.
3. **Atlas por superficie** (ui/icons/portraits/story) ≤ 2K, regenerables por script.
4. **Sin texto en arte**: todo texto es capa de M87/M88.
5. **Retratos con plantilla 3D** (render del modelo + repintado).
6. **Validador automático** (`validate_2d.gd`) como puerta de entrada previa a M108.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Iconos incoherentes entre sí | Alta | Alto | Guía de estilo única + recetas por familia + review |
| Retratos que no parecen al NPC 3D | Media | Alto | Plantilla 3D obligatoria + comparación lado a lado en review |
| Atlas que crecen sin control | Media | Medio | Atlas por superficie, límite 2K, regeneración por script |
| Texto en arte que impide localizar | Media | Alto | Regla dura RF16 + validador (detección de regiones con texto no permitido) |
| Sobrecarga de memoria por texturas 2D | Media | Medio | Compresión M108, atlas, carga diferida M63 |