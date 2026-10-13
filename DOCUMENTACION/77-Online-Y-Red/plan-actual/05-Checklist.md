**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 77: Online y Red (130 ítems)

## A. Arquitectura Cliente-Servidor (RF1)

- [x] Elegir cliente-servidor para el online [S] — **Diseño: 02-Analisis.md 2.1 A1**
- [x] Documentar servidor como autoridad total [S] — **Diseño: 02-Analisis.md 3.2 + 03-Diseno.md 2**
- [x] Documentar API Gateway (auth, rate limit) [M] — **Diseño: 03-Diseno.md 2.1**
- [x] Documentar World Sim con snapshots @ 10 Hz [M] — **Diseño: 03-Diseno.md 2.1 + 2.3**
- [?] Verificar coherencia con mp_contract.json (M76) [S]  [Auditoria T-agnes 2026-10-06: contractos mp/net ausentes en disco; M77 bloqueada v1 single-player]

## B. Evaluar P2P (RF2)

- [x] Evaluar P2P (NAT, host offline, trampas) [M] — **Diseño: 02-Analisis.md 2.1 A2**
- [x] Descartar P2P para online con argumentos [M] — **Diseño: 02-Analisis.md 2.1 A2**
- [x] Documentar P2P válido SOLO en local (M76) [S] — **Diseño: 02-Analisis.md 2.1 A2**
- [?] Registrar p2p=false en net_contract.json [S]
- [ ] Verificar que el local no usa red [S]

## C. Servidores Dedicados (RF3)

- [x] Elegir servidor dedicado como modelo objetivo [S] — **Diseño: 02-Analisis.md 2.1 A1**
- [x] Definir autoscaling por región [M] — **Diseño: 02-Analisis.md 2.6 A1**
- [x] Definir 1 instancia ≈ 200 CCU [S] — **Diseño: 03-Diseno.md 2.1**
- [x] Documentar instancia de referencia (8 vCPU/16 GB) [S] — **Diseño: 02-Analisis.md 4**
- [ ] Registrar ccu_por_instancia=200 en el manifiesto [S]

## D. Sincronización de Mundo (RF4)

- [x] Definir snapshot completo del área del jugador [M] — **Diseño: 03-Diseno.md 2.3 Flujo B**
- [x] Definir frecuencia de snapshot 10 Hz [S] — **Diseño: 02-Analisis.md 2.2 A1**
- [x] Definir suscripción por área (grid M61) [M] — **Diseño: 03-Diseno.md 2.3 Flujo A**
- [x] Definir presupuesto de red por jugador (<64 kbps) [M] — **Diseño: 02-Analisis.md 2.2 A1 + 5**
- [ ] Registrar snapshot_hz=10 en el manifiesto [S]

## E. Sincronización de NPC (RF5)

- [x] Definir estado compacto de NPC (pos/anima/emoción) [M] — **Diseño: 02-Analisis.md 2.2 A1**
- [x] Definir NPCs solo visibles (M35/M19) [M] — **Diseño: 02-Analisis.md 3.3**
- [x] Definir ritmo de actualización de NPCs [S] — **Diseño: 03-Diseno.md 2.2**
- [ ] Documentar sin NPCs siempre activos (M49 durmientes) [M]
- [ ] Verificar presupuesto con NPCs en el área [M]

## F. Sincronización de Construcción (RF6)

- [x] Definir construcción con confirmación del servidor [M] — **Diseño: 03-Diseno.md 2.2**
- [ ] Definir permisos por diseño (M76 RF10) [S]
- [ ] Definir undo/redo validado del invitado [M]
- [ ] Documentar que el servidor valida catálogos (M18) [S]
- [ ] Verificar sin estado duplicado de construcción [S]

## G. Sincronización de Inventario (RF7)

- [x] Definir autoridad del servidor sobre el inventario [S] — **Diseño: 02-Analisis.md 2.5 A1**
- [x] Definir jamás aceptar inventario del cliente [S] — **Diseño: 02-Analisis.md 2.5 A1**
- [x] Definir confirmación reliable de cambios [S] — **Diseño: 03-Diseno.md 2.2**
- [x] Documentar reconciliación tras reconexión [M] — **Diseño: 03-Diseno.md 4**
- [ ] Verificar integridad del inventario (M14) [M]

## H. Sincronización de Economía (RF8)

