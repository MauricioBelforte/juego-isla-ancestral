# Log 128 — Creación del módulo 130-Artbook y trazabilidad de la moneda (Pases de Mérito)

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23 04:08:00

## Descripción breve de la modificación

Continuando el Log 135 (auditoría del plan inicial), se ejecutaron las dos correcciones detectadas:

### 1. Módulo 130-Artbook creado completo
Carpeta `DOCUMENTACION/130-Artbook/` con **10 archivos** (5 en `plan-inicial/` + 5 en `plan-actual/`):

| Archivo | Contenido |
|---|---|
| `01-Requerimientos.md` | Problema, objetivos O1-O6, alcance, RF1-RF17, criterios de aceptación, restricciones, dependencias |
| `02-Analisis.md` | Dominio editorial, audiencias, fuentes por módulo, alternativas, decisiones D1-D10, riesgos, entidades |
| `03-Diseno.md` | Estructura de 12 capítulos (200-240 págs) que cubre los 15 puntos del plan maestro #129, estructura de carpetas, fichas estándar, specs técnicas digital/print, pipeline de curaduría |
| `04-Codigo.md` | Manifiesto CSV con reglas de validación, script auxiliar opcional de capturas Godot Editor, convenciones Git LFS |
| `05-Checklist.md` | 105 ítems granulares (plan-inicial: todos pendientes; plan-actual: 40 completados honestamente — solo diseño resuelto) |

Decisiones clave: curaduría incremental con manifiesto CSV (D1), fichas estándar de pieza/comentario dev/descarte (D3-D5), doble salida PDF RGB + CMYK POD desde una sola maqueta (D6), política de spoilers con bandas (D7), respaldo Git LFS fuera de Assets (D8).

### 2. Trazabilidad de los Pases de Mérito (moneda secundaria)
Investigación previa confirmó:
- La economía doble (Gemas de Ámbar + Pases de Mérito) definida en IDEA-BASE fue **superseded** por la decisión D1 de M38 Economía: **moneda única `monedas_aurora`** ("múltiples divisas agregan fricción").
- La *función* de los Pases de Mérito (recompensar tareas diarias positivas) quedó **absorbida** por M94 Retención sin FOMO (tablero de objetivos diarios/semanales/mensuales rotatorios con recompensas en oro + amistad + ítems) y M74 Eventos.

Se agregó la nota de trazabilidad en `DOCUMENTACION/38-Economia/plan-actual/02-Analisis.md` §6.1 documentando esta resolución estratégica (sin modificar el diseño vigente de M38). No se requiere módulo adicional ni reintroducir la segunda moneda; cualquier revisión futura debe pasar por QA cruzado (21.8).

## Archivos modificados/creados
- ✅ Creados: `DOCUMENTACION/130-Artbook/plan-inicial/{01..05}.md`, `DOCUMENTACION/130-Artbook/plan-actual/{01..05}.md`
- ✏️ Modificado: `DOCUMENTACION/38-Economia/plan-actual/02-Analisis.md` (§6.1 trazabilidad)
- ✏️ Modificado: `CHECKLIST-GLOBAL.md` (fila 130 agregada, fila 38 actualizada, Resumen corregido a 160 módulos, nota de actualización)
- ✏️ Modificado: `DOCUMENTACION/README.md` (entrada 130-Artbook)

## Código original / nuevo
No se tocó código del juego ni `00-PLAN-INICIAL/`. Cambios exclusivamente documentales.

## Recomendaciones
1. Iniciar nominación de piezas al manifiesto apenas existan assets de M45/M46.
2. Implementar `tools/artbook/validar_manifest.py` antes de escalar curaduría.
3. QA cruzado (21.8) del módulo 130 y de la nota de trazabilidad de M38 cuando un verificador esté disponible.