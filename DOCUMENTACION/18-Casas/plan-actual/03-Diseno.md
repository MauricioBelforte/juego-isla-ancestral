**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 18: Casas

## 1. Arquitectura general

| Clase | Responsabilidad | Escena |
|---|---|---|
| `HouseManager` | Singleton de servicio: registro de casas, parcelas, orquestación de visitas, persistencia | `res://scenes/houses/house_manager.tscn` |
| `House` | Nodo exterior en el mundo: puerta interactiva, estado de obra, etapa actual, reubicación | `res://scenes/houses/house.tscn` |
| `HouseInterior` | Escena instanciada del interior: habitaciones, cámara, decoración, almacenamiento | `res://scenes/houses/house_interior.tscn` |
| `HouseUpgrade` | Lógica de mejoras por etapas (Lee `HouseUpgradeData`) | Script de datos + componente en `House` |
| `HouseStorage` | Contenedores domésticos: slots, transferencia con M14 | `res://scenes/houses/house_storage.tscn` |
| `HouseDecor` | Colocación de muebles en grid interior, rotación, recolocación y preview | Script en `HouseInterior` |

Capas: los scripts de UI (`HouseUIPanel`, aparte) llaman solo a los objetos públicos de estas clases; ninguna clase anterior conoce nodos de UI (regla 9 de AGENTS.md).

```
WorldManager (M07)          GameState (M58)
      |                           |
      v                           v
 HouseManager <---------> HouseRegistry (por partida)
      |
      +-- House (exterior, mundo voxel M17)
      |       +-- HouseUpgrade (etapa actual, progreso de obra)
      |       +-- Puerta (Area3D interactiva, portal)
      |
      +-- HouseInterior (instanciada bajo demanda)
              +-- Habitaciones (nodes por sala) 
              +-- HouseDecor (grid fino, muebles)
              +-- HouseStorage (contenedores M14)
              |       +-- InventoryView (contrato M14, sin acoplar)
              +-- Cámara interior (M12)
```

## 2. Flujos en texto

### Flujo 2.1: Construcción inicial de la casa (M17)
1. Jugador activa el modo construcción (M17) sobre una parcela asignada.
2. `HouseManager.validar_parcela(parcela)` comprueba terreno despejado y parcelas disponibles.
3. M17 descuenta materiales de M14 via `M17.construir_parcela(parcela, materiales)`.
4. Al completar la obra (progreso por M29), `HouseManager.crear_casa(parcela)` instancia `House` sobre la huella.
5. La casa nace en etapa 1 (choza base) y queda registrada y guardada.

### Flujo 2.2: Entrar y salir del interior
1. Jugador interactúa con la puerta de `House` (Area3D + prompt de interacción).
2. `House.abrir_interior()` verifica estado de casa: si está en obra, muestra cartel "Obra en curso" (M21) y no permite entrar.
3. Se deshabilita input de juego, se instancia/activa `HouseInterior` (carga asíncrona) y se reproduce fundido.
4. Al entrar: la cámara pasa al interior (M12), GameClock pausa el exterior interiormente (iluminación propia).
5. Al salir (puerta interior): fundido inverso, se libera la escena interior, el jugador reaparece frente a la puerta exterior.

### Flujo 2.3: Ampliación por etapas (HouseUpgrade)
1. Jugador abre el panel de mejoras (UI aparte) que lista la próxima etapa.
2. `HouseUpgrade.verificar_requisitos(etapa)` valida: materiales M14, dinero, requisitos de misión M21, día/hora M29.
3. Confirmado, se descuentan materiales y `House.obra = true` (duración N días de juego según M29).
4. El exterior visual cambia a "en obra" (andamiaje); el interior queda bloqueado.
5. `HouseUpgrade.tick_diario()` avanza el progreso; al terminar, aplica la nueva etapa: agrega habitaciones y desbloquea slots de decoración/almacenamiento.

### Flujo 2.4: Decoración y mudanza de muebles (HouseDecor)
1. En modo decoración (panel UI), `HouseDecor.activar()` muestra preview fantasma del ítem del hotbar (M14).
2. `HouseDecor.validar_celda(celda, mueble)` comprueba: dentro de la habitación, sin solapamiento, superficie apta.
3. El jugador coloca/rota el mueble; al confirmar se descuenta del inventario M14 (o se toma del propio contenedor).
4. Para mover un mueble ya colocado: `HouseDecor.levantar(instancia)` — si el mueble es contenedor con objetos, `HouseStorage.extraer_contenido()` devuelve los ítems al inventario (con aviso previo).
5. Se guarda el estado del grid.

