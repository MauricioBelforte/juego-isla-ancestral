# Log 1446: Correccion de 3 drifts de conteo en CHECKLIST-GLOBAL (M24/M39/M70)

**Fecha:** 2026-10-07
**Hora:** 23:08
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Corregidos los 3 drifts de conteo detectados por `scripts/verificar_checklist.py` tras la consolidacion del CHECKLIST-GLOBAL (Log 1439). Las alertas del verificador bajaron de 15 a 12. Ademas se re-verifico de forma independiente la suite de rendimiento de M39 que agnes-3-flash cerro hoy (frente canal 76), cerrando el ultimo [ ] de ese modulo.

## Cambios Realizados

### 1. M24-Templos-Y-Puzzles: 70/128 -> 100/128 (inflacion del GLOBAL)
- Conteo canonico del plan-actual (regex `(?m)^\s*- \[x\]`): 100 [x] / 27 [ ] / 1 [?] = 128.
- El GLOBAL seguia en 70/128 (cierre de la iter. 4 de DeepSeek-V4.1-Flash, Log 1431); la iter. 5 (commit `8755edc`, ya en origin) elevo el conteo a 100.
- Estado corregido: "iter. 4 (70/128), iter. 5 pendiente" -> "iter. 5 DeepSeek en origin; conteo real 100/128". No se afirma cierre formal de la iter. 5 (sin verificacion del director); solo el hecho factual de que el conteo real es 100/128 y el commit esta en origin.

### 2. M39-Tiendas: 180/181 -> 181/181 ([ ] cerrado por agnes, re-verificado por s2)
- Hallazgo clave: el plan-actual tenia una contradiccion interna. La linea de Totales (L292) decaia 180/181 y la nota de auditoria de agnes (L315) llamaba "al 1 [ ] aislado" a la prueba de rendimiento de 1000 transacciones, PERO el item L257 ya estaba marcado `[x]` con respaldo en `scripts/shops/test_m39_rendimiento_tienda.gd`.
- El archivo existe (111 lineas), es trabajo de agnes-3-flash fechado 2026-10-08 y estaba **untracked** (sin commitear).
- **Re-verificacion independiente (s2, Godot 4.7.2 headless):**
  - Comando: `godot472.exe --headless --path game/isla-ancestral --script res://scripts/shops/test_m39_rendimiento_tienda.gd`
  - Resultado: **8 checks / 0 fallos / EXIT 0**, 2 corridas (2016 ms y 3003 ms totales para 1000 transacciones = 2-3 ms/txn; umbral "sin picos de frame" = 16.6 ms/txn).
  - Guardian anti-falso-verde presente y funcional: medicion viva (total_us > 0), efecto observable (stock reacciono a las 1000 compras), integridad (stock no negativo tras compra masiva fuera de stock).
- Conteo canonico final: 181 [x] / 0 [ ] / 0 [?] = 181.
- Se actualizo la linea de Totales del plan (L292: 180/181 -> 181/181) y se agrego una seccion "Notas del Agente - Re-verificacion de cierre (atria-dawn-s2, 2026-10-08)" sin tocar las notas anteriores de agnes (regla de historial intacto).
- Advertencias no bloqueantes observadas: 8 item_ids de catalogos de M39 inexistentes en M15 (deuda BUG-106 ya registrada; falta `pergamino_rec_tela_lino`) y tiendas sin `npc_duenio_id` (validar en editor).
- **No se flipo a ✅** — queda a decision del director (no se realizo QA §21.8 sobre este cierre).

### 3. M70-Interacciones: 155/198 -> 77/198 (inflacion del GLOBAL)
- Conteo canonico del plan-actual: 77 [x] / 121 [ ] / 0 [?] = 198, coincide con la linea de Totales del propio plan (L306).
- El 155/198 del GLOBAL era inflacion sin respaldo en el plan. Nota interna de Hy3 (Log 1224) ya registraba un drift en este modulo, pero en sentido inverso ("GLOBAL marca 77/198 mientras el modulo propio declara 155/198"); el GLOBAL subio de 77 a 155 en algun momento posterior sin que el plan cambiara en ese sentido. Se dejo la nota de Hy3 intacta y se agrego la correccion con firma.

## Verificacion

- `python scripts/verificar_checklist.py`: **15 alertas -> 12 alertas**. Los 3 drifts de conteo (M24/M39/M70) desaparecieron. Las 12 restantes son las 10 ya conocidas (modulos 137-144, 98, 99 en estado 🟢 con [x] — pendientes de convencion del director) y los 2 bloqueos colgados (M17 desde 2026-10-04, M37 desde 2026-10-03, regla §21.4.7).
- BOM UTF-8 del GLOBAL verificado: ausente (bytes iniciales 35 32 67).
- Diff git revisado antes del commit; index verificado vacio (sin staging heredado de otras sesiones).

## Archivos Modificados/Creados

- `CHECKLIST-GLOBAL.md` — 3 correcciones de Progreso (M24 L198, M39 L222, M70 L278) + 2 notas de correccion firmadas en las notas de M39 y M70.
- `DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md` — linea de Totales L292 (180/181 -> 181/181) + nueva seccion "Notas del Agente - Re-verificacion de cierre (atria-dawn-s2, 2026-10-08)" con comando y output reales.

## No incluido en este commit

- `game/isla-ancestral/scripts/shops/test_m39_rendimiento_tienda.gd` (untracked, trabajo de agnes-3-flash) — no se commitea; queda para que agnes/director lo integren. Su existencia en disco es la evidencia de la re-verificacion.

## Huella de push

Este log se creo ANTES del commit. Si el push se autoriza, el rango y la hora se documentan aqui mismo (regla §4.3).
