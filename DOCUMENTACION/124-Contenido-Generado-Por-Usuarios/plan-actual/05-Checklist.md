**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 124: Contenido Generado por Usuarios (110 ítems)

## Convención
- `[x]` = completado. `[ ]` = pendiente. `[?]` = no resuelto (decisión / servicio / UI / legal / proceso, con dueño externo).
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Decidir si existirá (1º)

- [x] Definir UGC como post-V2 con GATE [M]
- [?] Definir criterio: demanda comunitaria ≥ 25% (M100) [S] — dueño: producto + M100
- [?] Definir criterio: coste mensual de almacenamiento ≤ presupuesto [S] — dueño: infra/presupuesto
- [x] Definir criterio: efectividad de moderación automática ≥ 75% [S]
- [?] Definir criterio: diseño aprobado 100% [S] — dueño: diseño/producto
- [x] Definir posposición a V3 si el GATE falla [S]
- [x] Definir sin UGC en V1 (M143) documentado [S]

## 2. Definir fotografías (2º)

- [?] Definir compartir fotos de la cámara (M56) [M] — dueño: M56 + UI M89
- [x] Definir compresión 4K → 2K al compartir [M] — iter. 2 (Log 905): `UgcSanitizer.redimensionar()` / `preparar_foto()` (CP D-06..D-09)
- [x] Definir tamaño máximo 3 MB por foto [S] — iter. 2 (Log 905): `UgcLimits.peso_max("foto")` + `validar_item()` (CP B-01/B-02)
- [x] Definir formato JPG/WebP [S] — iter. 2 (Log 905): `limites.formatos_foto` + `formato_soportado()` (CP A-10/B-07/B-08)
- [x] Definir metadatos mínimos (alias, timestamp, tag) [S] — iter. 2 (Log 905): `UgcTelemetry`: alias hasheado + timestamp (CP E-10/E-11)
- [x] Definir opción de ocultar la foto de la galería [S]
- [x] Definir licencia informada antes de subir [M]
- [x] Definir sin datos de locación en la foto [S]

## 3. Definir diseños (3º)

- [?] Definir compartir blueprints de diseño (M18) [M] — dueño: M18 + UI M89
- [x] Definir formato JSON comprimido (esquema M108) [M]
- [x] Definir tamaño máximo 256 KB [S] — iter. 2 (Log 905): `peso_max("blueprint")` (CP B-03/B-04)
- [x] Definir validación de límites del diseño al compartir (M109) [M]
- [x] Definir previsualización del blueprint [S]
- [x] Definir sin coords del save en el blueprint [S] — iter. 2 (Log 905): `UgcSanitizer.sanitizar_blueprint()` (CP D-11..D-17)

## 4. Definir construcciones compartibles (4º)

- [x] Definir compartir construcciones (M17) como blueprint expandido [M]
- [x] Definir tamaño máximo 512 KB [S] — iter. 2 (Log 905): `peso_max("construccion")` (CP B-05/B-06)
- [x] Definir validación de requisitos del jugador receptor (M16/M17) [M]
- [?] Definir ejemplos de materiales requeridos [S] — dueño: contenido (M16/M17)
- [x] Definir construcción en modo "fantasma" previa (M17) [M]
- [?] Definir regla: no puede exceder límites de terreno del jugador [M] — dueño: M17/M109

## 5. Definir moderación (5º)

- [x] Definir pipeline: hash → heurística → IA de imágenes → cola humana [C]
- [x] Definir hash contra blacklist de contenido conocido [M]
- [?] Definir umbral de IA para NSFW/odio [M] — dueño: servicio de moderación (post-V2)
- [?] Definir cola humana con SLA 24 h [M] — dueño: proceso/ops
- [x] Definir apelación del usuario con 2ª instancia [M]
- [x] Definir anonimato del moderador [S]
- [x] Definir audit log de moderación sin datos personales (M103) [M]
- [?] Definir reportes de usuario entran a la misma cola (M100) [M] — dueño: M100
- [x] Definir métrica de efectividad de la moderación automática [M]
- [x] Definir guía de moderadores (criterios explícitos) [M]

