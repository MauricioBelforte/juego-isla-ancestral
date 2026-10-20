# RF26 — Guía de textos críticos: frases cortas y vocabulario simple

**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 09:55 (UTC)
**Módulo:** 28-Accesibilidad de textos (RF26 del 05 real de M58 — ítem [44] de la cola repoblada del director)
**Destinatarios:** redactores de diálogos (M21), tooltips (M16), toasts (M56), tickets (M28), misiones (M74) — cualquier texto del juego visible al jugador.

## Regla de oro (criterio de aceptación)

Un jugador de 10 años, con español básico o leyendo con prisa, entiende el mensaje en **una sola lectura** — sin releer, sin jerga, sin ironía ambigua.

## 1. Frases cortas

| Regla | Límite | Ejemplo MAL | Ejemplo BIEN |
|---|---|---|---|
| 1.1 Máximo de palabras por frase | 12 | "Deberías considerar la posibilidad de guardar tu progreso antes de continuar explorando la isla" | "Guarda tu partida antes de seguir explorando" |
| 1.2 Una sola idea por frase | 1 | "Craftea el pico y ves a la mina y mina el cobre" | "Craftea el pico. Luego ve a la mina" |
| 1.3 Sin subordinadas anidadas | 0 niveles | "El objeto que compraste que te dijeron que daría bug" | "El objeto comprado tiene un bug" |
| 1.4 Voz activa siempre | — | "Los materiales fueron retirados por el sistema" | "El sistema retiró los materiales" |
| 1.5 Imperativo directo en acciones | — | "Se procederá al guardado de la partida" | "Guarda la partida" |

## 2. Vocabulario simple

| Regla | Evita | Usa |
|---|---|---|
| 2.1 Sin anglicismos evitables | "feedback", "loot", "quest" | respuesta, botín, misión |
| 2.2 Sin tecnicismos del motor | "payload", "invariante", "checkpoint de escena" | "datos", "regla", "punto de guardado" |
| 2.3 Sin ironías ni sarcasmo | "¡Genial, otra vez sin Inventariamente!" | "No hay espacio de inventario" |
| 2.4 Sin dobles negaciones | "No es imposible que no falte" | "Puede faltar" |
| 2.5 Nombres del juego consistentes | sinónimos libres (isla/continente/mundo) | usa SIEMPRE el glosario del juego (ver sección 4) |

## 3. Estructura de los mensajes críticos

**3.1 Mensajes de error** — 3 partes separadas por espacios largos o línea: (a) QUÉ pasó, (b) QUÉ pierdes, (c) QUÉ hacer.
> Ejemplo: "Inventario lleno. No se perdió nada. Libera espacio y vuelve a craftear."

**3.2 Mensajes de éxito** — QUÉ ganaste + dónde está.
> Ejemplo: "¡Pico de cobre listo! Está en tu inventario."

**3.3 Toasts** — máximo 1 frase + icono. Sin detalles (van al log).
> Ejemplo: "Partida guardada"

**3.4 Diálogos de misión** — objetivo en la PRIMERA frase.

## 4. Glosario canónico (los términos que SIEMPRE se escriben igual)

- isla (no continente, no mundo) · pico · hacha · semilla · árbol · cobre (mineral), madera ·金钱 → monedas · guardado (no save) · misión (no quest) · contrastes WARNING (no error del sistema)

## 5. Checklist de revisión (antes de publicar un texto)

- [ ] Cada frase tiene menos de 12 palabras
- [ ] Una sola idea por frase
- [ ] Voz activa
- [ ] Sin anglicismos evitables
- [ ] Sin tecnicismos del motor
- [ ] Sin ironía
- [ ] Sin doble negación
- [ ] Glosario respetado (sección 4)
- [ ] Error = qué pasó + qué pierdes + qué hacer
- [ ] Éxito = qué ganaste + dónde está

## 6. Cómo auditar (para QA/なし reviewer)

1. Extrae los textos del catálogo (`data/balance/*.json`, `data/dialogos/`, `strings_es.json`).
2. Corre el conteo de palabras por oración (script Python, ejemplo en la cola del director si se pide).
3. Marca las frases > 12 palabras y los términos del glosario incumplido.
4. Propón el rewrite con la tabla de la sección 1/2.

## Estado

- Este documento es la **guía vigente RF26** — los dueños de M21/M16/M56/M28 la aplican al escribir.
- **QA de esta guía**: la verificación léxica (script de conteo) queda como item siguiente del dueño M58 si quiere automatizarla.
- Sin cambios de código del juego (documental puro).

Firma: G-5.3-Flash-Agente / Kilo Code.