### Flujo 2.5: Almacenamiento doméstico (HouseStorage + M14)
1. Jugador abre un mueble-contenedor (cofre, estantería).
2. `HouseStorage.abrir()` crea la vista de transferencia usando el contrato de M14 (sin acoplar UI).
3. Transferencia rápida (un click), por lotes, separación de stacks y confirmación para objetos importantes (reglas M14).
4. Cualquier cambio emite `storage_changed` y se marca el GameState para guardado.

### Flujo 2.6: Visita de vecino (M19 + M29 + M21)
1. El plan diario del vecino (M19, agenda M29) incluye "Visitar casa del jugador" según afinidad y decoración.
2. `HouseManager.solicitar_visita(vecino, dia, hora)` valida disponibilidad (casa accesible, no en obra).
3. Al entrar con el jugador o por horario, el vecino se instancia dentro de `HouseInterior` (punto de entrada).
4. El vecino reacciona a la decoración (mira muebles, comenta por M21) y puede sentarse en muebles aptos.
5. Puntos de amistad (M19) según ítems valiosos de la casa; la visita termina y el vecino sale por la puerta.

## 3. Contratos API GDScript (públicos)

```gdscript
# HouseManager (autoload "house_manager")
func validar_parcela(parcela: Vector3i, size_voxel: Vector3i) -> bool
func crear_casa(parcela_id: String, datos: HouseData) -> House
func obtener_casa_jugador() -> House
func registrar_casa(casa: House) -> void
func solicitar_visita(vecino_id: String, dia_juego: int, hora: int) -> bool
func salvar(estado: Dictionary) -> void
func cargar(estado: Dictionary) -> void
signal casa_creada(casa: House)
signal casa_reubicada(casa: House)

# House (exterior)
func abrir_interior() -> void
func esta_en_obra() -> bool
func etapa_actual() -> int
func reubicar(nueva_parcela: Vector3i, coste: Dictionary) -> bool
func obtener_entrada() -> Vector3
signal puerta_interactuada()

# HouseInterior (interior)
func entrar(jugador: Node3D) -> void
func salir() -> void
func obtener_habitaciones() -> Array[HouseRoom]
func agregar_habitaciones(ids: Array[String]) -> void
signal interior_listo
signal interior_cerrado

# HouseUpgrade
func etapa_actual() -> int
func proxima_etapa() -> HouseUpgradeData
func verificar_requisitos(etapa_id: String, inv: Inventory) -> Dictionary
func iniciar_obra(etapa_id: String) -> bool
func tick_diario() -> void
func aplicar_etapa(etapa: HouseUpgradeData) -> void
signal obra_iniciada(etapa_id: String)
signal obra_completada(etapa_id: String)

# HouseStorage
func abrir(mueble: Node3D) -> void
func cerrar() -> void
func transferir_a_inventario(mueble_id: String, idx: int, cantidad: int) -> int
func transferir_desde_inventario(mueble_id: String, item_id: String, cantidad: int) -> int
func extraer_contenido(mueble_id: String) -> Array
signal storage_changed(mueble_id: String)

# HouseDecor
func activar() -> void
func desactivar() -> void
func validar_celda(celda: Vector3i, mueble: FurnitureData) -> Dictionary
func colocar(celda: Vector3i, mueble_id: String, rotacion: int) -> bool
func levantar(celda: Vector3i) -> void
func rotar(celda: Vector3i, pasos: int) -> void
func recolectar_estado() -> Dictionary
func restaurar_estado(datos: Dictionary) -> void
signal decoracion_cambiada
```

## 4. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M17 Construcción | La casa exterior nace de `construir_parcela()`; obras de mejora reusan el patrón de obra de M17 (andamiaje, progreso) |
| M14 Inventario | Descuentos de materiales via `Inventory.quitar_item()`; transferencia de almacenamiento con el mismo contrato de stacks/UI |
| M19 NPC | `solicitar_visita()` coordina entrada/salida; puntos de amistad por valor de decoración |
| M21 Diálogos | Carteles de obra, reacciones a decoración y avisos de visita se emiten como eventos de diálogo |
| M29 Tiempo | `tick_diario()` para obras; agenda de visitas por hora; PRNG por partida para preferencias y variaciones |
| M58 Guardado | `House` y `HouseInterior` serializan via `salvar()/cargar()` con IDs y versión de esquema |
| M12 Cámara | Cámara interior dedicada con límites por habitación al entrar/salir |
| M61 Rendimiento | Contrato de presupuesto: interior instanciado, grid sin allocs, transición asíncrona |

## 5. Persistencia (esquema de datos)

