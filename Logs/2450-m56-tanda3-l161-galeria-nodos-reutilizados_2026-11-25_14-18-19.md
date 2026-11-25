# LOG 2450 - M56 tanda 3: L161 galería refactor a nodos reutilizados (134→135/138)

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25
**Hora:** 14:18

## Resumen

Tercera tanda del día sobre M56-Fotografía (re-claim del módulo propio, reserva §21.3 en 4 registros): el ítem L161 "No duplicar texturas en memoria al abrir la galería". Además, renumeración de mis mensajes salientes al hilo de MI carpeta (directiva del fundador).

## Cambios Realizados

### L161 — refactor de `scripts/foto/photo_gallery.gd`
**Diagnóstico del bug:** al descargar una miniatura fuera del rango visible, el `TextureRect` quedaba vacío en el grid y al volver a cargar se creaba OTRO nodo duplicado (además rompía el layout del GridContainer con la paginación).

**Solución (nodos reutilizados):**
- `_crear_nodos_fotos()`: un TextureRect POR FOTO, creado una sola vez en orden de lista (con meta "idx"), para que el layout del grid sea estable.
- `_actualizar_visibles()`: carga texturas SOLO para el rango visible (presupuesto M61 ≤ 24) y libera (`texture = null`) las que quedan fuera — la textura GPU muere por refcount, el nodo persiste para el layout.
- `_cargar_miniatura(ruta, tr)`: ahora llena el nodo existente (sin re-creación).
- `recargar()`: libera nodos + recrea en orden (consistente).

### Verificación (§12/§14)
- QA nueva `scripts/foto/qa_m56_galeria.gd`: **7 checks / 0 fallos / EXIT 0** — invariantes: 1 nodo por foto (33 nodos = 33 fotos del álbum sin duplicados), re-consultas sin nodos nuevos, presupuesto ≤24, scroll lejano sin re-creación, textura liberada fuera de rango (0 lejanas con textura), recargar consistente. Las fotos de prueba (`qa_m161_*.png` en user://fotos) se limpian al final — no pisa el álbum real.
- Regresión: `qa_m56_photopose` 16/0, `test_photomode` 0 fallos, `test_photo_service_headless` 10/0.
- Correcciones durante el desarrollo (honestidad): 3 iteraciones de la QA (defaults de tipo no inferibles; aserción que usaba `_indice_visible_*` nunca asignados — herencia del original; scroll clamped en headless — reset a 0 antes de la ventana chica). Los fallos intermedios eran del TEST, no de la galería.

### Documentación
- Flip L161 con cita + Totales de M56: **135 [x] / 2 [ ] / 1 [?] = 138** (135/138).
- Fila 56 del GLOBAL: 🔵 → **🟡 Liberado (135/138)** con nota de la tanda 3.
- ESTADO-PARALELO + guía 08 actualizados (reserva/cierre).

### Numeración de mensajes (directiva del fundador)
- Regla aclarada: cada agente escribe en SU carpeta; la directora lee todas; mensajes puntuales al director → carpeta del director.
- Mis 5 mensajes salientes re-ubicados y renumerados al hilo de MI carpeta (consumidos del pool propio): 035 (cierre M20), 036 (reintegración), 037 (rúbrica a GPT-6-Luna), 038 (a minimax), 039 (cierre M56). Cada archivo lleva nota de renumeración con su número original. Los pools ajenos quedan con huecos benignos (992-994 / 002 / 068).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/foto/photo_gallery.gd` (refactor L161)
- `game/isla-ancestral/scripts/foto/qa_m56_galeria.gd` (nueva QA, 7 checks)
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md` (flip + Totales 135/2/1)
- `CHECKLIST-GLOBAL.md` (fila 56 🟡 135/138), `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`
- `Mensajes entre modelos/GLM-5.3-Flash/` (5 mensajes renumerados 035-039)
- Reporte **040** (cierre tanda 3) en mi carpeta

## Pendientes / Deuda (honestidad)
- M56: quedan 2 [ ] (L112 bestiario → requiere M36/M37; L135 filtros en frame → requiere M49) y 1 [?] (L341, dueño deepseek-v4-flash-vision-exp).
- QA cruzado §21.8 de las 3 tandas del día (M20 ×5, M56 ×4, M56 ×1) pendiente de modelo distinto.
- 5 filas duplicadas del GLOBAL (115/127/139/148/48) para saneo de la directora.
- validate_photo: 2 fallos preexistentes (filtros M49) — deuda de L135.

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
