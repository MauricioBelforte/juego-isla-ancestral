**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# Log 130 — Creación de M162: Diálogos Contextuales de NPCs

**Fecha:** 2026-08-23 19:50
**Hora:** 19:50
**Tipo:** Creación de módulo
**Módulo:** M162 — Diálogos Contextuales de NPCs

## Descripción

Se completó la documentación del Módulo 162: Diálogos Contextuales de NPCs. El módulo define cómo los 23 NPCs del juego cambian sus diálogos según el capítulo de la historia principal (M22), el nivel de amistad (M20), la estación del año, la hora del día y la ubicación del jugador.

## Archivos creados

### plan-inicial/ (5 archivos)
- `01-Requerimientos.md` — 66 líneas. Requisitos funcionales, estructura de capítulos, tipos de diálogo, criterios de aceptación.
- `02-Analisis.md` — Análisis de dominio, 3 alternativas evaluadas (estática, árbol, prioridad), integración con M21/M22/M19/M20/M29/M160, riesgos.
- `03-Diseno.md` — 1406 líneas. Diseño completo de diálogos de 23 NPCs por capítulo (0-7). Isla Raíz (8 NPCs), Isla Coral (5), Isla Ceniza (5), Isla Aurora (5). Tabla resumen de progresión. Formato JSON para M21. Variables de estado.
- `04-Codigo.md` — Archivos involucrados, funciones clave (DialogueManager, DialogueConditions, DialogueResource), estructura JSON, flujo de ejecución, conteo de ~400 diálogos totales.
- `05-Checklist.md` — 120 ítems distribuidos en: Estructura y Diseño (20), Isla Raíz (32), Isla Coral (20), Isla Ceniza (20), Isla Aurora (20), Integración y Testing (8).

### plan-actual/ (5 archivos — copia de plan-inicial)

## Decisiones clave

1. **Enfoque híbrido:** Base de diálogos por capítulo (lista plana) + sistema de prioridad para combinaciones amistad/estación/hora.
2. **23 NPCs documentados:** 8 RIZ + 5 COR + 5 CEN + 5 AUR.
3. **~400 diálogos totales:** Promedio de ~17 diálogos por NPC (8 capítulos × 2-3 tipos).
4. **Viajero Misterioso (NPC-AUR-005):** Arco narrativo propio que complementa M22 — revela identidad gradualmente.
5. **JSON compatible con M21:** Formato `DLG-[ISLA]-[NPC]-[CAP]-[TIPO]` con condiciones evaluables.
6. **Fallback:** Si no hay diálogo válido para el contexto actual, se usa diálogo genérico del capítulo.

## Integración

- **M21 (Diálogos):** M162 genera contenido JSON que M21 consume con su motor nodal.
- **M22 (Historia Principal):** Los diálogos reflejan eventos de los 7 capítulos sin contradecir la historia.
- **M19 (NPC y Vecinos):** Cada NPC mantiene su personalidad definida en M19.
- **M161 (Diseño Visual):** Referencia visual para mantener coherencia de personajes.
- **M20 (Amistad):** 3 niveles de amistad afectan diálogos (desconocido/conocido/amigo).
- **M29 (Tiempo):** Estaciones y hora del día generan variantes de diálogos.
- **M160 (Ubicaciones):** Algunos diálogos dependen de la ubicación del jugador.

## Actualizaciones

- `CHECKLIST-GLOBAL.md`: Se agregó fila M162, actualizado total a 162 módulos.
- `Logs/ULTIMO_NUMERO.txt`: Actualizado de 129 a 130.

## Próximos pasos

- Cuando el usuario quiera: expandir más módulos con mecánicas adicionales.
- Verificar que la documentación esté lista para fase de codificación.
