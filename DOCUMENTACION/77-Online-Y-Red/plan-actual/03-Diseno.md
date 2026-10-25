**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 77: Online y Red

## 1. VisiÃ³n General

M77 es el **contrato de arquitectura de red** para la FASE ONLINE futura (M76 condiciona el arranque a >10k descargas). Entregables: documentos (01-05) + `net_contract.json` (manifiesto tÃ©cnico legible por mÃ¡quina) + `validate_net_contract.gd` (consistencia con M76). **No hay cÃ³digo de red en v1.**

## 2. Arquitectura de Referencia

```
â”Œâ”€ CLIENTE (Godot 4) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Input del jugador â†’ predicciÃ³n local (RF14)          â”‚
â”‚  Render: interpolaciÃ³n de entidades remotas (RF15)    â”‚
â”‚  ReconexiÃ³n con token JWT (RF10/RF11)                 â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                â”‚ HTTPS/WSS (TLS 1.3) + canales reliable/unreliable
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  SERVIDOR DEDICADO (autoridad total, RF1/RF16)        â”‚
â”‚  â”œâ”€â”€ Auth/API gateway (JWT, rate limit, whitelist)    â”‚
â”‚  â”œâ”€â”€ World Sim (snapshots @ 10 Hz por Ã¡rea)           â”‚
â”‚  â”œâ”€â”€ NPC Sim (M19/M35, solo visibles)                 â”‚
â”‚  â”œâ”€â”€ Estado: inventario, economÃ­a M38, eventos M74    â”‚
â”‚  â””â”€â”€ ValidaciÃ³n anti-trampas (posiciÃ³n/velocidad)     â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚              â”‚                  â”‚
  â”Œâ”€â”€â”€â”€â–¼â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”
  â”‚  DB (PG)â”‚   â”‚ TelemetrÃ­a â”‚    â”‚ Backups M65 â”‚
  â”‚  estado â”‚   â”‚ M64+logs   â”‚    â”‚ RPO 15m/RTO â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 2.1 Servicios del contrato (futuro)

| Servicio | Responsabilidad | Escala |
|---|---|---|
| API Gateway | Auth (JWT), rate limit, whitelist de endpoints | 1 + replicas |
| World Sim | Autoridad del mundo, snapshots @ 10 Hz | 1 instancia â‰ˆ 200 CCU |
| DB | Estado de mundo + cuentas + economÃ­as | PostgreSQL gestionado |
| TelemetrÃ­a (M64) | Logs, latencia, errores, dashboards | Streaming + almacenamiento |
| Backups (M65) | Estado + cuentas, RPO 15 min | Cron + bucket |

### 2.2 Protocolo de mensajes (contrato)

| Canal | Tipo | Mensajes |
|---|---|---|
| Reliable (ACK + reenvÃ­o) | `WebSocket` (TCP) | input confirmado, inventario, economÃ­a, construcciÃ³n, eventos |
| Unreliable (UDP) | `WebRTC`/DTLS | snapshots de entidades, animaciones (M13), emotes (M44) |

Frecuencias: snapshots de entidades 10 Hz; estado crÃ­tico bajo demanda + confirmaciÃ³n.

### 2.3 Flujos principales (futuros)

**Flujo A â€” ConexiÃ³n:** jugador â†’ API Gateway (HTTPS) â†’ login/guest token (JWT 15 min) â†’ WebSocket al World Sim con token â†’ suscripciÃ³n al Ã¡rea (isla M27, grid M61).

**Flujo B â€” Jugada:** input â†’ predicciÃ³n local â†’ servidor valida (anti-trampa) â†’ snapshot del Ã¡rea @ 10 Hz â†’ cliente interpola.

**Flujo C â€” EconomÃ­a (M38):** acciÃ³n (pesca M34, venta) â†’ servidor resuelve (monedas server-side) â†’ confirmaciÃ³n reliable â†’ UI M44.

**Flujo D â€” ReconexiÃ³n:** caÃ­da â†’ JWT renovado â†’ re-suscripciÃ³n â†’ estado servidor intacto (<10 s).

**Flujo E â€” Evento (M74):** timestamp servidor â†’ replicado a jugadores del Ã¡rea â†’ recompensas individuales (M76 RF19).

## 3. Estructura de Datos

### 3.1 `net_contract.json` â€” Manifiesto tÃ©cnico

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

### 3.2 `validate_net_contract.gd` â€” ValidaciÃ³n

| ValidaciÃ³n | CondiciÃ³n |
|---|---|
| Coherencia M76 | `topologia` == "cliente-servidor-dedicado" y `p2p` == false (salvo local) |
| Chat | `chat_texto_libre` == false (cozy, M76 RF14) |
| Presupuesto | `presupuesto_kbps_por_jugador` <= 64 |
| SesiÃ³n | `reconexion_segundos` <= 10 |
| Backups | `rpo_min` <= 15 y `rto_horas` <= 2 |
| Hit | `hit_apertura_downloads` == mp_contract.online_hit |

## 4. Persistencia (M59/M65)

- El estado de mundo online vive en el servidor (DB); el save local (M59) sigue siendo la fuente single-player.
- Backups (M65): RPO 15 min (bucket), RTO 2 h (failover con heartbeat 5 s).
- MigraciÃ³n (M60): si un perfil offline se conecta, el servidor reconcilia con regla "el mundo del servidor gana para multi; el local gana para single" â€” documentado como decisiÃ³n (futura).

## 5. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | Rol |
|---|---|
| M76 | Decide cuÃ¡ndo (hit) y cÃ³mo (contrato producto); fuente `mp_contract.json` |
| M59/M60 | Save local intacto; reconciliaciÃ³n futura |
| M07 | Eventos del dominio replicados por red |
| M38 | EconomÃ­a server-side (anti-duplicaciÃ³n) |
| M73 | Colecciones: progreso individual sincronizado (nunca compartido) |
| M74 | Eventos con timestamp servidor |
| M13/M44 | Animaciones/emotes en canal unreliable |
| M61/M62 | Presupuesto de red y memoria del buffer |
| M64 | TelemetrÃ­a y monitorizaciÃ³n |
| M65 | Backups y recuperaciÃ³n |

## 6. Impacto en Rendimiento (M61/M62)

- v1: **cero** (sin red).
- FASE ONLINE: presupuesto <64 kbps por jugador; memoria del buffer de interpolaciÃ³n acotada (M62); snapshots solo del Ã¡rea visible (grid M61); NPCs solo visibles (M35). Frame budget intacto (la red nunca corre en el hilo de render â€” Godot `MultiplayerAPI` async).

## 7. Lote de definiciones â€” M77 Online y Red (Reflection-Beam-1.0, 2026-10-22)

**L44 sin NPCs siempre activos (M49 durmientes):** QUE: NPCs fuera de Ã¡rea entran en estado durmiente (sin tick de IA). COMO: documentar en 03-Diseno la regla: NPC fuera del Ã¡rea de interÃ©s (grid M61) se pausa (process_mode = DISABLED) y se reactiva al entrar; solo NPCs visibles (M35) tick. UMBRAL: 0 NPCs activos fuera del Ã¡rea visible.

**L50 permisos por diseÃ±o (M76 RF10):** QUE: el servidor valida permisos por diseÃ±o (quÃ© acciones puede hacer cada rol). COMO: documentar en 03-Diseno la matriz de permisos (jugador/invitado/moderador) y que el servidor rechaza acciones no permitidas (anti-trampa). UMBRAL: 100% de acciones con permiso definido.

**L51 undo/redo validado del invitado:** QUE: el invitado (modo multijugador futuro) puede deshacer/rehacer construcciÃ³n con validaciÃ³n del servidor. COMO: documentar regla: undo/redo solo sobre construcciones propias del invitado, validado server-side (anti-trampa). UMBRAL: 0 undo sobre construcciones ajenas.

**L52 servidor valida catÃ¡logos (M18):** QUE: el servidor valida los catÃ¡logos de construcciÃ³n (items vÃ¡lidos). COMO: documentar en 03-Diseno: el servidor rechaza items no presentes en el catÃ¡logo M18; cliente solo envÃ­a ids. UMBRAL: 0 items invÃ¡lidos aceptados.

**L67 Ã­tems de historia jamÃ¡s transferibles (M76):** QUE: los Ã­tems de historia (quest items) no son transferibles entre jugadores. COMO: documentar regla en 03-Diseno: Ã­tems con flag historia=true no entran en trade/inventario compartido. UMBRAL: 0 transferencias de Ã­tems de historia.

**L75 cola de eventos fuera de lÃ­nea (reconexiÃ³n):** QUE: eventos ocurridos durante desconexiÃ³n se encolan y se aplican al reconectar. COMO: documentar en 03-Diseno: cola FIFO por jugador, idempotencia por event_id, aplicar al reconectar (<10s). UMBRAL: 0 eventos perdidos en reconexiÃ³n.

**L76 sin eventos duplicados (idempotencia):** QUE: los eventos no se duplican (idempotencia por id). COMO: documentar regla: cada evento lleva id Ãºnico; el servidor ignora ids ya procesados. UMBRAL: 0 duplicados.

**L91 sesiÃ³n Ãºnica por jugador:** QUE: un jugador tiene una sola sesiÃ³n activa (no multi-login). COMO: documentar en 03-Diseno: el servidor invalida sesiones previas al abrir una nueva (logout forzado). UMBRAL: 0 sesiones paralelas por cuenta.

**L107 manejo de paquetes duplicados (ids):** QUE: paquetes duplicados se descartan por id. COMO: documentar regla: cada paquete lleva seq_id; el receptor descarta seq_id ya visto. UMBRAL: 0 procesamiento de duplicados.

**L108 pÃ©rdida tolerable (snapshots):** QUE: pÃ©rdida de paquetes unreliable (snapshots) es tolerable (no rompe estado). COMO: documentar en 03-Diseno: snapshots son unreliable; el cliente interpola y el siguiente snapshot corrige. UMBRAL: estado consistente tras 3 snapshots consecutivos.

**L148 rotaciÃ³n de logs (secciÃ³n 18 AGENTS):** QUE: los logs del servidor rotan por tamaÃ±o. COMO: documentar en 03-Diseno: rotaciÃ³n por tamaÃ±o (MAX_LOG_SIZE) con backups en logs/rotated/, formato NN-nombre-YYYY-MM-DD.log. UMBRAL: 0 logs sin rotar > umbral.

**L156 mÃ©tricas de sesiÃ³n por regiÃ³n:** QUE: mÃ©tricas de sesiÃ³n agregadas por regiÃ³n (latencia, CCU). COMO: documentar en 03-Diseno: mÃ©tricas por regiÃ³n (p50/p99 latencia, CCU) en dashboard; sin PII. UMBRAL: 100% de regiones con mÃ©tricas.

**L164 balanceo de conexiones:** QUE: el servidor balancea conexiones entre instancias. COMO: documentar en 03-Diseno: balanceo round-robin por instancia (~200 CCU); sin cambio de cÃ³digo (contrato). UMBRAL: 0 instancias > 200 CCU.

**L170 bucket de backups cifrado:** QUE: los backups se guardan en bucket cifrado. COMO: documentar en 03-Diseno: bucket de backups con cifrado at-rest (AES-256) y acceso por IAM. UMBRAL: 100% de backups cifrados.

## Specs Online y Red (Beam 522)

### Verificar frame budget con buffer (M61)
- Spec: verificar frame budget con buffer (M61). Coherente con M77 (online) y M61 (rendimiento).