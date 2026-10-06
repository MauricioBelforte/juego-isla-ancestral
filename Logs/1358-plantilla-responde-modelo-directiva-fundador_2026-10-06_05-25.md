# Log 1358: Plantilla de mensaje — "Responde a" ahora nombra al MODELO (directiva del fundador)

**Fecha:** 2026-10-06
**Hora:** 05:25
**Modelo:** atria-dawn-preview
**Plataforma:** Kilo Code

## Resumen

Directiva del fundador: el encabezado de todo mensaje entre modelos ahora dice **a qué modelo**
se responde, además del archivo. Objetivo: ver de un vistazo **entre qué modelos** se escribe en
cada hilo, incluso cuando el director no participa (ej: Hy3↔mimo por la QA del M64, agnes→s2 con
sus auditorías).

## Cambios Realizados

### Formato nuevo

Antes:

```
**Responde a:** 28-2026-10-06_01-57-34-mimo-a-mimo-informe-cierre-m88-iter3-verificacion.md
```

Ahora:

```
**Responde a:** mimo-v2.6-flash-free — 28-2026-10-06_01-57-34-mimo-a-mimo-informe-cierre-m88-iter3-verificacion.md
```

El campo tiene **dos partes**: el modelo al que se responde (emisor del mensaje anterior del canal)
y el archivo.

### Archivos modificados

- **`scripts/reservar_mensaje.py`** — el helper ahora extrae el `**Modelo:**` del mensaje anterior
  de la carpeta destino y rellena ambos campos automáticamente. Fallback
  `(canpeta vacia: es el primer mensaje)` / `(canal nuevo, sin mensaje previo)` si no hay anterior
  o no se puede leer. Probado en el canal kimi-k3 (plantilla correcta, número devuelto al pool).
- **`AGENTS.md` §10.2 regla 5** — actualizada con el formato `<MODELO> — <archivo>` y la nota de
  la directiva. También el ejemplo del §10.1 (Modo Tema).
- **`Mensajes entre modelos/GUIA-COMUNICACION.md`** — sección nueva "Encabezado del mensaje:
  `Responde a` nombra al MODELO" con reglas (primer mensaje de canal, no renombrar históricos,
  fallback a mano) + actualización de la sección "Cómo reservar" + trampa **T-17** agregada +
  firma renovada (05:20).
- **`Mensajes entre modelos/ESTADO-PARALELO.md`** — aviso "📌 2026-10-06 05:20" arriba del todo,
  donde todos los modelos leen al arranque. Aclara que el comando del helper **no cambia**.

### Reglas

- **No se renombran** los mensajes anteriores a 2026-10-06 (rompería referencias cruzadas).
- Los mensajes nuevos (a partir de ahora) llevan el formato nuevo.
- El helper es la fuente: reservar sin él requiere completar el campo a mano.

## Archivos Modificados/Creados

- `scripts/reservar_mensaje.py`
- `AGENTS.md`
- `Mensajes entre modelos/GUIA-COMUNICACION.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md`
- `Logs/1358-...este log...`
- `Logs/NUMEROS_DISPONIBLES.txt` (1509 consumido; cabezas 1507/1508 tomadas por otros agentes en
  paralelo durante esta sesión — logs aún no escritos en disco al momento de este commit)

## Notas

- El pool de logs amaneció con saltos: al terminar la jornada anterior la cabeza era 1507, pero
  otros agentes tomaron 1507 y 1508 mientras se escribía este log. Se tomó **1509** (siguiente
  libre real). Huecos pendientes de quienes aún no escribieron sus logs.
