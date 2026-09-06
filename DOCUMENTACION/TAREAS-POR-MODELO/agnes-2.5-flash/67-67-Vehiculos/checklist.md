# Tareas módulo 67 67-Vehiculos

**Estado:** 🟡 Liberado (iter. 1 núcleo)

**Items pendientes:** 112

[ ] T-67-001: Navegar por agua leyendo la superficie (M51, sin fluidos)
[ ] T-67-002: Velocidad de crucero/rápida, timón suave y reversa
[ ] T-67-003: Colisiones con islas, rocas y vegetación (M50) sin atravesar
[ ] T-67-004: No atascarse en aguas poco profundas (aviso)
[ ] T-67-005: Vela desplegable (M48) y estela por evento (M52)
[ ] T-67-006: Vuelo con altitud/descenso y aterrizaje suave en plataformas
[ ] T-67-007: Altitud máxima 60 m (mejorable a 90 m)
[ ] T-67-008: No romper el streaming a gran altura (chunk_target + LOD, M10/M61)
[ ] T-67-009: No colisionar con vegetación alta (paso por encima)
[ ] T-67-010: Viento lateral (M32) y farol nocturno (M49)
[ ] T-67-011: Buceo/emersión con límite −40 m y flotabilidad mínima
[ ] T-67-012: Visibilidad y luces bajo el agua (M49)
[ ] T-67-013: Explorar cuevas subacuáticas (M25)
[ ] T-67-014: Burbujas por evento (M52) y audio amortiguado (M43)
[ ] T-67-015: Cámara estable bajo el agua (sin mareo)
[ ] T-67-016: Velocidad sobre riel fija (20 m/s) y sin giro libre
[ ] T-67-017: Vagón de carga (16 slots, M14)
[ ] T-67-018: Documentar el estado condicional en 01-Requerimientos.md
[ ] T-67-019: Controles con WASD y gamepad (palanca/gatillos)
[ ] T-67-020: Testear física en 30/60 FPS (delta correcto)
[ ] T-67-021: Volver chunk_target = jugador al salir
[ ] T-67-022: LOD de chunks por altitud del dirigible
[ ] T-67-023: Cargar islas cercanas (M27) antes que el terreno lejano
[ ] T-67-024: Testear barco/dirigible/submarino sin popping de terreno
[ ] T-67-025: Colisiones suaves con islas, rocas y vegetación (M50)
[ ] T-67-026: Barco no puede ir a tierra; submarino no emerge en tierra
[ ] T-67-027: Dirigible con techo de altitud
[ ] T-67-028: Vehículos no atraviesan puentes (M11) ni ruinas (M25)
[ ] T-67-029: No atropellar animales (M36)
[ ] T-67-030: Interacción para entrar/salir del vehículo
[ ] T-67-031: Entrada solo si está docked o en superficie
[ ] T-67-032: Al salir: restaurar cámara, HUD y sonidos (sin fugas)
[ ] T-67-033: No quedar atascado cerca de muros al entrar/salir
[ ] T-67-034: Testear entrada/salida con gamepad y durante eventos (M74)
[ ] T-67-035: Atraque con magnetismo suave en muelles
[ ] T-67-036: Ajustar posición y rotación; ángulo inválido → reintento
[ ] T-67-037: Docking de barco y dirigible en plataformas
[ ] T-67-038: Indicador visual de zona de atraque (M53) y sonido (M43)
[ ] T-67-039: Testear docking en muelles angostos y con olas (M51)
[ ] T-67-040: Baúl integrado con slots por tipo (barco 12, dirigible 8, submarino 10)
[ ] T-67-041: Abrir el baúl desde el HUD y mover ítems
[ ] T-67-042: Límite de slots respetado y apilables
[ ] T-67-043: Mejora de baúl persistente (M59)
[ ] T-67-044: Testear baúl con inventario lleno
[ ] T-67-045: Definir mejoras por vehículo (velocidad, giro, faroles, baúl)
[ ] T-67-046: Mejoras de velocidad/giro (niveles)
[ ] T-67-047: Mejoras de faroles (M49) y baúl
[ ] T-67-048: Comprar en tienda (M39) o artesanales (M16)
[ ] T-67-049: Persistencia y visualización de nivel en el HUD
[ ] T-67-050: Pintura del vehículo (paleta cozy, M46)
[ ] T-67-051: Banderas personalizables con viento (M50/M48)
[ ] T-67-052: Nombre del vehículo editable y localizable (M87)
[ ] T-67-053: Materiales de pintura del pool (M45/M49)
[ ] T-67-054: Persistencia de personalización (M59)
[ ] T-67-055: Sonidos de motor/agua/viento por vehículo
[ ] T-67-056: LOD de audio: atenuar > 40 m, silenciar > 80 m
[ ] T-67-057: Sin fugas de audio al salir
[ ] T-67-058: Sonidos de docking/salida y balance con M91
[ ] T-67-059: Testear audio 3D y bajo el agua (amortiguado)
[ ] T-67-060: Timón al girar, olas/estela y hélices del dirigible
[ ] T-67-061: Pasajeros a bordo y banderas con viento
[ ] T-67-062: Detener animaciones al salir (sin fuga)
[ ] T-67-063: LOD de animaciones en distancia
[ ] T-67-064: Testear animaciones con Reduce Motion (M58)
[ ] T-67-065: Cámara 3ª persona con zoom de cámara
[ ] T-67-066: Seguimiento suave sin mareo (M57)
[ ] T-67-067: Reducir movimiento con Reduce Motion (M58)
[ ] T-67-068: Cámara del submarino estable y sin clipping del dirigible
[ ] T-67-069: Testear cámara en 16:9 y 4:3 (M08)
[ ] T-67-070: Presupuesto por vehículo ≤ 30 draw calls (pooling M62)
[ ] T-67-071: Luces de faroles en pool (M49, máx 2 por vehículo)
[ ] T-67-072: VFX solo por eventos (M52)
[ ] T-67-073: Sin GC pesado durante la conducción
[ ] T-67-074: Probar con profiler (M116) y baja calidad (M90)
[ ] T-67-075: Entrar con inventario abierto (M14) o durante diálogo (M21, bloqueado)
[ ] T-67-076: Salir con el vehículo en movimiento rápido
[ ] T-67-077: Vehículo atascado en roca (desatascado manual)
[ ] T-67-078: Barco en agua congelada (hielo M51) y dirigible con viento fuerte (M32)
[ ] T-67-079: Carga de guardado con vehículo en el agua o a 60 m (M59)
[ ] T-67-080: Localizar HUD del vehículo (velocidad, dirección)
[ ] T-67-081: Localizar menús de personalización y avisos de docking
[ ] T-67-082: Localizar nombres de vehículos
[ ] T-67-083: Testear HUD en 3 idiomas sin desbordes
[ ] T-67-084: Localizar mensajes de límites (profundidad, altitud)
[ ] T-67-085: HUD legible con alto contraste opcional
[ ] T-67-086: Reduce Motion: cámara y animaciones reducidas
[ ] T-67-087: Subtítulos en avisos del vehículo
[ ] T-67-088: Controles completos con gamepad (sin mouse)
[ ] T-67-089: Crear validate_vehicles.gd (física, streaming, colisiones, presupuestos)
[ ] T-67-090: Probar ciclo barco: dock → entrar → navegar → atracar → salir
[ ] T-67-091: Probar ciclo dirigible: despegar → volar → aterrizar
[ ] T-67-092: Probar ciclo submarino: sumergir → explorar → emerger
[ ] T-67-093: Revisar logs VEH-* en consola sin errores
[ ] T-67-094: Documentar los presets en 04-Codigo.md
[ ] T-67-095: Documentar el flujo de streaming (chunk_target)
[ ] T-67-096: Documentar la condición de la locomotora
[ ] T-67-097: Agregar notas del agente al 04-Codigo.md (honestidad)
[ ] T-67-098: Alimentar logros de exploración (M72) por viajes
[ ] T-67-099: Registrar fotos del vehículo (M56, PHOTO_POSE_REQUEST)
[ ] T-67-100: Guardar estado del vehículo en el mundo (M59)
[ ] T-67-101: Coordinar con M68 la navegación asistida
[ ] T-67-102: Testear integración con M28 (viajes entre islas)
[ ] T-67-103: Firmar los documentos del módulo (modelo y plataforma)
[ ] T-67-104: Actualizar CHECKLIST-GLOBAL con el progreso real
[ ] T-67-105: Actualizar DOCUMENTACION/README.md con el módulo 67
[ ] T-67-106: Actualizar ESTADO-PARALELO.md
[ ] T-67-107: Generar el log 63 en Logs/
[ ] T-67-108: Verificar con verificar_checklist.py (sin alertas nuevas)
[ ] T-67-109: Push del módulo y reporte al usuario
[ ] T-67-110: Marcar ítems solo al cumplir la DoD (sección 21.6)
[ ] T-67-111: Revisar que plan-inicial == plan-actual (SHA-256)
[ ] T-67-112: Confirmar 130 ítems exactos
