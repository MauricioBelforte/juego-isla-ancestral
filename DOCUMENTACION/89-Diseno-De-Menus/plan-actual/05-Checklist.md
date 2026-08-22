**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 89: Diseño de Menús (110 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Shell y arquitectura (RF1/RF12)

- [x] Definir ShellManager como singleton central de pantallas [M]
- [x] Definir 21 pantallas identificadas por enum IdPantalla [M]
- [x] Definir grafo de navegación por pantalla (áreas/adyacencias) [M]
- [x] Definir reutilización de la arquitectura UGUI/Canvas de M53 [S]
- [x] Definir principio MVC: Views solo llaman managers (AGENTS.md §9) [S]
- [x] Definir reapertura de la última pantalla tras pausa [M]
- [x] Definir pantallas con plantilla Header/Cuerpo/Footer común [M]
- [x] Definir sin lógica de gameplay dentro de scripts de UI [S]
- [x] Definir boot que engancha ShellManager al inicio [M]
- [x] Definir cierre limpio de la app desde el shell [S]

## 2. Menú principal (P1)

- [x] Definir portada con identidad visual del juego (M147) [M]
- [x] Definir botones: Continuar, Nueva, Cargar, Ajustes, Créditos, Salir [S]
- [x] Definir Continuar activo solo con save reciente [S]
- [x] Definir música del menú (M41) con volumen respetuoso [S]
- [x] Definir créditos de transición de pantalla sin atascos [S]
- [x] Definir versión del juego visible discreta [S]

## 3. Continuar (P2)

- [x] Definir reanudación del último save válido del perfil [M]
- [x] Definir manejo de múltiples perfiles (primero el selector) [M]
- [x] Definir mensaje de "sin partida" si no hay saves [S]
- [x] Definir validación de integridad del save antes de cargar (M59/M66) [M]
- [x] Definir reintento guiado ante save corrupto (backup M66) [M]

## 4. Nueva partida (P3)

- [x] Definir flujo de creación con selección de perfil/slot [M]
- [x] Definir protección anti-pisada de slot ocupado [M]
- [x] Definir confirmación explícita antes de sobreescribir [S]
- [x] Definir arranque con tutorial (M139) [S]
- [x] Definir creación de perfil si no existe [M]
- [x] Definir nombre editable del perfil (validación de caracteres) [S]

## 5. Cargar partida (P4)

- [x] Definir lista de slots con resumen (isla, horas, sellos, temporada) [M]
- [x] Definir slots borrables con confirmación [M]
- [x] Definir orden de slots (recién usado primero) [S]
- [x] Definir navegación gamepad en la lista [M]
- [x] Definir carga directa sin pantalla intermedia (o minimapa de carga) [S]

## 6. Ajustes (P5/P17)

- [x] Definir acceso a ajustes desde menú principal y pausa [S]
- [x] Definir categorías: Controles, Accesibilidad, Audio, Gráfica [M]
- [x] Definir persistencia local `settings.json` (fuera del save) [M]
- [x] Definir aplicación en vivo de cambios [M]
- [x] Definir botón "Restablecer por defecto" por categoría [S]
- [x] Definir indicación de cambios no guardados [S]

## 7. Créditos (P6)

- [x] Definir pantalla de créditos con scroll [M]
- [x] Definir ralentización al final del scroll [S]
- [x] Definir volver al menú desde créditos [S]
- [x] Definir créditos accesibles con gamepad (scroll continuo) [S]
- [x] Definir créditos con estética del juego (M06/M49) [S]

## 8. Salir (P7)

- [x] Definir confirmación de salida [S]
- [x] Definir guardado previo si hay sesión activa [M]
- [x] Definir cancelación sin efectos [S]
- [x] Definir salida limpia (procesos, cloud flush M60) [M]

## 9. Selección de perfil (P8)

- [x] Definir perfiles 1-3 por instalación [M]
- [x] Definir tarjetas de perfil con avatar/nombre/estadística [M]
- [x] Definir creación y eliminación de perfiles con confirmación [M]
- [x] Definir persistencia de perfiles en M59 [M]
- [x] Definir selector recordado (último perfil activo) [S]

## 10. Selección de slot (P9)

- [x] Definir slots 3-6 por perfil [M]
- [x] Definir vista de slots con datos resumen [M]
- [x] Definir auto-selección del último usado [S]
- [x] Definir slots bloqueados (sin save) mostrados grises [S]
- [x] Definir orden estable (no reordena al jugar) [S]

## 11. Pantalla de pausa (P10)

- [x] Definir apertura con Input de pausa (Start/Esc) [M]
- [x] Definir Pausar() del mundo (M07/M29) [M]
- [x] Definir opciones: Reanudar/Inventario/Mapa/Diario/Colección/Habilidades/Relación/Ajustes/Guardar/Salir al título [M]
- [x] Definir reanudación sin saltos de tiempo [M]
- [x] Definir cierre con estado de última pantalla [S]
- [x] Definir inmunidad a inputs de gameplay en pausa [M]

## 12. Pantalla de inventario (P11/M16)

- [x] Definir grid paginado de ítems (12-20 por página) [M]
- [x] Definir pestañas: Items, Herramientas, Recetas [M]
- [x] Definir detalle del ítem (descripción, stack, lore opcional) [M]
- [x] Definir uso/equipar con confirmación cuando aplica [M]
- [x] Definir sin lógica de inventario en la View (manager M16) [S]

## 13. Pantalla de mapa (P12/M28)

- [x] Definir mapa por isla con nodos de viaje [M]
- [x] Definir marcadores de progreso (sellos, colecciones por zona) [M]
- [x] Definir viaje rápido desde el mapa (confirmación) [M]
- [x] Definir leyenda de símbolos del mapa [S]
- [x] Definir datos del mapa desde TravelManager [S]

## 14. Pantalla de diario (P13/M55)

- [x] Definir pestañas: Misiones, Lore Ambiental (M148), Sellos, Estación [M]
- [x] Definir misiones activas con objetivo y estado [M]
- [x] Definir lore con contador por isla (M148) [M]
- [x] Definir sellos con prerequisitos visibles [M]
- [x] Definir info de estación/clima (M32/M74) [S]

## 15. Pantalla de colección (P14/M73)

- [x] Definir pestañas: Peces, Flora, Fauna, Minerales [M]
- [x] Definir fichas con arte, descripción y lore (M148) [M]
- [x] Definir contadores x/y por categoría [S]
- [x] Definir filtros: totales, faltantes, nuevos [M]
- [x] Definir descubrimiento nuevo con notificación [S]

## 16. Pantalla de habilidades (P15/M71)

- [x] Definir lista/árbol de habilidades con coste y efecto [M]
- [x] Definir desbloqueo desde la pantalla (XP/viento disponible) [M]
- [x] Definir visual de nivel por habilidad [S]
- [x] Definir sin lógica en View (ProgressionManager) [S]

## 17. Pantalla de relación (P16/M20)

- [x] Definir lista de NPC con nivel de amistad [M]
- [x] Definir regalo del día sugerido por NPC [M]
- [x] Definir hitos de amistad visibles [M]
- [x] Definir avatar/retrato de cada NPC [S]
- [x] Definir sin lógica en View (FriendManager) [S]

## 18. Pantalla de configuración (P17)

- [x] Definir sub-pantalla general con idioma, región, unidad [M]
- [x] Definir idioma aplicado en vivo (M87) [M]
- [x] Definir tiempo: formato 12/24 h [S]
- [x] Definir guardar al salir de configuración [S]

## 19. Pantalla de controles (P18/M58)

- [x] Definir lista de acciones remapeables [M]
- [x] Definir captura de teclas/ejes con escucha [M]
- [x] Definir restablecer por defecto [S]
- [x] Definir conflictos de bindings detectados [M]
- [x] Definir compatibilidad teclado + gamepad [M]

## 20. Pantalla de accesibilidad (P19/M58)

- [x] Definir modos de color alternativos [M]
- [x] Definir reduce motion / flashing [M]
- [x] Definir tamaño de texto 100-150% [M]
- [x] Definir subtítulos configurables [M]
- [x] Definir retraso de diálogos [S]
- [x] Definir visor de foco (anillo) configurable [S]

## 21. Pantalla de audio (P20/M41-M44)

- [x] Definir buses: Master, Música, SFX, Ambient, Voces [M]
- [x] Definir slider con prueba de sonido [S]
- [x] Definir config de subtítulos de voces [S]
- [x] Definir mono/estéreo para accesibilidad auditiva [M]

## 22. Pantalla gráfica (P21)

- [x] Definir resolución (lista + custom) [M]
- [x] Definir calidad (baja/media/alta/personalizada) [M]
- [x] Definir vsync y límite de fps [S]
- [x] Definir fullscreen/windowed/borderless [S]
- [x] Definir escala de UI [S]
- [x] Definir aplicar con opción de revertir (10 s) [M]

## 23. Tests y calidad (RF2/RF8/M112)

- [x] Definir suite Navigator: recorre 21 pantallas sin atascos [M]
- [x] Definir suite de perfiles/slots 30 ciclos [M]
- [x] Definir suite de pausa: congelar/reanudar [M]
- [x] Definir suite de settings ida y vuelta [M]
- [x] Definir metric de apertura < 300 ms sin picos de memoria [M]
- [x] Definir foco visible en todas las pantallas (M58) [S]
- [x] Definir playtest de 5 usuarios en continuar/nueva/cargar [M]

## Totales

**Total de ítems:** 124
**Ítems resueltos por documentación:** 124 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
