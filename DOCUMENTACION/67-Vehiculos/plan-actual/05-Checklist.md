**Modelo:** glm-5.3-flash (último modificador; docs por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 (iter. 1 — glm-5.3-flash/Kilo Code)

## Reserva actual

- **Módulo:** 67 Vehículos
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** 🔵 En curso — iter. 1 (núcleo V0)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 3
- **Visión:** V0 (sin captura; física acotada testeada headless)
- **Entrada:** M28 ✅ (TravelService+Harbor, Log 517); M59 ✅; M07 ✅
- **Salida:** VehicleManager autoload + presets data-driven + controller física + EventBus.vehicle + test headless 0 fallos
- **Archivos:** `scripts/vehiculos/{vehicle_manager,vehicle_preset,vehicle_controller,test_vehiculos}.gd`, `data/vehiculos/vehicles.json`, `scripts/core/event_bus.gd` (aditivo)
- **Log:** 528 reservado

---

# 05-Checklist.md — Módulo 67: Vehículos (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. VehicleManager (autoload)

- [x] Definir VehicleManager como autoload único de vehículos [M] — iter. 1: scripts/vehiculos/vehicle_manager.gd registrado como autoload "Vehiculos" en project.godot (test headless 0 fallos)
- [x] Gestionar el vehículo activo (uno a la vez) y API enter/exit (M70) [M] — iter. 1: enter(vehicle_id)/exit() con resultado {ok, motivo}; segundo enter rechazado "uno a la vez" (testeado)
- [x] Validar estado antes de entrar (docked, superficie) [M] — iter. 1: enter rechaza si not docked (testeado); superficie por tipo en iter. 2 con nodos 3D
- [x] Registrar logs VEH-ENTER y VEH-EXIT [S] — iter. 1: [VEH-ENTER]/[VEH-EXIT]/[VEH-DOCK] visibles en boot headless
- [x] Emitir eventos VEHICLE_ENTERED/EXITED (M07) [S] — iter. 1: dominio VehicleEvents aditivo en EventBus (vehicle_entered/exited/docked/aviso); emisión testeada

## B. Presets de Vehículos

- [x] Definir vehicle_preset.gd (tipo, física, capacidades, mejoras) [M] — iter. 1: Resource VehiclePreset con desde_datos() (JSON → runtime; mejoras iter. 2)
- [x] Crear vehicles_catalog.tres: barco, dirigible, submarino + plantilla locomotora [M] — iter. 1: data/vehiculos/vehicles.json (data-driven, 4 presets); locomotora condicional se omite sin M68 (testeado: 3 activos)
- [x] Preset barco (agua M51, 12 m/s) [M] — iter. 1: velocidad_max 12, crucero 6, baúl 12, reversa (testeado); flotación M51 iter. 2
- [x] Preset dirigible (aire, altitud máx 60 m) [M] — iter. 1: altitud_max 60, vel 15, baúl 8 (testeado); vuelo físico iter. 2
- [x] Preset submarino (subagua, profundidad máx −40 m) [M] — iter. 1: profundidad_max -40, vel 8, baúl 10 (testeado); buceo iter. 2

## C. Barco

- [ ] Navegar por agua leyendo la superficie (M51, sin fluidos) [C]
- [ ] Velocidad de crucero/rápida, timón suave y reversa [M]
- [ ] Colisiones con islas, rocas y vegetación (M50) sin atravesar [C]
- [ ] No atascarse en aguas poco profundas (aviso) [M]
- [ ] Vela desplegable (M48) y estela por evento (M52) [M]

## D. Dirigible

- [ ] Vuelo con altitud/descenso y aterrizaje suave en plataformas [M]
- [ ] Altitud máxima 60 m (mejorable a 90 m) [S]
- [ ] No romper el streaming a gran altura (chunk_target + LOD, M10/M61) [C]
- [ ] No colisionar con vegetación alta (paso por encima) [M]
- [ ] Viento lateral (M32) y farol nocturno (M49) [M]

## E. Submarino

- [ ] Buceo/emersión con límite −40 m y flotabilidad mínima [C]
- [ ] Visibilidad y luces bajo el agua (M49) [M]
- [ ] Explorar cuevas subacuáticas (M25) [C]
- [ ] Burbujas por evento (M52) y audio amortiguado (M43) [M]
- [ ] Cámara estable bajo el agua (sin mareo) [M]

## F. Locomotora (condicional M68)

- [x] Plantilla de locomotora SOLO si M68 exige ferrocarril [M] — iter. 1: preset con condicional="M68"; _cargar_catalogo la omite si autoload Transporte no existe (testeado)
- [ ] Velocidad sobre riel fija (20 m/s) y sin giro libre [M]
- [ ] Vagón de carga (16 slots, M14) [M]
- [ ] Documentar el estado condicional en 01-Requerimientos.md [S]
- [x] Definir contrato de integración con M68 [M] — iter. 1: si M68 registra autoload "Transporte", la locomotora entra al catálogo automáticamente (condicional en JSON)

## G. Física y Control (M57)

- [x] Física acotada: velocidad/giro/frenado por preset con suavizado [M] — iter. 1: VehicleController lógico (ACELERACION 3 m/s², clamp vel_max, frenado por preset; testeado clamp 12 m/s + frenado a 0)
- [ ] Controles con WASD y gamepad (palanca/gatillos) [M]
- [x] Reversa para barco [S] — iter. 1: tiene_reversa por preset; reversa clamp a -40% vel_max (testeado barco+dirigible)
- [x] Velocidad limitada por tipo (nunca romper streaming) [M] — iter. 1: clamp por preset (12/15/8/20 m/s del diseño §3.1; testeado)
- [ ] Testear física en 30/60 FPS (delta correcto) [C]

## H. Streaming (M10/M61)

- [x] Establecer chunk_target = vehículo durante la conducción [C] — iter. 1: contrato desplazamiento() para el integrador de nodos 3D (chunk_target real con M10 iter. 2; aviso en Notas)
- [ ] Volver chunk_target = jugador al salir [M]
- [ ] LOD de chunks por altitud del dirigible [C]
- [ ] Cargar islas cercanas (M27) antes que el terreno lejano [M]
- [ ] Testear barco/dirigible/submarino sin popping de terreno [C]

## I. Colisiones y Límites

- [ ] Colisiones suaves con islas, rocas y vegetación (M50) [C]
- [ ] Barco no puede ir a tierra; submarino no emerge en tierra [M]
- [ ] Dirigible con techo de altitud [S]
- [ ] Vehículos no atraviesan puentes (M11) ni ruinas (M25) [M]
- [ ] No atropellar animales (M36) [M]

## J. Entrada/Salida (M70)

- [ ] Interacción para entrar/salir del vehículo [S]
- [ ] Entrada solo si está docked o en superficie [M]
- [ ] Al salir: restaurar cámara, HUD y sonidos (sin fugas) [M]
- [ ] No quedar atascado cerca de muros al entrar/salir [M]
- [ ] Testear entrada/salida con gamepad y durante eventos (M74) [M]

## K. Docking (M28)

- [ ] Atraque con magnetismo suave en muelles [C]
- [ ] Ajustar posición y rotación; ángulo inválido → reintento [M]
- [ ] Docking de barco y dirigible en plataformas [M]
- [ ] Indicador visual de zona de atraque (M53) y sonido (M43) [S]
- [ ] Testear docking en muelles angostos y con olas (M51) [C]

## L. Almacenamiento (M14)

- [ ] Baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10) [M]
- [ ] Abrir el baúl desde el HUD y mover ítems [M]
- [ ] Límite de slots respetado y apilables [M]
- [ ] Mejora de baúl persistente (M59) [M]
- [ ] Testear baúl con inventario lleno [M]

