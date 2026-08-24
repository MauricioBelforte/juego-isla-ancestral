**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 108: Pipeline de Assets

## ID del Módulo
- **Código:** M108 (plan maestro: sección 108 — Pipeline de Assets)
- **Carpeta:** `DOCUMENTACION/108-Pipeline-De-Assets/`
- **Dependencias:** M45 (Arte 3D, puede estar sin documentar; este módulo referencia su catálogo de entregables), M78 (Legal — Propiedad Intelectual: licencias y atribuciones). Relaciones: M04 (Game Engine: Godot 4.x + Voxel Tools), M47 (Texturas y Materiales), M48 (Animación), M08 (Mundo Voxel: paletas y meshes), M62 (Memoria), M63 (Cargas y Streaming), M61 (Rendimiento, en curso), M41/M42/M43 (audio), M88 (Fuentes), M90 (Configuración Gráfica), M86 (IA Generativa), M107 (Backups), M111 (Código de Calidad), M112 (Testing Automático), M59 (Guardado)
- **Delegable desde:** hoy (diseño completo; la implementación acompaña la entrada de los primeros assets de M45)

## 1. Problema

Un mundo cozy voxel con decenas de bloques, props, NPCs, animales y decoración acumula cientos de assets. Sin un pipeline definido: los nombres se vuelven inconsistentes, los formatos incorrectos entran al motor, las texturas sin comprimir destruyen el presupuesto de memoria (M62), los modelos sin LOD rompen el frame budget (M61), un asset licenciado sin registro genera riesgo legal (M78) y la entrada masiva de archivos hace imposible la revisión manual. En un proyecto Godot 4.x con GDScript y Voxel Tools, cada archivo que entra al árbol genera un `.import` y ocupa memoria; **la optimización no es opcional** (AGENTS.md 21.4.8 y principio técnico "performance prioridad sobre visuals" de M152). Se necesita un flujo único, documentado y verificable que garantice que todo asset que llega al juego cumpla formato, nombre, optimización y legalidad antes de ser usado.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Pipeline único de entrada | Todo asset entra por una única puerta: carpeta `assets/staging/` → validación → importación bajo convenciones → revisión de calidad → aprobación. No se admite importar assets sueltos fuera del flujo |
| RF2 | Formatos permitidos por tipo | Modelos: glTF 2.0 (`glb` binario para runtime, `gltf` + bin para edición) y OBJ solo para geometría simple/edición. Texturas: PNG (lossless) y WebP (lossy). Audio: OGG Vorbis; WAV solo para loops cortos de animación/UI |
| RF3 | Formatos prohibidos | FBX, TGA, BMP, GIF, MP3, MP4, AVI y cualquier formato propietario no documentado. Se documenta la ruta de conversión obligatoria (ej: FBX → Blender → glTF) |
| RF4 | Convenciones de nombres unificadas | Prefijos por tipo (`mdl_`, `tex_`, `mat_`, `aud_`, `anim_`, `fnt_`, `ui_`, `vox_`), snake_case, sin espacios ni caracteres especiales, máximo 64 caracteres, id estable derivado del nombre |
| RF5 | Importación con import settings deterministas | Presets de importación por tipo (textura, mesh, audio, fuente) definidos y documentados; los `.import` generados por Godot se versionan en Git; parámetros críticos (mipmaps, compresión VRAM, LODs) fijados por preset |
| RF6 | Optimización obligatoria en la importación | Mipmaps activos, compresión VRAM (BPTC en PC / ETC2-ASTC si hubiera mobile), LOD automático en meshes (Godot 4.x), potencias de 2 en texturas, límites de resolución por tipo de asset |
| RF7 | Pruebas de calidad automáticas | Script `asset_validator.gd` (EditorScript) que recorre `assets/` y verifica: nombre, formato, tamaño en disco, dimensiones, mipmaps, compresión, LOD, atribución de licencia, registro en la ficha |
| RF8 | Ficha de asset con origen y licencia | Cada asset tiene una ficha (markdown o Resource) con: id, tipo, origen (propio M45 / licenciado M78), licencia, atribución, fecha de entrada, estado del pipeline |
| RF9 | Review manual de calidad | Etapa de revisión humana de cada asset contra una plantilla fija (polígonos, UVs, escala, mipmaps, LODs, look dev, rendimiento estimado) antes de quedar disponible |
| RF10 | Prohibición de IA generativa sin control | Todo asset que venga de IA generativa (M86) pasa por revisión legal y se etiqueta explícitamente en la ficha; no se permite contenido IA sin licencia verificable |
| RF11 | Auditoría y reporte | El validador genera un reporte de estado del pipeline (aprobados, pendientes, con errores) consumible por humanos y por CI (M118) |
| RF12 | Rutas de actualización y retiro | Un asset puede actualizarse (nueva versión con changelog) o retirarse (discontinuado: se excluye del build y del catálogo sin borrar el historial) |

## 3. Requisitos No Funcionales

- **Optimización (principio rector, AGENTS.md 21.4.8):** ningún asset entra al juego sin mipmaps, compresión VRAM y LODs aplicados; el peso del asset set completo debe caber en el presupuesto de memoria de M62 y el frame budget de M61.
- **Cozy y rendimiento balanceados:** la calidad visual cozy no debe lograrse con texturas 4K indiscriminadas; se usan técnicas de batching, atlasing y MultiMesh (M08) para mantener draw calls bajos.
- **Idioma y documentación:** nombres, fichas, guías y reportes en español; código de herramientas en GDScript con comentarios en español (M05).
- **Determinismo:** la misma versión de Godot + los mismos presets producen los mismos `.import` en cualquier máquina; se documenta la versión del motor (≥ 4.4.1 por Voxel Tools).
- **Legalidad:** todo asset licenciado registra licencia y atribución según M78; los assets propios de M45 quedan marcados como copyright del estudio.
- **Escalabilidad:** el pipeline debe seguir funcionando con 500+ assets sin colapso de velocidad de importación ni de review (reviews por lotes).
- **Versionado:** los scripts y plantillas del pipeline viven en el repo con revisión de pares (M111); los assets binarios grandes usan LFS (M06/M107).
- **Trazabilidad:** la ficha de cada asset permite saber origen, estado y responsable en cualquier momento del proyecto.

## 4. Criterios de Aceptación

1. Los puntos de la sección 108 del plan maestro resueltos y documentados en `plan-actual/`.
2. Guía `assets/ASSET-PIPELINE.md` definida con formatos, nombres, presets y flujo completo.
3. `asset_validator.gd` verifica el 100% de los assets del árbol contra las reglas y produce reporte sin falsos negativos.
4. Fichas de asset con origen (M45/M78), licencia, atribución y estado creadas para los primeros 20 assets de prueba.
5. Presupuesto de memoria (M62) y frame budget (M61) respetados tras la entrada de los assets de prueba.
6. Edge cases cubiertos: asset gigante, textura sin comprimir, nombre conflictivo, asset discontinuado.
7. Delegable para implementación junto con la primera tanda de assets de M45.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M045** — Arte 3D | Pipeline de assets 3D |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M045** — Arte 3D | Depende de este módulo |

