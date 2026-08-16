# Log 36 — Creación del Componente 57: Interfaz de Control (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 23:45:00

## Descripción breve

Se documentó el **Módulo 57 — Interfaz de Control** en `DOCUMENTACION/57-Interfaz-De-Control/` como módulo **delegable**. Unifica los esquemas de control (teclado, ratón, gamepad Xbox/PlayStation/genérico y Steam Deck) bajo una capa de acciones única remapeable: 22/22 puntos de la sección 56, prompts dinámicos por dispositivo, dead zones, vibración, y persistencia atómica en JSON.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 9 RF + NFR y 5 criterios de aceptación |
| `plan-inicial/02-Analisis.md` | 22/22 puntos resueltos; 3 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | Arquitectura InputLayer/PromptLayer, catálogo de acciones, remapeo, dead zones, Deck, persistencia, QA |
| `plan-inicial/04-Codigo.md` | Archivos, API, integración + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **119 ítems**, 119 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M57 → 🟢 Disponible, 119/119, marcado **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 57 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 36.

## Decisiones

- **Capa de acciones única** (nunca scancodes en gameplay): requisito para remapeo, prompts y accesibilidad (M58).
- **Prompts dinámicos por detección de evento reciente**: cambiar de teclado a mando actualiza la UI al instante, sin recargar.
- **Remapeo con detección de conflictos** y sugerencia de tecla libre; guardado inmediato y "restablecer valores".
- **Persistencia atómica** (`controls.tmp` → rename → `.bak`): corrupción imposible; recovery a defaults con aviso.
- **Vibración cónsona al cozy**: eventos suaves y cortos, intensidad configurable con OFF; nunca en diálogos.
- **Táctil NO en esta fase** (build PC/Deck): capa de acciones lista para un futuro build móvil; Steam Deck con perfil propio.