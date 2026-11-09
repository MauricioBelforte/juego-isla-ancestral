# Reporte de auditoría UID — `game/isla-ancestral/` (.tscn/.tres)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (glyph-cluster)  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/**/*.tscn`, `game/isla-ancestral/**/*.tres` (548 archivos). También se contrastaron metadatos UID auxiliares en el mismo árbol (`*.uid`, `*.import`) para validar referencias a assets/scripts importados.  
**Exclusiones:** `Obsoletos/` (contiene `.tscn` históricos fuera de `game/isla-ancestral/`), otros directorios del repo.

## Resumen ejecutivo

| Métrica | Valor |
|---|---:|
| Archivos `.tscn`/`.tres` analizados | 548 |
| Definiciones UID en cabecera (`[gd_scene ... uid="uid://"]` / `[gd_resource ... uid="uid://"]`) | 21 (21 UID únicos) |
| Referencias `ext_resource` con `uid="uid://..."` y `path="..."` | 303 (303 UID únicos) |
| UID duplicados entre definiciones de escena/recurso | 0 |
| Referencias UID sin cabecera `.tscn/.tres` correspondiente | 303 |
| Referencias UID sin cabecera pero con UID resuelto en `.uid`/`.import` y ruta `res://...` existente | 303 |
| Referencias UID sin resolución en cabecera ni en `.uid`/`.import` | 0 |
| Rutas `res://` referenciadas inexistentes en el árbol analizado | 0 |
| `uid=` mal formado / `uid_sin_prefijo_uid://` / `unique_id` mal formado | 0 |

## 1) ¿Hay UID duplicados entre escenas/recursos?

**No se detectaron duplicados** entre las definiciones de UID propias de archivos `.tscn/.tres` (cabeceras `[gd_scene]` / `[gd_resource]`).

- Definiciones únicas detectadas: **21**.
- Ocurrencias totales de definición en cabecera: **21**.
- Colisiones (mismo `uid://` definido en más de un archivo `.tscn/.tres`): **0**.

> Nota metodológica: se consideran “definiciones” las UID declaradas en la cabecera del propio `.tscn/.tres`. Los UID de texturas/scripts importados suelen vivir en `.import`/`.gd.uid`; no son duplicados de escena/recurso.

## 2) ¿Hay referencias a UID que no existen?

**Depende del criterio:**

### 2.a Criterio estricto (solo cabeceras `.tscn/.tres`)
Las **303** referencias `ext_resource` apuntan a UID que **no** tienen una definición en cabecera `[gd_scene]`/`[gd_resource]` dentro de los `.tscn/.tres` analizados.

### 2.b Criterio operativo Godot 4 (cabeceras + `.uid`/`.import` + ruta)
Tras contrastar con metadatos auxiliares del proyecto (`*.uid`, `*.import`, 2468 UID indexados):
- **303/303** referencias “sin cabecera” **sí** se resuelven a un UID presente en `.import` o `.uid`.
- **303/303** rutas `res://...` referenciadas **existen** en el árbol del proyecto (`game/isla-ancestral/...`).
- **0/303** quedan sin resolución.

**Conclusión del punto 2:** no se observaron referencias rotas en términos prácticos (ruta + UID conocido por import/sidecar). El patrón corresponde mayoritariamente a `.tres` de ítems que referencian texturas (`res://assets/2d/items_m159/*.png`) cuyo UID está en el `.import` correspondiente, más referencias puntuales a scripts/escenas con sidecar.

### Evidencia (muestra representativa, archivo:línea)

| Archivo | Línea | UID referenciado | Recurso `res://` | UID resuelto en | Ruta existe |
|---|---:|---|---|---|---:|
| `game/isla-ancestral/data/items/ancient_crystal.tres` | 4 | `uid://r3oie0pv35qn` | `res://assets/2d/items_m159/ico_ancient_crystal.png` | `.import` (`assets/2d/items_m159/ico_ancient_crystal.png.import`) | Sí |
| `game/isla-ancestral/data/items/stone.tres` | 4 | `uid://04obc05kum5s` | (textura/icono de ítem, patrón `assets/2d/items_m159/*`) | `.import`/sidecar indexado | Sí |
| `game/isla-ancestral/scenes/CameraRig.tscn` | 3 | `uid://w4vl1b10xb1p` | script asociado (`res://scripts/...` según escena) | `.uid`/`.import` indexado | Sí |
| `game/isla-ancestral/scenes/CameraRig.tscn` | 4 | `uid://dvke765611m8o` | script asociado (`res://scripts/...` según escena) | `.uid`/`.import` indexado | Sí |
| `game/isla-ancestral/scenes/preview_particles.tscn` | 3 | `uid://ba6ma7swo32h3` | recurso asociado según escena | `.uid`/`.import` indexado | Sí |

> El resto de las 303 referencias sigue el mismo patrón (especialmente `data/items/*.tres` → iconos en `assets/2d/items_m159/`). Se omite el volcado completo para mantener el reporte legible; puede regenerarse con el script de auditoría usado en esta ejecución.

## 3) ¿Hay escenas con `unique_id` mal formado?

**No.**

- Búsqueda de `unique_id=` en los 548 archivos: **0 hallazgos mal formados** según patrón esperado (`[A-Za-z0-9_\-:.]+` no vacío).
- Búsqueda de `uid=` con valor sin prefijo `uid://` o con formato sospechoso: **0 hallazgos**.
- Errores de lectura: **0**.

## 4) Sugerencias de verificación (2 acciones)

1. **Verificación en editor Godot (fuente de verdad):** abrir el proyecto `game/isla-ancestral/` en Godot 4.x y ejecutar una recarga/reimportación controlada (`Project > Reload Current Project` o reimportar `assets/2d/items_m159/`) para confirmar que no aparezcan errores de “Missing resource”, “Invalid UID” o “Broken dependencies” en Output/Debugger. Esto valida que los `.import`/`.uid` y el caché `.godot/` estén coherentes con los `.tres/.tscn`.
2. **Auditoría automatizada reproducible en CI/pre-commit:** ejecutar periódicamente un escaneo estático como el realizado aquí, pero con criterio Godot 4: para cada `ext_resource uid+path`, aceptar como válido si `(a)` existe cabecera UID en `.tscn/.tres` **o** `(b)` existe UID en `.uid/.import` **y** la ruta `res://` resuelve a archivo existente. Marcar como fallo solo los casos sin `(a)` ni `(b)`, UID duplicado en cabeceras de escena/recurso, o `uid=`/`unique_id` mal formado; generar reporte con `archivo:línea:UID:ruta`.

## Conclusión final

En `game/isla-ancestral/` no se detectaron **UID duplicados entre escenas/recursos**, **UID/unique_id mal formados** ni **referencias rotas** bajo el criterio operativo de Godot 4 (todas las `ext_resource` con UID sin cabecera `.tscn/.tres` se resuelven mediante `.import`/`.uid` y sus rutas `res://` existen). El volumen principal de hallazgos (303) corresponde a referencias a assets importados (iconos de ítems), que es un patrón normal en Godot 4; aun así, se recomienda la verificación en editor para descartar inconsistencias de caché/importación no visibles en texto plano.