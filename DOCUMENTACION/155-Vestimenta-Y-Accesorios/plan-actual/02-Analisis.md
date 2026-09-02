**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# 02-Analisis.md — Módulo 155: Vestimenta y Accesorios

## 1. Análisis del dominio

### 1.1 Tipos de equipamiento

| Slot | Ejemplos | Función |
|------|----------|---------|
| Cabeza | Sombrero de pescador, casco de explorador, gorro de lana | Cosmético + bonos menores (visibilidad, resistencia climática) |
| Cuerpo | Camisa de lana, chaleco de explorador, capa impermeable | Cosmético + bonos de resistencia a clima/terreno |
| Pies | Botas de barro, patines, bicicleta, sandalias, botas de agua | **Funcional principal**: modifica velocidad por terreno |
| Accesorio | Mochila, linterna, brújula, binoculares | Funcional secundario: utilidades de exploración |

### 1.2 Tabla de bonos por terreno y equipamiento de pies

| Terreno | Sin equip. | Botas barro | Patines | Bicicleta | Botas agua | Sandalias |
|---------|-----------|-------------|---------|-----------|------------|-----------|
| Césped | 100% | 100% | 90% | 120% | 100% | 105% |
| Barro | 60% | **95%** | 40% | 50% | 70% | 55% |
| Pavimento | 100% | 100% | **130%** | **140%** | 100% | 100% |
| Arena | 70% | 80% | 30% | 60% | 75% | **90%** |
| Agua (poco profundo) | 50% | 60% | — | — | **80%** | 40% |
| Nieve | 75% | 85% | 50% | 70% | 75% | 60% |
| Rocas | 90% | 90% | 80% | — | 90% | 85% |

### 1.3 Análisis de alternativas

| Alternativa | Pros | Contras | Decisión |
|-------------|------|---------|----------|
| Solo cosmético (sin stats) | Simple, balanceado | Falta profundidad de gameplay | ❌ Descartado |
| Stats complejos (ATK, DEF) | RPG clásico | Rompe cozy, demasiado sistema | ❌ Descartado |
| Bonos suaves por terreno | Profundidad sutil, cozy | Requiere más diseño | ✅ Elegido |
| Prendas como consumibles | Economía activa | Frustrante, Management pesado | ❌ Descartado |

## 2. Decisiones clave

1. **4 slots fijos:** cabeza, cuerpo, pies, accesorio. Simple, intuitivo, cukup para variedad sin complejidad excesiva.

2. **Bonos suaves (+5-15%):** nunca bloquean movimiento. Usar patines en barro es lento pero posible. Cozy = sin frustración.

3. **Pies es el slot principal:** es donde están las botas, patines, bicicleta. Los otros slots son mayormente cosméticos con bonos menores.

4. **Desbloqueo orgánico:** las prendas se obtienen explorando, comprando en tiendas de NPC, completando misiones, o en eventos. No hay loot box ni gacha.

5. **Visual sobre el personaje:** cada prenda se superpone al modelo voxel del personaje (M11). Las prendas son meshes voxel simplificados.

## 3. Integraciones

- **M11 (Personaje):** el personaje expone los 4 slots y aplica los modificadores de velocidad.
- **M14 (Inventario):** las prendas se almacenan como ítems en el inventario.
- **M156 (Terrenos):** el sistema de terrenos consulta el equipamiento del jugador para calcular modificadores.
- **M59 (Guardado):** el equipo se persiste en GameState.
- **M65 (Assets):** las prendas finales son meshes de terceros.
- **M39 (Tiendas):** las prendas se compran en tiendas de NPC.
- **M22/M23 (Misiones):** algunas prendas se obtienen como recompensa.
