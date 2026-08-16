**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 03-Diseno.md — Módulo 118: CI/CD

## 1. Arquitectura

```
M117 (Build System) ──► Configuración de Godot (scenes, settings)
                      │
                      ▼
                      BuildScript (Assets/Editor/BuildScript.cs)
                      │
              ──► Pipeline CI (GitHub Actions o GitLab CI)
                      │
              ──► Tests (Edit Mode + Play Mode)
                      │
              ──► Artifact Upload (builds, reports)
                      │
              ──► Deployment Script (itch.io o servidor propio)
                      │
                      ▼
                      Release Notes Generator
```

## 2. Flujo de operación

1. **Commit push:** Agente o desarrollador hace push a rama main o feature branch
2. **Pipeline CI se desencadena:** GitHub Actions lee el workflow `.github/workflows/ci-cd.yml`
3. **Build Godot:** Script `BuildScript.cs` compila Godot en modo headless
   - Build dev: incluye símbolos, logs, configuración de debug
   - Build release: quita símbolos, optimización máxima, sin logs de Debug
4. **Tests automáticos:**
   - Edit Mode: pruebas de funciones, validación de invariantes
   - Play Mode: tests de sistemas críticos (generación de mundo, UI, ahorro)
5. **Evaluación de calidad:** Verificación M111 (style guide, límites, anti-patterns)
6. **Éxito/failure:**
   - Si todos los tests pasan → Build exitoso, artifact subido
   - Si falla algún test → Build marcado como fallido, notificación enviada
7. **Despliegue:** Si el build es de release y pasa calidad → tag vX.Y.Z creado → despliegue a itch.io

## 3. Workflow GitHub Actions (esquema)

```yaml
name: CI/CD Isla Ancestral

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Godot
        uses: game-engine-tools/godot-install@v1
        with: { version: "4.4.1" }
      - name: Run Tests
        run: godot --headless -e -s run_tests.gd
      - name: Build Dev
        run: godot --headless --build win64 dev IslaAncestral
      - name: Build Release
        run: godot --headless --build release win64 IslaAncestral
      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with: name: build-dev path: build/win64/dev/
      - name: Notify
        if: failure()
        run: curl -X POST -H "Content-type: application/json" --data '{"text":"Build Isla Ancestral falló"}' DiscordWebhookURL
```

## 4. QA

- Test M118: pipeline se ejecuta en cada push a main/develop
- Test de build dev: generado en < 10 min, jugable
- Test de build release: generado en < 15 min, sin símbolos de debug
- Test de calidad: verificación M111 passed antes de considerar exitoso
- Test de despliegue: tag vX.Y.Z desencadena release a itch.io