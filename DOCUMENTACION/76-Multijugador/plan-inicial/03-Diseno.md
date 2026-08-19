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