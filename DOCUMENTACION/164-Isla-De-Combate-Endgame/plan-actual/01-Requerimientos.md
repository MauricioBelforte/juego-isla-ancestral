**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Modulo 164: Isla de Combate Endgame

## ID del Modulo
- **Codigo:** M164
- **Carpeta:** `DOCUMENTACION/164-Isla-De-Combate-Endgame/`
- **Dependencias:** M158 (Herramientas y Desbloqueo), M163 (Encantamientos), M22 (Historia Principal), M27 (Islas), M38 (Economia)
- **Relaciones:** M13 (Herramientas), M39 (Tiendas), M14 (Inventario), M11 (Personaje), M71 (Progresion), M72 (Logros)

## 1. Problema

El juego principal es cozy, sin combate. Sin embargo, algunos jugadores desean la posibilidad de luchar contra enemigos. Se necesita una isla final que ofrezca combate opcional, accesible solo para jugadores que hayan avanzado lo suficiente (con gemas). La isla debe mantener la filosofia cozy: sin game over, sin penalidades duras, pero con desafio significativo.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Isla accesible solo con gemas | El jugador necesita intercambiar herramientas/objetos por gemas para acceder |
| RF2 | Combate opcional | Nunca es obligatorio; el jugador puede ignorar la isla completamente |
| RF3 | Sin game over | Si el jugador "pierde", vuelve al pueblo sin penalidad |
| RF4 | Sin penalidades duras | No se pierden objetos, no hay muerte permanente |
| RF5 | Villanos con patrones de ataque | Enemigos con IA basica pero interesante |
| RF6 | Mobs basicos para farmear | Enemigos faciles que dan gemas y recursos |
| RF7 | Jefes con mecanicas unicas | Enemigos fuertes con patrones especiales |
| RF8 | Recompensas exclusivas | Objetos cosmeticos, herramientas unicas, titulos |
| RF9 | Gema como moneda de acceso | Cada zona de la isla requiere cierta cantidad de gemas |
| RF10 | Progresion dentro de la isla | El jugador avanza desbloqueando zonas con gemas |

## 3. Sistema de Gemas

| Fuente de Gemas | Cantidad | Frecuencia |
|-----------------|----------|------------|
| Intercambiar herramientas encantadas | 1-5 segun tier | Por intercambio |
| Derrotar mobs | 1-3 | Por combate |
| Derrotar jefes | 5-10 | Por jefe |
| Completar desafios | 3-7 | Por desafio |
| Comprar con dinero real (Steam) | 1-20 | Por paquete |

## 4. Zonas de la Isla

| Zona | Gemas requeridas | Contenido |
|------|------------------|-----------|
| Costa | 0 (acceso libre) | Mobs basicos, tienda |
| Bosque | 10 gemas | Mobs medianos, recursos |
| Montaña | 25 gemas | Mobs fuertes, jefe 1 |
| Templo | 50 gemas | Jefe final, recompensas exclusivas |

## 5. Criterios de Aceptacion

1. La isla es accesible solo con gemas suficientes
2. El combate es opcional y sin penalidades
3. Los enemigos tienen IA basica pero interesante
4. Las recompensas son exclusivas y no rompen el juego principal
5. El jugador puede ir y venir de la isla libremente
6. Checklist minimo 100 items verificables

## 6. Alcance

**Dentro del alcance:** isla de combate, sistema de gemas, enemigos, jefes, recompensas, tienda de la isla.

**Fuera del alcance:** sistema de combate base (si se crea modulo separado), sistema de herramientas (M13), encantamientos (M163), historia principal (M22).

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M158** — Herramientas | Tiers para acceso |
| **M163** — Encantamientos | Fuente de gemas |
| **M22** — Historia Principal | Contexto narrativo |
| **M27** — Islas | Estructura de islas |
| **M38** — Economia | Sistema de gemas |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M013** — Herramientas | Se intercambian por gemas |
| **M039** — Tiendas | Tienda de la isla |
| **M014** — Inventario | Guarda gemas y recompensas |
| **M011** — Personaje | Combate en isla |
| **M071** — Progresion | Hitos de combate |
| **M072** — Logros | Logros de combate |
