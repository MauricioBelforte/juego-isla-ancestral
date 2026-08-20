**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 02-Analisis.md — Módulo 150: Diseño Sonoro Narrativo

## 1. Análisis de los puntos del plan maestro (sección 149)

| # | Punto | Resolución |
|---|---|---|
| 1 | Sonido distintivo de Aurora | ✅ Sonido distintivo de Aurora (personaje principal): suave, acogedor, naturaleza (aves, viento) |
| 2 | Sonido distintivo de Resonancia | ✅ Sonido distintivo de Resonancia (mecánica central): místico, vibrante, energía (resonancia, campanas) |
| 3 | Sonido distintivo de cada Sello | ✅ Sonido distintivo de cada Sello (decisión del jugador): cada Sello tiene sonido único (cello, piano, flauta, etc.) |
| 4 | Sonido distintivo de Elysia | ✅ Sonido distintivo de Elysia (antagonista): tenso, misterioso, oscuro (campanas distantes, bajo) |
| 5 | Sonido distintivo de cada templo | ✅ Sonido distintivo de cada templo (bioma, tema): cada templo tiene sonido único (hielo, volcán, bosque) |
| 6 | Sonido distintivo de descubrimientos | ✅ Sonido distintivo de descubrimientos (new locations, items): brillo, campana, swoosh |
| 7 | Sonido de misterios | ✅ Sonido de misterios (secretos, lore): susurro, eco, ambiente tenso |
| 8 | Sonido de puertas antiguas | ✅ Sonido de puertas antiguas (mecanismo, apertura): engranaje, rocas, eco |
| 9 | Sonido de máquinas | ✅ Sonido de máquinas (tecnología ancestral): zumbido, chisporroteo, energía |
| 10 | Sonido de telemetría ancestral | ✅ Sonido de telemetría ancestral (UI, feedback): beep, chirp, tono suave |
| 11 | Diseñar leitmotifs sonoros | ✅ Leitmotifs sonoros para personajes, islas, temas (repetición con variación) |
| 12 | Variar intensidad | ✅ Variar intensidad según contexto (calma, tensión, peligro) |
| 13 | Usar silencio narrativamente | ✅ Silencio narrativo (pausas, énfasis, tensión) |

## 2. Sonido distintivo de Aurora

**Aurora (personaje principal):**
- Sonido suave y acogedor
- Tema: naturaleza (aves, viento, agua)
- Instrumentos: flauta, piano suave, cuerdas
- Frecuencia: aparición en historia, interacciones importantes
- Leitmotif: repetición con variación según contexto (calma, tensión, peligro)

**Implementación:**
- Event trigger: Aurora aparece → leitmotif de Aurora
- Event trigger: Aurora habla → diálogo con leitmotif de fondo
- Event trigger: Aurora está en peligro → leitmotif tensa

## 3. Sonido distintivo de Resonancia

**Resonancia (mecánica central):**
- Sonido místico y vibrante
- Tema: energía (resonancia, campanas, vibración)
- Instrumentos: campanas, sintetizadores, bajo
- Frecuencia: uso de Resonancia, descubrimiento de nueva tecnología
- Leitmotif: repetición con variación según intensidad

**Implementación:**
- Event trigger: jugador usa Resonancia → sonido de Resonancia
- Event trigger: Resonancia se carga → sonido de carga
- Event trigger: Resonancia se activa → sonido de activación

## 4. Sonido distintivo de cada Sello

**Sellos (decisión del jugador):**
- Cada Sello tiene sonido único
- Tema: instrumento distintivo por Sello
- Instrumentos: cello (Sello 1), piano (Sello 2), flauta (Sello 3), etc.
- Frecuencia: elección de Sello por el jugador
- Leitmotif: repetición al recordar Sello

**Implementación:**
- Event trigger: jugador elige Sello → sonido del Sello
- Event trigger: jugador recuerda Sello → leitmotif del Sello
- Event trigger: jugador completa Sello → variación del leitmotif

## 5. Sonido distintivo de Elysia

**Elysia (antagonista):**
- Sonido tenso y misterioso
- Tema: oscuro (campanas distantes, bajo, eco)
- Instrumentos: bajo, campanas distantes, eco
- Frecuencia: aparición de Elysia, cinemáticas
- Leitmotif: repetición con variación según contexto (misterio, peligro)

**Implementación:**
- Event trigger: Elysia aparece → leitmotif de Elysia
- Event trigger: Elysia habla → diálogo con leitmotif de fondo
- Event trigger: Elysia ataca → leitmotif tensa

## 6. Sonido distintivo de cada templo

