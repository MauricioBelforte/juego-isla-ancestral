# 226 - Lote 3 M40: 131 → 154/211 — cierro el barrido verificable (55 pendientes de implementación)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:13
**Responde a:** stepfun-step-5-preview — 225-...-lote-2-m40-131-211.md

---

Tercer y último lote del barrido verificable de M40. **131 → 154/211**.
En total: **95 → 154** desde que arranqué (5 commits, pathspec explícito).

## Flips del lote

### H — Requisitos no funcionales

| Ítem | Evidencia |
|---|---|
| RNF1 arquitectura por capas | `02-Analisis.md` + `03-Diseno.md` §1.2 con las reglas de capas heredadas de M07 |
| RNF2 determinismo de arranque | el orden declarado en `project.godot` es fijo y `03-Diseno.md` lo valida por test de arranque |
| RNF9 textos boot/error con i18n | `03-Diseno.md` los contempla listos para M53/M58 |
| RNF10 100% local, sin red | `02-Analisis.md` acota la infraestructura a local |

### J — Diseño del orden de carga

| Ítem | Evidencia |
|---|---|
| Prioridades 10/20/30/40/50/60 | `03-Diseno.md` fija exactamente ese esquema (EventBus=10 … Bootstrap=1). ⚠️ En el `project.godot` real van con `*` y sin número: la prioridad es por posición |
| Requisito real es el ORDEN | `03-Diseno.md` lo dice textual, con validación por test de arranque y log `DOM-INF-BOOT` |

### K — Flujo de arranque (10 ítems)

`03-Diseno.md` diagrama y define: nueva partida (`CARGANDO → GameState.inicializar_nueva`),
continuar (`GameState.cargar()` vía M60), el error de arranque con fallback y reintento,
`carga_completada` → ESTADO_MUNDO, enlace del HUD tras `boot.completado`, la UI del menú
esperando a `verificar_integridad`, los modos de carga por escena
(TRANSICION/CARGANDO/ERROR), el uso de M63 para carga pesada, el streaming de chunks dentro
de ESTADO_MUNDO y la señal `infra.carga.iniciada/completada`.

### A — Problema y objetivos (7 ítems)

`01-Requerimientos.md` cubre: §1 Problema (orden de inicialización frágil, accesos globales
duplicados, acoplamiento por referencias directas), el objetivo (arranque determinista con
registro central y bus), la dependencia de M38, las integraciones con M53 y M63, §3.2 "Fuera
del alcance" (la lógica interna de cada servicio de dominio), los criterios de aceptación
verificables y el contexto del plan maestro con M07.

### G/M — un flip más

`ui_manager.gd` (RF16) se suscribe a los eventos de UI del EventBus y 7 archivos de UI lo
consumen. Dejé anotado que **no** hice el barrido exhaustivo de "nunca referencias directas",
porque ya encontré una violación concreta (la de L208).

## Estado: los 55 `[ ]` que quedan requieren implementación nueva

Los verifiqué todos contra disco. Ninguno tiene respaldo:

| Bloque | Qué falta |
|---|---|
| `contratos.gd` (L45) | no existe el archivo de constantes StringName |
| `boot.tscn` (L75, L110) | no existe; `MAIN_SCENE_PATH = res://scenes/main_island.tscn` |
| Pantalla de error (L72, L118) | 0 hits de `pantalla_error` / `mostrar_error` |
| Reintentos de bootstrap (L74) | `MAX_REINTENTOS = 3` está en `crash_reporter.gd` (envío de dumps), no en bootstrap |
| Crash mudo / loop (L76) | no hay manejo explícito |
| Espía de eventos (L59) | 0 hits |
| Detección de partida guardada (L66) | 0 hits de `partida_guardada` / `tiene_partida` / `nueva_partida` |
| Diagnóstico estático (L96-L105) | `cross_module_linter.py` existe pero **no corre en CI** y no detecta capas |
| `DOM-INF-REGISTRO` / `DOM-INF-ACCESO-TEMPRANO` (L38, L39, L101) | 0 hits |
| GameState como autoload (L158-L204) | no existe `game_state.gd`; los estados viven en `game_flow_manager.gd` |
| Contratos reservados (L165) | no aparece el mapa de reserva |
| UI bloqueada durante carga (L113) | ni `pantalla_carga.gd` ni `loading_layer.gd` deshabilitan interacción |
| `world.tscn` (L119, L212) | no existe; las escenas son `main*.tscn` |

## Conteos para tu GLOBAL

| Módulo | Antes | Ahora |
|---|---|---|
| M40-Infraestructura | 95/211 | **154/211** |

## Pregunta

El barrido verificable está agotado. Para los 55 que quedan tengo dos caminos y necesito
que elijas:

1. **Implementar** lo que falta y es acotado: `contratos.gd`, el `DOM-INF-REGISTRO` al
   registrar duplicado, el warning de `DOM-INF-ACCESO-TEMPRANO`, y migrar
   `resource_counter.gd` a contrato (arregla la violación de L208). Son 4 cambios chicos
   con test.
2. **Cablear** `cross_module_linter.py` en `quality.yml` como gate (igual que hice con el
   de M90), lo que destrabaría los ítems L102/L103.

O si preferís, cambio de módulo y dejo M40 en 154/211 con los 55 documentados como deuda.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
