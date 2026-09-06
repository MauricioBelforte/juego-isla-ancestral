# Log 639: M87 Localización — Iteración 4 robustez determinista + testings

**Fecha:** 2026-09-04
**Hora:** 03:07
**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 4 del módulo M87 (Localización) con foco en robustez determinista (mi especialidad: datos/serialización con tests headless). Se blindó el parseo de catálogos .po corruptos, se toleraron placeholders mal formados, se amplió la validación RF21 con estado por idioma, y se corrigió un bug real del contrato de plurales (n negativos excluidos). Se crearon los documentos de testings (06-Plan-Testings y 07-Resultados) que el módulo marcaba como pendientes. 4/4 suites de tests en verde (0 fallos).

## Cambios Realizados

### Código (game/isla-ancestral/scripts/localization/localization_manager.gd)
1. **Parseo .po robusto (T-084):** `_parse_po` ahora degrada con gracia ante `msgstr[ sin índice` o `msgstr[99]` (fuera de rango): la línea se omite con warning y el resto del catálogo parsea. Nuevos helpers `_indice_msgstr` / `_resto_msgstr` con tope defensivo de 8 formas. Antes `linea.split("]", 1)[1]` crasheaba con `msgstr[sin_indice]`.
2. **Placeholders mal formados (T-085/086/087):** `format_text` detecta `{` sin `}` (conteo) y deja el texto literal con warning dev; params sin valor quedan literales; params extra no usados se ignoran.
3. **RF21 ampliado:** nuevo `obtener_estado_catalogos()` con `{total, faltantes, vacias, ok}` por idioma — evidencia objetiva de cobertura (es 64 / en 64, 0 faltantes).
4. **Fix de contrato plural (bug real):** `_tr_clave`/`_buscar_texto` usaban `n >= 0`, excluyendo negativos; ahora `n != -1` (default sin plural). Detectado por el test: `tr_key(..., -3)` devolvía clave literal.

### Tests (game/isla-ancestral/scripts/localization/test_localizacion_iter4.gd) — NUEVO
- Parseo de .po corrupto (CP-01..03), placeholders edge (CP-04..07), estado de catálogos RF21 (CP-08..10), plurales n=0/1/2/-3 (CP-11), formatos 0/negativos/1e6/mediodía/fecha relleno (CP-12..14), regresión (CP-15).
- **Resultado: 0 fallos.**

### Documentación (DOCUMENTACION/87-Localizacion/plan-actual/)
- `06-Plan-Testings.md` creado: alcance, entorno, suites, 15 casos CP-01..CP-15, criterios de éxito, límites.
- `07-Resultados-Testings.md` creado: resultados por caso, fix aplicado, evidencia de cobertura 64/64, ruido del boot documentado, pendientes con dueño.
- `05-Checklist.md`: 22 ítems marcados [x] con evidencia (progreso 68 → 90/136).
- `04-Codigo.md`: Notas del Agente iteración 4 añadidas (historial conservado, iters 1-3 intactas).

## Archivos Modificados/Creados

| Archivo | Acción |
|---|---|
| `game/isla-ancestral/scripts/localization/localization_manager.gd` | Modificado (robustez) |
| `game/isla-ancestral/scripts/localization/test_localizacion_iter4.gd` | Creado |
| `DOCUMENTACION/87-Localizacion/plan-actual/06-Plan-Testings.md` | Creado |
| `DOCUMENTACION/87-Localizacion/plan-actual/07-Resultados-Testings.md` | Creado |
| `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md` | Modificado (22 [x]) |
| `DOCUMENTACION/87-Localizacion/plan-actual/04-Codigo.md` | Modificado (Notas iter. 4) |
| `CHECKLIST-GLOBAL.md` | Fila 87 → 🟡 90/136 |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Bloque M87 liberado |
| `DOCUMENTACION/TAREAS-POR-MODELO/deepseek-v4-flash/87-Localizacion/checklist.md` | 15 tareas T-### [x] |
| `DOCUMENTACION/TAREAS-POR-MODELO/deepseek-v4-flash/BACKLOG-MASTER.md` | Progreso actualizado |

## Evidencia de tests

```
test_localization.gd          → exit 0 · 0 fallos (núcleo)
test_localizacion_iter2.gd    → exit 0 · 0 fallos (persistencia/SO/contexto)
test_localizacion_iter3.gd    → exit 0 · 0 fallos (M88 fuentes)
test_localizacion_iter4.gd    → exit 0 · 0 fallos (robustez, NUEVO)
```

Cobertura de catálogos: `es.po` 64 claves (fuente) / `en.po` 64 claves → **0 faltantes** (`validar_catalogos` verde).

## Hallazgo honesto (no resuelto, documentado)

Existen **dos autoloads de localización** en `project.godot`: `Localization` (canónico, .po + TranslationServer, este módulo) y `LocalizationManager` (scripts/localizacion/, JSON + API `get_texto`/`set_idioma`, creado 2026-09-02). Decisión conservadora: **NO se tocó el duplicado** (núcleo de otro agente). Requiere unificación futura por el dueño de M87 o QA cruzado.

## Pendientes del módulo (con dueño)

- Selector de idioma visual en configuración → M53/M90 (V2 UI).
- QA visual de desbordes de texto inglés +30% → M53 + vía de visión (V1/V4).
- Traducción humana del catálogo de producción en crecimiento.
- Unificación de autoloads duplicados (hallazgo).