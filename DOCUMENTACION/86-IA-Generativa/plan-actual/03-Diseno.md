**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 86: IA Generativa

## 1. Propósito

Definir la estructura documental y operativa de la **política de IA generativa** del proyecto: el documento raíz `AI-POLICY.md`, el registro `AI-TOOLS-REGISTRY.md`, la matriz permitido/prohibido, el flujo de aprobación de contenido con IA y la plantilla de **declaración Steam** (AI Content Disclosure). El módulo es administrativo/legal: produce documentos y flujos, no código de juego.

## 2. Estructura de la política (documento raíz: `AI-POLICY.md`)

```
AI-POLICY.md
├── 1. Principio rector        → "La IA es una herramienta, no una autora"
├── 2. Ámbito de aplicación    → toda la producción (agentes IA incluidos)
├── 3. Matriz permitido/prohibido por categoría
├── 4. Flujo de aprobación de contenido con IA
├── 5. Registro de herramientas (referencia a AI-TOOLS-REGISTRY.md)
├── 6. Declaración Steam (referencia a plantilla)
├── 7. Créditos y transparencia (coordinación con módulo 131)
├── 8. Revisión y vigencia (fecha de última revisión; política de Steam es cambiante)
└── 9. Excepciones (toda excepción la aprueba el fundador y se documenta)
```

**Ubicación propuesta:** raíz del repositorio junto a `AGENTS.md` y `CHECKLIST-GLOBAL.md` (es un documento de gobernanza, no técnico), o `DOCUMENTACION/` si se prefiere mantener todo el corpus documental junto. Decisión operativa al implementar.

## 3. Matriz permitido/prohibido por categoría

| Categoría | Permitido (apoyo) | Prohibido (final) |
|---|---|---|
| Texto (lore, diálogos) | Lluvia de ideas, borradores, reescrituras sugeridas | Texto final en el juego sin reescritura editorial humana completa |
| Arte 2D (texturas, UI, iconos) | Moodboards, conceptos de referencia internos | Texturas/iconos finales publicados sin redibujado/edición humana integral |
| Arte 3D (meshes voxel, modelos) | Esquemas de bloqueo, referencias de forma | Meshes finales sin modelado/retoque humano y validación en motor (Godot 4.x) |
| Música | Esbozos de melodía, ideas de atmósfera | Pistas finales sin producción/mezcla humana y licencia verificada |
| SFX | Ideas y prototipos de sonido | Sonidos finales sin edición humana y licencia verificada |
| Código (GDScript) | Generación de código por agentes del protocolo | Código integrado sin revisión humana, compilación y QA (AGENTS §12) |
| Documentación | Redacción asistida, resúmenes | Documentos publicados sin revisión de quien firma |
| Marketing | Ideas de campaña, borradores de copy | Piezas publicitarias finales sin revisión humana (y declaradas si usan IA) |

**Regla de oro:** todo lo marcado "final" requiere **revisión humana integral documentada** antes de entrar al juego o a la tienda.

## 4. Flujo de aprobación de contenido con IA

```
1. GENERAR       → El colaborador/agente usa la herramienta registrada (si no está en el
                   registro, primero se registra: pasos de la sección 7)
2. REGISTRAR     → Se anota en AI-TOOLS-REGISTRY.md: herramienta, versión, fecha, propósito,
                   licencia, asset(s) involucrados
3. REVISAR       → Revisión humana integral (editorial, artística o técnica según categoría):
                   se documenta quién revisó, fecha y resultado (ver 04-Codigo.md §4)
4. APROBAR       → El revisado puede integrarse como asset final; se marca en el registro
                   el campo "estado: aprobado"
5. DECLARAR      → El asset aprobado alimenta la declaración Steam (sección 5) y los
                   créditos (módulo 131)
6. ARCHIVAR      → El registro y la revisión quedan en el repo (trazabilidad permanente)
```

**Reglas del flujo:**
- No existe el paso "omitir revisión" para contenido final: si no hay revisión documentada, el contenido NO puede entrar al juego.
- La revisión puede rechazar el contenido (queda como borrador con fecha y motivo).
- Los agentes de IA del protocolo están sujetos a la política: su salida es siempre "borrador" hasta revisión humana.

## 5. Plantilla de declaración Steam (AI Content Disclosure)

Sección obligatoria del plan de lanzamiento (módulo de Publicación), con verificación contra Steamworks:

| Campo | Valor propuesto (por defecto) | Tipo |
|---|---|---|
| ¿Se usó IA generativa en el desarrollo? | [Sí/No] — por defecto verificar contra registro | Selección |
| ¿El juego contiene contenido generado con IA pregenerado? | [Sí/No] — por defecto según registro | Selección |
| ¿El juego genera contenido con IA en vivo (runtime)? | No (el mundo voxel es generación procedural algorítmica, NO IA) | Selección |
| Descripción del uso (si Sí) | Texto breve: herramientas de apoyo a desarrollo (texto/código/ideas) y assets revisados | Texto libre |
| Promesa de contenido legal | "El contenido no infringe derechos de terceros y fue revisado" | Checkbox |
| Contenido publicitario (capturas, tráilers) | Representa el juego real; si hubo IA, se declara | Texto libre |

**Advertencia obligatoria en el documento:** la política de Steam/Valve sobre IA generativa cambia con frecuencia; dicha plantilla **debe re-verificarse contra la documentación oficial de Steamworks al momento de publicar**, antes de completar el formulario de Go Live.

## 6. Coordinación con el módulo 78 (Legal-PI)

- El 86 **no redefine** propiedad intelectual: asume el marco del 78 (marca, nombre del juego, derechos de contenido humano).
- El 86 agrega la regla específica: **el output de IA no genera derechos reclamables de autoría**; la PI del proyecto descansa en el contenido humano y la marca.
- Cualquier conflicto entre políticas se resuelve a favor del 78.
- Si el 78 detecta una cuestión legal nueva (ej: demanda relacionada a herramientas de IA), notifica al 86 para revisar herramientas y contenido afectado.

## 7. Registro de herramientas (`AI-TOOLS-REGISTRY.md`)

Tabla con una fila por herramienta/usuario/uso:

| Campo | Ejemplo |
|---|---|
| Herramienta | ChatGPT / Midjourney / Suno / Deepseek V4 Flash (agente) / etc. |
| Versión | fecha o versión usada |
| Proveedor | OpenAI / Stability / Suno / OpenCode / etc. |
| Licencia de uso comercial del output | Sí / No / Revisar |
| Propósito | Texto / Arte / Música / Código / Documentación |
| Frecuencia de uso | Ocasional / Recurrente |
| Assets/archivos afectados | enlace o ruta |
| Estado | En uso / Descontinuada / Aprobada / En revisión |
| Revisión humana | quién revisó + fecha (si aplica) |
| Última verificación de TOS | fecha |

**Regla de registro:** el registro es de **solo agregar** (append-only): no se editan filas históricas; los cambios se agregan como nueva fila o nota de revisión.

## 8. Verificación del módulo

- Existen plantillas de `AI-POLICY.md` y `AI-TOOLS-REGISTRY.md` (04-Codigo.md).
- La matriz cubre texto, arte 2D/3D, música, SFX, código, documentación y marketing.
- El flujo de aprobación exige revisión humana documentada y trazable.
- La plantilla de declaración Steam incluye el aviso de re-verificación de política vigente.
- Checklist ≥110 ítems, todos verificables y honestos.
- Sin contradicciones con el módulo 78 y con el protocolo multiagente (AGENTS.md).