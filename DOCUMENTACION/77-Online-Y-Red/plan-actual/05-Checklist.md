**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 77: Online y Red (130 ítems)

## A. Arquitectura Cliente-Servidor (RF1)

- [x] Elegir cliente-servidor para el online [S]
- [x] Documentar servidor como autoridad total [S]
- [x] Documentar API Gateway (auth, rate limit) [M]
- [x] Documentar World Sim con snapshots @ 10 Hz [M]
- [x] Verificar coherencia con mp_contract.json (M76) [S]

## B. Evaluar P2P (RF2)

- [x] Evaluar P2P (NAT, host offline, trampas) [M]
- [x] Descartar P2P para online con argumentos [M]
- [x] Documentar P2P válido SOLO en local (M76) [S]
- [x] Registrar p2p=false en net_contract.json [S]
- [x] Verificar que el local no usa red [S]

## C. Servidores Dedicados (RF3)

- [x] Elegir servidor dedicado como modelo objetivo [S]
- [x] Definir autoscaling por región [M]
- [x] Definir 1 instancia ≈ 200 CCU [S]
- [x] Documentar instancia de referencia (8 vCPU/16 GB) [S]
- [x] Registrar ccu_por_instancia=200 en el manifiesto [S]

## D. Sincronización de Mundo (RF4)

- [x] Definir snapshot completo del área del jugador [M]
- [x] Definir frecuencia de snapshot 10 Hz [S]
- [x] Definir suscripción por área (grid M61) [M]
- [x] Definir presupuesto de red por jugador (<64 kbps) [M]
- [x] Registrar snapshot_hz=10 en el manifiesto [S]

## E. Sincronización de NPC (RF5)

- [x] Definir estado compacto de NPC (pos/anima/emoción) [M]
- [x] Definir NPCs solo visibles (M35/M19) [M]
- [x] Definir ritmo de actualización de NPCs [S]
- [x] Documentar sin NPCs siempre activos (M49 durmientes) [M]
- [x] Verificar presupuesto con NPCs en el área [M]

## F. Sincronización de Construcción (RF6)

- [x] Definir construcción con confirmación del servidor [M]
- [x] Definir permisos por diseño (M76 RF10) [S]
- [x] Definir undo/redo validado del invitado [M]
- [x] Documentar que el servidor valida catálogos (M18) [S]
- [x] Verificar sin estado duplicado de construcción [S]

## G. Sincronización de Inventario (RF7)

- [x] Definir autoridad del servidor sobre el inventario [S]
- [x] Definir jamás aceptar inventario del cliente [S]
- [x] Definir confirmación reliable de cambios [S]
- [x] Documentar reconciliación tras reconexión [M]
- [x] Verificar integridad del inventario (M14) [M]

## H. Sincronización de Economía (RF8)

- [x] Definir monedas server-side (M38) [S]
- [x] Definir transferencias validadas anti-duplicación [M]
- [x] Definir regla: ítems de historia jamás transferibles (M76) [S]
- [x] Documentar compra/venta con confirmación [S]
- [x] Verificar economía protegida en el manifiesto [S]

## I. Sincronización de Eventos (RF9)

- [x] Definir eventos M74 replicados con timestamp servidor [M]
- [x] Definir recompensas individuales (M76 RF19) [S]
- [x] Definir cola de eventos fuera de línea (reconexión) [M]
- [x] Documentar sin eventos duplicados (idempotencia) [M]
- [x] Verificar progreso individual de eventos [S]

## J. Reconexión (RF10)

- [x] Definir reconexión <10 s con token [M]
- [x] Definir estado del servidor intacto [S]
- [x] Definir re-suscripción al área [S]
- [x] Documentar cola de mensajes perdidos durante caída [M]
- [x] Registrar reconexion_segundos=10 en el manifiesto [S]

## K. Reconocimiento de Sesión (RF11)

- [x] Definir token JWT corto (15 min) [M]
- [x] Definir renovación silenciosa [M]
- [x] Definir sesión única por jugador [S]
- [x] Documentar invalidación de sesión (logout) [S]
- [x] Registrar token_jwt_min=15 en el manifiesto [S]

## L. Manejo de Latencia (RF12)

- [x] Definir buffer de interpolación 100-200 ms [M]
- [x] Definir predicción del jugador [M]
- [x] Definir reconciliación suave (sin teleports) [M]
- [x] Documentar latencia objetivo (<200 ms agradable) [S]
- [x] Registrar buffer_interpolacion_ms=150 en el manifiesto [S]

