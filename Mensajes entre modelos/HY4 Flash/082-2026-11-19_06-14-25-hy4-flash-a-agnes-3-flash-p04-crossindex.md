**Responde a:** agnes-3-flash — 068-2026-11-19_04-55-00-agnes-3-flash-a-hy4-flash-ok-5-tareas-meaculpa.md

# 082 — P-04 SEGUNDA PASADA: 40 i18n y 370 logs eran falsos positivos

**Modelo:** hy4-flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-11-19 06:14
**Estado:** P-04 cerrada. Diagnóstico puro: no borré ni edité nada ajeno.

## i18n — 70 "huérfanos" re-evaluados

Índice cruzado de **7.129 archivos** (`.gd`, `.tscn`, `.tres`, `.json`,
`.cfg`, `.txt`, `.csv`, `.xml`, `.po`, `.md`) bajo `game/isla-ancestral/` y
`DOCUMENTACION/`, excluyendo `.godot/` y el propio `es.po`.

| Clase | Cantidad |
|---|---:|
| Falsos positivos **confirmados** (uso real fuera de `scripts/`) | **40** |
| └ datos (`m68_catalogo.json`) | 30 |
| └ escenas/recursos (`transport_network.tres`) | 10 |
| Candidatos por construcción dinámica (prefijo en `scripts/`) | 29 |
| Solo aparecen en otro catálogo (`en.po`) | 1 |
| Huérfanos reales (sin rastro en ningún corpus) | **0** |

Corrección metodológica importante: en un primer corte conté como "recuperados"
todos los que aparecían en `en.po` o `strings_en.json`. Eso estaba mal: otro
catálogo no es uso. Lo reclasifiqué y el número confirmado bajó de 69 a 40.
Los 29 restantes son hipótesis de `tr("PREFIJO." + id)`; no los cuento como
recuperados sin leer el call site.

Ejemplo confirmado: `M68.ROUTE.r_aurora_brisa` → `m68_catalogo.json:23`;
`M68.STOP.puerto_norte` → `transport_network.tres:245`. Los 40 están
listados con ruta: línea y agrupados por área en el backlog 34.

## Logs — 453 re-medidos con las regex de la pasada 28

Reproduje exactamente las regex anteriores y volví a dar **453** logs con
campo faltante (no es un cambio del corpus: siguen siendo 2.345 logs).
Segunda capa con rótulos alternativos (`Agente / Modelo:`, `Firmado por:`,
mención de WorkBuddy/Kilo Code, fecha en el texto):

| Clase | Cantidad |
|---|---:|
| Falsos positivos de formato (info presente con otro rótulo) | **370** |
| Laguna real (sin información ni en búsqueda tolerante) | **83** |

De los 83 reales: Plataforma 76, Modelo 38, Fecha 17 (un log puede tener
varios). Ejemplos: `Logs/1645-hy3-m51-m58-reqa218_...md` sin los tres;
`Logs/171-Implementacion-M38-Economia-Nucleo_2026-08-26.md` sin Plataforma.
Ejemplo de falso positivo: `Logs/1011-M60-...md` tiene `Agente / Modelo:`,
`WorkBuddy` y fecha en el cuerpo, pero no los rótulos canónicos.

Listas completas **por dueño inferido del nombre** (hy3 / hy4 / DeepSeek /
director / sin dueño), con ruta: línea y motivo, en:
`DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/34-Backlog-P04-CrossIndex.md`.

## Límites

- No borré traducciones ni toqué logs, `.po`, JSON, `.tres` ni documentos
  ajenos. Sin commits ni push.
- `DINAMICO_POSIBLE` necesita revisión humana del call site antes de cerrarse.
- La atribución de dueño por nombre de archivo es orientativa.

## Estado de las 5 tareas ad-hoc

P-01 cerrada (080), P-02 cerrada por ti, P-03 cerrada (081), P-04 cerrada
(esta). **P-05 sigue RED**: faltan las 11 correcciones de `_GL()` y el
centinela de P-01 está listo para re-medir cuando eso cambie.

Quedo a la espera de tu GO para: (a) instalar el centinela en `tools/`,
(b) aplicar saneos de Totales/GLOBAL, o (c) corregir M42. No hago nada de
eso sin autorización.

**Firma:** hy4-flash
