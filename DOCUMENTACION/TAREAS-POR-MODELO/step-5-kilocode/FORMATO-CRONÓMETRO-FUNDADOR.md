# Formato de cronómetro que funcionó (2026-10-15)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15

> Pedido del fundador: guardar el prompt del cronómetro que hoy funcionó bien, para
> aplicarlo mañana con otras tareas pero la **misma metodología**.

## La idea que lo hizo funcionar

El problema que resolvía: el ciclo de 5 minutos se disparaba, no había mensajes del
director, y el agente respondía "sin mensajes nuevos" y **no producía nada**. El fundador
perdía el ciclo.

La solución tiene dos mitades, y las dos son necesarias:

1. **La mitad de monitoreo** (lo de siempre): revisar mi canal y el del director,
   procesar lo nuevo, mantener el marcador al día.
2. **La mitad de producción**: si el director no escribe, **hay una tarea propia
   obligatoria** en la que avanzar. Sin esto, la primera mitad sola no Produce nada.

La regla operativa es una sola línea: **el director primero; si no hay director, no
digas "sin mensajes" — trabajá en la tarea del fundador.**

## El prompt completo (copiar y pegar mañana, cambiando la tarea)

```
Revisar mi canal `Mensajes entre modelos\step-5-kilocode\`. PASO 1 OBLIGATORIO: leer el
archivo `.ultima-revision-step-5.txt` de mi carpeta (contiene el numero del ultimo
mensaje procesado; formato: solo el numero, sin salto final) y usarlo como punto de
partida. PASO 2: listar TODOS los .md ordenados por FECHA DE MODIFICACION (no por
nombre: los prefijos numericos no son correlativos con la hora) y detectar mensajes
nuevos. PASO 3: si lei o procese mensajes nuevos, ACTUALIZAR
`.ultima-revision-step-5.txt` con el numero del ultimo procesado (escribir solo el
numero, UTF-8 sin BOM) — NUNCA dejarlo desactualizado. Revisar tambien la carpeta del
director `Mensajes entre modelos\mimo-v2.6-flash-free\` por si responde a mis informes.
El director es mimo-v2.6-flash-free. Si hay mensaje nuevo (del director o de otra sesion
mia step-5-kilocode), leerlo COMPLETO y obedecer sus reglas: identidad de firma
`step-5-kilocode` (plataforma Kilo Code); comandos secuenciales uno a uno anti-429;
UTF-8 sin BOM sin caracteres raros; NUNCA reportar que algo no existe sin verificar por
via alternativa; SI LLEGAN 2 O MAS MENSAJES SEGUIDOS, LEERLOS TODOS Y ESCRIBIR UN SOLO
REPORTE; regla T-19: si un mensaje aparece con plantilla vacia (`<cuerpo del mensaje
aca>`) o en 0 bytes, NO actuar por el nombre del archivo — esperar 5 minutos y releer,
y si sigue vacio es mensaje caido: avisar al emisor por su canal. Entregar con `python
scripts/reservar_mensaje.py step-5-kilocode "<tema>" --emisor step-5-kilocode` (si el
pool esta vacio, ampliarlo con python y UTF-8 sin BOM, AGENTS.md §10.2.4). Limites:
READ-ONLY absoluto sobre CHECKLIST-QA-SEALS.md, CHECKLIST-GLOBAL.md, checklists ajenos y
COMMITS. Regla de oro para reparaciones de tabla: distinguir ERROR DE DATO (valor
incorrecto en la celda correcta) de ERROR DE ESTRUCTURA (celda de mas o de menos); si
requiere mover contenido entre columnas o elegir que valor va en una celda, REPORTAR
ANTES de editar. Regla de calidad aprendida: distinguir DISEÑADO de IMPLEMENTADO antes
de flipar y verificar cada item contra disco antes de flipar. Si NO hay nada nuevo,
responder con UNA sola linea y no hacer nada mas.

FLUJO DE TRABAJO ORDENADO POR EL FUNDADOR (AAAA-MM-DD): (1) PRIMERO atender al director
— si hay mensaje nuevo de mimo-v2.6-flash-free, leerlo completo, ejecutar lo que pide y
escribir el informe en mi canal con `python scripts/reservar_mensaje.py step-5-kilocode
"<tema>" --emisor step-5-kilocode`. (2) SI EL DIRECTOR NO ESCRIBE NADA NUEVO, NO
responderle "sin respuesta del director" ni quedarme sin hacer nada: RECORDAR SEGUIR
TRABAJANDO EN <LA TAREA DEL FUNDADOR>. <Descripcion del estado actual y del siguiente
paso concreto.> Avanzar de a poco, committeando cada tanda con pathspec explicito.
<Limites especificos de la tarea.>
```

## Cómo adaptarlo mañana

Solo cambian dos bloques; **el resto se copia tal cual**:

| Bloque | Qué cambiar |
|---|---|
| `FLUJO DE TRABAJO ORDENADO POR EL FUNDADOR (AAAA-MM-DD)` | la fecha de la sesión |
| `RECORDAR SEGUIR TRABAJANDO EN <LA TAREA>` | la tarea del día + su estado actual |
| `<Descripcion del estado...>` | el siguiente paso concreto, para no arrancar deduciendo |
| `<Limites especificos>` | qué archivos no se tocan en esa tarea |

## Lo que NO hay que cambiar

- Las reglas del director (identidad, T-19, límites READ-ONLY, reserva de mensaje).
- El orden: **director primero, producción después**. Invertirlo hace que la tarea
  propia le coma el tiempo al encargo del director.
- El cierre con "committeando cada tanda con pathspec explicito": es lo que permitió
  mostrar progreso verificable en cada ciclo en vez de una promesa al final.

## Resultado de la sesión que usó este formato (2026-10-15)

- 18 ciclos, todos con producción: 12 informes al director + 6 tandas de audios.
- Sin un solo ciclo vacío.
