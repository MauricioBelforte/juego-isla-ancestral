**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 77: Online y Red

## 1. Visión General

M77 es el **contrato de arquitectura de red** para la FASE ONLINE futura (M76 condiciona el arranque a >10k descargas). Entregables: documentos (01-05) + `net_contract.json` (manifiesto técnico legible por máquina) + `validate_net_contract.gd` (consistencia con M76). **No hay código de red en v1.**

## 2. Arquitectura de Referencia

```
â”Œâ”€ CLIENTE (Godot 4) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
│  Input del jugador → predicción local (RF14)          │
│  Render: interpolación de entidades remotas (RF15)    │
│  Reconexión con token JWT (RF10/RF11)                 │
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                â”‚ HTTPS/WSS (TLS 1.3) + canales reliable/unreliable
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  SERVIDOR DEDICADO (autoridad total, RF1/RF16)        â”‚
â”‚  â”œâ”€â”€ Auth/API gateway (JWT, rate limit, whitelist)    â”‚
│  ├── World Sim (snapshots @ 10 Hz por área)           │
â”‚  â”œâ”€â”€ NPC Sim (M19/M35, solo visibles)                 â”‚
│  ├── Estado: inventario, economía M38, eventos M74    │
│  └── Validación anti-trampas (posición/velocidad)     │
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚              â”‚                  â”‚
  â”Œâ”€â”€â”€â”€â–¼â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”
  │  DB (PG)│   │ Telemetría │    │ Backups M65 │
  â”‚  estado â”‚   â”‚ M64+logs   â”‚    â”‚ RPO 15m/RTO â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 2.1 Servicios del contrato (futuro)

| Servicio | Responsabilidad | Escala |
|---|---|---|
| API Gateway | Auth (JWT), rate limit, whitelist de endpoints | 1 + replicas |
| World Sim | Autoridad del mundo, snapshots @ 10 Hz | 1 instancia â‰ˆ 200 CCU |
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

## 7. Lote de definiciones — M77 Online y Red (Reflection-Beam-1.0, 2026-10-22)

**L44 sin NPCs siempre activos (M49 durmientes):** QUE: NPCs fuera de área entran en estado durmiente (sin tick de IA). COMO: documentar en 03-Diseno la regla: NPC fuera del área de interés (grid M61) se pausa (process_mode = DISABLED) y se reactiva al entrar; solo NPCs visibles (M35) tick. UMBRAL: 0 NPCs activos fuera del área visible.

**L50 permisos por diseño (M76 RF10):** QUE: el servidor valida permisos por diseño (qué acciones puede hacer cada rol). COMO: documentar en 03-Diseno la matriz de permisos (jugador/invitado/moderador) y que el servidor rechaza acciones no permitidas (anti-trampa). UMBRAL: 100% de acciones con permiso definido.

**L51 undo/redo validado del invitado:** QUE: el invitado (modo multijugador futuro) puede deshacer/rehacer construcción con validación del servidor. COMO: documentar regla: undo/redo solo sobre construcciones propias del invitado, validado server-side (anti-trampa). UMBRAL: 0 undo sobre construcciones ajenas.

**L52 servidor valida catálogos (M18):** QUE: el servidor valida los catálogos de construcción (items válidos). COMO: documentar en 03-Diseno: el servidor rechaza items no presentes en el catálogo M18; cliente solo envía ids. UMBRAL: 0 items inválidos aceptados.

**L67 ítems de historia jamás transferibles (M76):** QUE: los ítems de historia (quest items) no son transferibles entre jugadores. COMO: documentar regla en 03-Diseno: ítems con flag historia=true no entran en trade/inventario compartido. UMBRAL: 0 transferencias de ítems de historia.

**L75 cola de eventos fuera de línea (reconexión):** QUE: eventos ocurridos durante desconexión se encolan y se aplican al reconectar. COMO: documentar en 03-Diseno: cola FIFO por jugador, idempotencia por event_id, aplicar al reconectar (<10s). UMBRAL: 0 eventos perdidos en reconexión.

**L76 sin eventos duplicados (idempotencia):** QUE: los eventos no se duplican (idempotencia por id). COMO: documentar regla: cada evento lleva id único; el servidor ignora ids ya procesados. UMBRAL: 0 duplicados.

**L91 sesión única por jugador:** QUE: un jugador tiene una sola sesión activa (no multi-login). COMO: documentar en 03-Diseno: el servidor invalida sesiones previas al abrir una nueva (logout forzado). UMBRAL: 0 sesiones paralelas por cuenta.

**L107 manejo de paquetes duplicados (ids):** QUE: paquetes duplicados se descartan por id. COMO: documentar regla: cada paquete lleva seq_id; el receptor descarta seq_id ya visto. UMBRAL: 0 procesamiento de duplicados.

**L108 pérdida tolerable (snapshots):** QUE: pérdida de paquetes unreliable (snapshots) es tolerable (no rompe estado). COMO: documentar en 03-Diseno: snapshots son unreliable; el cliente interpola y el siguiente snapshot corrige. UMBRAL: estado consistente tras 3 snapshots consecutivos.

**L148 rotación de logs (sección 18 AGENTS):** QUE: los logs del servidor rotan por tamaño. COMO: documentar en 03-Diseno: rotación por tamaño (MAX_LOG_SIZE) con backups en logs/rotated/, formato NN-nombre-YYYY-MM-DD.log. UMBRAL: 0 logs sin rotar > umbral.

**L156 métricas de sesión por región:** QUE: métricas de sesión agregadas por región (latencia, CCU). COMO: documentar en 03-Diseno: métricas por región (p50/p99 latencia, CCU) en dashboard; sin PII. UMBRAL: 100% de regiones con métricas.

**L164 balanceo de conexiones:** QUE: el servidor balancea conexiones entre instancias. COMO: documentar en 03-Diseno: balanceo round-robin por instancia (~200 CCU); sin cambio de código (contrato). UMBRAL: 0 instancias > 200 CCU.

**L170 bucket de backups cifrado:** QUE: los backups se guardan en bucket cifrado. COMO: documentar en 03-Diseno: bucket de backups con cifrado at-rest (AES-256) y acceso por IAM. UMBRAL: 100% de backups cifrados.

## Specs Online y Red (Beam 522)

### Verificar frame budget con buffer (M61)
- Spec: verificar frame budget con buffer (M61). Coherente con M77 (online) y M61 (rendimiento).

## Specs Online y Red (Beam 703)

### Verificar presupuesto con NPCs en el area
- Spec: verificar presupuesto con NPCs en el area. Coherente with M77 (online y red) and M61 (rendimiento).

### Verificar sin estado duplicado de construccion
- Spec: verificar sin estado duplicado de construccion. Coherente with M77 (online y red) and M17 (construccion).

### Verificar integridad del inventario (M14)
- Spec: verificar integridad del inventario (M14). Coherente with M77 (online y red) and M14 (recursos).

### Verificar economia protegida en el manifiesto
- Spec: verificar economia protegida en el manifiesto. Coherente with M77 (online y red) and M93 (balance).

### Verificar progreso individual de eventos
- Spec: verificar progreso individual de eventos. Coherente with M77 (online y red) and M74 (eventos).


## Specs Online y Red (Beam 704)

### Verificar estado critico jamas en unreliable
- Spec: verificar estado critico jamas en unreliable. Coherente with M77 (online y red) and M102 (logging).

### Verificar prediccion desactivada en UI/menus
- Spec: verificar prediccion desactivada en UI/menus. Coherente with M77 (online y red) and M53 (UI).

### Verificar sin datos personales en logs
- Spec: verificar sin datos personales en logs. Coherente with M77 (online y red) and M102 (logging).

### Verificar monitorizacion SIN costo en v1
- Spec: verificar monitorizacion SIN costo en v1. Coherente with M77 (online y red) and M61 (rendimiento).

### Verificar escalabilidad sin cambio de codigo (contrato)
- Spec: verificar escalabilidad sin cambio de codigo (contrato). Coherente with M77 (online y red) and M04 (game engine).


## Specs Online y Red (Beam 705)

### Verificar backups automaticos sin intervencion
- Spec: verificar backups automaticos sin intervencion. Coherente with M77 (online y red) and M59 (guardado).

### Verificar runbook de recuperacion documentado
- Spec: verificar runbook de recuperacion documentado. Coherente with M77 (online y red) and M102 (logging).

### Verificar hit de apertura coincidente
- Spec: verificar hit de apertura coincidente. Coherente with M77 (online y red) and M61 (rendimiento).

### Entregar validate_net_contract.gd
- Spec: entregar validate_net_contract.gd. Coherente with M77 (online y red) and M102 (logging).

### Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log
- Spec: actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log. Coherente with M77 (online y red) and AGENTS.md sec 21.


## Specs Online y Red (Beam 706)

### Verificar con verificar_checklist.py (sin alertas nuevas)
- Spec: verificar con verificar_checklist.py (sin alertas nuevas). Coherente with M77 (online y red) and AGENTS.md sec 21.9.

### Specs items degradados T226 (2026-10-26, Reflection-Beam-1.0)
- **L12 (verificar coherencia con mp_contract.json M76):** spec definida.
- **L20 (registrar p2p=false en net_contract.json):** spec definida.
- **L193 (respetar mp_contract.json como fuente de producto):** spec definida.
- **L201 (entregar net_contract.json manifiesto técnico):** spec definida.
