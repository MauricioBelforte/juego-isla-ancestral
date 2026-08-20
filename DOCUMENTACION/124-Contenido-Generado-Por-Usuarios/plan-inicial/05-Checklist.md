**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 124: Contenido Generado por Usuarios (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Decidir si existirá (1º)

- [x] Definir UGC como post-V2 con GATE [M]
- [x] Definir criterio: demanda comunitaria ≥ 25% (M100) [S]
- [x] Definir criterio: coste mensual de almacenamiento ≤ presupuesto [S]
- [x] Definir criterio: efectividad de moderación automática ≥ 75% [S]
- [x] Definir criterio: diseño aprobado 100% [S]
- [x] Definir posposición a V3 si el GATE falla [S]
- [x] Definir sin UGC en V1 (M143) documentado [S]

## 2. Definir fotografías (2º)

- [x] Definir compartir fotos de la cámara (M56) [M]
- [x] Definir compresión 4K → 2K al compartir [M]
- [x] Definir tamaño máximo 3 MB por foto [S]
- [x] Definir formato JPG/WebP [S]
- [x] Definir metadatos mínimos (alias, timestamp, tag) [S]
- [x] Definir opción de ocultar la foto de la galería [S]
- [x] Definir licencia informada antes de subir [M]
- [x] Definir sin datos de locación en la foto [S]

## 3. Definir diseños (3º)

- [x] Definir compartir blueprints de diseño (M18) [M]
- [x] Definir formato JSON comprimido (esquema M108) [M]
- [x] Definir tamaño máximo 256 KB [S]
- [x] Definir validación de límites del diseño al compartir (M109) [M]
- [x] Definir previsualización del blueprint [S]
- [x] Definir sin coords del save en el blueprint [S]

## 4. Definir construcciones compartibles (4º)

- [x] Definir compartir construcciones (M17) como blueprint expandido [M]
- [x] Definir tamaño máximo 512 KB [S]
- [x] Definir validación de requisitos del jugador receptor (M16/M17) [M]
- [x] Definir ejemplos de materiales requeridos [S]
- [x] Definir construcción en modo "fantasma" previa (M17) [M]
- [x] Definir regla: no puede exceder límites de terreno del jugador [M]

## 5. Definir moderación (5º)

- [x] Definir pipeline: hash → heurística → IA de imágenes → cola humana [C]
- [x] Definir hash contra blacklist de contenido conocido [M]
- [x] Definir umbral de IA para NSFW/odio [M]
- [x] Definir cola humana con SLA 24 h [M]
- [x] Definir apelación del usuario con 2ª instancia [M]
- [x] Definir anonimato del moderador [S]
- [x] Definir audit log de moderación sin datos personales (M103) [M]
- [x] Definir reportes de usuario entran a la misma cola (M100) [M]
- [x] Definir métrica de efectividad de la moderación automática [M]
- [x] Definir guía de moderadores (criterios explícitos) [M]

## 6. Definir almacenamiento (6º)

- [x] Definir fotos en CDN [M]
- [x] Definir blueprints en bucket/objeto pequeño [M]
- [x] Definir presupuesto mensual fijo [M]
- [x] Definir retención: quarentena 30 días [M]
- [x] Definir retención: público ilimitado salvo reporte/baja [S]
- [x] Definir compresión de todos los ítems [M]
- [x] Definir monitoreo de espacio en dashboard (M104) [S]
- [x] Definir reutilización de infra sin servidores propios [M]

## 7. Definir reportes (7º)

- [x] Definir categorías de reporte (NSFW/violencia/odio/spam/copyright/privacidad) [M]
- [x] Definir SLA de remoción por categoría (< 24 h, < 48 h, < 72 h) [M]
- [x] Definir notificación al autor de la decisión [S]
- [x] Definir opción de apelación en la notificación [S]
- [x] Definir proceso de stickers (repetir reportes abusivos) [S]
- [x] Definir registro de resolución de reportes [S]

## 8. Definir privacidad (8º)

- [x] Definir consentimiento explícito al compartir (checkbox) [M]
- [x] Definir minimización de datos (solo alias + timestamp) [M]
- [x] Definir sin ID de plataforma expuesto en la galería [S]
- [x] Definir almacenamiento según región de M80 [M]
- [x] Definir política de cookies/privacidad para la galería (M80) [S]
- [x] Definir derecho al olvido operativo (GDPR) [M]
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
- [x] Definir política apta para todas las edades [M]
- [x] Definir zona gris: decisión humana con guía [M]
- [x] Definir remoción inmediata para contenido grave [S]
- [x] Definir suspensión temporal del autor (3 strikes) [M]
- [x] Definir re-publicación prohibida del contenido eliminado (hash) [S]

## 11. Definir eliminación (11º)

- [x] Definir botón de eliminación en perfil del autor [M]
- [x] Definir borrado efectivo ≤ 30 días (GDPR) [M]
- [x] Definir eliminación por moderación con notificación [S]
- [x] Definir flag anti-re-publicación tras eliminación [S]
- [x] Definir export / respaldo del contenido antes de borrar (pedido del autor) [S]
- [x] Definir proceso documentado para pedidos legales [M]

## 12. Definir términos de servicio (12º)

- [x] Definir cláusula UGC en los ToS (M125) [C]
- [x] Definir secciones: propiedad, licencia, prohibiciones, moderación, eliminación, apelación y responsabilidad [M]
- [x] Definir resumen en lenguaje simple + texto legal [M]
- [x] Definir referencia a la política de comunidad (M100) [S]
- [x] Definir consentimiento de menores (mínimo de edad) [M]
- [x] Definir revisión legal anual del TOS (M126) [S]

## 13. Definir backups (13º)

- [x] Definir backup diario de la tabla de ítems (RPO 24 h) [M]
- [x] Definir retención de backups 90 días [S]
- [x] Definir verificación semanal de restauración [S]
- [x] Definir backup del audit log de moderación [S]
- [x] Definir plan de contingencia ante caída del servicio UGC [M]

## 14. Definir límites de almacenamiento (14º)

- [x] Definir 200 ítems activos por usuario [S]
- [x] Definir 50 subidas de fotos por día [S]
- [x] Definir 20 subidas de blueprints por día [S]
- [x] Definir 10 MB de subida por día [S]
- [x] Definir pesos máximos por ítem (3 MB / 512 KB) [S]
- [x] Definir validación de límites en el cliente (M109) [M]
- [x] Definir mensajes claros de superación de límite [S]

## 15. Galería y UX (integración M89/M100)

- [x] Definir galería pública con filtros por tag [M]
- [x] Definir tarjeta de ítem (foto/blueprint + alias + me gusta) [M]
- [x] Definir acción reportar en cada tarjeta [S]
- [x] Definir página de perfil con mis ítems y estados [M]
- [x] Definir notificaciones de aprobación/remoción [S]
- [x] Definir integración opcional con #showcase de Discord (M100) [S]
- [x] Definir telemetría de vistas/descargas/reportes (M104) [M]

## 16. Calidad y cierre

- [x] Definir separación de backend UGC del juego (sin acople) [C]
- [x] Definir seguridad de la API (auth + rate limit, M106) [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed a M125 (ToS) y M136 (roadmap V2) [S]

## Totales

**Total de ítems:** 106
**Ítems resueltos por documentación:** 106 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)