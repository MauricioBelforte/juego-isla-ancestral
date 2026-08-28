**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Implementación operativa (entregable M133)

---

# Guía de Hitos — Módulo 133

> Cada hito termina en **algo jugable** (principio anti-abandono D8). La duración y fechas objetivo son decisiones del fundador y se planifican con M136 (Roadmap); esta guía define la **estructura** y el **proceso** (RF5, RF8, RF15).

---

## 1. Los hitos del proyecto (M0-M5)

Fuente: `plan-actual/03-Diseno.md` §1.3. Cada hito se instancia con la plantilla de §3 y se archiva junto a esta guía o en el módulo coordinador del hito.

| Hito | Módulo(s) clave | Objetivo | Criterio de salida |
|------|-----------------|----------|--------------------|
| M0 — Base documental | M01-M06, M133 | Proceso y documentación base | 133 implementado, protocolo operativo, plantillas listas |
| M1 — Prototipo técnico | M137 (Prototipo) | Mundo voxel con cavar/colocar/guardar | M137 cumple DoD; jugable con los sistemas mínimos |
| M2 — Vertical slice | M138 (Vertical Slice) | Rebanada jugable de isla Aurora | Un área completa: mover, interactuar, un objetivo, guardado |
| M3 — Pre-alpha | M139 (Pre-Alpha) | Loop principal completo | Ciclo jugable de ~30 min con sistemas del GDD acotado |
| M4 — Alpha | M136 (Roadmap) | Contenido de v1.0 jugable | Todos los sistemas v1.0 integrados, sin bloques críticos |
| M5 — Beta / lanzamiento | M136 (Roadmap) | Estabilidad y pulido | Cero blockers, rendimiento en marco, build lista |

Regla de dependencias (RF15): no se abre un hito si el anterior no cumplió sus criterios de salida, salvo desviación justificada por ADR.

---

## 2. Reglas de un buen hito

1. **Termina jugable:** si el cierre no se puede probar jugando, no es un hito de este proyecto.
2. **Criterios de salida verificables:** cada criterio es un checkbox que se puede marcar `[x]` o `[?]`.
3. **Alcance cerrado:** la lista "fuera del alcance" es obligatoria para frenar el scope creep (RF8).
4. **Criterios de salida coordinados con el módulo dueño** (M137 para M1, M138 para M2…): este módulo define el marco, el módulo dueño define el detalle.
5. **Prueba de juego del fundador + retrospectiva** siempre cierran el hito (actas en `plan-actual/actas/`).

---

## 3. Plantilla de hito

> Copiar este bloque a un archivo nuevo (ej: `hito-M1-prototipo.md`) y completar. Los estados usan la simbología de la tabla global (⬜ 🟢 🔵 🟡 ✅).

```markdown
# Hito {N}: {Nombre}
**Fecha inicio:** ... · **Fecha objetivo:** ... · **Estado:** ⬜/🔵/🟡/✅

## Objetivo
{Una frase: qué se demuestra jugablemente al cerrar este hito}

## Alcance
- Módulos incluidos: {IDs y nombres}
- Fuera del alcance de este hito: {para evitar scope creep}

## Dependencias
- {Módulos que deben estar listos antes}

## Tareas (vinculadas al tablero)
1. {Tarea} → agente {X}
2. {Tarea} → agente {Y}

## Criterios de salida (cada uno verificable)
- [ ] {Criterio 1}
- [ ] {Criterio 2}
- [ ] Prueba de juego del fundador hecha
- [ ] Retrospectiva registrada en actas/

## Riesgos del hito
- {Riesgo} → mitigación
```

---

## 4. Ejemplo probado: Hito M1 — Prototipo técnico (M137)

> Ejemplo de redacción con el estado real del proyecto a 2026-08-28. Se actualiza al planificar formalmente el hito (ceremonia de planificación).

```markdown
# Hito M1: Prototipo técnico
**Fecha inicio:** por definir (fundador/M136) · **Fecha objetivo:** por definir · **Estado:** ⬜

## Objetivo
Demostrar jugablemente el bucle técnico mínimo: moverse en la isla voxel, extraer y
colocar bloques con una herramienta, y recuperar el estado tras guardar y cargar.

## Alcance
- Módulos incluidos: M13 (Herramientas), M14 (Inventario), M15 (Recursos),
  M59 (Guardado) y M137 (Prototipo, coordinador).
- Fuera del alcance de este hito: islas nuevas, tiendas, puzzles, NPCs con rutinas,
  assets finales, UI pulida (esos van a M2+).

## Dependencias
- M08/M09/M10/M11/M12 ✅ (completados 2026-08-26).
- M13 en curso (integración voxel); M14/M15/M59 detrás según tabla global.

## Tareas (vinculadas al tablero)
1. Cerrar F3: M13 conectado a bloques voxel reales → agente en curso (MiMo V2.5).
2. Inventario mínimo con slots → agente M14 (ox-alpha).
3. Un recurso recolectable con drop → agente M15.
4. Save/load del estado mínimo (posición + inventario) → agente M59.
5. Integración y playtest GO/NO-GO → M137 + fundador.

## Criterios de salida (cada uno verificable)
- [ ] Recoger un recurso y verlo en inventario.
- [ ] Guardar y cargar la posición del jugador.
- [ ] Extraer y colocar un bloque con la herramienta sobre terreno real.
- [ ] Captura de sesión completa con MCP (M154) adjuntada.
- [ ] Playtest registrado según M114.
- [ ] Decisión GO/NO-GO registrada en acta.
- [ ] Prueba de juego del fundador hecha.
- [ ] Retrospectiva registrada en actas/.

## Riesgos del hito
- Voxel sin soporte web (hallazgo 2026-08-25) → el hito se valida en desktop.
- Módulos 🔵 colgados >24 h → reclamar según regla 21.4.7 y replanificar tareas.
```

---

## 5. Cambio de alcance a mitad de hito (RF8)

1. Quien detecta la necesidad lo plantea en un hilo de `Mensajes entre modelos/` (o el fundador directamente).
2. Se evalúa: ¿bloquea el criterio de salida? ¿puede esperar al hito siguiente?
3. Si entra: se registra por **ADR** (contexto, decisión, consecuencias) y se actualiza la plantilla del hito (nueva tarea + nuevo riesgo si aplica).
4. Si no entra: se anota en M136 (backlog del hito siguiente) y se cierra el tema. Quedar en el medio está prohibido.
5. Todo cambio de alcance a mitad de hito se menciona en la retrospectiva.

---

## 6. Cierre del hito (checklist de cierre)

- [ ] Todos los criterios de salida marcados `[x]` (o el hito pasa a 🟡 con `[?]` documentados).
- [ ] Prueba de juego del fundador hecha y feedback registrado como issues.
- [ ] Retrospectiva con acta (incluye la variable "diversión").
- [ ] Reporte de avance actualizado (`plan-actual/reportes/`).
- [ ] Tabla global y tablero sincronizados; hito marcado ✅ solo tras QA cruzado aplicable.

**Firma del último agente que modificó esta guía:**

**Modelo:** GLM
**Plataforma:** Kilo
