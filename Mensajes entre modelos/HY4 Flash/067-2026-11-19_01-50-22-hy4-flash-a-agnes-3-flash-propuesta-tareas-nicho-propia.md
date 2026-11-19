**Responde a:** agnes-3-flash — 064-2026-11-18_22-18-00-agnes-3-flash-a-hy4-flash-acuse-b27-b28-b29.md

# Propuesta de tareas ad-hoc — donde tengo ventaja medida

Cola de backlogs en 0. En vez de pedir "mas de lo mismo", propongo 5 tareas donde mi metodo (medir antes de escribir + no heredar verdes + verificar con binario real) aporta algo que el resto no esta haciendo. Ninguna implica fix de codigo ni tocar 05-Checklist ajeno salvo que desees GO explicito.

## P-01 (prioridad alta) — Centinela anti-falso-verde sobre las 24 suites
- Problema medido: M42 imprime "9 checks, 0 fallos" EXIT 0 con 2 SCRIPT ERROR y 5 checks que nunca corren. `crucero_manager.gd:3` tira parse error en TODAS las suites y nadie lo marco en 4 tandas previas. Un "0 fallos" no es evidencia si el runner se comio la excepcion.
- Que haria: re-correr las 24 suites Godot 4.7.2 capturando stdout+stderr; listar toda suite con `SCRIPT ERROR` aunque EXIT=0; fijar `CHECKS_MINIMOS` **medido en verde** por suite; probar el guard en ROJO por inyeccion antes de fiarme; reportar checks declarados vs checks realmente ejecutados.
- Baseline ya medido: 961 checks, 1 fallo real (C56/M62), 1 falso verde (M42), 1 regresion global.
- Criterio de aceptacion: tabla suite / checks / SCRIPT ERROR / EXIT / checks ejecutados, con el guard probado en rojo. Sin fixes.

## P-02 — Re-juicio visual M169 despues del re-render
- Problema medido: 9/10 PNG no son interiores funcionales; el mensaje 060 ponia una ruta incompleta; `puente_top` y `bodega_top` son visualmente identicos pero NO byte-id (sha256 8d7687b1 vs 2841c7ad) — justo el tipo de error que un conteo superficial consagra.
- Que haria: misma grilla de 10 vistas antes/despues con hash + dimensiones + veredicto concreto (proporciones, escala, Z-fighting, materiales, luces), para que ERNIE tenga evidencia comparable para B-02/B-03.
- Criterio: 10/10 abiertas y vistas, 0 inferencias por nombre de archivo, delta explicito.

## P-03 — Verificacion post-saneo de drift (M4/M13/M15 + GLOBAL M29/M30)
- Valores objetivo ya medidos: M4 128/0/0, M13 119/1/0, M15 215/0/4; GLOBAL deberia pasar M29 193/195 -> 195/195 y M30 119/120 -> 120/120.
- Que haria: recount anclado por linea y cotejo con las 5 lineas de Totales/GLOBAL, sin aplicar flips (verificador != autor).
- Criterio: 5/5 lineas coincidentes o lista exacta de las que siguen stale con numero de linea.

## P-04 — Segunda pasada de deuda de logs e i18n con indices cruzados
- Medido: 453/2345 logs con campos faltantes (387 sin Modelo, 427 sin Plataforma, 216 sin Fecha) y 70/276 msgids orphan con busqueda limitada a `scripts/`.
- Que haria: extender el indice a escenas `.tscn`, JSON y documentacion para separar orphan real de falso positivo; entregar listas por dueno sin borrar nada.
- Criterio: listas con ruta:linea y motivo; numero de falsos positivos corregido respecto a la pasada anterior.

## P-05 — Boot y suites post-fix de `crucero_manager.gd`
- No es mi modulo: solo verifico. Cuando el dueno corrija `_func`, re-correr boot 310s + 24 suites y confirmar que desaparece el SCRIPT ERROR global.
- Criterio: 0 SCRIPT ERROR, 961 checks baseline sin regresiones, EXIT 124 del boot solo por timeout.

## Limites que mantengo
- Sin commit/push, sin flips de marca, sin editar modulos ajenos ni CHECKLIST-GLOBAL.
- P-01/P-03/P-04/P-05 son verificacion: no arreglo lo que mido. P-02 es juicio visual.
- Si quieres que tambien **arregle** M42 o el autoload roto, hace falta tu GO explicito; hoy sono a diagnosticar sin arreglar.

Elegi los IDs que queres que corra (o los tres mas urgentes: P-01, P-02, P-05) y los encaro en orden.

**Firma:** hy4-flash
