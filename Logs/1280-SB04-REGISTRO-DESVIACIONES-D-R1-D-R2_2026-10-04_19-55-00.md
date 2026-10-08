# Log 1280: SB-04 — Registro de desviaciones justificadas (D-R1 y D-R2) en M152

**Fecha:** 2026-10-04
**Hora:** 19:55:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

## Resumen

Creé el archivo de registro de desviaciones justificadas de M152 y registré las **dos desviaciones
reales** detectadas en SB-01 y decididas por el fundador el 2026-10-04:

- **D-R1 — combate: DESVIACIÓN JUSTIFICADA** (aprobada por el fundador).
- **D-R2 — mapa ×10: DESVIACIÓN PARCIAL** (2 de 3 patas cumplidas; aprobación pendiente porque el
  fundador pidió verificar la condición primero — veredicto en el Log 1278).

El archivo **no existía**: el `04-Codigo.md` §12 de M152 lo listaba como artefacto a crear, y la
plantilla de `03-Diseno.md` §5 tenía un ejemplo `D001` que era **ficticio** (no había ningún
registro real, y «Equipo de diseño» no es un rol que exista en este proyecto). **Esta es la
primera entrada real de desviaciones del proyecto.**

## Entregable

`DOCUMENTACION/152-Principios-Innegociables/plan-actual/desviaciones_justificadas.md`

Plantilla seguida: la del propio M152 en `03-Diseno.md` §5 — 6 columnas
`ID | Decisión | Principio desviado | Justificación | Aprobado por | Fecha`.

### Contenido

| ID | Decisión | Principio desviado | Aprobado por | Fecha |
|---|---|---|---|---|
| **D-R1** | Agregar combate (`164-Isla-De-Combate-Endgame`: 4 zonas, 8 mobs, 2 jefes con fases, tienda de gemas, 6 recompensas) | Sin combate por convención — `02-Vision` §1 + `01-Fundamentos` §11 dec. 1 | **Fundador** (escalado por atria-dawn; no es decisión de agente) | 2026-10-04 |
| **D-R2** | Ampliar el mapa ×10 (radio 256→2560, mundo 5120², commit `c107419`) | «No ampliar el mapa solamente para hacerlo grande» + la condición del Ejemplo 3 | **PENDIENTE** (veredicto: PARCIAL) | 2026-10-04 (verificación) |

**Justificación de D-R1** (la que pidió el director): el combate existe pero **no es letal en
consecuencias** — `164/plan-actual/03-Diseno.md` §4: «Si el jugador pierde (HP ≤ 0): vuelve al
pueblo **sin penalidad** · No se pierden objetos · **No hay game over**». Mantiene el principio de
fondo (muerte y castigo irreversible prohibidos) y abre una excepción acotada para contenido
opcional de endgame. Coincide con el **Ejemplo 1** del propio M152, ya aprobado entonces.

**Justificación de D-R2**: NPCs ✔ (3 zonas de fauna, r ≥ 1546) y recursos ✔ (r = 1838; vegetación
r ∈ [638..3038]; crafting r = 1844); misiones ✘ (`historia_principal.json` es un grafo narrativo
con 0 coordenadas). Detalle y radios en el **Log 1278**.

### Además del registro

El archivo incluye:
- La **nota de que `D001` era ficticio**, con el patrón identificado (ejemplo de plantilla que se
  lee como hecho — el mismo patrón H-D de SB-01/SB-02).
- Los **8 ítems del checklist de M152 §5** aplicados a cada entrada, con las casillas que se
  desmarcan y por qué.
- **3 tareas de plan** que surgen del registro (P1 anclar M22, P2 anclar M160, P3 limpiar
  `ubicaciones.json`), con dueño sugerido.

## Archivos Modificados/Creados

### Creados
- `DOCUMENTACION/152-Principios-Innegociables/plan-actual/desviaciones_justificadas.md` — el
  registro (nuevo archivo).
- `Logs/1280-SB04-REGISTRO-DESVIACIONES-D-R1-D-R2_2026-10-04_19-55-00.md` — este log.
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/scripts-prueba/` — carpeta de scripts de
  auditoría cross-módulo (SB-02/03/04).
- Informe al director: canal `space-bunny-alpha/06-...`.

### Modificado
- `Logs/NUMEROS_DISPONIBLES.txt` — **1280 borrado** (reservado). **La línea que tomé tenía un BOM
  pegado** (`﻿1280`); ver §Incidente. La reserva sigue siendo válida (el BOM es un
  artefacto de codificación, no parte del número). Cabeza actual **1281**.
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md` — SB-01..SB-04.

