**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 76: Multijugador

## 1. Visión General

M76 define el **contrato de producto del multijugador futuro** y la decisión de v1 (single-player). No se implementa red en v1: el módulo entrega documentación de contrato + `validate_mp_contract.gd` (verificador de consistencia del contrato) + un manifiesto de decisiones consultable por el equipo. La puerta de entrada futura es el **modo local cooperativo (couch)**; el online queda condicionado a hit de métricas.

## 2. Arquitectura (Contrato, no implementación)

```
┌─ NÚCLEO (v1, sin dependencias de M76) ──────────────┐
│  Juego single-player: M22, M59, M38, M73, M74...   │
└───────────────────▲─────────────────────────────────┘
                    │ (cero refs — regla M15)
┌───────────────────┴─────────────────────────────────┐
│  M76 CONTRATO MP (futuro, documentado y bloqueado)  │
│                                                      │
│  FASE LOCAL (primer paso):                           │
│    - 2 jugadores, mismo dispositivo (split-screen)   │
│    - Host autoritativo (simula mundo; invite inputs) │
│    - Progreso individual (M59 sin tocar formato)     │
│    - Permisos: invitado sin zona destructiva         │
│                                                      │
│  FASE ONLINE (condicionada a hit de métricas):       │
│    - M77 Online y Red (arquitectura cliente-serv.)   │
│    - Cuentas opcionales, código de visita con expira  │
│    - Chat: frases rápidas + emotes (sin texto libre) │
│    - Reporte si se habilita texto libre              │
└──────────────────────────────────────────────────────┘
```

### 2.1 Entregables del contrato

| Entregable | Contenido | Nota |
|---|---|---|
| `01-Requerimientos.md` | Los 25 puntos del plan maestro → tabla RF con decisión | Documento |
| `02-Analisis.md` | Alternativas, costes, riesgos | Documento |
| `03-Diseno.md` | Este contrato de arquitectura MP y manifiesto | Documento |
| `validate_mp_contract.gd` | Verificador: el núcleo no referencia M76; el contrato es coherente | Script editor |
| Manifiesto `mp_contract.json` | Decisiones clave en formato máquina (para build tooling futuro) | Datos |

### 2.2 Estados del módulo

```
DECIDIDO (v1: single-player; MP futuro)
├── CONTRATO_LOCAL  → si producto anuncia MP: primero local
├── CONTRATO_ONLINE → condicionado a hit (>10k descargas)
└── BLOQUEADO       → no se implementa hasta decisión del roadmap
```

El estado real del módulo en CHECKLIST-GLOBAL es `🟢 Disponible` con contrato completo; la implementación queda `BLOQUEADO` por decisión de producto (documentado en Notas).

### 2.3 Flujos del contrato

**Flujo A — Decisión de v1 (hoy):** el manifiesto fija `mp_v1: "single"`. Ningún sistema nuevo puede crear dependencias de M76 (check en `validate_mp_contract.gd`).

**Flujo B — Apertura de FASE LOCAL (futuro):** producto decide → el contrato obliga: (1) probar frame budget split-screen 60 FPS (M61) antes de aprobar feature; (2) crear `mp_local.gd` nuevo (M15: no tocar tranquilo single); (3) runs `validate_mp_contract.gd`.

**Flujo C — Apertura de FASE ONLINE (futuro):** métricas >10k descargas → abrir M77 como proyecto (arquitectura cliente-servidor), con presupuesto aprobado (costes RF24 del 02-Analisis).

## 3. Estructura de Datos

### 3.1 `mp_contract.json` — Manifiesto de decisiones

```json
{
  "mp_v1": "single",
  "mp_future": "local_first",
  "players_local": 2,
  "players_online_max": 4,
  "authority": "host",
  "persistence": "individual (invitado = perfil local)",
  "anti_griefing": "permisos por diseño: invitado sin zona destructiva",
  "economia": "solo decoración; nunca items de historia (M22/M23)",
  "chat": "frases rapidas + emotes; sin texto libre",
  "online_hit": "downloads > 10000",
  "servidores_v1": false,
  "coste_estimado_mensual": 0
}
```

### 3.2 `validate_mp_contract.gd` — Validación

| Validación | Condición |
|---|---|
| Núcleo limpio | Cero referencias a `M76`/`mp_` en scripts v1 (grep) |
| Manifiesto estable | `mp_v1 == "single"` y campos `future` coherentes |
| Autoridad | `authority == "host"` (local) / `"server"` (online, M77) |
| Economía | El contrato nunca transfiere `item_story:*` |
| Chat | `chat == "frases rapidas"` (sin texto libre) |

## 4. Persistencia (M59)

- Los saves **no cambian de formato**: invitado = perfil local (M92) en el mismo slot de preferencias.
- Nunca se persiste una "isla compartida": el mundo pertenece al host (anti-griefing por diseño + cero conflictos de escritura).

## 5. Integración con otros módulos

