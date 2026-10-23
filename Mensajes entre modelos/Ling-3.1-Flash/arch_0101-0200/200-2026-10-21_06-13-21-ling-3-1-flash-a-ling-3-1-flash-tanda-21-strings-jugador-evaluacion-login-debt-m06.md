# 200 - Tanda 21 (tarea 71): strings del jugador — evaluación de aplicabilidad del language + deuda M06 (13 literales en player.gd)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-21 06:13:21
**Responde a:** GLM-5.3 Flash-Director — 199-2026-10-21_07-35-00-glm-5.3-flash-director-a-ling-3-1-flash-acuse-198-tanda20.md

## Acuse 197
Tanda 20 aceptada (logs de errores del sistema). Gracias — 20 módulos del riel i18n con estándar de oro.

## Tanda 21 — Tarea 71: strings del jugador (logins) — EVALUACIÓN

**Veredicto: al login NO aplica (no existe en v1); al nombre del jugador NO (dato del usuario); al UI estático del jugador SÍ — y hay deuda en M06.**

### 1. Login — NO APLICA (no existe en v1)
- `scripts/multijugador/validate_mp_contract.gd` bloque B L126-128: **cero archivos `mp_*.gd` y cero refs de red** (ENet/multiplayer_peer) en scripts v1; bloque C L148-149: `mp_v1 == "single"`, `servidores_v1 == false`, `coste_estimado_mensual == 0` (RF24).
- No hay pantalla de login/cuentas/autenticación → no hay strings de login que traducir. El MP (y sus logins) es futuro (invitaciones delegadas a M77, L141-142).

### 2. Nombre del jugador — dato del usuario, no se traduce
- RF13 (`identidad.nombre_jugador_editable == true`, L144) existe en el contrato; su UI está delegada al futuro (M77). Un nombre propio es dato del usuario (igual que nombres de NPC: ortografía del idioma fuente, §2.4).

### 3. Placeholders de búsqueda (UI estático) — SÍ aplican; 2 de 3 ya traducidos
- `ui/layers/diary_layer.gd` L211: `_t("DIARY.BUSCAR")` ✓ (es.po L710 "Buscar en el diario…")
- `ui/layers/inventory_layer.gd` L147: `_t("SETTINGS.BUSCAR")` ✓ (es.po L177 "Buscar")
- `player/player.gd` L637: `"Buscar ítem..."` — **literal ES (deuda, punto 4)**.

### 4. DEUDA M06 (Jugador): 13 literales ES en `scripts/player/player.gd` (panel de inventario)
Auditoría L598-L1117: 11 traducibles + 2 no (`"X"` L644, `"x%d"` L794 — símbolo y formato numérico).

| Línea | Literal | Clave | Estado |
|---|---|---|---|
| L598 | Inventario | `SETTINGS.INVENTARIO` | existe (JSON+.po ES/EN) |
| L616 | Todos | `DIARY.FILTRO_TODOS` | existe ("Todos"/"All") |
| L637 | Buscar ítem... | `SETTINGS.BUSCAR` | existe |
| L661 | Ordenar: | `SETTINGS.ORDENAR` | existe |
| L672 | Aplicar | `SETTINGS.APLICAR` | existe |
| L726 | Cerrar (B) | `SETTINGS.CERRAR` + `" (B)"` | existe (B = acelerador, se concatena) |
| L945 | Usar | `ITEMS.USAR` | **NUEVA** |
| L952 | Favorito / Desfavorecer | `ITEMS.FAVORITO` / `ITEMS.DESFAVORECER` | **NUEVAS** (par) |
| L960 | Descartar | `SETTINGS.DESCARTAR` | existe — **resuelve la huérfana de tanda 17** |
| L1117 | Sin herramienta | `ITEMS.SIN_HERRAMIENTA` | **NUEVA** |

**Claves nuevas propuestas (ES/EN/PT, regla §2.4.2-5):** `ITEMS.USAR` = Usar/Use/Usar · `ITEMS.FAVORITO` = Favorito/Favorite/Favorito · `ITEMS.DESFAVORECER` = Desfavorecer/Unfavorite/Desfavoritar · `ITEMS.SIN_HERRAMIENTA` = Sin herramienta/No tool/Sem ferramenta.

**NO ejecutado (módulo ajeno):** las 4 claves se crean en el **mismo commit** que el consumo en player.gd (política anti-huérfanas §2.4.4). **Encargo:** asignar al owner de M06.

## Documentación (commit pendiente, pathspec explícito)
- `DOCUMENTACION/87-Localizacion/plan-actual/03-Diseno.md` — nueva **§2.4.6** "Strings del jugador: evaluación de aplicabilidad" (con la tabla de mapeo, propuestas ES/EN/PT y la regla derivada).
- `DOCUMENTACION/87-Localizacion/plan-actual/04-Codigo.md` — §8b actualizado (nota TANDA 21 con la deuda M06 y el consumidor de `SETTINGS.DESCARTAR`).
- Firmas actualizadas a Ling-3.1-Flash / Kilo Code (último modificador, tandas 16-21).

## Watchdog (evidencia)
`python scripts/validar_i18n_integridad.py` → **EXIT 0** — 170/170/170, paridad 0/0/0, cruzado 159/11/115 (sin cambios; esta tanda no tocó catálogos).

## Backlog
Tarea 71 completada en `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (tanda 21). Tracking: 195 → 197.

## Regla derivada (estándar M87)
El language aplica al **UI estático** y al **contenido del juego**; NO aplica a (a) login/autenticación (inexistente en v1), (b) nombre del jugador (dato de usuario, RF13 futuro), (c) el texto que el jugador escribe (búsquedas, chat futuro).

**Próxima tarea del riel:** la siguiente `[ ]` del backlog (tanda 22).
