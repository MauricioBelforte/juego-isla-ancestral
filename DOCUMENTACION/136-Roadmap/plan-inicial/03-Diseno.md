**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 136-Roadmap
**Estado:** Documentación inicial (plan original)

---

# 03-Diseno.md — Módulo 136: Roadmap

## 1. Estructura del Roadmap

```
FASE 1  →  FASE 2  →  FASE 3  →  FASE 4  →  FASE 5  →  FASE 6  →  FASE 7
M137     →  M138     →  M139     →  M140     →  M141     →  M142     →  M143
Prototipo → Vertical → Pre-Alpha → Alpha     → Beta      → RC        → Lanzamiento
           Slice
```

Reglas estructurales:

- Cada fase se cierra con un **build etiquetado y jugable** (git tag + build Godot).
- Un hito **no comienza** si sus criterios de entrada no se cumplen (se aplica replanificación, no improvisación).
- Un hito **no se cierra** si quedan criterios de salida incumplidos (no se marca `✅` sin la DoD).
- Los hitos M137-M143 corresponden UNA fila en `CHECKLIST-GLOBAL.md` cada uno (módulos homónimos); la fila 136 del roadmap es administrativa.

## 2. Hitos M137-M143 (criterios de entrada y salida)

### 2.1 M137 — Prototipo (Fase 1: protección de riesgo)

| Campo | Valor |
|---|---|
| Objetivo | Demostrar que el núcleo voxel funciona: un mundo voxel pequeño, cavar y colocar, guardar y cargar |
| Criterios de entrada | M01/M02 decididos; Godot 4.x + Voxel Tools instalados y funcionales; módulos base documentados |
| Criterios de salida | Mundo voxel generado proceduralmente con rendimiento aceptable; cavar/colocar operativo; guardado/carga funcional; build etiquetado jugable; prototipo probado con el fundador |
| Entregable | Build de prototipo + video/gif de demostración |
| Prioridad de la fase | Must: generación de mundo (M10), voxel básico (M08), personaje mínimo (M11), guardado mínimo (M60), cámara básica (M12) |

### 2.2 M138 — Vertical Slice (Fase 2: validación de visión)

| Campo | Valor |
|---|---|
| Objetivo | Rebanada jugable de la isla Aurora: el jugador despierta, camina, interactúa y cumple un objetivo corto con guardado |
| Criterios de entrada | Prototipo M137 aprobado; decisión de scope del slice tomada; assets mínimos disponibles |
| Criterios de salida | Escena completa del slice navegable; interacción básica (M70); un objetivo del GDD cumplible; guardado continuo; UI mínima (M53); rendimiento objetivo demostrado; playtest interno (M114) con feedback registrado |
| Entregable | Build del vertical slice + video promocional corto |
| Prioridad de la fase | Must: lo que hace al slice jugable de punta a punta; Should: primeros NPC (M19), música base (M41); Could/Won't: todo lo que no aporte al slice directo |

### 2.3 M139 — Pre-Alpha (Fase 3: loop principal completo)

| Campo | Valor |
|---|---|
| Objetivo | Loop principal completo del GDD acotado: explorar, recolectar, crear, construir y avanzar en ~30 min de juego |
| Criterios de entrada | Vertical slice validado con playtest; sistemas fundamentales identificados y priorizados |
| Criterios de salida | Ciclo jugable de 30 min; sistemas de recolección (M15), crafting (M16), construcción (M17) y economía mínima (M38) integrados; día/noche (M31) y clima básico (M32); guardado robusto; testings de integración pasados |
| Entregable | Build pre-alpha con el loop completo |
| Prioridad de la fase | Must: loop principal; Should: ciclo día/noche, fauna básica (M36); Could: amistad (M20), diálogos (M21) |

### 2.4 M140 — Alpha (Fase 4: contenido y sistemas del núcleo)

| Campo | Valor |
|---|---|
| Objetivo | Contenido y sistemas del núcleo con pulido: la isla Aurora con sus zonas, vecinos, misiones y progresión jugables completos |
| Criterios de entrada | Pre-alpha estable sin crashes bloqueantes; backlog de contenido priorizado |
| Criterios de salida | Contenido de la v1.0 (feature complete aproximado) presente; NPC/vecinos (M19), historia principal (M22) y secundarias (M23), templos y puzzles (M24) jugables; sistema de datos (M60) estable; sin softlocks conocidos (M66) |
| Entregable | Build alpha jugable de punta a punta |
| Prioridad de la fase | Must: contenido v1.0; Should: pulido de UX/UI (M53, M57); Could: extras de museos (M37) |

### 2.5 M141 — Beta (Fase 5: feature complete y equilibrio)