### Explícitamente NO tocados (por restricción del director)
`03-Diseno.md` de M152 · `CHECKLIST-GLOBAL.md` · los 167 `05-Checklist.md` · escenas ·
`quality.yml` · filas `🔵`/`🔴` · `M53` (mimo) · `M130` (Hy3).

## ⚠️ Incidente de numeración de logs — colisión real que conviene conocer

Reservando el número para este log, la primera línea del pool me devolvió **`﻿1280` — con un BOM
(U+FEFF) pegado al principio**. Al verificar, encontré dos cosas:

### 1. El pool volvió a tener BOM (ya se lo había quitado en SB-01, Log 1270)

Alguien lo reintrodujo. El BOM en la cabeza del pool es especialmente peligroso: **el primer
agente que lee la primera línea y hace `int()` recibe un `\ufeff` en el string**, y si no hace
`strip()` del BOM, consume un número corrupto. Yo hice `.Trim()` y obtuve `1280` correctamente, así
que la reserva es válida, pero el riesgo existe.

### 2. Colisión de log 1276 entre Hy3 y yo — ya resuelta por el director

- Cuando reservé **1276** para SB-02, la primera línea del pool era `1276`. La borré (§6.1.a).
- **Hy3 / WorkBuddy** tomó el **mismo 1276** para su re-verify de M43:
  `Logs/1276-m43-reverify-21.8_2026-10-04.md`.
- El director resolvió la colisión: reservó el **1279** del pool y renombró mi archivo
  `1276-SB02-...` → `1279-SB02-AUDITORIA-COHERENCIA-GLOBAL-2026-10-04_18-10-00.md`.
- **Ajusté el header interno** de ese log para que diga «Log 1279» y agregué una nota que explica
  la numeración. Su contenido no cambió.

**Causa raíz:** el protocolo §6.1.a («leer la primera línea y borrarla») **no es atómico**. Dos
agentes que leen en el mismo instante toman el mismo número. Con 20+ agentes va a seguir pasando.

**Propuesta concreta al director** (no la implemento — es `scripts/` del proyecto y `quality.yml`
está en manos de atria-dawn-s2):
1. Que la reserva sea **atómica**: un lock con `os.mkdir()` (que falla si el dir existe) o un
   `Move-Item` con `-ErrorAction Stop` sobre un archivo con el número en el nombre.
2. O que el número se **derive del contenido** (timestamp) y el pool deje de ser un contador.
3. Y un **validador que detecte duplicados**: recorrer `Logs/*.md`, extraer el número del título y
   avisar si hay dos archivos con el mismo. Eso es 10 líneas y habría detectado mi caso de una.

## Lo que NO hice (honestidad)

- **No cerré D-R2 como aprobada.** El fundador pidió verificar la condición; el resultado es
  **PARCIAL** y la decisión (justificada / parcial / deuda abierta) es suya. La entrada queda con
  «aprobación pendiente» y las 3 tareas de plan.
- **No modifiqué `03-Diseno.md`** para enlazar el archivo nuevo: el director pidió no tocarlo en
  SB-03/SB-04.
- **No toqué el checklist de M152.** Los ítems de la Familia J («Diseñar tabla de desviaciones» /
  «Diseñar ejemplo de desviación justificada») los marcó en SB-01; actualizarlos a `[x]` con
  evidencia de este archivo es una acción de una línea que **le dejo al director** para no pisar
  el módulo que ya liberé.
- **No verifiqué nada visual.** SB-04 es 100 % documental.

## Recomendaciones

1. **D-R2 → desviación PARCIAL**, con las tareas P1/P2 (anclar espacialmente M22 y M160) como
   deuda de M22/M160/M167, no de M152.
2. **Implementar la reserva atómica de logs** + el validador de duplicados (arriba).
3. **Quitar el BOM del pool** y considerar un chequeo de encoding en `verificar_checklist.py`
   (el proyecto ya tiene `scripts/diagnosticar_mojibake.py`, pero no mira `Logs/`).
4. **M152 puede pasar de `🟡` a un estado más cerrado**: las 29 `[?]` de SB-01 eran 8 sin
   denominador, 4 prácticas inexistentes, 4 emparejamientos mal, etc. **D-R1 y D-R2 eran 2 de
   esas** y ya están resueltas o en proceso de cierre.