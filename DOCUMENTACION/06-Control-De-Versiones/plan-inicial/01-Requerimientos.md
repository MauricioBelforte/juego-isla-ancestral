**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 06: Control de Versiones

## ID del Módulo
- **Código:** M06 (plan maestro: sección 5 — Control de Versiones)
- **Carpeta:** `DOCUMENTACION/06-Control-De-Versiones/`
- **Dependencias:** M01 (Fundamentos). Dependen de este: todos los módulos (flujo de commits)

## 1. Problema

El repo ya existe y funciona (commits e044c29 → 7dbe1b6), pero sin política escrita: estrategia de ramas, versionado de builds, changelog y protección remota. Sin este módulo, cada decisión de versionado se toma por inercia y el día de la publicación no habrá trazabilidad de versiones.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Estrategia de ramas | Definir main + branches por módulo/feature; hotfix |
| RF2 | Política de commits | Mensajes en español, pasado descriptivo (AGENTS §4) |
| RF3 | Revisión de código | Proceso de revisión manual (1 persona) con checklist de convenciones |
| RF4 | Versionado de builds | Tags semver + changelog |
| RF5 | Assets pesados | Regla para LFS/binarios grandes (solo si aplica) |
| RF6 | Backups del repo | Remoto GitHub + backups locales periódicos |

## 3. Requisitos No Funcionales

- El repo debe ser clonable y reproducible (sin dependencias de archivos locales).
- Nada de binarios de motor en el repo (`.godot/`, builds).
- Comunicación 100% en español en commits/changelog.

## 4. Criterios de Aceptación

1. Los 21 puntos del plan maestro (sección 5) resueltos o con dueño.
2. Política de ramas escrita y aplicable desde el próximo módulo.
3. .gitignore verificado contra Godot (M04) y los binarios del motor.
4. Changelog creado con las versiones documentadas hasta hoy.