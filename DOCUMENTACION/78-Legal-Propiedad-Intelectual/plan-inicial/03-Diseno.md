**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 78: Legal — Propiedad Intelectual

> ⚠️ **Aviso legal:** Este diseño es organizativo y NO constituye asesoramiento legal profesional.

---

## 1. Estructura legal del proyecto

```
RAÍZ DEL REPOSITORIO
├── THIRD-PARTY-NOTICES.md        ← Aviso legal consolidado (formato estándar, público)
├── ASSETS-LICENSE.md             ← Inventario maestro de activos (tabla de registro)
└── DOCUMENTACION/
    └── 78-Legal-Propiedad-Intelectual/
        ├── plan-inicial/         ← Documentación original (inmutable)
        └── plan-actual/          ← Espejo actualizado del plan
            ├── 01-Requerimientos.md
            ├── 02-Analisis.md
            ├── 03-Diseno.md      ← Este archivo
            ├── 04-Codigo.md      ← Plantillas y flujo de incorporación
            └── 05-Checklist.md
```

### 1.1 Documentos funcionales (en la raíz del repo, versionados con Git)

| Documento | Función | Contenido mínimo |
|---|---|---|
| `ASSETS-LICENSE.md` | Inventario maestro consultable | Tabla con: ID, nombre del asset, tipo, origen, autor, fuente (URL), licencia, uso permitido, atribución (SI/NO), estado, fecha de ingreso |
| `THIRD-PARTY-NOTICES.md` | Aviso legal consolidado para distribuir | Lista de componentes de terceros con: nombre, versión, autor, licencia, texto/URL de la licencia, atribución requerida |
| `CHECKLIST-ATRIBUCION.md` (plantilla, dentro del módulo) | Checklist de incorporación por asset | 10 ítems verificables de origen, licencia, uso comercial, compatibilidad y atribución |
| `POLITICA-PROPERTIES.md` (dentro del módulo) | Política del proyecto | Origen de activos, escala de preferencia de licencias, política anti-plagio, términos de uso del contenido por la comunidad |
| `REGISTRO-MARCAS.md` (dentro del módulo) | Decisiones de marca | Búsquedas realizadas, fechas, resultados, decisiones y fecha de re-revisión |

### 1.2 Cómo se relaciona con el repositorio

- Los archivos legales viven **en la raíz** (no en `Assets/`) porque Godot no los importa; así se evitan `.meta` innecesarios y quedan visibles para Steam/itch.io y colaboradores.
- Todo cambio legal se hace en un commit con mensaje descriptivo (historial auditable).
- La atribución en créditos del juego la consume el módulo M131 (Créditos) leyendo `ASSETS-LICENSE.md` vía export/proceso manual acordado.

## 2. Tabla de activos con licencia y atribución (formato del registro)

| ID | Asset | Tipo | Origen | Autor | Fuente | Licencia | Uso comercial | Atribución exigida | Atribución (texto a publicar) | Estado |
|----|-------|------|--------|-------|--------|----------|---------------|---------------------|-------------------------------|--------|
| A000 | Juego Isla Ancestral (código, arte, diseño) | Todo el proyecto | Propio | Fundador/Equipo | — | © todos los derechos reservados | — | — | — | Activo |
| A001 | Voxel Tools (godot-voxel) | Plugin motor | Tercero | ufbx | github.com/Zylann/godot_voxel | MIT | Sí | Sí (texto MIT) | "Voxel Tools © Zylann — MIT License" | Activo |
| A002 | Fuente: Nunito | Tipografía | Tercero | Google Fonts | fonts.google.com | OFL 1.1 | Sí | Sí (si se distribuye la fuente) | "Nunito © Vernon Adams — SIL OFL 1.1" | Activo |
| A003 | Pack SFX: sonidos de pasos | Audio | Tercero | Autor del pack | freesound.org/... | CC-BY-4.0 | Sí | Sí | "Pasos © [Autor] — CC BY 4.0" (con URL) | Activo |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

Reglas de la tabla:

1. Cada fila nueva se agrega cuando el asset entra al proyecto (regla acoplada al pipeline 108).
2. Si la licencia no exige atribución, el campo "Atribución (texto a publicar)" se completa con "No requerida (licencia X)".
3. Si el asset se retira, el estado cambia a "Retirado — fecha/motivo" (no se borra la fila: trazabilidad).
4. Los assets propios se catalogan con autoría y fecha para respaldar derechos de autor.

## 3. Registro `THIRD-PARTY-NOTICES.md` (formato estándar)

```markdown
# Third-Party Notices

Isla Ancestral usa componentes de terceros bajo las siguientes licencias.
Este documento se distribuye junto con el juego.

## Godot Engine
Copyright (c) 2007-2024 Juan Linietsky, Ariel Manzur, y colaboradores.
Licencia MIT. https://godotengine.org/license/

## Voxel Tools (godot-voxel)
Copyright (c) Zylann.
Licencia MIT. https://github.com/Zylann/godot_voxel/blob/master/LICENSE

## Nunito (tipografía)
Copyright (c) Vernon Adams.
SIL Open Font License 1.1. https://scripts.sil.org/OFL

### [A003] Pasos — pack de sonido
Autor: [Autor]. Licencia CC BY 4.0.
https://creativecommons.org/licenses/by/4.0/
Fuente: https://freesound.org/...
```

