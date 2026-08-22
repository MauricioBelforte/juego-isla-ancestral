**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 37: Museos y Colecciones

## ID del Módulo
- **Código:** M37 (CHECKLIST-GLOBAL.md: fila 37 — Museos y Colecciones)
- **Carpeta:** `DOCUMENTACION/37-Museos-Y-Colecciones/`
- **Dependencias:** M36 (Fauna — avistamientos), M34 (Pesca — peces), M25 (Ruinas — fósiles y piezas), M55 (Diario — registro de progreso)
- **Relaciones:** M29/M31 (reloj y calendario), M71 (logros), M39 (infraestructura — restauración del edificio), M69 (fast travel)
- **Stack técnico:** Godot 4.x (>= 4.4.1) + Voxel Tools (GDExtension) + GDScript

## 1. Problema

El jugador explora una isla ancestral donde avista fauna, pesca, excava fósiles y encuentra arte ancestral, pero no tiene ningún espacio que valore esos hallazgos. Sin un museo, los descubrimientos pierden su sentido de logro, el mundo se siente vacío de recompensas a largo plazo y no existe un motor de curiosidad ("¿qué falta por descubrir?"). Se necesita un sistema de museo y colecciones que convierta cada hallazgo en una pieza visible, durable y gratificante, alineado con la filosofía cozy (sin presión, sin competencia, progreso pausado y voluntario).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Museo visitable | Edificio en Aurora con salas navegables, vitrinas y un curador NPC que recibe donaciones |
| RF2 | Donación de fauna | El jugador dona especies avistadas en M36 (dioramas con el modelo avistado) |
| RF3 | Donación de peces | El jugador dona peces capturados en M34 (tanques/acuarios con nado) |
| RF4 | Donación de fósiles/ruinas | El jugador dona fósiles y piezas excavadas en M25 (pedestales y montajes) |
| RF5 | Donación de arte | El jugador dona obras de arte ancestral encontradas (marcos y paredes de exhibición) |
| RF6 | Exposiciones completables | Cada sala es una exposición con lista de piezas; al completarla se desbloquea la recompensa |
| RF7 | Recompensa por colección completa | Recompensa única por exposición y trofeo por museo 100% (sin duplicados) |
| RF8 | Registro en M55 Diario | Cada donación, colección completada y recompensa se registra en el diario |
| RF9 | Progreso visible | Porcentaje de completado por exposición y global del museo, visible en UI y carteles |
| RF10 | Inspección de piezas | Interactuar con una vitrina muestra nombre, procedencia y curiosidad de la pieza |
| RF11 | Donación segura | Validación de propiedad, duplicados y sala correcta; consumo del inventario solo tras éxito |
| RF12 | Persistencia | Estado de colección, vitrinas pobladas y recompensas otorgadas se guardan con la partida |

## 3. Requisitos No Funcionales

- **Cozy:** cero presión temporal; el museo no caduca y las donaciones se pueden hacer en cualquier momento. Mensajes de agradecimiento cálidos del curador.
- **Rendimiento:** vitrinas instanciadas solo para piezas registradas; iluminación estática; acuarios con nado ligero; carga de sala < 250 ms (Profiler).
- **Desacoplamiento:** los sistemas de colección no dependen de la capa de UI; se comunican por señales (Museum, CollectionRegistry, DonationService como servicios).
- **Determinismo y guardado:** el estado del registro se reconstruye idéntico al cargar partida; guardado atómico sin corrupción.
- **Accesibilidad:** textos legibles, navegación por mando, feedback visual y de audio para cada acción.
- **Idioma y estilo:** descripciones de piezas en español, tono cálido, coherente con la mitología de la isla.

## 4. Criterios de Aceptación

1. El museo es visitable y tiene como mínimo 4 salas (fauna, peces, fósiles, arte) con vitrinas.
2. Se pueden donar piezas procedentes de M36, M34 y M25 mas arte, con validación completa (duplicado, sala, propiedad).
3. Una donación duplicada o invalida es rechazada con feedback claro y sin consumir inventario.
4. Una vitrina ocupada nunca se sobrescribe; cada pieza tiene un hueco unico.
5. Al completar una exposicion, la recompensa se otorga una sola vez aunque se cargue la partida multiples veces.
6. Cada donacion, exposicion completada y recompensa queda registrada en M55 Diario.
7. El progreso por exposicion y global se muestra correctamente y coincide con las vitrinas visibles.
8. El estado completo se preserva entre guardado y carga de partida.
9. El modulo pasa el plan de testings (donacion feliz, duplicados, vitrina ocupada, recompensa unica, carga/descarga).
---

## 4. EXPANSIONES COZY (2026-08-22)

### 4.1 Museo del Pueblo

Inspirado en Animal Crossing y Tsuki's Odyssey, el jugador puede donar items al museo del pueblo para crear exhibiciones.

#### Salas del Museo

| Sala | Contenido | Recompensa al completar |
|------|-----------|------------------------|
| Sala de Peces | Todos los peces del juego | Fuente decorativa |
| Sala de Minerales | Todos los minerales | Lámpara de cristal |
| Sala de Plantas | Todas las hierbas y flores | Maceta gigante |
| Sala de Ruinas | Piezas arqueológicas | Glifo iluminado |
| Sala de Historia | Reliquias ancestrales | Mapa del tesoro |
| Sala del Jugador | Favoritos del jugador | Placa con su nombre |

#### Reglas del Museo

- El jugador dona 1 ítem de cada tipo (no se pierde, se exhibe)
- Cada ítem donado se muestra en una vitrina 3D
- Completar una sala da un bonuses cosmético
- El museo tiene horario (abierto 8:00-20:00)
- El curador (NPC) comenta cada nueva donación
- No hay obligación de donar todo (cozy = sin presión)
- Los ítems donados no se pueden recuperar (pero el jugador tiene copia)

### 4.2 Colecciones del Jugador

| Colección | Fuente | Recompensa |
|-----------|--------|------------|
| Peces legendarios | Pesca especial | Caña de oro |
| Minerales raros | Minería profunda | Pico de cristal |
| Flores exóticas | Exploración | Maceta encantada |
| Glifos ancestrales | Ruinas | Lupa mejorada |
| Recetas secretas | NPCs favoritos | Cocina especial |
| Fotos del mundo | Fotografía (M56) | Marco dorado |
| Muebles raros | Exploración/puzzles | Sala secreta de la casa |

### 4.3 Tienda de Museo

- El curador vende reproducciones de piezas donadas
- Las reproducciones son más baratas que las originales
- Son solo decorativas (no funcionales)
- Útiles para decorar la casa sin tener que encontrar la pieza original
- El curador trae 1 pieza nueva cada semana

### 4.4 Integración con M18 (Casas)

- El jugador puede colocar réplicas de piezas del museo en su casa
- Las piezas del museo tienen interacción (mirar, leer descripción)
- Si el jugador completa una sala, desbloquea un estilo de decoración
- Los NPCs visitantes reaccionan a las piezas del museo en la casa

### 4.5 Integración con M158 (Herramientas)

- Algunas piezas del museo solo se obtienen con herramientas específicas
- Ejemplo: glifos ancestrales necesitan T3 para extraerlos
- Esto motiva la progresión de herramientas
- Pero no hay pieza OBLIGATORIA para completar la historia
