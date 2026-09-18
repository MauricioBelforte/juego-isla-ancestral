**Modelo:** DeepSeek-V4.1-Flash (actualización iter. 2, Log 923) · especificación original SWE-1.6/Devin · núcleo de validación deepseek-v4-flash/Kilo Code
**Plataforma:** WorkBuddy

# 04-Codigo.md — Módulo 127: Copyright del Juego

## 1. Carácter del Componente

Módulo de **copyright del juego** para registro de copyright. Define registro de obras relevantes, código, arte, música, narrativa, logos y evidencia de autoría. Implementable inmediatamente (depende de M78 para legal general, M128 para identidad de marca, M41 para música). Es un módulo de documentación legal y procesos.

**06-Plan-Testings.md / 07-Resultados-Testings.md:** el módulo NO tenía plan de testings hasta la iter. 3 (Log 986), que creó ambos. La cobertura real vive en `game/isla-ancestral/scripts/legal/test_copyright_m127.gd` (13 checks, 0 fallos ×3) y en las **11 suites** de `tools/legal/` (**324 checks, 0 fallos**; las 7 nuevas suman 271). Ver §6 (iter. 2) y §7 (iter. 3).

## 2. Archivos involucrados (implementación)

```
# Datos (data-driven, dentro del proyecto Godot)
game/isla-ancestral/data/legal/copyright.json       → catálogo: 7 elementos + 5 políticas de copyright
game/isla-ancestral/data/arte2d/inventario_2d.json  → inventario real, usado como evidencia de metadata

# Código GDScript
game/isla-ancestral/scripts/legal/copyright_validator.gd  → validar(data) + reporte(errores)
game/isla-ancestral/scripts/legal/test_copyright_m127.gd  → suite headless (13 checks + guardián anti-falso-verde)

# Herramientas Python (fuera del runtime de Godot)
tools/legal/generate_copyright_docs.py      → NOTICE.md + LICENSE          (test 13/13)
tools/legal/generate_authors.py             → AUTHORS.md + CONTRIBUTING.md (test 10/10)
tools/legal/generate_copyright_register.py  → legal/copyright_register.md  (test 18/18)
tools/legal/signoff_check.py                → validador pre-release        (test 12/12)

# Documentos generados en la raíz del repositorio
NOTICE.md · LICENSE · AUTHORS.md · CONTRIBUTING.md
legal/copyright_register.md                 → entregable declarado por este módulo

06-Plan-Testings.md                         → creado en la iter. 3 (Log 986)
07-Resultados-Testings.md                   → creado en la iter. 3 (Log 986)
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M78 (Legal General):** Registro de copyright como parte del marco legal
- **M128 (Identidad de Marca):** Registro de logos como parte de branding
- **M41 (Música):** Registro de música como parte de sistema de audio

### Entrada (desde otros módulos)
- **M78 (Legal General):** Marco legal general para copyright
- **M128 (Identidad de Marca):** Logos para registro de copyright
- **M41 (Música):** Música para registro de copyright

### Configuración
- `legal/copyright_register.md` define registro de copyright

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear legal/copyright_register.md | **IMPLEMENTACIÓN INMEDIATA** |
| Verificar git logs para evidencia de autoría | **IMPLEMENTACIÓN MANUAL** |
| Verificar timestamps para evidencia de autoría | **IMPLEMENTACIÓN MANUAL** |
| Mantener borradores de arte, música, narrativa | **IMPLEMENTACIÓN MANUAL** |
| Registrar copyright formal (opcional, USCO) | **IMPLEMENTACIÓN MANUAL** |

## 5. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 15:44:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Definí copyright automatico en creacion (Berne Convention).
- Definí registro formal opcional (USCO, etc.).
- Definí evidencia de autoría (git logs, timestamps, borradores).
- Definí registro de código (copyright automatico, git logs).
- Definí registro de arte (copyright automatico, timestamps).
- Definí registro de música (copyright automatico, timestamps).
- Definí registro de narrativa (copyright automatico, timestamps).
- Definí registro de logos (copyright automatico, timestamps).
- Diseñé copyright_register.md con registro de copyright.

### Lo que NO pude hacer (honestidad obligatoria)
- Registrar copyright formal en USCO (requiere proceso manual y pago)
- Verificar legalmente git logs para evidencia de autoría (requiere abogado en disputas)
- Verificar legalmente timestamps para evidencia de autoría (requiere abogado en disputas)

### Recomendaciones para el primer agente (implementador)
- Crear copyright_register.md con registro de copyright.
- Verificar git logs para evidencia de autoría.
- Verificar timestamps para evidencia de autoría.
- Mantener borradores de arte, música, narrativa.
- Registrar copyright formal en USCO (opcional, USD 35-85 por registro).
- Probar que git logs muestren autoría correcta.
- Probar que timestamps sean consistentes.
- Probar que borradores estén accesibles.
- Probar que metadata esté presente.

## 6. Actualización de implementación (iter. 2 — DeepSeek-V4.1-Flash / WorkBuddy, Log 923)

Esta sección corrige §1 y §2, que describían el módulo como "documentación pura sin código" cuando
la implementación real ya existía y no estaba declarada.

### Qué existe de verdad (verificado en esta iteración)
- `copyright_validator.gd` — `validar()` devuelve `Array[String]` de errores (id vacío, id duplicado,
  sin nombre de elemento, sin titular, sin políticas) y `reporte()` los formatea. El test lo carga
  contra el JSON real.
- `test_copyright_m127.gd` — **13 checks, 0 fallos, ×3 corridas headless, EXIT 0, 0 `SCRIPT ERROR`**.
- `tools/legal/` — 4 herramientas, cada una con su suite: **13/13, 10/10, 18/18, 12/12**.
- `legal/copyright_register.md` — generado desde `copyright.json`; determinista (dos corridas
  byte-idénticas) y con modo `--check` (sale 1 si está desactualizado) para usarlo en CI.

### Correcciones de esta iteración
1. **Guardián anti-falso-verde** en `test_copyright_m127.gd`. Antes, un `SCRIPT ERROR` dentro de una
   función abortaba el resto **en silencio** y el resumen imprimía "0 fallos" (falso verde). Ahora
   cada bloque se registra con `_fin()` y un `_summary()` diferido nombra los bloques faltantes y
   sale con código 1. **Probado por inyección**: aborto real → `no terminaron: ["validator"]`,
   `11 checks, 1 fallos`, EXIT 1.
2. **Trampa medida (nueva):** `quit(1)` llamado desde `_process` **no termina el proceso** en esta
   build — el bucle se detiene pero el proceso queda vivo hasta el timeout externo (`EXIT 124`).
   Por eso el watchdog quedó como diagnóstico y la terminación real la hace el `_summary()` diferido.
   Medido: aborto en `_run()` → **EXIT 1 en 8,8 s**, sin cuelgue.
3. **`legal/copyright_register.md` ya no es una referencia colgante.** Era el entregable declarado en
   §2 y en `03-Diseno.md` §2, pero no existía ningún archivo en esa ruta.
4. **Nota de test desactualizada** corregida en `05-Checklist.md`: decía "9 checks" (estado de la
   versión previa); ahora son 13.

### Criterio del re-marcado de `05-Checklist.md`
- **[x]** cita un artefacto real o una sección **existente** de `03-Diseno.md`.
- **[?]** nombra el dueño externo o la acción humana requerida.
- **[ ]** es trabajo pendiente real de este módulo.
- Las 4 marcas previas de MiMo V2.5 se **preservan** (no se revierte el trabajo de un par).
- Resultado: **39 [x] · 25 [?] · 37 [ ]**.

### Por qué la reversión del 2026-09-14 (causa raíz)
agnes-2.5-flash cerró el módulo como `101/101` apoyándose en 18 notas "KnownIssue no bloqueante DoD"
que citaban `03-Diseno.md` §2.3, §3.1, §3.2, §4.2 y §4.3. **Esas secciones no existen**: el documento
tiene únicamente §1, §2 y §3. Las citas mezclaban referencias reales (p. ej. `inventario_2d.json`, la
mención a Berna en `NOTICE.md`) con otras inventadas. La auditoría revirtió el módulo completo.

### Pendientes reales de este módulo (no bloquean)
- Inserción automática de cabeceras de copyright en fuentes `.gd` / `.cs`.
- Sellado de tiempo criptográfico (SHA-256) sobre versiones maestras.
- Procedimientos operativos de registro formal USCO (4 documentos).
- Pantalla de licencias de terceros en el menú de opciones.

## 7. Actualización de implementación (iter. 3 — DeepSeek-V4.1-Flash / WorkBuddy, Log 986)

Iteración de **tooling de autoría**: 7 herramientas nuevas en `tools/legal/`, cada una con su
suite, y los 6 gates cableados en `.github/workflows/quality.yml` (job `legal-tools`).

### Qué se agregó

| Herramienta | Item | Qué hace |
|---|---|---|
| `insert_copyright_headers.py` | L105 | Cabecera de copyright + SPDX en `.gd`/`.cs`/`.py`. Idempotente, preserva el EOL **por archivo**, salta la línea de coding. Alcance declarado en `headers_scope.json`. |
| `timestamp_seal.py` | L106 | Sello SHA-256 de las versiones maestras: hash por archivo + `hash_arbol` + cadena `hash_previo`/`hash_cadena`. Alcance en `seal_scope.json`. |
| `scan_orphan_code.py` | L136 | Detecta código huérfano sin atribución: `SIN_HISTORIAL`, `SIN_CABECERA`, `AUTOR_PLACEHOLDER`. |
| `validate_asset_metadata.py` | L112 | Valida la metadata de copyright **embebida** (glTF `asset.copyright`, PNG `tEXt`, Vorbis `COPYRIGHT=`, WAV `ICOP`, EXIF `0x8298`) y detecta placeholders por magic number. |
| `audit_dependencies.py` | L141, L164 | Audita dependencias: addons declarados en `licencias.json`, archivo de licencia en disco, presencia en `NOTICE.md`, manifiestos excluidos del build, assets de terceros sin licencia y placeholders. |
| `dump_authorship_evidence.py` | L140 | Vuelca commits + diffstat por commit + autores + totales y firma el volcado con SHA-256 (`.sha256` hermano verificable). |
| `registros_db.py` | L139 | Base centralizada de números de registro, certificados y fechas de concesión (`data/legal/registros.json`), con contrato validado. |

### El techo de deuda: por qué un validador que siempre falla no sirve

`validate_asset_metadata.py` y `audit_dependencies.py` encuentran deuda **real y
legítima** que este módulo no puede cerrar (los `.glb` sin `asset.copyright` los
arregla el pipeline de exportación; los `.ttf` HTML son de M46/M88). Un gate de CI
que siempre sale 1 se desactiva en una semana.

La solución es el **techo de deuda** declarado en el `*_scope.json` de cada
validador: cada entrada tiene `tipo`, `patron` (glob con `**/`), `max`, `motivo` y
`dueño`. `--check` falla **solo con hallazgos NUEVOS** (los que superan el techo);
`--estricto` cuenta todo. La deuda queda **visible** (se imprime con su motivo y su
dueño) pero no bloquea; y agregar un asset sin copyright **sí** rompe CI, que es lo
que se quiere. Es el mismo criterio que el skill del proyecto aplica a las
heurísticas de localización: *una excepción invisible es un agujero negro*.

### Decisiones que se dejaron al dueño (no se resolvieron aquí)

1. **`addons/gdUnit4`** está en disco y **no** declarado en `licencias.json` ni en
   `NOTICE.md`. Declararlo toca artefactos legales (`NOTICE.md`, `LICENSE`) que
   genera este mismo módulo: la decisión de declarar o sacar el addon es del dueño.
   Queda en el baseline con motivo y dueño.
2. **Alcance de las cabeceras**: el item pide cubrir "los scripts de código fuente".
   Ampliarlo a todo el repo reescribe ~700 `.gd` y ~200 `.py` **de otros módulos**;
   en un worktree compartido eso arrastraría trabajo sin commitear ajeno. El alcance
   actual y el motivo de la ampliación pendiente están en `headers_scope.json`.
3. **Alcance del sellado**: ídem (`seal_scope.json`) — hoy sella las rutas legales;
   ampliarlo a `assets/`, `data/audio`, etc. multiplica el tamaño de cada sello.

### Hallazgos reales reportados (no arreglados)

- `addons/gdUnit4` sin declarar (autor *Mike Schulze*, v6.2.1, MIT).
- Los **3 `.ttf`** de `assets/fonts/` son páginas HTML 404 (**BUG-042**), dueño M46/M88.
- Los **434 `.glb`** exportados no llevan `asset.copyright` (dueño: pipeline de exportación).

### Bugs de las propias herramientas, encontrados por las suites

`detectar_contenido()` sin `lstrip()`; tabla de magic con OR en vez de AND en
formatos multi-firma; el parser Vorbis dejaba el NUL terminador en el valor;
`--json` contaminaba stdout con el resumen; `fnmatch` no da semántica globstar;
faltaba `import re`; un typo `FORMAT`/`FORMATO`. Detalle y cómo se detectó cada uno
en `07-Resultados-Testings.md` §5.
