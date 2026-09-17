# Log 975 — DeepSeek-V4.1-Flash — Restauración de huérfanos de `Logs/`, renumeración y citas

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-17
**Alcance:** higiene de `Logs/` — trampas 64/66/67/69/70
**Predecesor:** `Logs/952-DeepSeek-Auditoria-Referencias-Logs-Preservacion-Huerfanos_2026-09-17.md`
**Instrucción del dueño:** *"bueno te encargo todo eso arregla los problemas"*

---

## 1. Qué se pidió

El ciclo anterior (Log 952) dejó una lista de problemas **"pendiente de decisión del
dueño"**. En este turno el dueño la delegó explícitamente. La lista era:

1. Los 7 números de log vacíos (`723, 792, 800, 801, 802, 803, 805`) citados por
   código de juego y guías vivas.
2. Las 17 citas vivas a esos números.
3. M115 citando `Logs/308, 320, 327` (308 no existe; 320 es de M30).
4. La colisión `Logs/949-QA-M08` (Atria) vs `949-Hy3-M87`.
5. El gap del protocolo de reservas de logs.
6. Los 9 scripts `.py` versionados dentro de `Logs/reservas/`.

---

## 2. Qué se hizo

### 2.1 Restauración de los 25 huérfanos

Se movieron los **25 archivos huérfanos** de la cuarentena
(`PAPELERA/logs-recuperados-2026-09-16/`) a `Logs/`:

- **7 recuperan su número original** (estaba vacío): `723, 792, 800, 801, 802, 803, 805`.
- **18 se renumeran** a slots libres `956`–`973` porque su número original está
  ocupado por un log **distinto** (colisión silenciosa).
- El duplicado **byte-idéntico** `152-…AAAA-MM-DD_HH-MM-SS.md` se descartó (el log
  vivo es `Logs/152-…_2026-08-25_00-00-00.md`).

**Desempate aplicado:** quien primero usó el número lo conserva; el otro se renumera.
Para los 7 números vacíos no hay desempate → el huérfano recupera su número.

Mapa completo: **`PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`**.

Cada log renumerado lleva una **nota de procedencia** de 4 líneas bajo el título
("Recuperado 2026-09-17 … Se renumeró de Log X a Log Y …").

> **Desvío consciente de convención:** los renumerados previos del dedup
> (`838`, `891`, `894`) **conservaron el título viejo** (p. ej. `838-…` dice "Log 770").
> En este lote se **reescribió el título al número nuevo** a propósito: dejar el
> título viejo reproduce exactamente la colisión silenciosa de la trampa 67 (dos
> logs diciendo "Log 801"). La trazabilidad la da la nota de procedencia + el mapa.

### 2.2 Colisión de título en `Logs/792`

`792-M09-PARED-VERDE-SUELO-FANTASMA-AGUA_…` tenía como título `# Log 797: …`, que
**colisiona** con el log real y distinto
`Logs/797-M09-VERIFICACION-IMPOSTOR-PASO64_2026-09-08_08-25-00.md`.
Como el nombre del archivo es la identidad y el código lo cita como "Log 792"
(`terreno_horizonte.gd:255`), se corrigió el título a `# Log 792:` + nota de
procedencia.

### 2.3 Colisión 949/950 (Atria vs Hy3)

Dos logs de **atria-dawn** reusaron números ya tomados por **Hy3** (escritos 02:41;
los de Atria son de 05:38 y 08:32 → llegaron después):

| Antes | Después | Colisionaba con |
|---|---|---|
| `Logs/949-QA-M08-Mundo-Voxel_2026-09-17_05-38.md` | `Logs/976-…` | `Logs/949-Hy3-M87.md` |
| `Logs/950-QA-M11-Personaje_2026-09-17_08-32.md` | `Logs/977-…` | `Logs/950-Hy3-M127.md` |

Los de **Hy3 conservan 949/950** (son los citados por `CHECKLIST-QA-SEALS.md` y
`Hy3/BACKLOG-MASTER.md`). Se actualizaron **5 sitios de cita**: `CHECKLIST-GLOBAL.md`
(×2), `08-Mundo-Voxel/plan-actual/04-Codigo.md` (×2), `11-Personaje-Del-Jugador/plan-actual/05-Checklist.md`
y las **rutas completas** en `Mensajes entre modelos/ESTADO-PARALELO.md`.

### 2.3b Dos colisiones más (875 y 932), detectadas por el guardián nuevo

Al escribir el guardián de reservas (§2.6) aparecieron **2 colisiones pre-existentes**
más, fuera de la cuarentena:

| Antes | Después | Colisionaba con (el que llegó primero) |
|---|---|---|
| `Logs/875-AUDITORIA-AGNES-REVERT-28-MODULOS_2026-09-14.md` (2026-09-14 04:45) | `Logs/978-…` | `Logs/875-WorkBuddy-Docs-Versionado-Y-Politica.md` (2026-09-13 17:29) |
| `Logs/932-Verificacion-8-Modulos-Item-Por-Item_2026-09-16.md` (2026-09-16 18:00) | `Logs/979-…` | `Logs/932-M52-VFX-QA-Visual-V2-asistencia_…` (2026-09-16 08:10) |

