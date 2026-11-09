# Reporte: Partículas, VFX y efectos visuales — Isla Ancestral

- **Modelo:** Glyph Cluster
- **Plataforma:** Kilo Code (sesión de análisis)
- **Fecha:** 2026-11-09
- **Alcance solicitado:** `game/isla-ancestral/scripts/` — archivos `.gd` relacionados con partículas, VFX y efectos visuales (`scripts/particles/`, `scripts/vfx/`, `scripts/efectos/` o similar), más usos relevantes detectados en `scripts/terrenos/`, `scripts/fasttravel/`, `scripts/crafting/`, `scripts/tools/` y escenas/preview asociadas.
- **Método:** revisión estática del código fuente, escenas `.tscn` y catálogo `data/vfx/vfx_catalog.json`. No se ejecutó el juego en esta sesión.

## Archivos analizados (núcleo)

| Archivo | Rol principal |
|---|---|
| `game/isla-ancestral/scripts/particles/vfx_director.gd` | Orquestador de VFX por eventos: traduce buses del `EventBus` a emisiones, gestiona vida temporal y llama al pool. |
| `game/isla-ancestral/scripts/particles/vfx_factory.gd` | Crea/configura `GPUParticles3D` (`nuevo_emisor`, `crear`, `redisparar`) y carga el catálogo. |
| `game/isla-ancestral/scripts/particles/vfx_pool.gd` | Pool de emisores reutilizables con límites, reciclado, métricas y determinismo (`semilla_de`). |
| `game/isla-ancestral/scripts/particles/vfx_trigger.gd` | Mapeo catálogo → señales namespaced reales del `EventBus`; reporta buses faltantes. |
| `game/isla-ancestral/scripts/particles/vfx_loops.gd` | Lógica pura de loops ambientales (registro por zona, culling por radio, LOD, fase fija). **No instancia nodos.** |
| `game/isla-ancestral/scripts/particles/vfx_schema.gd` | Validación del catálogo VFX (rangos, naming, RF3/RF4/RF6/RF7/RF11/RF14/RF16). |
| `game/isla-ancestral/scripts/particles/preview_particles.gd` | Preview de polen (CPUParticles3D en escena + `GPUParticles3D` creado en runtime). |
| `game/isla-ancestral/scripts/particles/preview_vfx_m52.gd` | Preview que dispara eventos representativos vía `VfxDirector`. |
| `game/isla-ancestral/scripts/terrenos/terrain_particles.gd` | Ráfagas de `CPUParticles3D` por tipo de terreno, con pooling propio y límites. |
| `game/isla-ancestral/scripts/fasttravel/fast_travel_effect.gd` | `CPUParticles2D` de bruma 2D durante transición de viaje rápido (activada/desactivada). |
| `game/isla-ancestral/scripts/crafting/crafting_feedback.gd` | Burst `CPUParticles2D` one-shot con limpieza diferida por temporizador. |
| `game/isla-ancestral/scripts/tools/tool_feedback.gd` | Pools round-robin de `AudioStreamPlayer` y `GPUParticles3D` (`top_level=true`, `restart()` por impacto). |
| `game/isla-ancestral/data/vfx/vfx_catalog.json` | Catálogo v2 con 31 entradas VFX (loops/one-shot, buses, presupuestos, radios, etc.). |
| `game/isla-ancestral/scenes/preview_vfx_m52.tscn` | Escena de preview M52. |
| `game/isla-ancestral/scenes/terrenos/particulas_*.tscn` (7 escenas) | Plantillas `CPUParticles3D` por terreno (`emitting=false`, `amount` pequeño). |

> Nota: no existe `scripts/vfx/` ni `scripts/efectos/` como carpetas dedicadas; la funcionalidad VFX principal está en `scripts/particles/` y hay efectos puntuales en otros módulos.

---

## 1) ¿Cómo se gestionan los sistemas de partículas?

