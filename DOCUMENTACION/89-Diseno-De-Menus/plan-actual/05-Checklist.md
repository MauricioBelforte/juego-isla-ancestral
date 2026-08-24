**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 89: Diseño de Menús (110 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Shell y arquitectura (RF1/RF12)

- [ ] Definir ShellManager como singleton central de pantallas [M]
- [ ] Definir 21 pantallas identificadas por enum IdPantalla [M]
- [ ] Definir grafo de navegación por pantalla (áreas/adyacencias) [M]
- [ ] Definir reutilización de la arquitectura UGUI/Canvas de M53 [S]
- [ ] Definir principio MVC: Views solo llaman managers (AGENTS.md §9) [S]
- [ ] Definir reapertura de la última pantalla tras pausa [M]
- [ ] Definir pantallas con plantilla Header/Cuerpo/Footer común [M]
- [ ] Definir sin lógica de gameplay dentro de scripts de UI [S]
- [ ] Definir boot que engancha ShellManager al inicio [M]
- [ ] Definir cierre limpio de la app desde el shell [S]

## 2. Menú principal (P1)

- [ ] Definir portada con identidad visual del juego (M147) [M]
- [ ] Definir botones: Continuar, Nueva, Cargar, Ajustes, Créditos, Salir [S]
- [ ] Definir Continuar activo solo con save reciente [S]
- [ ] Definir música del menú (M41) con volumen respetuoso [S]
- [ ] Definir créditos de transición de pantalla sin atascos [S]
- [ ] Definir versión del juego visible discreta [S]

## 3. Continuar (P2)

- [ ] Definir reanudación del último save válido del perfil [M]
- [ ] Definir manejo de múltiples perfiles (primero el selector) [M]
- [ ] Definir mensaje de "sin partida" si no hay saves [S]
- [ ] Definir validación de integridad del save antes de cargar (M59/M66) [M]
- [ ] Definir reintento guiado ante save corrupto (backup M66) [M]

## 4. Nueva partida (P3)

- [ ] Definir flujo de creación con selección de perfil/slot [M]
- [ ] Definir protección anti-pisada de slot ocupado [M]
- [ ] Definir confirmación explícita antes de sobreescribir [S]
- [ ] Definir arranque con tutorial (M139) [S]
- [ ] Definir creación de perfil si no existe [M]
- [ ] Definir nombre editable del perfil (validación de caracteres) [S]

## 5. Cargar partida (P4)

- [ ] Definir lista de slots con resumen (isla, horas, sellos, temporada) [M]
- [ ] Definir slots borrables con confirmación [M]
- [ ] Definir orden de slots (recién usado primero) [S]
- [ ] Definir navegación gamepad en la lista [M]
- [ ] Definir carga directa sin pantalla intermedia (o minimapa de carga) [S]

## 6. Ajustes (P5/P17)

- [ ] Definir acceso a ajustes desde menú principal y pausa [S]
- [ ] Definir categorías: Controles, Accesibilidad, Audio, Gráfica [M]
- [ ] Definir persistencia local `settings.json` (fuera del save) [M]
- [ ] Definir aplicación en vivo de cambios [M]
- [ ] Definir botón "Restablecer por defecto" por categoría [S]
- [ ] Definir indicación de cambios no guardados [S]

## 7. Créditos (P6)

- [ ] Definir pantalla de créditos con scroll [M]
- [ ] Definir ralentización al final del scroll [S]
- [ ] Definir volver al menú desde créditos [S]
- [ ] Definir créditos accesibles con gamepad (scroll continuo) [S]
- [ ] Definir créditos con estética del juego (M06/M49) [S]

## 8. Salir (P7)

- [ ] Definir confirmación de salida [S]
- [ ] Definir guardado previo si hay sesión activa [M]
- [ ] Definir cancelación sin efectos [S]
- [ ] Definir salida limpia (procesos, cloud flush M60) [M]

## 9. Selección de perfil (P8)

- [ ] Definir perfiles 1-3 por instalación [M]
- [ ] Definir tarjetas de perfil con avatar/nombre/estadística [M]
- [ ] Definir creación y eliminación de perfiles con confirmación [M]
- [ ] Definir persistencia de perfiles en M59 [M]
- [ ] Definir selector recordado (último perfil activo) [S]

## 10. Selección de slot (P9)

- [ ] Definir slots 3-6 por perfil [M]
- [ ] Definir vista de slots con datos resumen [M]
- [ ] Definir auto-selección del último usado [S]
- [ ] Definir slots bloqueados (sin save) mostrados grises [S]
- [ ] Definir orden estable (no reordena al jugar) [S]

## 11. Pantalla de pausa (P10)

- [ ] Definir apertura con Input de pausa (Start/Esc) [M]
- [ ] Definir Pausar() del mundo (M07/M29) [M]
- [ ] Definir opciones: Reanudar/Inventario/Mapa/Diario/Colección/Habilidades/Relación/Ajustes/Guardar/Salir al título [M]
- [ ] Definir reanudación sin saltos de tiempo [M]
- [ ] Definir cierre con estado de última pantalla [S]
- [ ] Definir inmunidad a inputs de gameplay en pausa [M]

## 12. Pantalla de inventario (P11/M16)

- [ ] Definir grid paginado de ítems (12-20 por página) [M]
- [ ] Definir pestañas: Items, Herramientas, Recetas [M]
- [ ] Definir detalle del ítem (descripción, stack, lore opcional) [M]
- [ ] Definir uso/equipar con confirmación cuando aplica [M]
- [ ] Definir sin lógica de inventario en la View (manager M16) [S]

## 13. Pantalla de mapa (P12/M28)

- [ ] Definir mapa por isla con nodos de viaje [M]
- [ ] Definir marcadores de progreso (sellos, colecciones por zona) [M]
- [ ] Definir viaje rápido desde el mapa (confirmación) [M]
- [ ] Definir leyenda de símbolos del mapa [S]
- [ ] Definir datos del mapa desde TravelManager [S]

## 14. Pantalla de diario (P13/M55)

- [ ] Definir pestañas: Misiones, Lore Ambiental (M148), Sellos, Estación [M]
- [ ] Definir misiones activas con objetivo y estado [M]
- [ ] Definir lore con contador por isla (M148) [M]
- [ ] Definir sellos con prerequisitos visibles [M]
- [ ] Definir info de estación/clima (M32/M74) [S]

## 15. Pantalla de colección (P14/M73)

- [ ] Definir pestañas: Peces, Flora, Fauna, Minerales [M]
- [ ] Definir fichas con arte, descripción y lore (M148) [M]
- [ ] Definir contadores x/y por categoría [S]
- [ ] Definir filtros: totales, faltantes, nuevos [M]
- [ ] Definir descubrimiento nuevo con notificación [S]

## 16. Pantalla de habilidades (P15/M71)

- [ ] Definir lista/árbol de habilidades con coste y efecto [M]
- [ ] Definir desbloqueo desde la pantalla (XP/viento disponible) [M]
- [ ] Definir visual de nivel por habilidad [S]
- [ ] Definir sin lógica en View (ProgressionManager) [S]

## 17. Pantalla de relación (P16/M20)

- [ ] Definir lista de NPC con nivel de amistad [M]
- [ ] Definir regalo del día sugerido por NPC [M]
- [ ] Definir hitos de amistad visibles [M]
- [ ] Definir avatar/retrato de cada NPC [S]
- [ ] Definir sin lógica en View (FriendManager) [S]

## 18. Pantalla de configuración (P17)

- [ ] Definir sub-pantalla general con idioma, región, unidad [M]
- [ ] Definir idioma aplicado en vivo (M87) [M]
- [ ] Definir tiempo: formato 12/24 h [S]
- [ ] Definir guardar al salir de configuración [S]

## 19. Pantalla de controles (P18/M58)

- [ ] Definir lista de acciones remapeables [M]
- [ ] Definir captura de teclas/ejes con escucha [M]
- [ ] Definir restablecer por defecto [S]
- [ ] Definir conflictos de bindings detectados [M]
- [ ] Definir compatibilidad teclado + gamepad [M]

## 20. Pantalla de accesibilidad (P19/M58)

- [ ] Definir modos de color alternativos [M]
- [ ] Definir reduce motion / flashing [M]
- [ ] Definir tamaño de texto 100-150% [M]
- [ ] Definir subtítulos configurables [M]
- [ ] Definir retraso de diálogos [S]
- [ ] Definir visor de foco (anillo) configurable [S]

## 21. Pantalla de audio (P20/M41-M44)

- [ ] Definir buses: Master, Música, SFX, Ambient, Voces [M]
- [ ] Definir slider con prueba de sonido [S]
- [ ] Definir config de subtítulos de voces [S]
- [ ] Definir mono/estéreo para accesibilidad auditiva [M]

## 22. Pantalla gráfica (P21)

- [ ] Definir resolución (lista + custom) [M]
- [ ] Definir calidad (baja/media/alta/personalizada) [M]
- [ ] Definir vsync y límite de fps [S]
- [ ] Definir fullscreen/windowed/borderless [S]
- [ ] Definir escala de UI [S]
- [ ] Definir aplicar con opción de revertir (10 s) [M]

## 23. Tests y calidad (RF2/RF8/M112)

- [ ] Definir suite Navigator: recorre 21 pantallas sin atascos [M]
- [ ] Definir suite de perfiles/slots 30 ciclos [M]
- [ ] Definir suite de pausa: congelar/reanudar [M]
- [ ] Definir suite de settings ida y vuelta [M]
- [ ] Definir metric de apertura < 300 ms sin picos de memoria [M]
- [ ] Definir foco visible en todas las pantallas (M58) [S]
- [ ] Definir playtest de 5 usuarios en continuar/nueva/cargar [M]

## Totales

**Total de ítems:** 124
**Ítems resueltos por documentación:** 124 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