Regla: **cada entrada de `THIRD-PARTY-NOTICES.md` se actualiza cuando se agrega/modifica/retira un asset**, en el mismo commit que `ASSETS-LICENSE.md`.

## 4. Política del proyecto (documento `POLITICA-PROPERTIES.md`)

### 4.1 Origen de activos

- Los activos se clasifican en: propios, terceros con licencia, dominio público.
- No se acepta ningún asset de origen desconocido, "sacado" de otro juego, ni descargado sin verificar su página de licencia.

### 4.2 Escala de preferencia de licencias

1. Contenido propio
2. Dominio público / CC0
3. CC-BY (con atribución correcta)
4. MIT / BSD / Apache (código)
5. CC-BY-SA (solo aislado, con evaluación de compatibilidad)
6. Rechazado de plano: CC-BY-NC, CC-BY-ND, GPL en contenido integrado, "no commercial", sin licencia, trabajos robados/plagiados

### 4.3 Política anti-plagio

- Prohibido reproducir, adaptar o clonar arte, música, código, nombres o diseños de terceros sin licencia expresa.
- Si un colaborador incorpora material plagiado, el material se retira y el incidente se registra.
- Toda referencia de inspiración (ej: Animal Crossing, Stardew Valley, A Short Hike) se registra como referencia de diseño, jamás como fuente de assets.

### 4.4 Términos de uso del contenido del juego (comunidad)

- Permitido: streaming, videos, screenshots, fan art, mods (si el motor los habilita), uso personal.
- Permitido con aviso: monetización de videos/streams del juego.
- No permitido: reventa de assets extraídos, uso del código en otros juegos sin permiso, clonación de la marca.
- Los assets de terceros conservan los derechos de sus autores originales.

## 5. Registro de marcas (documento `REGISTRO-MARCAS.md`)

| Nombre analizado | ¿Qué es? | Búsquedas realizadas (fecha, fuente) | ¿Colisión relevante? | Decisión | Próxima revisión |
|---|---|---|---|---|---|
| "Isla Ancestral" | Título del juego | Web, Steam, itch.io, USPTO (2026-08-17) | Pendiente de ejecutar por el fundador | Documentar y decidir | Antes de release |
| "Isla Aurora" | Isla principal | Ídem | Pendiente | Documentar y decidir | Antes de release |
| Nombres de templos/herramientas | Nombres propios | Búsqueda básica web | Riesgo bajo (nombres compuestos originales) | Aceptado con registro | Lanzamiento |

## 6. Flujo de incorporación de un asset nuevo (resumen — detalle en 04-Codigo.md)

```
Necesito un asset
   │
   ▼
1. Buscar fuente legal (OGA, Freesound, itch.io, Google Fonts, etc.)
   │
   ▼
2. Verificar página de licencia del asset concreto (LEER, no asumir)
   │
   ▼
3. ¿Uso comercial? ¿Derivados? ¿Atribución?
   ├─ NC o ND o sin licencia → RECHAZADO (registrar en tabla como rechazado)
   └─ OK → continuar
   │
   ▼
4. Completar CHECKLIST-ATRIBUCION.md (10 ítems) y fila en ASSETS-LICENSE.md
   │
   ▼
5. Agregar entrada en THIRD-PARTY-NOTICES.md con texto oficial de licencia
   │
   ▼
6. Guardar el asset + documentación en el MISMO commit (pipeline 108 lo exige)
   │
   ▼
7. Si exige atribución → agregar a créditos del juego (M131)
```

## 7. Dónde se documenta (mapa de archivos)

| Contenido | Archivo | Ubicación |
|---|---|---|
| Inventario maestro de activos | `ASSETS-LICENSE.md` | Raíz del repo |
| Aviso legal consolidado | `THIRD-PARTY-NOTICES.md` | Raíz del repo |
| Checklist de atribución por asset | `CHECKLIST-ATRIBUCION.md` | `DOCUMENTACION/78-Legal-Propiedad-Intelectual/plan-actual/` |
| Política del proyecto (origen, anti-plagio, términos de uso) | `POLITICA-PROPERTIES.md` | Ídem |
| Decisiones de marca | `REGISTRO-MARCAS.md` | Ídem |
| Requisitos, análisis, diseño, código, checklist | 01 a 05 de este módulo | Ídem |
| Créditos en pantalla con atribuciones | Módulo M131 (Créditos) | `DOCUMENTACION/131-Creditos/` |

## 8. QA previsto

- Test: la tabla `ASSETS-LICENSE.md` cubre la totalidad de assets importados del módulo 108.
- Test: todo asset con licencia que exige atribución tiene el texto de atribución completo (autor + licencia + URL).
- Test: el checklist de incorporación frena assets sin licencia documentada.
- Test: `THIRD-PARTY-NOTICES.md` incluye el texto completo de cada licencia usada.
- Test: no existe ningún asset CC-BY-NC/CC-BY-ND integrado en el juego.
- Test: las decisiones de marca tienen fecha y resultado de búsqueda registrados.

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode