**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 03-Diseno.md — Módulo 69: Fast Travel

## 1. Arquitectura

```
M28 (Viajes) ──► FastTravelManager (autoload)
M29 (Tiempo) ──► validación ciclo día/noche
M31 (Ciclo Día/Noche) ──► validación franjas horarias
M157 (Transporte) ──► JourneyInstance (experiencia de viaje)
                          │
                  ──► UI FastTravelMenu (CanvasLayer)
                          │
                  ──► FastTravelEffect (node2D, animación de transición)
                          │
                          ▼
                  JourneyManager (eventos + misterios durante viaje)
                          │
                          ▼
                  World Persistence (guardado último punto)
```

## 2. Flujo de operación (expandido con M157)

1. **Jugador accede** al menú de fast travel (atajo M o mapa contextual)
2. **Sistema verifica** estado: ¿en combate? ¿en diálogo? ¿durante evento especial?
   - Si negativo → continuar; si positivo → mostrar warning y bloquear
3. **Sistema consulta** puntos de viaje desbloqueados y ordenados por distancia/acceso
4. **Jugador selecciona** destino de la lista
5. **Sistema muestra** medios de transporte disponibles para esa ruta (M157):
   - Barco (si hay ruta marítima)
   - Tren (si hay línea de tren)
   - Avión (si hay aeródromo)
   - Carreta (si hay camino terrestre)
   - A pie (siempre disponible, más lento)
6. **Jugador elige** medio de transporte → se muestra costo y duración estimada
7. **Sistema valida** restricciones de costo (recursos o tiempo)
8. **Si pasa:** Iniciar JourneyInstance (M157) → el jugador vive el viaje
9. **Durante el viaje:** eventos aleatorios, misterios, NPCs, recursos
10. **Al llegar:** restaurar estado del jugador en el destino

## 3. Mapa de puntos de viaje

| Categoría | Descripción | Desbloqueo | Transporte disponible |
|---|---|---|---|
| Pueblo | Centros principales | Tras completar área inicial | Tren, carreta, a pie |
| Santuario | Lugares sagrados | Tras visitar primero a pie | A pie, barco (costa) |
| Isla | Áreas aisladas | Tras explorar la isla | Barco, avión |
| Bosque | Áreas bióticas | Descubrir 3+ puntos bioma | Carreta, a pie |
| Montaña | Áreas de altitud | Alcanzar cumbres | A pie, tren (si hay línea) |
| Ciudad | Centros urbanos late-game | Progresión de historia | Tren, avión, barco |

## 4. Regla de costo

- **Costo en recursos:** 2-5 unidades del recurso más abundante del bioma actual
- **Costo en tiempo:** 15-30 minutos de tiempo de juego simulado
- **Mínimo:** 1 uso gratis cada 2 horas de juego real (cooldown real)
- **Costo varía por transporte:** barco más caro pero con más eventos; a pie gratis pero lento

## 5. Sistema de eventos durante viajes

### 5.1 Tipos de evento

| Tipo | Descripción | Frecuencia |
|------|-------------|------------|
| Hallazgo | Recurso o item raro encontrado durante el viaje | 30% |
| NPC | Encuentro con NPC viajero que da pista o regalo | 25% |
| Misterio | Puzle o enigma que resolver durante el trayecto | 20% |
| Clima | Cambio climático que afecta el viaje (tormenta, niebla) | 15% |
| Narrativo | Fragmento de historia o lore del mundo | 10% |

### 5.2 Sistema de misterios por ruta

- Cada ruta entre dos puntos tiene 3-5 misterios predefinidos
- Los misterios se eligen aleatoriamente al iniciar el viaje
- Resolver un misterio otorga recompensa (recurso, pista de historia, desbloqueo)
- Los misterios no se repiten en el mismo viaje (rotación)
- Algunos misterios solo aparecen en ciertos horarios (M29/M31)

## 6. QA

