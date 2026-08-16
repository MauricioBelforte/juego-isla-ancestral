**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 06: Control de Versiones

## 1. Carácter del Componente

Módulo de **infraestructura y política** (git). La mayor parte ya está ejecutada en este repo; aquí se fija por escrito la política y las reglas. No requiere 06/07 (testing) — la verificación es con `git status/diff` y el changelog.

## 2. Archivos involucrados

| Archivo | Rol |
|---|---|
| `.gitignore` | Exclusión de generados (actualizado para Godot en M1) |
| `CHANGELOG.md` | **Nuevo** — historial de versiones (se crea en este módulo) |
| `scripts/test_scripts.py`, `generar_checklist_global.py`, `verificar_checklist.py` | Herramientas internas documentadas |
| `CHECKLIST-GLOBAL.md` | Estado global (se commitea en cada módulo) |
| `Logs/` | Registro de cambios por tarea |

## 3. Comandos de flujo (referencia)

```
git status                                           # auto-revisión 1
git diff origin/main                                 # auto-revisión 2 (protocolo push)
git add -A && git commit -m "<mensaje español"       # commit tras revisión
git tag v0.1.0                                        # release
git push origin main --tags                           # remoto + tags
```

## 4. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| Commits directos + QA cruzado | Todos los módulos |
| Semver v0.x → v1.0 | Publicación (M-66), builds |
| Changelog obligatorio | Todo cambio de versión |
| GameState con migraciones aparte | M59 Guardado |
| LFS solo si >100 MB | Arte/Audio cuando apliquen |

## 5. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Protección de rama `main` en GitHub (evaluar reglas) | Publicación (antes de colaboradores) |
| Backup local mensual automatizado | M06 (rutina) |
| Tag v0.1.0 al completar el prototipo M1 | Hito M1 |
| Agregar reglas Godot al .gitignore al crear proyecto | Hito M1 |

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 01:50:00
**Estado:** Completado (política documentada; implementación parcial ya existente)

### Lo que hice
- Resolví los 21 puntos del plan maestro (sección 5) con estado real verificado del repo.
- Diseñé estrategia de ramas, auto-revisión, semver, changelog y backups.
- Creé `CHANGELOG.md` con el historial actual.

### Lo que NO pude hacer (honestidad obligatoria)
- Activar protección de rama en GitHub → requiere consola web de GitHub (acceso manual del usuario).
- Backup local mensual → depende de una rutina/lugar fuera del repo que el usuario debe indicar.
- Confirmar el estado de Git LFS → depende de tamaño real de assets futuros.

### Recomendaciones para el próximo agente
- M07 (Arquitectura) no necesita tocar git: usará la política aquí definida sin cambios.
- En el hito M1: completar .gitignore Godot, tag v0.1.0 y primer changelog de código.