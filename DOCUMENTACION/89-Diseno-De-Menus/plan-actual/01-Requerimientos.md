**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 89: Diseño de Menús

## 1. Problema
El juego crece en pantallas (diario, colecciones, habilidades, relaciones, mapa) sin una arquitectura de UI única: los menús actuales son ad-hoc. Falta un **sistema de menús** completo, coherente, navegable con gamepad/teclado y mouse, accesible (M58), con estados claros (continuar/nueva/cargar), perfiles y slots, ajustes por categoría (controles, accesibilidad, audio, gráfica) y conexión con los managers (save M59, diario M55, colecciones M73, habilidades M71, relaciones M20, mapa M28).

## 2. Objetivo del módulo
Diseñar e implementar el **sistema integral de menús** del juego: shell completo (principal, perfil, slots, ajustes, pausa) y pantallas de contenido (inventario, mapa, diario, colección, habilidades, relación), con navegación por inputs estándar, estados persistidos y estética coherente (M06/M49).

## 3. Alcance (derivado del plan maestro: sección 88 "DISEÑO DE MENÚS")
1. **Menú principal** — portada con identidad visual del juego (M147).
2. **Continuar** — reanuda el save más reciente.
3. **Nueva partida** — flujo de creación con perfil.
4. **Cargar partida** — lista de slots con datos (isla, tiempo, sellos).
5. **Ajustes** — acceso a configuración global.
6. **Créditos** — créditos del equipo con estética del juego.
7. **Salir** — cierre de la aplicación con confirmación.
8. **Selección de perfil** — perfiles de jugador (1-3).
9. **Selección de slot** — slots por perfil (3-6).
10. **Pantalla de pausa** — pausa con opciones de menú.
11. **Pantalla de inventario** — ítems, herramientas, recetas (M16).
12. **Pantalla de mapa** — mapa del mundo con viaje (M28).
13. **Pantalla de diario** — misiones/lore (M55 + M148).
14. **Pantalla de colección** — peces, flora, fauna, minerales (M73).
15. **Pantalla de habilidades** — habilidades y ventajas (M71).
16. **Pantalla de relación** — amistades y niveles (M20).
17. **Pantalla de configuración** — ajustes globales por categoría.
18. **Pantalla de controles** — remapeo (M58).
19. **Pantalla de accesibilidad** — modos de accesibilidad (M58).
20. **Pantalla de audio** — volúmenes por bus (M41-M44).
21. **Pantalla gráfica** — resolución, calidad, vsync, fullscreen.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Shell completo: 21 pantallas accesibles por navegación consistente |
| RF2 | Navegación D-pad/teclas + mouse en todas las pantallas (M57/M58) |
| RF3 | Gestión de perfiles (1-3) y slots (3-6 por perfil) con nombres y datos resumen |
| RF4 | Continuar → último save válido; Nueva partida → crear perfil/slot sin borrar existentes |
| RF5 | Pausa con pause-true (tiempo detenido), congelación correcta del mundo (M07) |
| RF6 | Ajustes por categorías: controles, accesibilidad, audio, gráfica |
| RF7 | Persistencia de ajustes en archivo local (no dentro del save de partida) |
| RF8 | Pantallas de contenido servidas por managers (sin lógica de gameplay en UI, AGENTS.md §9) |
| RF9 | Estado de UI guardado al minimizar/pausar (última pantalla abierta) |
| RF10 | Créditos con scroll accesible y vuelta al menú |
| RF11 | Salir con confirmación y guardado previo si hay sesión activa |
| RF12 | Consistencia visual: tema común, fuentes (M58 tamaño +), iconografía, sin pantallas sin estilo |

## 5. Criterios de aceptación (DoD del módulo)
1. Las 21 pantallas navegables con gamepad y mouse sin atascos (test M57).
2. Perfiles y slots funcionando sin pérdida de datos (30 ciclos, M59).
3. Continuar/Nueva/Cargar sin confusión (playtest 5 usuarios, 0 desvíos).
4. Pausa detiene el mundo y se reanuda correctamente (M07).
5. Ajustes persistidos fuera del save de partida y aplicados al instante.
6. Pantallas de contenido sin lógica (solo managers/MVC, AGENTS.md §9).
7. Accesibilidad: todas las pantallas con texto al 150% y foco visible (M58).
8. Documentación plan-actual actualizada y firmada.

## 6. Restricciones
- **Aplican:** M07 (arquitectura/gestión de estado), M53 (UI), M55 (diario), M57 (gamepad), M58 (accesibilidad), M59 (save), M71 (habilidades), M20 (relaciones), M16 (inventario/recetas), M28 (mapa), M73 (colecciones), M41-M44 (audio), M06/M49 (estilo/arte).
- La UI no contiene lógica de gameplay: solo llamadas a managers (AGENTS.md §9).
- No se reescribe la arquitectura existente de M53: se extiende con el sistema de menús.
- Rendimiento: apertura de menús sin picos de carga (M61-M63); pantallas de contenido con streaming de datos paginado.

## 7. Dependencias
- M53 (UI ✅), M55 (Diario ✅), M73 (Colecciones ✅), M71 (Progresión ✅), M20 (Amistad ✅), M16 (Inventario ✅), M28 (Viajes ✅), M58/M57 (Accesibilidad/Gamepad ✅), M59 (Saves ✅), M41-M44 (Audio ✅), M148 (Lore Ambiental — en curso, sección diario).

## 8. Entregables del módulo
1. Sistema de menús (shell + 21 pantallas) con prefabs y navegación.
2. Manager de perfiles/slots (integración M59).
3. Persistencia de ajustes local.
4. Ring de navegación gamepad/mouse con foco visible.
5. Guía de estilo de menús (M06/M49) para las pantallas.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M053** — UI/UX | Menús |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M053** — UI/UX | Depende de este módulo |