- Test M114: menú de fast travel accesible desde mapa y atajo de teclado
- Test de restricciones: fast travel bloqueado durante combate y diálogos críticos
- Test de costo: verificación de descuento de recursos y cooldowns
- Test de transición: animación suave sin "jump" visual ni pausas prolongadas
- Test de integración: fast travel respetando ciclo día/noche (M29/M31)
- Test de viaje: JourneyInstance se inicia correctamente con M157
- Test de eventos: al menos 1 evento ocurre durante viajes de 5+ minutos
- Test de misterios: misterios no se repiten en viajes consecutivos


## Specs Fast Travel (Beam 708)

### Iconos de apoyo visual al nombre del destino
- Spec: iconos de apoyo visual al nombre del destino. Coherente with M69 (fast travel) and M53 (UI).

### Alt text para thumbnails de destino
- Spec: alt text para thumbnails de destino. Coherente with M69 (fast travel) and M58 (accesibilidad).

### Modo cronologico para historiales
- Spec: modo cronologico para historiales. Coherente with M69 (fast travel) and M55 (diario).

### Filtros por tipo de lugar (bioma, servicios)
- Spec: filtros por tipo de lugar (bioma, servicios). Coherente with M69 (fast travel) and M54 (mapa).

### Sin dependencia solo de color para estado
- Spec: sin dependencia solo de color para estado. Coherente with M69 (fast travel) and M58 (accesibilidad).


## Specs Fast Travel (Beam 709)

### M110: debug menu con listado de anchors
- Spec: M110: debug menu con listado de anchors. Coherente with M69 (fast travel) and M110 (debug menu).

### M32: anulacion del portal en clima extremo
- Spec: M32: anulacion del portal en clima extremo. Coherente with M69 (fast travel) and M32 (clima).

### M91: respetar volumen de feedback de viaje
- Spec: M91: respetar volumen de feedback de viaje. Coherente with M69 (fast travel) and M91 (audio).

### Test de recuperacion: archivo corrupto -> resync
- Spec: test de recuperacion: archivo corrupto -> resync. Coherente with M69 (fast travel) and M59 (guardado).

### Test de bateria: consumo por viaje a larga distancia
- Spec: test de bateria: consumo por viaje a larga distancia. Coherente with M69 (fast travel) and M61 (rendimiento).


## Specs Fast Travel (Beam 710)

### Test multidioma: busqueda en distintos alfabetos
- Spec: test multidioma: busqueda en distintos alfabetos. Coherente with M69 (fast travel) and M86 (localizacion).

### Test de acceso: atajos disponibles sin teclado
- Spec: test de acceso: atajos disponibles sin teclado. Coherente with M69 (fast travel) and M58 (accesibilidad).

### Test de localizacion: posicionamiento visual ajustado
- Spec: test de localizacion: posicionamiento visual ajustado. Coherente with M69 (fast travel) and M53 (UI).

### Test de fallback: 3 fallos seguidos -> modo seguro
- Spec: test de fallback: 3 fallos seguidos -> modo seguro. Coherente with M69 (fast travel) and M66 (anti-softlock).

### Specs items degradados T210 (2026-10-26, Reflection-Beam-1.0)
- **L104 (test fast travel bloqueado durante combate):** NO existe tal test. Grep combate.*bloque|bloque.*combate|en_combate en scripts/ y tests/ → 0 hits en M69 (el único "bloqueado" es en_dialogo en transport_manager.gd:131, que es M68). El diseño sí lo pide (03-Diseno §6 "Test de restricciones"), pero el artefacto no existe.
- **L105 (test fast travel bloqueado durante diálogos críticos):** idem. bloqueado en_dialogo existe en transport_manager.gd:131 (M68), pero no hay test M69 que lo verifique sobre fast travel.
- **L154 (lectura por screen reader de menú):** 0 hits de screen_reader|screen reader|verbal description en scripts/. Claim de accesibilidad (M53/M62) sin artefacto.
- **L168 (M104 evento analytics fast_travel_used):** grep fast_travel_used en scripts/, tests/ y data/ → 0 hits. El evento genérico sí existe: analytics_director.gd define la constante EV_FEATURE_USADA y test_analytics.gd:82 la usa con {"feature": "fast_travel"}. Lo que no hay es emisión desde runtime (grep de EV_FEATURE_USADA fuera de tests: solo la definición en analytics_director.gd). El [?] se mantiene, pero la nota original inducía a error al decir "el evento no existe".
