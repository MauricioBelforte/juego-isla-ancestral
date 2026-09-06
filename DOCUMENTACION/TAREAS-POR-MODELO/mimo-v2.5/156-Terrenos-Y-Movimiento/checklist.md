**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Módulo:** 156-Terrenos-Y-Movimiento
**Estado:** 🟢 Disponible (10/302 completados)
**Prioridad:** #3
**Fortaleza:** Arquitectura de sistemas complejos, debug

# M156 — Terrenos y Movimiento: Checklist MiMo V2.5

## Reserva actual
- **Estado:** 🔵 Reservado
- **Fecha:** 2026-09-02
- **Log:** pendiente

## Pendientes (106 items — seleccionados por impacto)

### Diseño del sistema (13)
- [ ] T-156-001: Definir estructura de carpetas del módulo [S]
- [ ] T-156-002: Definir nombres de archivos del módulo [S]
- [ ] T-156-003: Documentar dependencias con M11 [S]
- [ ] T-156-004: Documentar dependencias con M155 [S]
- [ ] T-156-005: Definir interfaz pública del sistema [M]
- [ ] T-156-006: Definir señales del sistema [M]
- [ ] T-156-007: Definir eventos de comunicación entre módulos [M]
- [ ] T-156-008: Crear diagrama de componentes [S]
- [ ] T-156-009: Crear diagrama de secuencia [S]
- [ ] T-156-010: Definir orden de ejecución por frame [M]
- [ ] T-156-011: Documentar flujo principal de ejecución [M]
- [ ] T-156-012: Documentar flujo de audio [S]
- [ ] T-156-013: Documentar flujo de efectos visuales [S]
- [ ] T-156-014: Definir constantes del sistema [S]
- [ ] T-156-015: Documentar edge cases conocidos [M]

### Modificadores de terreno (17)
- [ ] T-156-016: Documentar parámetros export [S]
- [ ] T-156-017: Verificar modificador de césped = 1.0 [S]
- [ ] T-156-018: Verificar modificador de barro = 0.6 [S]
- [ ] T-156-019: Verificar modificador de pavimento = 1.0 [S]
- [ ] T-156-020: Verificar modificador de arena = 0.75 [S]
- [ ] T-156-021: Verificar modificador de agua = 0.7 [S]
- [ ] T-156-022: Verificar modificador de nieve = 0.8 [S]
- [ ] T-156-023: Verificar modificador de rocas = 0.85 [S]
- [ ] T-156-024: Caso base: 5.0 * 1.0 * (1 + 0.0) = 5.0 [S]
- [ ] T-156-025: Caso todoterreno: 5.0 * 0.6 * (1 + 0.1) = 3.3 [S]
- [ ] T-156-026: Validar que resultado nunca es negativo [S]
- [ ] T-156-027: Validar que resultado no excede 2x base [S]
- [ ] T-156-028: Crear tests unitarios para cálculos [M]
- [ ] T-156-029: Documentar interfaz estática [S]
- [ ] T-156-030: Crear archivo .gd correspondiente [S]
- [ ] T-156-031: Heredar de StaticBody3D [S]
- [ ] T-156-032: Documentar uso por bloques de terreno [S]

### PlayerMovementData (8)
- [ ] T-156-033: Asignar layer correcta según terreno [M]
- [ ] T-156-034: Agregar referencia a EquipmentSystem (M155) [M]
- [ ] T-156-035: Almacenar _current_effective_speed [S]
- [ ] T-156-036: Usar _current_effective_speed en movimiento [M]
- [ ] T-156-037: No romper movimiento existente de M11 [M]
- [ ] T-156-038: Mantener compatibilidad si no hay M156 [M]
- [ ] T-156-039: Agregar null checks para referencias [S]
- [ ] T-156-040: Retornar 0.0 si no hay bonificación [S]

### Bonus system (6)
- [ ] T-156-041: Retornar valor positivo si hay equipo adecuado [S]
- [ ] T-156-042: Limitar bonificación máxima a 0.5 [S]
- [ ] T-156-043: Iterar por slots equipados [M]
- [ ] T-156-044: Sumar bonificaciones de múltiples items [M]
- [ ] T-156-045: Documentar contrato de interfaz [S]
- [ ] T-156-046: Verificar compatibilidad con sistema de equipación [M]

### Huellas y partículas (12)
- [ ] T-156-047: Crear sistema de huellas por terreno [M]
- [ ] T-156-048: Crear escena huella_ceped.tscn [S]
- [ ] T-156-049: Crear sistema de partículas por terreno [M]
- [ ] T-156-050: Crear particulas_ceped.gd [S]
- [ ] T-156-051: Instanciar huellas en posición del jugador [M]
- [ ] T-156-052: Limitar número máximo de huellas activas [M]
- [ ] T-156-053: Seleccionar sonido aleatorio del array [S]
- [ ] T-156-054: Crear samples audio_ceped_step_1.wav [S]
- [ ] T-156-055: Crear samples audio_ceped_step_2.wav [S]
- [ ] T-156-056: Sincronizar con evento de animación [M]
- [ ] T-156-057: Evitar reproducción doble [S]
- [ ] T-156-058: Verificar que el jugador NO tiene layers de terreno [S]

