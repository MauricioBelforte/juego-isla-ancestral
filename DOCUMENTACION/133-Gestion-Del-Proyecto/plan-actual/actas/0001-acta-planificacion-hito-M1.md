# Acta 0001 — Planificación de Hito M1 (Prototipo técnico) — PLANTILLA CON EJEMPLO
**Fecha del documento:** 2026-08-28 · **Tipo:** Plantilla + ejemplo de redacción
**Nota de honestidad:** esta acta documenta el estado de planificación del Hito M1 a 2026-08-28 con la información de `CHECKLIST-GLOBAL.md` y la guía 08. La **ceremonia formal** de planificación (con el fundador y fechas objetivo) aún no se ejecuta; cuando se haga, se genera el acta definitiva con este formato.

**Modelo:** GLM
**Plataforma:** Kilo

---

## Formato estándar de acta (plantilla)

```markdown
# Acta {YYYY-MM-DD} — {Ceremonia}
**Presentes:** {quién} · **Duración:** {min}

## Temas
1. {Tema} → {acuerdo/decisión}

## Decisiones
- {Decisión con responsable y fecha límite}

## Pendientes
- {Ítem que queda abierto}

**Firma:** {Modelo} / {Plataforma}
```

---

## Ejemplo de redacción: planificación del Hito M1

# Acta 2026-08-28 — Planificación de Hito M1 (Prototipo técnico, M137)
**Presentes:** GLM (Kilo), en base al estado documentado de la tabla global · **Duración:** n/a (elaboración documental)

## Temas
1. Estado de la puerta F3 → M11/M12 ✅; M13 🔵 (raycast + extracción/colocación integrados, falta feedback/HUD/sonidos); M14 🔵 (núcleo de datos, 68/140); M15 y M59 bloqueados por dependencias.
2. Alcance del hito M1 → cavar/colocar + inventario + recurso + save/load + GO/NO-GO (ver ejemplo completo en `guia-hitos.md` §4).
3. Riesgos heredados → voxel sin soporte web (validación solo desktop); colgados >24 h detectados por script.

## Decisiones
- La ceremonia formal de planificación de M1 queda **pendiente del fundador** (fechas objetivo y capacidad) → responsable: fundador con M136.
- Mientras tanto, los agentes continúan por la regla de orden de la guía 08 (primer módulo pendiente de la primera fase habilitada).

## Pendientes
- Cerrar F3 con M13 (feedback visual/sonoro, HUD durabilidad).
- Terminar núcleo M14 y desbloquear M15/M59.
- Fijar fechas objetivo del hito M1 con M136.
- Confirmar ADR-0002 (herramienta de tablero).

**Firma:** GLM / Kilo
