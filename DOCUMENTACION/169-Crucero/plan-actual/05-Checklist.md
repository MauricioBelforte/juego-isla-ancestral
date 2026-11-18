**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25

# 05-Checklist.md — Módulo 169: Crucero de Lujo

> **Estado inicial (2026-11-14):** documentación creada, **0 de implementación**. Este checklist es
> la fuente de ítems verificables del módulo. Marcas: `[ ]` pendiente, `[x]` hecho, `[?]` no resuelto.
> Esfuerzo: `[S]` simple, `[M]` medio, `[C]` complejo.

## A. Documentación y planificación

- [x] A-01 Crear carpeta `DOCUMENTACION/169-Crucero/` con `plan-inicial/` y `plan-actual/` [S]  ✅
- [x] A-02 Escribir `plan-inicial/01-Requerimientos.md` [S]  ✅
- [x] A-03 Escribir `plan-inicial/02-Analisis.md` [M]  ✅
- [x] A-04 Escribir `plan-inicial/03-Diseno.md` [M]  ✅
- [x] A-05 Escribir `plan-inicial/04-Codigo.md` [M]  ✅
- [x] A-06 Escribir `plan-inicial/05-Checklist.md` con mínimo 100 ítems [M]  ✅
- [x] A-07 Copiar los 5 archivos a `plan-actual/` con la firma del agente que implemente [S]  ✅
- [x] A-08 Registrar la fila 169 en `CHECKLIST-GLOBAL.md` con prioridad, complejidad y dependencias [S]  ✅
- [x] A-09 Registrar el módulo en `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` [S]  ✅
- [x] A-10 Firmar cada archivo con modelo y plataforma (§3 AGENTS) [S]  ✅

## B. Exterior — modelado LOD alta (casco y estructura)

- [x] B-01 Modelar el casco con loft de secciones (obra viva + obra muerta), ≤ 1.400 v [C]  ✅
- [ ] B-02 Proa con tajamar y mascarón, ≤ 250 v [M] — **bloqueado: Blender no disponible** (mascarón de proa). Se hace con el addon MCP activo.
- [ ] B-03 Popa redonda con hélice y timón, ≤ 250 v [M] — **bloqueado: Blender no disponible** (hélice y timón de popa). Se hace con el addon MCP activo.
- [x] B-04 Cubierta 1 (72,0 × 14,0 m) con forjado y baranda, ≤ 700 v [M]  ✅
- [x] B-05 Cubierta 2 (66,0 × 13,2 m), ≤ 600 v [M]  ✅
- [x] B-06 Cubierta 3 (56,0 × 12,4 m), ≤ 550 v [M]  ✅
- [x] B-07 Cubierta 4 (34,0 × 10,0 m), ≤ 450 v [M]  ✅
- [x] B-08 Chimenea 1 con anillo y boca, ≤ 200 v [S]  ✅
- [x] B-09 Chimenea 2 con anillo y boca, ≤ 200 v [S]  ✅
- [x] B-10 Puente de mando con ventanas y timones, ≤ 600 v [C]  ✅
- [ ] B-11 Baranda de cubierta 1 con balaustres cada 1,5 m [M]
- [ ] B-12 Barandas de cubiertas 2, 3 y 4 [M]
- [ ] B-13 Escaleras exteriores entre cubiertas (2 tramos), ≤ 400 v [M]
- [ ] B-14 Fila de 24 ventanas de camarote en el casco, ≤ 500 v [M]
- [ ] B-15 Luces de navegación (roja babor, verde estribor, blanca mástil), ≤ 100 v [S]

## C. Exterior — detalle y mobiliario de a bordo

