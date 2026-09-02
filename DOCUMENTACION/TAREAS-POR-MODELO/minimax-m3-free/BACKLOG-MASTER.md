**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

# BACKLOG MASTER — minimax-m3-free

> Metodologia TAREAS-POR-MODELO (ver GUIA-METODOLOGIA.md). Total de tareas iniciales: **305** en 4 modulos. Modelo data-driven V0 complejidad 1-3, sin vision.

## Identidad

**minimax-m3-free** sobre **Kilo Code** (autoevaluacion en DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md §6).

## Perfil (resumen)

- **Fuerte #1**: Autoloads de orquestacion data-driven con duck-typing
- **Fuerte #2**: Catalogos JSON con fallback in-code
- **Fuerte #3**: Tests headless Godot 4 con auto-correccion rapida (1-3 iteraciones)
- **Fuerte #4**: Integraciones non-breaking entre modulos
- **Fuerte #5**: Cierre documental honesto (reparar CHECKLIST, firmar plan-actual)
- **NO hace**: vision 3D (Hy4), Blender (Hy4), QA visual (Hy3), diseno UX/UI (Hy4), shaders (Qwen 3.8), complejidad 5 sin data-driven

## Modulos asignados (4)

| ID | Modulo | Tareas asignadas | Prioridad | Recom original | Justificacion |
|---|---|---|---|---|---|
| 118 | 118-CI-CD | 100 | Alta | DeepSeek | Datos/scripts, sin vision, multi-archivo |
| 131 | 131-Creditos | 100 | Media | agnes-2.5-flash | Editorial + data-driven simple |
| 127 | 127-Copyright-Del-Juego | 101 | Baja | agnes-2.5-flash | Editorial simple, sin vision |
| 144 | 144-Despues-Del-Lanzamiento | 105 | Media | agnes-2.5-flash | Data-driven + post-lanzamiento |

**Total: 305 tareas** (cumple el minimo de 100 de la metodologia, con margen).

## Reglas de prioridad

1. **M118 CI-CD** primero (prioridad Alta + utilidad para todos los modulos).
2. **M131 Creditos** segundo (completar el juego para el jugador final).
3. **M127 Copyright** tercero (legal simple, baja complejidad).
4. **M144 Despues-Del-Lanzamiento** cuarto (post-release, no urgente).

## Convenciones de marcado

- `[ ] T-###` -> pendiente
- `[x] T-###` -> completado (con evidencia: log + test)
- `[?] T-###` -> no resuelto (con dueno explicito)
- `[→] T-###` -> movido a otro modelo (con nota)

## Estado de la iter

- 2026-09-02: carpeta creada. 4 modulos asignados. Sin trabajo iniciado todavia.
- 2026-09-01 (pre-metodologia): implemente 8 modulos en sesiones previas (M35/M70/M36/M65/M73/M14 iter 4-5/M115/M96). Ver Logs/ para evidencia.

## Próximo paso

Iter 1: tomar **M118 CI-CD**, reservar en 4 registros, implementar el nucleo data-driven (pipelines de build + tests automatizados + hooks de git), test headless 0 fallos, log, liberar, continuar con el siguiente.

**Nota sobre el conteo "0 pendientes" en 05-Checklist.md**: los planes estan al 100% de items `[x]` por diseno, pero la implementacion real esta pendiente. Mis tareas reales son implementar los modulos siguiendo el plan, no cerrar items de diseno. Por eso la metodologia me asigna 4 modulos con check de 100+ items cada uno: ese conteo refleja el plan completo a implementar/iterar.

## Estado de iter (2026-09-02)

- **M118 CI-CD iter 1**: 4 scripts Python en tools/ci/ (pipeline.py + build_dev.py + build_release.py + run_tests.py + lint_check.py). 17 items del checklist personal cerrados. log 541.
- **M131 Creditos iter 2**: credits_manager autoload + creditos.json 7 secciones + i18n es/en. test 26/26 OK. log 542.
- **M127 Copyright iter 1**: tools/legal/generate_copyright_docs.py + copyright.json ampliado a 7 elementos. test 13/13 OK. log 543.
- **M144 Post-Lanzamiento iter 1**: tools/postlaunch/generate_postlaunch_checklist.py + postlaunch_checks.json 30 checks en 9 categorias. test 14/14 OK. log 544.

## Pendientes por iter futura

- **M118 CI-CD iter 2**: implementar GitHub Actions workflows, M111 Code Quality integration, cobertura de tests.
- **M131 Creditos iter 2**: busqueda por nombre/rol, animaciones de scroll, accesibilidad (M58).
- **M127 Copyright iter 2**: registro formal USCO, evidencia de autoria (git logs, timestamps).
- **M144 Post-Lanzamiento iter 2**: automatizar reportes, alertas, dashboard con tendencias.

## Reglas de trabajo

1. Cada modulo: reserva en 4 registros -> implementar -> test 0 fallos -> log -> liberar.
2. Documentar honestamente lo que NO hago (con [?] y dueno explicito).
3. NO pisar a otros agentes. NO modificar codigo de otros modulos sin coordinacion.
4. Persistencia M59: cada nuevo autoload implementa get_section_name/get_save_data/restore_save_data.