## 6. Definir almacenamiento (6º)

- [?] Definir fotos en CDN [M] — dueño: infra/servicio
- [?] Definir blueprints en bucket/objeto pequeño [M] — dueño: infra/servicio
- [?] Definir presupuesto mensual fijo [M] — dueño: infra
- [x] Definir retención: quarentena 30 días [M]
- [x] Definir retención: público ilimitado salvo reporte/baja [S]
- [x] Definir compresión de todos los ítems [M] — iter. 2 (Log 905): ZSTD vía `FileAccess.open_compressed` (CP D-18/D-19)
- [x] Definir monitoreo de espacio en dashboard (M104) [S]
- [x] Definir reutilización de infra sin servidores propios [M]

## 7. Definir reportes (7º)

- [x] Definir categorías de reporte (NSFW/violencia/odio/spam/copyright/privacidad) [M]
- [x] Definir SLA de remoción por categoría (< 24 h, < 48 h, < 72 h) [M]
- [x] Definir notificación al autor de la decisión [S]
- [x] Definir opción de apelación en la notificación [S]
- [?] Definir proceso de stickers (repetir reportes abusivos) [S] — dueño: proceso/moderación
- [x] Definir registro de resolución de reportes [S]

## 8. Definir privacidad (8º)

- [x] Definir consentimiento explícito al compartir (checkbox) [M]
- [x] Definir minimización de datos (solo alias + timestamp) [M]
- [x] Definir sin ID de plataforma expuesto en la galería [S] — iter. 2 (Log 905): `CLAVES_PROHIBIDAS` + `CLAVES_PII` (CP D-11/E-07/E-08)
- [?] Definir almacenamiento según región de M80 [M] — dueño: M80/infra
- [x] Definir política de cookies/privacidad para la galería (M80) [S]
- [?] Definir derecho al olvido operativo (GDPR) [M] — dueño: proceso/legal
- [x] Definir auditoría de privacidad en M151 [S]

## 9. Definir copyright (9º)

- [x] Definir que el usuario conserva el copyright de su contenido [M]
- [x] Definir licencia limitada del usuario al servicio (alojar/mostrar/moderar) [M]
- [x] Definir política de assets del juego para contenido derivado (M127) [M]
- [x] Definir proceso DMCA para violaciones (M127/M78) [M]
- [x] Definir atribución de autores en la galería [S]
- [x] Definir prohibición de contenido de terceros no licenciado [M]

## 10. Definir contenido ofensivo (10º)

- [x] Definir criterios explícitos (lista tipo) [M]
- [?] Definir política apta para todas las edades [M] — dueño: legal/producto
- [x] Definir zona gris: decisión humana con guía [M]
- [x] Definir remoción inmediata para contenido grave [S]
- [?] Definir suspensión temporal del autor (3 strikes) [M] — dueño: proceso/moderación
- [x] Definir re-publicación prohibida del contenido eliminado (hash) [S]

## 11. Definir eliminación (11º)

- [x] Definir botón de eliminación en perfil del autor [M]
- [?] Definir borrado efectivo ≤ 30 días (GDPR) [M] — dueño: proceso/legal
- [x] Definir eliminación por moderación con notificación [S]
- [x] Definir flag anti-re-publicación tras eliminación [S]
- [x] Definir export / respaldo del contenido antes de borrar (pedido del autor) [S]
- [x] Definir proceso documentado para pedidos legales [M]

## 12. Definir términos de servicio (12º)

- [x] Definir cláusula UGC en los ToS (M125) [C]
- [x] Definir secciones: propiedad, licencia, prohibiciones, moderación, eliminación, apelación y responsabilidad [M]
- [?] Definir resumen en lenguaje simple + texto legal [M] — dueño: legal (M125)
- [x] Definir referencia a la política de comunidad (M100) [S]
- [?] Definir consentimiento de menores (mínimo de edad) [M] — dueño: legal (M125)
- [?] Definir revisión legal anual del TOS (M126) [S] — dueño: legal (M126)

