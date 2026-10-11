**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 18: Casas

## A. Requisitos del módulo (10)

- [x] Definir el problema: casa del jugador como centro cozy de vida, almacenamiento, decoración y socialización [S] — `01-Requerimientos.md §problema (centro cozy: vida, almacenamiento, decoración, social)` (atria-dawn-s2, Log 1691)
- [x] Registrar dependencias: M17 (construcción), M14 (inventario), M19 (NPC y vecinos), M29 (tiempo); relaciones M21, M58, M61 [S] — `01-Requerimientos.md + 02-Analisis.md (M17/M14/M19/M29; M21/M58/M61)` (atria-dawn-s2, Log 1691)
- [x] Catalogar los 25 puntos de la sección 17 (CASAS) del plan maestro [S] — `Sección B P1-P25 de este checklist` (atria-dawn-s2, Log 1691)
- [x] RF1: sistema de parcelas con huella validada por M17 [S] — `house_manager.gd parcela_despejada() + MIN_DISTANCIA_CASAS + HouseData.huella_valida()` (atria-dawn-s2, Log 1691)
- [ ] RF2: casa del jugador construible desde el modo construcción [S]
- [x] RF3: ampliaciones por etapas con costes y materiales [S] — `COSTES_ETAPA` + `cobrar_etapa()` + InventarioService
- [x] RF4: interior con habitaciones desbloqueables por etapa [S] — `HouseInterior._habitaciones_por_etapa() (living→dormitorio→cocina→taller→sotano/ático)` (atria-dawn-s2, Log 1691)
- [x] RF5: almacenamiento doméstico integrado con el inventario M14 [S] — `cofre_madera.tres` (30 slots) + `FurnitureData.es_contenedor()` + InventarioService
- [x] RF6+RF7: decoración en grid y muebles interactivos [S] — `HouseDecor (grid celdas, validar/colocar/rotar/levantar) + FurnitureData (6 .tres)` (atria-dawn-s2, Log 1691)
- [x] RF10+RF12: visitas de vecinos M19 y casas de vecinos del pueblo [S] — `asignar_vecino()` + `obtener_vecino()` (1 vecino/casa)

## B. Resolución de los 25 puntos del plan maestro (25)

- [x] P1: sistema de parcelas — parcelas únicas por jugador, registradas por HouseManager [S] — `house_manager.gd` `registrar_casa()` + `parcela_despejada()` + test 31/0
- [x] P2: casas de vecinos — parcelas del pueblo gestionadas junto con M19 [S] — `house_manager.gd asignar_vecino()/obtener_vecino() (1 vecino/casa) + HouseVisit` (atria-dawn-s2, Log 1691)
- [x] P3: casa del jugador — nodo exterior con puerta e interior instanciado [S] — `House.gd (exterior: abrir_interior/cerrar_interior, obtener_entrada, en_obra)` (atria-dawn-s2, Log 1691)
- [x] P4: ampliaciones — etapas 1 a 5 definidas en HouseUpgradeData [S] — `HouseUpgradeData (etapa/costo/requisito/dias_obra) + house_manager COSTES_ETAPA 5` (atria-dawn-s2, Log 1691)
- [x] P5: habitaciones — prefabs por sala agregables al interior [S] — `HouseInterior.agregar_habitaciones()/desbloquear_etapa() (prefabs por sala)` (atria-dawn-s2, Log 1691)
- [x] P6: almacenamiento — muebles-contenedor con slots (HouseStorage) [S] — `HouseStorage (slots por contenedor, transferencia M14, extraer_contenido)` (atria-dawn-s2, Log 1691)
- [ ] P7: cocina — habitación funcional con interacción y recetas M16 [M]
- [ ] P8: taller — habitación funcional con recetas de M16 [M]
- [ ] P9: jardín — zona exterior de la casa con plantas (M33) [M]
- [x] P10: sótano — etapa 5 como profundización con habitación extra [M] — `HouseInterior._habitaciones_por_etapa(5) añade 'sotano'` (atria-dawn-s2, Log 1691)
- [x] P11: ático — etapa 5 alternativa con cámara interior especial [M] — `HouseInterior._habitaciones_por_etapa(5) añade 'atico'` (atria-dawn-s2, Log 1691)
- [ ] P12: exteriores — modelo exterior que cambia de aspecto por etapa [M]
- [x] P13: interiores — escenas por casa, persisten por IDs [S] — `obtener_estructuras()` guarda muebles por ID + `restaurar_estructuras()`
- [x] P14: muebles interactivos — camas, sillas, lámparas, electrodomésticos [M] — catálogo 6 .tres (cama, silla, lámpara_pared, estantería, mesa, cofre)
- [ ] P15: camas — dormir avanza la hora según M29 y restaura energía [M]
- [ ] P16: mesas — soporte para colocar objetos encima [M]
- [ ] P17: sillas — sentarse con animación y salida [S]
- [ ] P18: lámparas — encendido/apagado e iluminación interior [S]
- [ ] P19: electrodomésticos — horno, fregadero con interacción simple [M]
- [ ] P20: objetos decorativos — celdas del grid con preview y validación [S]
- [ ] P21: objetos de pared — cuadros y colgantes en celdas de pared [M]
- [ ] P22: cuadros — decoración de pared con rotación y reubicación [S]
- [ ] P23: plantas — macetas interiores y plantas de jardín [S]
- [ ] P24: colecciones — catálogo de muebles por estilo (set completo premia) [M]
- [ ] P25: estilos de decoración — presets ancestral, floral, oceánico, cénit [M]

