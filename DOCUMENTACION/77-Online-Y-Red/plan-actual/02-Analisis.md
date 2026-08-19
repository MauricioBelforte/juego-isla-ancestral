**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 77: Online y Red

## 1. Análisis del Dominio

M77 hereda la decisión de M76: **online diferido, condicionado a hit**. El contrato técnico debe estar LISTO (para evitar rediseños) pero NADA implementado (cero coste en v1). Los 23 puntos del plan maestro se agrupan en 6 temas:

| Tema | Puntos | Naturaleza |
|---|---|---|
| Arquitectura | 1-3 (cliente-servidor, P2P, dedicados) | Elección de topología |
| Sincronización | 4-9 (mundo, NPC, construcción, inventario, economía, eventos) | Estado replicado |
| Conectividad | 10-15 (reconexión, sesión, latencia, paquetes, predicción, interpolación) | Calidad de experiencia |
| Seguridad | 16-17 (anti-trampas, API) | Confianza |
| Operación | 18-22 (logs, monitorización, escalabilidad, backups, recuperación) | SLA |
| Coste | 23 | Viabilidad |

## 2. Alternativas Consideradas

### 2.1 Topología (RF1-RF3)
- **A1. Cliente-servidor con servidor dedicado.** **ELEGIDA para online:** autoridad clara (anti-trampas por diseño), reconexión limpia, escalabilidad horizontal. Coste: infraestructura (acotado con autoscaling).
- **A2. P2P (host es jugador):** $0 de servidores pero NAT traversal, host offline = partida muerta, trampas fáciles (host ve todo). Descartado para online — el cozy NO tolera "el host se fue". Válido SOLO en local (M76, sin red).
- **A3. Peer-authoritative parcial:** híbrido complejo, sin beneficio real en este género. Rechazado.

### 2.2 Sincronización (RF4-RF9)
- **A1. Snapshot del estado relevante por área @ 10 Hz + autoridad del servidor.** **ELEGIDA:** simple, determinista, con interpolación client-side. Bytes/s acotados: estado compacto por entidad (posición 3 floats, rotación quaternion, estado enum, timestamp) ≈ 50-80 B/entidad/snapshot; presupuesto objetivo < 64 kbps por jugador.
- **A2. State synchronization (deltas por entidad):** ahorra bytes pero complejidad alta; innecesario para <50 entidades visibles. Rechazada (puede adoptarse en fase 2 de MP si se mide el presupuesto).

### 2.3 Latencia (RF12-RF15)
- **A1. Interpolación (buffer 100-200 ms) + predicción del jugador con reconciliación por snapshot.** **ELEGIDA:** estándar de la industria para moverse agradable con latencia.
- **A2. Sin predicción (input-lag puro):** intolerable >150 ms. Rechazada.
- **A3. Rollback netcode (estilo fighting):** sobre-ingeniería para un cozy. Rechazada; la reconciliación por snapshot es suficiente (movimiento no competitivo).

### 2.4 Reconexión (RF10-RF11)
- **A1. Token de sesión JWT corto (15 min) + renovación silenciosa; estado del mundo en servidor.** **ELEGIDA:** reconexión <10 s, sin pérdida de progreso en sesión.
- **A2. Sesión por IP (sin token):** inseguro y frágil. Rechazada.

### 2.5 Anti-trampas (RF16)
- **A1. Server-authoritative total:** el servidor valida posición (velocidad máxima), inventario, economía y eventos. **ELEGIDA.**
- **A2. Anti-cheat client-side (detección en cliente):** juega contra el propio jugador; coste alto. Solo telemetría opcional (M64), nunca autoridad. Rechazada como mecanismo.

### 2.6 Operación (RF18-RF22)
- **A1. Telemetría M64 + dashboards + autoscaling por región (1 instancia ≈ 200 CCU) + backups M65 (RPO 15 min / RTO 2 h) + failover con heartbeat 5 s.** **ELEGIDA:** SLA realista sin sobre-diseño.
- **A2. Servidor único (monolito sin autoescala):** suficiente en early access; el contrato exige autoscaling SOLO si CCU pico >150. Documentado como fase 1/2.

## 3. Decisiones Técnicas (Contrato)

1. **Topología:** cliente-servidor dedicado (autoscaling); P2P solo local (M76).
2. **Autoridad:** 100% servidor (anti-trampas por diseño, RF16).
3. **Snapshot @ 10 Hz** del área del jugador (world grid por isla M27/M61); NPCs solo visibles (M35/M19).
4. **Canales:** reliable (ACK) para estado crítico (inventario, economía, construcción); unreliable para animaciones/emotes (M13/M44).
5. **Latencia:** buffer de interpolación 100-200 ms + predicción de input del jugador; reconciliación suave (sin teleports).
6. **Reconexión:** token JWT 15 min renovable; sesión servidor reanudable <10 s.
7. **Economía (M38) y colecciones (M73):** server-side; transferencias validadas contra duplicados (anti-trampa y anti-griefing M76).
8. **Eventos (M74):** replicados con timestamp servidor; recompensas por jugador (progreso individual M76).
9. **Seguridad API:** HTTPS/TLS 1.3, JWT firmado, rate limiting por endpoint, whitelist.
10. **Costes:** estimación por servicio (Tabla 4.1) con hit >10k descargas antes de abrir.

## 4. Estimación de Costes (RF23, referencia)

| Servicio | Estimación | Nota |
|---|---|---|
| Instancia dedicada (8 vCPU/16 GB) | $120-180/mes | ≈ 200 CCU por instancia |
| Base de datos (PostgreSQL gestionado) | $60-100/mes | Estado de mundo + cuentas |
| Objetos/asset serving (CDN) | $20-40/mes | Parches, texturas |
| Monitoring + logs (M64) | $30-50/mes | Telemetría, dashboards |
| **Total mensual (fase 1)** | **~$230-370/mes** | Sin autoscaling |
| Autoscaling (pico >150 CCU) | +$120-180/instancia | Por instancia activada |

**Regla:** el online NO se abre hasta superar 10k descargas (mp_contract.json M76) y aprobar este presupuesto.

## 5. Conclusiones del Análisis

- **Cliente-servidor dedicado** es la única topología coherente con el cozy (reconexión, anti-trampas, permisos).
- **Snapshot + interpolación + predicción** dan latencia agradable con presupuesto de red bajo (<64 kbps/jugador).
- **Anti-trampas por autoridad** (no por cliente) es gratis y robusto.
- El **coste es acotado y condicionado**: ~$230-370/mes solo si el hit lo justifica.
- El contrato NO toca el núcleo single-player (M15): se implementa como capa nueva (M77-MP) cuando se abra la fase.