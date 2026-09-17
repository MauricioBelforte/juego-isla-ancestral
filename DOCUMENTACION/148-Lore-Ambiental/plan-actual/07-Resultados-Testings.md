**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13

# 07-Resultados-Testings.md — Módulo 148: Lore Ambiental (iter. 2)

## 1. Suites ejecutadas

| Suite | Archivo | Resultado | Corridas |
|-------|---------|-----------|----------|
| Test del módulo | `game/isla-ancestral/scripts/lore/test_lore_m148.gd` | **85 checks · 0 fallos** | 3/3 determinista |
| Gate de CI | `game/isla-ancestral/scripts/lore/lore_gate.gd` | **exit 0** (catálogo real) · **exit 1** (catálogo roto inyectado) | 2 |
| `SCRIPT ERROR` | — | **0** | 3 |

```
=== Resumen M148: 85 checks, 0 fallos ===
TEST M148 OK — todos los checks pasaron
```

Salida del gate con el catálogo real:

```
[M148] Cobertura de lore ambiental:
  - aurora: 14 piezas [OK]
  - ceniza: 14 piezas [OK]
  - coral: 14 piezas [OK]
  - raiz: 18 piezas [OK]
  - pistas: 16 (consumidores registrados: 18)
[M148] LoreGate: OK — 60 piezas, 16 pistas, grafo consistente
```

## 2. Cobertura por bloque

| Bloque | Tema | Checks |
|--------|------|--------|
| A | Catálogo: carga, lookup, cobertura, índices | 12 |
| B | Auditor sobre el catálogo real + reporte | 4 |
| C | Auditor adversario (8 escenarios + vía real de carga) | 14 |
| D | Grafo de pistas (registro, `es_pista_valida`, grafo roto) | 7 |
| E | `TerrenoLoreService` (4 temporadas, copia defensiva) | 7 |
| F | `LoreSaveProvider` (marcado, no re-notificación, contadores) | 17 |
| G | Migración (sin sección, parcial, dedup, basura, coerción) | 10 |
| H | 30 ciclos save/load + coherencia de contadores | 6 |
| — | Anti-falso-verde (8 marcadores `_fin()`) | 8 |
| | **Total** | **85** |

## 3. Prueba negativa del gate (extremo a extremo)

Se reemplazó `data/lore/lore.json` por un catálogo deliberadamente roto
(2 piezas con el mismo id, una con `canon_ref` vacío y consumidor inexistente),
se ejecutó el gate y se restauró el archivo original:

```
[M148] LoreGate: 5 violaciones:
  - ID duplicado: dup
  - dup: canon_ref vacío
  - dup: consumidor desconocido 'no_existe'
  - Isla 'raiz': solo 1 piezas (mínimo 12)
  - Pista dup -> consumidor desconocido 'no_existe'
LoreGate FALLIDO — salida con código 1
```

Verificado después: `lore.json` restaurado con **60 piezas**.

## 4. Bugs reales encontrados por las pruebas

### Bug 1 — `String(x)` no es constructor válido en Godot 4

`LoreSaveProvider.migrar()` hacía `String(i)` sobre un `int` (id numérico en un
save manipulado):

```
SCRIPT ERROR: Invalid call. Nonexistent 'String' constructor.
```

En Godot 4 los constructores de `String` son `String()`, `String(String)`,
`String(StringName)`, `String(NodePath)`: **no existe `String(int)`**. El error
**aborta la función en silencio** (el patrón de falso verde ya conocido), de modo
que `migrar()` devolvía sin normalizar. Corregido a **`str(x)`** (válido para
cualquier tipo). El mismo patrón estaba latente en `lore_catalogo.gd`
(`String(d.get(...))`, `String(i)`) y se corrigió también: solo funcionaba
porque el JSON siempre entregaba `String`.

### Bug 2 — El chequeo de IDs duplicados del auditor era código muerto

`LoreAuditor.validar()` recorría las piezas y comparaba contra un `Dictionary`,
pero `LoreCatalogo._piezas` **ya es** un `Dictionary` por `id`: `cargar()`
colapsaba el duplicado (el segundo pisaba al primero) **antes** de que el
auditor pudiera verlo. La prueba sintética original "pasaba" porque inyectaba
los duplicados directamente en `_piezas`, saltándose la carga real.

Solución: la detección se movió **al cargar** (`LoreCatalogo.ids_duplicados()`),
y el auditor la reporta. La prueba negativa del gate lo confirma: ahora
`ID duplicado: dup` aparece en la salida.

> Este es exactamente el caso que justifica la prueba adversaria: un validador
> que siempre devolviera "OK" habría pasado la prueba anterior.

## 5. Brechas declaradas (no cerradas en iter. 2)

| Brecha | Diseño | Real | Naturaleza |
|--------|--------|------|------------|
| Islas con lore | 6 | 4 | Contenido narrativo (M147/M26) |
| Pistas | 30 | 16 | Contenido narrativo |
| Ubicaciones por temporada | 3 (12/año) | 1 (4/año) | Contenido + M74 |
| Trigger de inspección 3D | `TriggerLore` | no existe | Requiere escena/arte |
| UI del diario | sección + filtros | no existe | Depende de M55/M89 |

Ninguna de estas brechas es de tipo "datos/CI": son contenido, escena o UI, y
quedan **explícitamente abiertas** en el checklist (`[ ]`/`[?]`).

## 6. Determinismo

- 3 corridas consecutivas → `85 checks, 0 fallos` idéntico.
- El catálogo es data-driven y de solo lectura en las pruebas; la única prueba
  que escribe el JSON real es la negativa del gate, que **restaura** el original.
