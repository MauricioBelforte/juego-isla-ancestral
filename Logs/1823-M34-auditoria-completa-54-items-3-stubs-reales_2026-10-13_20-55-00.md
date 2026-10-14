# Log 1823: M34-Pesca auditada completa (54 `[?]`, 0 promos) — 3 stubs reales identificados

**Fecha:** 2026-10-13
**Hora:** 20:55
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 54 `[?]` de M34-Pesca (encargo del director mimo, msg 280/285 + reenvío de s3).
Commit `fdea098`. **0 promociones**: los 54 son dependencias externas con dueño identificado — pero
la auditoría sirvió para ubicar los **3 stubs reales que sí son deuda de M34**.

## Resultado

- Conteos: **99 `[x]` / 0 `[ ]` / 54 `[?]`** = 153; línea Totales corregida (decía 84/69 de la
  iter 2, el conteo regex real es 99/54).
- 54 `[?]` anotados con archivo/línea/evidencia.

## Los 3 stubs reales de M34 (deuda propia, no externa)

| Stub | Evidencia | Efecto |
|---|---|---|
| `es_agua_pescable()` | `fishing_spot.gd` L29-30 → `return true` (comentario "Con M51 no integrado") | cualquier spot se acepta como pescable; las 3 validaciones (voxel AGUA, aire encima, orilla BFS) no existen |
| `spot_apunta_desde()` | `fishing_manager.gd` L114-119 devuelve el **primer** spot válido registrado | ignora `_rango` y `_direccion`: no hay selección por centro de rayo ni desempate |
| Marcador visual | `fishing_spot.gd` L38-42: `visible = true` / `pass` | sin ondulaciones ni burbujas (M52) |

## Contratos verificados (existen y se emiten — el cable del otro lado no)

- `picada_iniciada` (fishing_manager.gd L206), `captura_fallida("el_pez_se_fue")` (L227),
  `ventana_activa(inicio, duracion)` (fishing_session.gd L59), `pulsaciones_minijuego(restantes)`
  (L70/L74), `captura_exitosa(pez, tamano)` (manager L219).
- Consumidor real verificado: `achievement_service.gd` L141-144 conecta `captura_exitosa` →
  `_on_captura_pesca` (producción, no solo tests).
- Datos listos: `nombre_i18n="PESCA.PEZ_*"` en `data/balance/fishing.json` (claves localizables),
  rareza (`peso_rareza`, `UMBRAL_RARO=0.08`), `get_collection_data()` (L467-468).
- Balance pendiente: 4 cebos y 3 cañas en el JSON, **0 con `precio_compra`** (dueño M93/M38).
- Timers pausables: `SceneTreeTimer` con `get_tree().paused` (fishing_session.gd L8/L24-25/L46/L60).

## Archivos Modificados/Creados

- `DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md` (54 `[?]` anotados + Totales; commit `fdea098`)
- `Logs/1823-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1823 consumido)
- `scripts-prueba-temp/audit_m34_b*.py` (scripts de anotación por bloque)

## Pendiente

M11-Personaje (51 `[?]`) — último módulo del encargo de 10 bloques.