| Módulo | Rol |
|---|---|
| M77 | Arquitectura online futura (depende de este contrato) |
| M59 | Persistencia individual intacta |
| M15 | Regla "no tocar lo que funciona": MP futuro = scripts nuevos |
| M61/M62 | Frame budget split-screen antes de aprobar; sin duplicar escena |
| M38 | Economía protegida (solo decoración) |
| M22/M23 | Ítems de historia jamás transferibles |
| M92 | Perfiles locales para el invitado |
| M44 | Emotes como notificaciones express |

## 6. Impacto en Rendimiento (M61)

- En v1: **cero impacto** (no hay red ni segundo jugador).
- FASE LOCAL futura: 2 viewports (GPU cost ~1.6-1.9× a 1080p, según Profiler M116); el contrato exige probar 60 FPS en la consola objetivo antes de aprobar la feature.
- FASE ONLINE futura: presupuesto de red documentado en M77; aquí solo el hit de decisión.

## 7. Contrato MP Futuro - Definiciones (cierre de alcance, 2026-10-16)

Definiciones de producto del contrato MP futuro. Los items tecnicos de red
(tick real, NAT, cifrado de transporte, reconexion) son de M77: aqui se fija la
decision de producto y la referencia, no la implementacion.

### 7.1 Migracion de host
- FASE LOCAL (split-screen): no hay sesiones remotas; si el host cierra, la
  partida termina (no aplica migracion).
- FASE ONLINE: migracion/reconexion de host es contrato de M77 (dueno).

### 7.2 Tick rate de referencia
- Rango contractual del estado de mundo en online: 10-20 Hz.
- Referencia: M77 ya documenta snapshots @ 10 Hz (M77 05-Checklist L11/L33 [x]).
  M76 fija el rango; M77 la frecuencia exacta.

### 7.3 Interpolacion de animaciones del invitado
- M77 ya lo documenta (M77 05-Checklist L123 [x]): interpolacion de entidades
  remotas con buffer 100-200 ms (M77 L96/L100). Referencia cruzada, no se duplica.

### 7.4 Logros e historia de la isla ajena
- El invitado NUNCA desbloquea logros de la isla ajena (M72).
- El invitado NUNCA avanza la historia ajena (M22).
- Regla dura del contrato (RF19/RF20): progreso siempre individual.

### 7.5 Lista de amigos
- Feature de FASE ONLINE, dueno M77. En v1 y en FASE LOCAL no existe.

### 7.6 Nombre de jugador
- Editable: perfil local (M92), sin cuentas en v1 (RF12).

### 7.7 Set base de emotes
- hola, gracias, risa, enojo (4 emotes base). Rueda de emotes (M44).

### 7.8 Animaciones de emotes
- Emotes = notificaciones express (M44) + animacion del avatar (M13).
- En local NO requieren red (offline-first, M59).

### 7.9 Catalogo de muebles compartido
- Solo lectura para el invitado (nunca catalogo editable por el visitante).

### 7.10 Undo/redo del invitado
- El invitado tiene undo de SUS acciones en su zona asignada (anti-error).
- El host tiene rollback global de la sesion (ver 7.17).

### 7.11 Solucion compartida de puzzles sin estado duplicado
- Host autoritativo: el host mantiene el estado canonico del puzzle;
  el invitado envia inputs y ve el estado (sin duplicar estado, 2.3 A1).

### 7.12 Puzzles con 1 solucion
- Los puzzles cooperativos (M24) tienen solucion unica y determinista;
  nada de puzzles rojos por estado duplicado.

### 7.13 Eventos (M74)
- Se viven juntos (misma isla, misma sesion) pero cuentan individual
  (progreso individual RF20).

### 7.14 Sin exposicion de datos locales
- v1 sin red: los datos locales (user://) nunca se exponen.
- Codigo de visita futuro: expira y no autoriza lectura de datos del host.

### 7.15 Cifrado de transporte (futuro)
- FASE ONLINE exige TLS en toda comunicacion (dueno M77: seguridad de API
  HTTPS/TLS, rate limit). Contrato de producto, no implementacion.

### 7.16 Respaldo del mundo del host
- Backups de M59: ante incidente el host restaura SU mundo.
- El invitado nunca persiste en la isla del host (2.2 A1).

### 7.17 Rollback de cambios del invitado
- El host puede revertir los cambios del invitado en su isla
  (bitacora de acciones por sesion de visita).

### 7.18 Baneo de visitas
- El host puede banear visitas (lista local de excluidos).

### 7.19 Privacidad de cuentas futuras
- Si se habilitan cuentas (FASE ONLINE, M77): politica de privacidad
  obligatoria antes del lanzamiento online (dueno M77).

> **Limite con M77 (coordinar, no pisar):** todo lo tecnico de red
> (tick real, NAT traversal, reconciliacion, cifrado, reconexion, cuentas,
> amigos online) pertenece a M77. M76 define la decision de producto y
> este contrato; el manifiesto mp_contract.json es la fuente compartida.