# Log 39 — Creación del Componente 65: Animales IA (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Hora:** 01:20

## Descripción breve

Se documentó el **Módulo 65 — Animales IA** en `DOCUMENTACION/65-Animales-IA/` como módulo **delegable**. Resuelve los 19 puntos de la sección 64: herbívoro, acuático, aéreo, nocturno, migratorio, estacional, reproducción, descanso, alimentación, huida no violenta, curiosidad, interacción con entorno, sonidos contextuales y spawns/despawns con optimización y control de población.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | Problema, objetivos, alcance, restricciones cozy |
| `plan-inicial/02-Analisis.md` | 19/19 puntos resueltos; 4 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | FSM 10 estados, perfiles, manadas/bancos, spawns, presupuesto, QA |
| `plan-inicial/04-Codigo.md` | Archivos propuestos, API, reglas + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **100 ítems**, 100 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M65 → 🟢 Disponible, 100/100, **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 65 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 39.

## Decisiones

- **Reuso del orquestador de M64**: la fauna es una capa (`FaunaManager`) del mismo sistema; jamás un sistema paralelo.
- **Burbuja de simulación heredada**: 64 m; si el presupuesto M61 se excede, se reduce la burbuja de fauna (penalización ambiental), nunca la de NPC.
- **FSM datos-driven** con agenda y 10 estados; reproducción con nido y crías sin loot (regla cozy anti-explotación).
- **Sin muerte visible ni caza**: hambre agotada → emigración suave; registro M36 solo por avistamiento.
- **Validación de slots y revalidación por chunk** ante cambios de terreno (M08/M28) con teleport discreto anti-atasco.