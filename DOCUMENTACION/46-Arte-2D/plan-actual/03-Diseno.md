**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 46: Arte 2D

## 1. Arquitectura

El arte 2D es contenido: texturas, atlas y recursos, sin lógica de runtime. La arquitectura de carpetas:

```
Assets/_Project/Art/2D/
├── logo/            (logo_principal.svg, logo_icon.svg, variantes claro/oscuro)
├── ui/              (ui_art_*: marcos, paneles, botones, decoraciones → ui_atlas)
├── icons/           (ico_*: objetos, materiales, herramientas, peces, cultivos → icons_atlas)
├── portraits/       (pt_*: pt_<npc_id>_base.svg, pt_<npc_id>_alegre.svg... → portraits_atlas)
├── story/           (illus_*: mapas antiguos, textos ruinas, pantallas de carga → story_atlas)
├── symbols/         (sym_*: símbolos ancestrales)
├── badges/          (badge_*: insignias de logros y sellos)
└── cargo/           (archivos fuente SVG y documentos de trabajo, no se importn)

[Herramientas de editor — Assets/_Project/Editor/]
validate_2d.gd            → validador de piezas 2D (RF14)
pack_atlas.gd             → regeneración de atlas por script (M108)

[Documentación viva]
Docs/ART_STYLE_2D.md      → guía de estilo 2D (RF1)
```

El runtime (M53 UI) referencia **recursos empaquetados** (`ui_atlas.tres`, `icons_atlas.tres`...), nunca archivos sueltos ni rutas. La carga diferida por superficie la orquesta M63.

## 2. Diagramas de Flujo (texto)

### 2.1 Creación de un icono de objeto

```
diseñador consulta ART_STYLE_2D.md (RF1) y la receta de su familia (RF3)
  → toma plantilla: render 3D del objeto (M45) en ángulo 3/4
  → ilustra encima: trazo redondeado 3px (128px), sombra plana inferior,
    fondo de rareza según M38
  → exporta SVG a Assets/_Project/Art/2D/icons/ico_<item_id>.svg
  → valida en editor (validate_2d.gd):
      ├─ errores → corrige (tamaño, padding, halo, nombre) → revalida
      └─ OK
  → registra en catálogo (asset_catalog) con tipo=2d y ref_3d_id=<modelo>
  → revisión humana (estilo + comparación 3D) → estado "imported"
  → pack_atlas.gd regenera icons_atlas → disponible para UI
```

### 2.2 Creación de un retrato de NPC

```
seleccionar NPC del pueblo (M19)
  → render del modelo 3D (M45): ángulo 3/4 luz suave, encuadre medio pecho
  → repintado estilizado (ART_STYLE_2D.md): trazo, paleta, ojos grandes
  → generar expresiones base: base, alegre, triste, sorprendido, pensativo
    (+ 3 extra si romántico M20)
  → exportar pt_<npc_id>_<expr>.svg a portraits/
  → validar (tamaño 256, alfa limpio), registrar, review
  → pack_atlas.gd regenera portraits_atlas
  → diálogos (M21) consumen por señal/estado emocional
```

### 2.3 Empaquetado de atlas (pack_atlas.gd)

```
al detectar archivos nuevos/cambiados (M108 trigger):
  → agrupar por atlas de superficie (ui/icons/portraits/story)
  → empacar con padding ≥2px, sin rotaciones, ≤2048×2048
  → exportar PNG comprimido + .tres (AtlasTexture) + .json de coordenadas
  → verificar: ninguna pieza duplicada de id, ninguna > 1024
  → registrar resultados en log de editor (M103) y catálogo
```

## 3. Tablas de Métricas (técnico)

### 3.1 Resoluciones estándar

| Superficie | Resolución fuente | Mínimo display | Máximo atlas |
|---|---|---|---|
| Icono de objeto | 128×128 | 32 px (legible) | icons_atlas 2048 |
| Herramienta (icono) | 128×128 | 32 px | icons_atlas |
| Retrato | 256×256 | 96 px (diálogo) | portraits_atlas 2048 |
| Insignia grande | 100×100 | 48 px | badges_atlas 1024 |
| Ilustración de carga | 1024×1024 | 100% ventana | story (individual) |
| Mapa antiguo | 1024×1024 | 60% minimapa | story_atlas |
| Botón/panel UI | 32-256 (slice9) | según M53 | ui_atlas |

### 3.2 Paleta y estilo (resumen; detalle en ART_STYLE_2D.md)

- Paleta: derivada de los 13 biomas de M09 con dominante pastel; acentos por rareza (M38).
- Trazo: 2-3 px a 128 px (escala 1:40 del tamaño); redondeado, exterior.
- Sombra: plana, inferior, 10% de opacidad de color complementario.
- Prohibido: gradientes complejos, ruido, texturas foto, texto, alto contraste de neón.

### 3.3 Convención de variantes de nivel (herramientas M13)

| Nivel | Diferencia visual |
|---|---|
| 1 (básico) | mango madera clara, hoja gris suave |
| 2 (bueno) | mango madera oscura, hoja con brillo sutil |
| 3 (fino) | mango con tinte color, borde claro |
| 4 (ancestral) | aura pastel 6%, símbolo pequeño |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M45 (Arte 3D) | Plantillas 3D para iconos/retratos; catálogo compartido |
| M53 (UI/UX) | Piezas de UI listas para layout; texturas de botones/paneles |
| M87 (Localización) | Cero texto en arte; capa de texto superpuesta |
| M88 (Fuentes) | Texto con fuentes del sistema |
| M63 (Cargas) | Atlas cargados por superficie bajo demanda |
| M62 (Memoria) | Atlas únicos, sin duplicados en memoria |
| M108 (Assets) | Importación, compresión, convenciones de nombres |
| M72/M22/M37 | Insignias, sellos, coleccionables con marco común |
| M58 (Accesibilidad) | Variantes de alto contraste como recursos separados |