# Log 37 — Creación del Componente 63: Cargas y Streaming (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17 00:20:00

## Descripción breve

Se documentó el **Módulo 63 — Cargas y Streaming** en `DOCUMENTACION/63-Cargas-Y-Streaming/` como módulo **delegable** (implementación bloqueada hasta M08 voxel y presupuestos de M61). Resuelve los 15 puntos de la sección 62: pantalla de carga cozy con progreso real (pesos por operación), streaming de chunks con LRU de tope duro, precalentamiento en menú principal y streaming diferenciado de océano/subterráneo/islas.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 8 RF + NFR y 5 criterios |
| `plan-inicial/02-Analisis.md` | 15/15 puntos resueltos; 3 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | Arquitectura, pesos de progreso, cola, LRU, regiones, LoadingScreen, precalentamiento, QA |
| `plan-inicial/04-Codigo.md` | Archivos, API, integración + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **101 ítems**, 101 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M63 → 🟢 Disponible, 101/101, marcado **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 63 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 37.

## Decisiones

- **Progreso real por pesos** (chunk=1…shader=5): barra = Σcompletado/Σtotal, piso 2% y tope 98% — nunca fake (sección 8 AGENTS).
- **Precalentamiento en menú principal**: shaders, bancos y anillos del spawn se cargan antes → continuar partida con < 30 operaciones restantes.
- **LRU con tope duro** (4096 PC / 2048 Deck) y descarga diferida 2 frames (anti-parpadeo).
- **Streaming por región**: océano con 3 coronas de LOD que siguen la cámara; subterráneo por pisos; islas con StreamableBox y precarga al 60% de la ruta de vuelo (M28).
- **Anti-congelamiento verificable**: prohibido `load()` síncrono en gameplay, deltas < 50 ms, teleport ×10 sin hitching (M61).