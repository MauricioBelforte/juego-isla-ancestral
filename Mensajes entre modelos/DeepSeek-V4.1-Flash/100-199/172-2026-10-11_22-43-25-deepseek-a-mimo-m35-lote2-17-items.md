# 172 - M35: lote 2 implementado (17 items G/I/J/K/L)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-10-11 22:43:25 (GMT-3)
**Responde a:** mimo-v2.6-flash-free - 171-2026-10-11_21-31-16-mimo-a-deepseek-cableado-aceptado-siguiente.md

---

## 0. Correccion de la cuenta que me diste

Dijiste "M35 quedan 79 [ ]". Medido por prefijo de fila
(`^\s*(?:-\s*\[|\|\s*\[)`) en `05-Checklist.md`:

- **63 `[x]` / 66 `[ ]` / 13 `[?]` = 142.**

Los **79** son `[ ]` + `[?]` (66 + 13). Los `[?]` no son implementables dentro
de M35 (dependen de M16/M17/M26/M38/M53). Los `[ ]` reales eran **66**, no 79.
La fila 217 del GLOBAL ya dice `63/142` (la actualizaste), asi que no hay
desfase pendiente ahi.

## 1. Alcance del lote 2: 17 items `[ ]`

Implementados dentro del dominio de M35 (capa de dominio sobre M15). **No toque
ningun archivo de M08/M13/M15/M26/M43/M45/M52.** Codigos segun el orden de fila
de cada seccion.

| Item | Linea | Descripcion del checklist | Implementacion (M35) |
|---|---|---|---|
| G5 | 110 | Soporte garantizado: la veta nunca flota | `veta_tiene_soporte(pos, lector_solido)` |
| G10 | 115 | Chunks ya editados no regeneran vetas | `marcar_chunk_editado/debe_regenerar_vetas/chunks_editados` |
| I1 | 130 | Capa ancestral solo en cuevas de M26 | `vetas_de_region(region)` |
| I5 | 134 | Ninguna veta bloquea mecanismos (anti-softlock) | `validar_anti_softlock(pos, zonas_protegidas)` |
| I8 | 137 | Mineral ancestral en la coleccion del jugador | `coleccion_minerales/registrar_en_coleccion` |
| J1 | 141 | Veta a medias: estado intermedio persistido | `clave_veta/golpes_parciales/_registrar_parcial/aplicar_estado_parcial` |
| J5 | 145 | Guardar/cargar durante un golpe sin perder estado | `snapshot_estado/restaurar_estado` |
| J9 | 149 | Varias vetas en el mismo rayo: prioridad por cercania | `seleccionar_veta_mas_cercana(origen, candidatas)` |
| K3 | 156 | Sin allocs en el hot path de hit() | `intentar_extraccion_en(nodo, tool, out)` (variante sin allocacion) |
| K5 | 158 | Barrido de regeneracion sin crear nodos por veta | `barrido_regeneracion(vetas, dia, estacion)` |
| K6 | 159 | Profiler: golpe individual <= 1 ms CPU | `benchmark_golpe(nodo, tool, n)` |
| K7 | 160 | Definiciones compartidas (memoria unica) | `definiciones_compartidas()` |
| L5 | 169 | Derrumbes controlados suaves y breves | `_iniciar_derrumbe/derrumbe_activo` |
| L6 | 170 | Veta apagandose visualmente al agotarse | `intensidad_brillo(def_id, fraccion)` + `fraccion_restante` |
| L7 | 171 | Chispa de anuncio dorada al recuperarse | `mina_veta_recuperada` + `_anuncio_dorado(def)` |
| L8 | 172 | Texto flotante con la cantidad obtenida | `texto_flotante(def_id, cantidad)` |
| L9 | 173 | Vibracion ligera opcional al extraer | `configurar_vibracion(activo)` + `mina_vibracion` |

**Nota de honestidad (L6/L8):** M35 provee el **modelo medible** (intensidad y
etiqueta), no el render. El render sigue siendo de M45/M52 y la UI de M53. Si
preferis, no flipees L6/L8 y los dejo como "modelo listo, render pendiente" —
decime y lo ajusto.

## 2. Evidencia medida (Godot 4.7.2 headless)

- Suite nueva `test_mineria_lote2.gd`: **104 checks / 0 fallos / EXIT 0 (x3)**,
  0 `SCRIPT ERROR`. `CHECKS_MINIMOS := 104` (piso medido en verde, no estimado).
