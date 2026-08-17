**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 86: IA Generativa

## ID del Módulo

- **Código:** M86 (tabla de módulos del `Plan-inicial-minimo.md`)
- **Carpeta del componente:** `DOCUMENTACION/86-IA-Generativa/`
- **Dependencias:** Módulo 78 (Legal-Propiedad-Intelectual) — la política de IA se apoya en el marco legal de derechos de autor y propiedad intelectual del 78
- **Módulos que dependen de este:** Publicación (declaración Steam al momento del lanzamiento), Créditos (131), Documentación del Proyecto (03)
- **Nota de la tabla global:** "Declaración Steam"

---

## 1. Problema

El proyecto "Isla Ancestral" es un desarrollo indie de mundo voxel cozy con identidad artesanal propia. La producción moderna usa herramientas de IA generativa (texto, imágenes, audio, música) en distintos grados, pero el proyecto **no tiene definido qué está permitido y qué no**. Esta indefinición genera cuatro riesgos concretos:

1. **Riesgo legal:** contenido generado con IA integrado en el producto final sin registro ni revisión puede infringir derechos de terceros (datos de entrenamiento, estilos copiados) o exponer al proyecto a disputas de autoría.
2. **Riesgo de plataforma:** Steam (Valve) exige desde 2024 una **declaración de contenido generado con IA** (AI Content Disclosure) en el momento de publicar. Declarar mal, tarde o de forma inconsistente puede retrasar el lanzamiento o generar sanciones.
3. **Riesgo reputacional:** la comunidad valora la transparencia; usar IA sin política publicada puede percibirse como engaño si el jugador descubre contenido no declarado.
4. **Riesgo de coherencia:** sin una política única, cada agente/colaborador decide por su cuenta qué herramientas usar, rompiendo la consistencia visual y artística del juego.

## 2. Objetivos del Módulo

1. Definir una **política de uso de IA generativa** clara, escrita y aplicable al proceso de producción del proyecto (Godot 4.x + Voxel Tools).
2. Establecer **qué está permitido** (apoyo a prototipado, ideas, moodboards, referencias, brainstorming) y **qué está prohibido** (assets finales publicables sin revisión humana completa).
3. Crear un **registro de herramientas de IA** usadas en el proyecto con su propósito, fecha y licencia.
4. Definir el **flujo de aprobación** de cualquier contenido asistido por IA antes de integrarlo al juego.
5. Preparar la **declaración Steam** (AI Content Disclosure) como plantilla reutilizable, con verificación obligatoria contra la política vigente de Valve al momento de publicar.
6. Documentar los **riesgos de copyright** del output de modelos y las decisiones de mitigación, en coordinación con el módulo 78 (Legal-PI).

## 3. Alcance del Módulo

**Incluye:**
- Política escrita (`AI-POLICY.md`) con matriz permitido/prohibido por categoría (texto, arte 2D/3D, música, SFX, código).
- Registro de herramientas (`AI-TOOLS-REGISTRY.md`) con plantilla de tabla.
- Flujo de aprobación de contenido con IA (revisión humana obligatoria y trazable).
- Plantilla de la declaración Steam (contenido generado: desarrollo, en-juego, publicidad).
- Coordinación con el módulo 78 (Legal-PI) y con el flujo de producción (03-Documentacion).

**No incluye (contenido que vive en otros módulos):**
- El marco legal de derechos de autor general → módulo 78 (Legal-PI).
- La decisión comercial sobre monetización → módulo de Publicación.
- La implementación de sistemas de IA procedural dentro del juego (generación procedural de terreno/mundo) → módulos 08/09/10 (no es IA generativa de contenido).

## 4. Restricciones