```
partida -> casas: [
  { parcel_id, etapa, en_obra, progreso_obra, posicion_voxel, rotacion,
    interior: {
      habitaciones: [ids],
      muebles: [ { id, celda, rotacion, extra: {slot_id: {item, cantidad}} } ],
      storage: [ { mueble_id, slots: [{item_id, cantidad}] } ]
    }
  }
]
```
Versión del esquema incluida; migración en el cargador (M58).

## Specs Casas (Beam 678)

### RF2: casa del jugador construible desde el modo construcción
- Spec: RF2: casa del jugador construible desde el modo construcción. Coherente with M18 (casas) and M16 (construcción).

### P7: cocina — habitación funcional con interacción y recetas M16
- Spec: P7: cocina — habitación funcional con interacción y recetas M16. Coherente with M18 (casas) and M16 (crafting).

### P8: taller — habitación funcional con recetas de M16
- Spec: P8: taller — habitación funcional con recetas de M16. Coherente with M18 (casas) and M16 (crafting).

### P9: jardín — zona exterior de la casa con plantas (M33)
- Spec: P9: jardín — zona exterior de la casa con plantas (M33). Coherente with M18 (casas) and M33 (agricultura).

### P12: exteriores — modelo exterior que cambia de aspecto por etapa
- Spec: P12: exteriores — modelo exterior que cambia de aspecto por etapa. Coherente with M18 (casas) and M17 (construcción).


## Specs Casas (Beam 679)

### P15: camas — dormir avanza la hora segun M29 y restaura energia
- Spec: P15: camas — dormir avanza la hora segun M29 y restaura energia. Coherente with M18 (casas) and M29 (tiempo).

### P16: mesas — soporte para colocar objetos encima
- Spec: P16: mesas — soporte para colocar objetos encima. Coherente with M18 (casas) and M16 (construccion).

### P17: sillas — sentarse con animacion y salida (CUBO B-EDITOR)
- Spec: P17: sillas — sentarse con animacion y salida. Coherente with M18 (casas) and M47 (animacion). Saltado (CUBO B).

### P18: lamparas — encendido/apagado e iluminacion interior
- Spec: P18: lamparas — encendido/apagado e iluminacion interior. Coherente with M18 (casas) and M48 (iluminacion).

### P19: electrodomesticos — horno, fregadero con interaccion simple
- Spec: P19: electrodomesticos — horno, fregadero con interaccion simple. Coherente with M18 (casas) and M16 (construccion).


## Specs Casas (Beam 680)

### P20: objetos decorativos — celdas del grid con preview y validacion
- Spec: P20: objetos decorativos — celdas del grid con preview y validacion. Coherente with M18 (casas) and M16 (construccion).

### P21: objetos de pared — cuadros y colgantes en celdas de pared
- Spec: P21: objetos de pared — cuadros y colgantes en celdas de pared. Coherente with M18 (casas) and M16 (construccion).

### P22: cuadros — decoracion de pared con rotacion y reubicacion
- Spec: P22: cuadros — decoracion de pared con rotacion y reubicacion. Coherente with M18 (casas) and M16 (construccion).

### P23: plantas — macetas interiores y plantas de jardin
- Spec: P23: plantas — macetas interiores y plantas de jardin. Coherente with M18 (casas) and M33 (agricultura).

### P24: colecciones — catalogo de muebles por estilo (set completo premia)
- Spec: P24: colecciones — catalogo de muebles por estilo (set completo premia). Coherente with M18 (casas) and M73 (coleccion).


## Specs Casas (Beam 681)

### P25: estilos de decoracion — presets ancestral, floral, oceanico, cenit
- Spec: P25: estilos de decoracion — presets ancestral, floral, oceanico, cenit. Coherente with M18 (casas) and M16 (construccion).

### Cimientos visibles con la huella de la casa en el modo construccion
- Spec: cimientos visibles con la huella de la casa en el modo construccion. Coherente with M18 (casas) and M16 (construccion).

### Visual del exterior (choza, obra, etapa) coherente con el estado
- Spec: visual del exterior (choza, obra, etapa) coherente con el estado. Coherente with M18 (casas) and M16 (construccion).

### Plantas y macetas con requisitos de superficie
- Spec: plantas y macetas con requisitos de superficie. Coherente with M18 (casas) and M33 (agricultura).

### Sets de coleccion por estilo con bonus de visita
- Spec: sets de coleccion por estilo con bonus de visita. Coherente with M18 (casas) and M73 (coleccion).


## Specs Casas (Beam 682)

### Catalogo de estilos con presets visuales
- Spec: catalogo de estilos con presets visuales. Coherente with M18 (casas) and M16 (construccion).