## 13. Definir backups (13º)

- [x] Definir backup diario de la tabla de ítems (RPO 24 h) [M]
- [x] Definir retención de backups 90 días [S]
- [x] Definir verificación semanal de restauración [S]
- [x] Definir backup del audit log de moderación [S]
- [x] Definir plan de contingencia ante caída del servicio UGC [M]

## 14. Definir límites de almacenamiento (14º)

- [x] Definir 200 ítems activos por usuario [S] — iter. 2 (Log 905): `items_activos_max()` (CP A-02/C-03/C-04)
- [x] Definir 50 subidas de fotos por día [S] — iter. 2 (Log 905): `fotos_por_dia_max()` (CP A-03/C-06/C-07)
- [x] Definir 20 subidas de blueprints por día [S] — iter. 2 (Log 905): `blueprints_por_dia_max()` (CP A-04/C-08/C-09)
- [x] Definir 10 MB de subida por día [S] — iter. 2 (Log 905): `bytes_por_dia_max()` (CP A-05/C-10/C-11)
- [x] Definir pesos máximos por ítem (3 MB / 512 KB) [S] — iter. 2 (Log 905): `peso_max()` por tipo (CP A-06..A-08/B-01..B-06)
- [x] Definir validación de límites en el cliente (M109) [M]
- [x] Definir mensajes claros de superación de límite [S]

## 15. Galería y UX (integración M89/M100)

- [?] Definir galería pública con filtros por tag [M] — dueño: UI M89
- [?] Definir tarjeta de ítem (foto/blueprint + alias + me gusta) [M] — dueño: UI M89
- [x] Definir acción reportar en cada tarjeta [S]
- [?] Definir página de perfil con mis ítems y estados [M] — dueño: UI M89
- [x] Definir notificaciones de aprobación/remoción [S]
- [x] Definir integración opcional con #showcase de Discord (M100) [S]
- [x] Definir telemetría de vistas/descargas/reportes (M104) [M] — iter. 2 (Log 905): `UgcTelemetry.exportar_a_m104()` (CP E-16/E-17)

## 16. Calidad y cierre

- [x] Definir separación de backend UGC del juego (sin acople) [C]
- [x] Definir seguridad de la API (auth + rate limit, M106) [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S] — iter. 2 (Log 905): `Logs/905-M124-Contenido-Generado-Por-Usuarios-Iter2_2026-09-15.md`
- [x] Definir feed a M125 (ToS) y M136 (roadmap V2) [S]

## Totales

**Total de ítems:** 106
**Ítems completados:** 81 — de los cuales **16** los implementé en la iter. 2 (Log 905)
**Ítems no resueltos `[?]`:** 25 (decisión / servicio / infra / UI / legal / proceso, con dueño externo)

> ⚠️ **Corrección de sobre-cierre (2026-09-15, iter. 2):** este bloque decía
> "106 resueltos, 0 pendientes" cuando el cuerpo del checklist tenía **41 `[ ]` reales**.
> Recontado sobre los ítems de lista reales (`- [x|?| ]`), no sobre el texto del banner.
## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — validación / detección de bugs

### Resultado de test (headless, Godot 4.7.2-stable)
- godot --headless -s res://scripts/ugc/test_ugc_m124.gd -> **16 checks, 0 fallos** (exit 0) ✅ ⚠️ la ruta escrita antes (`scripts/legal/`) **no existe** (corregido en iter. 2).

### Artefactos verificados
- `data/ugc/ugc_catalog.json` — carga y estructura validada por el test. ⚠️ La ruta escrita antes (`data/legal/ugc/`) **no existe** (corregido en iter. 2).
- `scripts/ugc/ugc_validator.gd` — `validar()`/`reporte()` detectan datos corruptos. ⚠️ La ruta escrita antes (`scripts/legal/UgcValidator.gd`) **no existe**, y el texto tenía un **vertical tab (0x0B)** donde iba la `v` y una `r` comida en `eporte()` (corregido en iter. 2).
- `scripts/ugc/test_ugc_m124.gd` — ejecuta sin errores, sin regresiones con M60 (66/0 OK).

