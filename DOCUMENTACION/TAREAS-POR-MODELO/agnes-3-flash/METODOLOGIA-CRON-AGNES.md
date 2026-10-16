# Metodología Cron agnes-3-flash (2026-10-15)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 07:56
**Fuente:** directiva del usuario — guardar formato del cron para reutilizar al día siguiente.

## Estructura del cron

- **Frecuencia:** */5 (cada 5 minutos)
- **Regla operativa:** El director primero; si no hay director, NO decir "sin mensajes" — trabajar en la tarea del fundador (anti-drift docs).
- **Prompt:**
```
[OJEAR-5min agnes] (1) Leer .ultima-revision-agnes.txt → último número.
(2) Ojear canal para mensajes nuevos > ese número.
Si hay mensaje nuevo → leer y ejecutar, actualizar .ultima-revision.
Si NO hay mensaje nuevo → TAREA REPETITIVA: barrido anti-drift documentación.
Elegir un módulo de DOCUMENTACION/ (rotar por orden numérico), comparar su
04-Codigo.md y 03-Diseno.md contra scripts/ (grep de nombres de clases/scripts
citados). Si hay drift → reportar. Si no → "drift 0". 1 módulo por turno.
REGLA: todo encargo terminado DEBE tener reporte en mi canal. Parar solo si USUARIO dice.
```

## Tarea repetitiva en tiempo libre (anti-drift docs)

**Objetivo:** detectar si la documentación (plan-actual) está desincronizada con el código real.

**Método por módulo (1 por turno):**
1. Elegir módulo `DOCUMENTACION/{NN}-{Nombre}/plan-actual/` (rotar por orden: M01, M02, M03...)
2. Leer `04-Codigo.md` → extraer nombres de scripts/clases citados (p. ej. `house_manager`, `DataStore`, `memory_monitor`)
3. Grep cada nombre contra `game/isla-ancestral/scripts/` (y `scenes/`, `tests/` si aplica)
4. Si 0 hits → **drift detectado** (el doc cita algo que no existe en código)
5. Si hits → OK
6. Reportar: "M{NN}: drift 0" o "M{NN}: drift N (ítems: ...)"

**Reglas:**
- NO tocar `plan-inicial/` (inmutable)
- NO flipear ni degradar items sin permiso del director
- Si el director tiene mensaje → priorizar al director, posponer el barrido
- 1 módulo por turno (5 min) → 12 módulos/hora → 24h para los 168 módulos
- Escribir reporte en `Mensajes entre modelos/agnes-3-flash/` cada N módulos

## Archivos clave

- `Mensajes entre modelos/agnes-3-flash/.ultima-revision-agnes.txt` — último msg procesado
- `Mensajes entre modelos/agnes-3-flash/NUMEROS_DISPONIBLES.txt` — pool de números
- `CHECKLIST-GLOBAL.md` — tabla de módulos (referencia para rotar)
- `DOCUMENTACION/{NN}-{Nombre}/plan-actual/04-Codigo.md` — doc a verificar
- `DOCUMENTACION/{NN}-{Nombre}/plan-actual/03-Diseno.md` — doc a verificar
- `game/isla-ancestral/scripts/` — código real (fuente de verdad)

## Criterios de veredicto

| Hallazgo | Acción |
|----------|--------|
| 0 drift en 5+ módulos consecutivos | Reportar "barrido limpio" al director |
| Drift > 3 ítems en 1 módulo | Reportar inmediatamente + proponer corrección |
| Módulo sin 04-Codigo.md | Reportar como gap documental |
| Doc cita script que no existe | Drift → anotar en reporte |
| Doc NO cita script que SÍ existe | No es drift (la doc no es exhaustiva) |

## Cómo reactivar mañana

1. `cron_create` con `*/5 * * * *` y el prompt de arriba
2. Verificar `.ultima-revision-agnes.txt` está actualizado
3. Iniciar rotación de módulos desde el último M{NN} verificado
