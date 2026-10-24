# Log 2165 - M01 - Clasificacion de los 111 modulos bloqueados por TIPO de dependencia

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy AI)
**Modulo:** 01-Fundamentos-Del-Proyecto (indice maestro)
**Fecha:** 2026-10-24 00:38
**Rama:** 1 (director 379, punto 5: GO a clasificar los bloqueado_ambos por tipo de dependencia)
**Log:** 2165 (cabeza del pool medida justo antes = 2165; head tras reservar = 2166)
**Canal:** 380 (reporte de la tanda)
**Iteracion:** 10 del indice maestro

## 1. Que se pidio

El director (mensaje 379, punto 5) dio GO explicito a: *clasificar los 107 bloqueado_ambos por
tipo de dependencia (asset / hardware / cuenta-externa-fundador / decision-del-proyecto),
entrega por bloques*.

## 2. Estado de partida MEDIDO (no heredado)

El mensaje hablaba de 107. Medido sobre disco hoy: **111**. La diferencia es el efecto de los
flips que el director aplico despues del 378 (M69/M98/M117 al indice y las filas del GLOBAL),
no un error de conteo.

- Indice maestro: **152** items = 32 [x] / 120 [ ] / 0 [?] (conteo por prefijo `- [marca]`).
- `--pendientes`: 120 [ ] = 111 bloqueado_ambos + 9 bloqueado_global + 0 resoluble + 0
  bloqueado_checklist + 0 sin_checklist.
- Items abiertos leidos dentro de los 111 modulos: **2571** ([ ] + [?] de cada 05-Checklist).

**Hallazgo colateral (drift, no tocado):** la fila 01 de CHECKLIST-GLOBAL.md dice 29/152 y el
disco dice 32/152. Los 3 de diferencia son exactamente los flips M69/M98/M117: se aplicaron al
indice y no a la celda Progreso de la fila. CHECKLIST-GLOBAL.md es zona protegida, se reporta.

## 3. Hallazgo de partida: el codigo de iter.10 ya estaba en HEAD sin log ni mensaje

Al abrir la vuelta encontre `--dependencias` y los bloques K/L/M/N de la suite ya escritos y
COMMITEADOS en c96721d ('las herramientas y sondas del indice M01'), con mtime 23:12, es decir
POSTERIOR al ultimo registro de mi memoria de automatizacion (22:04) y SIN log ni mensaje en mi
canal. Es el patron ya documentado: el cron del director commitea el worktree EN VUELO. Se
verifico el codigo en vez de reescribirlo, y se continuo desde ahi.

## 4. Lo que se hizo (iter. 10)

### 4.1 Medir la precision antes de publicar el numero

Un conteo por palabra clave no es un veredicto. Se muestreo deterministicamente (un item cada
N, sin elegir) y se leyo cada item:

| Familia | Items | Muestra | Reales | Precision |
|---|---|---|---|---|
| cuenta_externa_fundador | 5 | 5 (todos) | 5 | 100% |
| hardware | 37 | 13 | 9 | 69% |
| asset | 168 | 34 | 19 | 56% |
| decision_proyecto | 4 | 4 (todos) | 4 | 100% |

### 4.2 Dos correcciones de patron (medidas, no esteticas)

