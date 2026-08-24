**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 148: Lore Ambiental (110 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Catálogo de lore (RF1/RF9)

- [ ] Definir catálogo central `LoreCatalogo` (SO/JSON) como única fuente [C]
- [ ] Definir modelo `PiezaDeLore` con Id, CanonRef, Isla, Tipo, TextoLore, ConsumidorId [M]
- [ ] Definir IDs únicos por pieza (formato LORE-{ISLA}-{NNN}) [S]
- [ ] Definir referencia obligatoria de canon (M147) en cada pieza [S]
- [ ] Definir cobertura mínima de 12 piezas por isla (6 islas = 72+) [M]
- [ ] Definir composición sugerida por isla (ruinas/objetos/arquitectura/vegetación/daños/murales/estatuas/mapas/canciones/rumores) [M]
- [ ] Definir plantillas de texto por tipo (ruina 3-5 líneas, objeto 2-3, etc.) [M]
- [ ] Definir validador de catálogo en CI (LoreGate) [M]
- [ ] Definir fallo de CI ante IDs duplicados o canonRef vacío [S]
- [ ] Definir índice por isla y por tipo en el catálogo [S]

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
- [ ] Definir TerrenoLoreService con hook de nueva temporada [M]
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

- [ ] Definir campo `loreExplorado` en save v3.x [M]
- [ ] Definir contadores por isla persistidos [M]
- [ ] Definir migración v3.1 para saves sin el campo [M]
- [ ] Definir 30 ciclos de carga/guardado sin pérdida de lore [M]
- [ ] Definir no re-notificación de piezas ya exploradas [S]

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
- [ ] Definir búsqueda eficiente de piezas (índice por Id) [M]
- [ ] Definir memoria estable (SO referenciados, sin cargas duplicadas) [M]
- [ ] Definir triggers desactivados cuando ya explorados (bajo costo) [S]
- [ ] Definir sin impacto en tiempos de carga (M63) [S]

## 20. Integración y calidad

- [ ] Definir integración con sistema de interacción (IInteractable) [M]
- [ ] Definir grafo de pistas auditado (30 pistas, 3 por misterio crítico) [M]
- [ ] Definir puente de descubrimiento por rumores (no lore invisible) [M]
- [ ] Definir tests de catálogo en EditMode [M]
- [ ] Definir tests de trigger/persistencia en PlayMode [M]
- [ ] Definir CI: LoreGate en build [M]
- [ ] Definir revisión narrativa de todas las piezas contra M147 [C]
- [ ] Definir 0 contradicciones detectables con la biblia [M]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 114
**Ítems resueltos por documentación:** 114 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)