### Arquitectura M52 (VFX por eventos)
- **Catálogo data-driven:** `vfx_factory.gd` carga `res://data/vfx/vfx_catalog.json` (`RUTA_CATALOGO`, línea 18; `cargar_catalogo()`, líneas 22–28). `vfx_schema.gd` valida versión, campos, rangos, naming, cobertura del plan y reglas RF (`validar_catalogo`, líneas 61–85; `validar_entrada`, 88–165).
- **Traducción evento → VFX:** `vfx_trigger.gd` deriva un mapa `bus -> ids` desde el catálogo (`construir`, líneas 33–52), conecta señales namespaced reales del `EventBus` (`conectar`, líneas 81–110) y filtra por condición (`disparar`, 115–124; `cumple_condicion`, 128–134). Esto corrige el fallo histórico de iter. 5 donde el director dependía de una señal inexistente.
- **Orquestación:** `vfx_director.gd` indexa por evento/id (`_por_evento`, `_por_id`, líneas 78–85), crea un `VfxContainer` propio si no se inyecta (`líneas 86–92`), construye el trigger y conecta buses (`93–105`), actualiza vida en `_process` (`actualizar(delta)`, 109–110, 166–176) y dispara VFX (`disparar`, 147–163). La posición se resuelve desde `contexto["args"]` o proveedor/cámara (`_on_bus`, 183–193; `_posicion_de`, 197–205; `_posicion_defecto`, 207–219).
- **Pool de emisores:** `vfx_pool.gd` presta/libera `GPUParticles3D` reutilizables (`prestar`, 135–177; `liberar`, 180–188; `liberar_todos`, 191–196), precalienta (`precalentar`, 99–113; `precalentar_catalogo`, 117–121), fija semilla determinista (`semilla_de` FNV-1a, 83–90; `validar_semillas`, 94–103) y aplica límites de emisores/partículas con reciclado del más antiguo (`_hacer_hueco`, 271–286; `_reciclar_mas_antiguo`, 292–306). Emite `emision_descartada` para telemetría/log (`_descartar`, 260–265; director lo registra como `VFX-SKIP`, director 222–229).
- **Creación/reuso de nodos:** `vfx_factory.gd` configura `draw_pass_1` (Godot 4.3+), `one_shot`, `lifetime`, `amount`, material y malla (`nuevo_emisor`, 52–61). `redisparar` reconfigura y **fija `seed` después de `restart()`** para determinismo (`líneas 68–77`).

### Loops ambientales (diseño, sin nodos)
- `vfx_loops.gd` es **lógica pura** (`RefCounted`): registra loops por zona, culling por radio, LOD (25% lejos), cantidad efectiva, fase fija en `[0,1)` y resumen (`registrar`, 28–45; `activos`, 68–77; `factor_lod`, 81–85; `cantidad_efectiva`, 89–98; `fase_en_t`, 104–107; `resumen`, 116–129). **No crea ni destruye emisores**; el ciclo de vida real del nodo queda a cargo del consumidor que integre esta lógica.

### Sistemas fuera de M52
- **Terreno (M156):** `terrain_particles.gd` usa escenas `particulas_<terreno>.tscn` (`CPUParticles3D`), precarga 7 escenas (`_precargar_escenas`, 57–66), emite ráfagas al moverse según frecuencia/intensidad (`_physics_process`, 73–88; `_emitir_rafaga`, 99–112), mantiene pool propio con tope `max_emisores` y recicla el activo más viejo (`líneas 100–103`, `_liberar` 162–168).
- **Herramientas:** `tool_feedback.gd` mantiene pools fijos (5 audio, 8 partículas) y reutiliza emisores `GPUParticles3D` con `one_shot`, `top_level=true`, `restart()` y recolor por material (`_crear_emisor`, 136–159; `_reventar`, 161–168).
- **Crafteo:** `crafting_feedback.gd` instancia un `CPUParticles2D` one-shot por descubrimiento y lo elimina con `timer.timeout -> queue_free` (`_emitir_particulas_doradas`, 140–168).
- **Viaje rápido:** `fast_travel_effect.gd` crea una bruma `CPUParticles2D` persistente en la UI de transición y solo conmuta `emitting`/visibilidad (`_armar_bruma`, 126–145; `iniciar_transicion`/`cancelar`/finalización, 169–236).

---

## 2) ¿Hay fugas de partículas no detenidas?

### Hallazgos

1. **`vfx_pool.vaciar()` no detiene ni libera nodos (riesgo de fuga/referencia huérfana si se usa mal).**  
   - **Archivo/líneas:** `game/isla-ancestral/scripts/particles/vfx_pool.gd:247-254`.  
   - **Detalle:** `vaciar()` hace `_activos.clear()`, `_libres.clear()`, `_creados = 0`, `_emisiones = 0`, pero **no** llama `queue_free()`, **no** pone `emitting=false` y **no** desparenta nodos. La API segura documentada está en el director (`finalizar()` hace `queue_free` de `nodos()` y luego `vaciar()`; `vfx_director.gd:246-252`), pero cualquier consumidor que use el pool directamente y llame `vaciar()` puede dejar `GPUParticles3D` vivos en el árbol o, si ya fueron removidos, perder la referencia sin liberar.

