**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 153-Objetivo-Final
**Estado:** Implementación operativa (entregable M153)

---

# Prueba de Visión O1-O19 (`prueba_vision`) — Módulo 153

> Checklist que **M114 (Playtest)** aplica en cada corte de playtest y que **M151 (Control Final)** aplica como verificación de terminación antes del lanzamiento. Fuente de criterios: `vision_contract.json` (única fuente del contrato).

## 1. Condiciones de la prueba

- **Duración:** 30-60 min por sesión de playtest (O11 requiere sesión larga ≥ 3 h).
- **Participantes:** mínimo 5 jugadores por corte (S1-S5 del plan de M145).
- **Captura:** formulario por objetivo (§3), más observación del facilitador.
- **Aprobación del corte:** ≥ 80 % de los objetivos aplicables marcados ✓; los objetivos con ✖ bloquean y generan hallazgo con módulo dueño.

## 2. Checklist O1-O19 (marcar por corte)

| O | Objetivo | Cómo se verifica en sesión | ✓/✖ |
|---|---|---|---|
| O1 | Aurora como Hogar | Telemetría `volver_a_casa` ≥1/sesión 30 min + pregunta "¿dónde fuiste primero?" | ☐ |
| O2 | Curiosidad por la siguiente isla | La isla siguiente es visible; pregunta "¿a dónde irías?" sin presión (sin FOMO, M152) | ☐ |
| O3 | Recordar a los NPC | Test de memoria tras 3 sesiones: ≥2 vecinos por nombre | ☐ |
| O4 | Curiosidad por las Ruinas | Aproximación espontánea sin tutorial (observación) | ☐ |
| O5 | Disfrutar construyendo sin historia | ≥15 min de construcción continua sin misión activa | ☐ |
| O6 | Poder ignorar la historia | QA: recorrido del mundo completo sin misiones | ☐ |
| O7 | Perseguir la historia cuando quiera | Objetivo activo siempre visible; cero ventanas de tiempo | ☐ |
| O8 | Construcciones que importan | Construir desbloquea contenido; persistencia verificada | ☐ |
| O9 | Decisiones que afectan el entorno | El mapa cambia con las elecciones; persistencia visual | ☐ |
| O10 | Comprender la Resonancia | Explicación con palabras propias (pregunta abierta) | ☐ |
| O11 | Mundo continúa tras créditos | Sesión larga: 10+ h de postgame con contenido propio | ☐ |
| O12 | Ampliar sin romper arquitectura | Chequeo modular (M07/M15): isla nueva sin tocar sistemas | ☐ |
| O13 | Contenido que reutiliza sistemas | Revisión de 04-Codigo de módulos nuevos (cero duplicación) | ☐ |
| O14 | Mundo coherente | QA transversal de contradicciones (canon M147) | ☐ |
| O15 | Tecnología al servicio de la experiencia | Cobertura O# en 01-Requerimientos (validate_vision) | ☐ |
| O16 | Experiencia al servicio de la historia | Cada mecánica refuerza un hilo narrativo | ☐ |
| O17 | Historia refuerza identidad | Lore integrado en ruinas/documentos/colecciones (M73/M148) | ☐ |
| O18 | Mundo agradable sin eventos | Sesión de 30 min de inactividad disfrutable | ☐ |
| O19 | Quedarse mirando el mar | 2+ pausas de 5 min sin input (telemetría `pausa_contemplativa`) | ☐ |

## 3. Formulario por objetivo (por jugador)

```markdown
O{n} — {título}
- ¿Lo viviste? (sí/no/parcial)
- ¿Qué sentiste? (palabras propias — sin sugerir emociones)
- Minuto aproximado: ____
- Nota del facilitador: ____
```

## 4. Criterios de aprobación y flujo

1. Corte aprobado: ≥ 80 % de aplicables en ✓ y **cero** ✖ en objetivos Must del hito activo.
2. Cada ✖ genera: hallazgo con módulo dueño (de `vision_contract.json`) → log → corrección → re-test en el siguiente corte.
3. **Retest tras cada regresión principal** (parche mayor, cambio de sistema central).
4. M151 (Control Final): los 19 en ✓ son condición de terminación; **el juego no se lanza sin O1-O19 aprobado** (aprobación única del fundador documentada en acta).
5. Resultados por corte se archivan en `Mensajes entre modelos/` o el reporte mensual de M133, y alimentan el tablero de métricas de M145.

## 5. Estado

- ⏳ **Pendiente de ejecución real:** requiere build jugable (M138+). La instrumentación de los eventos de telemetría (`volver_a_casa`, `acercarse_puerto`, `aproximacion_ruinas`, `bloque_construccion`, `pausa_contemplativa`) corresponde a M105 cuando implemente telemetría (ítems `[?]` del checklist, programados).

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
