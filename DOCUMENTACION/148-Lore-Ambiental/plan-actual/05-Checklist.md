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
- **Conteo real de ítems: 117** (no 110/114 como decía la versión anterior)

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
- [ ] Definir composición sugerida por isla (ruinas/objetos/arquitectura/vegetación/daños/murales/estatuas/mapas/canciones/rumores) [M]
- [ ] Definir plantillas de texto por tipo (ruina 3-5 líneas, objeto 2-3, etc.) [M]
- [x] Definir validador de catálogo (LoreAuditor: IDs/canonRef/cobertura/grafo, 0 errores en catálogo real) [M]
- [x] Definir fallo de CI ante IDs duplicados o canonRef vacío [S]
- [x] Definir índice por isla y por tipo en el catálogo (por_isla/por_tipo) [S]

## 2. Ruinas cuentan historias (P1)

- [ ] Definir ruinas como piezas inspeccionables con micro-narrativa [M]
- [ ] Definir mínimo 2-3 ruinas por isla con historia propia [C]
- [ ] Definir ruinas vinculadas a templos sin contradecir M26 [M]
- [ ] Definir ruinas con pistas de ubicación de otros secretos (opcional) [M]
- [ ] Definir ruinas con estado visual (nunca "explorada" visualmente rota) [S]

## 3. Objetos cuentan historias (P2)

- [ ] Definir objetos inspeccionables con procedencia (2-3 por isla) [C]
- [ ] Definir objetos de ítems clave sin duplicar lore de M66 [M]
- [ ] Definir objetos con historia de familia/cultura de la isla [M]
- [ ] Definir objetos que reaccionan a temporada (lore extra en invierno) [S]
- [ ] Definir objetos persistentes (no desaparecen tras inspección) [S]

## 4. Arquitectura cuenta historias (P3)

- [ ] Definir estilo constructivo narrado por isla (cultura del constructor) [M]
- [ ] Definir piezas de arquitectura inspeccionables (columnas, arcos, casas) [C]
- [ ] Definir relación arquitectura ↔ biblia sin contradicciones [S]
- [ ] Definir arquitectura que delata antigüedad (materiales por época) [M]
- [ ] Definir arquitectura con pistas de acceso a templos (M26) [M]

## 5. Vegetación cuenta historias (P5)

- [ ] Definir vegetación narrativa (bosques/árboles ancestrales) [C]
- [ ] Definir árboles/plantas inspeccionables con historia local [M]
- [ ] Definir vegetación vinculada a eventos pasados (quemas, curaciones) [M]
- [ ] Definir vegetación con cambio estacional que revela lore (M50) [S]
- [ ] Definir sin contradicción con la flora de colección (M73) [S]

## 6. Daños estructurales cuentan historias (P6)

- [ ] Definir daños/derrumbes inspeccionables (grieta, torre caída) [C]
- [ ] Definir daños con evento pasado narrado (catástrofe, batalla) [M]
- [ ] Definir daños que ocultan pasadizos (destape por temporada - opcional) [M]
- [ ] Definir coherencia: daños visibles también en M50 (no solo lore) [S]
- [ ] Definir daños sin bloquear caminos principales (M28) [S]

## 7. Murales contienen pistas (P7)

- [ ] Definir murales en templos con pistas de puzzles (M24) [C]
- [ ] Definir mínimo 1 mural por templo (6 templos) [M]
- [ ] Definir murales con lore de la historia del templo [M]
- [ ] Definir grafo: mural → puzzle que desbloquea [M]
- [ ] Definir murales legibles: pista usable sin devolver texto gigante [M]
- [ ] Definir murales con estado en diario (visto/no visto) [S]

## 8. Estatuas contienen pistas (P8)

- [ ] Definir estatuas con pistas de sellos/artefactos (M22/M13) [C]
- [ ] Definir mínimo 2 estatuas-pista por isla [M]
- [ ] Definir estatuas de personajes del canon (M147) [M]
- [ ] Definir grafo: estatua → sello/artefacto que referencia [M]
- [ ] Definir estatuas con diálogo inspección registrable en diario [S]

## 9. Mapas contienen pistas (P9)

- [ ] Definir mapas antiguos coleccionables con pistas de secretos (M73) [C]
- [ ] Definir mínimo 1 mapa por isla (6 mapas) [M]
- [ ] Definir grafo: mapa → coleccionable/ruina oculta [M]
- [ ] Definir mapa con lore de la zona mapeada [M]
- [ ] Definir mapa con marcado persistente al recolectar [S]

## 10. Canciones contienen pistas (P10)

- [ ] Definir canciones aprendidas por eventos/amistad (M20) [C]
- [ ] Definir mínimo 2 canciones con mensaje cifrado (ritual, historia) [M]
- [ ] Definir grafo: canción → rumor/NPC que responde [M]
- [ ] Definir letras registrables en diario como pieza canción [M]
- [ ] Definir canciones sin romper el audio (M41-M44) [S]

## 11. NPC cuentan rumores (P11)

