**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# ASSET-PIPELINE.md — Guía del Pipeline de Assets (Módulo 108)

> **Puerta única:** todo asset que entra al juego pasa por esta guía. No se admite importar assets sueltos fuera del flujo.

## 1. Flujo de entrada

```
staging/ (nuevos desde Blender/M45)
  → 1. Validación automática (asset_validator.gd: nombre, formato, tamaño, ficha, licencia)
  → 2. Importación (presets de importación de Godot, deterministas)
  → 3. Review manual (plantilla de la sección 5)
  → 4. Aprobación (ficha con estado APROBADO + registro)
  → disponible para el juego
```

- **staging:** `assets/staging/` — carpeta de llegada de assets nuevos (se limpia al aprobar).
- **Producción:** `assets/3d/{media,baja,alta}/` (variantes por perfil M166), `assets/2d/`, `assets/audio/`, `assets/fonts/`, `assets/ui/` — las carpetas de consumo del motor.
- **Fichas:** `assets/fichas/{id}.md` — una por asset (ver sección 4).
- **Reportes:** el validador escribe `tools/reportes/asset_validation.txt`.

## 2. Formatos (RF2/RF3)

| Tipo | Permitido | Prohibido | Ruta de conversión |
|---|---|---|---|
| Modelos | **glTF 2.0** `.glb` (runtime), `.gltf`+`.bin` (edición) | FBX, OBJ (menos geometría simple), cualquier propietario | FBX → Blender → export glTF |
| Texturas | PNG (lossless), WebP (lossy) | TGA, BMP, GIF | Convertir en GIMP/ImageMagick → PNG/WebP |
| Audio | OGG Vorbis (.ogg), WAV solo loops cortos | MP3, MP4, AVI | Convertir → OGG |
| Fuentes | TTF/OTF | BDF, PostScript .pfb | Convertir → TTF/OTF |

## 3. Convención de nombres (RF4) — adaptada a la convención real del proyecto

La regla del proyecto (AGENTS.md §3, módulos con prefijo ID) manda sobre el formato original
del RF4. **Convención adoptada (verificada en M166/M18):**

```
{NN}-{Modulo}_{snake_case}.{ext}    ej: 18-Casas_pared_madera.glb · 50-Vegetacion_palmera.glb
```

| Regla | Valor |
|---|---|
| Prefijo | `NN-` = ID del módulo productor (M18, M45, M50, ...) |
| Segmento módulo | PascalCase (sin espacios ni guiones internos) |
| Segmento nombre | snake_case (minúsculas, `_` separador; palabras en uno sin `_` internos) |
| Caracteres especiales | Prohibidos: `áéíóúñ` → `a e i o u n` (ASCII), sin espacios, sin `() [] {}` |
| Longitud | Máximo 64 caracteres (nombre sin extensión) |
| Sufijo de variante | `_media` / `_baja` / `_alta` al final del nombre (M166) |
| Extensión | minúscula |

**No se renombran los 153 GLB ya producidos:** la tanda existente cumple el patrón
(`{NN}-{Modulo}_{snake_case}`) y es la evidencia de la convención; renombrar rompería
los contratos de M166/M18 mencionados en su documentación. Si un asset nuevo no cumple,
se rechaza en validación y se renombra en origen (Blender, M45).

## 4. Ficha de asset (RF8) — plantilla

```markdown
# {id} — {Nombre}

| Campo | Valor |
|---|---|
| id | {NN}-{Modulo}_{snake_case} |
| tipo | {modelo_3d / textura / audio / fuente / ui / voxel} |
| variante | {media / baja / alta / —} |
| origen | {propio (M45/M166) / licenciado (M78)} |
| licencia | {MIT / CC0 / ...} |
| atribución | {— / autor} |
| fecha_entrada | YYYY-MM-DD |
| estado | {PENDIENTE-VALIDACION / APROBADO / RETIRADO} |
| responsable | {agente} |
| peso_mb | {tamaño en disco} |
| resumen | {nota de 1 línea: uso en el juego} |
```

