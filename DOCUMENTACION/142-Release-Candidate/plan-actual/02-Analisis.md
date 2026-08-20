**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 142: Release Candidate

## 1. Análisis del dominio
El RC es una fase de **validación y congelación**, no de desarrollo. El trabajo se organiza en 4 frentes:

1. **Congelación**: un comité de release autoriza hotfixes; todo cambio genera nueva build etiquetada. Sin esto, el "RC" es una Beta más.
2. **Validación técnica**: instalación limpia, actualización funcional, saves/cloud, logros, idiomas, rendimiento, crash rate.
3. **Validación de negocio**: certificación, legal y marketing.
4. **Operación**: soporte y plan/runbook de lanzamiento.

## 2. Alternativas consideradas y decisiones

### D1: Política de hotfixes en RC
- **A1 (cero cambios)**: arriesgado si aparece un bloqueador de plataforma.
- **A2 (hotfixes P0/P1 aprobados, re-etiquetado rc-N)**: cada hotfix revalida el checklist; es el estándar de la industria.
- **Decisión:** **A2** — comité de release (producción + QA + plataformas) vota cada hotfix; re-etiqueta `rc-2`, `rc-3`…

### D2: Duración de la fase
- **A1 (2 semanas a calendario fijo)**: puede dejar bloqueadores sin cerrar.
- **A2 (gate-based, con ventana de 4 semanas máx.)**: el RC se cierra cuando el checklist da verde; tope de 4 semanas obliga a decidir.
- **Decisión:** **A2** — gates con tope; si a las 4 semanas no se logra, se baja a 2 hotfixes y se replanifica la fecha.

### D3: Cómo medir crash rate
- **A1 (esperar al público)**: tarde para corregir.
- **A2 (pilotaje previo de 1000 sesiones con telemetría)**: representativo y medible antes del día 0.
- **Decisión:** **A2** — 1000 sesiones con invitados (alpha cerrada de lanzamiento) recolectando stacktraces (M105).

### D4: Verificación de idiomas/logros
- **A1 (muestra por idioma)**: rápido pero con riesgo de claves rotas.
- **A2 (matriz completa: 6 idiomas × todas las pantallas + logros por hito)**: exhaustivo; automatizable con gates CI.
- **Decisión:** **A2** — gates automáticos + playtest dirigido de 30 min por idioma.

### D5: Saves cloud en día 0
- **A1 (sin cloud en día 0)**: simplifica certificación pero degrada experiencia.
- **A2 (cloud activo con conflicto resuelto por "último ganador + backup")**: ya implementado en Beta (M60), se valida en RC.
- **Decisión:** **A2** — sin cambios de arquitectura; validación masiva de sincronización.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Hotfix que reintroduce un bug (regresión) | Media | Alta | Test de regresión obligatorio (M112) + re-corrida del checklist RC |
| Certificación rechazada por política de plataforma | Baja | Alta | Checklist M149 con revisión legal 2 semanas antes |
| Crash rate fuera de objetivo en piloto | Baja | Alta | Stacktraces por zona desde M105; hotfix dirigido antes del día 0 |
| Store/reviews negativos por bugs menores | Media | Media | P0/P1 cero + plan de hotfix 2.0.x con cola de P2 |
| Error en fecha de lanzamiento (coordinación M143) | Media | Media | Runbook con responsables y holgura de 48 h |

## 4. Plan de ejecución (gates, máx. 4 semanas)
| Etapa | Contenido | Salida |
|-------|-----------|--------|
| **G1 Congelar** | Freeze de features/contenido firmado; manifest RC-1 | Build `rc-1` etiquetada |
| **G2 Validar técnica** | Instalación/actualización limpias, saves/cloud, logros, idiomas, rendimiento | Checklist técnico verde |
| **G3 Validar negocio** | Certificación, legal, marketing, soporte | Aprobaciones firmadas |
| **G4 Pilotar** | 1000 sesiones; crash rate < 0.5%; métricas finales | Informe de piloto |
| **G5 Congelar final** | Checklist RC completo verde; build `rc-final` | Entrega a M143 |

## 5. Métricas de éxito
1. Cero features nuevas desde el freeze (audit diffs contra `beta-rc-candidate`).
2. 100% instalaciones limpias y 100% actualizaciones funcionales en plataformas.
3. 30 ciclos de cloud sin pérdida; 0 bugs de saves en piloto.
4. Logros: matriz 100% alcanzable; 0 dependencias de red en desbloqueo local.
5. 6 idiomas sin claves rotas (gate CI + playtest 30 min c/u).
6. Rendimiento en presupuesto (M61-M63) y crash rate < 0.5% en 1000 sesiones.
7. Certificación/legal firmados; marketing y soporte operativos.
8. Plan de lanzamiento aprobado con runbook completo (M143).

## 6. Notas para M143 (Lanzamiento)
- El RC se entrega como `rc-final + hash`; solo actualizaciones por hotfix post-lanzamiento (2.0.x).
- Analítica de lanzamiento (Día 0): stores, reviews, crashes, saves, compras (según M149/M106).
- El runbook define quién vigila qué en las primeras 72 h.