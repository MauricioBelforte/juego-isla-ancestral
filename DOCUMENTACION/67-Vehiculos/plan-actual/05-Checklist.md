**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 67: Vehículos (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. VehicleManager (autoload)

- [x] Definir VehicleManager como autoload único de vehículos [M]
- [x] Gestionar el vehículo activo (uno a la vez) y API enter/exit (M70) [M]
- [x] Validar estado antes de entrar (docked, superficie) [M]
- [x] Registrar logs VEH-ENTER y VEH-EXIT [S]
- [x] Emitir eventos VEHICLE_ENTERED/EXITED (M07) [S]

## B. Presets de Vehículos

- [x] Definir vehicle_preset.gd (tipo, física, capacidades, mejoras) [M]
- [x] Crear vehicles_catalog.tres: barco, dirigible, submarino + plantilla locomotora [M]
- [x] Preset barco (agua M51, 12 m/s) [M]
- [x] Preset dirigible (aire, altitud máx 60 m) [M]
- [x] Preset submarino (subagua, profundidad máx −40 m) [M]

## C. Barco

- [x] Navegar por agua leyendo la superficie (M51, sin fluidos) [C]
- [x] Velocidad de crucero/rápida, timón suave y reversa [M]
- [x] Colisiones con islas, rocas y vegetación (M50) sin atravesar [C]
- [x] No atascarse en aguas poco profundas (aviso) [M]
- [x] Vela desplegable (M48) y estela por evento (M52) [M]

## D. Dirigible

- [x] Vuelo con altitud/descenso y aterrizaje suave en plataformas [M]
- [x] Altitud máxima 60 m (mejorable a 90 m) [S]
- [x] No romper el streaming a gran altura (chunk_target + LOD, M10/M61) [C]
- [x] No colisionar con vegetación alta (paso por encima) [M]
- [x] Viento lateral (M32) y farol nocturno (M49) [M]

## E. Submarino

- [x] Buceo/emersión con límite −40 m y flotabilidad mínima [C]
- [x] Visibilidad y luces bajo el agua (M49) [M]
- [x] Explorar cuevas subacuáticas (M25) [C]
- [x] Burbujas por evento (M52) y audio amortiguado (M43) [M]
- [x] Cámara estable bajo el agua (sin mareo) [M]

## F. Locomotora (condicional M68)

- [x] Plantilla de locomotora SOLO si M68 exige ferrocarril [M]
- [x] Velocidad sobre riel fija (20 m/s) y sin giro libre [M]
- [x] Vagón de carga (16 slots, M14) [M]
- [x] Documentar el estado condicional en 01-Requerimientos.md [S]
- [x] Definir contrato de integración con M68 [M]

## G. Física y Control (M57)

- [x] Física acotada: velocidad/giro/frenado por preset con suavizado [M]
- [x] Controles con WASD y gamepad (palanca/gatillos) [M]
- [x] Reversa para barco [S]
- [x] Velocidad limitada por tipo (nunca romper streaming) [M]
- [x] Testear física en 30/60 FPS (delta correcto) [C]

## H. Streaming (M10/M61)

- [x] Establecer chunk_target = vehículo durante la conducción [C]
- [x] Volver chunk_target = jugador al salir [M]
- [x] LOD de chunks por altitud del dirigible [C]
- [x] Cargar islas cercanas (M27) antes que el terreno lejano [M]
- [x] Testear barco/dirigible/submarino sin popping de terreno [C]

## I. Colisiones y Límites

- [x] Colisiones suaves con islas, rocas y vegetación (M50) [C]
- [x] Barco no puede ir a tierra; submarino no emerge en tierra [M]
- [x] Dirigible con techo de altitud [S]
- [x] Vehículos no atraviesan puentes (M11) ni ruinas (M25) [M]
- [x] No atropellar animales (M36) [M]

## J. Entrada/Salida (M70)

- [x] Interacción para entrar/salir del vehículo [S]
- [x] Entrada solo si está docked o en superficie [M]
- [x] Al salir: restaurar cámara, HUD y sonidos (sin fugas) [M]
- [x] No quedar atascado cerca de muros al entrar/salir [M]
- [x] Testear entrada/salida con gamepad y durante eventos (M74) [M]

## K. Docking (M28)

- [x] Atraque con magnetismo suave en muelles [C]
- [x] Ajustar posición y rotación; ángulo inválido → reintento [M]
- [x] Docking de barco y dirigible en plataformas [M]
- [x] Indicador visual de zona de atraque (M53) y sonido (M43) [S]
- [x] Testear docking en muelles angostos y con olas (M51) [C]

## L. Almacenamiento (M14)

- [x] Baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10) [M]
- [x] Abrir el baúl desde el HUD y mover ítems [M]
- [x] Límite de slots respetado y apilables [M]
- [x] Mejora de baúl persistente (M59) [M]
- [x] Testear baúl con inventario lleno [M]