### Hallazgo honesto (brecha de implementación)
El módulo se liberó como "núcleo iter. 1" con JSON + Validator + Test.
- Autoload de servicio: UgcManager autoload SÍ presente (verificado por test).
El checklist de producto (espec. completa) permanece sin marcar: la capa de validación de datos SÍ está verificada; la capa de servicio/docs puede faltar según el plan.

### Veredicto QA
- DoD de la *capa de validación de datos*: **CUMPLIDO** (código existe, compila, tests 0 fallos, sin regresiones).
- Producto completo según plan: revisar con dueño.
- Estado recomendado: **🟡 Con dudas** (scaffold de validación verificado; pendiente capa de servicio/docs si aplica).

**Firma:** Hy3 / Kilo Code — 2026-09-02
## Verificación (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] test_ugc_m124.gd: **16/16 checks OK, exit 0** (UgcManager 3 piezas, 5 tipos/4 estados válidos, 2 publicadas + 1 en revisión, 2 decoraciones, catálogo 0 errores, reportes, detecciones de tipo/estado/política inválidos)
- [x] Módulo verificado: flujos de moderación y validación de UGC operativos

## Iteración 2 — 2026-09-15 (Log 905, DeepSeek-V4.1-Flash / WorkBuddy)

**Reclamo:** §21.4.7 (dueño `deepseek-v4-flash-vision-exp` descatalogado).

**Alcance:** solo la **parte verificable headless**. Todo lo que es servicio, infra,
UI, legal o proceso queda `[?]` con dueño externo (25 ítems).

### Código nuevo
| Archivo | Qué hace |
|---------|-----------|
| `scripts/ugc/ugc_limits.gd` | `UgcLimits` — RF13 data-driven: validación por ítem y por cuota, con motivo constante + mensaje claro |
| `scripts/ugc/ugc_sanitizer.gd` | `UgcSanitizer` — 4K→2K, formatos, blueprint sin coords del save, compresión ZSTD |
| `scripts/ugc/ugc_telemetry.gd` | `UgcTelemetry` — eventos sin PII (alias hasheado FNV-1a), export a M104 |
| `scripts/ugc/test_ugc_m124_iter2.gd` | 85 checks, 6 bloques con marcador `_fin()` + watchdog anti-cuelgue |

`data/ugc/ugc_catalog.json` se extendió (aditivo) con `limites` y
`claves_prohibidas_blueprint`; la iter. 1 (3 piezas / 5 tipos / 4 estados) sigue verde.

### Evidencia
- `test_ugc_m124_iter2.gd`: **85/0 ×3**, `EXIT 0`, `0 SCRIPT ERROR`.
- Regresión `test_ugc_m124.gd`: **16/0 ×2**, `EXIT 0`, `0 SCRIPT ERROR`.
- Total M124: **101 checks**.

### Hallazgos (ver `07-Resultados-Testings.md`)
1. `PackedByteArray.compress()`/`decompress()` **no cierran el ciclo** en 4.7.2
   (33 B → `compress(ZSTD)` 42 B → `decompress(true)` **1 B**). Se usa
   `FileAccess.open_compressed` con ZSTD.
2. El proyecto trata los **warnings de GDScript como errores**: un `:=` sobre `Variant`
   rompe la compilación y el bloque de test **aborta en silencio**.
3. Un aborto silencioso dentro de `_run()` con `call_deferred` **cuelga el SceneTree**
   para siempre (nunca llega a `quit()`) y el stdout se pierde. Se agregó watchdog.
4. `04-Codigo.md` describía rutas **Unity/C#** inexistentes → reescrito.
5. La fila de `CHECKLIST-GLOBAL` decía `10/106` mientras este checklist tenía 65 `[x]`
   (desincronización fila↔checklist).

**Pendiente:** QA cruzado §21.8 por otro agente (verificador ≠ autor).
