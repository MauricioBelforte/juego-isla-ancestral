# 01 — Requerimientos — M22: Historia Principal

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

La isla ancestral necesita una Historia Principal completa y coherente con el mundo (misterio de los Sellos, la civilización caída y el Templo de la Brisa) que guíe al jugador por los 7 capítulos, presente giros, pistas y revelaciones, y ofrezca finales (principal, alternativos y secreto) sin perder el tono **cozy**.

## Objetivos

- Resolver los 25 puntos de la sección 21 del plan maestro (prólogo, 7 capítulos, finales, escenas, giros, pistas, foreshadowing, ritmo, momentos, secuencia de Templos y Sellos, misterio, exposición).
- Definir la estructura narrativa como **datos** (arco por capítulo, nodos de escena, puertas de progresión) para que M23 (secundarias) y M68 (misiones) la consuman.
- Integrar con la cadena de templos (M24/M25/M26) y con el sistema de progresión de mundo (M21/misiones).

## Alcance

- Prólogo y 7 capítulos + capítulo final.
- Final principal, finales alternativos y final secreto (registrable y verificable).
- Escenas principales, giros, pistas, foreshadowing, revelaciones.
- Ritmo (momentos emotivos/calma/descubrimiento), secuencia de Templos y de Sellos.
- Desarrollo del misterio e información oculta; anti-exposición.

## Fuera de alcance

- Diálogos línea por línea (M23 sec.) y cinemáticas (M33) — solo se define el esqueleto.
- Misiones/JPS de combate (M68) — solo se definen los hooks de verificación.
- Música/cine (M31/M41/M44) — solo los momentos emocionales a los que atan.

## Restricciones

- **Cozy:** la historia jamás castiga al jugador; los momentos tensos son acogedores (el "misterio" se resuelve con descubrimiento, no con miedo).
- **Anti-exposición:** cada lore se entrega en contexto (murales de M25, insignias de M26), nunca en bloques.
- **Datos-driven:** la Historia Principal se serializa (JSON) y valida (sin referencias rotas a nodos/escenas).
- Integración con M66 (softlock: ninguna trama debe poder quedar sin completar por estado del mundo roto).
- Documentación `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 25 puntos de la sección 21 resueltos y verificables en la suite (cada capítulo tiene nodos válidos).
2. La historia se juega de punta a punta sin exposición excesiva (tests de guion: % de diálogo por escena > límite).
3. Los 3 finales (principal, alternativos, secreto) son alcanzables según reglas documentadas.
4. Cero softlocks de trama (todo gating verificable por M66).