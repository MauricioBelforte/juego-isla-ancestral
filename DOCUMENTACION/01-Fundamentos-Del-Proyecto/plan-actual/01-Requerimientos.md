# 01-Requerimientos.md — PLAN INICIAL GENERICO DEL PROYECTO

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Componente:** 01-Fundamentos-Del-Proyecto
**Estado:** Documentación inicial (plan genérico)

---

## 1. Problema

Se desea desarrollar un videojuego de mundo abierto tipo **Cozy Voxel / Life Simulation / Puzzle Adventure** cuyo título provisorio es *Proyecto Isla Ancestral*. El proyecto parte de un GDD (Documento Maestro de Diseño), una Biblia Narrativa completa y un Plan de Producción ya escritos por el usuario. El desafío es convertir esa documentación en un proyecto de software profesional y organizado, con arquitectura modular, documentación por componentes y un plan de trabajo desglosable.

### Contexto del problema

- El alcance completo del GDD (6+ islas, 6 templos con mecánica única cada uno, sistema oceánico completo, 4 finales, multijugador opcional) equivale a **varios juegos completos combinados**.
- Es necesaria una **v1.0 acotada y viable** (según el Plan de Producción) y un roadmap post-lanzamiento para el resto.
- Los problemas técnicos de mayor riesgo son: **sistema voxel** (chunking, mesh culling, streaming, persistencia de modificaciones), **navegación de NPC sobre terreno modificable**, **guardado de mundos grandes**, **iluminación, agua y rendimiento** a 60 FPS.
- Todo el contenido debe expandirse por etapas sin romper la arquitectura (estructura "Gran Vapor / islas mensuales" ya lo permite narrativamente).

---

## 2. Objetivos

### 2.1 Objetivo General

Crear la **base documentada del proyecto** (plan inicial genérico) que sirva como punto de partida para desglosar los **152 módulos** del plan maestro en componentes individuales con checklist propia de 100+ ítems cada uno.

### 2.2 Objetivos Específicos (v1.0 recomendada)

| # | Objetivo | Criterio de éxito |
|---|----------|-------------------|
| 1 | Isla Aurora completa (hub principal jugable) | Recorrible de punta a punta, con pobladores, economía y construcción funcionales |
| 2 | 1-2 islas adicionales vía el Gran Vapor (Coral y/o Verde) | Viaje ida/vuelta funcional con condiciones de desbloqueo |
| 3 | 2-3 Sellos obtenibles (Brisa, Marea, y opcional Raíz) con sus templos y herramientas | Cada templo resoluble con su herramienta única (Gancho Mecánico, Vara de Flujo, etc.) |
| 4 | Cierre narrativo parcial satisfactorio | Punto de historia que se sienta completo (descubrimiento de que Aurora está conectada a algo más grande) |
| 5 | Sistema voxel optimizado a 60 FPS | Mesh culling + face culling + threading sin microfreezes |
| 6 | Sistema de guardado versionado confiable | Saves compatibles entre versiones, sin corrupción, con backup |
| 7 | Cero violencia en todo el juego | Herramientas solo con "Eficacia de Recolección"/"Alcance de Acertijo" |
| 8 | Resto del GDD (Cenizas, Cielo, Elysia, finales, océano con submarino) | Planificado como roadmap post-lanzamiento documentado |

---

## 3. Alcance

### 3.1 Dentro del alcance (plan inicial genérico — ESTE COMPONENTE)

- Documentación maestra del proyecto (requerimientos, análisis, diseño, código planificado).
- División del proyecto en **152 módulos** (según `Plan-inicial-minimo.md`) como checklist base.
- Definición de decisiones de diseño claves (motor, arquitectura voxel, framework de puzzles, guardado, arquitectura de código).
- Estructura de documentación por componentes según `AGENTS.md`.

### 3.2 Fuera del alcance (fases posteriores — módulos individuales)

- Implementación de cada uno de los 152 módulos (se realizará en componentes `02-...` en adelante).
- Contenido post-v1.0 (Isla de las Cenizas, Islas del Cielo, Elysia, los 4 finales, capa oceánica con submarino).

---

## 4. Restricciones y Requisitos No Funcionales

