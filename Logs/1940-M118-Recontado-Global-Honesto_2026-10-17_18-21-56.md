# Log 1940 - M118 - Re-contado global honesto (item 103 de la cola activa V2)

- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M118-CI-CD (tooling / QA de protocolo)
- **Fecha:** 2026-10-17 18:21 (GMT-3)
- **Tarea:** item 103 de la COLA ACTIVA del BACKLOG-MASTER V2 - "Re-contado global honesto:
  corrida de `scripts/verificar_checklist.py` y reporte".
- **Rama del ciclo:** RAMA 2 (sin mensaje nuevo del director; tracker 294 = ultimo procesado,
  msg 294 era acuse del commit `e276765` de M62 L191).

## Objetivo

Medir el estado real de los 05-Checklist de los 167 modulos y contrastarlo con
`CHECKLIST-GLOBAL.md`, sin editar nada protegido. Entregar cifras medidas al director.

## Metodo

1. `python scripts/verificar_checklist.py --todos > out/verif_103_full.txt` -> **EXIT 1**
   (1 = miro y encontro alertas; 0 seria sin alertas, 3 seria detector ciego).
2. Analisis de la salida con `out/analiza_103.py` (parser por bloque `[x]/[ ]/[?]`).

## Resultado medido

- **Modulos parseados: 167.**
- **Suma global: 19.207 `[x]` / 3.656 `[ ]` / 1.150 `[?]` = 24.013 items.**
- **178 alertas**, desglosadas:
  | tipo | n |
  |------|-----|
  | `Inconsistencia en` (GLOBAL vs 05-Checklist) | 2 |
  | estado global vs `[x]` (modulos (verde) con items hechos) | 4 |
  | `timestamp ilegible` (posible bloqueo colgado) | 4 |
  | filas mal formadas en la tabla GLOBAL | 152 |
  | bloques `Totales` del 05-Checklist que se contradicen | 16 |

### (1) GLOBAL vs 05-Checklist: solo 2 discrepancias reales

- `46-Arte-2D`: GLOBAL dice **90/110**, el 05-Checklist tiene **91/110**.
- `55-Diario-Del-Jugador`: GLOBAL dice **58/131**, el 05-Checklist tiene **62/131**
  (el 62/131 es el flip de Log 1934, pendiente de que el director lo aplique a la fila GLOBAL).

### (2) Modulos con `[x]` pero estado global (verde) Disponible (4)

`138-Vertical-Slice` (11/131), `142-Release-Candidate` (23/129), `143-Lanzamiento` (18/111),
`144-Despues-Del-Lanzamiento` (4/105). Filas bien alineadas: la inconsistencia es real
(estado (verde) = disponible/no arrancado, pero el checklist ya tiene items hechos).

### (3) `timestamp ilegible` (4) = SINTOMA, no causa

`159-Catalogo-De-Objetos`, `41-Musica`, `46-Arte-2D`, `49-Iluminacion`. El verificador no
puede leer la columna "Ultima actividad" porque el parser mapea por POSICION y la fila esta
desplazada (ver (4)). No son bloqueos colgados reales: es lectura de columna equivocada.

### (4) CAUSA RAIZ de las 152 filas mal formadas - `CHECKLIST-GLOBAL.md` esta degradado

Medido sobre el archivo (218 lineas, LF, sin BOM, 176 lineas que empiezan con `| `):

- **L22: la fila de cabecera y la fila separadora estan en la MISMA linea fisica**
  (`| ID | ... | Notas ||----|--------|...`), falta el salto de linea. El parser detecta
  **23 columnas** cuando la tabla real tiene **11** -> casi todas las filas quedan "mal formadas"
  (152 de 176). En GitHub esta tabla NO renderiza como tabla.
- **16 filas con celdas vacias iniciales de mas** (hasta 9): L24 (02), L27 (04), L28 (05),
  L39 (104), L51 (115), L64 (127), L76 (137), L78 (139), L80 (140), L89 (148), L91 (15),
  L103 (16), L131 (35), L141 (45), L144 (48), L166 (70). Cada celda de mas desplaza
  ID/Modulo/Estado/Progreso/Agente/Actividad una posicion a la derecha.
