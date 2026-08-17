**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 20: Sistema de Amistad

## 1. Alternativas consideradas

### Alternativa A: Amistad con decaimiento pasivo
Modelo clasico (Stardew Valley con corazones que decaen, Animal Crossing original con flores marchitas): si el jugador no interactua con un vecino durante X dias, los puntos de amistad bajan lentamente.

- **Pros:** presiona al jugador a mantener el contacto; da peso a la rutina diaria; feedback clara de relacion viva.
- **Contras:** genera ansiedad por ausencia; contradice el pilar "sin FOMO" (seccion 93 del plan maestro: "Evitar castigar al jugador por ausentarse"); molesta a jugadores casuales; obliga a visitas de mantenimiento que se sienten como tarea.

### Alternativa B: Amistad acumulativa sin decaimiento (ELEGIDA)
Los puntos solo aumentan con interacciones positivas y jamas disminuyen por inactividad. El progreso queda congelado mientras el jugador no juega, nunca retrocede.

- **Pros:** maxima afinidad con el piloto cozy y retencion sin FOMO; el jugador avanza a su ritmo; el juego se puede dejar semanas sin castigo; simple de balancear y de explicar al jugador.
- **Contras:** sin presion de contacto el ritmo de subida debe dosificarse (limite diario por vecino); riesgo de "farmear de golpe" si los limites no existen; el mundo se siente menos reactivo a la ausencia (mitigado con lineas de bienvenida, no con penalizacion).

### Alternativa C: Decaimiento solo por acciones negativas
Los puntos solo bajan si el jugador comete acciones hostiles explicitas (golpear con herramienta, regalar algo detestado repetidamente). La inactividad no afecta.

- **Pros:** retiene castigo cuando el jugador es genuinamente hostil; mantiene consequencia social.
- **Contras:** agrega complejidad de registro de "acciones negativas"; en un juego sin combate obligatorio y con tono amistoso el castigo punitivo sobra; riesgo de frustracion accidental (reacciones de Nuremburg: el jugador que no entiende por que bajo).

## 2. Decisiones y justificacion

| Decision | Opcion elegida | Justificacion |
|---|---|---|
| Decaimiento por inactividad | NO | Pilar "Retencion sin FOMO" (sec. 93): "evitar castigar al jugador por ausentarse" y "evitar recompensas obligatorias diarias" |
| Decaimiento por acciones negativas | NO (fuera de alcance base) | Cozy game sin hostilidad; si en el futuro se requiere, se implementa como alternativa C separada y documentada |
| Progresion | Acumulativa por puntos, niveles 0-10 | Recompensas escalonadas claras; un nivel = una recompensa tangible (receta, objeto, evento, historia) |
| Ritmo | Limite diario por vecino (1 regalo efectivo + 1 charla + 1 carta, segun M29) | Sin limite el sistema se farmea en un dia; con limite, una sesion corta (20-30 min) basta para avanzar todos los vecinos |
| Regalo duplicado | El evaluador pondera: amado > gusta > neutral > duplicado (puntos minimos) | El duplicado nunca da cero (no frustra) pero tampoco sube igual que el regalo adecuado; mantiene importancia de conocer gustos (M19) |
| Data | Reglas en Resources GDScript (FriendshipLevel, GiftPreference, FriendshipEvent) | Balanceable en editor sin tocar codigo; coherente con arquitectura data-driven del proyecto |
| Persistencia | Schema versionado por M26 | Compatibilidad con guardados futuros cuando se agreguen vecinos o niveles |

## 3. Impacto y riesgos

- **Impacto en M19:** los vecinos exponen gustos/disgustos, personalidad y estado emocional que M20 consume de solo lectura.
- **Impacto en M14:** el evaluador necesita metadatos de objeto (categoria, rareza, calidad, valor de regalo) expuestos por el inventario.
- **Impacto en M21:** el dialogo muestra frases por nivel de amistad; M20 emite `nivel_subido` para disparar nostalgia/contexto.
- **Impacto en M23:** las misiones de amistad consultan `nivel_minimo` y `evento_requerido` de M20.
- **Riesgo principal:** farmeo sin limite -> mitigado con limites diarios y "regalo de cortesia" de puntos minimos.
- **Riesgo secundario:** sensacion de progreso lento -> mitigado con recompensas pequenas entre niveles (frases, decorativos) y barras visibles de progreso.

## 4. Cierre

Se adopta la Alternativa B (acumulativa sin decaimiento) con limites diarios por vecino y data-driven. El sistema queda listo para implementacion delegada tras M19 y M14 (anotado en 04-Codigo.md).