2. **`preview_particles.gd` crea `GPUParticles3D` en runtime sin ruta de limpieza.**  
   - **Archivo/líneas:** `game/isla-ancestral/scripts/particles/preview_particles.gd:35-91`.  
   - **Detalle:** crea `gp`, materiales, malla y `ParticleProcessMaterial`, lo añade con `add_child(gp)` y lo deja emitiendo (`gp.emitting = true`). No hay `_exit_tree()`/`queue_free()`. En una escena de preview aislada esto es de bajo impacto, pero es un patrón de nodo creado dinámicamente sin ownership explícito de cierre.

3. **`terrain_particles._liberar()` conserva nodos en pool interno (retención controlada, no fuga inmediata).**  
   - **Archivo/líneas:** `game/isla-ancestral/scripts/terrenos/terrain_particles.gd:162-168`.  
   - **Detalle:** apaga `emitting` y oculta, pero guarda el nodo en `_pool`. No hay liberación al salir de escena/árbol. Es **pooling intencional** acotado por uso, aunque puede retener memoria si el componente se destruye en condiciones no estándar; en el flujo normal, al destruir el `Node3D` padre sus hijos se liberan.

### Casos bien manejados
- **Director M52:** `_exit_tree()` llama `finalizar()` y `finalizar()` hace `queue_free()` de todos los nodos del pool antes de vaciar (`vfx_director.gd:112-114, 246-252`).
- **Crafteo:** el burst se elimina con temporizador y `queue_free()` sobre el contenedor (`crafting_feedback.gd:158-168`).
- **Tool feedback:** usa pools fijos persistentes y `restart()`/`one_shot` en vez de instanciar por impacto (`tool_feedback.gd:136-168`).
- **Catálogo/plantillas:** escenas de terreno tienen `emitting=false` en la plantilla (`particulas_arena.tscn`), evitando emisión automática al instanciar.

---

## 3) ¿Hay problemas de rendimiento con demasiadas partículas activas?

### Controles existentes (positivos)
- **Presupuesto y tope en pool VFX:** `VfxPool` limita `max_emisores` y `max_particulas` (defaults 32/1200), recicla activos antiguos y descarta si el efecto excede el presupuesto (`vfx_pool.gd:30-42, 142-154, 271-286`). `stats()` expone métricas (`227-234`).
- **Catálogo con presupuesto por efecto:** `vfx_catalog.json` incluye `presupuesto` y `cantidad`; el schema exige `presupuesto >= cantidad` (`vfx_schema.gd:127-129`).
- **LOD/culling en loops (lógica):** `vfx_loops.gd` aplica culling por radio y LOD 25% lejos (`líneas 19-21, 68-98`).
- **Pooling en terreno/herramientas:** `terrain_particles.gd` limita a `max_emisores` (default 6, línea 28) y reutiliza nodos; `tool_feedback.gd` usa pool fijo de 8 emisores.

### Riesgos / puntos de presión
1. **`vfx_loops.gd` no controla instancias reales de emisores.**  
   - **Archivo/líneas:** `vfx_loops.gd` completo (especialmente 116–129 `resumen`).  
   - **Detalle:** calcula qué zonas/cantidades deberían emitir, pero **no crea, no detiene ni no limita nodos**. Si un integrador instancia un emisor por zona activa sin respetar presupuesto global/Límites del director/pool, puede acumular demasiados emisores simultáneos. El propio archivo declara ser “lógica pura”; el riesgo está en la integración futura.

2. **Director M52: vida gestionada por temporizador manual, no por señal de fin de partícula.**  
   - **Archivo/líneas:** `vfx_director.gd:68, 161-163, 166-176`.  
   - **Detalle:** guarda `_vida[nodo] = maxf(0.2, emision)` y libera cuando el contador llega a 0. Esto es simple y determinista, pero no observa `emitting`/señal `finished`. Si `lifetime` real del emisor difiere del campo `emision` usado por el director, puede devolver al pool antes o después de lo visualmente esperado. No es fuga directa, pero puede afectar calidad/percepción de carga.

3. **Efectos 2D/3D puntuales con asignaciones por evento.**  
   - `crafting_feedback.gd:140-168` crea nodos por activación (aunque los limpia); en ráfagas de eventos podría generar churn. Impacto esperado bajo/moderado.
   - `preview_particles.gd:35-91` crea materiales/mallas/texturas en runtime (aceptable para preview, no para gameplay repetido).

---

## 4) ¿Hay partículas que no se limpian al salir del área?