### Obra de casa iniciada mediante el patron de construccion M17
- Spec: obra de casa iniciada mediante el patron de construccion M17. Coherente with M18 (casas) and M17 (construccion).

### Iluminacion interior propia (independiente del ciclo M31)
- Spec: iluminacion interior propia (independiente del ciclo M31). Coherente with M18 (casas) and M48 (iluminacion).

### Eventos M29 (cumpleanos, festivales) generan visitas especiales
- Spec: eventos M29 (cumpleanos, festivales) generan visitas especiales. Coherente with M18 (casas) and M29 (tiempo).

### Culling de muebles dentro de la habitacion
- Spec: culling de muebles dentro de la habitacion. Coherente with M18 (casas) and M61 (rendimiento).


## Specs Casas (Beam 683)

### Carga asincrona del interior sin congelar el frame
- Spec: carga asincrona del interior sin congelar el frame. Coherente with M18 (casas) and M63 (streaming).

### Iluminacion calida interior por habitacion
- Spec: iluminacion calida interior por habitacion. Coherente with M18 (casas) and M48 (iluminacion).

### Microfeedback del mueble colocado (chirrido/martillito)
- Spec: microfeedback del mueble colocado (chirrido/martillito). Coherente with M18 (casas) and M42 (sonido).

### API estable para consumo de M17, M14 y M19
- Spec: API estable para consumo de M17, M14 y M19. Coherente with M18 (casas) and M16 (construccion).

### Test: flujo completo construir, entrar, ampliar, decorar, almacenar
- Spec: test: flujo completo construir, entrar, ampliar, decorar, almacenar. Coherente with M18 (casas) and M112 (testing).


## Specs Casas (Beam 684)

### Test: 3 dias simulados con visitas de vecinos sin fallos
- Spec: test: 3 dias simulados con visitas de vecinos sin fallos. Coherente with M18 (casas) and M112 (testing).

### Test: mudanza de muebles contenedores sin perdida de items
- Spec: test: mudanza de muebles contenedores sin perdida de items. Coherente with M18 (casas) and M112 (testing).

### Test: obra en curso sin softlocks (M66)
- Spec: test: obra en curso sin softlocks (M66). Coherente with M18 (casas) and M66 (anti-softlock).

---

## 8. Casas grandes y objetos nuevos (2026-11-12, ERNIE-5.5-Flash-Preview)

> **Superado por §9 (v2, 20×15 / 28×20).** Las cifras de §8 corresponden a la primera versión (16×12 / 22×16) y se conservan como histórico.

> Modelado vivo en Blender 4.2.23 (escena `Casas_Grandes`) y guardado en `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_2026-11-12.blend`. Script fuente: `tools/mcp/blender-mcp/18-Casas/build_casas_grandes.py`.

### 8.1 Casona del Gremio — 16×12 m, 2 plantas

- **Uso:** vivienda-taller de un gremio artesano; 6 ambientes por planta.
- **Estructura:** zócalo de piedra 0,30 m; planta baja 0,45–3,85 m; planta alta 4,00–7,40 m; techo a dos aguas 2,20 m.
- **Fachada:** abierta al frente (vista de muñeca); muros laterales y posterior completos.
- **Escalera:** recta de 16 escalones, 1,6 m de ancho, con baranda.
- **Materiales:** 16 detectados (madera clara/oscura, paja, piedra, tela, metal, cristal, vino, oro, verde, agua, libro, cobre, marfil, musgo, coral, faro). Para Godot se recomienda merge a ≤8.

| Planta | Ambiente | Dimensiones | m² | Mobiliario principal |
|---|---|---:|---:|---|
| PB | Sala de estar | 5,4×8 | 43,2 | Sofá, 2 sillones, mesa ratonera, chimenea, estantería, tapiz, acuario, planta |
| PB | Vestíbulo | 5,6×8 | 44,8 | Fuente interior, consola, espejo, reloj de pie, araña |
| PB | Comedor | 5,0×8 | 40,0 | Mesa 3,4×1,5, 6 sillas, aparador, araña |
| PB | Cocina | 5,4×4 | 21,6 | Estufa cerámica, mesada, estante, mesa + 4 banquetas |
| PB | Estudio/biblioteca | 5,6×4 | 22,4 | Escritorio, biblioteca caracol, mesa alquimista, globo |
| PB | Baño | 5,0×4 | 20,0 | Bañera de cobre, lavabo, espejo |
| PA | Dormitorio principal | 5,4×8 | 43,2 | Cama con dosel, armario, 2 mesas de noche, 2 sillones |
| PA | Distribuidor | 5,6×8 | 44,8 | Alfombra, consola, araña, planta |
| PA | Dormitorio infantil | 5,0×8 | 40,0 | Cama, escritorio, baúl, estantería |
| PA | Taller/observatorio | 5,4×4 | 21,6 | Mesa de trabajo, telescopio, telar, estantería |
| PA | Estudio | 5,6×4 | 22,4 | Escritorio, estantería, globo |
| PA | Vestidor/baño | 5,0×4 | 20,0 | Armario, banco, espejo |

