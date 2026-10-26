**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 93: Balance

## 1. Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│ data/balance/                                               │
│  ├── prices.json            (RF1)                           │
│  ├── rewards.json           (RF2)                           │
│  ├── construction.json      (RF3)                           │
│  ├── crafting.json          (RF4)                           │
│  ├── tools.json             (RF5)                           │
│  ├── resources.json         (RF6)                           │
│  ├── farming.json           (RF7)                           │
│  ├── fishing.json           (RF8)                           │
│  ├── mining.json            (RF9)                           │
│  ├── travel.json            (RF10)                          │
│  ├── seals.json             (RF11)                          │
│  ├── friendship.json        (RF12)                          │
│  ├── quests.json            (RF13)                          │
│  ├── puzzles.json           (RF14)                          │
│  ├── unlocks.json           (RF15)                          │
│  ├── timing.json            (RF16)                          │
│  ├── progression.json       (RF17)                          │
│  └── meta.json              (versión, fecha, afecta)        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Scripts (autoload)                                          │
│  balance.gd            ← Acceso central (recursos cargados) │
│  validate_balance.gd   ← Validación de reglas + assert      │
│  simulate_economy.gd   ← Simulación offline (editor)        │
│  balance_report.gd     ← Dumps de legibilidad para diseño   │
└─────────────────────────────────────────────────────────────┘

Sistemas de gameplay (M38, M20, M16, M33, M34, M35, M28...)
    ↓ consulta
balance.gd (autoload, carga única al inicio)
    ↓ lee
