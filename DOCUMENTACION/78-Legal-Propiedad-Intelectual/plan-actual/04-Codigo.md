**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 78: Legal — Propiedad Intelectual

> ⚠️ **Aviso legal:** Las plantillas de este archivo son modelos organizativos. NO constituyen asesoramiento legal profesional; deben revisarse con el texto oficial de cada licencia y, antes del lanzamiento comercial, idealmente con un profesional.

---

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `THIRD-PARTY-NOTICES.md` (raíz del repo) | Aviso legal consolidado de componentes de terceros, formato estándar para distribuir junto al juego | Plantilla lista, archivo real pendiente de creación en implementación |
| `ASSETS-LICENSE.md` (raíz del repo) | Inventario maestro de activos: tabla completa con licencia y atribución | Plantilla lista, archivo real pendiente |
| `CHECKLIST-ATRIBUCION.md` (`DOCUMENTACION/78-.../plan-actual/`) | Checklist de incorporación por asset (10 ítems) | Plantilla lista |
| `POLITICA-PROPERTIES.md` (`DOCUMENTACION/78-.../plan-actual/`) | Política de origen de activos, anti-plagio y términos de uso del contenido | Plantilla lista |
| `REGISTRO-MARCAS.md` (`DOCUMENTACION/78-.../plan-actual/`) | Búsquedas y decisiones de marca con fechas | Plantilla lista, búsquedas reales pendientes del fundador |

## 2. Plantilla `ASSETS-LICENSE.md` (ejemplo de uso)

```markdown
# ASSETS-LICENSE.md — Inventario de activos de Isla Ancestral

## Cómo usar
- Una fila por asset. Los assets propios también se registran (respaldan autoría).
- Columna "Atribución (texto a publicar)": copiar tal cual a los créditos del juego (M131).
- Si una licencia cambia o se revoca, editar la fila con fecha y motivo (nunca borrar historial).

## Tabla
| ID | Asset | Tipo | Origen | Autor | Fuente | Licencia | Uso comercial | Atribución exigida | Atribución (texto a publicar) | Estado |
|----|-------|------|--------|-------|--------|----------|---------------|---------------------|-------------------------------|--------|
| A000 | Proyecto Isla Ancestral (código GDScript, arte, diseño, narrativa) | Proyecto completo | Propio | Fundador y equipo | Repositorio oficial | © 2026 Todos los derechos reservados | — | — | — | Activo |
| A001 | Voxel Tools (addon godot-voxel) | Plugin | Tercero | Zylann | https://github.com/Zylann/godot_voxel | MIT | Sí | Sí (conservar aviso) | "Voxel Tools © Zylann — MIT License" | Activo |
| A002 | Nunito (tipografía) | Fuente | Tercero | Vernon Adams | https://fonts.google.com/specimen/Nunito | SIL OFL 1.1 | Sí | Sí si se redistribuye la fuente | "Nunito © Vernon Adams — SIL Open Font License 1.1" | Activo |
| A003 | SFX "pasos en arena" | Audio | Tercero | Autor del sonido | https://freesound.org/... | CC BY 4.0 | Sí | Sí | "pasos en arena © Autor — CC BY 4.0 — https://freesound.org/..." | Activo |
| A004 | Pack "cosechas voxel" | Modelos | Tercero | Autor del pack | https://opengameart.org/... | CC0 | Sí | No requerida (CC0) | "No requerida (CC0)" | Activo |
| A005 | Textura "césped claro" | Textura | Tercero | Autor | https://opengameart.org/... | CC-BY-SA 4.0 | Sí | Sí + share-alike | "césped claro © Autor — CC BY-SA 4.0" — ⚠️ aislado, evaluar compatibilidad | En evaluación |
```

### Ejemplo de fila de asset rechazado (se conserva para trazabilidad)

| ID | Asset | Tipo | Origen | Autor | Fuente | Licencia | Uso comercial | Atribución exigida | Atribución (texto a publicar) | Estado |
|----|-------|------|--------|-------|--------|----------|---------------|---------------------|-------------------------------|--------|
| A006 | Banda sonora "melodía épica" | Audio | Tercero | Autor | freesound.org/... | CC BY-NC 4.0 | NO | — | — | Rechazado (NC prohibido) 2026-08-17 |

