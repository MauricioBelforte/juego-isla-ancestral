**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 01-Requerimientos.md — Módulo 11: Personaje del Jugador

## ID del Módulo
- **Código:** M11 (plan maestro: sección 10 — Personaje del Jugador)
- **Carpeta:** `DOCUMENTACION/11-Personaje-Del-Jugador/`
- **Dependencias:** M07 (Arquitectura, ServiceLocator), M155 (Vestimenta), M156 (Terrenos). Dependen de este: M12 (Cámara), M13 (Herramientas), M14 (Inventario), M19 (NPC)

## 1. Problema

El jugador necesita un **cuerpo jugable** con movimiento cómodo (cozy), físico coherente con el mundo voxel de 1 m y estados claros (caminar, correr, saltar, nadar, interactuar) que soporten el loop diario y la exploración sin fricción. El jugador debe poder **elegir su apariencia** al inicio y **personalizar su vestimenta** durante el juego, con accesorios que afecten el movimiento según el terreno.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Movimiento terrestre | Caminar, correr, saltar (altura 1.2 m = 2 bloques) |
| RF2 | Movimiento acuático | Nadar en superficie y buceo limitado por aire |
| RF3 | Colisiones con voxel | Hitbox 0.6×1.8 m vs bloque de 1 m (GDD altura de personas 1.8 m) |
| RF4 | Estados del personaje | idle, run, sprint, jump, swim, dive, interact, sleep, craft |
| RF5 | Interacción | Prompts contextuales con tecla única (F) sobre IInteractable |
| RF6 | Energía/Terreno | Sistema de desgaste que regula el sprint (no castiga) |
| RF7 | Recogida de luz | Destellos de luz (Ø×Ø) recogidos al pasar con magnetismo suave |
| RF8 | Animaciones/sonido | Base jugable con animaciones placeholder y pasos |
| RF9 | Selección de personaje | Elegir entre 4-6 personajes con distinto diseño visual al iniciar partida |
| RF10 | Vestimenta funcional | Prendas que dan bonos según terreno (botas para barro, patines para pavimento, etc.) |
| RF11 | Modificadores de terreno | Velocidad y comodidad varían según tipo de superficie y equipamiento |

## 3. Requisitos No Funcionales

- **Cozy:** sin haters; el movimiento nunca castiga al jugador (sin daño por caída > 3 bloques; fatiga progresiva).
- Cámara tercera persona fija tras el hombro (M12 la define; el personaje expone el pivot).
- Física suave: no velocidad de sprint infinita; stamina regen libre.
- Punto de data: presets de movimiento (data/player/player_motion.tres).
- Selección de personaje: todos los personajes tienen las mismas mecánicas; la diferencia es **puramente visual** (coherencia cozy = sin ventajas/desventajas por elección).
- Vestimenta: las bonificaciones son suaves (+5-15% velocidad en terreno adecuado); nunca bloqueantes.

## 4. Criterios de Aceptación

1. Los 30 puntos del plan maestro (sección 10) resueltos.
2. Modelo de estados completo con transiciones y permisos.
3. Hitbox, velocidades y físicas documentadas como constantes consumibles.
4. Sin contradicción con la filosofía cozy (cero daño por caída, fatiga suave).
5. Sistema de selección de personaje con 4-6 opciones visuales documentado.
6. Integración con M155 (Vestimenta) y M156 (Terrenos) definida.
---

## 6. SISTEMA DE RUTINA DIARIA PASIVA (estilo Tsuki's Odyssey)

**Filosofía:** El jugador puede vivir la isla como un juego passive/daily. El que solo quiera pescar y decorar su casa puede hacerlo. El que quiera explorar también. Nada es obligatorio.

### 6.1 Energía y Ciclo Diario

#### Sistema de Energía

| Parámetro | Valor | Nota |
|-----------|-------|------|
| Energía máxima | 100 puntos | Sube con nivel de amistad (+5 por nivel) |
| Costo caminar | 0 | Caminar no gasta energía |
| Costo correr | 1/minuto | Suave, regen rápido |
| Costo herramienta | 2-8 por uso | Depende de herramienta |
| Costo interactuar | 0 | Hablar, mirar, abrir |
| Regeneración | 1/minuto | Siempre, incluso en movimiento |
| Regeneración dormir | 100% completo | Al dormir en cama |
| Regeneración descanso | +30% | Sentarse en silla/banco |

**Regla cozy:** La energía NUNCA llega a cero por caminar o correr. Solo se agota por uso intensivo de herramientas. Si se agota, el personaje se sienta automáticamente a descansar (no hay "game over").

#### Ciclo del Día (reloj del juego)

| Hora | Fase | Actividad del personaje (modo pasivo) |
|------|------|---------------------------------------|
| 06:00 | Amanecer | Despertar, ventana se ilumina |
| 06:15 | Mañana temprana | Salir de casa, paseo por el pueblo |
| 06:30 | Desayuno | Sentarse a comer (si hay comida en casa) |
| 07:00 | Trabajo mañana | Ir al trabajo (si tiene profesión asignada) |
| 12:00 | Mediodía | Almuerzo, descanso en banco |
| 13:00 | Tarde | Pesca, exploración, o visita a NPCs |
| 17:00 | Atardecer | Volver al pueblo, visitar tiendas |
| 19:00 | Noche | Regresar a casa, cenar |
| 20:00 | Noche tardía | Leer, descansar, o visitar vecinos |
| 22:00 | Dormir | Acostarse, cerrar día |

