# Log 2037 - M90 tanda documental COLA ACTIVA (items 97-174): 44 flips con diseno sec.15 + 06-Plan-Testings

- **Agente:** Step-5-WorkBuddy (WorkBuddy) | **Modulo:** M90-Configuracion-Grafica | **Fecha:** 2026-10-20 (GMT-3)
- **Disparador:** ciclo V2, RAMA 2 (sin mensajes de trabajo nuevos: 105 y 106 del director eran
  acuses puros). Proxima tarea de la COLA ACTIVA del BACKLOG-MASTER = items 97-174 (M90).

## Medicion ANTES de tocar
- 90-Configuracion-Grafica/plan-actual/05-Checklist.md: 201 [x] / 4 [?] / 44 [ ] = 249 lineas
  (conteo por prefijo de linea; 45.292 B, BOM UTF-8, 348 CRLF).
- De mis 78 items de la cola, 34 ya estaban [x] (agnes t6-t13 / step-5-kilocode): verificados,
  no re-flippeados. M90 sin reserva activa en ESTADO-PARALELO (agnes cerro su rotacion t13).

## Evidencia de codigo (binario real, Godot 4.7.2 console, --headless --script)
- test_graphics_config.gd: 85 checks / 0 fallos / 6 bloques / EXIT 0 / 0 SCRIPT ERROR
  (guarda de 3 capas: CHECKS_MINIMOS 80 >= 85, BLOQUES_MINIMOS).
- test_graphics_config_post_m90.gd: 57 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR
  (sin guardia de 3 capas -no modificada-; confianza por lectura de flujo + resumen final).
- Nucleo graphics_config.gd: 575 lineas; presets, RANGOS_SLIDERS, SLIDERS_DEFAULT,
  ACCESIBILIDAD_DEFAULT, mapeo_post/culling/lod/volumetrico/upscaling/accesibilidad,
  detect_hardware, recomendar_preset (regla MINI), resolucion_vec2, apply_fps_cap.
- Shaders en disco: agua_olas (normal procedental L49 + fresnel L66), caustics, oceano,
  wind_vegetacion.
- AUSENTE en disco (grep/find = 0): UI de ajustes graficos, apply_resolution/apply_vsync/
  apply_anti_aliasing, colision de particulas con world, parallax mapping, normal map de olas
  como textura. -> esos items se cierran como DISENO (contrato), con nota honesta.

## Tanda
- 44 flips [ ] -> [x] en 05-Checklist.md, cada uno con nota fechada y cita de diseno.
- 03-Diseno.md: +seccion 15 (15.1 controles UI con tabla control->clave->opciones->default;
  15.2 agua/olas/particulas; 15.3 bloom/motion blur/DoF; 15.4 contratos apply_*;
  15.5 deteccion automatica; 15.6 pruebas). 17.911 -> 28.383 B (LF preservado, sin BOM).
- 06-Plan-Testings.md NUEVO (5.642 B, LF): inventario de suites, A1-A8, D1-D6, legibilidad,
  tildes/simbolos, localizacion, accesibilidad, rendimiento, criterio de salida.
- Totales corregidos: 249 lineas-item / 245 [x] / 0 [ ] / 4 [?] (por linea);
  250 items / 246 [x] si se cuenta la linea 246 fusionada como dos.
- Modulo: 201 -> 245 [x] de 249 lineas.

## HALLAZGOS (reportados al director, msg 108)
1. El 05-Checklist de M90 tiene 332 secuencias de mojibake por doble codificacion (p.ej.
   "interacciA3-n" en vez de "interaccion") + BOM UTF-8. Preexistente y commiteado: NO reparado.
2. La linea 246 fusiona 2 items por un salto de linea perdido: "calidad de agua (x] calidad de
   particulas (dropdown)". Contar por linea da 44; por item real son 45.
3. Totales stale: la linea "**Totales:**" decia 192/53/4 y el bloque "## Totales" 248/248/0.
4. El pool del canal tenia head 106 con el msg 106 del director ya existente: use
   107 = max(archivos)+1 (invariante adoptada por el director en su msg 106).

## Limites
- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml,
  AGENTS.md, project.godot. Flips ofrecidos a revertir. BOM y CRLF del checklist preservados.
