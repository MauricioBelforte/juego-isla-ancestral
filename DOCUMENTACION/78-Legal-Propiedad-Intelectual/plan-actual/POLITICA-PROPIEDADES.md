# POLITICA-PROPIEDADES.md — Política de Propiedad Intelectual de Isla Ancestral

> **Fecha de creación:** 2026-09-15
> **Modelo:** mimo-v2.5 / OpenCode
> **Módulo:** M78 — Legal Propiedad Intelectual
> **Aviso:** Este documento NO constituye asesoramiento legal profesional. Son directrices para un desarrollo indie con presupuesto cero. Consultar a un profesional antes del lanzamiento comercial.

---

## 1. Origen de activos

Todos los activos del juego se clasifican en:

| Clasificación | Descripción |
|---------------|-------------|
| **Propio** | Creado por el equipo del juego (código, arte, música, diseño) |
| **Tercero con licencia** | Obtenido de un tercero con licencia verificada |
| **Dominio público** | obra cuyos derechos expiraron o fueron renunciados |

### Reglas de aceptación

1. **No se acepta ningún asset de origen desconocido.** Todo asset debe tener una fuente verificable.
2. **No se acepta assets "sacados" de otros juegos** o de imágenes de Internet sin licencia verificable, aunque el juego sea gratuito.
3. **No se acepta assets sin licencia declarada** en su página de descarga.
4. **Inspiración ≠ copia:** las referencias de diseño (Animal Crossing, Stardew Valley, A Short Hike, etc.) se anotan como referencias en el GDD, con **cero assets reutilizados**.

---

## 2. Escala de preferencia de licencias

Cuando se busca un asset de terceros, se sigue esta escala (de mayor a menor preferencia):

| Prioridad | Licencia | Notas |
|-----------|----------|-------|
| 1 | **Propio** | Máxima libertad, cero riesgo |
| 2 | **Dominio público / CC0** | Sin obligaciones, máxima flexibilidad |
| 3 | **CC-BY** (Atribución) | Uso comercial permitido, solo exige atribución |
| 4 | **MIT / BSD / Apache** (código) | Permisivas, conservar aviso de copyright |
| 5 | **SIL OFL** (fuentes) | Permisible, redistribuir fuente solo si se incluyen .ttf |
| 6 | **CC-BY-SA** (aislado) | Solo si está contenido separado y compatible; evaluar caso por caso |
| — | **RECHAZADO** | CC-BY-NC, CC-BY-ND, GPL (contenido integrado), sin licencia, plagiado |

### Licencias rechazadas de plano

- **CC-BY-NC (No Comercial):** Prohibido en un juego comercial.
- **CC-BY-ND (Sin Derivados):** Un juego voxel siempre modifica/trata el asset; incompatible.
- **GPL en contenido integrado:** Puede obligar a abrir el código del juego.
- **Sin licencia:** No hay certeza de que se pueda usar.
- **Plagiado:** Copiar sin permiso es ilegal y viola la política del proyecto.

---

## 3. Atribución obligatoria

Para todo asset con licencia que exija atribución (CC-BY, MIT, OFL, varias EULAs), se debe:

1. **Registrar** el texto de atribución en `ASSETS-LICENSE.md`
2. **Incluir** el texto de atribución en `THIRD-PARTY-NOTICES.md`
3. **Publicar** la atribución en los créditos del juego (M131)
4. **Conservar** el aviso de copyright del autor original

### Formato estándar de atribución

```
"Nombre del Asset — Copyright (c) Autor. Licencia X.X. URL"
```

### Ejemplo

```
"Voxel Tools — Copyright (c) Zylann. MIT License."
"Nunito — Copyright (c) Vernon Adams. SIL Open Font License 1.1."
```

---

## 4. Compatibilidad de licencias

El juego se distribuye bajo **licencia cerrada** (todos los derechos reservados por el fundador) excepto lo que las licencias de terceros obliguen a liberar.

### Reglas

