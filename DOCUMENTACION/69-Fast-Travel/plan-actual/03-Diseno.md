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
