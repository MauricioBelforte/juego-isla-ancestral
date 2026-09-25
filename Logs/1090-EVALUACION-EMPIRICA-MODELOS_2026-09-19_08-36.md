# Log 1090: Evaluacion empirica de modelos con evidencia real del repositorio

**Fecha:** 2026-09-19
**Hora:** 08:36
**Modelo:** Atria-Dawn-Preview (Shanghai AI Laboratory)
**Plataforma:** Kilo Code

## Resumen

Se creo el documento `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md`,
que reemplaza los benchmarks vendor-reported por **evidencia real verificada en este
repositorio** (2026-09-18 / 2026-09-19). El proposito es que la asignacion de tareas
se apoye en fortalezas **medidas**, no declaradas.

El usuario confirmo el nombre del archivo ("me gusto el nombre que le pusiste").

## Cambios Realizados

- Creado `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md` (298 lineas,
  16.4 KB, UTF-8 sin BOM, 0 lineas con mojibake).
- Verificado con lectura binaria + regex de deteccion (`Ã|Â|â€|ï¿½|ðŸ`): 0 coincidencias.
- Reservado el log 1090 (protocolo v3, `Logs/NUMEROS_DISPONIBLES.txt`).

### Que documenta el archivo

| Seccion | Contenido |
|---|---|
| 1 | Como se midio: metricas reales (checks con binario Godot 4.7.2, anti-falso-verde exit+0 SCRIPT ERROR, conteo de `[x]`, drift) |
| 2 | Tabla por modelo: kimi-k3, mimo-v2.5, hy3, agnes-3-flash, nex-n2.5-pro |
| 3 | Hallazgos clave (incluido el claim falso de Nex y la honestidad de Agnes) |
| 4 | Recomendaciones de asignacion por tipo de tarea |
| 5 | Como actualizar el documento (cada nueva entrega verificada) |

Principales evidencias registradas:

- **kimi-k3**: 4/4 tareas de seguridad en M106 con suites rc=0 (CyberGym 86.5 confirmado
  en trabajo real, no en paper).
- **mimo-v2.5**: 6 suites verificadas (M11, M64, M107, M115, M12) + QA visual fauna
  aprobado (Log 1061).
- **hy3**: 9 suites rc=0, 0 SCRIPT ERROR; cerro el bug real player.gd:972 (BUG-060).
- **agnes-3-flash**: honestidad documentada (M31 con 0 flips reales, M51 duplicados
  encontrados en vez de ocultados).
- **nex-n2.5-pro**: claim "0 SCRIPT ERROR propios" **FALSO** — habia 1 real que Hy3 cerro.

## Archivos Modificados/Creados

- `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md` (creado)
- `Logs/NUMEROS_DISPONIBLES.txt` (numero 1090 consumido)
- `Logs/1090-EVALUACION-EMPIRICA-MODELOS_2026-09-19_08-36.md` (este log)

## Notas

- Este documento es **vivo**: cada entrega verificada de un modelo debe sumarse a su
  seccion (proceso descripto en la seccion 5 del propio archivo).
- No se uso ningun benchmark de internet; toda afirmacion se respalda con un Log
  concreto o una suite ejecutable.
