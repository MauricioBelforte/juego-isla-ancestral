**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 77: Online y Red

## 1. Visión General

M77 es el **contrato de arquitectura de red** para la FASE ONLINE futura (M76 condiciona el arranque a >10k descargas). Entregables: documentos (01-05) + `net_contract.json` (manifiesto técnico legible por máquina) + `validate_net_contract.gd` (consistencia con M76). **No hay código de red en v1.**

## 2. Arquitectura de Referencia

```
┌─ CLIENTE (Godot 4) ──────────────────────────────────┐
│  Input del jugador → predicción local (RF14)          │
│  Render: interpolación de entidades remotas (RF15)    │
│  Reconexión con token JWT (RF10/RF11)                 │
└───────────────┬───────────────────────────────────────┘
                │ HTTPS/WSS (TLS 1.3) + canales reliable/unreliable
┌───────────────▼───────────────────────────────────────┐
│  SERVIDOR DEDICADO (autoridad total, RF1/RF16)        │
│  ├── Auth/API gateway (JWT, rate limit, whitelist)    │
│  ├── World Sim (snapshots @ 10 Hz por área)           │
│  ├── NPC Sim (M19/M35, solo visibles)                 │
│  ├── Estado: inventario, economía M38, eventos M74    │
│  └── Validación anti-trampas (posición/velocidad)     │
└──────┬───────────────┬──────────────────┬─────────────┘
       │              │                  │
  ┌────▼────┐   ┌─────▼──────┐    ┌──────▼──────┐
  │  DB (PG)│   │ Telemetría │    │ Backups M65 │
  │  estado │   │ M64+logs   │    │ RPO 15m/RTO │
  └─────────┘   └────────────┘    └─────────────┘
```

### 2.1 Servicios del contrato (futuro)

| Servicio | Responsabilidad | Escala |
|---|---|---|
| API Gateway | Auth (JWT), rate limit, whitelist de endpoints | 1 + replicas |
| World Sim | Autoridad del mundo, snapshots @ 10 Hz | 1 instancia ≈ 200 CCU |
| DB | Estado de mundo + cuentas + economías | PostgreSQL gestionado |
| Telemetría (M64) | Logs, latencia, errores, dashboards | Streaming + almacenamiento |
| Backups (M65) | Estado + cuentas, RPO 15 min | Cron + bucket |

### 2.2 Protocolo de mensajes (contrato)

| Canal | Tipo | Mensajes |
|---|---|---|
| Reliable (ACK + reenvío) | `WebSocket` (TCP) | input confirmado, inventario, economía, construcción, eventos |
| Unreliable (UDP) | `WebRTC`/DTLS | snapshots de entidades, animaciones (M13), emotes (M44) |

Frecuencias: snapshots de entidades 10 Hz; estado crítico bajo demanda + confirmación.

### 2.3 Flujos principales (futuros)

**Flujo A — Conexión:** jugador → API Gateway (HTTPS) → login/guest token (JWT 15 min) → WebSocket al World Sim con token → suscripción al área (isla M27, grid M61).

**Flujo B — Jugada:** input → predicción local → servidor valida (anti-trampa) → snapshot del área @ 10 Hz → cliente interpola.

**Flujo C — Economía (M38):** acción (pesca M34, venta) → servidor resuelve (monedas server-side) → confirmación reliable → UI M44.

**Flujo D — Reconexión:** caída → JWT renovado → re-suscripción → estado servidor intacto (<10 s).

**Flujo E — Evento (M74):** timestamp servidor → replicado a jugadores del área → recompensas individuales (M76 RF19).

## 3. Estructura de Datos

### 3.1 `net_contract.json` — Manifiesto técnico

```json
{
  "topologia": "cliente-servidor-dedicado",
  "p2p": false,
  "autoridad": "servidor",
  "snapshot_hz": 10,
  "buffer_interpolacion_ms": 150,
  "prediccion": true,
  "presupuesto_kbps_por_jugador": 64,
  "token_jwt_min": 15,
  "reconexion_segundos": 10,
  "tls": "1.3",
  "ccu_por_instancia": 200,
  "rpo_min": 15,
  "rto_horas": 2,
  "chat_texto_libre": false,
  "hit_apertura_downloads": 10000
}
```

### 3.2 `validate_net_contract.gd` — Validación

| Validación | Condición |
|---|---|
| Coherencia M76 | `topologia` == "cliente-servidor-dedicado" y `p2p` == false (salvo local) |
| Chat | `chat_texto_libre` == false (cozy, M76 RF14) |
| Presupuesto | `presupuesto_kbps_por_jugador` <= 64 |
| Sesión | `reconexion_segundos` <= 10 |
| Backups | `rpo_min` <= 15 y `rto_horas` <= 2 |
| Hit | `hit_apertura_downloads` == mp_contract.online_hit |

## 4. Persistencia (M59/M65)

- El estado de mundo online vive en el servidor (DB); el save local (M59) sigue siendo la fuente single-player.
- Backups (M65): RPO 15 min (bucket), RTO 2 h (failover con heartbeat 5 s).
- Migración (M60): si un perfil offline se conecta, el servidor reconcilia con regla "el mundo del servidor gana para multi; el local gana para single" — documentado como decisión (futura).

## 5. Integración con otros módulos

| Módulo | Rol |
|---|---|
| M76 | Decide cuándo (hit) y cómo (contrato producto); fuente `mp_contract.json` |
| M59/M60 | Save local intacto; reconciliación futura |
| M07 | Eventos del dominio replicados por red |
| M38 | Economía server-side (anti-duplicación) |
| M73 | Colecciones: progreso individual sincronizado (nunca compartido) |
| M74 | Eventos con timestamp servidor |
| M13/M44 | Animaciones/emotes en canal unreliable |
| M61/M62 | Presupuesto de red y memoria del buffer |
| M64 | Telemetría y monitorización |
| M65 | Backups y recuperación |

## 6. Impacto en Rendimiento (M61/M62)

- v1: **cero** (sin red).
- FASE ONLINE: presupuesto <64 kbps por jugador; memoria del buffer de interpolación acotada (M62); snapshots solo del área visible (grid M61); NPCs solo visibles (M35). Frame budget intacto (la red nunca corre en el hilo de render — Godot `MultiplayerAPI` async).