## 3. Plantilla `THIRD-PARTY-NOTICES.md` (ejemplo de uso)

```markdown
# Third-Party Notices — Isla Ancestral

Este juego incluye componentes de terceros. Se distribuyen bajo sus licencias originales.

## Godot Engine
- Licencia: MIT
- Fuente: https://godotengine.org/license/
- Aviso: "Copyright (c) 2007-2024 Juan Linietsky, Ariel Manzur y colaboradores. Se concede permiso por la presente, de forma gratuita, a cualquier persona que obtenga una copia de este software y de los archivos de documentación asociados..."

## Voxel Tools (godot-voxel)
- Licencia: MIT
- Fuente: https://github.com/Zylann/godot_voxel
- Aviso: "Copyright (c) Zylann. Se concede permiso por la presente, de forma gratuita..."

## Nunito
- Licencia: SIL Open Font License 1.1
- Fuente: https://scripts.sil.org/OFL
- Aviso: "Copyright (c) Vernon Adams..."

## SFX "pasos en arena" (ID A003)
- Licencia: CC BY 4.0
- Fuente: https://freesound.org/...  |  https://creativecommons.org/licenses/by/4.0/
- Atribución: "pasos en arena © [Autor], CC BY 4.0"
```

**Regla práctica:** copiar el texto oficial del aviso desde la página de la licencia; no parafrasear la parte legal.

## 4. Plantilla `CHECKLIST-ATRIBUCION.md` (por cada asset nuevo)

```markdown
# Checklist de atribución — Asset: [NOMBRE] — ID: [A0XX]

- [ ] 1. Origen conocido (URL directa del asset verificada)
- [ ] 2. Página de licencia Leída (no asumida por el nombre de la web)
- [ ] 3. Uso comercial permitido (la licencia o EULA lo dice explícitamente)
- [ ] 4. Derivados permitidos (no es CC-BY-ND)
- [ ] 5. Compatibilidad con el resto del juego (no contamina la distribución)
- [ ] 6. Autor registrado (nombre real o seudónimo tal como figura)
- [ ] 7. Texto de atribución redactado (título, autor, licencia, URL)
- [ ] 8. Fila agregada en ASSETS-LICENSE.md
- [ ] 9. Entrada agregada en THIRD-PARTY-NOTICES.md (texto oficial de licencia)
- [ ] 10. Fecha y decisión (aceptado/rechazado) registradas en el mismo commit
```

## 5. Política de origen y anti-plagio (resumen operativo)

- Escala de preferencia: `propio > CC0/dominio público > CC-BY > MIT/permisivas > CC-BY-SA (aislado) > rechazado (NC/ND/sin licencia/robado)`.
- Prohibido: extraer assets de otros juegos o de imágenes de Internet sin licencia verificable, aunque el juego sea gratuito.
- Inspiración ≠ copia: referencias de diseño (Animal Crossing, Stardew Valley, A Short Hike) se anotan en el GDD como referencias, con cero assets reutilizados.
- Los colaboradores aceptan la política del proyecto al contribuir; el incumplimiento se registra en el módulo de gestión (Bug-Tracking/colaboración).

## 6. Términos de uso del contenido (resumen operativo)

- Usuarios: streaming, videos, screenshots, fan art y mods permitidos; monetización de contenido del juego permitida (política estándar indie).
- Prohibido: reventa de assets extraídos, distribución de builds modificados como propios, usurpación de marca.
- Assets de terceros: siguen perteneciendo a sus autores; este documento no transfiere derechos.

## 7. Flujo de incorporación de un asset nuevo (paso a paso)

