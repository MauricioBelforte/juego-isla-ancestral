**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 77: Online y Red (130 ítems)

## A. Arquitectura Cliente-Servidor (RF1)

- [ ] Elegir cliente-servidor para el online [S]
- [ ] Documentar servidor como autoridad total [S]
- [ ] Documentar API Gateway (auth, rate limit) [M]
- [ ] Documentar World Sim con snapshots @ 10 Hz [M]
- [ ] Verificar coherencia con mp_contract.json (M76) [S]

## B. Evaluar P2P (RF2)

- [ ] Evaluar P2P (NAT, host offline, trampas) [M]
- [ ] Descartar P2P para online con argumentos [M]
- [ ] Documentar P2P válido SOLO en local (M76) [S]
- [ ] Registrar p2p=false en net_contract.json [S]
- [ ] Verificar que el local no usa red [S]

## C. Servidores Dedicados (RF3)

- [ ] Elegir servidor dedicado como modelo objetivo [S]
- [ ] Definir autoscaling por región [M]
- [ ] Definir 1 instancia ≈ 200 CCU [S]
- [ ] Documentar instancia de referencia (8 vCPU/16 GB) [S]
- [ ] Registrar ccu_por_instancia=200 en el manifiesto [S]

## D. Sincronización de Mundo (RF4)

- [ ] Definir snapshot completo del área del jugador [M]
- [ ] Definir frecuencia de snapshot 10 Hz [S]
- [ ] Definir suscripción por área (grid M61) [M]
- [ ] Definir presupuesto de red por jugador (<64 kbps) [M]
- [ ] Registrar snapshot_hz=10 en el manifiesto [S]

## E. Sincronización de NPC (RF5)

- [ ] Definir estado compacto de NPC (pos/anima/emoción) [M]
- [ ] Definir NPCs solo visibles (M35/M19) [M]
- [ ] Definir ritmo de actualización de NPCs [S]
- [ ] Documentar sin NPCs siempre activos (M49 durmientes) [M]
- [ ] Verificar presupuesto con NPCs en el área [M]

## F. Sincronización de Construcción (RF6)

- [ ] Definir construcción con confirmación del servidor [M]
- [ ] Definir permisos por diseño (M76 RF10) [S]
- [ ] Definir undo/redo validado del invitado [M]
- [ ] Documentar que el servidor valida catálogos (M18) [S]
- [ ] Verificar sin estado duplicado de construcción [S]

## G. Sincronización de Inventario (RF7)

- [ ] Definir autoridad del servidor sobre el inventario [S]
- [ ] Definir jamás aceptar inventario del cliente [S]
- [ ] Definir confirmación reliable de cambios [S]
- [ ] Documentar reconciliación tras reconexión [M]
- [ ] Verificar integridad del inventario (M14) [M]

## H. Sincronización de Economía (RF8)

- [ ] Definir monedas server-side (M38) [S]
- [ ] Definir transferencias validadas anti-duplicación [M]
- [ ] Definir regla: ítems de historia jamás transferibles (M76) [S]
- [ ] Documentar compra/venta con confirmación [S]
- [ ] Verificar economía protegida en el manifiesto [S]

## I. Sincronización de Eventos (RF9)

- [ ] Definir eventos M74 replicados con timestamp servidor [M]
- [ ] Definir recompensas individuales (M76 RF19) [S]
- [ ] Definir cola de eventos fuera de línea (reconexión) [M]
- [ ] Documentar sin eventos duplicados (idempotencia) [M]
- [ ] Verificar progreso individual de eventos [S]

## J. Reconexión (RF10)

- [ ] Definir reconexión <10 s con token [M]
- [ ] Definir estado del servidor intacto [S]
- [ ] Definir re-suscripción al área [S]
- [ ] Documentar cola de mensajes perdidos durante caída [M]
- [ ] Registrar reconexion_segundos=10 en el manifiesto [S]

## K. Reconocimiento de Sesión (RF11)

- [ ] Definir token JWT corto (15 min) [M]
- [ ] Definir renovación silenciosa [M]
- [ ] Definir sesión única por jugador [S]
- [ ] Documentar invalidación de sesión (logout) [S]
- [ ] Registrar token_jwt_min=15 en el manifiesto [S]

## L. Manejo de Latencia (RF12)

- [ ] Definir buffer de interpolación 100-200 ms [M]
- [ ] Definir predicción del jugador [M]
- [ ] Definir reconciliación suave (sin teleports) [M]
- [ ] Documentar latencia objetivo (<200 ms agradable) [S]
- [ ] Registrar buffer_interpolacion_ms=150 en el manifiesto [S]

