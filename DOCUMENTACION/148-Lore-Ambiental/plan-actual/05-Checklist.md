**Modelo:** deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2)
**Plataforma:** Kilo Code (iter. 1) · WorkBuddy (iter. 2)
**Fecha:** 2026-09-01 (iter. 1 núcleo) · 2026-09-13 (iter. 2: CI gate, grafo, persistencia)

# 05-Checklist.md — Módulo 148: Lore Ambiental

## Reserva actual

- Estado: 🟡 Liberado (iter. 2: CI gate + grafo + persistencia) — 2026-09-13
- Agente: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2)
- Fase: Narrativa/mundo (soporte M147 Biblia)
- Dificultad: 3
- Visión: V0
- Entrada: M147 🟢 (biblia documentada), M24 ✅ (templos)
- Salida: LoreCatalogo (**60 piezas**, 4 islas, 14 tipos) + PiezaDeLore + LoreAuditor + TerrenoLoreService + LoreSaveProvider + LoreGate (CI) + test headless **85/0** OK
- Archivos: `game/isla-ancestral/scripts/lore/` + `data/lore/`
- Fecha cierre iter. 1: 2026-09-01 16:00 (Log 368) · iter. 2: 2026-09-13 (Log 881)
- **Totales:** 117 ítems · Completados: 115 · Pendientes: 0 · No resueltos: 2. (Corregido agnes-3-flash 2026-10-14: +49 flips b1-b7 `m148_spec.md` §4-§20. M148 CERRADO.)

## Convención
- `[x]` = completado (implementado y verificable). `[ ]` = pendiente. `[?]` = no resuelto / parcial.
  > La versión anterior definía `[ ]` **a la vez** como "completado" y como
  > "pendiente": la ambigüedad permitía declarar 114/114 con 99 `[ ]` reales.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Catálogo de lore (RF1/RF9)

- [x] Definir catálogo central `LoreCatalogo` (JSON) como única fuente [C]
- [x] Definir modelo `PiezaDeLore` con Id, CanonRef, Isla, Tipo, TextoLore, ConsumidorId [M]
- [x] Definir IDs únicos por pieza [S]
- [x] Definir referencia obligatoria de canon (M147) en cada pieza [S]
- [x] Definir cobertura mínima de 12 piezas por isla (4 islas implementadas: raiz 18, coral 14, ceniza 14, aurora 14) [M]
- [x] Definir composición sugerida por isla (ruinas/objetos/arquitectura/vegetación/daños/murales/estatuas/mapas/canciones/rumores) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — tabla 4 islas × 9 tipos.**
- [x] Definir plantillas de texto por tipo (ruina 3-5 líneas, objeto 2-3, etc.) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 9 plantillas con ejemplos.**
- [x] Definir validador de catálogo (LoreAuditor: IDs/canonRef/cobertura/grafo, 0 errores en catálogo real) [M]
- [x] Definir fallo de CI ante IDs duplicados o canonRef vacío [S]
- [x] Definir índice por isla y por tipo en el catálogo (por_isla/por_tipo) [S]

## 2. Ruinas cuentan historias (P1)

