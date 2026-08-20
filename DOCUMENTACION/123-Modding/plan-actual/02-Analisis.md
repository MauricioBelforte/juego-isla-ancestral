**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 123: Modding

## 1. Análisis del dominio
Es un juego single-player premium cosy; el modding aporta longevidad (contenido infinito a coste cero para el estudio) pero con costes de ingeniería, soporte y riesgo de fragmentación. La decisión se toma con GATE después del lanzamiento (V2), pero la arquitectura propia del proyecto (M108 data-driven + M109 editores + M117 versionado) ya deja **todas las bisagras listas** — este módulo las documenta para que el trabajo post-V2 sea barato y sin re-arquitecturas.

## 2. Alternativas consideradas y decisiones

### D1: ¿Habrá modding?
- **A1 (Sí, desde el lanzamiento)**: riesgo alto de retrasos y bugs de integración en V1.
- **A2 (No, nunca)**: pierde longevidad y comunidad técnica.
- **A3 (GATE post-V2, diseño hoy)**: cero riesgo en V1; coste bajo en V2 porque se documenta la superficie y se proyecta el formato sobre M108.
- **Decisión:** **A3** — GATE post-V2 con criterios: comunidad activa (Discord ≥ X, mods pedidos), risk < 10% presupuesto, y 100% de los puntos de este diseño aprobados. Prioridad Baja confirmada.

### D2: Alcance de la API
- **A1 (API total, incl. scripts C#)**: poderoso pero riesgo de seguridad y balance.
- **A2 (data-first v1: objetos, recetas, biomas, misiones, NPC, tiendas, clima)**: aprovecha M108 y los validators de M109; sin ejecutar código.
- **A3 (scripting con lista de aprobación v2)**: opcional futuro; los scripts corren solo si están en una whitelist firmada.
- **Decisión:** **A2 + A3 parcial** — v1 data-first con validación estricta; v2 scripting solo en whitelist (avance de M106).

### D3: Distribución
- **A1 (Workshop de Steam + tienda propia)**: el Play trazable con M97; demasiada superficie para V2.
- **A2 (solo Steam Workshop)**: integración nativa (Steamworks/Workshop) + telemetría de subscripciones; sin ecosistema propio.
- **Decisión:** **A2** — solo Steam Workshop (M97). Otros canales (Google Drive de la comunidad) fuera de alcance oficial.

### D4: Saves con mods
- **A1 (guardado compactible sin marca)**: cargas rotas inesperadas.
- **A2 (marca de mods + validación al cargar)**: el save registra `mods[]` y el loader valida antes de cargar (M59/M60); carga sin mods → advertencia + opción de continuar (modo sin mods desactivable).
- **Decisión:** **A2** — política: saves con mods y sin mods coexisten con marcas; el modo "sin mods" (desactivar loader) es el estándar de soporte y logros (M72: logros solo en sesiones sin flags de mods).

### D5: Conflicto y compatibilidad
- **A1 (sin gestión)**: mods que se pisan silenciosamente.
- **A2 (ids + prioridad + honestidad)**: manifiesto con `id`, `versión`, `minBuild`; loader cargas por orden de prioridad y marca conflictos (overrides explícitos); incompatibilidad de build → bloqueo con mensaje.
- **Decisión:** **A2** — conflictos id vs id: se declaran como "override" explícito; cualquier duplicado no declarado → warning y el mod de menor prioridad se omite.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Coste técnico excede presupuesto V2 | Media | Alta | GATE ≤ 10%; alcance data-first primero |
| Saves rotos por desinstalación de mods | Media | Alta | Marca + advertencia + backup de save (M107) |
| Balance/canonicidad rota por mods | Media | Media | Logros fuera en sesiones con mods (M72); telemetría con flag de mods (M104) |
| Malware vía "mods" | Baja | Alta | Validación de datos + sin scripts en v1 + whitelist v2 |
| Soporte esclavo de bugs de mods | Media | Media | TRIAGE solo sin mods + FAQ (M100) |

## 4. Plan de ejecución (fases — post-V2)
| Fase | Contenido |
|------|-----------|
| **F1 GATE** | Revisar criterios (comunidad, presupuesto) y aprobar alcance |
| **F2 Core** | ModLoader, manifiesto, validación, conflictos |
| **F3 Exportadores** | Extender M109 para exportar mods |
| **F4 Saves** | Marca de mods + carga compatible (M59) |
| **F5 Distribution** | Workshop (M97) + telemetría + FAQ (M100) |

## 5. Métricas de éxito
1. GATE de modding definido y ejecutable en V2.
2. Cero re-arquitecturas: el diseño usa M108/M109 tal cual.
3. ModLoader con 100 mods simultáneos < 5 s de carga extra.
4. 0 conflictos no detectados (todos id vs id resueltos o advertidos).
5. Saves con mods: 0 cargas rotas en pruebas (100 ciclos).
6. Coste técnico estimado < 10% presupuesto (documentado).
7. Documentación de modding redactada (guía índice + 1 mod de ejemplo funcional).

## 6. Notas para integración
- El formato de mod es el de M108 (misma serialización); los validators de M109 se reutilizan (con lista de reglas modables).
- La marca de mods entra en el save v3.x (M59) y el manifiesto en el build metas (M117).
- El Workshop usa Steamworks (M97) con límites de tamaño (Workshop permite ~100 MB por item); se define el límite aquí.