(a) `hardware` cazaba implementacion y targets de diseno. Los tokens FPS / rendimiento /
frame budget matcheaban solos: **16 de 56 items (28,6%)** eran implementacion ('FPS overlay
cada 0.5s', 'Implementar metricas de rendimiento') o targets ('Definir objetivo 30 fps').
Regla nueva: token DURO de dispositivo (Steam Deck, GPU, VRAM, hardware, dispositivo, tactil,
haptics, android) O token de performance MAS verbo de medicion en el mismo enunciado.
Efecto medido: 56 -> 37 items.

(b) `asset` cazaba vocabulario tecnico: mesh, malla, material, particula, vfx. 'Pool de meshes
reutilizado', 'materiales regionales habilitan variantes' y 'particulas de satisfaccion' son
IMPLEMENTACION, no un archivo de arte que falte. Se sacaron. Efecto medido: 206 -> 168.

(c) Ceguera a plurales: `\bdispositivo\b` no matcheaba 'dispositivos' y `\bmesh\b` no
matcheaba 'meshes'. Medido sobre el residual: 5 items con token de familia en plural que el
patron no cubria. Corregido con `s?`.

(d) El residual se llamaba `sin_senal`, que se lee como 'el detector no vio nada'. El 56% en
ese cajon hacia pensar en un detector ciego; medido, es trabajo de implementacion real
('Saltar, nadar y escalar del jugador'). Renombrado a `sin_dependencia_declarada`.

### 4.3 Resultado

2569 items en 111 modulos:

- cuenta_externa_fundador: 5 (0,2%)
- hardware: 37 (1,4%)
- asset: 168 (6,5%)
- decision_proyecto: 4 (0,2%)
- otro_modulo: 803 (31,3%)
- trabajo_propio: 74 (2,9%)
- sin_dependencia_declarada: 1478 (57,5%)

Modulos SIN ninguna dependencia externa: **52**. Con al menos una: 59.

Lectura: alrededor del **5% de la deuda abierta espera a un tercero**. El resto es
implementacion, trabajo entre modulos o decision tecnica. 52 de 111 modulos no tienen ni un
solo item en una familia externa: su bloqueo es su propia checklist.

Los 5 items del fundador (los unicos con precision 100%): M01 'Verificar ausencia de marca
registrada conflictiva'; M106 x4: proyecto en Google Cloud Console, habilitacion de Drive API,
creacion de credenciales OAuth, obtencion de token OAuth.

## 5. Entregables

- `scripts/auditar_indice_m01.py` - flag `--dependencias` (+ `--bloque`, `--tam`, `--json`),
  7 familias con precedencia, guarda de ceguera (exit 3).
- `scripts/test_auditar_indice_m01.py` - bloque O NUEVO (8 checks) para la regla de precision
  de `hardware`; renombre del residual en bloques K/L; piso 54 -> **62** (medido).
- `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/10-Clasificacion-Dependencias.md` -
  documento de cierre: metodo, precision medida, bloque 0 (fundador), los 52 modulos sin
  dependencia externa, y las 6 tablas de 20 modulos.

## 6. Evidencia

- Suite: **62 checks / 0 fallos / EXIT 0 x3** (tres corridas, mismo conteo).
- Piso `CHECKS_MINIMOS = 62` MEDIDO en verde antes de fijarlo (era 54).
- Sonda EN ROJO de la regla nueva: se copiaron auditor + suite a un temporal, se revirtio la
  regla de medicion al patron viejo y se corrio. Resultado: **EXIT 1, 5 fallos**, nombrando
  exactamente los checks del bloque O (items 0/1/2 + 'exactamente 3 de 6' + '3 externos').
  Restauracion byte-exacta verificada por sha256 y control posterior **62/0 EXIT 0**.
- Guarda de ceguera probada: bloque M (sin items abiertos) -> exit 3.
- Higiene del Log y del doc: ASCII puro por bytes, CRLF, sin BOM (medido, no mirado).

## 7. Archivos tocados

- `scripts/auditar_indice_m01.py` (clasificador: 3 correcciones de patron + renombre)
- `scripts/test_auditar_indice_m01.py` (bloque O, renombre, piso)
- `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/10-Clasificacion-Dependencias.md` (nuevo)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (nota + marca)
- `.ultima-revision-deepseek.txt` (377 -> 379)

## 8. Pendientes y pedidos al director

1. **Commit** de los 3 paths de codigo/doc (no commiteo sin autorizacion).
2. **Drift de la fila 01**: dice 29/152, el disco dice 32/152. Los 3 son M69/M98/M117. La celda
   Progreso la aplica el director (zona protegida).
3. **Decision sobre `asset`**: 168 marcados con 56% de precision. Opciones: (i) dejarlo como
   cota superior y triagear a mano con `--json`; (ii) pedir a cada dueno de modulo que confirme
   sus items de asset. No propongo mas regex: el vocabulario del proyecto solapa los dos casos
   ('audio de recogida' vs 'sin loops de audio') y no hay verbo que los separe.
4. Si el director quiere la clasificacion item por item de un modulo concreto, `--json` la trae
   con `tipo`, `familias` y `evidencia` (el texto exacto que disparo el match).

## 9. Cierre de numeracion

Pool de logs: 2165 consumido, cabeza 2166. Pool del canal: cabeza 380 al reservar el mensaje.
No se commitea el pool (regla dura).
**Nota de medicion:** el conteo se movio durante la vuelta (2571 items a las 00:38,
2569 a las 00:47): otro agente cerro 2 items en una checklist ajena del worktree
compartido. Las cifras de este log son de la ULTIMA medicion. Las familias no se movieron
salvo el residual (1480 -> 1478).