## M. Pérdida de Paquetes (RF13)

- [ ] Definir canal reliable (ACK + reenvío) [M]
- [ ] Definir canal unreliable (UDP/WebRTC) para animaciones [M]
- [ ] Definir manejo de paquetes duplicados (ids) [M]
- [ ] Documentar pérdida tolerable (snapshots) [S]
- [ ] Verificar estado crítico jamás en unreliable [S]

## N. Predicción (RF14)

- [ ] Definir predicción de input del jugador [M]
- [ ] Definir reconciliación con snapshot del servidor [M]
- [ ] Definir rollback suave (sin snap del avatar) [M]
- [ ] Documentar predicción SOLO del jugador propio [S]
- [ ] Verificar predicción desactivada en UI/menús [S]

## O. Interpolación (RF15)

- [ ] Definir interpolación de entidades remotas [M]
- [ ] Definir buffer de 100-200 ms [M]
- [ ] Definir sin teleports visibles en NPCs [M]
- [ ] Documentar interpolación de animaciones (M13) [M]
- [ ] Verificar frame budget con buffer (M61) [C]

## P. Protección contra Trampas (RF16)

- [ ] Definir server-authoritative total [S]
- [ ] Definir validación de posición/velocidad [M]
- [ ] Definir validación de inventario/economía [M]
- [ ] Definir rate limits por acción [M]
- [ ] Documentar anti-cheat SOLO por servidor (nunca cliente) [S]

## Q. Seguridad de API (RF17)

- [ ] Definir HTTPS/TLS 1.3 [M]
- [ ] Definir JWT firmado y con expiración [M]
- [ ] Definir rate limiting por endpoint [M]
- [ ] Definir whitelist de endpoints [S]
- [ ] Registrar tls=1.3 en el manifiesto [S]

## R. Logs (RF18)

- [ ] Definir telemetría M64 [M]
- [ ] Definir logs de eventos y errores por sesión [M]
- [ ] Definir latencia registrada por sesión [S]
- [ ] Documentar rotación de logs (sección 18 AGENTS) [S]
- [ ] Verificar sin datos personales en logs [S]

## S. Monitorización (RF19)

- [ ] Definir dashboards (CCU, latencia, errores) [M]
- [ ] Definir alertas de umbrales [M]
- [ ] Definir alerta de instancia caída [S]
- [ ] Documentar métricas de sesión por región [M]
- [ ] Verificar monitorización SIN costo en v1 [S]

## T. Escalabilidad (RF20)

- [ ] Definir autoscaling por región [M]
- [ ] Definir 1 instancia ≈ 200 CCU [S]
- [ ] Definir autoscaling SOLO si pico >150 CCU [M]
- [ ] Documentar balanceo de conexiones [M]
- [ ] Verificar escalabilidad sin cambio de código (contrato) [S]

## U. Backups (RF21)

- [ ] Definir RPO 15 min (backups M65) [M]
- [ ] Definir bucket de backups cifrado [M]
- [ ] Definir backups de estado + cuentas [S]
- [ ] Registrar rpo_min=15 en el manifiesto [S]
- [ ] Verificar backups automáticos sin intervención [S]

## V. Recuperación (RF22)

- [ ] Definir RTO 2 h [M]
- [ ] Definir failover con heartbeat 5 s [M]
- [ ] Definir recuperación sin pérdida de sesión [M]
- [ ] Registrar rto_horas=2 en el manifiesto [S]
- [ ] Verificar runbook de recuperación documentado [M]

## W. Costes (RF23)

- [ ] Estimar instancia dedicada ($120-180/mes) [M]
- [ ] Estimar base de datos ($60-100/mes) [M]
- [ ] Estimar CDN y telemetría ($50-90/mes) [M]
- [ ] Calcular total mensual (~$230-370/mes) [M]
- [ ] Condicionar la apertura al hit >10k descargas [S]

## X. Coherencia con M76

- [ ] Respetar mp_contract.json como fuente de producto [S]
- [ ] Respetar chat sin texto libre [S]
- [ ] Respetar progreso individual [S]
- [ ] Respetar economía protegida [S]
- [ ] Verificar hit de apertura coincidente [S]

## Y. Validación y Cierre Técnico

- [ ] Entregar net_contract.json (manifiesto técnico) [M]
- [ ] Entregar validate_net_contract.gd [M]
- [ ] Verificar que v1 no abre puertos (grep) [S]
- [ ] Documentar reconciliación offline→online futura [M]
- [ ] Documentar presupuesto de red <64 kbps/jugador [M]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]