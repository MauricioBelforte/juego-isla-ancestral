**Modelo:** Cline
**Plataforma:** Nemotron 3.5 Lightning

# 03-Diseno.md — Módulo 118: CI/CD

## 1. Arquitectura

```
M117 (Build System) ──► Godot Build Pipeline (scripts custom)
                       │
                       ▼
                       BuildSystem (autoload, singleton)
                       │
               ──► PipelineScript (build, test, deploy)
                       │
               ──► TestRunner (edición + play mode tests)
                       │
               ──► DeployScript (itch.io / plataforma designada)
                       │
               ──► NotificationManager (Discord webhooks)
                       │
               ──► QualityGate (style guide, anti-patterns)
                       │
                       ▼
                       Reportes CI (dashboard, logs)
```

## 2. Flujo de operación

1. **Commit a main/develop:** Trigger de pipeline CI automático
2. **Build:** Godot Build Pipeline compila el proyecto con compile/export templates
3. **Tests:** Se ejecutan tests unitarios y de integración (Edit Mode + Play Mode)
4. **Quality gate:** Verificación de style guide, tamaño de archivos y anti-patterns
5. **Artifact:** Si todo pasa, se genera build de desarrollo con símbolos y logs
6. **Deploy:** Si se crea un tag semver, se genera build de release y se despliega automáticamente
7. **Notifications:** Fallos reportados vía Discord/webhook al equipo de desarrollo

## 3. Tipos de builds

| Tipo | Configuración | Símbolos de debug | Optimización | Propósito |
|---|---|---|---|---|
| Desarrollo | `-d` flag | Sí | No | Testing local, debugging |
| Staging | Release mode | No | Sí | Build estable para QA |
| Release | `-r` flag | No | Sí | Build de publicación final |

## 4. Quality gates

- **Style guide:** GDScript conventions verificadas con linter
- **Tamaño de archivos:** Límite de 500KB por archivo fuente, 10MB por asset
- **Anti-patterns:** Detección de singletons globales, acoplamiento, magic strings
- **Tests:** 95% de los tests nuevos deben pasar
- **Build time:** Máximo 15 minutos por build

## 5. QA

- Test M117: build automático se ejecuta en cada commit a main
- Test de calidad: style guide y anti-patterns verificados
- Test de fiabilidad: tasa de éxito de build >= 95%
- Test de tiempo: build de desarrollo < 10 min, build de release < 15 min
- Test de notificaciones: fallos reportados vía Discord/webhook
- Test de idempotencia: build reproducible
- Test de atomicidad: sin estados parciales
- Test de versionamiento: artifacts versionados correctamente