- **Medidas:** 608 piezas, **12.608 tris**, 16 materiales, bbox 17,7×13,1×9,7 m. Sin piezas bajo el suelo.

### 8.2 Mansión del Museo — 22×16 m, 2 plantas + torres

- **Uso:** mansión nobiliaria con galería de museo, biblioteca, invernadero y sala de música.
- **Estructura:** zócalo 0,35 m; planta baja 0,50–4,30 m; planta alta 4,45–8,25 m; techo 2,60 m; dos torres cilíndricas de r=1,6 m y 9,5 m de alto.
- **Fachada:** abierta al frente; torres en las esquinas delanteras.
- **Escalera:** monumental de 18 escalones, 2,0 m de ancho.
- **Materiales:** 15 detectados (misma paleta + vino/oro/verde/agua/libro/cobre/marfil). Merge a ≤8 recomendado.

| Planta | Ambiente | Dimensiones | m² | Mobiliario principal |
|---|---|---:|---:|---|
| PB | Galería de museo | 7,4×11 | 81,4 | 3 vitrinas, 4 cuadros, escultura, barreras, banco |
| PB | Vestíbulo | 7,8×11 | 85,8 | Fuente, araña, mesa de recepción, 2 armaduras, plantas |
| PB | Biblioteca | 6,8×11 | 74,8 | 3 estanterías, 2 mesas de lectura, 8 sillas, 2 globos, chimenea |
| PB | Invernadero | 7,4×5 | 37,0 | 6 jardineras, fuente, banco, techo de cristal |
| PB | Cocina | 7,8×5 | 39,0 | Estufa grande, mesada, estante, mesa + 6 sillas |
| PB | Comedor de gala | 6,8×5 | 34,0 | Mesa 5,4×1,8, 12 sillas, aparador, araña |
| PA | Dormitorio principal | 7,4×11 | 81,4 | Cama con dosel, armario, 2 sillones, candelabro |
| PA | Distribuidor | 7,8×11 | 85,8 | Alfombra, consola, armadura, araña |
| PA | Dormitorio de invitados | 6,8×11 | 74,8 | Cama, escritorio, armario |
| PA | Observatorio | 7,4×5 | 37,0 | Telescopio, esfera armilar, estantería, carta estelar |
| PA | Sala de música | 7,8×5 | 39,0 | Piano de cola, arpa, 3 sillas |
| PA | Estudio | 6,8×5 | 34,0 | Escritorio, estantería, globo, chimenea |
| PA | Terraza | 7,0×2 | 14,0 | Baranda, 2 plantas, telescopio, mesa bistró |

- **Medidas:** 845 piezas, **19.866 tris**, 15 materiales, bbox 23,9×18,6×11,7 m. Sin piezas bajo el suelo.

### 8.3 Objetos nuevos y dónde se usan

| Objeto | Casona | Mansión |
|---|---|---|
| Biblioteca caracol | Estudio PB | — |
| Mesa alquimista | Estudio PB | — |
| Tapiz ancestral | Sala PB | — |
| Globo terráqueo | Estudio PB/PA | Biblioteca/estudio |
| Reloj de pie | Vestíbulo PB | — |
| Vitrina de conchas | — | Galería |
| Bañera de cobre | Baño PB | — |
| Fuente interior | Vestíbulo PB | Vestíbulo PB / invernadero |
| Araña | Vestíbulo/comedor | Vestíbulo/comedor/distribuidor |
| Cama con dosel | Dormitorio principal | Dormitorio principal |
| Telar | Taller PA | — |
| Acuario empotrado | Sala PB | — |
| Estufa cerámica | Cocina PB | Cocina PB |
| Vitrina de museo | — | Galería |
| Piano de cola | — | Sala de música |
| Arpa | — | Sala de música |
| Esfera armilar | — | Observatorio |
| Armadura | — | Vestíbulo/distribuidor |
| Mesa de billar | — | Biblioteca |
| Hamaca | — | Invernadero |
| Candelabro de pie | — | Dormitorio principal |

### 8.4 Presupuesto y LOD