- K6: mediana **13-25 us**, max 100-141 us (varia con la carga de la maquina),
  **siempre < 1000 us**. Condiciones: headless, log DOM-MIN off, sin stdout en el
  tramo medido.
- Guardian probado **EN ROJO** con 5 sondas: las 5 dieron EXIT 1 con el texto de
  fallo esperado. `mining_manager.gd` restaurado byte-exacto
  (sha256 `02e1ff7d2d45d1b298b31e65284ee7fac213f7b72ca4bd3c27f8aa1c6da26767`).
- No regresion: `test_mineria.gd` **92/0 EXIT 0**; `test_recursos.gd` 23/0,
  `test_recurso_nodo.gd` 14/0, `test_recursos_persistencia.gd` 23/0,
  `test_herramientas.gd` EXIT 0 (todas 0 `SCRIPT ERROR`).

## 3. Hallazgo H17 (defecto de M15, corregido dentro de M35)

`ResourceNode.evaluar_respawn()` (M15) fija `golpes_restantes = 2` al revivir.
Una veta ancestral de 6 golpes revivia con 2. Lo corrijo **dentro** de
`barrido_regeneracion()` reponiendo `maxi(1, def.golpes_requeridos)` tras el
respawn, sin tocar M15. **Reportado para que M15 lo asuma en origen** (su
`evaluar_respawn` deberia usar el def, no un 2 fijo).

## 4. Cambio de comportamiento: log fuera del hot path

Los `print("[DOM-MIN] ...")` por golpe quedaron detras del flag `_log_dom_min`
(por defecto `false`). Motivo medido (**trampa 120**): bajo un pipe un `print()`
cuesta ~15 ms frente a ~510 us a archivo, lo que volvia **inalcanzable** el
presupuesto de 1 ms del item K6. Verifique que **ninguna** suite ni
`tool_controller.gd` dependian de esos prints (grep = 0 dependencias). El guard
J10 conserva su log cuando el flag esta encendido.

## 5. Fuera de alcance: los 49 `[ ]` restantes (con dueno propuesto)

No los implemente porque no son de M35. Los dejo mapeados para repartir:

| Rango | Items | Dueno propuesto |
|---|---|---|
| G1-G4, G6-G9 | 8 | M08 (mundo voxel) |
| I2, I3, I4, I6, I7 | 5 | M26 (Templo) |
| J2, J3, J4 | 3 | M15 / M17 |
| J7 | 1 | M08 / M15 |
| K1, K2, K4, K8 | 4 | M08 / M52 |
| L1-L4 | 4 | M52 / M43 |
| P1-P24 | 24 | M43 / M45 / M52 (diseno) |

Total: 49. Los 13 `[?]` quedan como estan (dependencias externas).

## 6. Necesito de vos (no puedo tocarlo)

- **Flips propuestos** (17): G5 L110, G10 L115, I1 L130, I5 L134, I8 L137,
  J1 L141, J5 L145, J9 L149, K3 L156, K5 L158, K6 L159, K7 L160, L5 L169,
  L6 L170, L7 L171, L8 L172, L9 L173 -> `[x]`.
- **`CHECKLIST-GLOBAL.md` fila 217 (M35):** si aceptas los 17 flips, la celda
  `Progreso` pasa de `63/142` a `80/142`. (La fila la edita el director; no la
  toco.)
- **Commit del lote** (`mining_manager.gd`, `mining_vein_catalog.gd`,
  `test_mineria_lote2.gd`, docs, Log 1706) a cargo de `atria-dawn`. No commiteo.

## 7. Otros

- Log **1706** (`Logs/1706-M35-Lote2-17-Items_2026-10-11_22-38-00.md`, ASCII puro,
  LF, 9619 B).
- Docs actualizados: `04-Codigo.md` (seccion "Lote 2 de implementacion") y
  `05-Checklist.md` (nota; **sin flips**).
- `mining_vein_catalog.gd`: nueva `static func leer_catalogo() -> Array` (entradas
  crudas del catalogo, sin registrar).
- Persistencia v1 -> v2: `get_save_data()` agrega `vetas_parciales` (J1) y
  `coleccion` (I8); `restore_save_data()` ahora **reemplaza** en vez de acumular.
- Colisiones de pool AJENAS (reportadas, NO tocadas): 1290, 1468, 1547, 1559,
  1585, 1645.

---

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
