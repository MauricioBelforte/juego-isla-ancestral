# M19 — NPC y Vecinos: Especificación Completa

**Módulo:** M19
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de NPCs.

---

## A. Requisitos
- **Problema:** NPCs con vida, rutina y relaciones.
- **Dependencias:** M21 (diálogos), M33 (cultivos), M14 (inventario), M59 (guardado).
- **6 vecinos:** Elysia, Finneas, Marta, Tomás, Sofía, Bruna.

## B. Rutinas
- **Diaria:** Despertar → trabajo → comida → paseo → dormir.
- **Estacional:** Cambia por M29.
- **Eventos:** M74 desplaza rutinas.
- **Determinismo:** M10 PRNG.

## C. Diálogos (M21)
- **Saludo:** 3 variantes por estado.
- **Preguntas:** 2-3 por vecino.
- **Respuestas:** Contextuales.
- **Amistad:** Cambia tono (M20).

## D. Amistad (M20)
- **Niveles:** 0-5.
- **Desbloqueos:** Regalos, misiones, secretos.
- **Sin FOMO:** Progreso accesible.

## E. Misiones (M22/M23)
- **Principales:** 3 por vecino.
- **Secundarias:** 2 por vecino.
- **Recompensas:** Ítems + amistad.

## F. Spawner
- **Zonas:** Pueblo (6), islas (2 por isla).
- **Densidad:** Máx 10 por zona.
- **Respawn:** 30 min de juego.

## G. IA
- **Persecución:** No (cozy).
- **Rutina:** Waypoints + tiempo.
- **Eventos:** M74 desplaza.
- **Interacción:** M21 + M39 (tiendas).

## H. Test
- **Rutina completa (24h).**
- **Diálogo sin crash.**
- **Amistad persistente.**
- **Misiones desbloqueables.**
- **Spawner sin duplicados.**