1. **Evitar CC-BY-SA** en contenido integrado al juego principal: obliga a distribuir bajo la misma licencia.
2. **Evitar GPL** en código integrado: puede obligar a abrir el código del juego.
3. **MIT/BSD/Apache** conviven sin problema: solo conservar los avisos.
4. **CC-BY** conviven sin problema: solo atribuir.
5. **OFL** conviven sin problema: redistribuir la fuente solo si se incluyen los archivos .ttf.

---

## 5. Política anti-plagio

- **Prohibido** reproducir, adaptar o clonar arte, música, código, nombres o diseños de terceros sin licencia expresa.
- Si un colaborador incorpora material plagiado, **el material se retira** y el incidente se registra.
- Toda referencia de inspiración se registra como referencia de diseño, **jamás como fuente de assets**.
- Los colaboradores **aceptan la política del proyecto** al contribuir; el incumplimiento es motivo de retiro del asset y del colaborador.

---

## 6. Términos de uso del contenido del juego (comunidad)

### Permitido

- Streaming, videos, screenshots del juego
- Fan art (arte inspirado en el juego)
- Mods (si el motor los habilita)
- Uso personal y educativo
- Monetización de videos/streams del juego (política estándar indie)

### Permitido con aviso

- Uso del nombre "Isla Ancestral" en reseñas o menciones (con atribución al juego)

### No permitido

- Reventa de assets extraídos del juego
- Distribución de builds modificados como propios
- Usurpación de marca o identidad del juego
- Uso del código en otros juegos sin permiso escrito
- Copia de assets del juego para usar en otros proyectos

### Assets de terceros

Los assets de terceros conservan los derechos de sus autores originales. Este documento no transfiere derechos de autor sobre assets de terceros.

---

## 7. Registro de marcas

### Marcas a verificar

| Nombre | Tipo | Estado | Próxima revisión |
|--------|------|--------|------------------|
| "Isla Ancestral" | Título del juego | Búsqueda realizada (2026-09-15) — sin colisión en videojuegos | Antes de release |
| "Isla Aurora" | Isla principal | Búsqueda realizada (2026-09-15) — riesgo bajo | Antes de release |
| Nombres de templos/herramientas | Nombres propios | Riesgo bajo (nombres compuestos originales) | Lanzamiento |

### Procedimiento de búsqueda

1. Búsqueda web: nombre + "game" + "Steam"/"itch.io"
2. Búsqueda en tiendas: Steam, itch.io, Google Play, App Store
3. Bases de marcas gratuitas: USPTO (EE.UU.), EUIPO (UE), WIPO Global Brand Database
4. Búsqueda de dominios y redes sociales (indicio de uso activo)
5. Documentar resultado con fecha en `REGISTRO-MARCAS.md`

### Criterio de decisión

- Si existe un juego o marca **del mismo rubro (videojuegos)** con nombre idéntico o confusamente similar: documentar conflicto y elegir alternativa.
- Si existe solo en rubros ajenos: documentar análisis de bajo riesgo.

---

## 8. Revisión y mantenimiento

| Acción | Frecuencia | Responsable |
|--------|------------|-------------|
| Revisión de licencias | Cada trimestre y antes de cada release | Fundador |
| Búsqueda de colisión de marca | Cada trimestre y antes de release | Fundador |
| Actualización de `ASSETS-LICENSE.md` | Al incorporar cada asset nuevo | Cualquier agente |
| Actualización de `THIRD-PARTY-NOTICES.md` | Al incorporar cada asset nuevo | Cualquier agente |
| Revisión de este documento | Anual o ante cambios legales relevantes | Fundador |

---

## 9. Disclaimer

> **Este documento y todo el módulo M78 NO constituyen asesoramiento legal profesional.**
> Son directrices de organización y buenas prácticas para un desarrollo indie con presupuesto cero.
> Ante dudas jurídicas concretas (registro de marcas, disputas, distribución en tiendas específicas),
> **consultar a un profesional del derecho.**

---

**Modelo:** mimo-v2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-15