| Restricción | Detalle |
|---|---|
| Idioma | Español obligatorio en toda documentación |
| Motor | El proyecto usa Godot 4.x + GDScript (no aplica C#/Unity) |
| Naturaleza | Módulo administrativo/legal: no genera código de juego |
| Dependencia | Debe coordinarse con 78-Legal-Propiedad-Intelectual |
| Plataforma | Política de Steam vigente al momento de publicar; debe re-verificarse (puede cambiar) |
| Transparencia | Toda herramienta de IA usada debe quedar registrada |
| Revisión humana | Ningún asset final publicable puede ser 100% salida directa de IA sin revisión |
| Inmutabilidad | `plan-inicial/` no se modifica; los cambios viven en `plan-actual/` |

## 5. Entregables del Módulo

| # | Entregable | Estado |
|---|---|---|
| 1 | Política `AI-POLICY.md` (documento raíz) | ✅ esqueleto en 04-Codigo.md |
| 2 | Registro `AI-TOOLS-REGISTRY.md` | ✅ esqueleto en 04-Codigo.md |
| 3 | Flujo de aprobación de contenido con IA | ✅ definido en 03-Diseno.md §4 |
| 4 | Plantilla de declaración Steam | ✅ definida en 03-Diseno.md §5 |
| 5 | Matriz permitido/prohibido por categoría | ✅ 03-Diseno.md §3 |
| 6 | Coordinación con 78-Legal-PI | ✅ 03-Diseno.md §6 |
| 7 | 5 archivos del componente + checklist ≥110 ítems | ✅ |

## 6. Requisitos Funcionales (RF)

| ID | Requisito | Prioridad |
|---|---|---|
| RF1 | Definir una política escrita de uso de IA generativa aplicable a toda la producción | Alta |
| RF2 | Definir categorías de uso: texto, arte 2D/3D, música, SFX, código, herramientas de apoyo | Alta |
| RF3 | Establecer qué usos están permitidos sin revisión (prototipos, ideas, moodboards internos) | Alta |
| RF4 | Establecer qué usos están prohibidos (assets finales publicables sin revisión humana integral) | Alta |
| RF5 | Definir el flujo de aprobación de contenido asistido por IA con revisión humana obligatoria | Alta |
| RF6 | Mantener un registro de herramientas de IA con nombre, versión, propósito, licencia y fecha | Alta |
| RF7 | Registrar qué contenido del juego usa IA asistida y distinguirlo del 100% humano | Media |
| RF8 | Preparar plantilla de declaración Steam (AI Content Disclosure) para el lanzamiento | Alta |
| RF9 | Incluir aviso de re-verificación de la política de Steam antes de publicar | Alta |
| RF10 | Definir qué se declara en publicidad/marketing (capturas, tráilers, arte promocional) | Media |
| RF11 | Definir el tratamiento de textos generados (diálogos, lore) y su revisión editorial | Media |
| RF12 | Definir el tratamiento de música y SFX generados y su equivalencia/licencia de uso | Media |
| RF13 | Definir qué hacer con el código generado (GDScript) y su revisión obligatoria | Alta |
| RF14 | Publicar la política en el repo (raíz o DOCUMENTACION) accesible a colaboradores | Media |

## 7. Requisitos No Funcionales (RN)

| ID | Requisito |
|---|---|
| RN1 | La política debe estar escrita en español y en un lenguaje claro, no legalista |
| RN2 | La política debe ser verificable: cada regla debe poder auditarla un tercero |
| RN3 | Los registros de herramientas deben ser inmutables ante ediciones retroactivas (solo agregar) |
| RN4 | El flujo de aprobación debe exigir mínimo una revisión humana documentada |
| RN5 | La declaración Steam debe ser honesta y coincidir con el registro de herramientas real |
| RN6 | La política debe cubrir cambios futuros de las políticas de Valve (re-verificación al publicar) |
| RN7 | No debe contradecir el marco legal del módulo 78 (Legal-PI) |
| RN8 | Debe ser compatible con el protocolo multiagente (los agentes de IA son "herramientas" sujetas a esta política) |
| RN9 | El costo de cumplimiento debe ser bajo para un equipo indie de 1 persona |

## 8. Criterios de Aceptación

1. Existen `AI-POLICY.md` y `AI-TOOLS-REGISTRY.md` (plantillas al menos en 04-Codigo.md) al cierre del módulo.
2. La matriz permitido/prohibido cubre todas las categorías de contenido del juego.
3. El flujo de aprobación incluye mínimo una revisión humana documentada y trazable.
4. La plantilla de declaración Steam existe e incluye aviso de re-verificación de política vigente.
5. El checklist del módulo tiene mínimo 110 ítems verificables.
6. La documentación aclara que la política de Steam puede cambiar y debe verificarse al momento de publicar.
7. El módulo 78 (Legal-PI) queda referenciado como dependencia y las reglas no lo contradicen.