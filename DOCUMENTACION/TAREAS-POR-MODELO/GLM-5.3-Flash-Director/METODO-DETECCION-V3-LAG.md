# MÉTODO V3 DE DETECCIÓN DE MENSAJES SIN RESPONDER — LAG POR ACUSE (script)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 02:49
**Estado:** VIGENTE — método único de detección. Los métodos V1 y V2 quedan OBSOLETOS (ver §5).
**Aprobación:** fundador 2026-10-19 02:38 ("podes ejecutar un script que detecte si hay nuevos archivos — es porque hay mensajes que leer") y validación 02:48 ("detectaste a ling que no me lo queria decir yo").

---

## 1. La idea (una frase)

Un mensaje está SIN RESPONDER cuando el **número de archivo más alto escrito por el agente** es mayor que el **número de archivo más alto de mi último acuse** en ese mismo canal. Esa diferencia se llama **LAG**.

## 2. El script

`scripts/verificar_mensajes_nuevos.py` (UTF-8 estricto, sin BOM, sin dependencias).

- **Canal**: cada carpeta de `Mensajes entre modelos/<CANAL>/`.
- **Clasificación por archivo** (no por puntero, no por receptor):
  - **MÍO (acuse)**: el nombre contiene el emisor `glm-5.3-flash-director-a-` (el emisor va ** después de la fecha** en el patrón `NN-AAAA-MM-DD_HH-MM-SS-EMISOR-a-RECEPTOR-tema.md`; buscarlo al inicio del nombre es un bug, ya corregido).
  - **DE ÉL**: todo archivo numerado cuyo nombre NO contenga ese slug — **sin importar a quién diga el receptor** (los casos reales `hy3-a-hy3` y `agnes-a-director` son mensajes PARA mí con slug impreciso).
- **Salida**: por canal, `NN` pendientes con rutas; `TOTAL`; exit 0 = al día, exit 1 = hay pendientes.
- **Propiedad clave**: es idempotente — cuando respondo el último pendiente, el LAG vuelve a 0 solo, sin registro extra que mantener.

## 3. Por qué NO se puede usar el puntero `.ultima-revision` como prueba de respuesta

El puntero prueba **LECTURA**, no **RESPUESTA**. Tres casos reales de la misma noche (2026-10-19):

| Caso | Qué pasó | Fallo del método viejo |
|---|---|---|
| Hy3 #259 | slug `hy3-a-hy3` (era para mí) | V1 filtraba por receptor → invisible |
| DS-OC #131-133 | leí los archivos para RENUMERARLOS y el puntero saltó a 133 | V1/V2 creían "≤ puntero = procesado" → vueltas 54-56 sin respuesta durante horas |
| Ling #177-178 | puntero suyo actualizado, mi acuse viejo | ambos métodos searchaban por puntero → invisible hasta que el V3 lo detectó |

**Regla derivada**: el puntero se actualiza SOLO como estado de lectura; jamás decide si respondo.

## 4. El procedimiento completo (cada vuelta de cron)

1. **Ejecutar el script**: `python scripts/verificar_mensajes_nuevos.py`.
2. Si exit 1: para cada pendiente listado → **leer el archivo completo** → **responder**, sacando el número del `NUMEROS_DISPONIBLES.txt` DE la carpeta destino y **borrando ese número del pool** en el mismo acto (el pool lo comparten el agente y el director — regla del fundador 02:27).
3. Si el pool está desalineado (primer número ≠ máximo de la carpeta + 1): sanear ANTES de escribir. Los huecos del medio JAMÁS se reutilizan; el pool queda con 100 números consecutivos libres, UTF-8 sin BOM, LF.
4. Actualizar el puntero como lectura (opcional, informativo).
5. Toda escritura (respuestas, docs, journal): Python `io.open(p,'w',encoding='utf-8',newline='\n')`. **PROHIBIDO** PowerShell `>`, `Set-Content` (incluso `-Encoding UTF8`: escribe BOM en PS 5.1) y la herramienta Write cuando corrompa UTF-8.

### Cronómetros (ambos con doble red, ninguno confía en punteros)

| Cron | Horario | Primera acción |
|---|---|---|
| **Cron A v3** | :00/:20/:40 | ejecutar el script y atender su salida (verificación por script) |
| **Cron B v3** | :10/:30/:50 | verificar LAG por canal (misma lógica, segunda red) |

## 5. Qué queda obsoleto (no reactivar)

- **V1 "barrido por puntero"**: comparar archivos contra `.ultima-revision` y filtrar por slug del receptor. OBLETO (casos Hy3 259 y Ling 177).
- **V2 "barrido full sin punteros"**: barría sin puntero pero seguía filtrando por slug del receptor al clasificar emisor. OBSOLETO (el filtro ocultó DS-OC 131-133).
- Cualquier instrucción anterior de crons que diga "leé tu riel de procesado" o "registers contra .ultima-revision" como paso de decisión: **superseded por este documento**.

## 6. Evidencia de la validación (2026-10-19 02:40-03:00)

- Script detectó **7 pendientes** reales en 3 canales (agnes 770-772, Hy3 267-268, Ling 177-178) que V1/V2 no vieron.
- Respondidos los 7 con los números del pool de cada carpeta: agnes #773, Hy3 #269, Ling #179; pools saneados (agnes 774-872, Hy3 270-398, Ling 180-314).
- Hallazgo lateral de la vuelta: CHECKLIST-GLOBAL.md re-dañado (BOM + mojibake por herramienta Write de agnes) → reparado con `fix_encoding.py` (reversible, 168 filas íntegras) y sello M112 `✅ Verificado por Hy3 2026-10-19` aplicado en fila 112.

**Nota 2026-10-19 03:10 (casi-error propio):** consumir el numero TOCANDO el pool en el MISMO acto de escribir el mensaje; entre tomar y escribir puede entrar un mensaje del agente y duplicar el numero. Si hubo esa ventana, re-verificar el pool antes del write y re-sacar el numero.

## 7. VALIDACIÓN DEL FUNDADOR (2026-10-19 04:29)

> Cita literal del fundador (04:29): "esta estrategia si esta funcionando muchisimo mejor por lo que veo. dejalo documentado". **MÉTODO V3 VALIDADO.**

**Métricas de la noche (02:36 -> 04:29, 13 vueltas de Cron A/B):**

- Detección inicial: **7 mensajes invisibles** para V1/V2 descubiertos en la primera corrida del script (agnes 770-772, Hy3 267-268, Ling 177-178).
- Desde entonces: **9 pendientes nuevos** detectados y respondidos EN LA MISMA VUELTA (agnes #777, DS-OC #137/#139/#141, DeepSeek #316, Step-5 #082, G-5.3 #073/#075/#077).
- Latencia de respuesta: de horas (DS-OC 131-133 colgaron ~4 h) a **una vuelta (<=20 min)**.
- Backlogs: de 5-14 pendientes contables a **97-201 reales por agente** (los 7 canales al 100+ con tareas de 05-Checklist reales).
- CADA vuelta cerró con **TOTAL sin responder: 0 / exit 0** salvo las que traían novedad, y esa novedad se consumía antes del siguiente cron.
- Correcciones de método aplicadas en vivo sin romper el ciclo: consumo atómico del pool, convención de lista plana (agnes), saneo de pools con BOM, flips de pendientes en backlogs.

**Alcance del sello:** el V3 queda como ÚNICO método de detección del director; esta sección + `Mensajes entre modelos/GUIA-COMUNICACION.md` son la referencia para toda la flota.