Estado del pipeline: `PENDIENTE-VALIDACION` → `PENDIENTE-REVIEW` → `APROBADO` → `RETIRADO` (el retiro excluye del build sin borrar historial, RF12).

## 5. Review manual (RF9) — checklist por asset

- [ ] Polígonos dentro del presupuesto de la variante (M166: ALTA ≤6000, MEDIA ≤1500, BAJA ≤700)
- [ ] Un solo material por mesh si es posible (merge material / draw calls M166)
- [ ] Escala coherente con el mundo voxel (1 unidad = 1 bloque)
- [ ] Silueta legible a 3 distancias (cerca, media, far) — ideal revisar en la escena de preview
- [ ] Sin artefactos: caras invertidas, vértices sueltos, normales raras, geometría en (0,0,0)
- [ ] Mipmaps activos (texturas) y compresión VRAM
- [ ] Atribución/licencia presente en la ficha
- [ ] Rendimiento estimado: draw calls + peso dentro del presupuesto (M61/M62)

## 6. Optimización en importación (RF6)

- **Mipmaps:** activos en todas las texturas (import settings).
- **Compresión VRAM:** BPTC (PC) / ETC2-ASTC si hubiera mobile; nunca "Lossless/Uncompressed" en archivos finales.
- **LOD:** Godot 4.x; sin importer LOD automático para glb → se controla vía variantes M166 (`_media/_baja/_alta`) que se seleccionan en el preset gráfico (M90/M115).
- **Potencias de 2:** texturas deben ser 256/512/1024; límite 2048 por tipo (512 iconos UI, 1024 texturas de superficie, 2048 atlas).
- **Batching/atlas:** preferir atlas para props pequeños (M47) antes que texturas individuales.

## 7. IA generativa (RF10)

Todo asset que venga de IA generativa (M86) se etiqueta `origen: ia_gen` en la ficha y NO se aprueba sin licencia verificable ni revisión legal (M78). El validador del pipeline (campos de la ficha) lo marca como ERROR si `origen: ia_gen` y no tiene licencia.

## 8. Auditoría (RF11)

`tools/asset_validator.gd` (headless, `godot --headless -s res://tools/asset_validator.gd -- <opciones>`):

| Regla check | Qué valida |
|---|---|
| NOMBRE | patrón `{NN}-{Modulo}_{snake_case}[_media|_baja|_alta].glb`; snake no ASCII; ≤64 chars; sin espacios |
| FORMATO | extensión permitida por tipo (glb/gltf/png/webp/ogg/ttf/otf) |
| TAMAÑO | aviso si > 8 MB (asset pesado) |
| FICHA | existe `assets/fichas/{id}.md` y el estado es `APROBADO` o `PENDIENTE-REVIEW` salvo que se pase `--sin-ficha` |
| LICENCIA | la ficha declara licencia (`—` no válida salvo propios `MIT` del estudio, ver RF10) |
| VARIANTE | los archivos terminan en `_media/_baja/_alta` (o se está en staging) |

Salida: `tools/reportes/asset_validation.txt` + `quit(1)` si hay errores (apto CI M118).

## 9. Rutas de actualización y retiro (RF12)

- **Actualizar:** nueva versión en `assets/staging/` con `vN` en la ficha (changelog de 1 línea); el archivo nuevo reemplaza al viejo; se conserva el `.import` versionado.
- **Retirar:** estado `RETIRADO` en la ficha + el archivo se mueve a `assets/retirados/` (no se borra); el validador no emite error por `retirados/` (se excluye del recorrido).

## 10. Referencias

- Optimización obligatoria: AGENTS.md §21.4.8 · M52/M61/M62 (presupuestos)
- Variantes por perfil: M166 (presupuestos de triángulos/draw calls por variante)
- Legal: M78 (licencias), M83 (licencias de software), M86 (IA generativa)
- Determinismo de importación: versionar `.import` (Godot ≥ 4.4.1, el proyecto usa 4.7.2)