| Tipo | Requisito |
|------|-----------|
| Filosofía | **Ausencia total de combate, muerte y penalizaciones violentas** |
| Rendimiento | 60 FPS objetivo; mundo voxel con caras visibles únicas (mesh/face culling) |
| Plataforma | PC (Windows prioritario), Steam; Steam Deck Verified como meta (soporte de mando obligatorio) |
| Motor | Unity (URP) o Godot 4.x (decisión abierta — ver `02-Analisis.md`) |
| Tecnología | C# (.NET Standard 2.1) o GDScript según motor; New Input System / Input de Godot |
| Documentación | Todo componente con 5 archivos principales + checklist ≥100 ítems; documentación en español |
| Arquitectura | Modular, desacoplada de la UI; ScriptableObject architecture / service locator / interfaces |
| Accesibilidad | Modo daltonismo, remapeo completo, subtítulos, tamaño de texto ajustable desde el día uno |
| Localización | Textos separados del código (tablas de claves) desde el día uno |
| Legal | Uso comercial de assets con licencia verificada; declaración de IA en Steam si corresponde |
| Presupuesto | Autofinanciado / Early Access; `Steam Direct Fee` (USD 100) previsto |
| IA de desarrollo | Claude Code / agentes MCP sobre Blender y el motor elegido para automatizar tareas repetitivas |

---

## 5. Criterios de Aceptación del Plan Inicial

- [ ] Los 152 módulos del plan maestro están identificados y listados en la `05-Checklist.md` de este componente.
- [ ] Cada módulo cuenta con prioridad, complejidad y dependencias preliminares.
- [ ] Las decisiones de diseño principales están documentadas (`02-Analisis.md`) con alternativas y recomendación.
- [ ] La arquitectura del código y el pipeline de producción están definidos (`03-Diseno.md`, `04-Codigo.md`).
- [ ] El `CHECKLIST-GLOBAL.md` refleja el estado real del componente 01.
- [ ] Un log de cambios documenta la creación en `Logs/`.

---

## 6. Fuentes del Requerimiento

| Fuente | Archivo |
|--------|---------|
| GDD / Idea base | `DOCUMENTACION/00-PLAN-INICIAL/IDEA-BASE-DEL-JUEGO.md` |
| Biblia narrativa | `DOCUMENTACION/00-PLAN-INICIAL/HISTORIA-DEL-JUEGO.md` |
| Checklist maestro (152 módulos) | `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` |
| Plan de producción | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` |
| Reglas del proyecto | `AGENTS.md` (raíz) |

---

## 7. Riesgos Iniciales Identificados

| Riesgo | Nivel | Mitigación |
|--------|-------|-----------|
| Scope creep (alcance gigante) | Alto | Alcance v1.0 acotado por escrito; roadmap documentado |
| Complejidad técnica del sistema voxel | Alto | Prototipo técnico en preproducción (cavar/colocar/guardar/cargar) |
| Saturación del género cozy en 2026 | Medio | Dirección de arte distintiva + narrativa profunda como diferenciador |
| Burnout de equipo chico/solo | Medio | Roadmap por fases con hitos concretos |
| Sorpresas fiscales/cambiarias (Argentina) | Medio | Contador con experiencia en exportación de servicios |
| Lanzamiento sin audiencia | Medio | Página de Steam y wishlists con meses de antelación |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M002** — Visión y Concepto | Visión y concepto del proyecto |
| **M003** — Documentación del Proyecto | Convenciones de documentación |
| **M004** — Game Engine | Decisiones de motor |
| **M006** — Control de Versiones | Versionado |
| **M078** — Legal — Propiedad Intelectual | Marco legal |
| **M133** — Gestión del Proyecto | Gestión del proyecto |
| **M145** — Diseño de Experiencia | Diseño de experiencia |
| **M152** — Principios Innegociables | Principios innegociables |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M002** — Visión y Concepto | Este módulo lo necesita |
| **M003** — Documentación del Proyecto | Este módulo lo necesita |
| **M004** — Game Engine | Este módulo lo necesita |
| **M006** — Control de Versiones | Este módulo lo necesita |
| **M078** — Legal — Propiedad Intelectual | Este módulo lo necesita |
| **M133** — Gestión del Proyecto | Este módulo lo necesita |
| **M145** — Diseño de Experiencia | Este módulo lo necesita |
| **M152** — Principios Innegociables | Este módulo lo necesita |

