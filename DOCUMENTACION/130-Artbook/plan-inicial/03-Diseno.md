**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23

# 03-Diseno.md — Módulo 130: Artbook

## 1. Arquitectura Editorial: los 12 Capítulos

La estructura temática (D2) agrupa los 15 puntos del plan maestro en 12 capítulos. Extensión objetivo total: **200-240 páginas**.

| # | Capítulo | Puntos del plan maestro que cubre | Págs. | Piezas mínimas |
|---|----------|-----------------------------------|-------|----------------|
| 1 | Prólogo — La Isla que Despierta | (apertura) | 4-6 | Portada, mapa de Aurora, carta del director |
| 2 | Arte Conceptual Fundacional | Arte conceptual | 16-20 | Paletas pastel, pruebas de estilo voxel, moodboards |
| 3 | Evolución del Mundo | Evolución del mundo | 14-18 | Línea de tiempo prototipo → RC con capturas comparativas |
| 4 | Aurora: Diseño de la Isla | Diseño de Aurora | 20-24 | Puerto, faro, plaza, pueblo; estados deteriorado → restaurado |
| 5 | Personajes y Vecinos | Diseño de personajes | 24-28 | Jugador (6 opciones), Finneas, Lía, Bruno, Nilo, Vera + vecinos |
| 6 | Fauna de Aurora | Diseño de animales | 12-16 | Fauna por bioma con variantes estacionales (M36/M65) |
| 7 | Ruinas y Templos | Diseño de ruinas | 20-24 | Kit modular M25, Templo de Brisa M26, iconografía ancestral |
| 8 | Herramientas y Vehículos | Diseño de herramientas + vehículos | 16-20 | 9 herramientas × 4 niveles, Gancho/Lanza/Varas, barco/dirigible/submarino/Gran Vapor |
| 9 | Biomas e Islas | Diseño de biomas | 18-22 | 13 regiones M09 + islas satélite M27 |
| 10 | Interfaz y Símbolos | Diseño de UI | 12-16 | Evolución de pantallas, iconos, fuentes M88, símbolos de Sellos |
| 11 | Storyboards y Escenas | Storyboards | 14-18 | Faro encendido, Gran Vapor, Corazón del Mundo, Elysia, Jardín Final |
| 12 | El Taller: Proceso, Descartes y Equipo | Conceptos descartados + comentarios devs + proceso + créditos | 30-36 | Fichas de descarte, citas firmadas, pipeline M108, créditos M131 |

> Los capítulos finales (11-12) llevan **banda de advertencia de spoilers** (D7).

## 2. Estructura de Carpetas (fuera de Assets/, D8)

```
artbook/
├── manifest/
│   └── artbook_manifest.csv        ← Manifiesto central de piezas (D1)
├── candidatos/
│   ├── 01-concepto/
│   ├── 02-evolucion/
│   ├── 03-aurora/
│   ├── 04-personajes/
│   ├── 05-fauna/
│   ├── 06-ruinas-templos/
│   ├── 07-herramientas-vehiculos/
│   ├── 08-biomas-islas/
│   ├── 09-ui-simbolos/
│   ├── 10-storyboards/
│   └── 11-descartes/
├── seleccionadas/                   ← Aprobadas para el libro (con ficha)
├── textos/
│   ├── capitulos/*.md              ← Textos externalizables (D10)
│   ├── comentarios-dev/*.md        ← Fichas D4
│   └── creditos-resumidos.md       ← Heredado de M131
├── maqueta/
│   ├── artbook_vN.apkg/.indd       ← Archivo de maquetación
│   └── exports/
│       ├── digital/                ← PDF RGB pantalla
│       └── print/                  ← PDF/X CMYK + sangrado 3 mm
└── legal/
    └── verificacion-licencias.md   ← Cruce con M83/M85
```

## 3. Formato de la Ficha de Pieza (D3)

Toda pieza en `seleccionadas/` lleva un archivo `.md` hermano:

```markdown
# PIEZA: aurora_faro_concepto_03
- **Autor:** [nombre]
- **Fecha:** AAAA-MM-DD
- **Módulo origen:** M45-Arte-3D
- **Estado:** concepto | producción | final | descartado
- **Capítulo:** 04 — Aurora
- **Página asignada:** p. 87
- **Comentario dev (opcional):** ver comentarios-dev/faro.md
```

## 4. Formato de Comentario de Desarrollador (D4)

```markdown
# COMENTARIO DEV — pieza: aurora_faro_concepto_03
**Autor:** [nombre] — [rol]
> "Probamos tres siluetas de faro antes de entender que tenía que
> verse apagado pero prometedor: es el primer misterio visible del juego."
```

Reglas: ≤40 palabras · tono cálido y honesto · puede incluir un error aprendido · siempre anclado a una pieza concreta.

## 5. Formato de Ficha de Concepto Descartado (D5)

```markdown
# DESCARTE: isla_flotante_temprana
- **Qué era:** islas flotantes accesibles desde el prólogo.
- **Por qué se descartó:** rompía el gating del Gran Vapor y saturaba el streaming (M61).
- **Qué enseñó:** separar "deseo de exploración" de "recompensa por progreso".
- **¿Sobrevivió en otra forma?** Sí → Isla Flotante como contenido FASE 2 del postgame (M75).
```

## 6. Especificaciones Técnicas (D6)

| Parámetro | Digital (pantalla) | Print (POD) |
|-----------|--------------------|-------------|
| Tamaño página | 240 × 300 px/in equivalente (16:10 horizontal) | 240 × 300 mm (horizontal) |
| Resolución imágenes | ≥150 DPI efectivos | 300 DPI efectivos |
| Perfil de color | sRGB | CMYK (perfil POD de M129) |
| Sangrado | — | 3 mm |
| Tipografías | Nunito (cuerpo), Fredoka One (títulos) — M128/M88 | Ídem, convertidas a curvas |
| Peso PDF objetivo | ≤150 MB | ≤500 MB |
| Marca de agua | No (prensa citable) | — |

## 7. Pipeline de Curaduría (flujo continuo)

1. **Nominación:** cualquier miembro registra una pieza en `artbook_manifest.csv` (id, autor, fecha, módulo, estado, capítulo propuesto).
2. **Revisión mensual de curaduría:** sesión corta (≤1 h) que aprueba/mueve piezas de `candidatos/` a `seleccionadas/`.
3. **Fichado:** al aprobarse, se crea la ficha de pieza (sección 3) y, si corresponde, comentario dev o ficha de descarte.
4. **Snapshot semanal:** respaldo de `candidatos/` (M107) para evitar pérdidas.
5. **Cierre editorial (post-RC, M142):** congelar manifiesto, verificar licencias (legal/), maquetar, exportar ambas salidas.

## 8. Integraciones

| Sistema | Integración |
|---------|-------------|
| M129 Merchandising | SKU del artbook, precio USD 30-50, specs POD compartidas, tirada limitada numerada |
| M128 Identidad de Marca | Cubierta con logo oficial, paleta y tipografías del manual |
| M131 Créditos | Capítulo 12 reproduce versión resumida + referencia |
| M99 Marketing | Extractos aprobados sin spoilers para prensa/comunidad |
| M120 DLC | Opción volumen 2 si hay expansión con arte nuevo suficiente |
| M59/M107 | Backups 3-2-1 de la carpeta artbook/ |

## 9. Criterios de Calidad Editorial

- Cada capítulo abre con una página de título + texto introductorio ≤80 palabras.
- Ninguna imagen a menos de 150 DPI efectivos en su tamaño final impreso.
- Máximo 2 piezas por página salvo planchas tipo "galería" (máximo 6 miniaturas).
- Todo texto alternativo/descripción lista para localización (sin texto incrustado en imágenes).
- Consistencia de nomenclatura de archivos: `{capitulo}_{tema}_{variante}.{ext}` en minúsculas y guiones bajos (M149).