- [x] Definir monedas server-side (M38) [S] — **Diseño: 02-Analisis.md 3.7**
- [x] Definir transferencias validadas anti-duplicación [M] — **Diseño: 02-Analisis.md 3.7**
- [ ] Definir regla: ítems de historia jamás transferibles (M76) [S]
- [x] Documentar compra/venta con confirmación [S] — **Diseño: 03-Diseno.md 2.3 Flujo C**
- [ ] Verificar economía protegida en el manifiesto [S]

## I. Sincronización de Eventos (RF9)

- [x] Definir eventos M74 replicados con timestamp servidor [M] — **Diseño: 02-Analisis.md 3.8 + 03-Diseno.md 2.3 Flujo E**
- [x] Definir recompensas individuales (M76 RF19) [S] — **Diseño: 03-Diseno.md 2.3 Flujo E**
- [ ] Definir cola de eventos fuera de línea (reconexión) [M]
- [ ] Documentar sin eventos duplicados (idempotencia) [M]
- [ ] Verificar progreso individual de eventos [S]

## J. Reconexión (RF10)

- [x] Definir reconexión <10 s con token [M] — **Diseño: 02-Analisis.md 2.4 A1 + 3.6**
- [x] Definir estado del servidor intacto [S] — **Diseño: 03-Diseno.md 2.3 Flujo D**
- [x] Definir re-suscripción al área [S] — **Diseño: 03-Diseno.md 2.3 Flujo D**
- [ ] Documentar cola de mensajes perdidos durante caída [M]
- [ ] Registrar reconexion_segundos=10 en el manifiesto [S]

## K. Reconocimiento de Sesión (RF11)

- [x] Definir token JWT corto (15 min) [M] — **Diseño: 02-Analisis.md 2.4 A1 + 03-Diseno.md 3.1**
- [x] Definir renovación silenciosa [M] — **Diseño: 02-Analisis.md 2.4 A1**
- [ ] Definir sesión única por jugador [S]
- [ ] Documentar invalidación de sesión (logout) [S]
- [ ] Registrar token_jwt_min=15 en el manifiesto [S]

## L. Manejo de Latencia (RF12)