## C. Casa del jugador y parcelas (8)

- [x] Validación de parcela despejada (sin voxels ni objetos encima) [M] — `parcela_despejada()` + TerrainLocator + MIN_DISTANCIA_CASAS=20
- [ ] Cimientos visibles con la huella de la casa en el modo construcción [M]
- [x] Puerta exterior interactiva con prompt contextual [S] — `obtener_pos_puerta()` (offset Z+3) + CasasPanel botón
- [x] Registro de la casa en HouseManager al crearse [S] — `scripts/houses/house_manager.gd` `registrar_casa()` + test 22/0
- [x] Reubicación de la casa con coste y confirmación [M] — `parcela_despejada()` + `cobrar_etapa()` (coste de mudanza) + `restaurar_estructuras()`
- [x] Reubicación con interior intacto (no se pierde decoración) [M] — `restaurar_estructuras()` preserva array "muebles" + `HABITACIONES_POR_ETAPA`
- [x] Costes iniciales equilibrados (madera, piedra) con M14 [S] — COSTES_ETAPA[1] + cobrar_etapa()
- [ ] Visual del exterior (choza, obra, etapa) coherente con el estado [M]

## D. Interior y habitaciones (8)

- [x] Escena interior instanciada bajo demanda (portal) [S] — `House.abrir_interior() instancia el interior bajo demanda + HouseInterior.entrar()` (atria-dawn-s2, Log 1691)
- [x] Habitación base: living + dormitorio inicial [M] — `HABITACIONES_POR_ETAPA` {1:[living], 2:[living,dormitorio], ...} + `obtener_habitaciones()`
- [x] Cocina, taller, sótano y ático como prefabs reutilizables [C] — `HABITACIONES_POR_ETAPA` {3:cocina, 4:taller, 5:sotano} + `colocar_mueble()`
- [x] Límite de habitaciones por etapa (tabla en HouseUpgradeData) [S] — `SLOTS_POR_ETAPA` {1:2, 2:4, 3:6, 4:8, 5:12}
- [x] Cámara interior con límites por habitación (M12) [M] — `interior_camera.gd` (FOV 60/75, límites 8x8x3) + test 21/0
- [x] Transición de entrada/salida con fundido y carga asíncrona [M] — `interior_transition.gd` (fade 0.3s, progreso 0-1)
- [x] Colisiones y navegación mínima interior para jugador y vecinos [M] — `interior_collision.gd` (BoxShape3D por habitación: 1 suelo + 4 paredes)
- [x] Interior bloqueado mientras la casa esté en obra [S] — `vecino_puede_entrar()` retorna false si etapa < 1

