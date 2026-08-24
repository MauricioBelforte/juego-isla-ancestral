**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 01-Requerimientos.md — Modulo 157: Medios de Transporte

## Problema

El juego necesita un sistema de transporte que permita al jugador desplazarse entre ubicaciones distantes de la isla (y potencialmente fuera de ella). En lugar de simples pantallas de carga, el viaje debe ser una **experiencia jugable por sí misma**: un recorrido con eventos aleatorios, encuentros con NPCs, misterios por resolver y decisiones que afectan la narrativa. Cada tipo de transporte (barco, tren, avión, carreta, a pie) debe ofrecer una experiencia única y diferenciada que recompense la exploración y la curiosidad del jugador.

## Requisitos Funcionales

### RF-01: Gestión Centralizada de Transporte
- **TransportManager** como singleton que gestione todos los medios de transporte disponibles.
- Registrar y desregistrar medios de transporte en tiempo de ejecución.
- Consultar disponibilidad de cada medio según ubicación del jugador y estado del mundo.
- Escalar prioridad de transporte según distancia y tipo de terreno.

### RF-02: Instancia de Viaje (JourneyInstance)
- Crear una instancia de viaje cuando el jugador inicia un desplazamiento.
- Cada instancia contiene: transporte origen, transporte destino, duración estimada, eventos programados, estado actual.
- La instancia persiste durante todo el viaje y se destruye al completar.
- Permitir cancelar el viaje antes de completar (con penalización según medio).

### RF-03: Sistema de Eventos Aleatorios
- Cada tipo de transporte tiene una tabla de eventos aleatorios propios.
- Los eventos se disparan en intervalos aleatorios durante el viaje.
- Los eventos pueden ser: combate, diálogo, puzzle, hallazgo de recurso, emergencia, misterio.
- La frecuencia y tipo de evento depende del bioma/ubicación recorrida.

### RF-04: Tipos de Transporte Diferenciados
- **Barco:** Viaje costero/oceánico. Eventos de tormenta, ballenas, naufragios, islas secretas.
- **Tren:** Viaje terrestre por vías. Eventos de asaltos, pasajeros misteriosos, túneles, estaciones abandonadas.
- **Avión:** Viaje aéreo corto. Eventos de Falla de motor, avistamientos, tierra de nadie, aterrizajes forzados.
- **Carreta:** Viaje terrestre lento. Eventos de fauna, bandidos, caravanas, mercados ambulantes.
- **A pie:** Viaje libre. Eventos de exploración, descubrimientos, riesgos ambientales, atajos secretos.

### RF-05: Sistema de Misterios por Viaje
- Cada viaje puede contener un **misterio narrativo** activo.
- Los misterios se desbloquean al encontrar pistas durante eventos aleatorios.
- Resolver un misterio otorga recompensa significativa (recurso raro, desbloqueo de área, NPC aliado).
- Los misterios tienen múltiples pasos que se completan durante el viaje.

### RF-06: Interfaz de Usuario del Viaje
- Panel de información del viaje: transporte, destino, progreso, tiempo estimado.
- Panel de eventos: lista de eventos ocurridos y activos.
- Panel de inventario rápido durante el viaje.
- Botones de interacción contextual: investigar, ignorar, huir, usar objeto.
- Indicador de progreso visual (barra de avance del recorrido).

### RF-07: Integración con Sistemas Existentes
- **M69 (Inventario):** Acceso a inventario durante viaje, consumo de recursos, obtención de items.
- **M22 (NPCs):** NPCs durante eventos, diálogos, combate con NPCs hostiles.
- **M24 (Misiones):** Misiones activas pueden afectar eventos del viaje.
- **M19 (Combate):** Sistema de combate integrado en eventos de combate del viaje.
- **M29 (Economía):** Comercio con NPCs durante viaje, costos de transporte, recompensas económicas.

### RF-08: Progresión y Desbloqueo
- Algunos medios de transporte están bloqueados al inicio y se desbloquean con progresión.
- Nuevos medios de transporte desbloquean nuevas rutas y eventos.
- Completar misterios puede desbloquear medios de transporte especiales.

### RF-09: Persistencia de Estado
- El estado del viaje se guarda si el jugador sale del juego.
- Los eventos completados quedan registrados para no repetirse.
- Los misterios resueltos persisten en el save data.
- Los medios de transporte desbloqueados persisten.

### RF-10: Costos y Economía del Viaje
- Cada medio de transporte tiene un costo en moneda del juego.
- Costo variable según distancia y destino.
- Posibilidad de viajar gratis en situaciones especiales (misiones, NPCs aliados).
- Los costos se deducen del inventario del jugador antes de iniciar el viaje.

## Requisitos No Funcionales

### RNF-01: Rendimiento
- El sistema de viaje no debe causar drops de frame mayores a 5ms.
- Los eventos aleatorios se generarán bajo demanda, no pre-cargados.
- La instanciation de eventos debe ser pooling-friendly.

### RNF-02: Extensibilidad
- Nuevo tipo de transporte se agrega implementando una interfaz `ITransportType`.
- Nuevos eventos se agregan mediante configuración (ScriptableObject o JSON).
- El sistema debe soportar futuro multijugador (viajes compartidos).

### RNF-03: Accesibilidad
- Toda información de viaje debe ser comunicada por audio y texto.
- Los eventos deben tener alternativas para jugadores con distintas habilidades.
- La interfaz debe ser usable con teclado, mouse y gamepad.

### RNF-04: Localización
- Todos los textos de eventos, diálogos y misterios deben ser localizables.
- Usar sistema de localización de Godot (ResourceFile o similar).

### RNF-05: Testing
- Cobertura mínima del 80% en tests unitarios del TransportManager.
- Tests de integración para el flujo completo de viaje.
- Tests de regresión para cada tipo de transporte.

## Criterios de Aceptación

1. **CA-01:** El jugador puede iniciar un viaje con cualquiera de los 5 medios de transporte disponibles.
2. **CA-02:** Durante el viaje ocurren al menos 2 eventos aleatorios por viaje promedio.
3. **CA-03:** Cada tipo de transporte tiene al menos 8 eventos únicos en su tabla.
4. **CA-04:** Los misterios se resuelven encontrando pistas en eventos del viaje.
5. **CA-05:** La interfaz muestra progreso, eventos activos y opciones de interacción.
6. **CA-06:** El viaje se puede cancelar con penalización antes de completar.
7. **CA-07:** El estado del viaje persiste correctamente al guardar/cargar partida.
8. **CA-08:** No hay errores de runtime durante un viaje completo de cada tipo.
9. **CA-09:** Los costos de viaje se deducen correctamente del inventario.
10. **CA-10:** El sistema es extensible: se puede agregar un nuevo tipo de transporte sin modificar código existente.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | Transporte con NPCs |
| **M022** — Historia Principal | Transporte narrativo |
| **M024** — Templos y Puzzles | Transporte y templos |
| **M069** — Fast Travel | Transporte y fast travel |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M022** — Historia Principal | Depende de este módulo |
| **M024** — Templos y Puzzles | Depende de este módulo |
| **M069** — Fast Travel | Depende de este módulo |
| **M162** — Diálogos Contextuales de NPCs | Comparten dependencias (M019, M022) |

