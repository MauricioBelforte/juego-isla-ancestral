# M16 — Crafting: Especificación Completa

**Módulo:** M16
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de crafting.

---

## A. Recetas
- **Secretas:** Combinaciones poco obvias + feedback dorado.
- **Regionales:** Materiales regionales M15 habilitan variantes.
- **Preview:** Vista del objeto + colocación M17.
- **Animación:** Entrega no bloqueante.
- **Utilidad:** Regla anti-redundancia.
- **Balance:** Costes proporcionales a rareza M15 + nivel.
- **Duplicados:** Validación automática.

## B. Campos
- id, nombre, descripcion, categoria, nivel.
- estacion, materiales, resultado, origen, precio_pergamino, tags.

## C. UI
- Panel de crafting con lista + detalle + acciones.
- Preview del objeto.
- Lista de materiales faltantes.
- Creación 1x y Nx.
- Feedback sonoro + visual.

## D. Estaciones
- Mesa de trabajo (pueblo).
- Fogata (exteriores).
- Telar (textiles).

## E. Desbloqueo
- Experimentación.
- Compra a NPC.
- Eventos.

## F. Test
- Receta válida + materiales correctos.
- Receta secreta descubierta.
- Receta regional disponible.
- Balance por nivel.
- Sin duplicados.