**Templos (bioma, tema):**
- Cada templo tiene sonido único
- Tema: bioma (hielo, volcán, bosque)
- Instrumentos: cello (templo de hielo), bajo (templo de volcán), flauta (templo de bosque)
- Frecuencia: entrada a templo, puzzles
- Leitmotif: repetición en templo específico

**Implementación:**
- Event trigger: jugador entra a templo → leitmotif del templo
- Event trigger: jugador resuelve puzzle → variación del leitmotif
- Event trigger: jugador completa templo → variación final del leitmotif

## 7. Sonido distintivo de descubrimientos

**Descubrimientos (new locations, items):**
- Sonido de brillo y satisfacción
- Tema: descubrimiento (campana, swoosh, brillo)
- Instrumentos: campana, sintetizador brillante
- Frecuencia: descubrimiento de nueva isla, nuevo item, nueva mecánica
- Leitmotif: no aplica (sonido puntual)

**Implementación:**
- Event trigger: jugador descubre nueva isla → sonido de descubrimiento
- Event trigger: jugador descubre nuevo item → sonido de descubrimiento
- Event trigger: jugador desbloquea nueva mecánica → sonido de descubrimiento

## 8. Sonido de misterios

**Misterios (secretos, lore):**
- Sonido tenso y misterioso
- Tema: secreto (susurro, eco, ambiente tenso)
- Instrumentos: susurro, eco, sintetizador tenso
- Frecuencia: descubrimiento de secreto, lore oculto
- Leitmotif: no aplica (sonido puntual)

**Implementación:**
- Event trigger: jugador descubre secreto → sonido de misterio
- Event trigger: jugador encuentra lore oculto → sonido de misterio
- Event trigger: jugador entra a área misteriosa → ambiente tenso

## 9. Sonido de puertas antiguas

**Puertas antiguas (mecanismo, apertura):**
- Sonido de mecanismo antiguo
- Tema: antiguo (engranaje, rocas, eco)
- Instrumentos: engranaje, rocas, eco
- Frecuencia: apertura de puerta antigua, mecanismo de templo
- Leitmotif: no aplica (sonido puntual)

**Implementación:**
- Event trigger: jugador interactúa con puerta antigua → sonido de mecanismo
- Event trigger: puerta se abre → sonido de apertura
- Event trigger: puerta se cierra → sonido de cierre

## 10. Sonido de máquinas

**Máquinas (tecnología ancestral):**
- Sonido de tecnología ancestral
- Tema: tecnología (zumbido, chisporroteo, energía)
- Instrumentos: zumbido, chisporroteo, energía
- Frecuencia: interacción con máquina ancestral, uso de tecnología
- Leitmotif: no aplica (sonido puntual)

**Implementación:**
- Event trigger: jugador interactúa con máquina → sonido de máquina
- Event trigger: máquina se activa → sonido de activación
- Event trigger: máquina se desactiva → sonido de desactivación

## 11. Sonido de telemetría ancestral

**Telemetría ancestral (UI, feedback):**
- Sonido de UI suave
- Tema: tecnología ancestral (beep, chirp, tono suave)
- Instrumentos: beep, chirp, tono suave
- Frecuencia: UI feedback, telemetría ancestral
- Leitmotif: no aplica (sonido puntual)

**Implementación:**
- Event trigger: UI feedback → sonido de telemetría
- Event trigger: telemetría ancestral se actualiza → sonido de actualización
- Event trigger: telemetría ancestral se completa → sonido de completado

## 12. Leitmotifs sonoros

**Leitmotifs sonoros:**
- Repetición con variación
- Personajes: Aurora, Elysia, NPCs importantes
- Islas: cada isla tiene leitmotif
- Temas: cozy, tensión, peligro, misterio

**Implementación:**
- Leitmotif de Aurora: repetición con variación según contexto
- Leitmotif de Elysia: repetición con variación según contexto
- Leitmotif de cada isla: repetición en isla específica
- Leitmotif de cada templo: repetición en templo específico

## 13. Variación de intensidad

**Variación de intensidad:**
- Calma: leitmotifs suaves, piano, flauta
- Tensión: leitmotifs tensos, bajo, campanas
- Peligro: leitmotifs peligrosos, sintetizador, percusión

**Implementación:**
- Contexto calma → leitmotifs suaves
- Contexto tensión → leitmotifs tensos
- Contexto peligro → leitmotifs peligrosos

## 14. Silencio narrativo

**Silencio narrativo:**
- Pausas para énfasis
- Silencio para tensión
- Silencio para impacto

**Implementación:**
- Pausa después de evento importante → silencio narrativo
- Silencio antes de revelación → tensión
- Silencio después de música → impacto
