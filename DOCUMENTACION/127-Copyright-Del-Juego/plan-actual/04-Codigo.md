**Modelo:** DeepSeek-V4.1-Flash (actualización iter. 2, Log 923) · especificación original SWE-1.6/Devin · núcleo de validación deepseek-v4-flash/Kilo Code
**Plataforma:** WorkBuddy

# 04-Codigo.md — Módulo 127: Copyright del Juego

## 1. Carácter del Componente

Módulo de **copyright del juego** para registro de copyright. Define registro de obras relevantes, código, arte, música, narrativa, logos y evidencia de autoría. Implementable inmediatamente (depende de M78 para legal general, M128 para identidad de marca, M41 para música). Es un módulo de documentación legal y procesos.

**06-Plan-Testings.md:** el módulo NO tenía plan de testings. La cobertura real vive en `game/isla-ancestral/scripts/legal/test_copyright_m127.gd` (13 checks, 0 fallos ×3) y en las 4 suites de `tools/legal/` (13/13, 10/10, 18/18, 12/12). Ver §6.

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

06-Plan-Testings.md                         → NO EXISTE en plan-actual/ (ver §6)
07-Resultados-Testings.md                   → NO EXISTE en plan-actual/ (ver §6)
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
