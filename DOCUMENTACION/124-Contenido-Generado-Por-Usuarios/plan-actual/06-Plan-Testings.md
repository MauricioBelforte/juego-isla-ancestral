**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Log:** 905

# 06-Plan-Testings.md — Módulo 124: Contenido Generado por Usuarios (iter. 2)

## 1. Alcance de esta iteración

Se testea **la parte verificable headless** del módulo: límites de almacenamiento
(RF13), sanitización del UGC (4K→2K, sin coords del save, compresión) y telemetría
sin PII (RF7 / M104), más la **regresión** de la iter. 1.

Fuera de alcance (declarado `[?]`, con dueño externo): backend de servicio, CDN/bucket,
moderación con IA, cola humana, apelaciones, UI de galería/perfil, ToS/copyright,
región de datos, derecho al olvido operativo, cableado con M56/M18/M100.

## 2. Archivos y comandos

```
game/isla-ancestral/scripts/ugc/test_ugc_m124.gd        (iter. 1, 16 checks)
game/isla-ancestral/scripts/ugc/test_ugc_m124_iter2.gd  (iter. 2, 85 checks)
```
```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/ugc/test_ugc_m124_iter2.gd
```
**Criterio de verde:** `EXIT 0` **y** `SCRIPT ERROR: 0` en el stdout completo
(verde sin `SCRIPT ERROR: 0` no es verde).

## 3. Bloques del suite iter. 2 (85 checks)

| Bloque | Foco | Checks |
|--------|------|--------|
| **A** | Catálogo y límites data-driven (valores reales del JSON + defaults sin `limites`) | 12 |
| **B** | `UgcLimits` por ítem: pesos exactos y peso+1, formatos, tipo desconocido, 0 bytes, mensaje | 12 |
| **C** | `UgcLimits` por cuota: ítems activos, fotos/día, blueprints/día, bytes/día, `consumir()` | 12 |
| **D** | `UgcSanitizer`: 4K→2K, aspecto, `Image` real, no mutación, sobre sin coords, variantes, ZSTD | 21 |
| **E** | `UgcTelemetry`: hash, eventos, PII rechazada (plana y anidada), resumen, JSON, M104 | 18 |
| **F** | Regresión iter. 1: catálogo, `UgcValidator`, autoload `UgcManager` | 4 |
| — | **Marcadores** `_fin()` de los 6 bloques | 6 |
| | **Total** | **85** |

## 4. Casos de prueba (CP)

### Bloque A — catálogo y límites
| CP | Caso | Esperado |
|----|------|----------|
| A-01 | `ugc_catalog.json` carga | dict con las claves esperadas |
| A-02 | `items_activos_max()` | 200 |
| A-03 | `fotos_por_dia_max()` | 50 |
| A-04 | `blueprints_por_dia_max()` | 20 |
| A-05 | `bytes_por_dia_max()` | 10 485 760 |
| A-06/07/08 | `peso_max(foto/blueprint/construccion)` | 3 MB / 256 KB / 512 KB |
| A-09 | `lado_max_foto_px()` | 2048 |
| A-10 | `formatos_foto()` | `["jpg","webp"]` |
| A-11 | `sla_reporte_horas(nsfw/spam)` | 24 / 72 |
| A-12 | `UgcLimits.new({})` (sin bloque `limites`) | defaults 200/50/3 MB |

### Bloque B — límites por ítem
| CP | Caso | Esperado |
|----|------|----------|
| B-01 | foto de 3 MB exactos | `ok` (tope inclusivo) |
| B-02 | foto de 3 MB + 1 byte | `peso_excedido` |
| B-03/04 | blueprint 256 KB / +1 | `ok` / `peso_excedido` |
| B-05/06 | construcción 512 KB / +1 | `ok` / `peso_excedido` |
| B-07 | foto con formato `png` | `formato_no_soportado` |
| B-08 | foto con formato `".JPG"` | `ok` (normaliza punto y mayúsculas) |
| B-09 | tipo `musica` (contenido sin archivo) | `tipo_desconocido` |
| B-10 | 0 bytes | `bytes_invalidos` |
| B-11 | mensaje cuando el redondeo humano empata | contiene `3145729 B` |
| B-12 | motivo == constante `MOTIVO_PESO_EXCEDIDO` y mensaje no vacío | ok |

### Bloque C — límites por cuota
| CP | Caso | Esperado |
|----|------|----------|
| C-01 | `uso_vacio()` | 4 claves |
| C-02 | uso vacío + foto | `ok` |
| C-03 | 199 ítems activos | `ok` (tope 200 inclusivo) |
| C-04/05 | 200 ítems activos | `cuota_items` + mensaje con "200" |
| C-06/07 | 49 / 50 fotos hoy | `ok` / `cuota_diaria` |
| C-08/09 | 19 / 20 blueprints hoy | `ok` / `cuota_diaria` |
| C-10 | bytes/día justo al tope | `ok` |
| C-11 | bytes/día al tope + 1 KB | `cuota_bytes` |
| C-12 | `consumir()` ok descuenta / falla no muta | contadores coherentes |

