**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 124: Contenido Generado por Usuarios

## 1. Análisis del dominio
El UGC en juegos cosy (Animal Crossing, Stardew) aporta longevidad y comunidad; sin embargo, exige moderación, almacenamiento y legales. El proyecto ya tiene: fotografía (M56), construcción (M17/18), community (M100), legal (M125/M78/M80/M127) y telemetría (M104). Este módulo define el UGC como **feature post-V2** con GATE, aprovechando la filosofía del M123 (modding): no gastar en V1.

## 2. Alternativas consideradas y decisiones

### D1: ¿Existe UGC?
- **A1 (Sí, en V1)**: riesgo de moderación y costes en la ventana crítica.
- **A2 (No, nunca)**: pierde networking social del juego cosy.
- **A3 (GATE post-V2)**: sin riesgo en V1; el diseño queda listo (galería, moderación, TOS).
- **Decisión:** **A3** — GATE post-V2 con criterios: comunidad ≥ 25% pide compartir (M100), coste mensual de almacenamiento ≤ X, moderación automática ≥ 90% de efectividad (métrica estimada), y diseño aprobado.

### D2: Contenido compartible
- **A1 (compartir todo)**: fotos, diseños, construcciones, textos: superficie de moderación enorme.
- **A2 (contenido nodal: fotos + blueprints de construcción)**: lo que más socializa en el género; las construcciones como blueprints (JSON comprimido, sin datos de mundo).
- **Decisión:** **A2** — fotos (de M56, comprimidas 2K, opción de permitir texturas del juego), blueprints de diseño/construcción (M18/M17) validados por límites; sin compartir textos/mundos.

### D3: Moderación
- **A1 (humana 100%)**: caro y lento.
- **A2 (híbrida: hash + IA + humana para apelaciones y muestras)**: costo razonable; la IA (M86 no, pero pipelines) valida imágenes; humana revisa flags y apelaciones.
- **Decisión:** **A2** — orden: hash de contenido conocido (lista negra) → moderación automática heurística + IA de imágenes → cola humana para dudosos → apelaciones.

### D4: Almacenamiento
- **A1 (backend propio)**: operación y costo.
- **A2 (servicio en la nube con presupuesto)**: fotos en CDN + blueprints en tabla/objeto pequeño; retención y límites estrictos.
- **Decisión:** **A2** — presupuesto mensual fijo: fotos 2K (max 3 MB) en CDN; blueprints ≤ 256 KB JSON comprimido; 200 ítems por usuario; 30 días de retención en quarentena, ilimitado en público hasta reporte/baja.

### D5: Propiedad y licencia
- **A1 (reclamar copyright total del UGC)**: mala imagen y legal confuso.
- **A2 (el usuario conserva su contenido; licencia de uso al servicio para operarlo + política de contenido del juego M127)**: correcto y típico de la industria.
- **Decisión:** **A2** — cláusula en ToS (M125): el usuario conserva el copyright; otorga licencia limitada al servicio (alojar, mostrar, moderar); el contenido que usa assets del juego cae bajo las políticas del juego (M127).

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Inundación de contenido ofensivo | Media | Alta | Moderación automática + cola humana + SLA de remoción < 24 h |
| Coste de almacenamiento descontrolado | Media | Media | Límites por usuario/ítem + compresión + presupuesto mensual |
| Reportes legales (derecho al olvido) | Baja | Media | Proceso de eliminación documentado (M80) |
| Spam/duplicados | Alta | Baja | Hash + límites + telemetría (M104) |
| UGC roto por saves con mods | Baja | Media | Los blueprints validan contra límites del juego (M123/M109) |

## 4. Plan de ejecución (fases — post-V2)
| Fase | Contenido |
|------|-----------|
| **F1 GATE** | Criterios de comunidad/coste/efectividad |
| **F2 Core de subida** | Publicar/descargar fotos y blueprints (CDN) |
| **F3 Moderación** | Hash + IA + cola humana + apelaciones |
| **F4 Legal y datos** | Licencia en ToS, privacidad M80, eliminación |
| **F5 Almacenamiento** | Límites, retención, backups |

## 5. Métricas de éxito
1. GATE de UGC definido con los 4 criterios.
2. Flujo de publicación validado con 10 000 ítems simulados (coste/hr).
3. Moderación automática ≥ 75% de resolución sin humana (meta estimada).
4. Remoción de contenido reportado < 24 h (SLA).
5. 0 violaciones de privacidad en auditoría (M80/M151).
6. Presupuesto mensual de almacenamiento dentro de X (ajustable).
7. Backups del UGC con RPO 24 h.

## 6. Notas para integración
- El UGC reutiliza el formato de M108 (blueprint de construcción) y validadores de M109.
- La galería se integra con la telemetría de M104 (vistas, descargas, reportes).
- Las políticas de contenido son las de M100; los ToS de M125; copyright de M127.