- [ ] C-01 Bote salvavidas tipo 1 (4 unidades, 200 v c/u) [M]
- [ ] C-02 Bote salvavidas tipo 2 (variante de color) [S]
- [ ] C-03 Pescantes para los 4 botes, ≤ 300 v [M]
- [ ] C-04 Ancla y cadena de proa, ≤ 200 v [S]
- [ ] C-05 Escotillas de carga en cubierta 1 [S]
- [ ] C-06 Pescantes de proa (chicla) [S]
- [ ] C-07 Paneles de carga y cajas de provisiones [S]
- [ ] C-08 Toldos de cubierta 4 (sombra) [M]
- [ ] C-09 Barandillas de la terraza de cubierta 4 [S]
- [ ] C-10 Letrero con el nombre del crucero en el casco [S]
- [ ] C-11 Bandera de popa [S]
- [ ] C-12 Defensas de goma en el casco (4) [S]
- [ ] C-13 Claraboyas de cubierta 3 [S]
- [ ] C-14 Ventanas del comedor (6 paneles) [M]
- [ ] C-15 Cristal del puente de mando [S]

## D. LOD media y baja

- [ ] D-01 Generar LOD media del exterior, ≤ 3.500 v [C]
- [ ] D-02 Generar LOD baja del exterior, ≤ 1.500 v [C]
- [ ] D-03 Verificar que el LOD baja conserve la silueta (72 m de eslora) [M]
- [ ] D-04 Verificar que el LOD media conserve chimeneas y botes [S]
- [ ] D-05 Auditar `z_min` de los 3 LOD con `auditar_glb_490.py` [S]
- [ ] D-06 Auditar escala (eslora 72 m ± 0,5 m) en los 3 LOD [S]

## E. Colisiones

- [ ] E-01 Colisión del casco con `ConvexPolygonShape3D` simplificado (12-16 puntos) [C]
- [ ] E-02 Colisión de los 4 forjados (cajas planas) [M]
- [ ] E-03 Colisión de barandillas en todo el perímetro [M]
- [ ] E-04 Rampa de colisión en las escaleras con `FloorMaxAngle = 45°` [M]
- [ ] E-05 Colisión de las puertas de camarote (`Area3D`) [M]
- [ ] E-06 Colisión del puente de mando y la terraza [S]
- [ ] E-07 Verificar que el jugador no pueda caer al agua desde cubierta 1 [M]
- [ ] E-08 Verificar que el jugador no atraviese paredes de los interiores [M]

## F. Interior — cubierta 1 (botes y carga)

- [ ] F-01 Crear `interior_cubierta_1.tscn` [M]
- [ ] F-02 Pasillo de carga con deflexión hacia proa [M]
- [ ] F-03 2 botes guardados en el interior [S]
- [ ] F-04 Escotillas de carga con tapa [S]
- [ ] F-05 Iluminación con 2 `OmniLight3D` [S]
- [ ] F-06 Puerta de acceso a la escalera (Area3D) [S]
- [ ] F-07 Presupuesto ≤ 2.500 v [S]
- [ ] F-08 Verificar carga/descarga sin parpadeo [M]

## G. Interior — cubierta 2 (camarotes)

- [ ] G-01 Crear `interior_cubierta_2.tscn` [M]
- [ ] G-02 Pasillo central de 66 m con 6 puertas [M]
- [ ] G-03 Modelar `camarote_interno` (2,4 × 3,0 m, 1 litera) [M]
- [ ] G-04 Modelar `camarote_exterior` (3,0 × 3,4 m, ventana redonda) [M]
- [ ] G-05 Modelar `camarote_familiar` (4,0 × 3,6 m, 2 camas + litera) [M]
- [ ] G-06 Modelar `suite_small` (4,4 × 4,0 m, cama + sofá) [M]
- [ ] G-07 Modelar `suite_grande` (5,6 × 4,6 m, ventanal + balcón) [C]
- [ ] G-08 Modelar `camarote_tripulacion` (2,0 × 2,6 m) [S]
- [ ] G-09 Instanciar los 6 camarotes en el pasillo (sin duplicar malla) [M]
- [ ] G-10 Variar el decorado entre camarotes del mismo tipo (2 variantes) [M]
- [ ] G-11 Puertas con `Area3D` para entrar y salir [M]
- [ ] G-12 Iluminación: 1 luz por camarote + luz de pasillo [M]

## H. Interior — cubierta 3 (comedor y casino)