### Bloque D — sanitizador
| CP | Caso | Esperado |
|----|------|----------|
| D-01 | 4096×2160 con lado máx 2048 | necesita redimensión |
| D-02 | escala 4096×2160 | 2048×1080 (mantiene aspecto) |
| D-03 | retrato 2160×4096 | 1080×2048 |
| D-04 | 1024×768 | no necesita redimensión |
| D-05 | factor de escala | 0.5 |
| D-06 | `Image` real 4096×2160 → `preparar_foto` | 2048×1080 |
| D-07 | `redimensionada` | true |
| D-08 | la imagen original | **no** se muta (4096×2160) |
| D-09 | imagen chica | no se redimensiona, conserva tamaño |
| D-10 | `formato_de_ruta("foto.JPG")` | `"jpg"` |
| D-11 | sobre con `coords`, `save_id`, `slot`, `steam_id` | las 4 eliminadas, ordenadas |
| D-12 | `limpio` | false |
| D-13 | clave legítima (`nombre`) | sobrevive |
| D-14 | `piezas[].posicion` | **intacta** (es contenido) |
| D-15 | blueprint original | no se muta |
| D-16 | variante `meta.world_coords_2` | detectada por subcadena |
| D-17 | sobre ya limpio | `limpio == true`, 0 eliminadas |
| D-18 | roundtrip ZSTD por `FileAccess.open_compressed` | JSON idéntico (incluye `ñandú`) |
| D-19 | peso del archivo ZSTD vs JSON crudo (4 KB repetitivos) | ZSTD < crudo |
| D-20 | `bytes_de_json` | == tamaño del buffer UTF-8 |
| D-21 | temporal de test | borrado |

### Bloque E — telemetría
| CP | Caso | Esperado |
|----|------|----------|
| E-01 | `hash_alias` repetido | estable, 8 hex |
| E-02 | dos alias distintos | hashes distintos |
| E-03 | el hash | no contiene el alias |
| E-04/05 | publicar/ver/descargar | registrados, contadores = 1 |
| E-06 | evento inválido | `false` |
| E-07 | `extra` con `email` | `false` |
| E-08 | `extra` con `meta.steam_id` | `false` |
| E-09 | los rechazos | no suman contadores |
| E-10 | `autor` del evento | == hash, sin el alias |
| E-11 | `t` del evento tras `avanzar(2.5)` | 2.5 |
| E-12 | `resumen()` | 1 ítem único, 2 autores únicos |
| E-13 | export/import JSON | roundtrip, 3 eventos |
| E-14 | `cargar_json` con versión 99 | `false` |
| E-15 | `cargar_json` con texto inválido | `false` |
| E-16 | `exportar_a_m104()` | shape con `categoria`/`autor_hash` |
| E-17 | export M104 | no filtra el alias |
| E-18 | `claves_pii` / `tiene_pii` | detecta sin mutar |

### Bloque F — regresión iter. 1
| CP | Caso | Esperado |
|----|------|----------|
| F-01 | catálogo | 3 piezas / 5 tipos / 4 estados |
| F-02 | `UgcValidator.validar(catálogo real)` | 0 errores |
| F-03 | autoload `UgcManager` | presente |
| F-04 | `UgcManager.por_estado("publicado")` | 2 |

## 5. Casos NO cubiertos (y por qué)
- **Backend de servicio / CDN / bucket**: no existe (post-V2). Nada que testear.
- **Moderación automática (IA) y cola humana**: no hay servicio ni modelo.
- **UI de galería / tarjeta / perfil**: M89 no tiene estas vistas.
- **Cableado con M56 (cámara), M18 (blueprints), M100 (comunidad)**: no implementado.
- **Región de datos (M80), derecho al olvido operativo, ToS, DMCA**: proceso/legal.
- **Rate limit / auth del servicio (M106)**: no hay servicio.
- **`Image` con JPEG/WebP reales**: no hay codificador de imagen en GDScript puro;
  el módulo valida el **formato declarado**, no re-codifica.

## 6. Anti-falso-verde
1. **Marcadores `_fin("X")`** al final de cada bloque: si un error de script aborta la
   función en silencio, el bloque queda sin marcar y el suite **falla**.
2. **Watchdog en `_process`**: si `_run()` no termina en `FRAMES_MAX` (300) frames, el
   proceso cierra con código 1. Sin esto, un aborto silencioso deja el `SceneTree`
   colgado **para siempre** (nunca se llama `quit()`) y el stdout se pierde.
3. El grep de verificación incluye `SCRIPT ERROR`, `Parse Error`, `Invalid` y `Warning`.
