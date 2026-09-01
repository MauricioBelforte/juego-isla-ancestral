# Log 228: M25 Ruinas — ruina legible validada con vision

**Fecha:** 2026-08-29
**Hora:** 01:35
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se cerro la puerta V2 de M25 (estructura pequena y legible) con evidencia visual: la ruina chocavil construida sobre la altura REAL del terreno aparece completa y distinguible en la captura oficial. Se resolvio la causa raiz de que no se viera: la ruina quedaba ENTERRADA (losas a y fijo por debajo de la superficie de la isla denotada por el generador seed 42).

## Cambios
- generador_ruina.gd (RuinaChozavil): _buscar_altura(x,z) muestrea la superficie y construye sobre ella; se elimino la conexion a una senal inexistente (chunk_generated -> crash de debugger); placa Area3D con body_entered al jugador; puzzle M24 (placa->puerta) configurado.
- scripts/ruinas/preview_ruina.gd + scenes/ruina_preview.tscn: escena preview autocontenida (generador seed 42 + VoxelViewer + camara 45 grados + captura in-engine) para validar legibilidad sin depender del encuadre del spawn.
- main_island.gd: la ruina sigue conectada al arranque (ya con _buscar_altura).

## Verificacion
- Captura oficial cap_25_2026-08-29_01-32-18_ruina-legible-oficial.png: se ven los 3 muros de piedra (con vano de puerta en el oeste), la columna de madera y el piso interior, sobre la superficie de tierra y no enterrada.
- Compilacion limpia (check-only) de ambos scripts; la preview corre sin break en el run validado.

## Hallazgo reportado
- world_generator.gd:34 del modulo M09 lanza "Invalid call get_block_at in previously freed" al generar ciertos chunks (bug latente del generador). No bloquea la preview ni la isla visible, pero debe corregirse en M09.

## Archivos
- game/isla-ancestral/scripts/ruinas/generador_ruina.gd, preview_ruina.gd (+ .uid)
- game/isla-ancestral/scenes/ruina_preview.tscn (+ .uid)
- game/isla-ancestral/scripts/main_island.gd (ruina en _ready)
- Checklist/CHECKLIST-GLOBAL/ESTADO-PARALELO/guia 08 actualizados; cap_25_* oficial en capturas/25-Ruinas