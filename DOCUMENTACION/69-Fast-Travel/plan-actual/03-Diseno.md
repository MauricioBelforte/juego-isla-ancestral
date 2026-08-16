**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 03-Diseno.md — Módulo 69: Fast Travel

## 1. Arquitectura

```
M28 (Viajes) ──► FastTravelManager (autoload)
M29 (Tiempo) ──► validación ciclo día/noche
M31 (Ciclo Día/Noche) ──► validación franjas horarias
                       │
                       ▼
                       FastTravelService (singleton)
                       │
               ──► UI FastTravelMenu (CanvasLayer)
                       │
               ──► FastTravelEffect (node2D, animación de transición)
                       │
                       ▼
                       World Persistence (guardado último punto)
```

## 2. Flujo de operación

1. **Jugador accede** al menú de fast travel (atajo M o mapa contextual)
2. **Sistema verifica** estado: ¿en combate? ¿en diálogo? ¿durante evento especial?
   - Si negativo → continuar; si positivo → mostrar warning y bloquear
3. **Sistema consulta** puntos de viaje desbloqueados y ordenados por distancia/acceso
4. **Jugador selecciona** destino de la lista
5. **Sistema valida** restricciones de costo (recursos o tiempo)
6. **Si pasa:** Mostrar animación de transición → Cargar destino → Restaurar estado del jugador
7. **Si falla:** Mostrar mensaje explicativo (costo insuficiente, estado bloqueado, etc.)

## 3. Mapa de puntos de viaje

| Categoría | Descripción | Desbloqueo |
|---|---|---|
| Pueblo | Centros principales del mundo | Desbloqueado tras completar área inicial |
| Santuario | Lugares sagrados/dioses (M17) | Desbloqueado tras visitar primero a pie |
| Isla | Áreas de juego aisladas | Desbloqueado tras explorar la isla |
| Bosque | Áreas bióticas específicas | Desbloqueado al descubrir 3+ puntos en ese bioma |
| Montaña | Áreas de altitud elevada | Desbloqueado al alcanzar cumbres específicas |

## 4. Regla de costo

- **Costo en recursos:** 2-5 unidades del recurso más abundante del bioma actual
- **Costo en tiempo:** 15-30 minutos de tiempo de juego simulado
- **Mínimo:** 1 uso gratis cada 2 horas de juego real (cooldown real)

## 5. QA

- Test M114: menú de fast travel accesible desde mapa y atajo de teclado
- Test de restricciones: fast travel bloqueado durante combate y diálogos críticos
- Test de costo: verificación de descuento de recursos y cooldowns
- Test de transición: animación suave sin "jump" visual ni pausas prolongadas
- Test de integración: fast travel respetando ciclo día/noche (M29/M31)
- Test de mapa: todos los puntos de viaje llevan a destinos válidos