### UI de terreno (8)
- [ ] T-156-059: Agregar TextureRect para icono de terreno [S]
- [ ] T-156-060: Agregar Label para nombre de terreno [S]
- [ ] T-156-061: Actualizar icono según terreno [S]
- [ ] T-156-062: Actualizar texto según terreno [S]
- [ ] T-156-063: Actualizar barra de progreso [S]
- [ ] T-156-064: Posicionar UI en esquina inferior [S]
- [ ] T-156-065: Animar transiciones de UI [M]

### Tests (7)
- [ ] T-156-066: Test: resultado nunca negativo [S]
- [ ] T-156-067: Test: resultado no excede 2x base [S]
- [ ] T-156-068: Test: detección inicial es -1 [S]
- [ ] T-156-069: Test: debounce evita updates rápidos [M]
- [ ] T-156-070: Ejecutar suite de tests completa [M]

### Documentación (6)
- [ ] T-156-071: Crear 01-Requerimientos.md [M]
- [ ] T-156-072: Crear 02-Análisis.md [M]
- [ ] T-156-073: Crear 03-Diseno.md [C]
- [ ] T-156-074: Crear 04-Codigo.md [M]
- [ ] T-156-075: Crear 05-Checklist.md [M]
- [ ] T-156-076: Documentar arquitectura del sistema [M]

### Rendimiento (6)
- [ ] T-156-077: Limitar número máximo de huellas activas [M]
- [ ] T-156-078: Usar Object pooling para partículas [M]
- [ ] T-156-079: Verificar que audio no causa lag [S]
- [ ] T-156-080: Medir tiempo de ejecución por detección [S]
- [ ] T-156-081: Documentar impacto en rendimiento [S]

### Compatibilidad (5)
- [ ] T-156-082: Mantener backwards compatibility [M]
- [ ] T-156-083: Null checks en todas las referencias [M]
- [ ] T-156-084: Graceful degradation sin errores [M]
- [ ] T-156-085: Asignar referencia de EquipmentSystem en M11 [M]

### Validación visual (12)
- [ ] T-156-086: Verificar movimiento normal en césped [S]
- [ ] T-156-087: Verificar movimiento lento en barro [S]
- [ ] T-156-088: Verificar movimiento normal en pavimento [S]
- [ ] T-156-089: Verificar movimiento lento en arena [S]
- [ ] T-156-090: Verificar movimiento lento en agua [S]
- [ ] T-156-091: Verificar movimiento medio en nieve [S]
- [ ] T-156-092: Verificar movimiento medio en rocas [S]
- [ ] T-156-093: Verificar botas todoterreno mejoran todos [S]
- [ ] T-156-094: Verificar sonidos diferentes por terreno [S]
- [ ] T-156-095: Verificar huellas diferentes por terreno [S]
- [ ] T-156-096: Verificar partículas diferentes por terreno [S]
- [ ] T-156-097: Verificar indicador de UI actualiza [S]
- [ ] T-156-098: Verificar que jugador nunca se bloquea [C]
- [ ] T-156-099: Verificar FPS estable a 60 [M]
- [ ] T-156-100: Verificar sin errores en consola [S]

### Ajustes finos (6)
- [ ] T-156-101: Ajustar volúmenes de audio por terreno [M]
- [ ] T-156-102: Ajustar variación de pitch por terreno [S]
- [ ] T-156-103: Ajustar intensidad de huellas por terreno [M]
- [ ] T-156-104: Verificar documentación completa [S]
- [ ] T-156-105: Verificar tests completos [M]
- [ ] T-156-106: Crear log de cierre [S]

## Completados esta sesión
_(ninguno aún)_

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02
**Estado:** Inicio de backlog

### Lo que voy a hacer
- Diseñar la arquitectura del sistema (T-156-001 a T-156-015)
- Implementar los modificadores de terreno (T-156-016 a T-156-032)
- Integrar con M11 (jugador) y M155 (equipación)

### Lo que NO puedo hacer todavía
- Huellas y partículas requieren assets de audio y shaders
- UI de terreno depende de M53 (UI-UX)
- Tests de rendimiento requieren escena poblada

### Recomendaciones para el próximo agente
- Empezar por el diseño del sistema (T-156-001 a T-156-015)
- Los modificadores de terreno son la base — hacerlos primero
- Integrar con M11 una vez que los modificadores funcionen