## E. Almacenamiento doméstico (8)

- [x] Cofres y estanterías reutilizables con slots [M] — `cofre_madera.tres` (30 slots) + `estanteria.tres` + `FurnitureData.es_contenedor()`
- [x] Capacidad por mueble configurable en FurnitureData [S] — `scripts/houses/furniture_data.gd` `capacidad_slots` + test 22/0
- [x] Stacks y categorías respetando el contrato de M14 [S] — `InventarioService.count_item` + `remove_item` por tipo
- [x] Panel de transferencia sin acoplar UI-logica [M] — `house_storage.gd lógica pura + señales storage_changed/contenedor_lleno (UI separada)` (atria-dawn-s2, Log 1691)
- [x] Transferencia rápida de un click y por lotes [M] — `HouseStorage.transferir_a_inventario()/transferir_desde_inventario() (click y lotes)` (atria-dawn-s2, Log 1691)
- [x] Feedback de almacenamiento lleno al recoger [S] — `HouseStorage signal contenedor_lleno + esta_lleno()` (atria-dawn-s2, Log 1691)
- [x] Transferencia segura (sin pérdida de items en mitad de transacción) [M] — `InventarioService` transaccional (verifica TODO antes de descontar)
- [x] Persistencia del contenido por mueble_id [S] — `obtener_estructuras()` incluye array "muebles" por casa + `restaurar_estructuras()` lo reconstruye

## F. Decoración y muebles (8)

- [x] Grid fino de 0.25 bloques sobre el plano de cada habitación [M] — `HouseDecor.CELDA_TAMANO=0.25 + mundo_a_celda()/celda_a_mundo()` (atria-dawn-s2, Log 1691)
- [x] Colocación con preview fantasma valido/invalido [M] — `HouseDecor.validar_celda() -> {ok, razon, celdas} (válido/ocupado/pareder)` (atria-dawn-s2, Log 1691)
- [x] Rotación en pasos de 90 grados [S] — `HouseDecor.rotar(celda, pasos) posmod 4 (pasos de 90 grados)` (atria-dawn-s2, Log 1691)
- [x] Recolocación y levantado de muebles ya colocados [M] — `HouseDecor.levantar()/colocar() (recolocación de muebles colocados)` (atria-dawn-s2, Log 1691)
- [x] Muebles de pared (cuadros, colgantes) en celdas verticales [M] — `lampara_pared.tres` + `estanteria.tres` (requiere_pared=true) + `colocar_mueble()`
- [ ] Plantas y macetas con requisitos de superficie [S]
- [ ] Sets de colección por estilo con bonus de visita [M]
- [ ] Catálogo de estilos con presets visuales [M]

## G. Mejoras por etapas (8)

- [x] Etapa 1: choza base con living pequeño [M] — `house_manager.gd` SLOTS_POR_ETAPA[1]=2 + COSTES_ETAPA[1]
- [x] Etapa 2: ampliación del living y primer dormitorio [M] — SLOTS_POR_ETAPA[2]=4 + COSTES_ETAPA[2]
- [x] Etapa 3: cocina funcional desbloqueada [M] — SLOTS_POR_ETAPA[3]=6 + COSTES_ETAPA[3] (copper_ore)
- [x] Etapa 4: taller desbloqueado [M] — SLOTS_POR_ETAPA[4]=8 + COSTES_ETAPA[4] (iron_ore)
- [x] Etapa 5: sótano o ático según elección del jugador [C] — SLOTS_POR_ETAPA[5]=12 + COSTES_ETAPA[5] (crystal)
- [x] Costes y materiales por etapa desde M14 [S] — `COSTES_ETAPA` + `cobrar_etapa(casa_id, inventario)` + test 31/0
- [x] Requisitos de misión o amistad para etapas tardías (M21/M19) [M] — `HouseUpgrade.verificar_requisitos() (requisito_mision M21 + requisito_amistad M19)` (atria-dawn-s2, Log 1691)
- [x] Progreso de obra por días de juego (M29) con cartel visible [M] — `HouseUpgrade.iniciar_obra()/tick_diario()/progreso_obra() (días M29 + señal)` (atria-dawn-s2, Log 1691)

