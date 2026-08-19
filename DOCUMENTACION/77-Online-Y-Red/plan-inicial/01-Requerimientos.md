**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 77: Online y Red

## ID del Módulo
- **Código:** M77 (CHECKLIST-GLOBAL: ID 77 — Online y Red; plan maestro: sección 76 "ONLINE Y RED")
- **Carpeta:** `DOCUMENTACION/77-Online-Y-Red/`
- **Dependencias:** M76 (Multijugador — contrato y decisión). Relaciones: M59 (Persistencia), M07 (Eventos), M13 (Animación), M16 (Construcción/Crafting), M38 (Economía), M22 (Historia), M73 (Colecciones), M61 (Rendimiento), M62 (Memoria), M64 (Logs — telemetría), M65 (Backup), M66 (Seguimiento de errores)
- **Nota:** igual que M76, este módulo queda como **contrato de arquitectura** para la FASE ONLINE futura (condicionada a hit >10k descargas según `mp_contract.json` de M76). v1 no abre red.

## 1. Problema

El plan maestro exige resolver 23 problemas de red: arquitectura cliente-servidor, P2P, servidores dedicados, sincronización (mundo, NPC, construcción, inventario, economía, eventos), reconexión, reconocimiento de sesión, latencia, pérdida de paquetes, predicción, interpolación, anti-trampas, seguridad de API, logs, monitorización, escalabilidad, backups, recuperación y costes. **En v1 no hay red (M76)**: este módulo documenta el contrato técnico que evita rediseños cuando (si) se abre la FASE ONLINE — respuestas listas, decisiones evaluadas, sin código ejecutándose.

## 2. Objetivo

Documentar la arquitectura de red de referencia (contrato): cliente-servidor con P2P evaluado y descartado para online, servidor dedicado como modelo objetivo, sincronización por snapshot + autoridad del servidor, latencia manejada con interpolación y predicción, reconexión con reconocimiento de sesión, anti-trampas server-authoritative, seguridad de API (HTTPS/TLS, rate limit), logs/monitorización (M64), escalabilidad horizontal, backups (M65) y costes estimados. Todo alineado con `mp_contract.json` (M76) y sin acoplar el núcleo (M15).

## 3. Alcance

### 3.1 Dentro del alcance
- Arquitectura de referencia: cliente-servidor (autoridad de servidor) — evaluado y elegido.
- Evaluación de P2P (descartado para online; válido solo en local M76) y servidores dedicados (elegido para online).
- Contrato de sincronización: mundo, NPC, construcción, inventario, economía, eventos.
- Reconexión y reconocimiento de sesión (token de sesión reanudable).
- Latencia: predicción + interpolación + compensación de lag (autoridad).
- Pérdida de paquetes: ACK + reenvío selectivo (reliable/unreliable channels).
- Anti-trampas: servidor autoritativo (nunca confiar en cliente), validación de estado.
- Seguridad de API: HTTPS/TLS 1.3, autenticación JWT, rate limiting, whitelist de endpoints.
- Logs, monitorización y escalabilidad: telemetría (M64), autoscaling.
- Backups y recuperación (M65): copias del estado del mundo, RPO/RTO.
- Costes: estimaciones por CCU y por servicio (M76 RF24 ampliado).
- Validación: `validate_net_contract.gd` (consistencia con mp_contract.json).

### 3.2 Fuera del alcance
- La implementación de red (bloqueada hasta FASE ONLINE — M76).
- El modo local couch: se implementa sin red (M76 define el contrato local).
- Servicios de terceros concretos (hosting): solo criterios y costes de referencia.

## 4. Restricciones

- **Contrato, no código:** sin scripts de runtime de red en v1 (cero puertos abiertos).
- **Coherente con M76:** respeta `mp_contract.json` (hit >10k descargas, economía protegida, chat sin texto libre).
- **Server-authoritative:** el servidor valida TODO (anti-trampas por diseño).
- **Cozy:** latencia tolerable (>200 ms con interpelación, sin frustración).
- **Rendimiento (M61/M62):** presupuesto de red documentado (bytes/s por jugador).
- **Validable:** `validate_net_contract.gd` sin errores.

## 5. Requisitos Funcionales (Contrato de Referencia)

| # | Requisito (plan maestro) | Decisión de contrato |
|---|---|---|
| RF1 | Arquitectura cliente-servidor | ELEGIDA para online: servidor autoritativo dedicado |
| RF2 | Evaluar P2P | Descartado para online (NAT, trampas, host offline); válido solo local (M76) |
| RF3 | Servidores dedicados | Modelo objetivo (autoscaling por región) |
| RF4 | Sincronización de mundo | Snapshot completo del estado relevante (área del jugador) @ 10 Hz |
| RF5 | Sincronización de NPC | Estado compacto (posición/animación/emoción) solo NPCs visibles (M19/M35) |
| RF6 | Sincronización de construcción | Confirmación del servidor; permisos por diseño (M76 RF10) |
| RF7 | Sincronización de inventario | Autoridad servidor; jamás se acepta inventario del cliente |
| RF8 | Sincronización de economía | Monedas M38 server-side; transferencias validadas (anti-duplicación) |
| RF9 | Sincronización de eventos | Eventos M74 replicados con timestamp; recompensas individuales (M76 RF19) |
| RF10 | Reconexión | Reanudar sesión en <10 s con token (estado servidor intacto) |
| RF11 | Reconocimiento de sesión | Token de sesión firmado (JWT corto) + renovación silenciosa |
| RF12 | Manejo de latencia | Interpolación de entidades + predicción del jugador (cliente) |
| RF13 | Pérdida de paquetes | Reliable (ACK) para estado crítico; unreliable para animaciones (M13) |
| RF14 | Predicción | Input predicho local, reconciliado con snapshot (rollback suave) |
| RF15 | Interpolación | Buffer de 100-200 ms; sin teleports visibles |
| RF16 | Anti-trampas | Server-authoritative + validación de velocidad/posición + rate limits |
| RF17 | Seguridad de API | HTTPS/TLS 1.3, JWT, rate limiting, whitelist de endpoints |
| RF18 | Logs | Telemetría M64: eventos, errores, latencia por sesión |
| RF19 | Monitorización | Dashboards (CCU, latencia, errores) con alertas |
| RF20 | Escalabilidad | Autoscaling por regiones (1 instancia ≈ 200 CCU) |
| RF21 | Backups | Estado del mundo + cuentas, RPO 15 min / RTO 2 h (M65) |
| RF22 | Recuperación | Failover de instancia sin pérdida de sesión (heartbeat 5 s) |
| RF23 | Costes | Estimación por servicio (ver 02-Analisis §4) con hit de decisión |

## 6. Criterios de Aceptación

1. La arquitectura elegida (cliente-servidor dedicado) está justificada contra P2P.
2. Los 23 puntos del plan maestro están definidos como contrato técnico.
3. El contrato respeta `mp_contract.json` de M76 (hit, economía, chat, permisos).
4. Anti-trampas por diseño: el servidor jamás confía en el cliente (RF16).
5. Latencia >200 ms sin frustración (interpolación + predicción documentadas).
6. Costes estimados por servicio con hit de decisión (>10k descargas).
7. `validate_net_contract.gd` existe y pasa sin errores.