```
1. NECESIDAD → búsqueda en fuente permitida (OGA, Freesound, itch.io, Google Fonts, repos oficiales)
2. VERIFICAR → abrir la página del asset y LEER la licencia aplicable (no la del sitio, la del archivo)
3. FILTRAR   → ¿usa comercial? ¿derivados? ¿atribución?
              ├─ NO comercial / ND / sin licencia → RECHAZAR, registrar fila con motivo y fecha
              └─ OK → continuar
4. REGISTRAR → fila en ASSETS-LICENSE.md + texto de atribución listo para copiar
5. NOTCES    → entrada en THIRD-PARTY-NOTICES.md con el texto oficial de la licencia
6. CHECKLIST → CHECKLIST-ATRIBUCION.md completo (10/10 ítems verificables)
7. COMMIT    → asset + documentación en el MISMO commit (lo exige el pipeline 108)
8. CRÉDITOS  → si exige atribución, notificar al módulo M131 (Créditos) para su inclusión
9. REVISAR   → re-verificación de licencias cada trimestre y antes de cada release
```

## 8. Criterios de implementación mínima (para el agente delegado)

- Crear los 5 archivos del módulo en `plan-actual/` (copias de plan-inicial si aún no se tocaron).
- Crear `THIRD-PARTY-NOTICES.md` y `ASSETS-LICENSE.md` en la raíz del repo con los assets reales que existan (empezar vacíos si el juego no tiene aún assets de terceros integrados).
- Registrar los assets propios actuales (código, arte, música propia) con autoría y fecha.
- Completar `REGISTRO-MARCAS.md` con la primera búsqueda real del nombre del juego (web, STEAM, itch.io y una base de marcas gratuita).
- Ejecutar la primera revisión trimestral de licencias y dejar constancia.
- Actualizar `CHECKLIST-GLOBAL.md` (módulo 78) al completar: estado ✅ y notas de verificación.

---

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé los 5 archivos del módulo 78 (plan-inicial + plan-actual idénticos) con firma del modelo.
- Definí los RF1-RF12 y RN (presupuesto cero, trazabilidad, mantenibilidad) alineados al proyecto indie cozy voxel Isla Ancestral (Godot 4.x + Voxel Tools, GDScript).
- Analicé el dominio de licencias relevante: CC0, CC-BY, CC-BY-SA, CC-BY-NC/ND (rechazadas), MIT, OGA, Freesound, asset packs de itch.io, dominios público y riesgos de marca (USPTO/EUIPO/WIPO gratuitas).
- Diseñé la estructura legal: `ASSETS-LICENSE.md` + `THIRD-PARTY-NOTICES.md` en la raíz del repo, política y registro de marcas dentro del módulo.
- Definí el flujo de incorporación de assets acoplado al pipeline 108 y la integración con M01 (Fundamentos) y M131 (Créditos).
- Redacté el checklist de 115+ ítems con marcadores [S]/[M]/[C], todos completados como documentación.

### Lo que NO pude hacer (honestidad obligatoria)
- No pude crear los archivos legales reales (`THIRD-PARTY-NOTICES.md`, `ASSETS-LICENSE.md`, `REGISTRO-MARCAS.md` con datos reales): requieren revisión y decisión del fundador/equipo (nombres reales de autores, URLs reales, decisiones de marca efectivas).
- No ejecuté búsquedas reales de colisión de marca; dejé el procedimiento y las plantillas para que el fundador las complete.
- No actualicé `CHECKLIST-GLOBAL.md`: fuera del alcance de este documento (módulo 78 queda `⬜`/`🟢` hasta que se implemente o el orquestador lo actualice por protocolo).
- No redacté términos legales de cumplimiento de ninguna legislación concreta (solo buenas prácticas; el disclaimer de "no asesoramiento legal" figura en todos los archivos).

### Recomendaciones para el próximo agente
- Al implementar: crear los archivos de la raíz con los assets reales del proyecto (empezar con 0 terceros si el juego aún no integró ninguno) y registrar los activos propios.
- Completar la primera búsqueda de marca real del nombre "Isla Ancestral" (web + Steam + itch.io + una base de marcas gratuita) y archivar el resultado con fecha en `REGISTRO-MARCAS.md`.
- Coordinar con el módulo M131 (Créditos) para que la atribución de assets fluya desde `ASSETS-LICENSE.md` a la pantalla de créditos.
- Coordinar con el pipeline 108 (assets): exigir el checklist de atribución en la integración de cada asset nuevo.
- Antes de todo release (Steam/itch.io): re-verificar licencias, textos de `THIRD-PARTY-NOTICES.md` y decisiones de marca.

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode