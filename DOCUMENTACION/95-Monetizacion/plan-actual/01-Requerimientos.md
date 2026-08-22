**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 95: Monetización

## 1. Problema
"Isla Ancestral" es un juego premium de 60-100 h sin microtransacciones previstas. La monetización debe definirse de forma completa y **justa**: modelo comercial (premium), precio base por plataforma, impuestos, política de reembolsos, bundles, descuentos, contenido Deluxe, Edición Coleccionista y DLCs futuros (expansiones, soundtrack, merchandise), **sin pay-to-win, sin loot boxes innecesarias y sin fragmentar la historia principal**.

## 2. Objetivo del módulo
Definir la **estrategia de monetización completa** del juego y su documentación ejecutable (precios, ediciones, DLC roadmap, reembolsos, legal fiscal) coherente con los principios del proyecto (M94 sin FOMO, M152 salud del jugador, M93 diversión sostenida) y con la preparación de plataformas (M149).

## 3. Alcance (derivado del plan maestro: sección 94 "MONETIZACIÓN")
1. **Modelo comercial** — premium (compra única) con DLC opcionales; sin F2P/GaaS.
2. **Premium confirmado** — compra única; sin suscripciones forzadas.
3. **Free-to-play si corresponde** — NO aplica; se documenta la decisión y sus motivos.
4. **DLC si corresponde** — DLC de expansión (nueva isla), DLC cosmético de bajo impacto.
5. **Expansiones** — roadmap pos-lanzamiento: expansión estacional/temática.
6. **Soundtrack** — OST vendible (M41) en plataforma y físico.
7. **Merchandise** — artículos físicos opcionales post-lanzamiento.
8. **Cosméticos** — decoración de la isla/casa (M17/M65) sin tocar poder.
9. **Evitar pay-to-win** — 0 ítems de pago que den ventaja en progresión.
10. **Evitar loot boxes** — 0 cajas de azar; todo contenido se compra directo.
11. **Definir precio base** — precio de venta estándar (con fundamento).
12. **Definir precio por plataforma** — ajuste por plataforma/región con política de precios.
13. **Definir impuestos** — IVA/regionales por tienda; neto al equipo.
14. **Definir política de reembolsos** — política de cada plataforma + extra propia.
15. **Definir bundles** — packs de ediciones iniciales.
16. **Definir descuentos** — política de rebajas (primer descuento, mínimo).
17. **Definir contenido Deluxe** — edición con extras cosméticos y OST.
18. **Definir Edición Coleccionista** — física con arte, mapa, póster.
19. **Evitar fragmentar historia** — la historia principal (6 sellos + actos) completa en el juego base.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Documento de modelo comercial: premium, sin F2P, con justificación y datos de mercado |
| RF2 | Tabla de precios: base, por plataforma y por región (con ajustes y topes) |
| RF3 | Tabla de impuestos por tienda/región y neto esperado por venta |
| RF4 | Política de reembolsos por plataforma + política propia documentada |
| RF5 | Catálogo de ediciones: Standard, Deluxe, Coleccionista (contenido y precio de cada una) |
| RF6 | Roadmap de DLC: 2 DLC planificados (expansión + cosmético) sin fragmentar la historia |
| RF7 | Política de descuentos: primer descuento post-lanzamiento, mínimo y frecuencia |
| RF8 | Política de bundles: packs iniciales y de DLC |
| RF9 | Regla anti-P2W y anti-lootbox: cláusula formal en el documento |
| RF10 | Plan de merchandise/OST con canales y viabilidad |

## 5. Criterios de aceptación (DoD del módulo)
1. Modelo premium confirmado con datos de mercado (3 juegos de referencia).
2. Precios definidos por plataforma/región con impuestos calculados.
3. Política de reembolsos escrita y publicable.
4. Ediciones (Standard/Deluxe/Coleccionista) con contenido y precio.
5. DLC roadmap sin tocar la historia principal (RF9 auditada).
6. 0 ítems pay-to-win y 0 loot boxes verificables por scan.
7. Documentación plan-actual actualizada y firmada.

## 6. Restricciones
- **Aplican:** M38 (economía — los precios internos de ítems no se ligan a dinero real), M94 (sin FOMO: sin compras por presión), M149 (plataformas — política de precios por tienda), M147 (biblia — el canon no se vende por partes), M152 (ética/UX), M22 (la historia completa está en el juego base).
- Prohibido: pay-to-win, loot boxes, rebajas que engañen (precio falso), contenido de historia fragmentado en DLC.
- Los precios internos del juego (oro/ítems M38) nunca se vinculan a divisa real (sin microtransacciones).

## 7. Dependencias
- M38 (Economía ✅ — definición de precio interno), M94 (Retención sin FOMO ✅), M149 (Plataformas/Marketing ✅), M152 (Salud/Ética ✅), M41 (OST para soundtrack), M17/M65 (cosméticos de construcción), M143/M144 (lanzamiento/post-lanzamiento para ejecutar roadmap).

## 8. Entregables del módulo
1. `95-Monetizacion/plan-actual/` con el documento de estrategia completo.
2. Tablas de precios, impuestos y reembolsos listas para M149/M143.
3. Roadmap de DLC y ediciones.
4. Cláusulas anti-P2W/anti-lootbox adoptadas formalmente.
---

## 9. EXPANSIONES DEL MODULO 158 (2026-08-22)

### 9.1 Compra de Monedas por Steam

El juego permite comprar monedas del juego con dinero real a traves de Steam IAP. Esta es la unica forma de gastar dinero real dentro del juego.

### 9.2 Paquetes de Monedas

| Paquete | Monedas | Precio USD | Precio ARS (aprox) |
|---------|---------|------------|---------------------|
| Pequeno | 500 | .99 | ~150 ARS |
| Mediano | 2000 | .99 | ~450 ARS |
| Grande | 5000 | .99 | ~750 ARS |

### 9.3 Reglas Premium

- Monedas premium son IDENTICAS a monedas normales (misma moneda monedas_aurora)
- Premium NO compra herramientas directamente
- El jugador SIEMPRE debe ir a las islas y hablar con profesionales
- Premium solo acelera la obtencion de monedas, no el recorrido
- No hay limite de compra
- No hay loot boxes ni cajas de azar
- No hay contenido exclusivo premium (solo monedas)

### 9.4 Anti-Pay-to-Win

- Las monedas premium compran las mismas monedas que se obtienen jugando
- No hay items exclusivos premium
- No hay ventajas competitivas (juego single-player)
- El jugador que no paga puede completar todo el juego
- Premium es una OPCION para quienes quieran avanzar mas rapido

### 9.5 Integracion con M158 (Herramientas)

- El jugador premium puede comprar monedas para forjar herramientas mas rapido
- Pero SIEMPRE debe ir a la isla correspondiente y hablar con el profesional
- No puede comprar herramientas directamente en una tienda
- El recorrido del mapa es obligatorio para todos los jugadores
