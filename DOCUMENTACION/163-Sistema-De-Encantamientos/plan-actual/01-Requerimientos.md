**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Modulo 163: Sistema de Encantamientos

## ID del Modulo
- **Codigo:** M163
- **Carpeta:** `DOCUMENTACION/163-Sistema-De-Encantamientos/`
- **Dependencias:** M13 (Herramientas), M158 (Herramientas y Desbloqueo de Zonas), M159 (Catalogo de Objetos)
- **Relaciones:** M39 (Tiendas), M38 (Economia), M14 (Inventario), M11 (Personaje)

## 1. Problema

El jugador necesita una capa de progresion lateral que le permita mejorar sus herramientas de forma permanente sin depender solo del tier material. Los encantamientos dan habilidades unicas por tier que abren nuevas posibilidades de juego (intercambios especiales, bonus economicos, mejoras en extraccion). El sistema debe ser accesible pero requerir esfuerzo (conseguir incienso, encontrar al chaman).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | 4 encantamientos por tier | Cada tier de herramienta tiene un encantamiento unico |
| RF2 | Encantamiento permanente | Una vez encantada, la herramienta conserva el encantamiento para siempre |
| RF3 | Cualquier tier se puede encantar | No hay restriccion de tier minimo para encantar |
| RF4 | Chamán del monte | NPC especial en Isla Raiz que encanta herramientas a cambio de incienso |
| RF5 | Incienso como recurso | Recurso renovable que se obtiene por cultivo o eventos |
| RF6 | Encantamientos se pueden vender | Distintas tiendas compran distintos encantamientos a precios premium |
| RF7 | Habilidades unicas por tier | Cada encantamiento da una habilidad diferente y util |
| RF8 | Visual diferenciado | Herramientas encantadas tienen brillo/particulas distintivas |

## 3. Habilidades por Tier

| Tier encantado | Nombre | Habilidad |
|----------------|--------|-----------|
| Cobre Encantado | Cobre Ancestral | Se intercambia por un objeto especial con un NPC + bonus adicional por definir |
| Hierro Encantado | Hierro Prospero | Al romper rocas/minerales, da el doble de monedas |
| Oro Encantado | Oro Brillante | Aumenta el precio de venta en tiendas +50% |
| Cristal Encantado | Cristal de Caverna | Funciona en cuevas con bonus de extraccion |

## 4. Criterios de Aceptacion

1. El jugador puede encantar cualquier herramienta que posea
2. El chaman requiere incienso (recurso renovable, no limitante)
3. Los encantamientos son permanentes y visuales
4. Las tiendas compran herramientas encantadas a precio premium
5. El sistema es opcional: ningun contenido requiere encantamiento obligatorio
6. Checklist minimo 100 items verificables

## 5. Alcance

**Dentro del alcance:** sistema de encantamientos, chamán del monte, incienso, habilidades por tier, venta de encantamientos.

**Fuera del alcance:** sistema base de herramientas (M13), tiers de material (M158), economia general (M38), inventario (M14).

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M013** — Herramientas | Sistema base de herramientas |
| **M158** — Herramientas y Desbloqueo | Tiers de material y profesiones |
| **M159** — Catalogo de Objetos | Definicion de items encantados |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M039** — Tiendas | Compra herramientas encantadas |
| **M038** — Economia | Precios premium por encantamiento |
| **M014** — Inventario | Almacena herramientas encantadas |
| **M011** — Personaje | Equipa herramientas encantadas |
