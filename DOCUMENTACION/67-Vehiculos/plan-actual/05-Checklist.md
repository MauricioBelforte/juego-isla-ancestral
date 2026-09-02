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

- [ ] Definir VehicleManager como autoload único de vehículos [M]
- [ ] Gestionar el vehículo activo (uno a la vez) y API enter/exit (M70) [M]
- [ ] Validar estado antes de entrar (docked, superficie) [M]
- [ ] Registrar logs VEH-ENTER y VEH-EXIT [S]
- [ ] Emitir eventos VEHICLE_ENTERED/EXITED (M07) [S]

## B. Presets de Vehículos

- [ ] Definir vehicle_preset.gd (tipo, física, capacidades, mejoras) [M]
- [ ] Crear vehicles_catalog.tres: barco, dirigible, submarino + plantilla locomotora [M]
- [ ] Preset barco (agua M51, 12 m/s) [M]
- [ ] Preset dirigible (aire, altitud máx 60 m) [M]
- [ ] Preset submarino (subagua, profundidad máx −40 m) [M]

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

- [ ] Plantilla de locomotora SOLO si M68 exige ferrocarril [M]
- [ ] Velocidad sobre riel fija (20 m/s) y sin giro libre [M]
- [ ] Vagón de carga (16 slots, M14) [M]
- [ ] Documentar el estado condicional en 01-Requerimientos.md [S]
- [ ] Definir contrato de integración con M68 [M]

## G. Física y Control (M57)

- [ ] Física acotada: velocidad/giro/frenado por preset con suavizado [M]
- [ ] Controles con WASD y gamepad (palanca/gatillos) [M]
- [ ] Reversa para barco [S]
- [ ] Velocidad limitada por tipo (nunca romper streaming) [M]
- [ ] Testear física en 30/60 FPS (delta correcto) [C]

## H. Streaming (M10/M61)

- [ ] Establecer chunk_target = vehículo durante la conducción [C]
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
