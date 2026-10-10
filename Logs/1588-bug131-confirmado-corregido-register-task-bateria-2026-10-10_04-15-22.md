# Log 1588: BUG-131 confirmado y corregido — register_task.ps1 arrancaba con bateria

**Fecha:** 2026-10-10
**Hora:** 04:15
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Encargo del director (msg 198): BUG-131 descubierto por Hy3 (msg 126) en
`scripts/backup/register_task.ps1` (M107-Backups). **Confirmado: el bug es
REAL.** El script seteaba `-AllowStartIfOnBatteries` y contradecia el diseno
§7 ("Iniciar solo si esta conectado a la alimentacion de CA"). **Fix
aplicado** (sin commit, reglas del encargo).

## Cambios Realizados
- `scripts/backup/register_task.ps1`: quitado `-AllowStartIfOnBatteries` de la
  linea de `New-ScheduledTaskSettingsSet` + header reescrito con las
  condiciones reales y la nota del BUG-131.
- **Sin commit** (regla del director: READ-ONLY sobre marcas, sin commits).
- **Sin tocar marcas** del checklist de M107.

## Verificacion tecnica (la que pidio el director)

### El bug era real — tu hipotesis del default era incorrecta
Supusiste que "probablemente ya este correcto" porque el default de
`-AllowStartIfOnBatteries` es no-seteado. El problema: **el script lo seteaba
EXPLICITAMENTE** (L65), asi que el default no aplicaba.

`Get-Command New-ScheduledTaskSettingsSet` en PS 5.1 **NO tiene**
`-StartOnlyIfOnACPower` ni `-DisallowStartIfOnBatteries` como parametro: los
unicos relacionados son `AllowStartIfOnBatteries` y `DontStopIfGoingOnBatteries`.

### Evidencia medida con los dos settings

| Config | `DisallowStartIfOnBatteries` | `StopIfGoingOnBatteries` | Significado |
|---|---|---|---|
| **HEAD** (con `-AllowStartIfOnBatteries`) | **False** | False | la tarea **SI arranca** con bateria — viola §7 |
| **FIX** (sin el parametro) | **True** | False | la tarea **NO arranca** con bateria — cumple §7 |

Mapeo interno de PS: el switch `-AllowStartIfOnBatteries` pone
`DisallowStartIfOnBatteries = false`; sin el, el default es `true`.

### Diseno §7 (03-Diseno.md L244-245)
```
- **Condiciones:**
  - "Iniciar solo si el equipo está conectado a la red de CA"
  - "Iniciar solo si está conectado a la alimentación de CA"
```
HEAD violaba ambas lineas; el fix las cumple.

### Header del script — tambien mentia
El header (L10) afirmaba "Solo con alimentación de CA" mientras el codigo
hacia lo contrario. **Reescrito** con las condiciones reales + nota del
BUG-131.

## Decisiones
- **Quitar el parametro, no anadir uno nuevo:** no existe
  `-DisallowStartIfOnBatteries` en el cmdlet (solo es propiedad interna del
  XML). La forma canonica de "solo CA" es omitir `-AllowStartIfOnBatteries`.
- **Mantener `-DontStopIfGoingOnBatteries`:** correcto para integridad — si el
  equipo se pasa a bateria a mitad de un respaldo, mejor terminarlo que
  dejarlo corrupto a medias. El §7 habla de *iniciar*, no de detener.
  `StopIfGoingOnBatteries = False` verificado en ambos configs.

### Hallazgo secundario (fuera del encargo)
El diseno §7 L246 pide **"Despertar el equipo para ejecutar esta tarea"**
(WakeToRun activado), pero el script NO lo setea y su header dice
"WakeToRun desactivado". **Otra contradiccion diseño-codigo**, en sentido
opuesto. **No la toque** (fuera del alcance del BUG-131) — decide el
director.

## Veredicto
**BUG-131: CONFIRMADO y CORREGIDO.** La tarea programada de backup ahora
arranca solo con red CA, como exige §7. **Queda en manos del director** el
flip de la marca de M107 y el commit (reglas del encargo).

## Archivos Modificados/Creados
- `scripts/backup/register_task.ps1` — fix + header (sin commit)
- `Logs/1588-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/199-...md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1588 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 199 consumido
