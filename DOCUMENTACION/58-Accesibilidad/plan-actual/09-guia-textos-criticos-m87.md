# Guía de Textos Críticos (RF26) — frases cortas y vocabulario simple

**Modelo:** G-5.3-Flash-Agente
**Plataforma:** Kilo Code
**Fecha:** 2026-10-20
**Fuente:** ítem RF26 de la cola de accesibilidad (repoblado por el director); consumidor: M87 localización, M53 UI, M59/M38 feedback.

## Propósito

Reglas para redactar/revisar los textos críticos del juego (avisos, confirmaciones, fallos, tutorial y prompts) con **frases cortas y vocabulario simple** asequibles para lectura fácil — y que luego traducen bien a EN/PT.

## Reglas de redacción (nas 7)

1. **Una idea por frase.** Máximo ideal ~8-10 palabras por oración; dos frases cortas > una con subordinadas.
2. **Verbo primero, imperativo amable donde aplica.** "Guardamos la partida" / "¿Guardar antes de salir?" — evitar nominalizaciones ("procedemos a la realización del guardado").
3. **Vocabulario cotidiano.** "Reparar" antes que "restaurar la integridad"; "materiales que faltan" antes de "insuficiencia de recursos".
4. **Sin negaciones dobles.** "No pudimos guardar" → sí; "no es imposible que no se guarde" → jamás.
5. **Cifras concretas.** "Faltan 2 de madera" mejor que "materiales insuficientes" solos (si el motor lo provee); el nombre del material entre comillas.
6. **Pronombres claros.** Cada "esto/eso" debe poder reemplazarse por su sustantivo sin ambigüedad.
7. **Tono no punitivo.** Los fallos informan, no culpan: "Faltan 1 de piedra caliza" (coherente con la filosofía MF11: el fallo no daña").

## Patrones por tipo de texto (ejemplos canónicos ES)

| Tipo | Patrón | Ejemplo ES |
|---|---|---|
| Confirmación | ¿[verbo infinitivo] + [objeto]? | "¿Guardar la partida en el slot 1?" |
| Éxito | [Objeto] + participle/pasado + (donde) | "Partida guardada correctamente." |
| Fallo recursable | "No se pudo…" + causa corta | "No se pudo guardar: la ranura está llena." |
| Fallo con remedio | "Faltan [n] de [material]." | "Faltan 2 de madera." |
| Aviso/bloqueo | "No puedes [acción]: [causa corta]." | "No puedes guardar ahora (hay un diálogo abierto)." |
| Tutorial (paso) | [Verbo] + [objeto] + [tecla/botón]. | "Golpea la veta con el martillo (E)." |
| Prompt de interacción | [Verbo infinitivo] + [objeto]. | "Reparar hacha" |

## Reglas multi-idioma (acuerdo M87)

- **Escuchar primero ES, luego traducir.** La frase ES corta y simple ES la que viaja a EN/PT — nunca traducir al unísono frases complejas.
- **Placeholders inviolables.** Los `{n}`/`%d` y nombres de ítems viajan IGUAL en las 3 lenguas; el orden puede cambiar, el número no.
- **Termas fijas por módulo.** Un objeto tiene UN nombre canónico por idioma (no sinónimos rotativos): revisar `strings_es/en/pt.json` ANTES de crear un concepto nuevo.
- **Regla PT del §28 del AGENTS:** cualquier cambio va con las 3 lenguas + .po es/en en el MISMO commit y `validar_t18n_integridad.py` EXIT 0.
- **Tildes/ñ UTF-8 sin BOM** (§28): un texto crítico con mojibake se considera ERROR crítico (se repara antes de otro contenido).

## Antipatrones (rechazos en revisión)

- Humor ambiguo o ironía en avisos (traduce mal y confunde).
- Jerga técnica (pool, provider, frame) en textos de jugador.
- Oraciones > 15 palabras en un aviso.
- Omisión de la cifra en fallos de recursos.
- Textos que asumen color/sonido para entenderse (accesibilidad RF12: nada crítico depender de oír un sonido específico o de ver solo un color).

## Checklist antes de flipar un ítem de texto

- [ ] Una idea por frase (≤ 10 palabras ideal).
- [ ] Vocabulario simple (sin jerga de motor).
- [ ] Cifras concretas cuando aplique.
- [ ] Clave definida en strings_es/en/pt + .po es/en, validador EXIT 0.
- [ ] Sin dependencia de color/sonido único para entenderse.
- [ ] Prueba mental de traducción EN/PT sin ambigüedad.