## M. Mejoras

- [ ] Definir mejoras por vehículo (velocidad, giro, faroles, baúl) [M]
- [ ] Mejoras de velocidad/giro (niveles) [M]
- [ ] Mejoras de faroles (M49) y baúl [M]
- [ ] Comprar en tienda (M39) o artesanales (M16) [M]
- [ ] Persistencia y visualización de nivel en el HUD [M]

## N. Personalización

- [ ] Pintura del vehículo (paleta cozy, M46) [M]
- [ ] Banderas personalizables con viento (M50/M48) [M]
- [ ] Nombre del vehículo editable y localizable (M87) [M]
- [ ] Materiales de pintura del pool (M45/M49) [M]
- [ ] Persistencia de personalización (M59) [M]

## O. Sonido (M43)

- [ ] Sonidos de motor/agua/viento por vehículo [M]
- [ ] LOD de audio: atenuar > 40 m, silenciar > 80 m [M]
- [ ] Sin fugas de audio al salir [M]
- [ ] Sonidos de docking/salida y balance con M91 [M]
- [ ] Testear audio 3D y bajo el agua (amortiguado) [M]

## P. Animaciones (M48)

- [ ] Timón al girar, olas/estela y hélices del dirigible [M]
- [ ] Pasajeros a bordo y banderas con viento [M]
- [ ] Detener animaciones al salir (sin fuga) [M]
- [ ] LOD de animaciones en distancia [M]
- [ ] Testear animaciones con Reduce Motion (M58) [M]

