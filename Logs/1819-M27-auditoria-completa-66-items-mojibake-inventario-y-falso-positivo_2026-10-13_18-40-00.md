# Log 1819: M27 auditada completa (66 `[?]`, 1 promo) + inventario de mojibake + corrección de falso positivo propio

**Fecha:** 2026-10-13
**Hora:** 18:40
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Cierre de la auditoría de `[?]` de M27-Islas-Del-Mundo (encargo del director mimo, msg 280/285 y
reenvío de s3), más el inventario de mojibake autorizado (msg 2028) y una **corrección honesta de un
falso positivo mío** del informe anterior.

## 1. M27 — auditoría completa (66 ítems)

Método Patrón D (Log 1807): cada `[?]` verificado contra disco con grep/artifact; promoción solo con
respaldo. Resultado:

- **1 promovido** (`[?]`→`[x]`): "La isla Flotante y las del Cielo no tienen océano debajo
  (`es_flotante`)" — campo en `island_definition.gd` L74, lógica en `island_travel_guard.gd`
  L208-215, validación L168-169 y test dedicado `test_islas_m27_iter2.gd` L354.
- **65 permanecen `[?]`** con la explicación de qué falta anotada en cada línea (evidencia:
  archivo, línea y resultado del grep).
- Conteos: **127 `[x]` / 0 `[ ]`` / 65 `[?]`** = 192 ítems; línea Totales actualizada
  (126→127 completados, 66→65 no resueltos).
- Commits: `337b5f2` (bloques 1-4) y `f9e7d2a` (bloques 5-7 + corrección + Totales).

### Patrón del resultado: M27 es un módulo de DEFINICIÓN con deuda de integración

De los 66 `[?]`, ninguno era "inflado": la gran mayoría son **contratos delegados a otros módulos**
(M10 anclas/regen, M28 viaje/UI, M29 calendario, M32 clima, M36 fauna, M41 música, M50 vegetación,
M54 mapa, M59 persistencia, M61 presupuesto, M63 streaming) o **cables que existen en un extremo y
nunca se conectan**: `marcar_visitada()` con 0 llamadores, `descubrir()` con 0 consumidores en
producción (solo tests), `esta_desbloqueada()` testeada pero sin consumo del viaje, `punto_partida`
consumido por el guard pero no por M28. Los datos por isla (fauna_endemica, clima_tendencia, musica,
npc_residentes) existen como campos; nadie los lee.

### Auto-corrección detectada y corregida

En el bloque 4 las anotaciones quedaron desplazadas un ítem (efecto secundario de la promoción del
ítem 38, que cambió la numeración de la secuencia `[?]`). Detectado en la verificación final
("items sin anotar: 3") y corregido por contenido antes de commitear. Las 65 anotaciones finales
fueron reverificadas una por una contra su ítem.

## 2. Inventario de mojibake (autorizado, msg 2028)

- `diagnosticar_mojibake.py` completo (tardó ~4 min, no colgado): **273 archivos con marcadores,
  21 SUCIO, 0 IRREVERSIBLE, 252 EXCLUIDO**.
- Con el patrón exacto del script, barrido acotado a `game/isla-ancestral/scripts/` (1125 archivos
  de texto): **2 SUCIOS**:
  - `scripts/houses/house_interior.gd` (6 marcadores: "Â¿", "Ã³", "Ã¡", "Â§")
  - `scripts/houses/test_m18_sistemas_s2.gd` (3+ marcadores: "â€”" × 12 líneas)
- `scripts/t_m37_mark.py` (raíz de automatización) es **falso positivo del detector**: L36 contiene
  el propio patrón como literal de regex (`r"\xc3|\xc2|\xe2\u20ac"`).
- **NO se corrió `fix_encoding.py`** (el director pospuso la reparación hasta ver el inventario).

## 3. Corrección de mi informe anterior (falso positivo)

En el msg 2027 reporté mojibake en `test_generacion_m10_atria.gd` L6-8 y
`test_islas_m27_iter2.gd` L6. **Era un falso positivo**: ambos archivos decodifican como UTF-8
válido y tienen **0 coincidencias** con el patrón exacto. Lo que vi fue un artefacto de
visualización de la herramienta de lectura (mostraba `Â§`/`Ã³` donde el archivo tiene `§`/`ó`
correctos). La lección operativa: para mojibake, **siempre** confirmar con lectura Python
(`io.open(encoding="utf-8")`), nunca con la vista previa de la tool. Los 2 SUCIOS reales de `houses/`
sí están confirmados por esa vía.

## Archivos Modificados/Creados

- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` (66 `[?]` auditados, 1 promo,
  Totales; commits `337b5f2` y `f9e7d2a`)
- `Logs/1819-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1819 consumido)
- `scripts-prueba-temp/` (scripts de anotación y verificación de la auditoría)
