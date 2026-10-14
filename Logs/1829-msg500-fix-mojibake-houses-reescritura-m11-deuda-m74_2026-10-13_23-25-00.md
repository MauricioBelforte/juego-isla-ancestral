# Log 1829: Msg 500 del director — fix mojibake houses + reescritura M11 (3 promos) + deuda duck-typing M74 documentada

**Fecha:** 2026-10-13
**Hora:** 23:25
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Tres encargos del director (msg 500, respuesta a mis informes 2029-2032 del cierre de los 10
bloques). Los tres cerrados y commiteados.

## 1. Fix de mojibake en houses — CERRADO (commit `ebd13ba`)

`fix_encoding.py` camina todo el repo y no acepta rutas, así que repliqué su lógica (Log 852) en un
script acotado a los 2 archivos autorizados, con backup previo y verificación posterior:

| Archivo | Marcadores | Resultado |
|---|---|---|
| `game/isla-ancestral/scripts/houses/house_interior.gd` | 6 (`Â¿`, `Ã³`, `Ã¡`, `Â§`) | 0 restantes |
| `game/isla-ancestral/scripts/houses/test_m18_sistemas_s2.gd` | 3 (`â€"` ×12 líneas) | 0 restantes |

Verificado: UTF-8 **sin BOM**, decodificación OK, **sin drift de líneas** (70 y 268),
contenido correcto (`¿La habitación está desbloqueada?`, `Añade`, `§3`, separadores `──`).
Backups eliminados tras verificar. Commit con pathspec explícito de los 2 archivos.

## 2. Reescritura de 3 ítems desactualizados de M11 — CERRADO (commit `0e0f521`)

Autorizado por el director. Cada ítem quedó `[x]` con la **cita explícita de la discrepancia**
(lo que pedía vs lo que hay):

1. **Velocidad de correr 6.5 m/s** — implementada como FACTOR (`player_core_m11.gd` L50
   `VELOCIDAD_CORRER=6.5` + `FACTOR_SPRINT`), no como absoluto (runtime usa `move_speed`, 25.0 DEV).
2. **InteractionService 4 m** — implementado con otro nombre: `interaction_manager.gd` (autoload M70)
   `DEFAULT_RANGO=2.5` + radio 1.5 = **4.0 m**, verificado por `test_interacciones.gd` L124.
3. **AnimationPlayer/clips** — `Player.tscn` L48 **sí** tiene AnimationPlayer + `jugador_lib.tres`
   con **3** clips (idle/walk/run); el ítem decía "NO existen" y pedía 10.

Totales M11 actualizados: **75 `[x]` / 0 `[ ]` / 48 `[?]`** = 123 (antes 72/0/51).

## 3. Deuda de duck-typing de M74 documentada para dueños — CERRADO (commit `863fb5b`)

El director pidió **no resolverla** (toca M20/M71/M37 de otros) sino documentarla como encargo.
Se insertó una fila en la sección 5 (Pendientes de implementación) de
`DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md` con: los 3 métodos faltantes
(`sumar_puntos`, `registrar_progreso_evento`, `registrar_recuerdo`), el efecto actual (amistad no se
entrega; progreso/colección hooks dormidos), los **dueños asignados** (M20/M71/M37), la verificación
contra disco del 2026-10-13 y la alternativa para M20 (API real `get_puntos()`/`aplicar_puntos()` vía
`VecinoAmistad`).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/houses/house_interior.gd` (mojibake; commit `ebd13ba`)
- `game/isla-ancestral/scripts/houses/test_m18_sistemas_s2.gd` (mojibake; commit `ebd13ba`)
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md` (3 reescrituras + Totales;
  commit `0e0f521`)
- `DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md` (deuda documentada; commit `863fb5b`)
- `Logs/1829-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1829 consumido)
- `scripts-prueba-temp/` (fix acotado de mojibake + scripts de reescritura)

## Nota operativa

El primer intento de commit de houses falló porque el shell de PowerShell interpretaba los
caracteres especiales del mensaje (`â`); se resolvió escribiendo el mensaje en un archivo temporal
UTF-8 y usando `git commit -F`. Lección registrada para próximos commits con texto no ASCII.
