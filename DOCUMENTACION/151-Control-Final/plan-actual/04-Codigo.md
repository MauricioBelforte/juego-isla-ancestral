**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 151: Control Final

## 1. Archivos involucrados
El Control Final no toca el código del juego; agrega **herramientas de auditoría** (repositorio de ops/docs):

| Archivo | Función |
|---------|---------|
| `scripts/auditoria/generar_acta.py` | Genera el acta semaforizada (JSON→MD) con plantilla del 03-Diseno |
| `scripts/auditoria/importar_telemetria.py` | Trae métricas 72 h (M143): crash, fps p99, saves, sesiones |
| `scripts/auditoria/importar_encuestas.py` | Ingesta encuestas (CSV) → promedio por frente |
| `scripts/auditoria/verificar_puntos.py` | Valida que los 26 puntos tengan evidencia y estado |
| `DOCUMENTACION/151-Control-Final/plan-actual/acta-control-final.md` | Acta final firmada (generada por el script) |

## 2. Funciones clave
```python
# scripts/auditoria
def generar_acta(puntos: list, firma: tuple) -> str      # JSON → markdown
def importar_telemetria(backend, dias=3)                 # crash/fps/saves
def importar_encuestas(csv_path) -> dict                 # prom. por frente
def verificar_puntos(acta) -> list[str]                  # puntos sin evidencia
```

## 3. Datos / config
| Dato | Fuente | Uso |
|------|--------|-----|
| Telemetría 72 h | Backend M104/M105 | Crash < 0.5%, fps p99, 0 saves perdidos |
| Encuestas | CSV anónimo | Diversión ≥ 4/5 por frente |
| Criterios de puntos | `criterios-151.md` (S1) | Semáforo objetivo |
| Documentos admin | Carpeta segura + índice | Contratos, licencias, PI |
| Rating de rendición puzzles | Simulación M93 | < 15% |

## 4. Tests de la herramienta de auditoría
| Test | Qué valida |
|------|------------|
| `verificar_puntos` con acta incompleta | Detecta puntos sin evidencia |
| `importar_telemetria` con datos de prueba | Umbrales correctos |
| `importar_encuestas` con CSV mal formado | Error claro, sin crash |
| `generar_acta` con ⚠ | Incluye dueño y fecha del plan de acción |

## 5. Notas de integración
- La telemetría usada es la misma de M143 (sin duplicar infraestructura).
- El acta final se archiva en plan-actual del módulo y se vincula en el 05-Checklist.
- Los ⚠ pasan a la hoja de ruta de M144 (mismo JSON del acta).
- Los documentos administrativos se listan SOLO como referencias (nunca se exponen secretos/contratos en el repo público).