- [x] Definir buffer de interpolación 100-200 ms [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir predicción del jugador [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir reconciliación suave (sin teleports) [M] — **Diseño: 02-Analisis.md 3.5**
- [x] Documentar latencia objetivo (<200 ms agradable) [S] — **Diseño: 02-Analisis.md 2.3**
- [ ] Registrar buffer_interpolacion_ms=150 en el manifiesto [S]

## M. Pérdida de Paquetes (RF13)

- [x] Definir canal reliable (ACK + reenvío) [M] — **Diseño: 03-Diseno.md 2.2**
- [x] Definir canal unreliable (UDP/WebRTC) para animaciones [M] — **Diseño: 03-Diseno.md 2.2**
- [ ] Definir manejo de paquetes duplicados (ids) [M]
- [ ] Documentar pérdida tolerable (snapshots) [S]
- [ ] Verificar estado crítico jamás en unreliable [S]

## N. Predicción (RF14)

- [x] Definir predicción de input del jugador [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir reconciliación con snapshot del servidor [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir rollback suave (sin snap del avatar) [M] — **Diseño: 02-Analisis.md 3.5**
- [x] Documentar predicción SOLO del jugador propio [S] — **Diseño: 03-Diseno.md 2.3 Flujo B**
- [ ] Verificar predicción desactivada en UI/menús [S]

## O. Interpolación (RF15)

- [x] Definir interpolación de entidades remotas [M] — **Diseño: 02-Analisis.md 2.3 A1 + 03-Diseno.md 2**
- [x] Definir buffer de 100-200 ms [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir sin teleports visibles en NPCs [M] — **Diseño: 02-Analisis.md 3.5**
- [x] Documentar interpolación de animaciones (M13) [M] — **Diseño: 03-Diseno.md 2.2**
- [ ] Verificar frame budget con buffer (M61) [C]

## P. Protección contra Trampas (RF16)

- [x] Definir server-authoritative total [S] — **Diseño: 02-Analisis.md 2.5 A1**
- [x] Definir validación de posición/velocidad [M] — **Diseño: 02-Analisis.md 2.5 A1**
- [x] Definir validación de inventario/economía [M] — **Diseño: 02-Analisis.md 2.5 A1**
- [x] Definir rate limits por acción [M] — **Diseño: 03-Diseno.md 2.1**
- [x] Documentar anti-cheat SOLO por servidor (nunca cliente) [S] — **Diseño: 02-Analisis.md 2.5 A2**

## Q. Seguridad de API (RF17)

- [x] Definir HTTPS/TLS 1.3 [M] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir JWT firmado y con expiración [M] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir rate limiting por endpoint [M] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir whitelist de endpoints [S] — **Diseño: 02-Analisis.md 3.9**
- [ ] Registrar tls=1.3 en el manifiesto [S]

## R. Logs (RF18)

- [x] Definir telemetría M64 [M] — **Diseño: 03-Diseno.md 2.1**
- [x] Definir logs de eventos y errores por sesión [M] — **Diseño: 03-Diseno.md 2.1**
- [x] Definir latencia registrada por sesión [S] — **Diseño: 03-Diseno.md 2.1**
- [ ] Documentar rotación de logs (sección 18 AGENTS) [S]
- [ ] Verificar sin datos personales en logs [S]

## S. Monitorización (RF19)

- [x] Definir dashboards (CCU, latencia, errores) [M] — **Diseño: 02-Analisis.md 2.6 A1**
- [x] Definir alertas de umbrales [M] — **Diseño: 02-Analisis.md 2.6**
- [x] Definir alerta de instancia caída [S] — **Diseño: 02-Analisis.md 2.6 A1**
- [ ] Documentar métricas de sesión por región [M]
- [ ] Verificar monitorización SIN costo en v1 [S]

## T. Escalabilidad (RF20)

- [x] Definir autoscaling por región [M] — **Diseño: 02-Analisis.md 2.6 A1**
- [x] Definir 1 instancia ≈ 200 CCU [S] — **Diseño: 02-Analisis.md 2.6**
- [x] Definir autoscaling SOLO si pico >150 CCU [M] — **Diseño: 02-Analisis.md 2.6 A2**
- [ ] Documentar balanceo de conexiones [M]
- [ ] Verificar escalabilidad sin cambio de código (contrato) [S]

## U. Backups (RF21)

- [x] Definir RPO 15 min (backups M65) [M] — **Diseño: 02-Analisis.md 2.6 + 03-Diseno.md 3.1**
- [ ] Definir bucket de backups cifrado [M]
- [x] Definir backups de estado + cuentas [S] — **Diseño: 03-Diseno.md 2.1**
- [ ] Registrar rpo_min=15 en el manifiesto [S]
- [ ] Verificar backups automáticos sin intervención [S]

## V. Recuperación (RF22)

- [x] Definir RTO 2 h [M] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir failover con heartbeat 5 s [M] — **Diseño: 02-Analisis.md 2.6 A1**
- [x] Definir recuperación sin pérdida de sesión [M] — **Diseño: 03-Diseno.md 2.3 Flujo D**
- [ ] Registrar rto_horas=2 en el manifiesto [S]
- [ ] Verificar runbook de recuperación documentado [M]

## W. Costes (RF23)

- [x] Estimar instancia dedicada ($120-180/mes) [M] — **Diseño: 02-Analisis.md 4**
- [x] Estimar base de datos ($60-100/mes) [M] — **Diseño: 02-Analisis.md 4**
- [x] Estimar CDN y telemetría ($50-90/mes) [M] — **Diseño: 02-Analisis.md 4**
- [x] Calcular total mensual (~$230-370/mes) [M] — **Diseño: 02-Analisis.md 4**
- [x] Condicionar la apertura al hit >10k descargas [S] — **Diseño: 02-Analisis.md 4**

## X. Coherencia con M76

- [?] Respetar mp_contract.json como fuente de producto [S]
- [x] Respetar chat sin texto libre [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Respetar progreso individual [S] — **Diseño: 03-Diseno.md 2.3 Flujo E**
- [x] Respetar economía protegida [S] — **Diseño: 02-Analisis.md 3.7**
- [ ] Verificar hit de apertura coincidente [S]

## Y. Validación y Cierre Técnico

- [?] Entregar net_contract.json (manifiesto técnico) [M]
- [ ] Entregar validate_net_contract.gd [M]
- [ ] Verificar que v1 no abre puertos (grep) [S]
- [x] Documentar reconciliación offline→online futura [M] — **Diseño: 03-Diseno.md 4**
- [x] Documentar presupuesto de red <64 kbps/jugador [M] — **Diseño: 02-Analisis.md 2.2**

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S] — **Diseño: 04-Codigo.md Notas del Agente**
- [x] Firmar los documentos del módulo (modelo y plataforma) [S] — **Diseño: 01..04 cabecera Modelo/Plataforma**
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]
**Totales:** 130 ítems · Completados: 82 · Pendientes: 44 · No resueltos: 4.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas (post-Auditoria T-agnes 2026-10-06): 0 [x] / 4 [?] / 126 [ ] (contractos mp/net ausentes en disco).
> Las marcas no se tocaron.
