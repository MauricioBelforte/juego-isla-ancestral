**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 44: ASMR y Feedback

## 1. Resolución de los 17 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Sensación cortar madera | 3 golpes ascendentes (1º seco, 2º rumble, 3º crujido) + astillas al caer (M13/M43) — microfoley "ck-ck-ck" |
| 2 | Sensación de cavar | Golpe blando + tierra suelta + granulación al retirar (2 capas M43) |
| 3 | Sensación de picar piedra | 3 golpes: percusión seca + gravilla + eco corto del filo |
| 4 | Sensación de colocar bloques | Impacto corto + "clic" de encaje (satisfacción); sin thud fuerte |
| 5 | Sensación de cosechar | Rizoma de follaje + nota ligera ascendente (M43 logro suave) |
| 6 | Sensación de cocinar | Sizzle + chasquido de grasa + vapor sibilante (loop corto, jamás agresivo) |
| 7 | Sensación de abrir cajas | Cofre: cerrojo + madera + crujido de tapa (2 variaciones) |
| 8 | Caminar superficies | Microfoley por superficie (M43 6 tipos) con reverb contextual del interior |
| 9 | Sonido sincronizado con animaciones | Disparo en keyframes (M34): eje temporal alineado ±15 ms del impacto visual |
| 10 | Capas de sonido | Estructura de 4 capas estrictas (abajo→arriba): 1) ambiente M42, 2) acción M43, 3) microfoley M44, 4) respuesta M41 (solo eventos narrativos y logros) |
| 11 | Microfeedback | Chasquidos: recoger item (click+nota), sembrar (click tierra), abrir inventario (click pergamino), navegar (clic suave) |
| 12 | Evitar sonidos agresivos | Blacklist: distorsión de clip, frecuencias 2-4 kHz sostenidas, buzz, scare chords; revisión de master en pooled master test |
| 13 | Evitar saturación | Limitador maestro -1 dBFS; bus SFX -6 dB headroom; sin más de 6 SFX simultáneos (M43) |
| 14 | Ajustar volumen contextual | Reglas: interior -3 dB, debajo del agua muy suave (low-pass), lluvia/tormenta levantan ambiente +2 dB y bajan SFX -2 dB |
| 15 | Ajustar distancia | Distancias max: pasos 15 m, romper 20 m, mundo 30 m (M43); con fade suave por cierre de oclusión |
| 16 | Ajustar reverberación | Reverb por interior: cueva 1.5 s, templo 1.2 s, ruinas 1.0 s, casa 0.5 s, exterior 0.15 s (M42/refuerzo) |
| 17 | Ajustar oclusión | Oclusión RayCast solo en interiores críticos (cueva/templo): paso de muro atenúa 30% y filtra bajos |

## 2. Decisiones clave

1. **La "sensación" es una receta de capas** (no un solo archivo): cada acción define qué capas de M42/M43/M44 se apilan y en qué orden — verificable y sin duplicar assets.
2. **Sincronía por keyframes de animación (M34):** el sonido se dispara en el fotograma del impacto, nunca en el inicio de la animación (evita el desfase "fantasma").
3. **Microfoley = el 5º pilar covert:** chasquidos mínimos, dulces y premiadores en cada interacción; volumen bajo (-18 dB sobre el SFX base).
4. **Blacklist anti-agresión verificable:** revisión automática de pico (AnalyserNode/sidechain) en test M112: ningún evento supera -3 LUFS de pico; frecuencia sostenida prohibida detecta buzz.
5. **Ajustes contextuales con precedencia fija:** interior > clima > día/noche (si chocan, gana interior; M42/M36).

## 3. Alternativas descartadas

- **"ASMR con grabaciones reales crudas"** (ej. cortar madera real con muchos micrófonos): inconsistentes con el resto del audio y pesados; descartado (se diseñan las sensaciones como capas de assets).
- **Binaural/HRTF completo:** requiere headphones fijos; descartado para el público cozy (se mantiene 3D estándar + reverb).
- **Reverb global único de escena:** mata la personalidad de interiores; descartado (se usa el reverb por interior de M42).