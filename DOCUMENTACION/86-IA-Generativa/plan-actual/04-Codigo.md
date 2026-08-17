**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 86: IA Generativa

## 1. Carácter del Componente

Módulo **administrativo/legal** (gobernanza de producción): no genera código de juego ni escenas. Su "código de ejecución" son los documentos de política y los flujos de aprobación. **No aplican testings 06/07** (no hay código ejecutable); la verificación es documental (existencia de plantillas + consistencia con el 78 y con la declaración Steam).

## 2. Archivos involucrados

### Entradas
| Archivo | Rol |
|---|---|
| `CHECKLIST-GLOBAL.md` | Fila 86 (IA Generativa); nota "Declaración Steam"; dependencia 78 |
| `AGENTS.md` | Protocolo multiagente: AGENTS.md = herramientas de IA sujetas a esta política |
| `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` | Backlog y contexto del proyecto |
| Módulo 78 (Legal-PI) | Marco legal de propiedad intelectual (dependencia jerárquica) |
| Módulo 131 (Créditos) | Consumidor del registro para transparencia de créditos |

### Salidas (de este componente)
| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | Problema, objetivos, alcance, RF, RN, criterios |
| `plan-inicial/02-Analisis.md` | Política Steam/Valve 2024+, copyright del output, decisiones clave |
| `plan-inicial/03-Diseno.md` | Estructura `AI-POLICY.md`, matriz, flujo de aprobación, declaración Steam |
| `plan-inicial/05-Checklist.md` | 110+ ítems del módulo |
| `plan-actual/*` | Espejo vigente (idéntico al inicio) |

### Generados por este módulo (archivos previstos de producción)
| Archivo | Estado | Tipo |
|---|---|---|
| `AI-POLICY.md` | Esqueleto definido aquí (sección 3) | Documento de gobernanza |
| `AI-TOOLS-REGISTRY.md` | Esqueleto definido aquí (sección 4) | Registro append-only |
| Sección "Declaración Steam" del plan de lanzamiento | Plantilla (sección 5) | Documento del módulo Publicación |

> **Nota de ubicación:** la ubicación final de `AI-POLICY.md` (raíz del repo vs `DOCUMENTACION/`) es una decisión operativa que tomará el agente implementador junto al fundador; ambas opciones son válidas según la convención existente.

## 3. Esqueleto de `AI-POLICY.md` (plantilla)

```markdown
# AI-POLICY.md — Política de Uso de IA Generativa (Isla Ancestral)

**Versión:** 1.0 · **Última revisión:** AAAA-MM-DD · **Próxima revisión:** al publicar

## 1. Principio rector
La IA generativa es una herramienta de apoyo, no una autora.
Los derechos de autoría del proyecto descansan en el contenido humano y la marca.

## 2. Ámbito de aplicación
Toda la producción (desarrollo, arte, audio, texto, código, marketing),
incluidos los agentes de IA del protocolo multiagente (AGENTS.md).

## 3. Permitido / Prohibido (resumen)
- Permitido: prototipado, ideas, moodboards, referencias, borradores, generación de
  código como borrador, redacción asistida de documentación.
- Prohibido: incorporar como asset final de juego o de tienda cualquier salida
  directa de IA sin revisión humana integral documentada.

## 4. Flujo de aprobación
Generar → Registrar → Revisar (humano) → Aprobar → Declarar → Archivar.
Sin revisión documentada no hay integración al juego.

## 5. Registro de herramientas
Ver `AI-TOOLS-REGISTRY.md` (registro append-only).

## 6. Declaración Steam
Ver plantilla en DOCUMENTACION/86-IA-Generativa (04-Codigo.md §5) y en el plan de
lanzamiento. La política de Valve cambia: verificar siempre al momento de publicar.

## 7. Créditos y transparencia
El registro alimenta los créditos (módulo 131): las herramientas de IA usadas se
mencionan cuando corresponde.

## 8. Vigencia y revisión
Este documento se revisa cuando: cambie la política de Steam, se incorpore una
herramienta nueva relevante, o el módulo 78 lo solicite.
```

## 4. Esqueleto de `AI-TOOLS-REGISTRY.md` (plantilla)

```markdown
# AI-TOOLS-REGISTRY.md — Registro de Herramientas de IA Generativa

**Regla:** registro append-only. No se editan filas históricas; cambios = fila nueva.

| Fecha | Herramienta | Versión | Proveedor | Licencia uso comercial output | Propósito | Frecuencia | Assets/archivos | Revisión humana (quién/fecha) | Estado |
|---|---|---|---|---|---|---|---|---|---|
| AAAA-MM-DD | (nombre) | (versión) | (proveedor) | Sí/No/Revisar | Texto/Arte/Música/Código/Docs | Ocasional/Recurrente | (ruta o "—") | (quién + fecha, o "—" si solo es apoyo interno) | En uso/Descontinuada |

## Notas de revisión
- AAAA-MM-DD: verificación de TOS de (herramienta): (resultado)
```

