**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 124: Contenido Generado por Usuarios

## 1. Problema
Un juego cosy con fotografía (M56) y construcción (M17/18) invita a que los jugadores **compartan contenido** (fotos, diseños/planos, construcciones). Sin reglas, sistema y límites definidos, el UGC (User Generated Content) puede generar: contenido ofensivo no moderado, costos de almacenamiento descontrolados, problemas de copyright/privacidad y obligaciones de soporte sin criterio. Este módulo define **si existe UGC, qué se comparte y cómo se gobierna**.

## 2. Objetivo del módulo
Documentar el **plan de contenidos generados por usuarios**: decisión de alcance (post-V2, alineado a M123 Modding), tipos de contenido (fotografías de M56, diseños/planos, construcciones compartibles), moderación, almacenamiento, reportes, privacidad (M80), copyright (M127), contenido ofensivo, eliminación, términos de servicio (M125), backups y límites de almacenamiento.

## 3. Alcance (derivado del plan maestro: sección 123 "CONTENIDO GENERADO POR USUARIOS")
1. **Decidir si existirá** — GATE post-V2 con criterios de seguridad/coste.
2. **Fotografías** — compartir fotos tomadas con la cámara del juego (M56) en galería pública.
3. **Diseños** — compartir planos/diseños de construcción (M18) como blueprints en código.
4. **Construcciones compartibles** — exportar/importar construcciones (M17) con validación de límites.
5. **Moderación** — flujo de moderación (automática + humana + comunitaria).
6. **Almacenamiento** — dónde y cuánto (backend propio vs servicio).
7. **Reportes** — reporte de contenido (usuario) y reportes de sistema (abuso).
8. **Privacidad** — datos que se comparten, consentimiento (M80), minimización.
9. **Copyright** — quién es dueño de qué (contenido del juego vs contenido del usuario) (M127/M78).
10. **Contenido ofensivo** — política clara, agua en falso, criterios de remoción.
11. **Eliminación** — pedido del usuario y bajas del sistema.
12. **Términos de servicio** — cláusulas UGC en los ToS (M125).
13. **Backups** — backup del UGC y su retención.
14. **Límites de almacenamiento** — por usuario, por ítem, por total.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Decisión de UGC con GATE post-V2 (criterios: seguridad, coste, demanda) |
| RF2 | Tipos de contenido: fotos, blueprints de diseño, construcciones |
| RF3 | Compartir: flujo publicar/descargar galería pública |
| RF4 | Moderación: automática (hash+IA) → humana → apelación |
| RF5 | Almacenamiento: servicio con presupuesto y retención |
| RF6 | Reportes: categorías y SLA de respuesta |
| RF7 | Privacidad: consentimiento, minimización, región (M80) |
| RF8 | Copyright: licencia del usuario al servicio + uso de contenido del juego |
| RF9 | Contenido ofensivo: criterios + proceso de remoción |
| RF10 | Eliminación: derecho al olvido (GDPR) y bajas por política |
| RF11 | ToS: cláusula UGC redactada (M125) |
| RF12 | Backups: frecuencia y retención del UGC |
| RF13 | Límites: máx por usuario (archivos, peso) y por ítem |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 14 puntos del maestro documentados con decisiones.
2. GATE de UGC con criterios medibles (igual que M123).
3. Galería pública diseñada (publicar/ver/descargar/reportar).
4. Moderación con flujo completo (auto → humano → apelación).
5. Almacenamiento con presupuesto y retención.
6. Privacidad alineada a M80 (consentimiento y región).
7. Licencia de UGC redactada (TOS M125 + copyright M127).
8. Límites definidos por usuario/ítem.
9. Proceso documentado de eliminación (derecho al olvido).
10. Backups del UGC con retención.

## 6. Restricciones
- **Aplican:** M56 (foto), M17/M18 (construcción/diseño), M123 (modding), M125 (ToS), M80 (privacidad), M127 (copyright), M100 (comunidad/moderación), M104 (telemetría), M106 (seguridad).
- Sin UGC en V1 (M143): solo diseño + preparación de código (marcadores de telemetría opcionales).
- Coste de almacenamiento contenido en presupuesto general: hace que las fotos se compriman a 4K→2K, los blueprints sean JSON comprimido.
- El UGC nunca ejecuta scripts (alineado con M123).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M123** — Modding | Base para modding |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M123** — Modding | Depende de este módulo |