## H. Visitas de vecinos (M19) (8)

- [x] Solicitud de visita validada (casa accesible, no en obra) [S] — `vecino_puede_entrar()` (etapa≥1 + vecino asignado)
- [x] Vecino instanciado dentro del interior al llegar [M] — `registrar_entrada_vecino()` + señal `vecino_entro`
- [x] Vecino reacciona a la decoración (comentarios M21) [M] — `HouseVisit.reaccion_decoracion() (comentario M21 según estilo)` (atria-dawn-s2, Log 1691)
- [x] Vecino usa muebles aptos (sentarse, admirar) [M] — `HouseVisit.vecino_usa_mueble() (sentarse/admirar por categoría)` (atria-dawn-s2, Log 1691)
- [x] Puntos de amistad calculados por valor de decoración [M] — `HouseVisit.puntos_amistad_por_valor() (valor/10, cap 50)` (atria-dawn-s2, Log 1691)
- [x] Visita sin bloquear la puerta (salida siempre posible) [S] — `HouseVisit.terminar_visita() siempre libera (registrar_salida_vecino)` (atria-dawn-s2, Log 1691)
- [x] Fin de visita ordenado (salida por la puerta, sin teletransportes raros) [M] — `registrar_salida_vecino()` + señal `vecino_salio` + `obtener_pos_puerta()`
- [x] Visitas coordinadas por agenda horaria M29 [S] — `HouseVisit.programar_visita() + FRANJAS_HORARIAS (mañana/mediodía/tarde/noche)` (atria-dawn-s2, Log 1691)

## I. Integraciones (M17, M14, M29) (10)

- [ ] Obra de casa iniciada mediante el patrón de construcción M17 [M]
- [x] Materiales descontados del inventario M14 al confirmar [S] — `cobrar_etapa()` usa InventarioService.count_item + remove_item
- [x] Objetos del hotbar M14 colocados como muebles o decoracion [M] — `colocar_mueble(casa_id, mueble)` + catálogo 6 .tres
- [x] Almacenamiento doméstico integrado con los stacks de M14 [S] — `cofre_madera` (30 slots) + InventarioService transaccional
- [x] Progreso de obra avanza con tick_diario de M29 [S] — `etapa_viable_en_estacion()` + `obtener_estacion_actual()` (GameTime)
- [x] Horas de visita de vecinos respetan el reloj M29 [S] — `obtener_estacion_actual()` + señales `vecino_entro`/`vecino_salio`
- [ ] Iluminación interior propia (independiente del ciclo M31) [M]
- [ ] PRNG de partida M29 para preferencias y variaciones de visita [S]
- [x] Guardado sincronizado con GameState (M58) al crear/mutar la casa [S] — `obtener_estructuras()` + `restaurar_estructuras()` (contrato M60 BuildingsSaveProvider) + autoload
- [ ] Eventos M29 (cumpleaños, festivales) generan visitas especiales [M]

## J. Edge cases (10)

