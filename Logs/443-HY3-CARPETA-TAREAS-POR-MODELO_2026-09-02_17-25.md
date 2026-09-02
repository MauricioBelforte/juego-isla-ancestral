# Log 443: Hy3 — Creación de carpeta de tareas por modelo (metodología TAREAS-POR-MODELO)

**Fecha:** 2026-09-02
**Hora:** 17:25
**Modelo:** Hy3
**Plataforma:** Kilo Code

## Resumen
Se creó la carpeta personal de tareas del modelo **Hy3** según la metodología `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. La carpeta agrupa las tareas granulares extraídas de los `05-Checklist.md` de los módulos en el alcance de Hy3 (QA cruzado, validación entre modelos, y sistemas de diálogo/narrativa).

## Alcance de Hy3 (identidad en `10-GUIA-COMPARATIVA-MODELOS.md` §5.D y §11)
- QA cruzado (AGENTS.md §21.8) de los módulos ya verificados: M133-M136, M145-M146, M149, M153.
- Diálogos y narrativa: M21 (núcleo implementado por Hy3, iter 8), M22, M23, M24, M148, M150.
- QA cruzado de sistemas data-driven: M29, M35, M39.
- Diálogos contextuales de NPCs (M162) — incluye la alerta 🔴 del selector de diálogos pendiente de fix.

## Cambios realizados
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` — índice con 916 tareas en 14 módulos (mínimo 100 ✅).
- 14 archivos `checklist.md` por módulo con ítems `[ ] T-###` extraídos de los `[ ]`/`[?]` de cada `05-Checklist.md` (fuente de verdad).
- Módulos M133-M136 registrados como "QA cruzado completo (0 pendientes)".
- Extracción automatizada con script Python (UTF-8) `generar_hy3_backlog.py` para garantizar IDs secuenciales y trazabilidad.

## Conteo por módulo
| Módulo | Tareas |
|--------|--------|
| 39-Tiendas | 157 |
| 24-Templos-Y-Puzzles | 122 |
| 148-Lore-Ambiental | 102 |
| 35-Mineria | 83 |
| 23-Historias-Secundarias | 82 |
| 150-Diseo-Sonoro-Narrativo | 81 |
| 39 / 35 ... | (ver BACKLOG-MASTER) |
| 21-Dialogos | 61 |
| 162-Dialogos-Contextuales-De-NPCs | 62 |
| 22-Historia-Principal | 63 |
| 29-Tiempo-Y-Calendario | 65 |
| 145-Diseno-De-Experiencia | 15 |
| 146-Diseno-Emocional | 10 |
| 149-Nombres-Y-Nomenclatura | 3 |
| 153-Objetivo-Final | 10 |
| **Total** | **916** |

## Reglas aplicadas
- Al completar T-### se marcará también el `05-Checklist.md` del módulo y la fila de CHECKLIST-GLOBAL (tres lugares sincronizados).
- Ciclo de trabajo: tomar siguiente tarea → reservar log → verificar → test headless 0 fallos → documentar → liberar.

## Archivos creados
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/<ID-Modulo>/checklist.md` (14 archivos)
