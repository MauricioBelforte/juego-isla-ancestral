**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 146-Diseno-Emocional
**Estado:** Implementación operativa (entregable M146)

---

# Mapeo Emocional (`emotional-mapping`) — Módulo 146

> Dónde vive cada emoción de la paleta según fase del juego, mecánica, momento del día y estación. Fuente de fases: M145 `player-journey.md` §1; estaciones: M29; día/noche: M31.

## 1. Por fase del juego

| Fase | Emoción dominante | Apoyo | Cuidado especial |
|---|---|---|---|
| Introducción (0-30 min) | Curiosidad + Calma | Asombro (primer amanecer) | No saturar: 1 solo pico de asombro |
| Primeras horas (30 min-3 h) | Satisfacción + Calma | Curiosidad (mapa que se abre) | Micro-satisfacciones cada 5-15 min |
| Juego principal (3 h+) | Calma + Pertenencia | Satisfacción, asombro dosificado | Alternar libre/exploración/ social (evitar rutina) |
| Progresión (Sellos) | Satisfacción + Asombro | Curiosidad (misterio) | Cada Sello cierra con revelación, no con grind |
| Postgame | Nostalgia + Pertenencia | Calma | Sin presión de completado (M94) |

## 2. Por mecánica

| Mecánica | Emoción objetivo | Diseño emocional clave |
|---|---|---|
| Construcción (M17) | **Satisfacción** | Progreso visible, resultado persistente, confeti de cierre (M145 feedback) |
| Exploración (M27/M10) | **Curiosidad** | Siluetas que preguntan, rumores (M148), recompensa siempre a < 5 min del anuncio visual |
| Socialización (M19/M20/M21) | **Pertenencia** | NPCs recuerdan (diálogos contextuales M162), regalos, rutinas visibles (M64) |
| Progresión (M22/M158) | **Logro/Satisfacción** | Sellos con ceremonia de revelación; herramientas con ritual de forja |
| Decoración (M17/M18) | **Nostalgia** | Objetos con historia (recuerdos de eventos), la casa como diario espacial |
| Agricultura/Pesca (M33/M34) | **Calma** | Ciclos lentos, sin muerte permanente de cultivos, rhythm suave |

## 3. Por momento del día (M31: 5 franjas)

| Franja | Emoción | Notas |
|---|---|---|
| Alba | Asombro suave | Luz cálida baja (M49), pájaros (M42); mejor momento para vistas |
| Día | Calma productiva | Música de base, actividad plena |
| Atardecer | Nostalgia temprana | Paleta dorada/rosada; NPC camino a casa (rutinas) |
| Noche | Calma íntima | Linternas, luciérnagas (M52), diálogo más personal |
| Noche profunda | Curiosidad leve | Sonidos únicos, estrellas; sin peligro real (cozy) |

## 4. Por estación (M29: 4 estaciones, año de 336 días)

| Estación | Emoción dominante | Contenido emocional |
|---|---|---|
| Primavera | Curiosidad renovada | Todo florece; nuevos cultivos; inicio natural de partidas |
| Verano | Calma festiva | Festivales grandes (M74), playa, actividad social |
| Otoño | Nostalgia | Paleta ámbar, cosechas, cierre de arcos menores |
| Invierno | Pertenencia | Calor del hogar, eventos al abrigo, comunidad reunida |

## 5. Diagrama del mapeo (ASCII)

```
Asombro  ▲                    ×                 ×
Satisfac. │      ▄▄    ×···▄▄···×···▄▄    ×···▄▄
Pertenenc.│         ····           ····▄▄·····▄▄▄
Curiosidad│   ▄···▄···        ····
Calma    ▲━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━▶ tiempo
         Intro(30m) Primeras horas  Principal  Progresión→Postgame
```

Leyenda: `━━` calma constante (fondo) · `▄` picos de satisfacción · `×` asombro dosificado · `····` pertenencia creciente.

## 6. Gaps y sobre-emociones detectados

- **Gap revisado (2026-08-28):** la fase "Primeras horas" concentra satisfacción; la pertenencia llega tarde (primer NPC solo en M138 slice). Mitigación: el primer NPC (Finneas) aparece en la introducción y las rutinas visibles tempranas evitan sentir la isla vacía.
- **Sobre-emoción a evitar:** nunca un festival (pertenencia) inmediatamente después de una revelación de Sello (asombro+satisfacción): mínimo 1 sesión de calma entre picos.
- **Validación con jugadores:** pendiente de playtest (M114) — ver `playtesting-guide.md`.

## 7. Documento completo

Este documento + `emotional-palette.md` + `wow-moments.md` constituyen el mapeo completo; cualquier mecánica nueva debe añadir su fila en §2.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