En ambos casos se renumeró **el que llegó después**, y **coincidió con el no citado**
→ **no hubo que tocar ninguna cita** (verificado por `grep`).

### 2.4 Citas actualizadas

Detalle exhaustivo en `MAPA-RENUMERACION.md` §"Citas actualizadas". Resumen:

- `GUIA-GODOT/16-zoom-camara-personaje.md`: Log 803 → **958** (el fix del minimapa).
- `CHECKLIST-GLOBAL.md`: M10 `722→961` (×2), M12 `724→962`, M33 `761→963`,
  M33 `790→965`, atria `949→976`, `950→977`.
- `10-Generacion-Del-Mundo/plan-actual/05-Checklist.md`: `722→961`.
- `atria-dawn/BACKLOG-MASTER.md`: `722→961` (×3), `724→962`.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: `722→961`, `949→976`, `950→977` y las
  **rutas completas** de los dos logs de Atria.
- M115 (×2 archivos): `Logs/308, 320, 327` → **`Logs/327, 414, 526, 921`**.

**Surgical, no `sed` global:** en `CHECKLIST-GLOBAL.md` el número **722** se usa para
**dos logs distintos** (QA de M10 y `M48-AnimationService` del M118) y **724** para
otros dos (QA de M12 y `M118-ITER3`). Solo se tocaron las citas del QA; las del M118
quedan intactas porque **esas sí apuntan al log commiteado** en 722/724.

### 2.5 Otros

- **9 scripts `.py`** movidos de `Logs/reservas/` a `tools/logs/` (violaban la regla
  "`Logs/` sólo tiene logs"). Se usó `git mv` para conservar historial.
- **Corrupción de bytes en `Mensajes entre modelos/ESTADO-PARALELO.md`:** tenía
  `0x08` en `\x08ackup.yml` y `0x00` en `\x005-Checklist.md` (el primer carácter del
  token reemplazado por un byte de control). Eso hacía que **grep tratara el archivo
  como binario** y no mostrara su contenido. Reparado → `backup.yml` y `05-Checklist.md`.

### 2.6 Guardián del protocolo de reservas (fix de la causa raíz)

Se creó **`scripts/reservar_log.py`**, que cierra el gap por el que dos agentes
pudieron reservar el mismo número sin que nada lo detectara:

- `--estado` → lista reservas y reporta **conflictos**: reserva doble, número
  reservado *y* ya escrito, y **colisiones** (2 logs con el mismo número). Es lo que
  destapó las colisiones 875/932 de §2.3b.
- `--check NNN` → exit 0 si el número está libre, 1 si está ocupado o reservado.
- `--reservar --agente X --modulo Y` → asigna el siguiente libre
  (`max(ULTIMO_NUMERO, max Logs/NNN, max reservas/NNN) + 1`), crea la reserva y
  actualiza `ULTIMO_NUMERO.txt`.
- `--liberar NNN` → borra la reserva al cerrar el ciclo.

---

## 3. Evidencia

### 3.1 Auditor de referencias

`scripts/auditar_referencias.py` (modo informe), antes → después:

| Métrica | Antes | Después |
|---|---|---|
| Rutas rotas (auto-reparables) | 3 | **1** |
| Ambiguas (varios logs mismo número) | 4 | 4 (pre-existentes) |
| Menciones "Log NNN" sin log | 13 | 13 (casi todas falsos positivos de prosa) |

La **única** ruta rota que queda es `Logs/9*agnes*M107*` en
`DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn/107-Backups-QA/checklist.md` — es un
**patrón con comodín** (una condición "o equivalente"), no una cita concreta; el
auditor no puede resolverlo. **Pre-existente y de otro agente** → no se tocó.

Las 4 "ambiguas" también son pre-existentes (`364-qa-sim-m70.py`, `258/263/333`,
`906-BUG-039`). Las 13 menciones sin log son casi todas prosa (`"logs 5"`,
`"log 2026"`) o instantáneas en `scripts/backups/`.

### 3.2 Integridad de `Logs/`

```
$ ls Logs/ | grep -oE '^[0-9]{3}' | sort | uniq -d
(vacío)

$ python scripts/reservar_log.py --estado
Logs/*.md         : 852 numeros
reservas/*.txt    : 4
  !! 891 reservado Y ya escrito en Logs/: ['891-muse-spark-1.3-contributor-M111.txt'] | ['891-AGNES-BUCLE-P18-CIERRE_2026-09-12.md']
1 problema(s) de numeracion.
```

