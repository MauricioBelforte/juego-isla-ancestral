# 06-Plan-Testings — M66 Anti-Softlock

**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-05

## Objetivo
Validar que el sistema anti-softlock previene estados imposibles de recuperar.

## Casos de prueba

### PT-01: Recuperación tras cierre inesperado
- Setup: Juego en estado normal, save activo
- Acción: Simular crash (forzar terminación)
- Expectativa: Jugador aparece en punto seguro al reiniciar
- Criterio éxito: Sin crash, posición válida

### PT-02: Recuperación tras terreno extremo
- Setup: Jugador en borde del mapa
- Acción: Forzar caída más allá del límite
- Expectativa: Teletransporte a zona segura
- Criterio éxito: Jugador no queda fuera del mundo

### PT-03: Cofre lleno sin bloqueo
- Setup: Inventario lleno
- Acción: Intentar recoger objeto
- Expectativa: Sistema notifica y evita softlock
- Criterio éxito: No se pierde progreso

### PT-04: Doble recuperación consecutiva
- Setup: Estado softlock activado
- Acción: Ejecutar recuperación dos veces
- Expectativa: Segunda llamada idempotente
- Criterio éxito: Sin crash, mismo resultado

### PT-05: Rendimiento crítico
- Setup: Múltiples softlocks simultáneos
- Acción: Activar todos a la vez
- Expectativa: Tiempo < 100ms
- Criterio éxito: Sin GC spikes

## Criterio de éxito
Suite completa pasa sin fallos, 0 crashes, 0 softlocks confirmados.