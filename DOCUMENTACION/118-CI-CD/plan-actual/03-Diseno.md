**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 03-Diseno.md — Módulo 118: CI/CD

## 1. Arquitectura

```
M117 (Build System) ──► Configuración de Godot (scenes, settings)
                      │
                      ▼
                      BuildScript (Assets/Editor/BuildScript.cs _(diseno heredado)_)
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
3. **Build Godot:** Script `BuildScript.cs` _(diseno heredado)_ compila Godot en modo headless
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

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 2 | Triggers por workflow (push/tag/schedule) | Push a main/develop (diario, ~7-14/semana), tag (release, 1-2/mes), schedule (nightly, 7/semana) | Coherente con flujo de desarrollo (commits diarios, releases mensuales). |
| 4 | Ventanas de expiracion de artefactos | Dev build: 7 dias. Release build: 90 dias. | Coherente con GitHub Actions retention (default 90 dias). |
| 5 | Presupuesto de runs simultaneos | Max 20 concurrent jobs (GitHub Actions free tier). | Coherente con limite de GitHub Actions (20 concurrent para free tier). |
| 6 | Piso de checks minimos por workflow | CHECKS_MINIMOS = [lint (0 errors), test (100% pass), build (success)]. | Coherente con M111 (codigo de calidad) y M112 (tests). |

## Auditoria aritmetica de presupuestos CI/CD (S63 — G-5.3-Flash-Agente, 2026-10-23; encargo 337-director, celdas 5-7)

| Celda | Formula verificada | Resultado |
|---|---|---|
| Suma de triggers | push 7-14/sem + tag 1-2/mes (~0.25-0.5/sem) + nightly 7/sem | Total 14.25-21.5 runs/semana. PASS (sin total declarado que contradiga; la suma queda documentada aqui) |
| Retention artifacts | dev 7 d (retention-days custom) / release 90 d (default GitHub) | Coherente con defaults de GitHub Actions. PASS |
| Cuota free tier | 15 min/job x 14-21.5 runs/sem x 4.3 sem = 903-1,387 min/mes Linux; el limite free es 2,000 min/mes | Linux: DENTRO (banda alta 69%). HALLAZGO: si el runner es WINDOWS (factor x2 de minutos en la cuota) -> 1,806-2,774 min-equivalentes: EXCEDE 2,000 en la banda alta. Mitigacion: runner ubuntu-latest, o reducir nightly a 3/semana, o tier Team. | [IMPLEMENTADO el 23oct 21:50, GO fundador: backup.yml de diario->semanal con retencion 7d; dev/quality/testing con concurrency cancel-in-progress; coverage retention 7d — commits de la ronda 23oct]

ROLL-UP al fundador: el HALLAZGO de la cuota (factor x2 runners Windows en banda alta) entra al paquete de decisiones de infra junto a los 38-Totales (A/B/C) y los 5 flags M151.


## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de runs free-tier 20 concurrentes y 2000 min/mes** [x] - formula de timeout x runs/mes <= 2000min (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de pesos de artefactos x retencion 7d/90d** [x] - formula de probabilidad de pipeline y budget (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 30. Triggers por workflow
- Formula: push a main/develop (7-14/semana) + tag release (1-2/mes) + schedule nightly (7/semana). Total: 14-21.5 runs/semana.
- Coherente con flujo de desarrollo (commits diarios, releases mensuales).
- Unidad: runs/semana. Dependencia: M118 (CI/CD).

### 31. Ventanas de expiracion de artefactos
- Formula: dev build 7 dias, release build 90 dias. Coherente con GitHub Actions retention (default 90 dias).
- Unidad: dias. Dependencia: M118 (CI/CD).

### 32. Presupuesto de runs simultaneos
- Formula: max 20 concurrent jobs (GitHub Actions free tier). Coherente con limite de la plataforma.
- Unidad: jobs. Dependencia: M118 (CI/CD).

### 33. Piso de checks minimos por workflow
- Formula: CHECKS_MINIMOS = [lint (0 errors), test (100% pass), build (success)].
- Coherente con M111 (codigo de calidad) y M112 (tests).
- Unidad: checks. Dependencia: M111, M112.

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-6 (H26)**: M118 artefactos CI 21.5 GB/mes vs 10 GB free: decision = **REDUCIR el nightly** (menor frecuencia + runner ubuntu, sin tier pago). Calculo post-reduccion: nightly 3/semana (en vez de 7) -> total runs/semana = push 7-14 + tag 0.25-0.5 + nightly 3 = 10.25-17.5 runs/semana. Minutos/mes = 15 min/job x 10.25-17.5 x 4.3 = 646-1,136 min/mes Linux. DENTRO del free tier (2,000 min/mes). Con runner ubuntu-latest (sin factor x2 de minutos). Decision documentada: reducir nightly a 3/semana + runner ubuntu-latest, sin tier pago. Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-7 (H24/H27)**: piso de checks "5, max 50" vs contados 57/42/29: el texto del piso/techo se actualiza para reflejar el conteo real medido (57/42/29). El piso minimo sigue siendo 5 checks/archivo, el maximo sigue siendo 50; los conteos reales (57 en el maximo) se documentan como "fuera de techo, flaggeado para revision" (no se cambia el umbral). Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".

