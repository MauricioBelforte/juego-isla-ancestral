# 08 — Integraciones y Diseño de Ruinas — M25 (hy3 / WorkBuddy, 2026-09-19)

**Alcance:** diseño de las 8 tareas pendientes del `05-Checklist.md` (items 1–8 del backlog
T1–T15) que no estaban documentadas: atalayas, validación de caminos con NavigationServer3D,
e integración con M26/M28/M31/M32/M36/M45/M47. Especificación de diseño (no implementación de
GDScript); el autor de M25 (MiMo V2.5) implementa contra estos contratos.

**Contrato base reutilizado (M24, `03-Diseno.md` L252–262):**
```
signal emisor_cambiado(id: int, activo: bool)
func set_emisor(id: int, activo: bool) -> void
func get_emisor() -> bool
signal estado_cambiado(ruina_id: String, nuevo_estado: Estado)   # L295
```
Todos los activadores de ruina son `Node3D` que implementan ese contrato; las reglas del
puzzle viven en datos de M24 (`PuzzleRoom`).

---

## 1. Atalayas con vista de bioma (item 1)

**Objetivo:** torre delgada (4–8 piezas: base + fuste + plataforma + baranda) que ofrece
vista de lejos del bioma y sirve de punto de descubrimiento anticipado.

**Diseño:**
- Altura ≥ 6 m para sobrepasar canopy del bioma; cámara de observación opcional (visor M63).
- Señaliza `estado_cambiado(ruina_id, Descubierta)` al subir (detecta biomas vecinos en radio).
- Sin puzzle obligatorio (estructura de apoyo a exploración).
- LOD: la plataforma usa LOD1 a distancia (presupuesto M166).

**Riesgo:** colisión con terreno voxel (`_buscar_altura` de M25 ya resuelve enterramiento).
**Aceptación:** ensambla sin traslape; emite `estado_cambiado` al subir; 0 `SCRIPT ERROR`.

---

## 2. Validación de caminos con NavigationServer3D (item 2)

**Objetivo:** validar que los caminos de 2–4 tramos entre ruinas son navegables antes del build.

**Diseño:**
- Cada tramo de camino = `NavigationRegion3D` + `NavigationMeshSourceGeometryData3D`.
- `NavigationServer3D.region_get_connections()` debe reportar conectividad continua origen→destino.
- Validación en editor (`validar_caminos_m25.gd`): si un tramo no conecta, fallo de build (`_build_fail`)
  con mensaje "camino roto en tramo N".
- Coste: recalcular mesh solo en edición (no en runtime; M25 es estática).

**Aceptación:** caminos de 2–4 tramos validan conectividad; tramo roto → fallo de build; 0 `SCRIPT ERROR`.
**Nota:** no confundir con `NavigationServer3D` de NPCs (M66/M28); M25 solo valida geometría de camino.

---

## 3. Integración con M26 — Templo Subterráneo (item 3)

**Objetivo:** una ruina grande puede contener acceso al templo subterráneo de M26, sin tocar
el código de M26.

**Contrato:** M25 expone un `Node3D` marcador `acceso_m26` (posición + radio). M26 (autor
independiente) lee el marcador si existe; M25 NO importa scripts de M26.
- Señal `estado_cambiado` de M25 no bloquea a M26.
- Riesgo: solapamiento de geometría → usar `_buscar_altura` para anclar la entrada al terreno real.

**Aceptación:** ruina grande con marcador `acceso_m26` presente; M26 opera sin error si lo consume;
M25 no referencia `res://scripts/templo/` de M26.

---

## 4. Integración con M28 — Caminos (item 4)

**Objetivo:** conectar ruinas al sistema de caminos de M28 como nodos.

**Contrato:** tramos de M25 = nodos M28 (`NodoCamino`) declarados en datos de M28. M25 registra
sus tramos vía `M28.registrar_tramo(ruina_id, [puntos])` (API de M28, no acoplada).
- M25 provee los puntos; M28 computa el grafo. Sin lógica de grafo en M25.

**Aceptación:** tramos de M25 aparecen como nodos en M28; navegación entre ruinas funciona; 0 acoplamiento inverso.

---

## 5. Integración con M31 — Alineación Solar (item 5)

**Objetivo:** observatorios de M25 alinean anillos de piedra con el sol según M31.

**Contrato:** M25 lee `M31.get_sol_dir()` (vector de dirección solar) para orientar anillos.
M31 es dueño del ciclo día-noche; M25 solo consulta.
- Puzzle de alineación: activador `activador_anillo.gd` (`set_emisor` cuando ángulo correcto,
  `03-Diseno.md` L197–L200) compara contra `M31.get_sol_dir()` en solsticio.

**Aceptación:** anillos se alinean al consultar M31; caída de M31 (API null) → puzzle en estado neutro, sin crash.

---

## 6. Integración con M32 — Viento/Lluvia (item 6)

**Objetivo:** pasajes ocultos y jardines de M25 reaccionan a viento/lluvia de M32.

**Contrato:** M25 se suscribe a `M32.signal clima_cambiado(tipo, intensidad)`.
- Pista ambiental de pasaje: susurro de viento (`03-Diseno.md` L81) se amplifica en lluvia.
- Jardines: canales de agua usan intensidad de lluvia de M32 para nivel de flujo.

**Aceptación:** `clima_cambiado` de M32 modula audio/agua de M25; M25 no escribe estado de M32.

---

## 7. Integración con M36 — Museo (item 7)

**Objetivo:** los 25 objetos arqueológicos de M25 (3 estados: enterrado→expuesto→museo,
`03-Diseno.md` L93–L94) se exponen en vitrinas de M36 al completar la ruina.

**Contrato:** al `estado_cambiado(ruina_id, Completada)`, M25 emite
`M36.exponer_objeto(objeto_id, ruina_id)` para cada objeto único. M36 dueño de vitrinas.
- `copia única`: cada objeto se expone 1 vez (M66 cofre garantiza unicidad).

**Aceptación:** al completar ruina, M36 recibe los 25 objetos; vitrina no duplica; M25 no toca UI de M36.

---

## 8. Integración con M45/M47 — Kit de referencia para assets (item 8)

**Objetivo:** M25 usa el kit de referencia de assets (texturas/geometría) de M45/M47 para
piedra rota, glifos y decoración.

**Contrato:** M25 referencia `res://assets/referencia/` de M45/M47 por `Resource` (no copia).
- Paletas visuales (3 épocas, `03-Diseno.md` L124) mapean a materiales de M45.
- Si M45/M47 no está listo, M25 usa placeholder `m25_placeholder.tres` (no bloquea).

**Aceptación:** ruinas usan materiales de M45/M47 vía Resource; fallback placeholder si ausente; sin duplicación de assets.

---

## Resumen de dependencias (no bloqueantes para el diseño)

| Módulo | Tipo | Contrato | Dueño |
|--------|------|----------|-------|
| M24 | emisor/receptor | `set_emisor`/`get_emisor`/`emisor_cambiado` | M24 |
| M26 | marcador `acceso_m26` | sin tocar código M26 | M26 |
| M28 | nodos de tramo | `registrar_tramo` | M28 |
| M31 | `get_sol_dir()` | consulta solo lectura | M31 |
| M32 | `clima_cambiado` | suscripción señal | M32 |
| M36 | `exponer_objeto` | al Completada | M36 |
| M45/M47 | Resource assets | referencia, no copia | M45/M47 |

Todas son integraciones por señal/Resource (acoplamiento débil); ninguna requiere que M25
modifique el código de los otros módulos. Cumple la regla "sin rozar" del checklist.
