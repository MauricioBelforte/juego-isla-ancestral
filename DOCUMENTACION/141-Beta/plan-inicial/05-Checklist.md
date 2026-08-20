**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 141: Beta (124 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Contenido completo (RF1)

- [x] Definir inventario maestro de ítems (SO) contra lista M73 [C]
- [x] Definir inventario maestro de recetas contra M16 [C]
- [x] Definir inventario maestro de coleccionables 100/100 (M73) [M]
- [x] Definir inventario maestro de eventos estacionales (M74) [M]
- [x] Definir inventario maestro de misiones secundarias (M23) [M]
- [x] Definir herramienta Editor `ContentRegister` para detectar gaps [C]
- [x] Definir reporte de gaps en CSV para tickets [M]
- [x] Definir gate CI: build falla si gaps > 0 [M]
- [x] Definir contenido reutilizable desde pipeline M108 para cerrar faltantes [M]
- [x] Definir verificación semanal de inventario (W1-W6) [S]
- [x] Definir 6 islas finales con todos los ítems de M50 [C]
- [x] Definir 6 templos con todos los puzzles de M24/M26 [C]
- [x] Definir todos los NPC con rutinas y cadenas de amistad (M20/M23) [C]
- [x] Definir todas las recetas desbloqueables por isla (M16) [M]
- [x] Definir todos los artefactos obtenibles (M13) [M]
- [x] Definir 100% de coleccionables localizables sin guía (pistas en diario) [M]
- [x] Definir evento de cierre: festival con todos los NPC (M74) [M]
- [x] Definir sin ítems placeholder o provisionales en inventarios [S]
- [x] Definir reutilización de scripts de M140 sin modificación (estables) [S]

## 2. Historia completa (RF2/M153)

- [x] Definir el Acto 3 completo (crisis final con los 6 sellos) [C]
- [x] Definir epílogo en el faro tras el Sello 6 [M]
- [x] Definir el desenlace de Elysia en el Acto 3 [M]
- [x] Definir los diálogos finales sin texto placeholder [M]
- [x] Definir verificación CI: sin strings TODO/placeholder en diálogos [M]
- [x] Definir hook de `HistoriaMaster` para estado `EpílogoDisponible` [M]
- [x] Definir transición Sello6 → Acto3 → epílogo sin interrupciones [M]
- [x] Definir las 3 rutas de orden de sellos validadas (M66) [M]
- [x] Definir rama inválida (4ta combinación) rechazada por diseño [S]
- [x] Definir coherencia con biblia M147 en todos los hitos [M]
- [x] Definir misiones finales que cierren cabos de Alpha (M23) [M]
- [x] Definir créditos de cierre con equipo [S]
- [x] Definir registro de elecciones del jugador visibles en el epílogo [M]
- [x] Definir soporte de vuelta post-epílogo (continuar jugando) [M]

## 3. Puzzles completos (RF3/M24/M26)

- [x] Definir los 6 templos con puzzles en dificultad final [C]
- [x] Definir puzzle de tutorial por templo (primer cuarto) [M]
- [x] Definir pistas visibles dentro del templo (no frustración) [M]
- [x] Definir balance de dificultad cerrado con M93 simulado [M]
- [x] Definir modos de color alternativos para puzzles de color [M]
- [x] Definir puzzles de espejos con modo de alto contraste (M58) [M]
- [x] Definir puzzles de sombras/luz sin ceguera de color [M]
- [x] Definir recompensa final por templo (artefacto + lore) [S]
- [x] Definir verificación de resolución completa por templo [M]
- [x] Definir minimap de templo (M57) coherente con puzzles [S]
- [x] Definir guardado del estado de puzzle (M59) sin pérdidas [M]
- [x] Definir anti-softlock: salida de puzzle siempre disponible [S]

## 4. Islas completas (RF4/M50/M36)

- [x] Definir arte final de 6/6 islas sin prototipos [C]
- [x] Definir fauna final por isla (M36) [C]
- [x] Definir flora final por isla (M50) [C]
- [x] Definir pesca de especies final por isla (M34) [M]
- [x] Definir minería con vetas finales (M35) [M]
- [x] Definir clima y estaciones finales por isla (M32) [M]
- [x] Definir viajes entre islas en versión final (M28) [M]
- [x] Definir músicas de zona por isla (M41) [M]
- [x] Definir ambient de bioma por isla (M43) [M]
- [x] Definir iluminación y post-final por isla [M]
- [x] Definir densidades de objetos optimizadas por isla (LOD/culling) [M]
- [x] Definir zonas de carga por isla dentro de presupuesto (M63) [M]
- [x] Definir NPC y spawns finales por isla [M]
- [x] Definir coherencia de altura/orografía con la biblia (M147) [S]

## 5. Audio completo (RF5/M41-M44)

- [x] Definir música por acto (Acto1/2/3) final [M]
- [x] Definir música por zona/isla final [M]
- [x] Definir transiciones suaves por hitos de Sello [M]
- [x] Definir SFX de todas las interacciones finales [C]
- [x] Definir SFX de eventos estacionales [S]
- [x] Definir ambient por bioma con capas de estación [M]
- [x] Definir voces en hitos de historia (EN + ES) [M]
- [x] Definir mezcla dentro de presupuesto de audio (M61) [S]
- [x] Definir ducking de música con diálogos [S]
- [x] Definir buses de audio funcionando en Beta pública [S]
- [x] Definir verificación de audio en las 3 rutas de sellos [S]

## 6. Localización completa (RF6/M87)

- [x] Definir los 6 idiomas objetivo de M87 [M]
- [x] Definir glosario centralizado por término clave [M]
- [x] Definir archivo JSON por idioma [M]
- [x] Definir export/import CSV para traductores [M]
- [x] Definir revisión humana por idioma con checklist [M]
- [x] Definir subtítulos completos (UI, diálogos, eventos) [M]
- [x] Definir localización de logros y store (M149) [M]
- [x] Definir gate CI de claves por idioma (sin huecos) [M]
- [x] Definir nombres propios no traducidos (biblia) [S]
- [x] Definir localización de fechas/formatos por idioma [S]
- [x] Definir verificación de tamaño de textos (desbordes UI) [S]
- [x] Definir fallback de idioma (EN) ante clave faltante [S]
- [x] Definir ronda de revisión final en W5-W6 [S]

## 7. Accesibilidad implementada (RF7/M58)

- [x] Definir remapeo completo de controles (teclado/gamepad) [M]
- [x] Definir subtítulos configurables (tamaño/opacidad/fondo) [M]
- [x] Definir modos de color alternativos (puzzles y UI) [M]
- [x] Definir reducción de efectos visuales y sacudidas [M]
- [x] Definir Reduce Motion en pantallas de carga [S]
- [x] Definir Reduce Flashing en eventos [S]
- [x] Definir tamaño de texto escalable hasta 150% [M]
- [x] Definir dificultad de puzzles opcional (M58) [M]
- [x] Definir navegación completa con gamepad (M57) [M]
- [x] Definir soporte de lectura de diálogos (velocidad, pausa) [S]
- [x] Definir feedback háptico configurable [M]
- [x] Definir verificación de M58 en build final con checklist [M]

## 8. Rendimiento objetivo (RF8/M61-M63)

- [x] Definir presupuestos por zona en hardware mínimo y recomendado [C]
- [x] Definir ruta fija de 20 min para medición semanal [M]
- [x] Definir informe semanal de tendencia (M61) [M]
- [x] Definir gate CI de rendimiento (mínimo y recomendado) [M]
- [x] Definir memoria dentro de M62 en las 6 islas [M]
- [x] Definir tiempos de carga/streaming dentro de M63 [M]
- [x] Definir telemetría de sesión en la build Beta pública (M104) [M]
- [x] Definir FPS p99 ≥ objetivo en partida larga (60+ min) [M]
- [x] Definir draw calls/batching finales por zona [M]
- [x] Definir profilado de picos de memoria en transiciones [M]
- [x] Definir plan de acción por regresión (rollback de zona) [S]
- [x] Definir comparativa mínima vs recomendada al cerrar W6 [S]

## 9. Cero bugs críticos conocidos (RF9/M101/M112)

- [x] Definir severidades P0/P1/P2 (P0 crash/bloqueo, P1 pérdida de progreso, P2 menor) [S]
- [x] Definir triaje diario en W4-W6 [S]
- [x] Definir policy de duplicados en el tracker (M101) [S]
- [x] Definir fix con test de regresión adjunto (M112) [M]
- [x] Definir gate CI de bugs: falla si P0/P1 abiertos > 0 (W4+) [M]
- [x] Definir playtest público con encuesta de diversión (M152) [M]
- [x] Definir métricas semanales abiertos/cerrados/regresión [S]
- [x] Definir cierre con 0 P0/P1 y P2 con plan y dueño [S]
- [x] Definir inventario final de P2 para la ruta a RC (M142) [S]
- [x] Definir verificación de regresiones del 100% de features de Alpha [M]

## 10. Integración de plataformas (RF10/M149)

- [x] Definir perfiles de plataforma (PC Steam + definidos en M149) [M]
- [x] Definir abstracción `PlatformBridge` común [M]
- [x] Definir logros mapeados a hitos (M59) [M]
- [x] Definir cloud saves con manejo de conflictos (M60) [M]
- [x] Definir overlay de plataforma (invitados, capturas) funcionando [M]
- [x] Definir build de muestra por plataforma sin contenido de dev [M]
- [x] Definir compatibilidad de saves entre builds [M]
- [x] Definir telemetría por plataforma (M104) [S]
- [x] Definir documentación de desvíos por plataforma [S]
- [x] Definir prueba de instalación limpia por plataforma [M]

## 11. Store page final (RF11/M149)

- [x] Definir textos de store (descripción corta/larga, características) [M]
- [x] Definir 10 capturas finales de build real [M]
- [x] Definir tags y géneros correctos para descubrimiento [S]
- [x] Definir requisitos mínimos/recomendados verificados [S]
- [x] Definir caja de puntuación y configuraciones de la tienda [S]
- [x] Definir página en los idiomas de M87 [M]
- [x] Definir historial de notas de parche para el lanzamiento [S]
- [x] Definir material de prensa (kit de medios, 3 capturas HQ) [S]
- [x] Definir aprobación final del equipo de la store page [S]

## 12. Trailer final (RF12/M149)

- [x] Definir tráiler principal de 90s con captura real W6 [M]
- [x] Definir variante corta de 15s para redes [S]
- [x] Definir música del tráiler con dere-chos despejados [S]
- [x] Definir subtítulos de tráiler por idioma [M]
- [x] Definir versión sin texto para A/B en plataformas [S]
- [x] Definir revisión de ritmo con playtest brief [S]

## 13. Preparación para certificación (RF13/M149/M142)

- [x] Definir checklist de plataforma completo (users, políticas, contenido) [M]
- [x] Definir build estable final de W6 como candidato [M]
- [x] Definir manifest de contenido del candidato (hash/git tag) [S]
- [x] Definir verificación de instalación limpia y actualización funcional [M]
- [x] Definir guardado de logs de certificación (M149) [S]
- [x] Definir etiquetado `beta-rc-candidate` en el repositorio [S]
- [x] Definir acta de cierre Beta firmada [S]
- [x] Definir traspaso formal del candidato a M142 (RC) [S]
- [x] Definir verificación del checklist de cierre 100% [S]

## Totales

**Total de ítems:** 151
**Ítems resueltos por documentación:** 151 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)