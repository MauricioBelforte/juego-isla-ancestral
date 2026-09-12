# Tareas módulo 77 77-Online-Y-Red

**Estado:** 🟢 Disponible

**Items pendientes:** 126

[ ] T-77-001: Elegir cliente-servidor para el online
[ ] T-77-002: Documentar servidor como autoridad total
[ ] T-77-003: Documentar API Gateway (auth, rate limit)
[ ] T-77-004: Documentar World Sim con snapshots @ 10 Hz
[ ] T-77-005: Evaluar P2P (NAT, host offline, trampas)
[ ] T-77-006: Descartar P2P para online con argumentos
[ ] T-77-007: Documentar P2P válido SOLO en local (M76)
[ ] T-77-008: Verificar que el local no usa red
[ ] T-77-009: Elegir servidor dedicado como modelo objetivo
[ ] T-77-010: Definir autoscaling por región
[ ] T-77-011: Definir 1 instancia ≈ 200 CCU
[ ] T-77-012: Documentar instancia de referencia (8 vCPU/16 GB)
[ ] T-77-013: Registrar ccu_por_instancia=200 en el manifiesto
[ ] T-77-014: Definir snapshot completo del área del jugador
[ ] T-77-015: Definir frecuencia de snapshot 10 Hz
[ ] T-77-016: Definir suscripción por área (grid M61)
[ ] T-77-017: Definir presupuesto de red por jugador (<64 kbps)
[ ] T-77-018: Registrar snapshot_hz=10 en el manifiesto
[ ] T-77-019: Definir estado compacto de NPC (pos/anima/emoción)
[ ] T-77-020: Definir NPCs solo visibles (M35/M19)
[ ] T-77-021: Definir ritmo de actualización de NPCs
[ ] T-77-022: Documentar sin NPCs siempre activos (M49 durmientes)
[ ] T-77-023: Verificar presupuesto con NPCs en el área
[ ] T-77-024: Definir construcción con confirmación del servidor
[ ] T-77-025: Definir permisos por diseño (M76 RF10)
[ ] T-77-026: Definir undo/redo validado del invitado
[ ] T-77-027: Documentar que el servidor valida catálogos (M18)
[ ] T-77-028: Verificar sin estado duplicado de construcción
[ ] T-77-029: Definir autoridad del servidor sobre el inventario
[ ] T-77-030: Definir jamás aceptar inventario del cliente
[ ] T-77-031: Definir confirmación reliable de cambios
[ ] T-77-032: Documentar reconciliación tras reconexión
[ ] T-77-033: Verificar integridad del inventario (M14)
[ ] T-77-034: Definir monedas server-side (M38)
[ ] T-77-035: Definir transferencias validadas anti-duplicación
[ ] T-77-036: Definir regla: ítems de historia jamás transferibles (M76)
[ ] T-77-037: Documentar compra/venta con confirmación
[ ] T-77-038: Verificar economía protegida en el manifiesto
[ ] T-77-039: Definir eventos M74 replicados con timestamp servidor
[ ] T-77-040: Definir recompensas individuales (M76 RF19)
[ ] T-77-041: Definir cola de eventos fuera de línea (reconexión)
[ ] T-77-042: Documentar sin eventos duplicados (idempotencia)
[ ] T-77-043: Verificar progreso individual de eventos
[ ] T-77-044: Definir reconexión <10 s con token
[ ] T-77-045: Definir estado del servidor intacto
[ ] T-77-046: Definir re-suscripción al área
[ ] T-77-047: Documentar cola de mensajes perdidos durante caída
[ ] T-77-048: Registrar reconexion_segundos=10 en el manifiesto
[ ] T-77-049: Definir token JWT corto (15 min)
[ ] T-77-050: Definir renovación silenciosa
[ ] T-77-051: Definir sesión única por jugador
[ ] T-77-052: Documentar invalidación de sesión (logout)
[ ] T-77-053: Registrar token_jwt_min=15 en el manifiesto
[ ] T-77-054: Definir buffer de interpolación 100-200 ms
[ ] T-77-055: Definir predicción del jugador
[ ] T-77-056: Definir reconciliación suave (sin teleports)
[ ] T-77-057: Documentar latencia objetivo (<200 ms agradable)
[ ] T-77-058: Registrar buffer_interpolacion_ms=150 en el manifiesto
[ ] T-77-059: Definir canal reliable (ACK + reenvío)
[ ] T-77-060: Definir canal unreliable (UDP/WebRTC) para animaciones
[ ] T-77-061: Definir manejo de paquetes duplicados (ids)
[ ] T-77-062: Documentar pérdida tolerable (snapshots)
[ ] T-77-063: Verificar estado crítico jamás en unreliable
[ ] T-77-064: Definir predicción de input del jugador
[ ] T-77-065: Definir reconciliación con snapshot del servidor
[ ] T-77-066: Definir rollback suave (sin snap del avatar)
[ ] T-77-067: Documentar predicción SOLO del jugador propio
[ ] T-77-068: Verificar predicción desactivada en UI/menús
[ ] T-77-069: Definir interpolación de entidades remotas
[ ] T-77-070: Definir buffer de 100-200 ms
[ ] T-77-071: Definir sin teleports visibles en NPCs
[ ] T-77-072: Documentar interpolación de animaciones (M13)
[ ] T-77-073: Verificar frame budget con buffer (M61)
[ ] T-77-074: Definir server-authoritative total
[ ] T-77-075: Definir validación de posición/velocidad
[ ] T-77-076: Definir validación de inventario/economía
[ ] T-77-077: Definir rate limits por acción
[ ] T-77-078: Documentar anti-cheat SOLO por servidor (nunca cliente)
[ ] T-77-079: Definir HTTPS/TLS 1.3
[ ] T-77-080: Definir JWT firmado y con expiración
[ ] T-77-081: Definir rate limiting por endpoint
[ ] T-77-082: Definir whitelist de endpoints
[ ] T-77-083: Registrar tls=1.3 en el manifiesto
[ ] T-77-084: Definir telemetría M64
[ ] T-77-085: Definir logs de eventos y errores por sesión
[ ] T-77-086: Definir latencia registrada por sesión
[ ] T-77-087: Documentar rotación de logs (sección 18 AGENTS)
[ ] T-77-088: Verificar sin datos personales en logs
[ ] T-77-089: Definir dashboards (CCU, latencia, errores)
[ ] T-77-090: Definir alertas de umbrales
[ ] T-77-091: Definir alerta de instancia caída
[ ] T-77-092: Documentar métricas de sesión por región
[ ] T-77-093: Verificar monitorización SIN costo en v1
[ ] T-77-094: Definir autoscaling por región
[ ] T-77-095: Definir 1 instancia ≈ 200 CCU
[ ] T-77-096: Definir autoscaling SOLO si pico >150 CCU
[ ] T-77-097: Documentar balanceo de conexiones
[ ] T-77-098: Verificar escalabilidad sin cambio de código (contrato)
[ ] T-77-099: Definir RPO 15 min (backups M65)
[ ] T-77-100: Definir bucket de backups cifrado
[ ] T-77-101: Definir backups de estado + cuentas
[ ] T-77-102: Registrar rpo_min=15 en el manifiesto
[ ] T-77-103: Verificar backups automáticos sin intervención
[ ] T-77-104: Definir RTO 2 h
[ ] T-77-105: Definir failover con heartbeat 5 s
[ ] T-77-106: Definir recuperación sin pérdida de sesión
[ ] T-77-107: Registrar rto_horas=2 en el manifiesto
[ ] T-77-108: Verificar runbook de recuperación documentado
[ ] T-77-109: Estimar instancia dedicada ($120-180/mes)
[ ] T-77-110: Estimar base de datos ($60-100/mes)
[ ] T-77-111: Estimar CDN y telemetría ($50-90/mes)
[ ] T-77-112: Calcular total mensual (~$230-370/mes)
[ ] T-77-113: Condicionar la apertura al hit >10k descargas
[ ] T-77-114: Respetar chat sin texto libre
[ ] T-77-115: Respetar progreso individual
[ ] T-77-116: Respetar economía protegida
[ ] T-77-117: Verificar hit de apertura coincidente
[ ] T-77-118: Entregar validate_net_contract.gd
[ ] T-77-119: Verificar que v1 no abre puertos (grep)
[ ] T-77-120: Documentar reconciliación offline→online futura
[ ] T-77-121: Documentar presupuesto de red <64 kbps/jugador
[ ] T-77-122: Agregar notas del agente al 04-Codigo.md (honestidad)
[ ] T-77-123: Firmar los documentos del módulo (modelo y plataforma)
[ ] T-77-124: Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log
[ ] T-77-125: Verificar con verificar_checklist.py (sin alertas nuevas)
[ ] T-77-126: Confirmar 130 ítems exactos y plan-inicial == plan-actual
