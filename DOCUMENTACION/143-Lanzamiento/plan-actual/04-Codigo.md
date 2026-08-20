**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 143: Lanzamiento

## 1. Archivos involucrados
El lanzamiento es operativo: usa piezas ya existentes (M104/M105/M106/M101/M149/M152) y agrega scripts/módulos de **operación** (fuera del juego, bajo `Assets/Editor/` o repositorio de ops):

| Archivo | Función |
|---------|---------|
| `Assets/Editor/Launch/PublicarBuild.cs` | Verifica hash `rc-final` y publica en plataforma (solo con credenciales de CI) |
| `Assets/Editor/Launch/VerificarPublicacion.cs` | Chequea "visible" de la página tras publicar (todas las plataformas) |
| `scripts/ops/dashboard_crashes.py` | Lee crash de M105 → tablero + alerta si ≥ 0.5% |
| `scripts/ops/dashboard_reviews.py` | Ingesta de reviews (M106) → triaje y respuestas |
| `scripts/ops/dashboard_backend.py` | Latencia/errores del backend (M104) |
| `scripts/ops/dashboard_ventas.py` | Compras/errores de pago (M149, si aplica) |
| `scripts/ops/dashboard_saves.py` | Errores de save/cloud (M59/M60) |
| `scripts/ops/triaje_bugs.py` | Importa tickets M101 → cola hotfix 2.0.x |
| `scripts/ops/informe_72h.py` | Genera informe 4 ejes desde los dashboards |
| `scripts/ops/preservar_builds.py` | Archiva builds + manifiestos (M142) en bucket de backups |

## 2. Funciones clave
```python
# scripts/ops
def alerta_crash_rate(crash_rate, umbral=0.005)
def ingesta_reviews(plataforma)            # M106
def generar_informe_72h(crash, reviews, backend, ventas, saves)
def archiviar_build(build_id, manifest)    # M142
def importar_tickets(severidad_p0p1)       # M101
```

## 3. Datos / config
| Dato | Fuente | Uso |
|------|--------|-----|
| Hash de build publicada | `version-manifest.json` (M142) | Verificación de publicación |
| Crash rate real | Backend M105 | Alerta 0.5% |
| Reviews | API plataforma (M106) | Triaje |
| Backend (latencia, 4xx/5xx) | Backend M104 | Disponibilidad 99.9% |
| Ventas/pagos (si aplica) | API M149 | Transacciones |
| Errores de save/cloud | Backend M60 | Alerta ≥ 5 |
| Tickets | Tracker M101 | Cola hotfix |

## 4. Tests / verificaciones previas al día 0
| Suite | Qué valida |
|-------|------------|
| Simulación de publicación (staging) | Orden de pasos del runbook sin tocar producción |
| Test de alertas | Umbrales disparan notificaciones correctas |
| Test de ingesta de reviews | Datos de prueba se trian y etiquetan |
| Test de informe 72 h | Formato y 4 ejes completos con datos de prueba |
| Test de preservación | Archivo y recuperación de build simulada |

## 5. Runbook ejecutable (resumen para T0)
1. `python scripts/ops/preservar_builds.py --build rc-final` → backup listo.
2. Publicar página (CI con credenciales de CI, nunca locales) → `VerificarPublicacion`.
3. Liberar build → verificar hash (PublicarBuild).
4. Publicar tráiler y comunicado.
5. Abrir los 5 dashboards + guardias.
6. Triaje cada 12 h; informe 72 h al cierre.

## 6. Notas de integración
- Todos los scripts de ops son **léctura/escritura segura**: nunca tocan código del juego.
- Los secretos (tokens de plataforma) viven en variables de entorno del CI, jamás en el repo.
- Los dashboards quedan operando tras el lanzamiento (M144 los reutiliza).
- A M144 se entrega: informe 72 h, cola de bugs/hotfix, cola de contenido de comunidad y estado de builds preservadas.