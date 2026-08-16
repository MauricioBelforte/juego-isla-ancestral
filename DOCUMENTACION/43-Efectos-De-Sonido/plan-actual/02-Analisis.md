**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 43: Efectos de Sonido

## 1. Resolución de los 25 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Pasos | 6 superficies (hierba, madera, piedra, tierra, nieve, arena) × 4+ variaciones; pitch random ±4% |
| 2 | Correr | Mismo material con ritmo doble y volumen +3 dB; activado por M34 (estado corriendo) |
| 3 | Saltar | Despegue suave (swoosh + tierra) en M34 salto; variación por superficie |
| 4 | Caer | Aterrizaje por altura de caída: 3 rangos (suave, media, fuerte); sin sonido de daño violento |
| 5 | Nadar | Salpicaduras al entrar/salir (M34): entrada, avance por brazada, salida |
| 6 | Recoger | Recogida de objetos (M35): "click" suave + nota aguda positiva corta |
| 7 | Abrir | Apertura de cofres, cobertizos, puertas (M17): madera/cerrojo 3 variaciones |
| 8 | Cerrar | Cierre correspondiente: madera con golpe seco corto |
| 9 | Equipar | Equipar herramienta/vestimenta (M33): swish + clic; 2 variaciones |
| 10 | Herramienta | Uso de herramienta (pala/pico/hacha/regadera): por tipo; 4 variaciones |
| 11 | Bloque roto | Rotura del voxel (M13): por material (piedra, madera, tierra, cristal, metal); 5 variaciones |
| 12 | Bloque colocado | Colocación (M13): mismo material que roto pero impacto corto; 4 variaciones |
| 13 | Plantar | Siembra en parcela (M17): tierra + grano; 3 variaciones |
| 14 | Regar | Agua de regadera: chorrito + goteo; loop corto no molesto |
| 15 | Cosechar | Arranque de cultivo (M17): follaje + nota de logro ligera |
| 16 | Pescar | Pesca (M35): cast (línea), splash pez, bote + pez; variaciones de giro de carrete |
| 17 | Crafting | Mesa de trabajo (M20): golpes de trabajo por etapa + éxito (arpegio corto) |
| 18 | Compra | Comercio (M45): monedas + nota de éxito; 2 variaciones |
| 19 | Venta | Comercio (M45): monedas al revés + nota media; feedback distinto de compra |
| 20 | Diálogo | Chasquido de diálogo (M21): click de UI; NPC habla — voz sin SFX extra |
| 21 | Menú | Apertura/cierre de menús (M45/M46): papel/pergamino suave |
| 22 | Selección | Hover/navegación de items: clic corto muy suave |
| 23 | Confirmación | Aceptar/colocar: tono positivo ascendente (2 notas, familia M41) |
| 24 | Error | Rechazo/acción inválida: tono descendente suave (nunca buzz estridente) |
| 25 | Logro | Logro/desbloqueo: arpegio cálido de 3 notas (triada mayor) |

## 2. Decisiones clave

1. **Familia tonal compartida con M41:** los SFX usan la misma escala y timbres que la música (leitmotifs cortos en confirmación/logro) → coherencia auditiva total.
2. **Pool de 24 voces con prioridades:** 3-NCI0: pasos/ambiente < interacciones < UI. Los SFX de UI nunca se cortan entre sí (prioridad alta).
3. **Variaciones anti-repetición:** 4-6 variaciones por tipo + pitch/banda aleatoria suave (PRNG de partida, M29) — sin "clic de metralleta".
4. **Ducking recíproco:** SFX -6 dB durante diálogos (M21) y música se empuja -6 dB (M41) durante logros — jerarquía clara.
5. **Error amable:** feedback negativo con tono descendente de tríada menor suave, 0.4 s — informa sin castigar.

## 3. Alternativas descartadas

- **SFX generados con síntesis procedural en runtime:** carga de CPU y timbres sintéticos; descartado (assets + variaciones).
- **Un AudioStreamPlayer por efecto sin pool:** quiebres/pops y gasto de memoria; descartado (pool de 24).
- **Pasos con un audio genérico para todas las superficies:** feedback pobre; se exige 6 superficies diferenciadas.