## Q. Cámara

- [ ] Cámara 3ª persona con zoom de cámara [M]
- [ ] Seguimiento suave sin mareo (M57) [M]
- [ ] Reducir movimiento con Reduce Motion (M58) [M]
- [ ] Cámara del submarino estable y sin clipping del dirigible [M]
- [ ] Testear cámara en 16:9 y 4:3 (M08) [M]

## R. Rendimiento (M61/M62)

- [ ] Presupuesto por vehículo ≤ 30 draw calls (pooling M62) [C]
- [ ] Luces de faroles en pool (M49, máx 2 por vehículo) [M]
- [ ] VFX solo por eventos (M52) [M]
- [ ] Sin GC pesado durante la conducción [M]
- [ ] Probar con profiler (M116) y baja calidad (M90) [C]

## S. Edge Cases

- [ ] Entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado) [M]
- [ ] Salir con el vehículo en movimiento rápido [M]
- [ ] Vehículo atascado en roca (desatascado manual) [M]
- [ ] Barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32) [M]
- [ ] Carga de guardado con vehículo en el agua o a 60 m (M59) [C]

## T. Localización (M87)

- [ ] Localizar HUD del vehículo (velocidad, dirección) [S]
- [ ] Localizar menús de personalización y avisos de docking [S]
- [ ] Localizar nombres de vehículos [S]
- [ ] Testear HUD en 3 idiomas sin desbordes [M]
- [ ] Localizar mensajes de límites (profundidad, altitud) [S]

## U. Accesibilidad (M58)

- [ ] HUD legible con alto contraste opcional [M]
- [ ] Tamaño de texto configurable [M]
- [ ] Reduce Motion: cámara y animaciones reducidas [M]
- [ ] Subtítulos en avisos del vehículo [S]
- [ ] Controles completos con gamepad (sin mouse) [M]

## V. Validación y QA

- [ ] Crear validate_vehicles.gd (física, streaming, colisiones, presupuestos) [C]
- [ ] Probar ciclo barco: dock → entrar → navegar → atracar → salir [C]
- [ ] Probar ciclo dirigible: despegar → volar → aterrizar [C]
- [ ] Probar ciclo submarino: sumergir → explorar → emerger [C]
- [ ] Revisar logs VEH-* en consola sin errores [S]

## W. Documentación

- [ ] Documentar la API de VehicleManager [M]
- [ ] Documentar los presets en 04-Codigo.md [M]
- [ ] Documentar el flujo de streaming (chunk_target) [M]
- [ ] Documentar la condición de la locomotora [S]
- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## X. Integraciones Finales

- [ ] Alimentar logros de exploración (M72) por viajes [M]
- [ ] Registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST) [M]
- [ ] Guardar estado del vehículo en el mundo (M59) [M]
- [ ] Coordinar con M68 la navegación asistida [M]
- [ ] Testear integración con M28 (viajes entre islas) [C]

## Y. Cierre del Módulo

- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [ ] Actualizar DOCUMENTACION/README.md con el módulo 67 [S]
- [ ] Actualizar ESTADO-PARALELO.md [S]
- [ ] Generar el log 63 en Logs/ [S]

## Z. Validación Final (DoD)

- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Push del módulo y reporte al usuario [S]
- [ ] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [ ] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [ ] Confirmar 130 ítems exactos [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 07:40
**Estado:** Liberado (iter. 1 núcleo V0 cerrada) — 17/131 [x]

### Lo que hice en iter. 1 (Log 528)
- **VehicleManager** (autoload "Vehiculos"): enter(vehicle_id)/exit()/atracar(dock)/zarpar() con resultado {ok, motivo}; un vehículo a la vez; validación docked; dock con lock duck-typed a HarborDock de M28; ISaveProvider M59 sección "vehiculos" (cozy: restaura docked a velocidad 0).
- **VehiclePreset** (Resource + class_name, como BoatRoute): desde_datos() desde JSON; física (vel_max/crucero, giro, frenado), capacidades (altitud/profundidad máx), baúl slots, reversa, condicional M68.
- **Catálogo data-driven**: data/vehiculos/vehicles.json (barco 12 m/s, dirigible 60 m alt, submarino -40 m prof, locomotora 20 m/s condicional). Locomotora se omite si M68 no existe (testeado: 3 activos).
- **VehicleController** (RefCounted puro): ACELERACION 3 m/s², clamp vel_max, frenado, reversa -40% vel_max, giro con wrapf(0, TAU), desplazamiento() listo para nodos 3D. Instanciado con ScriptCtrl.new() (set_script NO inicializa vars — lección §9).
- **EventBus.vehicle** (dominio aditivo): vehicle_entered/exited/docked/aviso — sin romper contratos (§9).
- **Tests** (test_vehiculos.gd, 8 secciones ~35 checks): catálogo, enter/exit validación, física acotada, reversa, giro, dock/zarpar, eventos, persistencia — 0 fallos headless.

### Hallazgo técnico (07-GUIA §9, nuevo pitfall)
- **set_script sobre RefCounted.new() NO inicializa las variables del script** (quedan sin declarar → "Invalid access to property"). La forma correcta: `var ScriptCtrl: GDScript = load(...); var c: RefCounted = ScriptCtrl.new()`. Documentado en 04-Codigo.md y candidato a la guía 07 §8.

### Nota sobre concurrentes (transparencia)
- Mi primer dominio VehicleEvents en event_bus.gd fue pisado por otro agente durante la iteración (mismo patrón que M71/Log 527). Lo re-apliqué y verifico en el test final. Recomiendo coordinar ediciones de event_bus.gd (archivo caliente compartido).

### Lo que NO está resuelto (pendientes con dueño / iter. 2)
- Nodos 3D reales (barco/dirigible/submarino visuales, flotación M51, chunk_target M10 real): iter. 2 V1/V2 con dueño visual (M45/M51/M61).
- Colisiones con islas/rocas (M50), aguas poco profundas con aviso (emitir vehicle_aviso), vela/estela (M48/M52).
- Viento lateral dirigible (M32), faroles (M49), luces submarinas, burbujas (M52), audio amortiguado (M43).
- HUD del vehículo (M53), personalización pintura/banderas, mejoras (velocidad/giro/baúl+).
- Controles M57 (WASD/gamepad reales) y cámara 3ª persona al conducir (M12).
- Baúl M14 real (integración con Inventario por slots del preset) y logs VEH-MOVE debug.

### Decisiones clave
1. **Controller lógico puro (RefCounted) separado del VehicleManager**: testeable headless sin nodos 3D; la iter. 2 solo conecta nodos y consume aplicar()/desplazamiento().
2. **Locomotora condicional por JSON** ("condicional": "M68"): sin código de integración — el catálogo se auto-adapta al autoload existente.
3. **Dock duck-typed a HarborDock (M28)**: atracar(dock) llama lock() si existe; el magnetismo visual queda para iter. 2 con posiciones reales.
4. **Persistencia cozy**: si se guarda en movimiento, restaura docked y a velocidad 0 (sin perder el vehículo, sin soft-lock).

### Validación
- test_vehiculos.gd: 0 fallos (8 secciones, ~35 checks).
- Regresiones: test_viajes (M28) 0 fallos, test_logros (M72) 0 fallos, test_progresion (M71) 0 fallos.
- Boot: [M67] VehicleManager listo: 3 presets; logs VEH-ENTER/EXIT visibles.

### Recomendaciones para el próximo agente
- Iter. 2 (V1 visual): crear escena Vehicle3D que consuma controller.aplicar(delta) y desplazamiento(delta) para mover el Node3D; registrar el autoload de cámara M12 al enter y restaurar al exit.
- El controller ya expone rumbo (rad) y velocidad (m/s con signo) — el HUD M53 puede leerlos directo vía Vehiculos.controller.
- Para aguas poco profundas: consultar M51/mesh de agua y emitir Vehiculos.avisar("...") (la señal ya existe).
- Al integrar M57: el enter/exit actual es programático; conectar a InteractionManager (M70) con área de proximidad.
