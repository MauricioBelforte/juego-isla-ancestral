**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 31: Ciclo Día/Noche

## 1. Resolución de los 22 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Iluminación diurna | `DirectionalLight3D` (sol): rotación según hora del GameClock; curva de intensidad 0.25→1.0 (06:00→12:00), 1.0→0.2 (12:00→20:00); temperatura: mañana 5500K, mediodía 6200K, tarde 4200K (suave) |
| 2 | Iluminación nocturna | Luna `DirectionalLight3D`: intensidad 0.12-0.2 fija (no varía con fases; las fases lunares son visuales M29), color azul-gris (7500K); luz ambiental mínima 0.15 (ver anti-oscuridad) |
| 3 | Sombras | Solo el sol proyecta sombras dinámicas (cascada corta, 2 splits, radio ~30 m, M61); luna SIN sombras dinámicas (una luz por sombra). Sombreado suave (PCF) |
| 4 | Color ambiental | `WorldEnvironment` con ambiente de color por hora (gradiente 24 puntos Tween); estación modula: primavera fresco, verano cálido, otoño ámbar, invierno frío/pastel |
| 5 | Cielo | `ProceduralSkyMaterial`: gradiente zenith/horizonte por hora; energía Noon 1.0, Noche 0.18; horizonte con tinte perezoso en amanecer/atardecer (naranja→violeta) |
| 6 | Estrellas | Textura de estrellas en el cielo (canvas procedural, M45): visibilidad 0% de día → 100% a 22:00; parpadeo sutil estático (sin animación por frame) |
| 7 | Luna | Mesh esférico distante en el cielo + textura de fases sincronizada con calendario M29 (los 7 días del mes); tamaño cozy (aparente grande pero suave) |
| 8 | Nubes | `ProceduralSkyMaterial` clouds + capa de nubes volumétrica ligera (sin nubes 3D reales en v1; M50): velo 2D translúcido con drift lento; densidad por estación (invierno más cubierto) |
| 9 | Amanecer | 06:00-07:30 (90 s de juego): gradiente naranja/violeta, sol sube con curva senoidal suave; pajaros empiezan cantar (M42) |
| 10 | Atardecer | 19:00-20:00 (90 s: última hora tiene dos gradientes suaves + 60 s de ocaso tras 20:00): cielo naranja→índigo; se encienden luces artificiales al superar umbral 0.35 |
| 11 | Niebla | Fog volumétrico ligero (M61): matinal en otoño (07:00-09:00), bruma de calor en verano (13:00-16:00), niebla densa suave en invierno; densidad nocturna 0.25 |
| 12 | Luces artificiales | OMNI/SPOT por prefab de farol (refugio, casas, caminos): encendido automático por fase (umbral de luz), radio 8 m, tinte cálido 3200K; la linterna del jugador (M13) complation la navegación |
| 13 | Cambio comportamiento NPC | Franjas consultadas por M19: DÍA (06:00-18:59) actividades/tiendas; PRE-NOCHE (19:00-20:59) vuelven a casa; NOCHE (21:00-22:59) cena/descanso; NOCHE PROFUNDA (23:00-05:59) duermen; ALBA (06:00-06:59) salen las actividades |
| 14 | Cambio fauna | M36: fauna diurna deja de spawnear 20:00; nocturna (búhos, luciérnagas, zorros) 21:00-06:00; peces luna solo de noche (M34); insectos de luz cerca de faroles |
| 15 | Cambio música | M41: 4 variantes de tema por franja (día/alba/noche/profunda) + crossfade 3 s; sin música de "tensión" nocturna (cozy) |
| 16 | Cambio sonidos | M42: banco diurno (pájaros, agua, viento suave) ↔ nocturno (grillos, ranas, viento oscuro suave); transición por crossfade de buses |
| 17 | Cambio spawn de recursos | M15: flores lumínicas y "cristales estelares" solo 21:00-05:00; pesca nocturna distinta en luna llena; resto del catálogo sin restricción horaria (anti-frustración) |
| 18 | Cambio actividades | M34/M39: tiendas cerradas 21:00 (cartel "vuelvo mañana"); pesca disponible toda la noche; cultivos sin efecto horario (M33); museo con horario (M37) |
| 19 | Eventos nocturnos | Lluvia de estrellas (días 10 y 25 del mes, verificada por M29): partículas + jamás coincide con tormenta (M32); avistamiento del "lince de luna" (1 vez por mes, lore M148) |
| 20 | Secretos nocturnos | Flora brillante en Senda de las Luciérnagas (M24/geografía M09: POI); murales luminosos en ruinas (M25) visibles solo de noche; sin combate nocturno forzado (cozy) |
| 21 | Navegación nocturna | Luz ambiental mínima 0.15 + linterna (M13) + minimapa de M12 (no depende de luz) + caminos con faroles cada 40 m en poblado; la navegación nunca se vuelve "juego ciego" |
| 22 | Evitar oscuridad excesiva | Regla: **ambiente nocturno ≥ 0.15 en LDR post-tonemap**; gamma del jugador predeterminada; opción M58 "Noche clara" (sube piso a 0.35); prohibido renderear negro puro |

## 2. Decisiones clave

1. **Franjas duras (no horario continuo) para consumidores:** NPC/fauna/audio reaccionan a fases discretas (DÍA/PRE-NOCHE/NOCHE/PROFUNDA/ALBA), mientras que la iluminación sí es continua. Evita bugs de comportamientos a las 19:31 vs 19:32 y simplifica testing.
2. **Sin sombras de luna** (rendimiento, M61) — la luna solo da luz.
3. **Anti-oscuridad como regla de diseño:** 0.15 piso de ambiente nocturno + linterna + opción M58. El horror a lo oscuro NO es un género cozy.
4. **Neutralidad frustración:** recursos raros de noche son opcionales; nada crítico para la historia exige jugar de noche (M24/M22 lo respetan).
5. **Cielo procedural 2D + nubes velo** en v1 (sin volumétricos de pago): costo de GPU despreciable.

## 3. Alternativas descartadas

- **Nubes volumétricas 3D (Godot volumetric fog):** descartado por el gate de 60 FPS del proyecto (M61) en v1. Se evalúa post-v1.0 (FUTURAS-MEJORAS).
- **Sombras de luna:** descartadas (costo doble de shadow maps; ganancia visual mínima).
- **Ciclo de luz por estado global:** descartado (acoplaría M31 al GameState; el motor visual solo debe leer la hora por señal/API de M29).
- **Oscuridad "modo linterna" estilo survival:** descartada (rompe el pilar cozy y el anti-FOMO).