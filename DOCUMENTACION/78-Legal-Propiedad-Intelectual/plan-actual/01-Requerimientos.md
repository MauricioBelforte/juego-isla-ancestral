**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 78: Legal — Propiedad Intelectual

## ID del Módulo

- **Código:** M78 (plan maestro: Legal — Propiedad Intelectual)
- **Carpeta:** `DOCUMENTACION/78-Legal-Propiedad-Intelectual/`
- **Dependencias:** M01 (Fundamentos del Proyecto)
- **Módulos que dependen de este:** M79 (Legal — Contratos), M80 (Legal — Privacidad), M82 (Clasificación por Edades), M83 (Licencias de Software), M84 (Música y Audio — Legal), M85 (Modelos 3D — Legal), M86 (IA Generativa), M125 (Términos de Servicio), M126 (Marketing Legal), M127 (Copyright del Juego), M128 (Identidad de Marca), M131 (Créditos)
- **Delegable desde:** documentación completa (este módulo); implementación de archivos legales reales requiere revisión del fundador/equipo

> ⚠️ **Aviso legal:** Este documento y todo el módulo M78 NO constituyen asesoramiento legal profesional. Son directrices de organización y buenas prácticas para un desarrollo indie con presupuesto cero. Ante dudas jurídicas concretas (registro de marcas, disputas, distribución en tiendas específicas), consultar a un profesional del derecho.

---

## 1. Problema

*Isla Ancestral* es un desarrollo indie con presupuesto cero sobre Godot 4.x (Voxel Tools, GDScript) y no dispone de un equipo legal. El juego usará activos de múltiples orígenes: assets propios (modelos voxel, texturas, música, código), assets de terceros con distintas licencias (CC0, CC-BY, CC-BY-SA, MIT, OGA, Freesound, asset packs de itch.io, tipografías libres) y posiblemente herramientas open source (Godot Engine, Voxel Tools, addons).

Sin una política de propiedad intelectual clara, el proyecto corre riesgos concretos:

1. **Uso indebido de licencias:** incluir un asset con licencia restrictiva sin cumplir sus condiciones (atribución, share-alike, prohibición de uso comercial) puede obligar a retirar el juego o rehacer contenido.
2. **Sin registro de origen:** con decenas de assets es imposible recordar manualmente qué es propio, qué es de terceros y con qué licencia; se pierde la trazabilidad.
3. **Créditos y atribuciones incompletas:** plataformas (Steam, itch.io) y varias licencias CC exigen atribución visible; omitirla es motivo de reclamo.
4. **Riesgo de marca:** nombres, logos y títulos no revisados pueden colisionar con marcas registradas existentes ("Isla Ancestral" debe verificarse antes del lanzamiento).
5. **Conflicto de licencias entre assets:** por ejemplo, usar un asset CC-BY-SA junto a música con licencia no-compatible puede "contaminar" los términos de distribución del juego completo.
6. **Falta de precedente para decisiones futuras:** sin una política documentada, cada nueva incorporación de asset (módulo 108 — pipeline de assets) reabre la discusión.

## 2. Objetivos

### 2.1 Objetivo General

Definir e implementar una política de propiedad intelectual transparente, simple y aplicable a un indie con presupuesto cero, que garantice que **todos los activos del juego tengan un origen conocido, una licencia válida y una atribución correcta** antes de su primer lanzamiento público (Steam/itch.io).

### 2.2 Objetivos Específicos

| # | Objetivo | Criterio de éxito |
|---|----------|-------------------|
| 1 | Inventario completo de activos con licencia | Todo asset del juego está en `THIRD-PARTY-NOTICES.md` o marcado como propio |
| 2 | Atribuciones cumplidas | Toda licencia que exija atribución está cumplida en documento y en créditos del juego |
| 3 | Revisión de licencias antes de integrar | El pipeline 108 no incorpora ningún asset sin licencia válida documentada |
| 4 | Decisión de marca documentada | Búsqueda de colisiones de marca sobre "Isla Ancestral" registrada y archivada |
| 5 | Política contra plagio | Política escrita que prohíbe copiar arte/código/audio de otros juegos sin licencia expresa |
| 6 | Términos de uso del contenido propios | Términos que definen qué pueden hacer los usuarios con el contenido del juego (streaming, fan art) |

## 3. Alcance

### 3.1 Dentro del alcance

- Clasificación de las licencias que puede usar el proyecto (CC0, CC-BY, CC-BY-SA, MIT, OGA, Freesound, itch.io, dominio público).
- Plantillas de registros: `THIRD-PARTY-NOTICES.md`, `ASSETS-LICENSE.md`, checklist de atribución.
- Política del proyecto: origen de activos, preferencias de licencia, política anti-plagio, términos de uso del contenido.
- Reglas de atribución y de créditos en pantalla (apoyo al módulo M131 — Créditos).
- Procedimiento de incorporación de assets nuevos (integración con el pipeline 108).
- Revisión inicial de marcas (nombre del juego y nombres de islas/mecánicas clave).
- Registro de decisiones de copyright y derechos sobre el contenido original del juego.

### 3.2 Fuera del alcance

- Redacción de contratos individuales (M79 — Legal: Contratos).
- Privacidad y datos personales (M80 — Legal: Privacidad).
- Clasificación por edades (M82 — Clasificación por Edades).
- Licencias de software de terceros del motor (M83 — Licencias de Software), aunque se archiva la regla general de compatibilidad.
- Legal específico de música (M84) y modelos 3D (M85), que se apoyan en este módulo pero se desarrollan allí.
- Declaraciones de IA generativa para plataformas (M86 — IA Generativa).
- Asesoramiento legal profesional (declarado arriba).

## 4. Requisitos Funcionales

