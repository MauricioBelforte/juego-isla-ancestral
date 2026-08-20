**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 140: Alpha

## 1. Arquitectura de la fase

### 1.1 Capas (M07, sobre la base de M139)

```
[UI Layer]        Menú · HUD por sistema · Diario (M55) · Diálogos (M21) · Mapa (M54) · Colecciones (M37/M73)
[Gameplay Managers] SesionMaster · HistoriaMaster (M22) · SelloManager (M153) · Almanaque (M29-M32) ·
                    TiendaManager · ConstruccionManager · AmistadManager (M20) · ViajeManager · TemploManager
[World Services]  MundoVoxel (M08) · BiomaManager · StreamingZonas (M63) · GuardadoV3 (M59/M60) ·
                  AudioManager (M41-M44) · MetricsHub (M104/M105) · BalanceService (M93)
[Infra]           Godot 4 · Voxel Tools · Pipeline M108 · CI (M118): compila + simulación + gate de rendimiento
```

- Lo nuevo de Alpha: `HistoriaMaster` y `SelloManager` orquestan la narrativa sin acoplar a las misiones individuales (contrato `ICondicionDeSello`).
- `Almanaque` unifica clima (M32), calendario (M29), estaciones y eventos base (M74) como servicio único consumido por el resto.

### 1.2 Director de acto (H1)

```
Sello 1 (Brisa, ya en Pre-Alpha) → sin prerequisitos
Sello 2 (profundidades)          → prerequisito: 2 amistades nivel 3 (M20) + carta de Elysia (M22)
Sello 3 (ceniza)                 → prerequisito: 1 templo extra + 15 coleccionables (M73)
Sello 4 (flora)                  → prerequisito: dominio agrícola (1 estación completa + museo ítem 1, M33/M37)
Sello 5 (eco)                    → prerequisito: 3 viajes distintos + evento estacional 1 (M28/M74)
Sello 6 (aurora)                 → prerequisito: sellos 1-5 + Set de Rincones (M22/M153)
Cierre: epílogo (Acto 3) en el faro (M153)
```

- Cada prerequisito se modela como `ICondicionDeSello` con estado persistido en save v3 (flags globales M60).
- Los prerequisitos se muestran al jugador como *pistas suaves en el diario* (M55), sin romper misterio (M153).

### 1.3 Flujo de sesión extendido

```
Menú → mundo → Aurora u otra isla → rutina diaria (juego libre) → hitos de sistemas
→ avance de prerequisitos → desbloqueo de Sello → templo → artefacto → epílogo (acto 3)
```

## 2. Diseño de sistemas integrados

### 2.1 Integraciones cruzadas (RF3)

| Integración | Cadena |
|---|---|
| Amistad → Economía | Mayor amistad con tiendero ⇒ 5-10% mejor precio y ítems exclusivos (M20/M39/M93) |
| Clima → Cultivos | Lluvia acelera riego 20%; helada amenaza cultivos de invierno (M32/M33) |
| Tiempo/IA | Calendario dispara rutinas especiales (fiesta del puerto cada 7 días, M29/M64/M74) |
| Construcción → Amistad | Regalar muebles fabricados sube amistad 25% más que ítems comprados (M17/M20) |
| Viajes → Mundo | Viajar a isla con estación avanzada adelanta su ciclo vegetal (M28/M33) |
| Templar → Artefactos | Cada Sello desbloquea un artefacto con efecto pasivo (M13/M71) |

### 2.2 Progresión completa (M71)

```
Herramientas (M13): 5 niveles por herramienta (madera→bronce→hierro→plata→aurora)
Habilidades (M71): pesca/agricultura/minería/cocina/build con XP y ventajas selectivas
Colecciones (M73): 8 categorías × 10 ítems; museo (M37) con recompensas
Artefactos (M13/M26): 6 pasivos (uno por sello) + activos de templo
```

### 2.3 Contenido (RF5)

