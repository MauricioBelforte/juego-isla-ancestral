**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 05: Lenguaje y Programación

## ID del Módulo
- **Código:** M05 (plan maestro: sección 4 — Lenguaje y Programación)
- **Carpeta:** `DOCUMENTACION/05-Lenguaje-Y-Programacion/`
- **Dependencias:** M04 (Game Engine → Godot 4.x). Dependen de este: M07 (Arquitectura) y todos los módulos de código.

## 1. Problema

Sin convenciones de lenguaje y código fijadas, cada módulo escribiría a su manera → reglas rotas, código ilegible, refactors costosos y agentes IA inconsistentes. Este módulo fija el lenguaje y las reglas de estilo que TODOS los módulos de código deben seguir.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Lenguaje principal del proyecto | GDScript (nativo Godot 4) + C# opcional (.NET) |
| RF2 | Convenciones de nombres | Clases PascalCase, variables snake_case (GDScript), `_privadas`, métodos PascalCase/snake_case |
| RF3 | Estructura de guiones por sistema | 1 directorio/script por sistema (nada monolítico) |
| RF4 | Arquitectura de software | Basada en M07; con separación lógica/presentación |
| RF5 | Patrones transversales | Eventos, estados, servicios, timers, pooling, logs, errores |

## 3. Requisitos No Funcionales

- Legibilidad para agentes IA y futura contratación (nada críptico).
- Código autocontenido: cada script se entiende sin contexto oral.
- Comentarios en español (o bilingües) solo donde aporten; nada de comentarios tontos.
- Sin deuda consciente: reglas de "done" por script.

## 4. Criterios de Aceptación

1. Todos los puntos del plan maestro (sección 4) resueltos o con dueño.
2. Guía de convenciones verificable (checklist aplicable a cualquier PR).
3. Compatible con Godot 4.x (M04) y la arquitectura de M07.
4. El sistema de eventos global y de errores diseñado (base de M59 Guardado).