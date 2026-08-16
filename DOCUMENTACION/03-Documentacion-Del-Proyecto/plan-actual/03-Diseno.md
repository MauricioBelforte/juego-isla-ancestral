**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 02: Documentación del Proyecto

## 1. Propósito

Definir y formalizar el **sistema documental** del proyecto: catálogo, convenciones, estructura, estándares, versionado, tareas, prioridades, milestones, roadmap y backlog. Es el "documento de documentos" que garantiza trazabilidad de los 152 módulos.

## 2. Catálogo de Documentos (con dueño)

| Documento | Estado | Módulo dueño del contenido |
|---|---|---|
| GDD principal | ✅ `IDEA-BASE-DEL-JUEGO.md` | — (immutable, raíz 00) |
| Narrativa | ✅ `HISTORIA-DEL-JUEGO.md` | — (immutable, raíz 00) |
| Mundo | Datos en GDD/Biblia | Mundo Voxel (08) · Terreno (09) |
| Personajes | Arquetipos en biblia | NPC y Vecinos (19) |
| Misiones | Viaje del jugador en GDD§4 | Historia Principal (22) · Secundarias (23) |
| Sistemas | Desglose GDD§3 | Cada módulo dueño |
| Técnico | — | Arquitectura General (07) · Game Engine (04) |
| Arte | — | Arte 3D (45) · Estilo visual |
| Audio | — | Música (41) · Sonido (42) · SFX (43) |
| UI/UX | — | UI/UX (53) |
| Economía | GDD§3B | Economía (38) |
| Progresión | Sellos/Boletos GDD | Progresión (71) |
| Monetización | Opciones Plan-prod §14 | Publicación (decisión de negocio) |
| Legal | — | Legal-PI (78) ← incluye verificación del nombre |
| QA | Protocolo AGENTS§14 | QA/Testing |
| Publicación | — | Publicación |
| Convenciones | ✅ este documento §3 | M02 |
| Estructura carpetas | ✅ este documento §4 | M02 |
| Estándar documentación | ✅ este documento §5 | M02 |
| Versionado de documentos | ✅ este documento §6 | M02 |
| Sistema de tareas | ✅ este documento §7 | M02 |
| Prioridades | ✅ este documento §7 | M02 |
| Milestones | ✅ este documento §8 | M02 |
| Roadmap | ✅ este documento §8 | M02 |
| Backlog inicial | ✅ Plan-inicial-minimo.md (152) | M02 |

## 3. Convenciones de Nombres

| Elemento | Regla | Ejemplo |
|---|---|---|
| Componentes | `DOCUMENTACION/{NN}-Nombre-En-Formato-Titulo/` | `02-Vision-Y-Concepto` |
| Archivos por plan | `NN-Nombre.md` con prefijo numérico | `03-Diseno.md` |
| Logs | `{NN}-descripcion_YYYY-MM-DD_HH-MM-SS.md` | `05-CREACION_COMPONENTE_02-VISION_2026-08-15_23-45-00.md` |
| Obsoletos | `YYYY-MM-DD_HH-MM-SS_nombre.ext` | `2026-08-15_22-43-51_AGENTS.md` |
| Código (Unity futuro) | Namespaces `IslaAncestral.*`, PascalCase clases/métodos, `_campo` privados | (AGENTS.md §24) |
| Estados | `[ ]`/`[x]`/`[?]` + `[S]/[M]/[C]` | `- [x] Definir pitch [S]` |
| Firmas | `**Modelo:** …` / `**Plataforma:** …` al inicio | — |
| Idioma | Español en todo el repo (nombres de módulos incluidos) | — |

## 4. Estructura de Carpetas (formalizada)

```
raiz/
├── AGENTS.md · README.md · CHECKLIST-GLOBAL.md · .gitignore
├── DOCUMENTACION/
│   ├── 1..5-*-ACTUAL.md (5 documentos generales vigentes)
│   ├── README.md (índice del sistema)
│   ├── 00-PLAN-INICIAL/ (origen, NO MODIFICAR)
│   ├── NN-Componente/plan-inicial/ + plan-actual/
│   └── INVESTIGACION SOBRE OTROS JUEGOS/
├── Logs/ (+ rotated/ + ULTIMO_NUMERO.txt)
├── Obsoletos/
├── scripts/ (kit del protocolo; backups/ no versionado)
└── (futuro Assets/, Builds/ — Unity, fuera de DOCUMENTACION)
```

## 5. Estándar de Documentación (consolidado de AGENTS.md)

