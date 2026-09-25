# Log 1114: COORD — Corrección del cuadro BUG-050 + política de over-marks (Caso A/B)

**Fecha:** 2026-09-20
**Hora:** 04:10
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code (sesión 1, coordinación)

## Resumen

El usuario me puso en contexto de dos hallazgos (s2: 145 over-marks en 17 módulos ✅;
hy3: BUG-050, "36 módulos sobre-cerrados") y dio una política para resolverlos.
**Verifiqué ambos de forma independiente** y el cuadro real es **distinto al transmitido**:
ningún módulo está falsamente completado; el defecto es una frase de sello mal
atribuida. Registro la política del usuario y reasigno la limpieza.

## Cambios Realizados

### 1. Política del usuario (2026-09-20 04:00) — registrada en ESTADO-PARALELO

Ante un `[x]` sospechoso:
1. **Verificar el código** (grep / binario real).
2. **CASO A** — marcaron la tarea pero el código **NO está implementado** → **se descarta
   la marca** `[x]` → vuelve a `[ ]` (o `[?]` con dueño).
3. **CASO B** — el **plan fue malo** / la checklist **no corresponde** → **no tocar la
   marca**; se **revalúa el plan-actual y la checklist**.

Un ítem puede ser ambos: si su texto dice honradamente "NO implementado" y el código no
está, la checklist SÍ corresponde → aplica solo **A**.

### 2. Corrección al informe de hy3 (Log 1111-hy3, BUG-050)

hy3 lo llamó "sobre-cierre masivo de 36 módulos". **Mi verificación muestra que el cuadro
es otro** — conté 12 módulos uno por uno:

| Módulo | Mi conteo | Global decía | Estado global |
|---|---|---|---|
| M01 Fundamentos | 0 [x] / 152 [ ] | 0/152 | 🟢 Disponible |
| M02 Visión | 0 / 172 | 0/172 | 🟢 |
| M06 Control-Versiones | 0 / 100 | 0/100 | 🟢 |
| M99 Marketing | 7 / 162 | 7/169 | 🟢 |
| M55 Diario | 8 / 123 | 8/131 | 🟢 |
| M97 Steam-Store | 129 / 66 | 129/195 | 🟢 |
| M100 Community | 146 / 76 | 146/222 | 🟢 |
| M120 DLC | 163 / 59 | 163/222 | 🟢 |
| M121 Soporte | 123 / 88 | 123/211 | 🟢 |
| M124 UGC | 83 / 25 [?] | 83/108 | 🟡 |
| M130 Artbook | 96 / 50 | 96/146 | 🟢 |
| M137 Prototipo | 10 / 121 | 10/131 | 🟢 |

**Conclusión: las columnas Estado y Progreso son EXACTAS. Ningún módulo está falsamente
marcado ✅. NO hay 36 reversiones de estado que hacer.**

El defecto real es la **frase "✅ Verificado por Hy3" en la columna Notas de ~42
módulos**, que cita los logs 866/867 de **agnes** (no de hy3). Es una **misatribución de
sello**: indica una verificación §21.8 que nunca ocurrió. Fix = limpiar la frase de las
Notas, preservando todo lo demás.

Para los que **sí son** ✅ de esa lista (M08, M102, M112, M114, M118, M119, M133-M136),
conté todos: **exactos, sin `[ ]` ocultos**. Over-marks detectados en M114 (2), M118 (4),
M119 (1), M136 (1) → **CASO A** puro.

### 3. Confirmación del hallazgo de s2 (145 over-marks)

Conté los 5 peores y **coinciden con s2**: M93 **22/134**, M32 **15/121**, M36 **13/228**,
M146 **10/100**, M85 **15**. Verifiqué la cadena completa del peor caso:

- M93 L138: *"Definir `simulate_economy.gd` con escenarios... → KnownIssue no bloqueante
  DoD: NO implementado"* marcado `[x]`.
- **`simulate_economy.gd` NO EXISTE en el repo** (búsqueda recursiva en
  `game/isla-ancestral`). → **CASO A confirmado**: marca sin código.

### 4. Verificación de los cierres de mimo (informe 2026-09-20)

- **M156 Terrenos: 246 [x] / 59 [ ] / 2 [?]** — cerró +40, **exacto**.
- **M150: 131 [x]** — exacto. **M131: 83 [x]** — exacto.
- Los bloqueos restantes de mimo son genuinos (M150 diseño creativo + M22/M148; M131
  audio engine M41/M42/M43 inexistentes; M156 integración M11/M155; M160 M25/M28).

### 5. Colisión de log 1111 (cuarta de la misma clase)

hy3 tomó **1111** directo del filesystem (Log 1111-hy3 BUG-050, commit 9c5eda2) sin pasar
por el pool; mi Log 1111 chocó. **Renombré el mío a 1113** (vía correcta, número consumido
del pool). Pool final: **sin conflictos**.

> **Protocolo:** la afirmación de §6.1.d ("colisión imposible") sigue siendo falsa en la
> práctica — cualquier agente que nombre su log a mano puede duplicar un número del pool.
> `reservar_log.py --reservar` es obligatorio; `--estado` al cerrar lote, la red real.

## Acciones derivadas (asignadas)

- **T-L11 → atria-dawn s2** (agregada a su backlog): limpiar la frase falsa
  "Verificado por Hy3" de ~42 Notas en CHECKLIST-GLOBAL. **Alcance estricto: solo la
  frase.** No toca Estado, Progreso ni marcas — los conteos están verificados exactos.
- **s2** continúa su escaneo aplicando **CASO A** a los 145 over-marks (descartar la
  marca, **no** revertir estados 🟢/🟡, que están correctos).
- **CASO B** queda como decisión del usuario: los módulos fundacionales sin iniciar
  (M01/M02/M06 con 0 [x]) están **correctamente reportados como 🟢**; si sus checklists
  describen trabajo que no corresponde al módulo, eso es revaluación de plan, no un bug.

## Verificación final

- `reservar_log.py --estado`: **sin conflictos de numeración**.
- 12 módulos contados a mano: Estado/Progreso de CHECKLIST-GLOBAL **exactos**.
- `simulate_economy.gd`: ausente en el repo (over-mark M93 confirmado).
- Cierres de mimo: 3/3 exactos.
- Codificación: 0 mojibake en lo tocado.

## Archivos Modificados/Creados

- `Mensajes entre modelos/ESTADO-PARALELO.md` — política Caso A/B + cuadro corregido.
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/BACKLOG-MASTER.md` — tarea T-L11.
- `Logs/1111-COORD-...md` → `Logs/1113-COORD-...md` (renumerado).
- `Logs/1114-COORD-correccion-bug050-politica-overmarks_2026-09-20_04-10-00.md` (este log).

## Notas

- **Aclaración importante para el usuario:** el proyecto NO está sobrerreportado en su
  estado de completitud. Lo que sí está roto es (a) la atribución de ~42 sellos §21.8 y
  (b) 145 marcas `[x]` que violan la DoD apuntando a código inexistente. Ambos se arreglan
  sin cambiar el estado reportado de ningún módulo.
- Push a git: **NEGATIVO** (directiva del usuario).