### Evaluación
- **VFX por eventos (M52):** los one-shot se devuelven al pool por expiración de vida (`vfx_director._process -> actualizar`, líneas 109–110, 166–176). No dependen del “área” sino del tiempo; al salir del árbol, el director limpia el pool (`_exit_tree/finalizar`, 112–114, 246–252). **Correcto para el modelo actual.**
- **Loops ambientales:** `vfx_loops.gd` no mantiene nodos; `desregistrar(zona)` existe (líneas 48–49), pero **la limpieza del emisor visual real depende del código que consuma esta clase**. Si el integrador registra una zona y nunca llama `desregistrar` ni detiene su emisor al salir del radio/área, el loop puede seguir activo. **Riesgo de integración/no-limpieza al salir del área.**
- **Terreno (`terrain_particles.gd`):** emite ráfagas mientras la velocidad horizontal supera `velocidad_minima`; al detenerse reinicia `_timer_rafaga` (`_physics_process`, 73–82). Los emisores activos se apagan cuando su tiempo restante termina (`_gestionar_activos`, 152–159). No hay mecanismo explícito “al salir del área de terreno”, pero el sistema está ligado al movimiento del jugador y al detector de terreno; no se observó acumulación infinita por diseño.
- **Viaje rápido:** la bruma se apaga en `_al_terminar` y `cancelar` (`fast_travel_effect.gd:213-236, 252-256`), adecuada al alcance de la transición.

**Conclusión puntual (4):** no se evidencia una fuga clara de one-shots M52 al salir de área; el punto débil es la **integración de `VfxLoops`** (lógica sin ownership de nodos) y el uso directo de `VfxPool.vaciar()` sin liberar nodos.

---

## 5) Dos mejoras sugeridas

1. **Cerrar el ciclo de vida de loops ambientales con un “owner” de emisores (integración segura de `VfxLoops`).**  
   - **Problema:** `vfx_loops.gd` decide culling/LOD/fase, pero no instancia ni limpia emisores; al salir de área/radio o al descargar zona, un integrador puede dejar partículas activas.  
   - **Acción concreta:** crear un componente integrador (p. ej. `VfxLoopManager`) que, por cada zona activa devuelta por `VfxLoops`, pida un emisor al pool/director, lo posicione, ajuste `amount` por LOD y lo libere/pare al perder culling o al llamar `desregistrar`. Añadir prueba headless que simule “entrar → salir de radio → zona desregistrada” verificando `activos()==0`/nodos liberados.  
   - **Beneficio:** elimina fugas por abandono de loops y hace cumplir RF9/RF14 en runtime, no solo en cálculo.

2. **Endurecer la API de liberación del pool y alinear la vida con el estado real del emisor.**  
   - **Problema:** `VfxPool.vaciar()` borra estructuras sin liberar nodos (`vfx_pool.gd:247-254`), y `VfxDirector` libera por contador `emision` (`vfx_director.gd:161-176`) en vez de observar el fin real del `GPUParticles3D`.  
   - **Acción concreta:** (a) hacer que `vaciar(liberar_nodos := false)` detenga `emitting` y, opcionalmente, haga `queue_free()`/desparentado controlado; documentar que el uso directo requiere `liberar_todos()`+liberación de nodos o usar `finalizar()` vía director. (b) en `actualizar()`, considerar también `gp.emitting == false`/señal `finished` (cuando aplique) o usar `lifetime` efectivo del emisor para devolver al pool, manteniendo fallback determinista.  
   - **Beneficio:** reduce riesgo de fugas por uso incorrecto del pool y mejora la precisión de reciclado/rendimiento bajo variaciones de configuración.

---

## Conclusión final

El sistema de partículas/VFX del proyecto está **más maduro en M52** que en iteraciones previas documentadas: el `VfxDirector` ya usa `VfxTrigger` con buses namespaced reales, registra `VFX-SKIP` al descartar, actualiza en `_process` y libera nodos en `_exit_tree/finalizar`. `VfxPool` + `VfxFactory` aportan reutilización, límites de emisores/partículas, reciclado y determinismo (semilla FNV-1a, `seed` tras `restart()`), lo cual mitiga fugas y picos de asignación en el flujo principal.

Sin embargo, quedan riesgos concretos: (1) **`VfxPool.vaciar()` no libera nodos**, lo que puede causar fugas si se usa fuera del patrón `finalizar()`; (2) **`VfxLoops` es solo lógica** y no garantiza limpieza de emisores al salir de área/culling sin un integrador que gestione el ciclo de vida; (3) la **vida de emisión en el director** se controla por temporizador (`emision`) y no por el estado real del emisor. Los efectos fuera de M52 (`terrain_particles`, `tool_feedback`, `crafting_feedback`, `fast_travel_effect`) muestran, en general, patrones razonables (pooling, `one_shot`, limpieza diferida o conmutación de `emitting`), con observaciones menores en previews/scripts de demo.

**Estado global:** base técnica sólida para VFX por eventos y presupuestos; se recomienda priorizar la **integración segura de loops ambientales** y el **endurecimiento de `vaciar()`/ciclo de vida** antes de escalar cantidad de efectos simultáneos en gameplay.