| # | Requisito | Detalle |
|---|-----------|---------|
| RF1 | Inventario de activos | Registro único de todos los activos del juego: nombre, tipo, origen (propio/terceros), autor, fuente (URL), licencia y estado de atribución |
| RF2 | Clasificación por licencia | El registro permite saber de un vistazo si cada asset es: propio, dominio público, CC0, CC-BY, CC-BY-SA, MIT, otra licencia permisiva, o licencia comercial restringida |
| RF3 | Atribución obligatoria | Para todo asset con licencia que exija atribución, el registro incluye la nota de atribución exacta tal como debe publicarse |
| RF4 | Atribución en créditos del juego | Los créditos en pantalla (M131) deben incluir la atribución de assets según lo definido por este módulo (título, autor, licencia, URL) |
| RF5 | Checklist de incorporación | Antes de que el pipeline 108 admita un asset, se ejecuta un checklist de atribución con ítems verificables (¿licencia válida?, ¿uso comercial permitido?, ¿atribución documentada?, ¿compatible con el resto del juego?) |
| RF6 | Revisión periódica de licencias | Procedimiento para re-verificar las licencias existentes ante cambios de términos (al menos 1 vez por trimestre y antes de cada build de release) |
| RF7 | Decisiones de marca | Registro de búsquedas de colisión de marca: nombre del juego "Isla Ancestral", "Isla Aurora" y nombres de mecánicas clave; resultado archivado con fecha |
| RF8 | Política de origen de activos | Documento que declara qué licencias acepta el proyecto, cuáles prefiere y cuáles rechaza (ej: prohibido usar arte con licencia no-comercial, prohibido ND -sin derivados-) |
| RF9 | Política anti-plagio | Declaración escrita de que no se copia ni se reproduce arte, código, audio, nombres o diseños de terceros sin licencia expresa; aplica a desarrollo y a colaboradores |
| RF10 | Términos de uso del contenido | Documento que define el uso permitido del contenido original del juego (streaming, videos, fan art, mods) por parte de la comunidad |
| RF11 | Registro de activos propios | Lista de activos 100% propios (código GDScript, modelos voxel, texturas, música original) con declaración de autoría y fecha |
| RF12 | Compatibilidad de licencias | Regla documentada de qué licencias pueden convivir en el juego sin contaminar la distribución (evitar CC-BY-SA junto a contenido con restricciones incompatibles) |

## 5. Requisitos No Funcionales

- **Presupuesto cero:** toda la política debe ser aplicable sin gasto económico (uso de registros markdown locales, herramientas gratuitas de búsqueda de marcas, sin abogados obligatorios para la fase de desarrollo).
- **Trazabilidad:** cada decisión clave (aceptar/rechazar licencia, renombrar marca, retirar asset) queda registrada con fecha y motivo.
- **Transparencia:** la documentación legal es pública dentro del repositorio (a menos que el fundador decida otra cosa) y cualquier colaborador puede consultarla.
- **Simplicidad:** los formularios y checklists deben poder completarse en menos de 10 minutos por asset; si un proceso requiere más tiempo, se simplifica.
- **Mantenibilidad:** los registros se actualizan en el mismo commit en que se incorpora un asset (regla acoplada al pipeline 108).
- **Lenguaje:** toda la documentación legal del proyecto se redacta en español (los créditos en juego pueden incluir versión en inglés de atribuciones).
- **Versionado:** los documentos legales viven en el repositorio con control de versiones Git para historial de cambios auditable.

## 6. Criterios de Aceptación

1. Existen `THIRD-PARTY-NOTICES.md` y `ASSETS-LICENSE.md` con el formato de este módulo (aunque sea con 0 activos de terceros al inicio).
2. Todo asset de terceros presente en el proyecto tiene su fila de atribución en el registro.
3. El checklist de incorporación del pipeline 108 exige la atribución (y falla la integración si falta).
4. La decisión sobre el nombre "Isla Ancestral" (y alternativas) está registrada con fecha y resultado de búsqueda.
5. La política anti-plagio y los términos de uso del contenido están redactados y aceptados por el fundador.
6. Los créditos en pantalla (M131) definidos incluyen la sección de assets de terceros con las atribuciones de este módulo.
7. El disclaimer de "no asesoramiento legal profesional" está presente en toda la documentación legal.
8. El módulo queda en estado "documentación completa, delegable para implementar": los archivos legales reales requieren revisión del fundador.

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M001** — Fundamentos del Proyecto | Marco legal general |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M079** — Legal — Contratos | Usado por legal — contratos |
| **M080** — Legal — Privacidad | Usado por legal — privacidad |
| **M082** — Clasificación por Edades | Usado por clasificación por edades |
| **M084** — Música y Audio — Legal | Usado por música y audio — legal |
| **M085** — Modelos 3D — Legal | Usado por modelos 3d — legal |
| **M086** — IA Generativa | Usado por ia generativa |
| **M125** — Términos de Servicio | Usado por términos de servicio |
| **M126** — Marketing Legal | Usado por marketing legal |
| **M127** — Copyright del Juego | Usado por copyright del juego |
| **M128** — Identidad de Marca | Usado por identidad de marca |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M001** — Fundamentos del Proyecto | Depende de este módulo |
| **M079** — Legal — Contratos | Este módulo lo necesita |
| **M080** — Legal — Privacidad | Este módulo lo necesita |
| **M082** — Clasificación por Edades | Este módulo lo necesita |
| **M084** — Música y Audio — Legal | Este módulo lo necesita |
| **M085** — Modelos 3D — Legal | Este módulo lo necesita |
| **M086** — IA Generativa | Este módulo lo necesita |
| **M125** — Términos de Servicio | Este módulo lo necesita |