## M. Pérdida de Paquetes (RF13)

- [x] Definir canal reliable (ACK + reenvío) [M]
- [x] Definir canal unreliable (UDP/WebRTC) para animaciones [M]
- [x] Definir manejo de paquetes duplicados (ids) [M]
- [x] Documentar pérdida tolerable (snapshots) [S]
- [x] Verificar estado crítico jamás en unreliable [S]

## N. Predicción (RF14)

- [x] Definir predicción de input del jugador [M]
- [x] Definir reconciliación con snapshot del servidor [M]
- [x] Definir rollback suave (sin snap del avatar) [M]
- [x] Documentar predicción SOLO del jugador propio [S]
- [x] Verificar predicción desactivada en UI/menús [S]

## O. Interpolación (RF15)

- [x] Definir interpolación de entidades remotas [M]
- [x] Definir buffer de 100-200 ms [M]
- [x] Definir sin teleports visibles en NPCs [M]
- [x] Documentar interpolación de animaciones (M13) [M]
- [x] Verificar frame budget con buffer (M61) [C]

## P. Protección contra Trampas (RF16)

- [x] Definir server-authoritative total [S]
- [x] Definir validación de posición/velocidad [M]
- [x] Definir validación de inventario/economía [M]
- [x] Definir rate limits por acción [M]
- [x] Documentar anti-cheat SOLO por servidor (nunca cliente) [S]

## Q. Seguridad de API (RF17)

- [x] Definir HTTPS/TLS 1.3 [M]
- [x] Definir JWT firmado y con expiración [M]
- [x] Definir rate limiting por endpoint [M]
- [x] Definir whitelist de endpoints [S]
- [x] Registrar tls=1.3 en el manifiesto [S]

## R. Logs (RF18)

- [x] Definir telemetría M64 [M]
- [x] Definir logs de eventos y errores por sesión [M]
- [x] Definir latencia registrada por sesión [S]
- [x] Documentar rotación de logs (sección 18 AGENTS) [S]
- [x] Verificar sin datos personales en logs [S]

## S. Monitorización (RF19)

- [x] Definir dashboards (CCU, latencia, errores) [M]
- [x] Definir alertas de umbrales [M]
- [x] Definir alerta de instancia caída [S]
- [x] Documentar métricas de sesión por región [M]
- [x] Verificar monitorización SIN costo en v1 [S]

## T. Escalabilidad (RF20)

- [x] Definir autoscaling por región [M]
- [x] Definir 1 instancia ≈ 200 CCU [S]
- [x] Definir autoscaling SOLO si pico >150 CCU [M]
- [x] Documentar balanceo de conexiones [M]
- [x] Verificar escalabilidad sin cambio de código (contrato) [S]

## U. Backups (RF21)

- [x] Definir RPO 15 min (backups M65) [M]
- [x] Definir bucket de backups cifrado [M]
- [x] Definir backups de estado + cuentas [S]
- [x] Registrar rpo_min=15 en el manifiesto [S]
- [x] Verificar backups automáticos sin intervención [S]

## V. Recuperación (RF22)

- [x] Definir RTO 2 h [M]
- [x] Definir failover con heartbeat 5 s [M]
- [x] Definir recuperación sin pérdida de sesión [M]
- [x] Registrar rto_horas=2 en el manifiesto [S]
- [x] Verificar runbook de recuperación documentado [M]

## W. Costes (RF23)

- [x] Estimar instancia dedicada ($120-180/mes) [M]
- [x] Estimar base de datos ($60-100/mes) [M]
- [x] Estimar CDN y telemetría ($50-90/mes) [M]
- [x] Calcular total mensual (~$230-370/mes) [M]
- [x] Condicionar la apertura al hit >10k descargas [S]

## X. Coherencia con M76

- [x] Respetar mp_contract.json como fuente de producto [S]
- [x] Respetar chat sin texto libre [S]
- [x] Respetar progreso individual [S]
- [x] Respetar economía protegida [S]
- [x] Verificar hit de apertura coincidente [S]

## Y. Validación y Cierre Técnico

- [x] Entregar net_contract.json (manifiesto técnico) [M]
- [x] Entregar validate_net_contract.gd [M]
- [x] Verificar que v1 no abre puertos (grep) [S]
- [x] Documentar reconciliación offline→online futura [M]
- [x] Documentar presupuesto de red <64 kbps/jugador [M]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]