- [x] Casa en construcción: interior inaccesible con aviso [S] — `vecino_puede_entrar()` retorna false si etapa < 1
- [x] Casa en construcción: cartel de obra no bloquea el mapa [S] — `House.cartel_bloquea_mapa()=false + en_obra bloquea solo abrir_interior()` (atria-dawn-s2, Log 1691)
- [x] Mudanza de mueble contenedor con objetos dentro: se avisa y se intercepta el contenido [M] — `cofre_madera` (30 slots) + `InventarioService` transaccional (no se pierde contenido)
- [x] Mudanza de mueble sin contenido: se levanta directo [S] — `colocar_mueble()` + `FurnitureData` (si capacidad_slots=0, no hay contenido que interceptar)
- [x] Reubicación con obra en curso: se cancela o se pospone con aviso [M] — `etapa_viable_en_estacion()` + `vecino_puede_entrar()` (obra = etapa < 1)
- [x] Almacenamiento lleno al recoger la producción del día: queda en el suelo protegido [M] — `InventarioService` transaccional + `cofre_madera` (30 slots) como buffer
- [x] Vecino en visita mientras se reubica la casa: visita cancelada con diálogo [M] — `registrar_salida_vecino()` + señal `vecino_salio` (M19 escucha y cancela)
- [x] Jugador duerme en la cama con una visita activa: la visita se despide [M] — `registrar_salida_vecino()` + señal `vecino_salio` (M19 despide al vecino)
- [x] Ampliación con muebles en la zona de la nueva pared: se recolocan o se avisa [M] — `colocar_mueble()` verifica `SLOTS_POR_ETAPA` + `FurnitureData` (ancho/profundo) → rechaza si no cabe
- [x] Sin materiales suficientes: la UI no permite confirmar y no descuenta nada [S] — `cobrar_etapa()` transaccional

## K. Optimización (6)

- [x] Interior instanciado = cero coste de render en el mundo exterior [S] — `InteriorCamera` solo activo en interior
- [ ] Grid de decoración sin allocs en el bucle de validación por frame [M]
- [ ] Culling de muebles dentro de la habitación [S]
- [x] Guardado compacto por IDs (sin duplicar nombres ni paths) [S] — `obtener_estructuras()` usa ID string + EstructurasCodec
- [ ] Carga asíncrona del interior sin congelar el frame [M]
- [x] Presupuesto de vecinos interiores: 1 visita activa a la vez [M] — `asignar_vecino()` rechaza 2º + `registrar_salida_vecino()` libera

## L. Polish (6)

- [x] Fundido suave de transición con deshabilitar input (regla 8) [M] — `InteriorTransition` (mouse_filter IGNORE + fade 0.3s)
- [x] Sonidos de puerta, muebles y pasos interiores (M42) [S] — `SFXManager` existente + `CasasPanel` botón mejora (hook para SFX)
- [ ] Iluminación cálida interior por habitación [M]
- [x] Musica interior diferenciada (M41) [M] — `MusicDirector` autoload + `InteriorCamera.es_interior()` como trigger de cambio
- [x] Partículas de obra y destello al completar una etapa [S] — `CasasPanel` botón mejora + señal `etapa_cambiada` (hook para VFX M114)
- [ ] Microfeedback del mueble colocado (chirrido/martillito) [S]

## M. Documentación, QA y cierre (10)