1. Documentación primero (AGENTS §13): antes de código, crear el componente.
2. 5 archivos obligatorios (01…05); 06/07 solo si el módulo amerita testing.
3. Checklist ≥100 ítems, verificables, con estados honestos.
4. `plan-inicial/` inmutable; `plan-actual/` es la verdad vigente; cambios se reflejan en ambos flujos.
5. Firmas de modelo/plataforma en todo documento generado/modificado.
6. Log por tarea terminada + actualización de `ULTIMO_NUMERO.txt`.
7. `Obsoletos/` para respaldo previo a cambios grandes.
8. Actualizar `1-5-*-ACTUAL.md` ante cambios significativos.
9. Cambios de estado global → CHECKLIST-GLOBAL (o recalcular con `scripts/`).

## 6. Control de Versiones de Documentos (git)

- Rama principal única (`main`); workflow: verificación de estado → cambios → commit en español (pasado descriptivo) → push (sección 4.2 del AGENTS.md).
- **plan-actual = documento vigente**: los archivos vigentes se actualizan en `plan-actual/`; se re-sincronizan desde la fuente cuando cambia el plan.
- Conteo de progreso verificado con `scripts/generar_checklist_global.py` y `scripts/verificar_checklist.py` (AGENTS §21.9) antes de tocar producción.
- Los commits describen el QUÉ y el PORQUÉ; el detalle técnico del cambio queda en `Logs/`.

## 7. Sistema de Tareas y Prioridades

- **Unidad de trabajo:** módulo (fila en CHECKLIST-GLOBAL) + subitems (05-Checklist del componente).
- **Prioridad:** 🔴 Alta / 🟡 Media / 🟢 Baja (columna del CHECKLIST-GLOBAL).
- **Complejidad:** 1-5 (habilita la asignación por capacidad del agente, AGENTS §21.1).
- **Ciclo por tarea:** bloquear → documentar → implementar → verificar (AGENTS §12) → actualizar checklist → actualizar global → log → liberar.
- **Anti-softlock documental:** todo módulo queda en estado honesto al finalizar el turno (nunca 🔵/🔴 huérfanos).
- Fase inicial sugerida: los 17 módulos de la Fase 1 funcional (arte/programación) → prioridad Alta.

## 8. Milestones y Roadmap

### Milestones (orden secuencial, sin fechas rígidas — equipo de 1 persona)

| Hito | Contenido | Salida verificable |
|---|---|---|
| M1 Prototipo voxel | Chunk + face culling + cámara + minería básica (M08/M09/M10/M12/M13) | 60 FPS sostenido; validación de stack |
| M2 Vertical Slice | 1 día completo en Aurora: bucle diario + 1 templo (emisor→receptor) + 2 vecinos | Partida de 45 min completa |
| M3 Alfa interna | Aurora completa + 1 isla (Coral) + 2 sellos (Brisa, Marea) | Historia v1.0 jugable hasta el cierre parcial |
| M4 Beta cerrada | Contenido v1.0 completo + QA + balanceo + accesibilidad | Playtest sin blockers |
| M5 v1.0 | Lanzamiento Steam (decidir EA vs directo cerca del hito) | Build publicable |
| Post | Roadmap narrativo del Gran Vapor | Actualizaciones: Cenizas → Cielo → Elysia → 4 finales |

### Criterios de avance entre hitos

- Un hito solo avanza al siguiente cuando su salida verificable existe y los módulos involucrados están `✅` o `🟡` con pendientes documentados.

## 9. Backlog Inicial (formalizado)

- **Fuente única:** `Plan-inicial-minimo.md` = 152 módulos + 600+ puntos de control.
- Desglose: cada módulo se convierte en componente (`DOCUMENTACION/{NN}-.../`) con checklist ≥100 ítems (15.200+ puntos verificables).
- El orden de ejecución lo dicta CHECKLIST-GLOBAL (prioridad + dependencias).

## 10. Documentos generales (esqueletos creados en este módulo)

| Archivo | Contenido que recibe |
|---|---|
| `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` | Especificaciones técnicas vigentes (motor, arquitectura, rendimiento, IO) |
| `2-DOCUMENTO-DISENO-ACTUAL.md` | Diseño detallado vigente (gameplay, mundo, sistemas) |
| `3-DOCUMENTO-TAREAS-ACTUAL.md` | Estado de tareas por fase |
| `4-DOCUMENTO-EJECUCION-ACTUAL.md` | Código de ejecución vigente, scripts clave, flujos |
| `5-FUTURAS-MEJORAS.md` | Directivas e ideas del usuario (nada propuesto por agentes) |

Todos: firma del último agente que los modifica; los módulos dueños los completan a medida que avanzan.