| Campo | Valor |
|---|---|
| Objetivo | Juego completo en contenido, enfocado en bugs, equilibrio y decisiones comerciales (EA vs full release) |
| Criterios de entrada | Alpha con todo el contenido jugable; deuda crítica pagada; decisión de plataforma definida |
| Criterios de salida | Bugs críticos cerrados; equilibrio de economía y progresión ajustado con playtests amplios (M114); accesibilidad (M58) y configuraciones (M90/M91) verificadas; decisión EA vs full release tomada con datos; page de Steam (M97) preparada |
| Entregable | Build beta estable + página de tienda lista |
| Prioridad de la fase | Must: estabilidad y equilibrio; Should: pulido audiovisual (M41-M44); Could: contenido extra |

### 2.6 M142 — RC (Fase 6: candidatos de release)

| Campo | Valor |
|---|---|
| Objetivo | Serie de candidatos de release con compatibilidad, rendimiento y estabilidad de producción |
| Criterios de entrada | Beta estable; lista de bugs conocidos documentada (M102); build de prensa planificado |
| Criterios de salida | RC probado en hardware objetivo; rendimiento dentro de presupuesto (M62/M63); crash reporting (M122) sin errores críticos; achievements y configuraciones de plataforma verificados; build de release etiquetado |
| Entregable | RC estable + notas de parche finales |
| Prioridad de la fase | Must: estabilidad, compatibilidad, performance; Should: último pulido; Won't: features nuevas (congeladas) |

### 2.7 M143 — Lanzamiento (Fase 7: release)

| Campo | Valor |
|---|---|
| Objetivo | Publicar la v1.0 en la plataforma elegida con marketing y soporte post-lanzamiento |
| Criterios de entrada | RC aprobado; página de tienda completa; claves de prensa y comunidad preparadas |
| Criterios de salida | Build v1.0 publicado; anuncio y campaña de lanzamiento ejecutada; plan de hotfix definido; soporte comunitario inicial operativo; retrospectiva final documentada |
| Entregable | Juego publicado + plan de soporte |
| Prioridad de la fase | Must: publicación, anuncio, hotfixes; Should: contenido de post-lanzamiento; Could: contenido poslanzamiento mayor |

## 3. Dependencias por Hito

| Hito | Depende de (hitos) | Dependencias de módulos típicas |
|------|--------------------|----------------------------------|
| M137 Prototipo | — (base M01, M02) | M08 (Mundo Voxel), M10 (Generación), M11 (Personaje), M12 (Cámara), M60 (Datos mínimos) |
| M138 Vertical Slice | M137 | M27 (Islas: zona del slice), M63 (cargas mínimas), M70 (Interacciones), M53 (UI mínima), M14 (Inventario básico) |
| M139 Pre-Alpha | M138 | M15 (Recursos), M16 (Crafting), M17 (Construcción), M38 (Economía mínima), M31 (Día/Noche), M32 (Clima básico) |
| M140 Alpha | M139 | M19 (NPC/Vecinos), M20 (Amistad), M21 (Diálogos), M22 (Historia), M23 (Secundarias), M24 (Templos), M66 (Anti-Softlock) |
| M141 Beta | M140 | M90/M91 (Configuración), M58 (Accesibilidad), M97 (Steam Page), M41-M44 (Audio final) |
| M142 RC | M141 | M62 (Memoria), M122 (Crash Reporting), M104 (Analytics), M82 (Performance si existe) |
| M143 Lanzamiento | M142 | M97 (publicación), M131 (Créditos), M78/M80 (Legal), M118 (CI/CD si aplica) |

## 4. Prioridades (visión global por fase)

| Prioridad | M137 | M138 | M139 | M140 | M141 | M142 | M143 |
|-----------|------|------|------|------|------|------|------|
| Must | Riesgo técnico | Slice jugable | Loop completo | Contenido v1.0 | Estabilidad | Calidad release | Publicación |
| Should | — | NPC/música | Día/noche, fauna | Pulido UX/UI | Equilibrio, audio | Último pulido | Post-lanzamiento |
| Could | — | Extras no críticos | Amistad/diálogos | Museos | Contenido extra | — | Contenido extra |
| Won't (en esta fase) | Todo lo no voxel | Sistemas profundos | Templos/Historia completa | Features nuevas | Features nuevas | Features nuevas | — |

Regla de corte: si una fase corre riesgo de deslizarse, lo primero que se mueve de fase es lo Could, luego Should. Los Must solo se mueven con renegociación documentada (RF11).

## 5. Calendario Estimado (rangos, decisión final del fundador)

> Los valores son rangos orientativos para un desarrollador solo a tiempo parcial o completo. Se recalibran con los datos reales del prototipo (M137). No son contrato.