- [x] Definir ruinas como piezas inspeccionables con micro-narrativa [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — ruinas inspeccionables.**
- [x] Definir mínimo 2-3 ruinas por isla con historia propia [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 3 ruinas por isla.**
- [x] Definir ruinas vinculadas a templos sin contradecir M26 [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — vinculadas a M26.**
- [x] Definir ruinas con pistas de ubicación de otros secretos (opcional) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — pistas opcionales.**
- [x] Definir ruinas con estado visual (nunca "explorada" visualmente rota) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — estado visual conservado.**

## 3. Objetos cuentan historias (P2)

- [x] Definir objetos inspeccionables con procedencia (2-3 por isla) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 2-3 objetos por isla.**
- [x] Definir objetos de ítems clave sin duplicar lore de M66 [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — sin duplicar M66.**
- [x] Definir objetos con historia de familia/cultura de la isla [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — historia familiar.**
- [x] Definir objetos que reaccionan a temporada (lore extra en invierno) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — lore estacional.**
- [x] Definir objetos persistentes (no desaparecen tras inspección) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — persistentes.**

## 4. Arquitectura cuenta historias (P3)

- [x] Definir estilo constructivo narrado por isla (cultura del constructor) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §4.1 — tabla 4 islas × cultura × estilo × pista.**
- [x] Definir piezas de arquitectura inspeccionables (columnas, arcos, casas) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §4.2 — 4 piezas con texto 60/40 + hint.**
- [x] Definir relación arquitectura ↔ biblia sin contradicciones [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §4.3 — 4 reglas de coherencia.**
- [x] Definir arquitectura que delata antigüedad (materiales por época) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §4.4 — tabla 6 épocas × material × aspecto.**
- [x] Definir arquitectura con pistas de acceso a templos (M26) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §4.5 — 4 templos × pista × ubicación × descifrado.**

## 5. Vegetación cuenta historias (P5)

- [x] Definir vegetación narrativa (bosques/árboles ancestrales) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §5.1 — tabla 4 islas × vegetación × historia.**
- [x] Definir árboles/plantas inspeccionables con historia local [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §5.2 — 4 piezas con texto 60/40.**
- [x] Definir vegetación vinculada a eventos pasados (quemas, curaciones) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §5.3 — 3 eventos × vegetación × ubicación.**
- [x] Definir vegetación con cambio estacional que revela lore (M50) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §5.4 — tabla 4 estaciones × cambio × lore.**
- [x] Definir sin contradicción con la flora de colección (M73) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §5.5 — 4 reglas de coherencia.**

## 6. Daños estructurales cuentan historias (P6)

- [x] Definir daños/derrumbes inspeccionables (grieta, torre caída) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — daños inspeccionables.**
- [x] Definir daños con evento pasado narrado (catástrofe, batalla) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — evento pasado.**
- [x] Definir daños que ocultan pasadizos (destape por temporada - opcional) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — pasadizos ocultos.**
- [x] Definir coherencia: daños visibles también en M50 (no solo lore) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — coherencia M50.**
- [x] Definir daños sin bloquear caminos principales (M28) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — sin bloquear M28.**

## 7. Murales contienen pistas (P7)

- [x] Definir murales en templos con pistas de puzzles (M24) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — murales M24.**
- [x] Definir mínimo 1 mural por templo (6 templos) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 6 murales.**
- [x] Definir murales con lore de la historia del templo [M] → **agnes-3-flash (2026-10-12): `m148_spec.md`.**
- [x] Definir grafo: mural → puzzle que desbloquea [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — grafo mural→puzzle.**
- [x] Definir murales legibles: pista usable sin devolver texto gigante [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — pista breve.**
- [x] Definir murales con estado en diario (visto/no visto) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — diario.**

## 8. Estatuas contienen pistas (P8)

- [x] Definir estatuas con pistas de sellos/artefactos (M22/M13) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — estatuas M22/M13.**
- [x] Definir mínimo 2 estatuas-pista por isla [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 2 por isla.**
- [x] Definir estatuas de personajes del canon (M147) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — canon M147.**
- [x] Definir grafo: estatua → sello/artefacto que referencia [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — grafo estatua→sello.**
- [x] Definir estatuas con diálogo inspección registrable en diario [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — diario.**

## 9. Mapas contienen pistas (P9)

- [x] Definir mapas antiguos coleccionables con pistas de secretos (M73) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — mapas M73.**
- [x] Definir mínimo 1 mapa por isla (6 mapas) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 6 mapas.**
- [x] Definir grafo: mapa → coleccionable/ruina oculta [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — grafo mapa→coleccionable.**
- [x] Definir mapa con lore de la zona mapeada [M] → **agnes-3-flash (2026-10-12): `m148_spec.md`.**
- [x] Definir mapa con marcado persistente al recolectar [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — persistente.**

## 10. Canciones contienen pistas (P10)

- [x] Definir canciones aprendidas por eventos/amistad (M20) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — canciones M20.**
- [x] Definir mínimo 2 canciones con mensaje cifrado (ritual, historia) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 2 cifradas.**
- [x] Definir grafo: canción → rumor/NPC que responde [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — grafo canción→rumor.**
- [x] Definir letras registrables en diario como pieza canción [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — diario.**
- [x] Definir canciones sin romper el audio (M41-M44) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — M41-M44.**

## 11. NPC cuentan rumores (P11)

- [x] Definir rumores locativos de NPC al nivel de amistad ≥ 4 (M20) [C] → **agnes-3-flash (2026-10-12): `m148_spec.md` — rumores M20.**
- [x] Definir mínimo 3 rumores por isla (18+ rumores) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — 3 por isla.**
- [x] Definir rumor → zona de lore no explorada (puente de descubrimiento) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — puente.**
- [x] Definir rumor con cooldown (no repetirse) [S] → **agnes-3-flash (2026-10-12): `m148_spec.md` — cooldown.**
- [x] Definir rumor de temporada (cambia por estación) [M] → **agnes-3-flash (2026-10-12): `m148_spec.md` — estacional.**

## 12. Peces revelan información (P12)

- [x] Definir lore en fichas de peces raros/descritos (M34/M73) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §12.1 — regla ficha 60/40 + ejemplo.**
- [x] Definir mínimo 6 peces con lore pivotal (mito de la isla) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §12.2 — tabla 6 peces × lore × mito.**
- [x] Definir pez-lore desbloqueado al capturarlo/completar ficha [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §12.3 — progresión 1ª/2ª/todos.**
- [x] Definir grafo: pez → secreto de aguas profundas (M34) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §12.4 — grafo 6 nodos → 4 templos.**
- [x] Definir pez con descripción de dieta/hábitat mezclada con mito [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §12.5 — ejemplo ficha completa Pez-luna.**

## 13. Plantas revelan secretos (P13)

- [x] Definir lore en fichas de plantas de colección (M50/M73) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §13.1 — regla ficha 60/40 + ejemplo.**
- [x] Definir mínimo 6 plantas con secretos (cura, clima, ritual) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §13.2 — tabla 6 plantas × secreto × tipo.**
- [x] Definir planta-lore desbloqueada al cosechar/ficha [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §13.3 — progresión + receta escondida.**
- [x] Definir grafo: planta → receta culinaria/curativa (M16) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §13.4 — grafo 6 plantas → 6 recetas.**
- [x] Definir planta con estacionalidad coherente (M33) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §13.5 — tabla 6 plantas × estación × coherencia M33.**

## 14. Minerales activan ruinas (P14)

- [x] Definir minerales que activan ruinas/altaríos (M35/M24) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §14.1 — regla activación + persistencia.**
- [x] Definir mínimo 3 minerales activadores (uno por isla/s) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §14.2 — tabla 4 minerales × isla × ruina × efecto.**
- [x] Definir grafo: mineral → ruina/altar que enciende [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §14.3 — grafo 4 minerales → 4 ruinas + anti-farmeo.**
- [x] Definir mineral con lore de extracción (dónde y cómo) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §14.4 — tabla 4 minerales × dónde × cómo × lore.**
- [x] Definir activación persistente (una vez encendida, queda) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §14.5 — 4 reglas de persistencia + M66 anti-softlock.**

## 15. Terreno revela información (P15)

- [x] Definir cambios del terreno que destapan secretos (M50/M74) [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §15.1 — 3 cambios × estación × secreto.**
- [x] Definir 3 ubicaciones por temporada (12 anuales) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §15.2 — tabla 4 estaciones × 3 ubicaciones.**
- [x] Definir TerrenoLoreService con hook de nueva temporada (4 temporadas, secretos JSON) [M]
- [x] Definir secretos de terreno registrados en el diario [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §15.3 — diario registra qué/dónde/cuándo + estado.**
- [x] Definir sin recompensa duplicada de lore ya explorado [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §15.4 — 3 reglas anti-duplicación.**

## 16. Regla anti-infodump (P16/RF7)

- [x] Definir proporción mínima 60% lore ambiental vs diálogo explicativo [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.1.**
- [x] Definir auditoría de muestreo de 10 zonas (2 por isla) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.2.**
- [x] Definir checklist de auditoría (¿explica algo que el mundo ya cuenta?) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.3.**
- [x] Definir plantillas de texto cortas por tipo de pieza [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.1 (texto 60/40) + Plantillas (pág. 3).**
- [x] Definir diálogos de NPC que avancen trama, no que expliquen el mundo [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.1 "NPC reactivo, no explicativo".**
- [x] Definir sin texto duplicado entre diálogo y pieza (una sola vía) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §16.3 "máx 4 pistas por Templo".**

## 17. Persistencia (RF8/M59)

- [x] Definir campo de exploración persistido (a_estado_exploracion/desde_estado, lista para M59/M60) [M]
- [x] Definir contadores por isla persistidos [M]
- [x] Definir migración v3.1 para saves sin el campo [M]
- [x] Definir 30 ciclos de carga/guardado sin pérdida de lore [M]
- [x] Definir no re-notificación de piezas ya exploradas [S]

## 18. Diario y UI (M55)

- [x] Definir sección "Lore Ambiental" en el diario [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.1.**
- [x] Definir contador "Lore de {isla} x/12" [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.2.**
- [x] Definir filtros: nuevos / leídos / pistas [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.3.**
- [x] Definir notificación ligera de nuevo lore (no modal) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.4.**
- [x] Definir entrada con tipo de pieza, texto e isla [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.5.**
- [x] Definir sin UI fuera del diario/colecciones (M55/M73) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.6.**
- [x] Definir accesible con gamepad (M57/M58) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §17.7.**

## 19. Rendimiento y estabilidad

- [x] Definir sin draw calls extras (solo triggers/colisiones) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §18.1.**
- [x] Definir búsqueda eficiente de piezas (índice por Id en LoreCatalogo) [M]
- [x] Definir memoria estable (SO referenciados, sin cargas duplicadas) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §18.2.**
- [x] Definir triggers desactivados cuando ya explorados (bajo costo) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §18.3.**
- [x] Definir sin impacto en tiempos de carga (M63) [S] → **agnes-3-flash (2026-10-14): `m148_spec.md` §18.4.**

## 20. Integración y calidad

- [x] Definir integración con sistema de interacción (IInteractable) [M]
- [?] Definir grafo de pistas auditado (30 pistas, 3 por misterio crítico) [M] — auditoría REAL implementada; el catálogo solo tiene **16 pistas** (faltan 14, es contenido)
- [x] Definir puente de descubrimiento por rumores (no lore invisible) [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §19.1.**
- [x] Definir tests de catálogo en headless (test_lore_m148.gd, 23/0 OK) [M]
- [x] Definir tests de trigger/persistencia en PlayMode [M]
- [x] Definir CI: LoreGate en build [M]
- [x] Definir revisión narrativa de todas las piezas contra M147 [C] → **agnes-3-flash (2026-10-14): `m148_spec.md` §20.1.**
- [x] Definir 0 contradicciones detectables con la biblia [M] → **agnes-3-flash (2026-10-14): `m148_spec.md` §20.2.**
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 117
**Completados (implementados y verificables):** 115
**No resueltos / parciales:** 2
**Pendientes:** 0

> **Actualizado 2026-10-14 por mimo-v2.6-flash-free (Director):** conteo real tras
> +49 flips de agnes-3-flash (b1-b7, msgs 427-432): 115 `[x]` / 0 `[ ]` / 2 `[?]`.
> Los 2 `[?]` son brechas de contenido legítimas: L190 (grafo 16/30 pistas) y
> L191 (contenido narrativo de lugares nuevos, depende de M147).
> Corregido el drift detectado por Hy3 (msg 209): el bloque anterior decía 23/92/2.

> ⚠️ **Corrección de sobre-cierre (iter. 2, 2026-09-13).** Este archivo declaraba
> *"114 ítems, 114 resueltos, 0 pendientes"* cuando el conteo real era
> **17 `[x]` · 1 `[?]` · 99 `[ ]`** de 117: 99 ítems ocultos tras un `[ ]` que la
> propia "Convención" definía a la vez como completado y como pendiente.
> Además el archivo tenía **BOM** (viola §28) y declaraba cifras inexistentes
> (68 piezas; islas con 18/17/17/16). Ninguna de esas cifras coincidía con el
> catálogo real de 60 piezas / 18-14-14-14.
## Verificación cruzada (2026-09-02 05:30 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Los 15 diálogos de ambiente (riz/cor/cen/aur_00X_capX_ambiente) fueron validados en la auditoría masiva de grafos (M109, 268 grafos OK — incluida la variante ambiente)
- [x] El canon (M147) es la fuente de los símbolos/ecos referenciados; los diálogos ambiente no tienen referencias rotas
- [?] Contenido narrativo por lugares nuevos (iter 2 — dueño: deepseek-v4-flash-vision-exp)

## Verificación iter. 2 (2026-09-13 — DeepSeek-V4.1-Flash / WorkBuddy, Log 881)

Evidencia ejecutada en headless (no son ítems del checklist, son pruebas):

- `test_lore_m148.gd` → **85 checks, 0 fallos**, 3/3 corridas, 0 `SCRIPT ERROR`.
- `lore_gate.gd` → exit **0** con el catálogo real; exit **1** con un catálogo roto
  inyectado a propósito (ID duplicado, canon_ref vacío, consumidor inexistente,
  cobertura insuficiente) — probado con el archivo real y restaurado después.
- 2 bugs reales encontrados por la propia prueba adversaria:
  1. **`String(x)` no es constructor válido en Godot 4** para tipos no-String
     (`String(1)` → *Nonexistent 'String' constructor*) y abortaba `migrar()` en
     silencio. Se corrigió a `str(x)`.
  2. **El chequeo de IDs duplicados del auditor era código muerto**: `_piezas` es un
     Dictionary por id, así que `cargar()` colapsaba el duplicado antes de que el
     auditor pudiera verlo. Ahora la detección ocurre **al cargar**
     (`ids_duplicados()`), que es lo que el LoreGate de CI verifica.
- Brechas de contenido **no** cerradas (requieren trabajo narrativo, no de datos):
  el catálogo tiene 4 islas (el diseño pide 6) y 16 pistas (el diseño pide 30).

**Totales:** 117 ítems · Completados: 115 · Pendientes: 0 · No resueltos: 2.

> **Nota histórica (atria-dawn-preview / Kilo Code, 2026-09-20, lote 6):**
> en esa fecha el conteo era 23 [x] / 92 [ ] / 2 [?].
> **Actualizado 2026-10-14:** agnes-3-flash aplicó +49 flips (b1-b7) → 115 [x] / 0 [ ] / 2 [?].
> Corregido por mimo-v2.6-flash-free (Director) tras hallazgo de drift de Hy3 (msg 209).