## M. Mejoras

- [x] Definir mejoras por vehículo (velocidad, giro, faroles, baúl) [M]
- [x] Mejoras de velocidad/giro (niveles) [M]
- [x] Mejoras de faroles (M49) y baúl [M]
- [x] Comprar en tienda (M39) o artesanales (M16) [M]
- [x] Persistencia y visualización de nivel en el HUD [M]

## N. Personalización

- [x] Pintura del vehículo (paleta cozy, M46) [M]
- [x] Banderas personalizables con viento (M50/M48) [M]
- [x] Nombre del vehículo editable y localizable (M87) [M]
- [x] Materiales de pintura del pool (M45/M49) [M]
- [x] Persistencia de personalización (M59) [M]

## O. Sonido (M43)

- [x] Sonidos de motor/agua/viento por vehículo [M]
- [x] LOD de audio: atenuar > 40 m, silenciar > 80 m [M]
- [x] Sin fugas de audio al salir [M]
- [x] Sonidos de docking/salida y balance con M91 [M]
- [x] Testear audio 3D y bajo el agua (amortiguado) [M]

## P. Animaciones (M48)

- [x] Timón al girar, olas/estela y hélices del dirigible [M]
- [x] Pasajeros a bordo y banderas con viento [M]
- [x] Detener animaciones al salir (sin fuga) [M]
- [x] LOD de animaciones en distancia [M]
- [x] Testear animaciones con Reduce Motion (M58) [M]

## Q. Cámara

- [x] Cámara 3ª persona con zoom de cámara [M]
- [x] Seguimiento suave sin mareo (M57) [M]
- [x] Reducir movimiento con Reduce Motion (M58) [M]
- [x] Cámara del submarino estable y sin clipping del dirigible [M]
- [x] Testear cámara en 16:9 y 4:3 (M08) [M]

## R. Rendimiento (M61/M62)

- [x] Presupuesto por vehículo ≤ 30 draw calls (pooling M62) [C]
- [x] Luces de faroles en pool (M49, máx 2 por vehículo) [M]
- [x] VFX solo por eventos (M52) [M]
- [x] Sin GC pesado durante la conducción [M]
- [x] Probar con profiler (M116) y baja calidad (M90) [C]

## S. Edge Cases

- [x] Entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado) [M]
- [x] Salir con el vehículo en movimiento rápido [M]
- [x] Vehículo atascado en roca (desatascado manual) [M]
- [x] Barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32) [M]
- [x] Carga de guardado con vehículo en el agua o a 60 m (M59) [C]

## T. Localización (M87)

- [x] Localizar HUD del vehículo (velocidad, dirección) [S]
- [x] Localizar menús de personalización y avisos de docking [S]
- [x] Localizar nombres de vehículos [S]
- [x] Testear HUD en 3 idiomas sin desbordes [M]
- [x] Localizar mensajes de límites (profundidad, altitud) [S]

## U. Accesibilidad (M58)

- [x] HUD legible con alto contraste opcional [M]
- [x] Tamaño de texto configurable [M]
- [x] Reduce Motion: cámara y animaciones reducidas [M]
- [x] Subtítulos en avisos del vehículo [S]
- [x] Controles completos con gamepad (sin mouse) [M]

## V. Validación y QA

- [x] Crear validate_vehicles.gd (física, streaming, colisiones, presupuestos) [C]
- [x] Probar ciclo barco: dock → entrar → navegar → atracar → salir [C]
- [x] Probar ciclo dirigible: despegar → volar → aterrizar [C]
- [x] Probar ciclo submarino: sumergir → explorar → emerger [C]
- [x] Revisar logs VEH-* en consola sin errores [S]

## W. Documentación

- [x] Documentar la API de VehicleManager [M]
- [x] Documentar los presets en 04-Codigo.md [M]
- [x] Documentar el flujo de streaming (chunk_target) [M]
- [x] Documentar la condición de la locomotora [S]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## X. Integraciones Finales

- [x] Alimentar logros de exploración (M72) por viajes [M]
- [x] Registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST) [M]
- [x] Guardar estado del vehículo en el mundo (M59) [M]
- [x] Coordinar con M68 la navegación asistida [M]
- [x] Testear integración con M28 (viajes entre islas) [C]

## Y. Cierre del Módulo

- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [x] Actualizar DOCUMENTACION/README.md con el módulo 67 [S]
- [x] Actualizar ESTADO-PARALELO.md [S]
- [x] Generar el log 63 en Logs/ [S]

## Z. Validación Final (DoD)

- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Push del módulo y reporte al usuario [S]
- [x] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [x] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [x] Confirmar 130 ítems exactos [S]