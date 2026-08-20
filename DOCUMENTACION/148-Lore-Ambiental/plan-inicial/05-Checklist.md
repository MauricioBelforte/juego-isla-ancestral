**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 148: Lore Ambiental (110 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Catálogo de lore (RF1/RF9)

- [x] Definir catálogo central `LoreCatalogo` (SO/JSON) como única fuente [C]
- [x] Definir modelo `PiezaDeLore` con Id, CanonRef, Isla, Tipo, TextoLore, ConsumidorId [M]
- [x] Definir IDs únicos por pieza (formato LORE-{ISLA}-{NNN}) [S]
- [x] Definir referencia obligatoria de canon (M147) en cada pieza [S]
- [x] Definir cobertura mínima de 12 piezas por isla (6 islas = 72+) [M]
- [x] Definir composición sugerida por isla (ruinas/objetos/arquitectura/vegetación/daños/murales/estatuas/mapas/canciones/rumores) [M]
- [x] Definir plantillas de texto por tipo (ruina 3-5 líneas, objeto 2-3, etc.) [M]
- [x] Definir validador de catálogo en CI (LoreGate) [M]
- [x] Definir fallo de CI ante IDs duplicados o canonRef vacío [S]
- [x] Definir índice por isla y por tipo en el catálogo [S]

## 2. Ruinas cuentan historias (P1)

- [x] Definir ruinas como piezas inspeccionables con micro-narrativa [M]
- [x] Definir mínimo 2-3 ruinas por isla con historia propia [C]
- [x] Definir ruinas vinculadas a templos sin contradecir M26 [M]
- [x] Definir ruinas con pistas de ubicación de otros secretos (opcional) [M]
- [x] Definir ruinas con estado visual (nunca "explorada" visualmente rota) [S]

## 3. Objetos cuentan historias (P2)

- [x] Definir objetos inspeccionables con procedencia (2-3 por isla) [C]
- [x] Definir objetos de ítems clave sin duplicar lore de M66 [M]
- [x] Definir objetos con historia de familia/cultura de la isla [M]
- [x] Definir objetos que reaccionan a temporada (lore extra en invierno) [S]
- [x] Definir objetos persistentes (no desaparecen tras inspección) [S]

## 4. Arquitectura cuenta historias (P3)

- [x] Definir estilo constructivo narrado por isla (cultura del constructor) [M]
- [x] Definir piezas de arquitectura inspeccionables (columnas, arcos, casas) [C]
- [x] Definir relación arquitectura ↔ biblia sin contradicciones [S]
- [x] Definir arquitectura que delata antigüedad (materiales por época) [M]
- [x] Definir arquitectura con pistas de acceso a templos (M26) [M]

## 5. Vegetación cuenta historias (P5)

- [x] Definir vegetación narrativa (bosques/árboles ancestrales) [C]
- [x] Definir árboles/plantas inspeccionables con historia local [M]
- [x] Definir vegetación vinculada a eventos pasados (quemas, curaciones) [M]
- [x] Definir vegetación con cambio estacional que revela lore (M50) [S]
- [x] Definir sin contradicción con la flora de colección (M73) [S]

## 6. Daños estructurales cuentan historias (P6)

- [x] Definir daños/derrumbes inspeccionables (grieta, torre caída) [C]
- [x] Definir daños con evento pasado narrado (catástrofe, batalla) [M]
- [x] Definir daños que ocultan pasadizos (destape por temporada - opcional) [M]
- [x] Definir coherencia: daños visibles también en M50 (no solo lore) [S]
- [x] Definir daños sin bloquear caminos principales (M28) [S]

## 7. Murales contienen pistas (P7)

- [x] Definir murales en templos con pistas de puzzles (M24) [C]
- [x] Definir mínimo 1 mural por templo (6 templos) [M]
- [x] Definir murales con lore de la historia del templo [M]
- [x] Definir grafo: mural → puzzle que desbloquea [M]
- [x] Definir murales legibles: pista usable sin devolver texto gigante [M]
- [x] Definir murales con estado en diario (visto/no visto) [S]

## 8. Estatuas contienen pistas (P8)

- [x] Definir estatuas con pistas de sellos/artefactos (M22/M13) [C]
- [x] Definir mínimo 2 estatuas-pista por isla [M]
- [x] Definir estatuas de personajes del canon (M147) [M]
- [x] Definir grafo: estatua → sello/artefacto que referencia [M]
- [x] Definir estatuas con diálogo inspección registrable en diario [S]

## 9. Mapas contienen pistas (P9)

- [x] Definir mapas antiguos coleccionables con pistas de secretos (M73) [C]
- [x] Definir mínimo 1 mapa por isla (6 mapas) [M]
- [x] Definir grafo: mapa → coleccionable/ruina oculta [M]
- [x] Definir mapa con lore de la zona mapeada [M]
- [x] Definir mapa con marcado persistente al recolectar [S]

## 10. Canciones contienen pistas (P10)

- [x] Definir canciones aprendidas por eventos/amistad (M20) [C]
- [x] Definir mínimo 2 canciones con mensaje cifrado (ritual, historia) [M]
- [x] Definir grafo: canción → rumor/NPC que responde [M]
- [x] Definir letras registrables en diario como pieza canción [M]
- [x] Definir canciones sin romper el audio (M41-M44) [S]

## 11. NPC cuentan rumores (P11)

- [x] Definir rumores locativos de NPC al nivel de amistad ≥ 4 (M20) [C]
- [x] Definir mínimo 3 rumores por isla (18+ rumores) [M]
- [x] Definir rumor → zona de lore no explorada (puente de descubrimiento) [M]
- [x] Definir rumor con cooldown (no repetirse) [S]
- [x] Definir rumor de temporada (cambia por estación) [M]

## 12. Peces revelan información (P12)

- [x] Definir lore en fichas de peces raros/descritos (M34/M73) [C]
- [x] Definir mínimo 6 peces con lore pivotal (mito de la isla) [M]
- [x] Definir pez-lore desbloqueado al capturarlo/completar ficha [M]
- [x] Definir grafo: pez → secreto de aguas profundas (M34) [M]
- [x] Definir pez con descripción de dieta/hábitat mezclada con mito [S]

## 13. Plantas revelan secretos (P13)

- [x] Definir lore en fichas de plantas de colección (M50/M73) [C]
- [x] Definir mínimo 6 plantas con secretos (cura, clima, ritual) [M]
- [x] Definir planta-lore desbloqueada al cosechar/ficha [M]
- [x] Definir grafo: planta → receta culinaria/curativa (M16) [M]
- [x] Definir planta con estacionalidad coherente (M33) [S]

## 14. Minerales activan ruinas (P14)

- [x] Definir minerales que activan ruinas/altaríos (M35/M24) [C]
- [x] Definir mínimo 3 minerales activadores (uno por isla/s). [M]
- [x] Definir grafo: mineral → ruina/altar que enciende [M]
- [x] Definir mineral con lore de extracción (dónde y cómo) [M]
- [x] Definir activación persistente (una vez encendida, queda) [S]

## 15. Terreno revela información (P15)

- [x] Definir cambios del terreno que destapan secretos (M50/M74) [C]
- [x] Definir 3 ubicaciones por temporada (12 anuales) [M]
- [x] Definir TerrenoLoreService con hook de nueva temporada [M]
- [x] Definir secretos de terreno registrados en el diario [M]
- [x] Definir sin recompensa duplicada de lore ya explorado [S]

## 16. Regla anti-infodump (P16/RF7)

- [x] Definir proporción mínima 60% lore ambiental vs diálogo explicativo [S]
- [x] Definir auditoría de muestreo de 10 zonas (2 por isla) [M]
- [x] Definir checklist de auditoría (¿explica algo que el mundo ya cuenta?) [M]
- [x] Definir plantillas de texto cortas por tipo de pieza [M]
- [x] Definir diálogos de NPC que avancen trama, no que expliquen el mundo [M]
- [x] Definir sin texto duplicado entre diálogo y pieza (una sola vía) [S]

## 17. Persistencia (RF8/M59)

- [x] Definir campo `loreExplorado` en save v3.x [M]
- [x] Definir contadores por isla persistidos [M]
- [x] Definir migración v3.1 para saves sin el campo [M]
- [x] Definir 30 ciclos de carga/guardado sin pérdida de lore [M]
- [x] Definir no re-notificación de piezas ya exploradas [S]

## 18. Diario y UI (M55)

- [x] Definir sección "Lore Ambiental" en el diario [M]
- [x] Definir contador "Lore de {isla} x/12" [M]
- [x] Definir filtros: nuevos / leídos / pistas [M]
- [x] Definir notificación ligera de nuevo lore (no modal) [S]
- [x] Definir entrada con tipo de pieza, texto e isla [M]
- [x] Definir sin UI fuera del diario/colecciones (M55/M73) [S]
- [x] Definir accesible con gamepad (M57/M58) [M]

## 19. Rendimiento y estabilidad

- [x] Definir sin draw calls extras (solo triggers/colisiones) [M]
- [x] Definir búsqueda eficiente de piezas (índice por Id) [M]
- [x] Definir memoria estable (SO referenciados, sin cargas duplicadas) [M]
- [x] Definir triggers desactivados cuando ya explorados (bajo costo) [S]
- [x] Definir sin impacto en tiempos de carga (M63) [S]

## 20. Integración y calidad

- [x] Definir integración con sistema de interacción (IInteractable) [M]
- [x] Definir grafo de pistas auditado (30 pistas, 3 por misterio crítico) [M]
- [x] Definir puente de descubrimiento por rumores (no lore invisible) [M]
- [x] Definir tests de catálogo en EditMode [M]
- [x] Definir tests de trigger/persistencia en PlayMode [M]
- [x] Definir CI: LoreGate en build [M]
- [x] Definir revisión narrativa de todas las piezas contra M147 [C]
- [x] Definir 0 contradicciones detectables con la biblia [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 114
**Ítems resueltos por documentación:** 114 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)