| Bloque | Cantidad objetivo | Notas |
|---|---|---|
| Islas jugables | 4 de 6 (Aurora, Coral, Bosque de Ceniza, Isla de la Flora) | 2 restantes en Beta (M141) |
| Templas jugables | 3 de 6 (Brisa ✅, Profundidades, Ceniza) | 3 restantes en Beta |
| NPC totales | 24-30 con rutinas | 6-8 por isla |
| Misiones secundarias | 30+ | Incluidos las cadenas de amistad |
| Coleccionables | 80 (de 100) | Resto en Beta |
| Eventos estacionales base | 4 (1 por estación) | M74 |
| Recetario de cocina (M16) | 60+ | Con ítems de todas las islas |
| Conjunto de audio | Por zona completa | M41-M44 |

### 2.4 Balance (RF4) — triple red

1. **Simulación (CI):** escenarios jugador productivo/completista/admin → 40 h sin alertas de M93.
2. **Playtest dirigido (M114):** 6-8 sesiones por mes con data de oro/hora y curvas de progreso.
3. **Ajuste en tiempo de dato (JSON):** `data/balance/*.json` re-cargable en debug (M110); sin recompilación.

- Feature freeze de balance 2 semanas antes del GONOGO (solo fixes críticos).

### 2.5 Rendimiento (RF6)

- Build semanal de referencia con dashboard: FPS/p99, memoria B/N, tiempos de carga por zona, draw calls por zona.
- Gate CI (M118): falla si una zona supera su presupuesto (M61) o la memoria global supera M62 o los tiempos M63.
- Instrumentación con métricas de sesión locales (M104/M105) en cada build de playtest.

### 2.6 QA intensivo (RF7)

```
Backlog de bugs (M102) → triaje diario (P0=P1 críticos/altos) → fix con test de regresión (M112)
→ integración → build semanal → verify en tracking (M101) → release candidate de la semana
```

- Objetivo: P0/P1 = 0 al cierre; P2 documentados con plan de Beta; severidad duplicada = proceso de triaje auditado.
- Playtest semanal con 5+ jugadores (M114) + encuesta de diversión (M152) y de confusión.

### 2.7 Deuda técnica (RF8/RF9)

- Inventario de TODO/FIXME en el repo (script CI, M111) → sprint de 2 semanas de pago → 0 al cierre.
- Deuda de M135 re-metricada (50% de reducción) con informe por sistema.

## 3. Hits GONOGO-BETA (M141)

| Hit | Criterio |
|---|---|
| H1 | Historia jugable completa (6 sellos + epílogo), sin bloqueos, canon OK |
| H2 | Todas las mecánicas principales presentes e integradas (RF2/RF3) |
| H3 | Primer balance estable: 40 h simuladas sin alertas + 2 meses de playtests acumulados |
| H4 | Contenido Alpha: 4 islas, 3 templos, 24-30 NPC, 30+ secundarias, 80 coleccionables |
| H5 | Rendimiento medible: presupuestos M61-M63 cumplidos en build semanal de referencia |
| H6 | QA: 0 bugs P0/P1; P2 documentados; tracking verificado (M101/M102) |
| H7 | Arquitectura: 0 TODO/FIXME; deuda M135 ≥ 50% reducida |
| H8 | Save v3 migrado a todo el juego; 0 pérdidas en 30 ciclos |
| H9 | Accesibilidad M58 validada en los sistemas nuevos |
| H10 | GONOGO-BETA documentado y firmado con backlog de Beta priorizado (M141) |

## 4. Plan de oleadas (W1-W6)

| Semana | Foco |
|---|---|
| W1 | Economía global + tiendas por isla + balance JSON (M93/M38/M39) |
| W2 | Amistad + diálogos + eventos de temporada base (M20/M21/M74) |
| W3 | Templos 2-3 + puzzles + artefactos (M26/M24/M13/M71) |
| W4 | Viajes + 2 islas nuevas + clima/calendario (M28/M27/M29-M32) |
| W5 | **Semana de integración** (cross-system QA, regresión, perfil) |
| W6+ | Sprint de deuda (2 sem) + Sprint de QA intensivo (3-4 sem) → GONOGO-BETA |