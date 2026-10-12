**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12

# 06-Plan-Testings.md — Módulo 74: Eventos

## 1. Estrategia

Todas las suites de M74 son **SceneTree puros** (headless, sin boot de escena) salvo
`test_event_manager_headless.gd` (play-mode). Se ejecutan con:

```
Godot --headless --path game/isla-ancestral --script res://scripts/eventos/<suite>.gd
```

Cada suite define `CHECKS_MINIMOS` (piso de checks) y aborta con `quit(1)` si:
- algún bloque no cerró (`_abrir` sin `_fin`),
- el piso no se cumple, o
- hay cualquier fallo.

Código de salida `0` = OK. Anti-falso-verde: el piso evita que una suite que no corrió se
reporte como exitosa.

## 2. Suites existentes y su cobertura

| Suite | Bloques | Cubre |
|---|---|---|
| `test_event_manager_pure.gd` | escaneo | Estructura/contenido de los 7 directorios de `data/` |
| `test_capitulos_m74.gd` | 6 | Carga 22 eventos, 7 capítulos, claves i18n, regresión 8 base |
| `test_event_manager_verificacion.gd` | 9 | Catálogo, anti-duplicado, entrega por tipo, finalizar, aviso, señales, sorpresas, persistencia, NFR |
| `test_solapes_m74.gd` | 5 | J7/J8/J12/J20: prioridad, resolución, cruces mes/año, persistencia, ciclo diario |
| `test_eventos_relativos_m74.gd` | 7 | RF4.10: reglas relativas, re-validación al cargar |
| `test_buzon_entregas.gd` | 6 | RF6.9/6.10: buzón, retención 30 días, reclamo, purge |
| `test_barrido_m74.gd` (nueva) | 13 | Ver sección 3 |

## 3. Suite nueva del barrido — `test_barrido_m74.gd`

Criterios de éxito por bloque (todos deben dar `[ok]`):

| # | Bloque | Criterio de éxito |
|---|---|---|
| 1 | Año nuevo + idempotencia | RF2.4/RF7.1/J1-J3: al cambiar de año el evento vuelve a `PENDIENTE`, el historial del año viejo se conserva, y un `dia_cambio` duplicado se descarta |
| 2 | Jugador ausente | J4/J5/J6: el evento no participado queda `NO_PARTICIPADO` y el año siguiente vuelve a `PENDIENTE` |
| 3 | Re-entrada | J17: la segunda `iniciar_participacion` en el mismo año devuelve `false` y `puede_participar` explica la razón |
| 4 | Evento sin recinto | J24: el ciclo iniciar/finalizar funciona con `escena_recinto == null` |
| 5 | Franja 00:00 | J25: `esta_en_franja(0,0)` es `true` con `hora_inicio == 0` |
| 6 | Evento sin recompensas | J23: `finalizar_evento` no crashea con `recompensas` vacío |
| 7 | Partida vieja | J22: `restore_save_data({})` y un save corrupto no tumba la partida |
| 8 | Guardar a mitad | J13/J14: franja abierta al cargar → se reabre; franja cerrada → `evento_terminado` + `NO_PARTICIPADO` |
| 9 | Clima interior | J11/J28: tormenta con evento sin `variante_cubierta` no cancela ni mueve |
| 10 | Sorpresas | RF9.2/RF9.3/J21: límite semanal de 3; la 4.ª se rechaza |
| 11 | Guardado doble | J27: el token anti-duplicado sobrevive un round-trip de save |
| 12 | Bicampeón | RF7.4: `get_anios_ganados` devuelve los años ganados en orden |
| 13 | Auditoría anti-FOMO | RN16/I19/I20: todo evento del catálogo (excepto capítulos) es recurrente; ninguno declara flag exclusivo |

## 4. Cobertura pendiente (deja [?] en el checklist)

- **M9 (clima)** — requiere swap de `variante_cubierta` (RF8.2 no implementado).
- **M14/M20/M21/M22 (runtime)** — requieren Godot en Play Mode.
- **M27 (FOMO end-to-end)** — perder un festival y vivirlo el año siguiente en una partida
  real.

## 5. Ejecución esperada

- 7 suites previas + 1 nueva = 8 suites.
- Las 7 previas totalizan 212 checks / 0 fallos (según Logs 1690/1694/1697/1699).
- La suite nueva **no se ejecutó en este entorno** (sin Godot): queda pendiente de CI/headless;
  su piso es `CHECKS_MINIMOS = 45`.