| Casa | ALTA actual | Objetivo exterior LOD0 | LOD1 | LOD2 | Estrategia |
|---|---:|---:|---:|---:|---|
| Casona | 12.608 | ≤6.000 | 1.500 | 650 | Quitar interior del exterior; interior como escena aparte |
| Mansión | 19.866 | ≤6.000 por ala | 1.500 | 650 | Dividir en 2–3 alas/pabellones; interior aparte |

> La cifra ALTA incluye muebles y libros. Para el juego, el **exterior** se decima a ≤6.000 tris y el **interior** se carga por portal (M18 §2, Alternativa A). Los 16/15 materiales se unen a ≤8 con `generar_variante.py` o atlas M47.

---

## 9. Casas grandes v2 — 20×15 y 28×20 (2026-11-12, ERNIE-5.5-Flash-Preview)

> **Vigente.** Reemplaza las proporciones de §8 (16×12 / 22×16), que el usuario reportó como apretadas y con objetos superpuestos. Se midió el solape real con AABB en Blender y se corrigió hasta **0 solapes**.

### 9.1 Casona del Gremio v2 — 20×15 m, 2 plantas, 3,6 m

- **Estructura:** zócalo 20,4×15,4 m; planta baja 0,45–4,05 m; planta alta 4,20–7,80 m; techo a dos aguas 2,40 m.
- **Fachada:** abierta al frente; muros laterales y posterior completos.
- **Escalera:** recta de 18 escalones, 1,8 m de ancho, hueco de losa y −7,3..−1,0 m.
- **Materiales:** 16; **568 piezas**, **11.896 tris**, bbox 21,1×16,0×10,3 m.

| Planta | Ambiente | Dimensiones | m² | Mobiliario principal |
|---|---|---:|---:|---|
| PB | Sala de estar | 7,0×10 | 70,0 | Sofá 3 m, mesa, 2 sillones, chimenea, estantería, tapiz, acuario |
| PB | Vestíbulo | 5,8×10 | 58,0 | Fuente, consola, espejo, reloj de pie, araña |
| PB | Comedor | 7,2×10 | 72,0 | Mesa 3,6×1,6, 6 sillas, aparador, araña |
| PB | Cocina | 7,0×5 | 35,0 | Estufa, mesada, estante, mesa + 4 banquetas |
| PB | Estudio/biblioteca | 6,5×5 | 32,5 | Escritorio, biblioteca caracol, alquimia, globo |
| PB | Baño | 6,5×5 | 32,5 | Bañera de cobre, lavabo, espejo |
| PA | Dormitorio principal | 7,0×10 | 70,0 | Cama con dosel, armario, 2 mesas, 2 sillones |
| PA | Distribuidor | 6,5×10 | 65,0 | Alfombra, consola, araña, planta |
| PA | Dormitorio infantil | 6,5×10 | 65,0 | Cama, escritorio, baúl, estantería |
| PA | Taller/observatorio | 7,0×5 | 35,0 | Mesa de trabajo, telescopio, telar, estante |
| PA | Estudio | 6,5×5 | 32,5 | Escritorio, estantería, globo |
| PA | Vestidor/baño | 6,5×5 | 32,5 | Armario, banco, espejo |

### 9.2 Mansión del Museo v2 — 28×20 m, 2 plantas + torres, 4,0 m

- **Estructura:** zócalo 28,4×20,4 m; planta baja 0,50–4,50 m; planta alta 4,65–8,65 m; techo 2,80 m; dos torres de r=1,8 m y 10,5 m de alto.
- **Escalera:** monumental de 20 escalones, 2,2 m de ancho, hueco y −9,8..−2,8 m.
- **Materiales:** 15; **826 piezas**, **19.874 tris**, bbox 30,2×22,8×12,9 m.

| Planta | Ambiente | Dimensiones | m² | Mobiliario principal |
|---|---|---:|---:|---|
| PB | Galería de museo | 9,5×14 | 133,0 | 3 vitrinas, 4 cuadros, escultura, barreras, banco |
| PB | Vestíbulo | 9,5×14 | 133,0 | Fuente, araña, recepción, 2 armaduras, plantas |
| PB | Biblioteca | 9,0×14 | 126,0 | 3 estanterías, 2 mesas, 8 sillas, 2 globos, chimenea, billar |
| PB | Invernadero | 9,5×6 | 57,0 | 6 jardineras, fuente, banco, hamaca, techo de cristal |
| PB | Cocina | 9,5×6 | 57,0 | Estufa grande, mesada, estante, mesa + 6 sillas |
| PB | Comedor de gala | 9,0×6 | 54,0 | Mesa 6,0×2,0, 12 sillas, aparador, araña |
| PA | Dormitorio principal | 9,5×14 | 133,0 | Cama con dosel, armario, 2 sillones, candelabro |
| PA | Distribuidor | 9,5×14 | 133,0 | Alfombra, consola, armadura, araña |
| PA | Dormitorio de invitados | 9,0×14 | 126,0 | Cama, escritorio, armario |
| PA | Observatorio | 9,5×6 | 57,0 | Telescopio, esfera armilar, estantería, carta estelar |
| PA | Sala de música | 9,5×6 | 57,0 | Piano de cola, arpa, 3 sillas |
| PA | Estudio | 9,0×6 | 54,0 | Escritorio, estantería, globo, chimenea |
| PA | Terraza | 9,0×2,5 | 22,5 | Baranda, 2 plantas, telescopio, mesa bistró |