- **6 filas sin `|` de cierre**: L79, L96, L98, L112, L129, L149.

**Consecuencia:** para esos 16 modulos la comparacion de "Progreso" del verificador NO es
confiable (lee la celda de al lado). El "0/2 discrepancias" de (1) solo cubre las filas sanas:
**el re-contado global es ciego en 16 modulos + 4 de los `timestamp ilegible`**.

### (5) Bloques `Totales` que mienten dentro del propio 05-Checklist (16)

Declarado -> real `[x]/[?]/[ ]`:

| modulo | linea | declarado | real |
|--------|-------|-----------|------|
| 103-Logging | L244 | total 158 | 173/6/0 = 179 |
| 104-Analytics | L173 | total 100 | 107/8/4 = 119 |
| 109-Herramientas-Internas | L226 | x 107, e 28 | x 120, e 15 (138) |
| 126-Marketing-Legal | L300 | x 101, ? 0 | x 100, ? 1 (101) |
| 129-Merchandising | L183 | x 103, ? 5 | x 101, ? 7 (108) |
| 137-Prototipo | L219 | x 8, e 123 | x 7, e 124 (131) |
| 150-Diseno-Sonoro-Narrativo | L201 | x 146, ? 4, e 0 | x 149, ? 0, e 1 (150) |
| 156-Terrenos-Y-Movimiento | L431 | total 246 | 202/47/58 = 307 |
| 19-NPC-Y-Vecinos | L189 | x 126, e 2 | x 128, e 0 (128) |
| 21-Dialogos | L204 | x 82, ? 6, e 55 | x 86, ? 4, e 53 (143) |
| 31-Ciclo-Dia-Noche | L423 | x 120, ? 49 | x 125, ? 44 (169) |
| 32-Clima | L212 | x 121, ? 0 | x 119, ? 2 (121) |
| 33-Agricultura | L250 | total 153, e 47 | 106/0/49 = 155 |
| 41-Musica | L148 | x 58, ? 2 | x 60, ? 0 (110) |
| 46-Arte-2D | L265 | x 0, e 110 | x 91, e 19 (110) |
| 93-Balance | L235 | x 131, e 3 | x 130, e 4 (134) |

El mas grave: `46-Arte-2D` declara **0** hechos cuando tiene **91** (nota de iteracion no
reflejada en el bloque Totales).

## Trampa propia cazada (medir antes de escribir la cifra)

La primera version de `out/analiza_103.py` leia una ventana de 5 lineas por modulo y se comia
el `completados` del modulo SIGUIENTE: reportaba `M01 = 168 [x]` (el valor de M02) y sumaba
19.336. Corregido el corte de bloque (`break` en la primera linea que no empieza con `   - `),
el valor real es **M01 = 26 [x] / 126 [ ] / 152** y la suma **19.207**. Ninguna cifra de este
log se escribio antes de re-medirla.

## Limites respetados

- 0 commits / 0 push.
- 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot` ni a ningun
  `05-Checklist.md` (los 16 `Totales` y las 152 filas los corrige quien tenga la orden).
- 0 flips / 0 auto-sellos 21.8.

## Propuesta al director (no ejecutada)

1. Reparar `CHECKLIST-GLOBAL.md` L22 (insertar salto de linea antes de `|----`), quitar las
   celdas vacias iniciales de las 16 filas y cerrar las 6 filas sin `|`. Es 1 archivo, 23
   lineas tocadas, y desbloquea el re-contado real de 16 modulos.
2. Reasignar los 16 `Totales` incoherentes a sus duenos (son 05-Checklist ajenos; yo solo
   puedo medirlos).
3. Decidir quien aplica el 58/131 -> 62/131 de `55-Diario` en la fila GLOBAL (flip de Log 1934).

## Evidencia

- `out/verif_103_full.txt` (865 lineas, salida completa, EXIT 1).
- `out/analiza_103.py` (parser del bloque, corregido).
- Medicion de `CHECKLIST-GLOBAL.md`: 218 lineas, LF, sin BOM, 176 filas `| `, 16 desplazadas,
  6 sin cierre, cabecera L22 fusionada con el separador (23 columnas detectadas).