data/balance/*.json
```

## 2. Componentes

### 2.1 `balance.gd` (autoload)
- `get_price(item_id) -> int` — precio de compra/venta (M38).
- `get_reward(activity_id, tier) -> Reward` — recompensas por actividad.
- `get_recipe(recipe_id) -> Recipe` — costes de crafting (M16).
- `get_fish_chance(fish_id, season, hour, weather) -> float` — M34.
- `get_seal_requirements(seal_id) -> Array` — M153.
- `get_friendship_thresholds() -> Dictionary` — M20.
- `get_timing() -> Timing` — tiempos objetivo diarios (RF16).
- `validate_all() -> Array[String]` — corre todas las reglas (devuelve errores; usado por el gate CI).
- Todos los accesos son de **lectura**; los valores se cargan con `ResourceLoader` una sola vez en `_ready()`.

### 2.2 `validate_balance.gd` (tool)
Reglas de negocio verificables (assert por regla):
1. Precio venta entre 55% y 70% del precio compra (márgenes).
2. Ningún ítem de historia (M22/M23) tiene precio de compra (no se puede comprar contenido crítico).
3. Ningún ítem con coste de crafting menor a la suma de recursos que lo componen (sin recetas generadoras de recursos).
4. Rarezas máximas ≤ 5% base; pity máximo definido por ítem.
5. Tiempo de resolución de puzzle (M24) ≤ 20 min con ayuda; ≤ 45 min sin ayuda.
6. Recompensa de misión secundaria entre 5-15% del costo del siguiente desbloqueo (M71).
7. Sesión rutina diaria ≤ 30 min (suma de timing.json).
8. Sellos: sin requisito de grind repetitivo; cada Sello es un bloque de contenido curado (M153).
9. Amistad: sin decaimiento por ausencia (M94); sin umbrales que exijan regalos diarios forzosos.
10. Sin exponencial en ninguna curva de progresión (pendiente decreciente).
11. Venta diaria con tope (anti-inflación).
12. versionado: `meta.json` presente, `balance_version` incrementa con cada cambio.

### 2.3 `simulate_economy.gd` (tool, editor)
- Escenarios: jugador "rutinario" (30 min/día), "diligente" (2 h/día), "minimalista" (1 sesión/semana).
- Simula 60/180/365 días usando curvas de tiempo real de sesión.
- Salida: AO total, recursos por pipeline, desvío vs. meta de diseño (tabla).
- Falla (exit code != 0) si algún bucle genera AO > 115% de la tasa diseñada (anti-exploit) o si la meta del 1er Sello supera el umbral de sesiones.

### 2.4 `balance_report.gd` (tool)
- Genera `docs/balance/reporte.md` legible (tablas markdown) desde los JSON, para revisión humana y sesiones de playtest (M114).

## 3. Schema de Datos (ejemplo `fishing.json`)

```json
{
  "schema_version": 1,
  "meta": { "balance_version": "1.4.0", "afecta": ["M34", "M38"], "fecha": "2026-08-19" },
  "fish": [
    {
      "id": "pez_sardina",
      "nombre_i18n": "pez_sardina",
      "season": ["todas"],
      "hours": [4, 20],
      "weather": ["despejado", "lluvia"],
      "weight_kg": [0.3, 1.2],
      "price_buy": 30,
      "price_sell": 20,
      "chance": 0.25,
      "pity": null
    },
    {
      "id": "pez_luna",
      "nombre_i18n": "pez_luna",
      "season": ["verano"],
      "hours": [21, 3],
      "weather": ["lluvia"],
      "weight_kg": [12.0, 60.0],
      "price_buy": 900,
      "price_sell": 550,
      "chance": 0.03,
      "pity": 80
    }
  ]
}
```

## 4. Flujos

### 4.1 Flujo de ajuste de balance (tuning)
```
Playtest (M114) o telemetría (M105)
   → detecta desvío (>20% vs simulación)
   → se edita el .json correspondiente (vía spreadsheet export o directo)
   → se corre validate_balance.gd (gate local)
   → se corre simulate_economy.gd (120 días)
   → si OK: bump balance_version, CHANGELOG, commit (M118 CI lo re-valida)
   → si falla: se corrige hasta pasar; nunca se sube un balance roto
```

### 4.2 Flujo de consumo en gameplay (ej. tienda M39)
```
Jugador interactúa con tienda
→ M39 llama balance.get_price(item_id)
→ balance.gd devuelve precio compra/venta
→ la tienda aplica descuentos/eventos (M74) por encima
→ nunca hardcodea precios
```

## 5. Integración con CI (M118)

- Gate `validate_balance` en cada PR que toque `data/balance/`:
  - `validate_balance.gd --check`
  - `simulate_economy.gd --days 180 --scenario rutinario`
- Si falla → PR bloqueado.

## 6. Metadatos de Observabilidad (M104/M105)

| Evento | Datos | Módulo |
|---|---|---|
| `BALANCE_SIM_RESULT` | AO/día simulado vs. real | M105 |
| `BALANCE_DESVIO` | Porcentaje desvío por categoría | M105 |
| `BALANCE_VERSION` | Versión activa | M104 |
| `PLAYER_ECON` | AO por sesión real, tiempo por actividad | M105 |

## Decisiones de diseno aplicadas (Reflection-Beam-1.0, 2026-10-23, GO del fundador)

### H4 — Margen de pesca rare >70% es INTENCIONAL
Los peces rare (ancestral_laguna 76.0%, ancestral_raiz 76.9%, koi_dorado 73.3%, pez_espada 73.1%, napoleon 72.9%, atun_real 72.7%) tienen margen superior al 70% por diseño (atun_real añadido 24oct — hallazgo Beam 413 T3, faltaba en la lista H4 original): los items rare tienen mayor margen para compensar su baja probabilidad de captura. La regla "55-70%" aplica a items comunes/uncommon; los rare tienen excepcion documentada.

### H5 — Probabilidades de pesca son PESOS RELATIVOS, no probabilidades mutuamente exclusivas
Los valores prob en fishing.json (0.6/0.25/0.1/0.04/0.01) son pesos relativos para seleccion ponderada, NO probabilidades que sumen a 1.0. La suma (7.83) es intencional. Documentado para evitar confusion en auditorias futuras.
### H1 — sello_1_umbral_ao = 1200 es alcanzable si dinero_diario es POR SESION

dinero_diario_promedio_ao = 80 es por sesion (no por dia). 12 sesiones x 80 = 960 AO + misiones one-time (750 AO) = 1710 AO > 1200 threshold. sello_1_tiempo_horas = 8h = 12 sesiones de ~40 min. Coherente.

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-2 (H1)**: sello_1 / dinero_diario = interpretacion **POR SESION ~1200 AO** (opcion C del consolidado 257; coherente con sesiones cozy de ~40 min). GO fundador 275 ya lo aplico (item 255); ratificado por director 315 con cita canonica "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones»".

### Specs items degradados T248 (2026-10-26, Reflection-Beam-1.0)
- **L138 (definir simulate_economy.gd con escenarios rutinario/diligente/minimalista):** KnownIssue no bloqueante DoD: NO implementado; es la brecha principal del módulo. Diseño documentado en 03-Diseno.md §2; implementación requerirá iteración futura M93 + M105 datos reales. [x] DEF verificada hoy 2026-10-19 (Step-5-WorkBuddy, Log 2015, msg 084): diseño verificado en 03-Diseno.md §2.3 (líneas 74-78): escenarios "rutinario" (30 min/día), "diligente" (2 h/día), "minimalista" (1 sesión/semana). Implementación (el .gd) diferida a iter futura M93 + M105 datos reales = deuda conocida que se mantiene. [?] degradado 2026-10-23 (DeepSeek-V4.1-Flash, P4/P5b dir 369): el artefacto citado simulate_economy.gd NO existe en disco ni en la historia de git (git log --all = 0 commits); el [x] no tenía evidencia en disco.
- **L190 (definir balance_report.gd que genera reporte markdown legible):** degradado 2026-10-16 (barrido agnes 622 + flip GLM-5.3 Flash-Director): archivo NO existe en disco (scripts/ y scripts/balance/ = 5 .gd, ninguno balance_report.gd). Verificar si el reporte se genera vía validate_balance.gd/CI (reformular) o implementar. [x] DEF verificada hoy 2026-10-19 (Log 2015, msg 084), cierra la degradación del 2026-10-16: verificado HOY que el reporte NO se genera vía validate_balance.gd (grep markdown|reporte|\.md = 0) ni existe docs/balance/ (ls) → no hay reformulación posible: la definición vigente es 03-Diseno.md §2.4 (líneas 80-81): genera docs/balance/reporte.md con tablas markdown desde los JSON. Implementación (el .gd) pendiente = deuda conocida. [?] degradado 2026-10-23 (DeepSeek-V4.1-Flash, P4/P5b dir 369): el artefacto citado balance_report.gd, docs/balance/reporte.md NO existe en disco ni en la historia de git (git log --all = 0 commits); el [x] no tenía evidencia en disco.