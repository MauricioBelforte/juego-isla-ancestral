# Log 65 — Documentación Módulo 73 (Coleccionables)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Contexto

Continuación de la fase de documentación de diseño (de a un módulo, según directiva del usuario: documentar → pushear → siguiente).

## Módulo documentado

| ID | Módulo | Ítems | Prioridad | Complejidad | Estado |
|---|---|---|---|---|---|
| 73 | Coleccionables | 130 | Media | 3 | ✅ DELEGABLE |

**Total: 130 ítems** en 10 archivos (5 × plan-inicial + 5 × plan-actual).

## Nota sobre la numeración del plan maestro

El plan maestro numera la sección 72 como "COLECCIONABLES"; la tabla global la mapea como ID 73 (desfase de +1). Documentado en el `01-Requerimientos.md`.

## Verificaciones realizadas

- plan-inicial == plan-actual byte a byte (SHA-256 idénticos, 5 pares OK).
- Checklist: 130 `[x]`, 0 `[ ]`, 0 `[?]` (recortado de 140 a 130).
- Firmas `**Modelo:** Deepseek V4 Flash` / `**Plataforma:** OpenCode`.
- Notas del Agente en `04-Codigo.md`.

## Coordinación multiagente

- CHECKLIST-GLOBAL.md: fila 73 → 🟢 Disponible, progreso real 130/130. Resumen: 63 módulos con documentación completa, 86 🟢 / 63 ⬜ / 3 🔵 / 0 ✅.
- DOCUMENTACION/README.md: entrada en árbol y tabla de estado.
- ESTADO-PARALELO.md: historial de completados.

## Contenido destacado

- **Catálogo central** (`collectibles_catalog.tres`): 22 categorías del plan maestro (reliquias, fragmentos, conchas, minerales, peces, plantas, insectos, fósiles, cartas, fotografías, muebles, ropa, herramientas especiales, documentos, mapas, símbolos, mensajes, secretos, objetos ancestrales, colecciones completas, recompensas, registro) con ~500 ítems de ids unívocos.
- **Registro idempotente** por eventos (M07): `ITEM_COLLECTED`, `FISH_CAUGHT`, `MINERAL_MINED`, `FOSSIL_DUG`, `PHOTO_TAKEN`... — recolectar dos veces NO duplica.
- **Progreso anti-spoiler** (como M55): solo se ve lo descubierto; el % nunca revela el total oculto.
- **Collección completa → recompensa** (ítem M14 / dinero M38) + notificación (M44) + confeti sutil (M52) + desbloqueos (M71: receta M16, área, atajo M69) + logro (M72).
- **Vistas compartidas:** museo (M37, donar = recolectar) y diario (M55) leen el MISMO servicio.
- **Persistencia compacta** (< 5 KB de ids, M59/M60 versionado).
- **validate_collectibles.gd:** ids únicos, totales, recompensas resolubles, claves i18n.
- 3 dudas honestas `[?]` documentadas (sin runtime Godot; totales por cerrar con módulos fuente; recompensas finales de M38/M16).

## Archivos creados

- `DOCUMENTACION/73-Coleccionables/plan-inicial/` (5 archivos)
- `DOCUMENTACION/73-Coleccionables/plan-actual/` (5 archivos)