**Sin ninguna colisión de número** (875, 932, 949 y 950 resueltas). La única
advertencia es la reserva huérfana de otro agente (§5.1). Los 27 archivos movidos
(25 de la cuarentena + 2 de Atria) y los 2 de §2.3b verificados **CRLF y sin BOM**;
`Logs/792` reescrito también CRLF sin BOM.

### 3.3 Verificación de títulos

Los 18 renumerados llevan el título con el **número nuevo** (`# Log 956:` … `# Log 973:`)
+ nota de procedencia; los 7 recuperados conservan su título original.

---

## 4. Observaciones (trampa 70 — worktree compartido)

Mientras corría este ciclo, **otro agente estaba activo**:

- Apareció la reserva `Logs/reservas/974-agnes-3-flash-M83.txt` **durante la sesión**
  (antes no estaba) → **974 quedó tomado**; este log usa **975**.
- `Logs/ULTIMO_NUMERO.txt` pasó de `955` a `974` por obra de ese agente.

**Consecuencia:** los 18 renumerados se asignaron a `956`–`973` **sin reserva previa**
(los slots estaban libres y sin reserva en el momento). Queda como **pendiente** cerrar
el protocolo de reservas (ver §5.1) para que esto no vuelva a pasar.

---

## 5. Pendientes / discrepancias registradas

### 5.1 Protocolo de reservas — RESUELTO

Causa raíz (la reserva `950` llegó a estar **doble** —Hy3 y Atria— y nada lo detectó):
cerrada con `scripts/reservar_log.py` (§2.6). Tras el fix, `--estado` reporta **1 sola
advertencia**, que es una **reserva huérfana de otro agente**:
`Logs/reservas/891-muse-spark-1.3-contributor-M111.txt` — el número 891 ya lo escribió
`891-AGNES-BUCLE-P18-CIERRE_2026-09-12.md`. **No se liberó** (es de muse-spark, no mía);
queda señalada para que su dueño la borre con `--liberar 891`.

### 5.2 Discrepancias de contenido en citas (NO editadas, sin prueba)

| Cita | Problema |
|---|---|
| `terreno_horizonte.gd:255` "FIX Log 792 v2 (aro sin superficie)" | el log 792 recuperado trata de la **pared perimetral + suelo fantasma**, no del abanico. La guía 17 atribuye el fix del abanico a **Log 790**, pero el contenido del 790 tampoco menciona el abanico → **sin prueba concluyente** |
| `GUIA-GODOT/18-impostores-terreno.md` L149/L319 "Log 803" | citan el fix de *exageración*; el 803 recuperado trata del **anillo de arena**. Los logs que sí mencionan la exageración son **817/820/843** |
| `GUIA-GODOT/19-diagnostico-tildes.md` C-09 "Log 805: `terreno_horizonte.gd:163`" | el 805 recuperado trata del ***winding*** del anillo, no de un parse error |
| `terreno_horizonte.gd:238` "Log 800" (disco base de fondo marino) | el 800 recuperado trata de la **generación por columnas** (misma sesión y subsistema) |

Se aplicó la regla del proyecto: **no editar una cita sin prueba**. Todas resuelven
ahora a un log real de la misma sesión/subsistema; se registran para revisión del dueño.

### 5.3 `scripts/backups/` y `Obsoletos/`

Contienen citas a los números viejos. **No se tocaron**: son instantáneas históricas.

---

## 6. Archivos

**Movidos (25):** `Logs/723-…`, `792-…`, `800-…`, `801-…`, `802-…`, `803-…`, `805-…`,
`956-…` … `973-…`.
**Renombrados (2):** `Logs/976-QA-M08-Mundo-Voxel_…`, `Logs/977-QA-M11-Personaje_…`.
**Renombrados (2 más):** `Logs/978-AUDITORIA-AGNES-REVERT-28-MODULOS_…`,
`Logs/979-Verificacion-8-Modulos-Item-Por-Item_…`.
**Movidos (9 .py):** `Logs/reservas/*.py` → `tools/logs/*.py`.
**Nuevo:** `scripts/reservar_log.py` (guardián de reservas),
`PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`.
**Editados:** `PAPELERA/logs-recuperados-2026-09-16/README.md` (+ nuevo `MAPA-RENUMERACION.md`),
`CHECKLIST-GLOBAL.md`, `GUIA-GODOT/16-zoom-camara-personaje.md`,
`10-Generacion-Del-Mundo/plan-actual/05-Checklist.md`,
`atria-dawn/BACKLOG-MASTER.md`, `08-Mundo-Voxel/plan-actual/04-Codigo.md`,
`11-Personaje-Del-Jugador/plan-actual/05-Checklist.md`,
`Mensajes entre modelos/ESTADO-PARALELO.md`,
`115-Hardware/plan-actual/05-Checklist.md`,
`deepseek-v4-flash/115-Hardware/checklist.md`.

---

**Firmado:** DeepSeek-V4.1-Flash / WorkBuddy — Log 975.