- [ ] Definir rumores locativos de NPC al nivel de amistad ≥ 4 (M20) [C]
- [ ] Definir mínimo 3 rumores por isla (18+ rumores) [M]
- [ ] Definir rumor → zona de lore no explorada (puente de descubrimiento) [M]
- [ ] Definir rumor con cooldown (no repetirse) [S]
- [ ] Definir rumor de temporada (cambia por estación) [M]

## 12. Peces revelan información (P12)

- [ ] Definir lore en fichas de peces raros/descritos (M34/M73) [C]
- [ ] Definir mínimo 6 peces con lore pivotal (mito de la isla) [M]
- [ ] Definir pez-lore desbloqueado al capturarlo/completar ficha [M]
- [ ] Definir grafo: pez → secreto de aguas profundas (M34) [M]
- [ ] Definir pez con descripción de dieta/hábitat mezclada con mito [S]

## 13. Plantas revelan secretos (P13)

- [ ] Definir lore en fichas de plantas de colección (M50/M73) [C]
- [ ] Definir mínimo 6 plantas con secretos (cura, clima, ritual) [M]
- [ ] Definir planta-lore desbloqueada al cosechar/ficha [M]
- [ ] Definir grafo: planta → receta culinaria/curativa (M16) [M]
- [ ] Definir planta con estacionalidad coherente (M33) [S]

## 14. Minerales activan ruinas (P14)

- [ ] Definir minerales que activan ruinas/altaríos (M35/M24) [C]
- [ ] Definir mínimo 3 minerales activadores (uno por isla/s). [M]
- [ ] Definir grafo: mineral → ruina/altar que enciende [M]
- [ ] Definir mineral con lore de extracción (dónde y cómo) [M]
- [ ] Definir activación persistente (una vez encendida, queda) [S]

## 15. Terreno revela información (P15)

- [ ] Definir cambios del terreno que destapan secretos (M50/M74) [C]
- [ ] Definir 3 ubicaciones por temporada (12 anuales) [M]
- [x] Definir TerrenoLoreService con hook de nueva temporada (4 temporadas, secretos JSON) [M]
- [ ] Definir secretos de terreno registrados en el diario [M]
- [ ] Definir sin recompensa duplicada de lore ya explorado [S]

## 16. Regla anti-infodump (P16/RF7)

- [ ] Definir proporción mínima 60% lore ambiental vs diálogo explicativo [S]
- [ ] Definir auditoría de muestreo de 10 zonas (2 por isla) [M]
- [ ] Definir checklist de auditoría (¿explica algo que el mundo ya cuenta?) [M]
- [ ] Definir plantillas de texto cortas por tipo de pieza [M]
- [ ] Definir diálogos de NPC que avancen trama, no que expliquen el mundo [M]
- [ ] Definir sin texto duplicado entre diálogo y pieza (una sola vía) [S]

## 17. Persistencia (RF8/M59)

- [x] Definir campo de exploración persistido (a_estado_exploracion/desde_estado, lista para M59/M60) [M]
- [x] Definir contadores por isla persistidos [M]
- [x] Definir migración v3.1 para saves sin el campo [M]
- [x] Definir 30 ciclos de carga/guardado sin pérdida de lore [M]
- [x] Definir no re-notificación de piezas ya exploradas [S]

## 18. Diario y UI (M55)

- [ ] Definir sección "Lore Ambiental" en el diario [M]
- [ ] Definir contador "Lore de {isla} x/12" [M]
- [ ] Definir filtros: nuevos / leídos / pistas [M]
- [ ] Definir notificación ligera de nuevo lore (no modal) [S]
- [ ] Definir entrada con tipo de pieza, texto e isla [M]
- [ ] Definir sin UI fuera del diario/colecciones (M55/M73) [S]
- [ ] Definir accesible con gamepad (M57/M58) [M]

## 19. Rendimiento y estabilidad

- [ ] Definir sin draw calls extras (solo triggers/colisiones) [M]
- [x] Definir búsqueda eficiente de piezas (índice por Id en LoreCatalogo) [M]
- [ ] Definir memoria estable (SO referenciados, sin cargas duplicadas) [M]
- [ ] Definir triggers desactivados cuando ya explorados (bajo costo) [S]
- [ ] Definir sin impacto en tiempos de carga (M63) [S]

## 20. Integración y calidad

- [x] Definir integración con sistema de interacción (IInteractable) [M]
- [?] Definir grafo de pistas auditado (30 pistas, 3 por misterio crítico) [M] — auditoría REAL implementada; el catálogo solo tiene **16 pistas** (faltan 14, es contenido)
- [ ] Definir puente de descubrimiento por rumores (no lore invisible) [M]
- [x] Definir tests de catálogo en headless (test_lore_m148.gd, 23/0 OK) [M]
- [x] Definir tests de trigger/persistencia en PlayMode [M]
- [x] Definir CI: LoreGate en build [M]
- [ ] Definir revisión narrativa de todas las piezas contra M147 [C]
- [ ] Definir 0 contradicciones detectables con la biblia [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 117
**Completados (implementados y verificables):** 23
**No resueltos / parciales:** 2
**Pendientes:** 92

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