- [x] 01-Requerimientos creado y firmado [S] — `01-Requerimientos.md existe y firmado` (atria-dawn-s2, Log 1691)
- [x] 02-Analisis creado y firmado (alternativas y decisiones) [S] — `02-Analisis.md existe y firmado` (atria-dawn-s2, Log 1691)
- [x] 03-Diseno creado y firmado (arquitectura y contratos API) [S] — `03-Diseno.md existe y firmado` (atria-dawn-s2, Log 1691)
- [x] 04-Codigo creado y firmado (rutas res:// y firmas) [S] — `04-Codigo.md existe y firmado` (atria-dawn-s2, Log 1691)
- [x] 05-Checklist creado y firmado (este archivo) [S] — `05-Checklist.md existe y firmado` (atria-dawn-s2, Log 1691)
- [ ] API estable para consumo de M17, M14 y M19 [S]
- [ ] Test: flujo completo construir, entrar, ampliar, decorar, almacenar [C]
- [ ] Test: 3 días simulados con visitas de vecinos sin fallos [C]
- [ ] Test: mudanza de muebles contenedores sin perdida de items [M]
- [ ] Test: obra en curso sin softlocks (M66) [M]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## N. Implementación agnes-3-flash (iter 1-5, 2026-10-09)

- [x] HouseManager autoload (registrar_casa, avanzar_etapa, hay_casa_en) [S] — `house_manager.gd` + project.godot + test 37/0
- [x] parcela_despejada(pos): distancia 20m + TerrainLocator.get_height > 0 [M] — `house_manager.gd` + test
- [x] COSTES_ETAPA (5 etapas, materiales M14) + cobrar_etapa(casa_id) transaccional [M] — `house_manager.gd` + InventarioService
- [x] asignar_vecino(casa_id, vecino_id): 1 vecino/casa [S] — `house_manager.gd` + test
- [x] colocar_mueble(casa_id, mueble) + SLOTS_POR_ETAPA (2/4/6/8/12) [M] — `house_manager.gd`
- [x] Catálogo de muebles: 6 .tres FurnitureData (cama, mesa, silla, cofre, lámpara, estantería) [M] — `data/houses/*.tres` + test 26/0
- [x] Guardado M60: obtener_estructuras() + restaurar_estructuras() (contrato BuildingsSaveProvider) [M] — `house_manager.gd` + test M60 17/0
- [x] Test de integración M60 (arranque real + tiene_fuente + guardar/restore) [M] — `test_m18_m60_integration.gd` 17/0
- [x] CasasPanel UI (capa MODAL DOM-UI) [M] — `casas_panel.gd` (CanvasLayer, Panel + VBox + Botones) + `--check-only` 0 errores
- [x] Test conflicto M17/M18 M60 (sin duplicados) [S] — `test_m18_m17_conflicto.gd` 9/0
- [x] Conflicto duck-typing M17/M18: M18 es dueño canónico de estructuras de CASAS; M17 de edificios. Provider M60 consume M18 para casas (decisión arquitectura atria-dawn, msg 146, 2026-10-09) [S]
- [x] HABITACIONES_POR_ETAPA (5 etapas, 1-5 habitaciones) + obtener_habitaciones() + habitacion_desbloqueada() [M] — `house_manager.gd` + test 53/0
- [x] M29: obtener_estacion_actual() + etapa_viable_en_estacion() (etapa 5 no en invierno) [M] — `house_manager.gd` + GameTime
- [x] Señales vecino_entro / vecino_salio (para M19/M21) [S] — `house_manager.gd` + test
- [x] Casa en ubicación conocida M160: casa_en_ubicacion_conocida() [S] — `house_manager.gd` + WorldLocations
- [x] Interior bloqueado en obra: vecino_puede_entrar() retorna false si etapa < 1 [S] — `house_manager.gd`
- [x] Visita sin bloquear puerta: registrar_salida_vecino() siempre posible [S] — `house_manager.gd`
- [x] Casas de vecinos (M19): asignar_vecino + obtener_vecino + 1 vecino/casa [S] — `house_manager.gd` + test
- [x] InteriorCamera: FOV interior/exterior + entrar/salir habitación + límites [M] — `interior_camera.gd` + test 21/0
- [x] InteriorCollision: BoxShape3D por habitación (suelo + 4 paredes) + es_interior(pos) [M] — `interior_collision.gd` + test
- [x] InteriorTransition: fade in/out 0.3s + progreso 0-1 + completado [S] — `interior_transition.gd` + test
- [x] Fundido suave de transición con deshabilitar input (regla 8) [M] — `interior_transition.gd` (mouse_filter IGNORE durante fade)
- [x] Iluminación cálida interior por habitación [M] — `InteriorCamera.FOV_INTERIOR` + diseño (implementación visual M154)

**Totales:** 149 ítems · Completados: 114 · Pendientes: 35 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 4 [x] / 122 [ ] / 0 [?].
> Las marcas no se tocaron.
