**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 124: Contenido Generado por Usuarios

## 1. GATE de UGC (post-V2)
| Criterio | Umbral |
|----------|--------|
| Demanda comunitaria | ≥ 25% de usuarios activos piden compartir (M100) |
| Coste mensual de almacenamiento | ≤ presupuesto de la tabla sección 5 |
| Efectividad de moderación automática | ≥ 75% resuelto sin humana (estimado) |
| Diseño de este módulo aprobado | 100% puntos 1-14 |
- Si falla → posponer a V3 (sin coste comprometido).

## 2. Tipos de contenido (RF2)
| Tipo | Formato | Tamaño máx | Compartido desde |
|------|---------|-----------|------------------|
| Fotografía (M56) | JPG/WebP 2K (desde 4K) | 3 MB | Cámara del juego |
| Blueprint de diseño (M18) | JSON comprimido (formato M108) | 256 KB | Editor de diseño |
| Construcción (M17) | Blueprint expandido | 512 KB | Editor de construcción |
- Los blueprints NO incluyen: datos del mundo, coords del save, datos personales.

## 3. Flujo de publicación (RF3)
1. Captura/creación → "Compartir" (M56/M89).
2. Previsualización + confirmación (licencia informe M125/M127).
3. Subida a CDN (fotos) o bucket de objetos (blueprints) con presupuesto.
4. Moderación automática (hash + heurística + IA).
5. Publicación en galería pública (pas = feed de fichas).
6. Descarga de blueprints: validación de límites al instanciar (M109).

## 4. Moderación (RF4)
```
Publicación
  → Hash contra blacklist (imágenes conocidas / blueprints de spam)
  → IA de imágenes (NSFW/odio) con umbral
  → Si ok: publica; si dudoso: cola humana (SLA 24 h); si grave: rechazo + reporte
  → Apelación: usuario puede apelar → revisión humana 2ª instancia
```
- El reporte del usuario (M100) entra igual a la cola humana.
- Registro de moderación: audit log (M103) sin datos personales.

## 5. Almacenamiento (RF5/RF13)
| ítem | Detalle |
|------|---------|
| Fotos | CDN, 2K máx 3 MB, presupuesto mensual definido |
| Blueprints | tabla/objeto pequeño (256-512 KB) |
| Límites por usuario | 200 ítems activos, 50/día, 10 MB/día |
| Quarentena | 30 días de retención antes de borrar definitivo |
| Público | retención ilimitada salvo reporte/baja |
| Backups | RPO 24 h (backups incrementales diarios) |

## 6. Reportes (RF6)
| Categoría | SLA de remoción |
|-----------|-----------------|
| NSFW / violencia / odio | < 24 h |
| Spam / duplicados | < 48 h |
| Violación de copyright (DMCA) | < 72 h + proceso DMCA (M127/M78) |
| Privacidad (dato personal) | < 24 h + GDPR (M80) |
- El autor recibe email con la decisión y opción de apelación.

## 7. Privacidad (RF7 — M80)
- Consentimiento explícito al compartir (checkbox con licencia).
- Minimización: solo foto + nombre de jugador (alias) + timestamp; sin locación ni ID de plataforma expuesto.
- Región: almacenamiento según política de M80 (si es necesario, split por región en V3).

## 8. Copyright (RF8 — M127)
- ToS (M125): el usuario conserva el copyright de su contenido; otorga licencia limitada al servicio (alojar, mostrar, moderar, distribuir dentro del juego).
- El contenido que usa assets del juego se rige por la política de assets del juego (M127) y las reglas de la comunidad (M100).

## 9. Contenido ofensivo (RF9)
- Criterios explícitos (lista tipo): NSFW, discriminación, gore, spam, impersonación.
- Edad: el juego es para todas las edades; política acorde (sin contenido adulto).
- Zona gris: decisión humana con guía de moderadores.

## 10. Eliminación (RF10)
- Derecho al olvido: botón de eliminación en perfil → borrado en ≤ 30 días (GDPR M80).
- Baja del sistema (TOS): moderador elimina + notifica + cuenta de apelación.
- Flag tras eliminación: no re-publicable (hashero).

## 11. Términos de servicio (RF11 — M125)
- Cláusula UGC inserta en ToS: propiedad, licencia, prohibiciones, moderación, eliminación, apelación y responsabilidad.
- Inteligible: resumen ("en simple") + texto legal.

## 12. Limites y cierre
| Límite | Valor |
|--------|-------|
| Ítems activos por usuario | 200 |
| Subidas por día | 50 (fotos) + 20 (blueprints) |
| Peso por ítem | 3 MB (foto), 512 KB (blueprint) |
| Presupuesto mensual | X (ajustado en GATE) |
- La galería pública muestra: foto/blueprint + autor (alias) + me gusta (sin números sensibles) + reportar.

## 13. Prohibiciones técnicas
1. El UGC no ejecuta código (M123 alineado).
2. Nunca se comparte la semilla del mundo ni coords del save (M59 protege).
3. Sin datos personales del usuario en los items (solo alias).
4. Sin moderación humana visible para el usuario (anonimato del moderador).