| Fase | Hito | Duración estimada | Acumulado estimado |
|------|------|-------------------|--------------------|
| Fase 1 | M137 Prototipo | 4-8 semanas | 4-8 semanas |
| Fase 2 | M138 Vertical Slice | 8-14 semanas | 12-22 semanas |
| Fase 3 | M139 Pre-Alpha | 12-20 semanas | 24-42 semanas |
| Fase 4 | M140 Alpha | 12-20 semanas | 36-62 semanas |
| Fase 5 | M141 Beta | 8-12 semanas | 44-74 semanas |
| Fase 6 | M142 RC | 4-8 semanas | 48-82 semanas |
| Fase 7 | M143 Lanzamiento | 2-6 semanas | 50-88 semanas |

Reglas del calendario:

- Las duraciones se ajustan a la disponibilidad real del fundador (tiempo parcial ≈ extremo alto del rango).
- El primer punto de recalibración obligatorio es el cierre del prototipo M137.
- Si un hito supera el extremo alto del rango, se aplica la replanificación de la sección 7 y se informa a M133/M135.

## 6. Política de Builds y Releases

| Fase | Etiqueta git | Nombre del build | Destino |
|------|--------------|------------------|---------|
| M137 | `prototype-1` | Prototipo | Uso interno (fundador + agentes) |
| M138 | `slice-1` | Vertical slice | Playtest interno (M114) + comunidad cercana |
| M139 | `prealpha-1` | Pre-Alpha | Playtest ampliado |
| M140 | `alpha-1` | Alpha | Testers seleccionados |
| M141 | `beta-1` | Beta | Comunidad + wishlist campaign (M97) |
| M142 | `rc-1` | RC | Prueba final de producción |
| M143 | `v1.0.0` | 1.0 | Público |

Estrategia EA vs full release: la beta (M141) decide con datos (wishlists, feedback de playtests, estado del build). Ambas puertas permanecen abiertas hasta entonces (ver 02-Analisis.md, sección 1.5).

## 7. Procesos del Roadmap

### 7.1 Replanificación por retraso (RF10)

1. Detectar el retraso (criterio de salida sin cumplir al límite del rango).
2. Diagnosticar causa (riesgo de M135 materializado, alcance, recurso).
3. Aplicar corte: mover Could → siguiente fase; luego Should.
4. Si aun así no se cumple: deslizar la fecha del hito con justificación documentada.
5. Recalcular el calendario acumulado y comunicar a M133/M135.

### 7.2 Corte de alcance (RF11)

1. Todo módulo de la fase tiene MoSCoW asignado.
2. Para mover un Must: renegociación documentada (ADR breve en `04-Codigo.md` de M133 o log del módulo).
3. Para mover un Should/Could: decisión del fundador o del agente con log.
4. Nunca cerrar un hito con un Must incumplido marcándolo como completado.

### 7.3 Dependencia fallida (RF12)

1. Verificar si el módulo dependiente tiene alternativa (otra librería, otro enfoque, otro orden).
2. Si existe: adoptar con evaluación de riesgo (M135).
3. Si no existe: mover el hito dependiente hacia adelante en el calendario; actualizar dependencias en `CHECKLIST-GLOBAL.md`.

## 8. Arquitectura de Archivos del Módulo

```
DOCUMENTACION/136-Roadmap/
├── plan-inicial/                     ← Documentación original (inmutable)
├── plan-actual/                      ← Documentación vigente (espejo)
│   ├── 01-Requerimientos.md
│   ├── 02-Analisis.md
│   ├── 03-Diseno.md
│   ├── 04-Codigo.md
│   ├── 05-Checklist.md
│   └── ROADMAP.md                    ← PENDIENTE DE IMPLEMENTACIÓN (hoja de ruta ejecutiva)
└── hitos/                            ← PENDIENTE DE IMPLEMENTACIÓN
    ├── 137-prototipo-checklist.md    ← Checklist de criterios del hito M137
    ├── 138-vertical-slice-checklist.md
    ├── 139-prealpha-checklist.md
    ├── 140-alpha-checklist.md
    ├── 141-beta-checklist.md
    ├── 142-rc-checklist.md
    └── 143-lanzamiento-checklist.md
```

## 9. Contratos de Integración

### Entrada (desde otros módulos)

- **M133 (Gestión del Proyecto):** ciclo de planificación, DoD, plantilla de hitos y flujo multiagente.
- **M135 (Riesgos del Proyecto):** riesgos que amenazan hitos y mitigaciones a ubicar en el tiempo.
- **M01/M02 (Fundamentos/Visión):** la visión define qué es Must/Should/Could del juego completo.

### Salida (hacia otros módulos)

- **M137-M143 (módulos de hitos):** marco de fases, criterios de entrada/salida, calendario y dependencias como plantilla de su contenido.
- **M133 (Gestión):** estado de hitos y fechas estimadas para ceremonias y reportes.
- **M135 (Riesgos):** deslizamientos y cortes que constituyen riesgos o cambios de riesgo.
- **`CHECKLIST-GLOBAL.md`:** fila 136 actualizada (progreso, notas) conforme avanza el roadmap.