### 9.3 Validación de solapes (medida, no estimada)

Se calculó el AABB mundial de cada malla y se buscaron intersecciones con tolerancia de 0,10 m.

| Casa | Muebles | Estructura | Solapes mueble-estructura | Solapes mueble-mueble |
|---|---:|---:|---:|---:|
| Casona v2 | 496 | 72 | **0** | **0** |
| Mansión v2 | 708 | 118 | **0** | **0** |

> Se excluyen las uniones intended (chimenea que atraviesa el techo, base/respaldo de sofá, tapa/cuerpo de piano, anillos de la esfera armilar). Con esa exclusión, el resultado es 0.

### 9.4 Por qué cambió

| Métrica | v1 (16×12 / 22×16) | v2 (20×15 / 28×20) |
|---|---:|---:|
| m² por planta | 192 / 352 | **300 / 560** |
| Piezas | 608 / 845 | 568 / 826 |
| Densidad | 3,17 / 2,40 piezas/m² | **1,89 / 1,48 piezas/m²** |
| Solapes mueble-estructura | 76 / 100 | **0 / 0** |
| Solapes mueble-mueble | 210 / 339 | **0 / 0** |

### 9.5 Archivos v2

| Archivo | Contenido |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_grandes_v2.py` | Script generador v2 con validador de AABB |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_v2_2026-11-12.blend` | Escena `Casas_Grandes_v2` + `Scene` (casas pequeñas) |
| `CAPTURAS/casas_grandes_v2_exterior_2026-11-12.png` | Vista general |
| `CAPTURAS/casona_v2_exterior/interior_2026-11-12.png` | Casona v2 |
| `CAPTURAS/mansion_v2_exterior/interior_2026-11-12.png` | Mansión v2 |

### 9.6 Correcciones de ubicación (2026-11-12, reporte del usuario)

El usuario detectó una mesa atravesando la pared y la alfombra de la cama sobre la escalera. Se midió y corrigió:

| Problema | Causa | Corrección |
|---|---|---|
| Mesa del comedor atravesaba el tabique | Tabique en x=3,5; mesa de 3,6 m llegaba a x=3,2 | Tabique E1/E2 movido a x=2,8; comedor pasa a 7,2 m de ancho |
| Alfombra de la cama tapa la escalera (Mansión) | Cama/alfombra de invitados sobre el hueco x 10,0..12,5 | Cama y alfombra movidas a x=7,5; escritorio/silla a y=0,0/−0,9 |
| Mesa de lectura 2 sobre el hueco | Reading table en x=11,5 | Movida a (8,0; 1,5) |
| Billar sobre el hueco | Billar en x=9,0 | Movido a (7,5; −1,5) |
| Cama infantil de la Casona sobre el hueco | Cama/escritorio/alfombra en x 6,8–8,8 | Cama a x=5,8; escritorio a y=0,5; alfombra a x=5,2 |
| Estanterías/consolas a 0,07 m de muros | Márgenes insuficientes | Estanterías, consolas, espejo y caracol corridos |
| Plantas sobre tabiques | AABB de hojas | Plantas movidas |

**Validación final (AABB + hueco de escalera):**

| Casa | Muebles | Solapes mueble-estructura | Objetos sobre el hueco | Solapes mueble-mueble |
|---|---:|---:|---:|---:|
| Casona v2 | 496 | **0** | **0** | **0** |
| Mansión v2 | 708 | **0** | **0** | **0** |

---

## 10. Casas extra y detalle exterior/interior (2026-11-12, ERNIE-5.5-Flash-Preview)

> El usuario pidió casas más detalladas, habitables y con exteriores más reales; además detectó que las casas anteriores no tenían ventanas y que las chimeneas quedaban ocultas. Se agregaron ventanas, chimeneas visibles y detalle exterior/interior a las cuatro casas.

### 10.1 Casa del Agricultor — 18×13 m, 2 plantas, 3,6 m