## 5. Sección de declaración Steam (plantilla para el plan de lanzamiento)

```markdown
## Declaración de contenido generado con IA (Steamworks)

### Estado proyectado (VERIFICAR CONTRA STEAMWORKS ANTES DE PUBLICAR)
- [ ] IA usada en desarrollo: SÍ/NO (según AI-TOOLS-REGISTRY.md)
- [ ] Contenido pregenerado con IA en el juego: SÍ (assets revisados) / NO
- [ ] Contenido generado con IA en vivo (runtime): NO (el mundo voxel usa
      generación procedural algorítmica, no IA)
- [ ] Descripción del uso (texto breve, coincide con el registro)
- [ ] Promesa de contenido legal firmada (no infringe derechos de terceros,
      contenido revisado)
- [ ] Publicidad/capturas: representan el juego real; piezas con IA declaradas

⚠️ La política de Steam/Valve sobre IA generativa cambia con frecuencia.
Completar este formulario SOLO contra la documentación oficial vigente de
Steamworks al momento del Go Live.
```

## 6. "Funciones clave" del sistema (flujos que ejecuta la producción)

| Función | Descripción | Consumida en |
|---|---|---|
| Registrar herramienta | Entrada en `AI-TOOLS-REGISTRY.md` antes de usar una herramienta | Toda tarea con IA |
| Aprobar asset con IA | Flujo de 03-Diseno.md §4 con revisión humana documentada | Integración de assets |
| Declarar en Steam | Plantilla 04-Codigo.md §5 al momento del lanzamiento | Módulo Publicación |
| Auditar política | Revisión de vigencia contra Steamworks y TOS de herramientas | Cada semestre + pre-publicación |
| Créditos | Alimentar módulo 131 con herramientas usadas | Créditos |

## 7. Verificación del Módulo

- Plantillas `AI-POLICY.md` y `AI-TOOLS-REGISTRY.md` definidas (secciones 3 y 4).
- Plantilla de declaración Steam definida con aviso de re-verificación (sección 5).
- Checklist ≥110 ítems, honestos y verificables.
- Coherencia con módulo 78 (dependencia) y con el protocolo AGENTS (los agentes IA son "herramientas").
- Se aclara explícitamente que la política de Steam puede cambiar y debe verificarse al momento de publicar.

---

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 86 (IA Generativa): Requerimientos, Análisis, Diseño, Código y Checklist (110+ ítems), en `plan-inicial/` y `plan-actual/` idénticos.
- Analicé la política de Steam/Valve sobre IA generativa 2024+ (línea de tiempo: enero 2024, abril 2024, junio 2024, 2025+) y su impacto en un juego Godot 4.x con mundo voxel procedural.
- Analicé los riesgos de copyright del output de modelos (autoría, datos de entrenamiento, TOS, jurisdicciones) y las alternativas; decidí la política mixta: IA de apoyo permitida, IA en assets finales solo con revisión humana integral.
- Diseñé los artefactos: `AI-POLICY.md`, `AI-TOOLS-REGISTRY.md` (append-only) y la plantilla de declaración Steam, con aviso explícito de que la política de Valve es cambiante y debe re-verificarse al publicar.
- Definí la coordinación con el módulo 78 (Legal-PI) y con el flujo de producción multiagente (AGENTS.md).

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé los archivos de producción `AI-POLICY.md` y `AI-TOOLS-REGISTRY.md` en la raíz del repo: su ubicación final y contenido definitivo requieren decisión del fundador (qué herramientas usará, dónde vivirán los documentos, y qué usa realmente en su flujo de trabajo).
- No decidí la política definitiva sobre herramientas específicas (Midjourney, Suno, etc.): requiere decisión del fundador sobre qué herramientas usar y sus licencias.
- No pude verificar la política de Steam vigente al 100%: la documentación de Valve cambia y debe consultarse oficialmente al momento de publicar (está marcado como checkbox obligatorio en el flujo).

### Recomendaciones para el próximo agente
1. Al implementar: crear `AI-POLICY.md` en la ubicación que el fundador elija (raíz vs DOCUMENTACION/) utilizando el esqueleto de 04-Codigo.md §3.
2. Crear `AI-TOOLS-REGISTRY.md` con el esqueleto de §4 y registrar TODAS las herramientas reales del proyecto (incluidos los agentes del protocolo multiagente).
3. Completar la sección de declaración Steam del plan de lanzamiento (módulo Publicación) con la plantilla de §5, verificando la política oficial de Steamworks al momento del Go Live.
4. Enlazar el módulo 86 con el 78 (Legal-PI) cuando el 78 exista: el 86 asume su marco, no lo redefine.
5. Actualizar la fila 86 de CHECKLIST-GLOBAL.md (estado, progreso y nota) recién cuando la implementación esté hecha; este componente solo documentó el diseño.
6. Alimentar el módulo 131 (Créditos) con el registro de herramientas cuando se produzcan assetos finales con IA aprobada.