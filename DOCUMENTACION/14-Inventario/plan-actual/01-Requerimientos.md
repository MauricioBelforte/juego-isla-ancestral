**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo Code

# 01-Requerimientos.md — Módulo 14: Inventario

## ID del Módulo
- **Código:** M14 (plan maestro: sección 13 — Inventario)
- **Carpeta:** `DOCUMENTACION/14-Inventario/`
- **Dependencias:** M13 (herramientas), M15 (recursos), M16 (crafting), M53 (UI/UX). Relaciones: M17 (construcción: cofres colocables), M18 (casas: almacenamiento doméstico), M19/M20 (regalos y amistad), M21 (diálogos de regalo), M37 (museos y colecciones), M39 (tiendas y venta), M55 (diario del jugador), M59 (guardado), M87 (localización), M92 (tutorial)
- **Delegable desde:** hoy (diseño completo; implementación tras M13/M15 para recolección y M53 para UI base)

## 1. Problema

En un cozy game sin combate, el jugador pasa la mayor parte del tiempo recolectando, plantando, pescando y crafteando. Un inventario mal diseñado (peso arbitrario, slots escasos, transferencias engorrosas, pérdida de ítems por llenura) destruye la sensación cálida que define al género. Se necesita un sistema de inventario que nunca frustre: que siempre se pueda recoger algo, que el orden y los filtros ayuden en vez de estorbar, y que la gestión entre el bolsillo del jugador y el almacenamiento de la casa sea rápida y agradable, a la manera de Animal Crossing.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Contenedores múltiples | Bolsillo del jugador (grid 4x6), mochila ampliable, almacenamiento doméstico en casa (M18), cofres colocables (M17), almacén del pueblo compartido |
| RF2 | Stacks y límites coherentes | Stack máximo por ítem: 99 para recursos base (M15), 10 para ítems medianos (semillas especiales, pescados grandes), 1 para herramientas (M13), muebles y objetos clave |
| RF3 | Ausencia de peso | Sin sistema de peso: el límite es por cantidad de slots y tamaño de stack. Regla cozy: nunca bloquear la recolección (ver RF8) |
| RF4 | Categorías, orden y filtros | 9 categorías: herramientas, recursos, comida y semillas, peces y animales, materiales ancestrales, regalos, espóras de luz, muebles y decoración, objetos de misión. Ordenamiento por categoría, rareza, nombre o fecha de obtención; filtro por búsqueda de texto y por favoritos |
| RF5 | Favoritos y tooltip | Slots favoritos fijados con pin (no se mueven al ordenar). Tooltip al pasar el cursor con nombre, rareza, descripción, precio base (M39) y recetas en las que interviene (M16) |
| RF6 | Hotbar y selección rápida | Hotbar de 6 slots siempre visible; asignación manual por arrastre o atajos; ciclo con teclas 1-6 y rueda del mouse; equipamiento de herramientas (M13) desde el hotbar |
| RF7 | Transferencias ágiles | Transferencia rápida (todo el stack), transferencia múltiple (cantidad elegida) y separación de stacks entre bolsillo y cualquier contenedor, con un solo botón o combinación de teclas |
| RF8 | Feedback de inventario lleno (anti-frustración) | Aviso temprano al 80% de capacidad; al llenarse, el ítem recolectado queda en el mundo y se muestra una notificación amable con sugerencia de llevar el botín al almacenamiento; nunca se pierde un ítem por llenura |
| RF9 | Descarte seguro | Sistema de descarte con confirmación obligatoria para objetos importantes (herramientas, regalos, espóras de luz, objetos de misión); descarte simple para recursos comunes |
| RF10 | Integración con el mundo | Recepción directa de la recolección (M13/M15), consumo de materiales por crafting (M16), salida de compras (M39), donación a colecciones (M37), entrega de regalos (M19/M20) y recepción de paquetes de NPCs |
| RF11 | Espóras de luz | Categoría e ítem especial de la isla vinculado a las deidades: apilable hasta 999, con animación de recogida propia, contador global visible en el diario (M55) y bloqueo de descarte accidental |
| RF12 | Persistencia completa | Todos los contenedores serializables y restaurables con validación de integridad (M59); configuración de hotbar y preferencias de orden guardadas |

## 3. Requisitos No Funcionales

- **Cozy:** cero frustración; mensajes amables y sugerencias proactivas; el inventario lleno nunca es punitivo.
- **Rendimiento (M61):** abrir el inventario ≤ 5 ms; mover u ordenar 100 ítems ≤ 8 ms; cero instancias de escena por ítem (los ítems son datos, no nodos); atlas de iconos para minimizar draw calls.
- **Desacople:** toda la lógica de contenedores vive en servicios (autoload y RefCounted); la capa UI (M53) solo refleja estado y emite intenciones.
- **Accesibilidad (M58):** tooltips legibles con alto contraste, tamaño de fuente ajustable, atajos reconfigurables y soporte completo de gamepad.
- **Identidad estable de ítems:** cada ItemData tiene un `id` único e inmutable (requisito de guardado M59 y localización M87).
- **Sin combate:** el inventario no tiene estadísticas de daño ni peso de armaduras; las herramientas solo mejoran eficiencia (M13).

## 4. Criterios de Aceptación

1. Los 24 puntos de la sección 13 del plan maestro resueltos y documentados.
2. API de contenedores estable (agregar, remover, mover, ordenar, separar, transferir) con contrato firmado.
3. Flujos completos diseñados: recolección → bolsillo, bolsillo → casa, casa → crafting, compra → bolsillo, regalo NPC → bolsillo/bandeja.
4. Reglas de anti-frustración por llenura y descarte seguro definidas (RF8/RF9) sin ambigüedad.
5. Delegable para implementación tras M13/M15 y M53.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M011** — Personaje del Jugador | Capacidad y slots del jugador |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M015** — Recursos | Recursos |
| **M016** — Crafting | Crafting |
| **M017** — Construcción | Construcción |
| **M053** — UI/UX | Usado por ui/ux |
| **M059** — Guardado | Guardado |
| **M137** — Prototipo | Prototipo |
| **M155** — Vestimenta y Accesorios | Usado por vestimenta y accesorios |
| **M159** — Catálogo de Objetos | Catálogo de objetos |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M015** — Recursos | Este módulo lo necesita |
| **M016** — Crafting | Este módulo lo necesita |
| **M017** — Construcción | Este módulo lo necesita |
| **M053** — UI/UX | Este módulo lo necesita |
| **M059** — Guardado | Este módulo lo necesita |
| **M137** — Prototipo | Este módulo lo necesita |
| **M155** — Vestimenta y Accesorios | Este módulo lo necesita |