- [ ] H-01 Crear `interior_cubierta_3.tscn` [M]
- [ ] H-02 Comedor con 12 mesas y 48 sillas (instanciadas) [C]
- [ ] H-03 Cocina con fogones, encimeras y despensa [M]
- [ ] H-04 Casino con 4 mesas de juego [M]
- [ ] H-05 Barra de bar con botellas [M]
- [ ] H-06 Escenario para música en vivo [S]
- [ ] H-07 Lámparas de araña (2) con `emission` [M]
- [ ] H-08 Ventanas al mar (6 paneles) [M]
- [ ] H-09 Puerta a la escalera y al pasillo [S]
- [ ] H-10 Presupuesto ≤ 4.000 v [M]
- [ ] H-11 Iluminación: 4 `OmniLight3D` + ambiente cálido [M]
- [ ] H-12 Verificar que las 12 mesas no se solapen (AABB con piezas planas excluidas) [M]

## I. Interior — cubierta 4 (puente y terraza)

- [ ] I-01 Crear `interior_cubierta_4.tscn` [M]
- [ ] I-02 Consola de mando con instrumentos [M]
- [ ] I-03 Timones (2 ruedas) [S]
- [ ] I-04 Silla del capitán [S]
- [ ] I-05 Terraza con tumbonas (4) [M]
- [ ] I-06 Barra exterior de bebidas [S]
- [ ] I-07 Presupuesto ≤ 2.000 v [S]
- [ ] I-08 Iluminación: 2 luces + sol del mundo [S]

## J. Navegación e integración con M28

- [ ] J-01 Agregar `crucero` a `data/vehiculos/vehicles.json` sin romper el esquema [M]
- [ ] J-02 Implementar `CruceroManager` como autoload [C]
- [ ] J-03 Implementar los 4 estados (ATRACADO, ABORDO, NAVEGANDO, EMERGENCIA) [M]
- [ ] J-04 Conectar el `Area3D "Puerto"` del casco al embarque [M]
- [ ] J-05 Implementar la ruta fija origen → destino (reutilizar `BoatRoute` de M28) [M]
- [ ] J-06 Implementar el desembarco con fade y descarga del interior [M]
- [ ] J-07 Persistir pasaje, camarote y cubierta en M59 [M]
- [ ] J-08 Bloquear el control del crucero (no es manejable) [S]
- [ ] J-09 Emitir las 5 señales nuevas en `EventBus` [M]
- [ ] J-10 Verificar que M28 (`Boat`, `BoatDeck`) no cambió de comportamiento [M]

## K. Streaming (M63)

- [ ] K-01 Registrar una `Sector` por cubierta [M]
- [ ] K-02 Cargar el interior al entrar y descargarlo al salir [C]
- [ ] K-03 Verificar que nunca haya 2 cubiertas en memoria [M]
- [ ] K-04 Tiempo de carga ≤ 1,5 s por cubierta [M]
- [ ] K-05 Prueba de estrés: entrar y salir 20 veces seguidas sin fuga [C]
- [ ] K-06 Verificar que no se rompa el streaming del mundo exterior al zarpar [M]

## L. Pasajeros NPC (M28 P20)

- [ ] L-01 Instanciar 6 pasajeros en cubierta 2 y 3 [M]
- [ ] L-02 Rutina breve: camarote → comedor → cubierta → camarote [C]
- [ ] L-03 Pasajeros con `CharacterBody3D` y colisión contra barandillas [M]
- [ ] L-04 Diálogo ambiental simple al interactuar (1 línea por NPC) [M]
- [ ] L-05 Los pasajeros desaparecen al desembarcar [S]
- [ ] L-06 Verificar que no bloqueen el paso del jugador [M]

## M. Economía y pasajes

- [ ] M-01 Crear `data/crucero/pasajes.json` con las 3 clases [S]
- [ ] M-02 Crear `data/crucero/camarotes.json` con los 6 tipos [S]
- [ ] M-03 Implementar `vender_pasaje(clase)` con validación de monedas (M38) [M]
- [ ] M-04 Descontar el precio y asignar camarote según disponibilidad [M]
- [ ] M-05 Bloquear la venta si no hay camarotes libres [M]
- [ ] M-06 Mostrar el precio en el HUD de la tienda [S]

