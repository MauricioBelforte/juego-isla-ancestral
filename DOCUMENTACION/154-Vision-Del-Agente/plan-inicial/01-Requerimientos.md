**Modelo:** stealth/ox-alpha
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 154: Visión del Agente

## 1. Problema

Los agentes de IA que documentan e implementan Isla Ancestral **no pueden ver el resultado visual** de su trabajo: renders de personajes voxel, escenas, UI, iluminación. Esto limita críticamente:

- La iteración de diseño de personajes (M11, M19, M45, M65) — el agente genera código pero no valida estética.
- La verificación visual de UI/UX (M53, M89) sin intervención manual del usuario en cada paso.
- El QA visual de iluminación (M49), partículas (M52), agua (M51) y clima (M32).
- La detección temprana de errores visuales (z-fighting, texturas rotas, escalados incorrectos).

**Directiva del usuario (2026-08-22):** documentar TODAS las alternativas de visión como opciones disponibles, con la **Opción 4 (godot-mcp comunitario) como fundamental y estándar permanente** de trabajo.

## 2. Objetivos

1. Documentar las **4 alternativas de visión** para agentes, como opciones complementarias (no excluyentes).
2. Establecer **godot-mcp comunitario como estándar obligatorio** del proyecto para trabajo continuo.
3. Definir el protocolo de iteración visual agente↔usuario para cada alternativa.
4. Especificar la instalación/configuración de cada vía en el entorno Windows + Cline + Godot 4.x.
5. Dejar registrado qué alternativa usar según el contexto (prototipado rápido, QA automatizado, validación artística).

## 3. Alcance

### Incluye
- Las 4 vías de visión:
  - **V1 — Capturas en chat:** el usuario pega screenshots; el agente los analiza con visión integrada.
  - **V2 — MCP custom de captura de pantalla:** servidor MCP en Python (PIL/ImageGrab) que captura ventana/pantalla de Windows y devuelve imagen base64.
  - **V3 — Export web + Playwright:** export HTML5 de Godot + skill webapp-testing para capturas automatizadas.
  - **V4 — godot-mcp comunitario (FUNDAMENTAL):** servidor MCP que controla el editor Godot (ejecutar escenas, leer consola de errores, capturar viewport).
- Protocolo de uso por escenario (diseño de personajes, QA UI, verificación de escenas).
- Requisitos de instalación y configuración (cline_mcp_settings.json).
- Integración con módulos existentes: M45 (Arte 3D), M48 (Animación), M53 (UI/UX), M61 (Rendimiento), M110 (Debug Menu), M112 (Testing).

### Excluye
- Entrenamiento de modelos de visión custom (fuera de alcance y costo).
- APIs de visión externas de pago como dependencia crítica.
- Visión en tiempo real a >5 FPS (no es necesario para iteración de diseño).

## 4. Requisitos Funcionales (RF)

| ID | Requisito |
|----|-----------|
| RF1 | El agente debe poder analizar imágenes pegadas en el chat (visión integrada) sin configuración adicional |
| RF2 | Debe existir un servidor MCP que capture la pantalla o ventana activa de Windows y devuelva la imagen al agente |
| RF3 | Debe existir un flujo de export web (HTML5) del juego verificable con Playwright/skill webapp-testing |
| RF4 | Debe estar instalado y configurado un godot-mcp que permita: ejecutar escenas, leer errores de consola, capturar el viewport |
| RF5 | Cada alternativa debe tener documentado su caso de uso recomendado y sus limitaciones |
| RF6 | El protocolo de iteración visual (generar → renderizar → capturar → analizar → ajustar) debe estar definido para cada vía |
| RF7 | La configuración MCP debe ser reproducible (instrucciones paso a paso para cualquier agente futuro) |

## 5. Requisitos No Funcionales (NFR)

| ID | Requisito |
|----|-----------|
| NFR1 | Latencia de captura ≤ 5 segundos por imagen (suficiente para iteración de diseño) |
| NFR2 | Sin dependencias de pago obligatorias (todo open source o incluido) |
| NFR3 | Compatible con Windows 10 + Cline + Godot 4.x (stack del proyecto) |
| NFR4 | Las instrucciones deben ser ejecutables por cualquier agente futuro sin conocimiento previo |
| NFR5 | Degradación elegante: si una vía falla, las otras siguen disponibles |
| NFR6 | Privacidad: las capturas no salen del equipo local salvo decisión explícita del usuario |

## 6. Criterios de Aceptación

- [ ] Los 4 archivos restantes del módulo documentan las 4 vías con detalle operativo.
- [ ] La V4 (godot-mcp) tiene sección destacada como **estándar fundamental** con guía de instalación completa.
- [ ] Existe una matriz de decisión "qué vía usar según el escenario".
- [ ] El checklist tiene ≥100 ítems verificables.
- [ ] plan-actual/ es espejo idéntico de plan-inicial/.