### 6.2 Modos de Juego

#### Modo Activo (default)
- El jugador controla al personaje 100%
- Interactúa manualmente con todo
- Experiencia completa de gameplay

#### Modo Semi-Pasivo
- El jugador camina al punto de interés
- La acción se ejecuta automáticamente al llegar
- Ejemplo: camina al río → la pesca ocurre sola → recoge el resultado
- Útil para quien quiere jugar sin estrés pero con control

#### Modo Pasivo (idle)
- El personaje ejecuta su rutina automáticamente
- El jugador observa o hace otras cosas
- Las actividades generan recompensas REALES
- Se puede interrumpir en cualquier momento (tocar cualquier tecla)
- NO resuelve puzzles ni combate
- NO recoge tesoros de exploración profunda
- Solo hace actividades seguras y básicas

### 6.3 Actividades del Modo Pasivo

| Actividad | Requisito | Recompensa | Frecuencia |
|-----------|-----------|------------|------------|
| Pescar automáticamente | Caña equipada | Pescados (calidad baja, 40% calidad normal) | 1×/30 min juego |
| Buscar jarrones | Ninguno | Monedas (5-10 c/u) | 3×/día |
| Cortar árboles pequeños | Hacha T1+ | Madera (1-3 piezas) | 2×/día |
| Recoger hierbas | Ninguno | Hierbas comunes | 2×/día |
| Pasear por el pueblo | Ninguno | Amistad +1 con 1 NPC al azar | 1×/día |
| Visitar la tienda | Tienda abierta | Venta automática de items | 1×/día |
| Regar plantas | Regadera | Plantas crecen +1 etapa | 1×/día |
| Alimentar animales | Comida en inventario | Producción de animales | 1×/día |

### 6.4 Progresión Offline (Away Progress)

Inspirado en Tsuki's Odyssey, el juego avanza cuando el jugador no está:

| Tiempo ausente | Progreso | Límite |
|----------------|----------|--------|
| 1 hora | 1 ciclo de生产cción | 10 items |
| 4 horas | 4 ciclos | 40 items |
| 8 horas (dormir) | 8 ciclos | 80 items |
| 24 horas | 12 ciclos (tope) | 120 items |

**Reglas del progreso offline:**
- Solo aplica para producción pasiva (cultivos, animales, minería básica)
- NO avanza misiones ni eventos
- NO avanza amistad (solo se mantiene, no baja)
- El jugador ve un resumen al volver: "Mientras estabas ausente: +15 monedas, +3 maderas, +2 peces"
- No hay penalización por no jugar (cozy = sin presión)

### 6.5 Sistema de Profesiones del Pueblo

Cada personaje puede tener una profesión que genera ingresos pasivos:

| Profesión | Requisito | Ingreso pasivo | Desbloquea |
|-----------|-----------|----------------|------------|
| Pescador | Hacha T1 | 20 monedas/día | Pesca idle mejorada |
| Carpintero | Hacha T2 | 30 monedas/día | Muebles básicos |
| Herrero | Hacha T3 | 50 monedas/día | Herramientas T2 |
| Jardinero | Hacha T1 | 15 monedas/día | Plantas raras |
| Cocinero | Ninguno | 25 monedas/día | Recetas especiales |
| Mercader | Ninguno | 40 monedas/día | Descuentos en tiendas |

**Reglas de profesión:**
- Se elige 1 profesión al inicio (se puede cambiar después)
- La profesión afecta qué genera el personaje en modo pasivo
- No hay penalización por no tener profesión
- La profesión NO bloquea otras actividades

### 6.6 Anti-Frustración (Principios Cozy)

Basado en principios de diseño de juegos cosy (Tsuki, Animal Crossing, Stardew Valley):

| Principio | Implementación |
|-----------|---------------|
| Sin "game over" | Si la energía llega a 0, el personaje se sienta a descansar自动 |
| Sin penalización por no jugar | El mundo no se degrada, los NPCs no se enojan |
| Sin presión temporal | Los eventos se repiten, nada es "único una vez" |
| Sin combate obligatorio | Todo el contenido accesible sin pelear |
| Sin muerte | El personaje nunca muere, solo se cansa |
| Sin pérdida de items | Los items no se pierden al fallar una acción |
| Sin bloqueo de progreso | Siempre hay algo que hacer en cualquier estado |
| Sin exigencia de skill | Las mecánicas son accesibles para todos |

### 6.7 Interacción con Otros Módulos

| Módulo | Integración |
|--------|-------------|
| M18 (Casas) | El modo pasivo regresa a casa al anochecer |
| M19 (NPCs) | Los NPCs visitan al jugador en modo pasivo |
| M29 (Tiempo) | La rutina respeta el calendario del juego |
| M34 (Pesca) | Pesca idle genera pescados de calidad baja |
| M38 (Economía) | Los ingresos pasivos se suman al balance |
| M156 (Terrenos) | El personaje busca terreno seguro en modo pasivo |
