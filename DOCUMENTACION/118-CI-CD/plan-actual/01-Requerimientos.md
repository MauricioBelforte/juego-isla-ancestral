**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 118: CI/CD

## ID del Módulo
- **Código:** M118 (plan maestro: componente nuevo - Integración Continua/Despliegue Continuo)
- **Carpeta:** `DOCUMENTACION/118-CI-CD/`
- **Dependencias:** M117 (Build System), M103 (Logging), M112 (Testing Automático), M61 (Rendimiento)
- **Delegable desde:** diseño completo; implementación tras sistema de build/base

## 1. Problema

Automatizar los procesos de integración y despliegue del proyecto "Isla Ancestral" para reducir errores humanos, asegurar que builds testeados y firmados se desplieguen correctamente, y proporcionar retroalimentación rápida sobre la calidad del código. El sistema CI/CD debe integrarse con el motor Godot, respetar el flujo de trabajo cozy del proyecto y permitir que tanto builds de desarrollo como releases se generen de manera confiable. Debe considerarse la naturaleza offline-first del proyecto y la necesidad de mantener la privacidad del usuario en los logs.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Pipeline de integración | Build automático en cada commit a ramas principales |
| RF2 | Pipeline de pruebas | Ejecución automática de tests unitarios y de integración |
| RF3 | Build de desarrollo | Generación de ejecutable de desarrollo con símbolos y logs |
| RF4 | Build de release | Generación de build optimizado sin símbolos de debug |
| RF5 | Despliegue automático | Despliegue a itch.io o plataforma designada al marcar tag de versión |
| RF6 | Notificaciones de fallo | Alertas por correo o chat cuando un build falla |
| RF7 | Calidad de código | Verificación de style guide, límites de tamaño y anti-patterns |

## 3. Requisitos No Funcionales

- **Rendimiento:** Time de build < 10 minutos para build de desarrollo; < 15 minutos para release
- **Fiabilidad:** Tasa de éxito de build >= 95% en commits que pasan tests
- **Integración Godot:** Scripts custom para Godot Build Pipeline, no solo comandos genéricos
- **Privacidad:** Logs que no contengan datos personales del usuario final
- **Accesibilidad:** Documentación clara para que cualquier agente pueda mantener el sistema

## 4. Criterios de Aceptación

1. Pipeline de integración se ejecuta automáticamente en cada commit a main/develop.
2. Tests unitarios y de integración pasan antes de permitir el merge.
3. Build de desarrollo genera ejecutable jugable con < 10 min.
4. Build de release genera ejecutable optimizado sin símbolos de debug.
5. Despliegue automático funciona al crear tag de versión semver.
6. Notificaciones de fallo llegan al equipo de desarrollo.
7. Calidad de código verificada (style guide, tamaño de archivos, anti-patterns).
8. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M117** — Build System | CI/CD sobre build |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M117** — Build System | Depende de este módulo |

