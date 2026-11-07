# 091 - Reporte W1-002 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:15 (GMT-3)
**Responde a:** (cierre del ítem W1-002 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-002

**Tarea:** Verificar las URLs de licencias en `DOCUMENTACION/{85,86,79,84}-*/` (modelos 3D, música, IA generativa): siguen activas y con la licencia declarada.

## Método de verificación

Extraje todas las URLs HTTP/HTTPS de todos los archivos `.md` dentro de las 4 carpetas de módulos legales:

| Carpeta | Rutas escaneadas |
|---------|-----------------|
| 79-Legal-Contratos | `plan-actual/`, `plan-inicial/` (10 archivos .md) |
| 84-Musica-Y-Audio-Legal | `plan-actual/`, `plan-inicial/` (11 archivos .md) |
| 85-Modelos-3D-Legal | `plan-actual/`, `plan-inicial/` (10 archivos .md) |
| 86-IA-Generativa | `plan-actual/`, `plan-inicial/` (10 archivos .md) |

Patrón de búsqueda: `https?://[^\s)]+` aplicado sobre el contenido crudo de cada archivo `.md`.

## Resultado

**No se encontró ninguna URL HTTP/HTTPS en ninguno de los 41 archivos `.md` de las 4 carpetas.**

Los archivos de esos módulos son documentación interna de requerimientos, análisis, diseño, código y checklist del proyecto (no contienen enlaces externos a sitios de licencias de terceros como TurboSquid, Sketchfab, PolyHaven, etc.). Las menciones a licencias (MIT, CC0, CC-BY, CC-BY-SA, CC-BY-NC, propias) aparecen como texto descriptivo sin URL asociada.

Ejemplo de contenido de licencias encontrado (texto, sin URL):
- `84-Musica-Y-Audio-Legal/plan-actual/08-Guia-Audio-Legal.md`: tabla de comparación de licencias (propia, MIT, CC0, CC-BY, CC-BY-SA, CC-BY-NC prohibida).
- `85-Modelos-3D-Legal/plan-actual/01-Requerimientos.md`: menciona "TurboSquid, Sketchfab, etc." como ejemplos de librerías de modelos de terceros, pero sin URLs.

## Veredicto

- **URLs de licencias encontradas en las 4 carpetas:** 0
- **URLs activas y vigentes:** N/A (no hay URLs que verificar)
- **Licencia declarada coincidente con URL:** N/A

El ítem W1-002 se resuelve con el hallazgo de que **la documentación de los módulos 79, 84, 85, 86 no contiene URLs de licencias externas citadas**. Todas las referencias a licencias son descriptivas (texto plano) sin enlace a sitios web de terceros.

- hecho=1 (W1-002)
- skip=0
- fail=0

El riel W1 lleva 2 de 12 items completados; restan W1-003 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