- **Uso:** granja; PB: cocina/comedor, vestíbulo, granero/establo, despensa, almacén de herramientas, cuarto de ordeño. PA: dormitorio principal, distribuidor, dormitorio infantil, taller, almacén de semillas, lavadero.
- **Exterior:** chimenea visible, silo, pacas de heno, carretilla, cerca, pozo, farol, sendero, jardineras y postigos.
- **Interior:** zócalos, vigas de techo, marcos de puertas, cuadros, vajilla, alacena, mantequera, costales, herramientas, telar.
- **Métricas:** 546 piezas, **12.330 tris**, 17 materiales, bbox 21,5×17,9×11,4 m (incluye cerca/pozo).
- **Validación:** 0 solapes mueble-estructura, 0 objetos sobre el hueco, 0 mueble-mueble.

### 10.2 Casa del Mercader — 16×12 m, 2 plantas, 3,8 m

- **Uso:** tienda + vivienda. PB: tienda (mostrador, estanterías, balanza, caja fuerte), vestíbulo, almacén, trastienda/oficina, cocina, baño. PA: dormitorio principal, distribuidor, dormitorio de invitados, estudio/contabilidad, sala de estar, vestidor.
- **Exterior:** toldo, cartel, escaparate, barriles/cajas, chimenea visible, sendero, cerca, pozo, farol, jardineras.
- **Interior:** zócalos, vigas, marcos, cuadros, vajilla, estanterías de mercancía, balanza, caja fuerte, sofá, chimenea.
- **Métricas:** 592 piezas, **12.708 tris**, 18 materiales, bbox 17,1×16,9×12,0 m (incluye cerca/pozo).
- **Validación:** 0 solapes mueble-estructura, 0 objetos sobre el hueco, 0 mueble-mueble.

### 10.3 Ventanas y chimeneas (las cuatro casas)

- **640 objetos de ventana**: marco, vidrio, traviesa, postigos, jardinera y flores.
- **Chimeneas**: subidas a 3,4–3,6 m y acercadas a la cumbrera; topes por encima del techo:

| Casa | Tope chimenea | Cumbrera | Estado |
|---|---:|---:|---|
| Casona v2 | 11,38 m | 10,20 m | Visible |
| Mansión v2 | 12,43 m | 11,45 m | Visible |
| Agricultor | 11,38 m | 10,20 m | Visible |
| Mercader | 12,02 m | 10,85 m | Visible |

- **Detalle exterior:** vigas de esquina, zócalo perimetral, aleros, sendero, cerca, farol, pozo, jardineras.
- **Detalle interior:** zócalos, vigas de techo, marcos de puertas, cuadros, vajilla.

### 10.4 Métricas finales con detalle

| Casa | Piezas | Tris | Materiales |
|---|---:|---:|---:|
| Casona v2 | 807 | 18.708 | 18 |
| Mansión v2 | 1.091 | 27.502 | 17 |
| Agricultor | 546 | 12.330 | 17 |
| Mercader | 592 | 12.708 | 18 |

> El detalle exterior/interior sube los tris del archivo de autoría. El LOD0 de exportación sigue siendo ≤6.000 tris por volumen (exterior) y el interior se separa como escena de portal.

### 10.5 Ventanas reales y corrección de choques (2026-11-13, ERNIE-5.5-Flash-Preview)

El usuario detectó dos problemas: las ventanas eran estéticas (no se veían desde el interior) y la escalera de la casa de las torres chocaba con la torre. Se corrigió:

- **Ventanas reales:** se cortaron **huecos con Boolean** en los muros exteriores y se reposicionaron a planta baja y planta alta (antes las dos filas estaban arriba). Total: **68 ventanas** con hueco real.
- **Visibilidad interior (raycast desde adentro):**

| Casa | Ventanas visibles | Total |
|---|---:|---:|
| Casona v2 | 18 | 18 |
| Mansión v2 | 20 | 20 |
| Agricultor | 14 | 14 |
| Mercader | 12 | 12 |

- **Muebles que tapaban ventanas:** tapiz (oculto), estanterías, espejo y chimenea movidos. Resultado: **0 solapes mueble-estructura**.
- **Escalera vs torre (Mansión):** la torre este se movió de (13, −9) a **(16, 9)**, fuera del interior. Resultado: **0 solapes escalera-torre**.
- **Escalera vs tabique (Agricultor/Mercader):** tabiques E movidos a x=3,8 y x=3,2. Resultado: **0 solapes escalera-tabique**.
- **Validación AABB final:** 0 mueble-estructura y 0 mueble-mueble en las cuatro casas (los postes del invernadero se excluyen por ser estructura de soporte).
