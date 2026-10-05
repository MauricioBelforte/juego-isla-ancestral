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

---

## 6. Estado real de la implementación (SB-01/M151, 2026-10-04 — space-bunny-alpha)

> **This section documents a design/implementation DRIFT.** The §1 above is the original
> design by Deepseek V4 Flash; it is preserved. What actually exists:

| Especificado en §1 | Estado real |
|---|---|
| `scripts/auditoria/generar_acta.py` | ❌ **no existe** |
| `scripts/auditoria/importar_telemetria.py` | ❌ **no existe** |
| `scripts/auditoria/importar_encuestas.py` | ❌ **no existe** |
| `scripts/auditoria/verificar_puntos.py` | ✅ **existe** (SB-01/M151, Log 1289) — Python, 11 tests propios |
| `DOCUMENTACION/151-Control-Final/plan-actual/acta-control-final.md` | ❌ no existe (y el validador usa `.json`, no `.md`) |

**Y la implementación real que §1 no menciona** (iteraciones 1-2 del checklist, GDScript):

| Archivo real | Ruta real |
|---|---|
| `control_final_schema.gd` | `game/isla-ancestral/scripts/control_final/control_final_schema.gd` |
| `control_final_gate.gd` | `game/isla-ancestral/scripts/control_final/control_final_gate.gd` |
| `test_control_final_headless.gd` | `game/isla-ancestral/scripts/control_final/test_control_final_headless.gd` |
| `estado_release.json` | `game/isla-ancestral/data/control_final/estado_release.json` |

### Consecuencias (verificadas, no supuestas)

1. **El diseño §1 es Python; la implementación es GDScript.** No son la misma capa: el schema/gate
   corren *dentro de Godot* (`extends SceneTree`, `preload`), mientras que `verificar_puntos.py`
   corre *fuera*. No son duplicados: son capas distintas (in-game vs repo).
2. **`release-build.yml` NO ejecuta el gate** (verificado: el workflow corre tests, lint, build,
   checksums y release notes). Los 2 `[?]` del checklist siguen abiertos. **Dueño: s2 (M118).**
3. **`estado_release.json` está congelado en «2026-09-02 18:00»** y nada lo escribe. cablesar el
   gate sin refrescar la fuente daría **falsa seguridad** — un gate que siempre lee lo mismo.
4. La ruta citada en las iteraciones 1-2 del checklist (`scripts/control_final/…`) omite el prefijo
   `game/isla-ancestral/`; los archivos existen, la ruta no.

> **Nota de numeración (SB-13, 2026-10-05):** esta sección quedó como `## 5.` en una entrega previa, chocando con la `## 5. Notas de integración` preexistente. Renumerada a `## 6.` para que no haya dos secciones con el mismo número. El contenido **no cambió**. Verificado antes de renumerar: ninguna referencia externa citaba esta sección, y `## 6.` estaba libre.

## 4. Implementacion del gate (2026-10-05, atria-dawn-s2 / Kilo Code, Log 1320)

La version arriba (secciones 1-3) es el diseno original de actas. La implementacion
operativa del gate es **codigo real en CI**, agregada por el subdirector:

### Archivos del gate

| Archivo | Funcion |
|---|---|
| game/isla-ancestral/scripts/control_final/control_final_schema.gd | ControlFinalSchema: los 7 gates, erificar_gates(), gates_pendientes(), es_pendiente(), eredicto() |
| game/isla-ancestral/scripts/control_final/control_final_gate.gd | Gate CLI: lee estado_release.json, imprime CONTROL FINAL: RELEASE OK (exit 0) o CONTROL FINAL: BLOQUEADO (exit 1) |
| game/isla-ancestral/scripts/control_final/test_control_final_headless.gd | Suite headless del schema: **12/12 OK, EXIT 0** |
| scripts/regenerar_estado_release.py | Regenera el JSON con el estado real y medible de cada gate |
| scripts/test_regenerar_estado_release.py | Tests del regenerador: **9/9 OK** |
| game/isla-ancestral/data/control_final/estado_release.json | El acta (lo regenera CI) |

### Regla de los tres estados de un gate

Directiva del fundador: un gate sin dato medible no bloquea. Un gate en
estado_release.json puede ser:

- 	rue / alse (bool): cumplido o roto. alse bloquea.
- Dict {"estado": "PENDIENTE", "duenio": ..., "fecha": ..., "desc": ...}: nadie
  puede medirlo todavia. **No bloquea**, pero queda visible en el acta.

Gates fijos PENDIENTE: crash_rate_cero (M143/M104, necesita 72 h de telemetria) y
	extos_localizados (M87, necesita build). smoke_aprobado (M114) y
ackup_configurado (M107) quedan PENDIENTE cuando el workflow no los mide
(quality.yml no corre smoke ni backup).

### Cableo en CI (dos pipelines, dos comportamientos)

| Pipeline | Comportamiento | Detalle |
|---|---|---|
| .github/workflows/quality.yml job elease-gate | **Acta informativa, NO bloquea** (decision a del fundador) | Si el gate bloquea -> ::warning:: + exit 0. Sube el JSON como artifact. |
| .github/workflows/release-build.yml job elease-gate | **Bloqueante** (decision b) | Si el gate bloquea -> ::error:: + exit 1; no se publica. uild depende de [test, release-gate]. |

Ambos con if: always(): el gate se ejecuta **aunque la suite falle** (si no, se
skipea justo cuando hay gates rotos). Corregido en commit 5d0ffd5 tras detectar el
job skipped en el primer run.

### Gate de ceguera (trampa 100)

Si egenerar_estado_release.py no puede leer DOCUMENTACION/11-BUGS.md (exit 3),
**falla el job**: un "0 criticos abiertos" sobre un archivo vacio no es un aprobado,
es "no mire". Mismo patron que erificar_checklist.py (BUG-075). El unico override
es --criticos-abiertos N, que se usa solo en los tests.

### Estado real actual

El gate queda **BLOQUEADO** por zero_criticos_abiertos (BUG-078 y BUG-091, criticos
abiertos reales del proyecto). Es el comportamiento correcto: son bugs reales, no
errores de cableo.
