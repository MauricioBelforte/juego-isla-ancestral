# Contributing to juego-isla-ancestral

Version Godot: **?**

## Como contribuir

1. **Fork** el repositorio
2. Crea una **rama de feature**: `git checkout -b feat/mi-mejora`
3. **Commit** tus cambios: `git commit -m 'feat: description'`
4. **Push**: `git push origin feat/mi-mejora`
5. Abre un **Pull Request**

## Convenciones de codigo

- **GDScript**: snake_case para variables/funciones, PascalCase para class_name, tabs NO (usar 4 espacios)
- **Python**: PEP 8, type hints cuando sea posible
- **JSON**: 2 espacios de indentacion
- **Commits**: Conventional Commits (feat:, fix:, docs:, refactor:)

## Estructura del proyecto

```
game/isla-ancestral/      # proyecto Godot
  scripts/                # codigo del juego
    <modulo>/             # cada modulo en su carpeta
  data/                   # datos data-driven (JSON)
  tests/                  # tests headless
tools/                   # scripts Python del orquestador
  ci/                     # pipeline CI/CD (M118)
  legal/                  # copyright + creditos (M127, M131)
  postlaunch/             # checklist post-release (M144)
logs/                    # logs de iteraciones
DOCUMENTACION/           # plan-actual por modulo
```

## Reporte de issues

Los issues se reportan en GitHub Issues. Plantillas en `.github/ISSUE_TEMPLATE/`.
Para bugs, inclui: version de Godot, OS, pasos para reproducir, log de error.

## Licencia

Copyright (c) 2026 Isla Ancestral Team. Ver LICENSE.

_Generado automaticamente el 2026-09-03T21:37:10.374949_
