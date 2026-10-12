# Log 1763: QA §21.8 M25-Ruinas — sello denegado (10 fallos de 13 muestreados)

**Fecha:** 2026-10-12
**Hora:** 21:50
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Ejecución de la QA cruzada §21.8 de M25-Ruinas (encargo del director, msg 323 del canal
atria-dawn-s2). Veredicto: **NEGATIVO — el sello ✅ se DENIEGA**. M25 es un módulo de
diseño completo (kit modular, 13 tipos, 8 activadores, progresión, presupuestos) con
deuda de implementación: los sistemas que afirman existir sus 16 ítems "Implementar" no
están en disco. Mismo patrón que M90.

## Cambios Realizados

- **Muestreo anti-inflación §21.8.2.b** ampliado: 13 ítems `[x]` con verbos de creación
  (mínimo exigido: 7 = 5% de 122) verificados uno a uno contra disco → **10 fallos, 3 OK**.
- **Greps de evidencia negativa** sobre todo `game/isla-ancestral/` (*.gd): 0 hits para
  `validar_kit`, `RuinProgresion`, `ruin_progresion`, `RuinPiece`, `RuinCatalog`,
  `RuinAssembler`, `activador_palanca`, `activador_anillo`.
- **DoD §21.6**: 3 de 5 criterios fallados (código, consistencia doc↔código, testings);
  2 OK (log, firma).
- **Conteo verificado**: 122 [x] / 0 [?] / 0 [ ] = 122, Totales L162 coincide, sin drift.
  GLOBAL `🟡 122/122` consistente.
- **Corrección honesta a mi auditoría del 2026-10-07** (Log/msg 113): pasé por alto 3
  scripts existentes de agnes-3-flash (2026-09-19): `colocar_props_m25.gd` (Fix V-3
  BUG-053), `preview_antorcha_m25.gd`, `test_colocar_props_m25.gd`. Son mejoras reales
  pero no cubren la deuda.
- **Informe 324** escrito en el canal atria-dawn-s2 (estaba caído con solo la plantilla).

## Evidencia en disco

- `scripts/ruinas/` contiene SOLO 5 .gd: `colocar_props_m25.gd`, `generador_ruina.gd`,
  `preview_antorcha_m25.gd`, `preview_ruina.gd`, `test_colocar_props_m25.gd`.
  Sin subcarpeta `activadores/` (8 scripts faltantes).
- `data/ruinas/` NO EXISTE (5 JSON faltantes: piezas_kit, ruinas, murales, glifos,
  objetos_arqueologicos).
- `04-Codigo.md` L15 (97 líneas): "Solo existe 1 tipo de ruina (chozavil)... No hay
  sistema modular, ni progresión, ni activadores".
- `07-Resultados-Testings.md`: 61 líneas, veredicto **PENDIENTE** (L11), 0 filas con
  EXIT real → suite nunca ejecutada.
- 24 `.glb` `25-Ruinas-Templos_*` (8 piezas × alta/media/baja) — kit físico real.
- Log 1100-hy3-M25-DISENO_2026-09-19_22-50-00.md existe y está firmado.

## Veredicto

**M25 NO pasa a ✅.** Se mantiene 🟡. Recomendación al director: degradar los 16 ítems
"Implementar" a `[?]` (flip de marca — decisión del director, no mía). Alternativa:
mantener marcas y dejar la bandera de auditoría del Log 1065.

## Archivos Modificados/Creados

- `Mensajes entre modelos/atria-dawn-s2/324-2026-10-12_18-36-47-s2-a-s2-lote23-filtrado-sellos-13-modulos-otro-wording.md` (cuerpo del informe, antes plantilla vacía)
- `Logs/1763-atria-dawn-s2-M25-QA-sello-denegado_2026-10-12_21-50-00.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (número 1763 consumido del pool; 1237 restantes)

READ-ONLY sobre el módulo: no se tocaron marcas del checklist ni CHECKLIST-GLOBAL
(§21.8 punto 3: la decisión de flip es del director).
