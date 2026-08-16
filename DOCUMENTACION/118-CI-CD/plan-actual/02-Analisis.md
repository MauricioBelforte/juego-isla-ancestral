**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 02-Analisis.md — Módulo 118: CI/CD

## 1. Resolución de los puntos del plan

| # | Punto | Resolución |
|---|---|---|
| 1 | Pipeline de integración | Build automático en cada commit a main/develop usando Godot headless mode |
| 2 | Pipeline de pruebas | Tests edit-mode y play-mode automáticos; coverage mínimo 80% |
| 2 | Build de desarrollo | Godot --headless --build win64 dev - proyecto Isla Ancestral |
| 3 | Build de release | Godot --headless --build release win64 - quitar símbolos, optimizar |
| 4 | Despliegue automático | Script de despliegue a itch.io al crear tag vX.Y.Z en main |
| 5 | Notificaciones de fallo | Integración con GitHub Actions notifications o Discord webhook |
| 6 | Calidad de código | Script CodeQualityCheck integrado en pipeline (M111) |

## 2. Decisiones clave

1. **Godot Build Pipeline personalizado:** En lugar de usar herramientas genéricas, se crearán scripts en Godot Editor (Assets/Editor/BuildScript.cs) que aprovechan la API BuildPipeline.BuildPlayer() con configuraciones específicas del proyecto (resolución, calidad, splash screen cozy).

2. **Tests en Edit Mode y Play Mode:** Se ejecutarán tests unitarios en Edit Mode (verificación de funciones puras sin necesidad de entrar en juego) y Play Mode (tests de sistemas integrados). Coverage mínimo del 80% para considerar el build exitoso.

3. **Semantic Versioning para tags:** Los tags de versión seguirán semver (vMAJOR.MINOR.PATCH) y desencadenarán el despliegue automático. El versionado será consistente con CHANGELOG.md.

4. **Fallback manual:** Si el pipeline falla 3 veces seguidas, el sistema bloqueará los builds automáticos y requerirá intervención manual para prevenir builds rotos.

5. **Integración con M111 (Código de Calidad):** El pipeline verificará los estándares de M111 (nomenclatura, tamaño de clases/métodos, SOLID principles) antes de considerar el build exitoso.

## 3. Alternativas descartadas

- **GitHub Actions solo:** Descartado; Godot requiere scripts específicos de Godot Editor que no pueden ejecutarse puramente en GitHub Actions sin el editor compilado.
- **Despliegue a consolas al inicio:** Descartado; requiere licencias y SDKs de plataforma que no están disponibles en fase actual.
- **Pipeline sin tests automatizados:** Descartado; riesgo alto de builds rotos y retrocesos en calidad.
- **Builds ilimitados sin control:** Descartado; este proyecto prioriza calidad sobre velocidad de entrega.