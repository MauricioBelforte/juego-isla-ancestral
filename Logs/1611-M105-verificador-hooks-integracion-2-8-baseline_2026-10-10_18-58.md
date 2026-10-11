# Log 1611: M105 — verificador de hooks de integración entregado (scripts/verificar_hooks_m105.py, 8 hooks, baseline 2/8)

**Fecha:** 2026-10-10
**Hora:** 18:58
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 109, tras gate .gitignore aceptado): **verificador de
hooks de M105**. Se entregó `scripts/verificar_hooks_m105.py` — script de solo
lectura que mide contra el árbol real los 8 hooks de integración de Telemetría
(H1 M105→M104, H2 hook de cierre, H3 gameplay→M105, H4 M22, H5 M71, H6 M53
encuesta, H7 M91 opt-in, H8 autoload). **Baseline medido: 2/8 cableados**
(H1 CONECTADO + H8 REGISTRADO; H2-H7 NO CONECTADO, H3 = 0 consumidores en 960
`.gd`), reproduciendo de forma independiente la medición de s2 (Log 1591).
Validación en ambas ramas: rama cableada (H1/H8) y rama sin cablear (H2-H7) +
**sonda de detección positiva** temporal (`_sonda_hooks_m105.gd` en
`scripts/player/` → H3 consumidores=1; borrada, 0 restos). Modo `--json` (8
claves, exit 0). Sin tocar runtime, marcas de checklist ni archivos ajenos.

## Cambios Realizados

1. **`scripts/verificar_hooks_m105.py` (NUEVO)** — 8 hooks, salida texto +
   `--json`; scans con regex sobre `game/isla-ancestral/scripts/**` excluyendo
   `telemetry/`, directorios de backup y tests (los tests no cuentan como
   consumidores); detección por llamada calificada `TelemetryDirector.*` o
   `get_node("/root/TelemetryDirector")`; lectura UTF-8 con conteo de errores
   de decode; informativo (exit 0), no gate.
2. **`DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/04-Codigo.md`** —
   sección "Verificador de hooks de integracion (2026-10-10)" con la tabla de
   8 hooks y la validación; sección "Notas del Agente" (firmada) con lo hecho,
   lo no hecho (cableado de gameplay = alcance nuevo pendiente de OK del
   director, propuesto por s2 en Log 1591), los 3 pares de duplicados textuales
   Patron D del `05-Checklist.md` (L230/231, L234/235, L237/238 — reportados,
   NO tocados, directiva msg 109) y el drift de conteo 120/45 documentado vs
   122/43 medido.
3. **`Logs/NUMEROS_DISPONIBLES.txt`** — consumo de 1611 + eliminación de un
   BOM (`ef bb bf`) que había aparecido en la primera línea ( probablemente
   PowerShell UTF8-BOM de otro agente); el pool queda utf-8 sin BOM.

## Evidencia

- Baseline: `python scripts/verificar_hooks_m105.py` → 2/8; H3
  `archivos_gd_escaneados=960 consumidores=0 menciones_sin_llamada=0
  decode_errores=0`; exit 0.
- Sonda positiva: con `_sonda_hooks_m105.gd` → `consumidores=1
  - player/_sonda_hooks_m105.gd [track=track_house_first_built]`; sin sonda →
  baseline; `sonda borrada: True`.
- JSON: exit 0, 8 claves, H1 CONECTADO, H8 REGISTRADO, H3 0/960.

## Archivos Modificados/Creados

- `scripts/verificar_hooks_m105.py` (nuevo)
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/04-Codigo.md`
- `Logs/NUMEROS_DISPONIBLES.txt`

## Siguiente

Informe msg 111. Cablear hooks de gameplay (H2-H7) queda pendiente de OK del
director (alcance nuevo, s2 lo propuso en Log 1591). Opinion sobre Rec 1
(`.claude/*` + `!.claude/skills/`) enviada en msg 110.