## N. Audio y VFX

- [ ] N-01 Motor del crucero (`AudioStreamPlayer` en bucle) [S]
- [ ] N-02 Olas y ambiente de mar (M33/M51) [S]
- [ ] N-03 Silbato al zarpar y al llegar [S]
- [ ] N-04 Humo de las 2 chimeneas (`GPUParticles3D`) [M]
- [ ] N-05 Estela en el agua al navegar (M51) [M]
- [ ] N-06 Ambiente interior (música de comedor, murmullo) [M]

## O. UI / HUD

- [ ] O-01 Prompt "Embarcar" al acercarse al `Area3D` [S]
- [ ] O-02 Indicador de cubierta actual (1-4) [S]
- [ ] O-03 Indicador de destino y tiempo restante de viaje [M]
- [ ] O-04 Aviso de llegada al puerto [S]
- [ ] O-05 Menú de compra de pasaje en el puerto [M]
- [ ] O-06 Minimapa con el ícono del crucero en el mar [M]

## P. QA, rendimiento y cierre

- [ ] P-01 `tests/unit/test_crucero_manager.gd` con los 4 estados [C]
- [ ] P-02 `tests/integration/test_crucero_viaje.gd` (embarque → zarpe → llegada) [C]
- [ ] P-03 Probar el ciclo completo a pie: puerto → camarote → comedor → cubierta → zarpe [C]
- [ ] P-04 Medir frame time con el crucero a la vista (≤ 16,6 ms) [M]
- [ ] P-05 Medir draw calls del exterior (≤ 40) [M]
- [ ] P-06 Probar la caída al agua desde cada cubierta [M]
- [ ] P-07 Probar el viaje con clima de tormenta (M32) [M]
- [ ] P-08 Probar la recarga del juego a mitad de viaje [M]
- [ ] P-09 Verificar que ningún otro módulo cambió de comportamiento [M]
- [ ] P-10 QA visual final del fundador (no lo firma este agente: no tiene visión) [S]

## Q. Aventura a bordo (capa 3) — juegos y retos

- [ ] Q-01 Definir las 5 actividades en data/crucero/juegos_a_bordo.json [M]
- [ ] Q-02 Casino: mesa de cartas 1 (juego simple de 3 cartas) [C]
- [ ] Q-03 Casino: mesa de cartas 2 (variante de apuesta) [M]
- [ ] Q-04 Casino: ruleta con animación y premio (M38) [C]
- [ ] Q-05 Casino: límite de 3 partidas por día (M29) [S]
- [ ] Q-06 Torneo de cubierta: 6 triggers de control en cubiertas 1-2 [M]
- [ ] Q-07 Torneo: cronómetro con GameClock (M29) y ranking local [M]
- [ ] Q-08 Torneo: premio de 80 monedas + reputación [S]
- [ ] Q-09 Espectáculo: .tres de M21 con 2 resultados y recompensa [M]
- [ ] Q-10 Camarote misterioso: pista + cofre con ítem raro (M15) [M]
- [ ] Q-11 Vigía: catalejo en cubierta 4 y 3 objetos detectables [M]
- [ ] Q-12 Vigía: FSM de 7 estados tomando ishing_session.gd como plantilla [C]
- [ ] Q-13 Conectar las 5 actividades al EventManager de M74 (contrato de minijuego) [C]
- [ ] Q-14 Bloquear las actividades de exterior con clima severo (M32); casino sigue abierto [M]
- [ ] Q-15 Pausar y conservar el progreso al desembarcar [M]
- [ ] Q-16 Verificar que ninguna actividad use dinero real ni microtransacciones [S]
- [ ] Q-17 Probar las 5 actividades de principio a fin en una sola travesía [C]
- [ ] Q-18 Verificar que las actividades se puedan rechazar sin castigo [S]

---

---

**Totales:** 162 ítems · Completados: 18 · Pendientes: 144 · No resueltos: 0.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 05:25