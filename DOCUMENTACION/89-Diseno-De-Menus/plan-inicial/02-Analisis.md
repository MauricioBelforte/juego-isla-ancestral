**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 89: Diseño de Menús

## 1. Análisis del dominio
Los menús cubren 3 dominios:

1. **Shell** (antes de la partida): principal, perfiles, slots, ajustes, créditos, salir. No depende de una partida activa.
2. **Pausa** (durante la partida): pausa el mundo y da acceso a todo el contenido.
3. **Contenido** (durante la partida): inventario, mapa, diario, colecciones, habilidades, relaciones; son vistas de managers.

El riesgo principal es la **heterogeneidad**: cada pantalla hecha a mano con estilos distintos. La solución centraliza un "ShellManager" con un sistema de navegación único.

## 2. Alternativas consideradas y decisiones

### D1: Arquitectura de las pantallas
- **A1 (UI Toolkit con UXML/USS)**: potente pero nueva curva y posible colisión con M53 existente.
- **A2 (UGUI/Canvas con prefabs de pantalla + ShellManager)**: consistente con el stack actual del proyecto (AGENTS.md §24 y M53), testable y con gamepad ya resuelto.
- **Decisión:** **A2** — UGUI/Canvas: `ShellManager` centraliza apertura/cierre, y cada pantalla es un prefab con su `View` (MVP).

### D2: Navegación
- **A1 (Input System UI de Unity sola)**: comportamientos de foco poco controlables.
- **A2 (Ring de navegación propio sobre el Input System)**: foco explícito, atajos tipo B/A/Start/Select, y fallback mouse. M58 exige foco visible.
- **Decisión:** **A2** — navegador con grafo de adyacencia por pantalla (áreas → botones) + atajos globales (NavigatorManager).

### D3: Perfiles y slots
- **A1 (un solo perfil con N slots)**: simple pero pierde la fragmentación de personas.
- **A2 (perfiles 1-3, slots 3-6 por perfil)**: soporta hogares compartidos sin pisar saves; integrado con M59.
- **Decisión:** **A2** — perfil es un directorio de slots; save v3.x guarda `perfil → slots[]`.

### D4: Ajustes
- **A1 (ajustes dentro del save de partida)**: confunde jugadores que cambian resoluciones entre perfiles.
- **A2 (archivo local `settings.json` fuera del save)**: global y persistente entre perfiles.
- **Decisión:** **A2** — `SettingsManager` escribe en local; se aplica en vivo (sin reiniciar salvo casos de vídeo).

### D5: Contenido en ítems pesados (colecciones grandes)
- **A1 (cargar todo al abrir)**: picos de memoria en islas con 80+ fichas.
- **A2 (vistas paginadas/scroll virtualizado + datos SO)**: 12-20 ítems por página con placeholder.
- **Decisión:** **A2** — paginación y virtualización; los SO son ligeros.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Navegación con gamepad rota en alguna pantalla | Media | Alta | Ring de navegación único + suite M57 que recorre cada pantalla |
| Pantallas con estética distinta | Media | Media | Guía de estilo + plantillas de pantalla (Header/Cuerpo/Footer) |
| Perfiles/slots con saves rotos | Media | Alta | Tests de 30 ciclos + migración M59 |
| Ajustes que no se aplican al instante | Media | Media | Aplicación en vivo + test por categoría |
| UI con lógica de gameplay | Baja | Alta | Regla AGENTS.md §9 verificada en code review |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Shell** | Menú principal, continuar, nueva, cargar, créditos, salir + navegación |
| **F2 Perfiles/slots** | Gestión con resúmenes y persistencia (M59) |
| **F3 Ajustes** | Controles, accesibilidad, audio, gráfica; settings.json local |
| **F4 Pausa** | Pausa del mundo + reapertura de estado (M07) |
| **F5 Contenido** | Inventario, mapa, diario, colección, habilidades, relación (conectados a managers) |

## 5. Métricas de éxito
1. 21 pantallas navegables con gamepad y mouse (suite M57: 0 atascos).
2. 30 ciclos de perfiles/slots sin pérdida (M59).
3. Playtest de 5 usuarios: 0 desvíos en continuar/nueva/cargar.
4. Ajustes aplicados en < 100 ms al cambiar el valor.
5. Apertura de cada pantalla < 300 ms sin picos de memoria (M61-M63).
6. 100% pantallas con foco visible y texto 150% (M58).

## 6. Notas para integración
- El ShellManager se integra con M53 (ya maneja modales/diálogos del juego).
- La pantalla de diario se extiende por M148 (sección Lore Ambiental) sin conflicto.
- El mapa (M28) provee datos por isla; la pantalla no viaja sola.
- Los ajustes de controles dependen del remapeo de M58 (campos de escucha de input).