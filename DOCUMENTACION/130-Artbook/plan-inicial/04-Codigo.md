**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23

# 04-Codigo.md — Módulo 130: Artbook

## 1. Naturaleza del Módulo

El artbook es un **producto editorial**: no contiene código de runtime del juego. Su "código" son los archivos de datos, manifiestos, plantillas y scripts auxiliares de apoyo que automatizan la curaduría y la verificación. Todo vive **fuera de `Assets/` del motor** (D8) para no disparar reimportaciones (regla de logs, sección 18 del AGENTS.md).

## 2. Archivos Involucrados

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `artbook/manifest/artbook_manifest.csv` | Datos | Manifiesto central: `id,autor,fecha,modulo_origen,estado,capitulo,pagina,comentario_dev` |
| `artbook/candidatos/**` | Assets | Piezas nominadas pendientes de curaduría |
| `artbook/seleccionadas/**` | Assets | Piezas aprobadas con ficha `.md` hermana |
| `artbook/textos/capitulos/*.md` | Texto | Contenido externalizable por capítulo (D10) |
| `artbook/textos/comentarios-dev/*.md` | Texto | Fichas de comentario de desarrollador (D4) |
| `artbook/textos/descartes/*.md` | Texto | Fichas de conceptos descartados (D5) |
| `artbook/textos/creditos-resumidos.md` | Texto | Versión resumida heredada de M131 |
| `artbook/maqueta/artbook_vN.*` | Editorial | Archivo de maquetación (Affinity Publisher / InDesign) |
| `artbook/maqueta/exports/digital/*.pdf` | Salida | PDF RGB para pantalla |
| `artbook/maqueta/exports/print/*.pdf` | Salida | PDF/X-1a CMYK + sangrado 3 mm |
| `artbook/legal/verificacion-licencias.md` | Legal | Cruce pieza ↔ licencia (M83/M85) |
| `tools/artbook/validar_manifest.py` | Script | Valida CSV: ids únicos, campos completos, capítulos válidos |
| `tools/artbook/exportar_capturas.gd` | Script Godot Editor | Exporta capturas estandarizadas desde escenas del juego (opcional) |

## 3. Plantilla del Manifiesto (CSV)

```csv
id,autor,fecha,modulo_origen,estado,capitulo,pagina,comentario_dev
aurora_faro_concepto_03,Lía G.,2026-09-02,M45-Arte-3D,seleccionada,04,87,faro.md
isla_flotante_temprana,Bruno M.,2026-08-20,M27-Islas,descartado,12,,descarte_isla_flotante.md
```

Reglas de validación (`validar_manifest.py`):
1. `id` único y en minúsculas con guiones bajos (M149).
2. Campos obligatorios: id, autor, fecha, modulo_origen, estado.
3. `estado ∈ {nominada, seleccionada, descartada}`.
4. `capitulo ∈ {01..12}` según la tabla de capítulos de 03-Diseno.
5. Si `estado = seleccionada`, debe existir ficha `.md` en `seleccionadas/`.
6. Si `estado = descartada`, debe existir ficha en `textos/descartes/`.

## 4. Script Auxiliar de Capturas (opcional, Godot Editor)

Para capturas comparativas "deteriorado → restaurado" y vistas de biomas:

```gdscript
# tools/artbook/exportar_capturas.gd — @tool, solo Editor
@tool
extends SceneTree
## Exporta capturas estandarizadas 2400x3000 px (300 DPI a 203x254 mm)
## Uso: godot --headless --script exportar_capturas.gd -- escena=aurora cam=(x,y,z) out=faro_final.png

const RESOLUCION := Vector2i(2400, 3000)

func _init() -> void:
    var args := OS.get_cmdline_user_args()
    # ... parsea escena/cam/out, instancia la escena, posiciona cámara,
    # espera 2 frames, captura viewport, guarda PNG sRGB.
    quit(0)
```

Restricciones: nunca se ejecuta en runtime del juego; no agrega dependencias al build; vive en `tools/` fuera de `Assets/`.

## 5. Logs Relacionados

- Eventos de curaduría se registran como entradas normales en `Logs/` del proyecto cuando hay decisiones relevantes (ej: cierre editorial).
- El script `validar_manifest.py` imprime resultados a consola; si se desea persistencia, escribe en `Logs/rotated/` siguiendo el formato `NN-artbook-AAAA-MM-DD.log` (sección 18 AGENTS.md).
- No se crean archivos de log dentro de `Assets/`.

## 6. Convenciones

- Nomenclatura de archivos de imagen: `{capitulo}_{tema}_{variante}.{ext}` (M149), minúsculas, sin espacios ni tildes.
- Versionado Git LFS para imágenes >1 MB (M06); el CSV y los `.md` van en texto plano normal.
- La maqueta se versiona por snapshot mensual (`artbook_vN`) con changelog en `maqueta/CHANGELOG.md`.
- Los PDFs finales se etiquetan en Git como tags `artbook-digital-vN` / `artbook-print-vN`.

## 7. Notas del Agente

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23
**Estado:** Completado (documentación de diseño)

### Lo que hice
- Definí la arquitectura de archivos completa del módulo (manifiesto, carpetas, salidas).
- Especificé el formato CSV del manifiesto y sus reglas de validación.
- Documenté el script auxiliar opcional de capturas estandarizadas.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar `validar_manifest.py` y `exportar_capturas.gd`: quedan como especificación; su implementación pertenece a la fase de producción del artbook (post-RC).

### Recomendaciones para el próximo agente
- Al iniciar producción real, crear primero `validar_manifest.py` con tests simples antes de nominar piezas masivamente.
- Coordinar con M129 el SKU y con M128 las tipografías definitivas antes de maquetar.