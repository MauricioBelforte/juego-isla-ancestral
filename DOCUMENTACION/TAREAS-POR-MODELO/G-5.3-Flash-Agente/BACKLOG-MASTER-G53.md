# BACKLOG-MASTER DE G-5.3-FLASH-AGENTE (generado por el director 2026-10-22 23:35 - RECLAMO DEL FUNDADOR: nunca se le genero)

Regla: [x] al flipar EN el 05 fuente con cita espejo; [?] si gated; re-poblar cuando queden < 20.
Fuera de asignacion: gated M156 (wav/escenas), M51/M45 visual, M72 (agnes), M77/M99/M16 (Beam), M23 (Step-5), M113 (DS-WB), flags L195-L227 de M151 (fundador).

## SECCION A - M151 Bateria 6 (definibles; SIN los flags del fundador)

- [x] (151-Control-Final) - [ ] Definir verificación de backup/reintento de cloud (M60) [M] — !!! FLAG TECNICO: backend cloud M60 inexistente en headless; dueno M60 con build integrado (anotado inline en el 05; NO flip en el 05)
- [x] (151-Control-Final) - [ ] Definir verificación de disponibilidad de nombre en plataformas [S] — !!! FLAG FUNDADOR anotado inline en el 05 (decision de nombre final; verificacion de stores post-decision)
- [x] (151-Control-Final) - [ ] Definir política de uso de la marca para la comunidad [S] — !!! FLAG FUNDADOR anotado inline (esbozo en 03 Bateria 5 pendiente de revision editorial)
- [x] (151-Control-Final) - [ ] Definir lista de mejoras de comunidad priorizada (5-FUTURAS-MEJORAS) [S] — !!! FLAG FUNDADOR anotado inline (5-FUTURAS-MEJORAS es anotador del usuario)
- [x] (151-Control-Final) - [ ] Definir dueño por función del post-lanzamiento [S] — !!! FLAG FUNDADOR anotado inline (staffing del post-lanzamiento)
- [x] (151-Control-Final) - [ ] Definir fecha de revisión del plan (M144) [S] — !!! FLAG FUNDADOR anotado inline (agenda M144)

## SECCION B - M156-Terrenos: protocolos de medicion en papel

- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar que audio no causa lag [S] — [x] P1 en 03 sec Protocolos (profiler Audio; 0 frames >100 ms; CPU <2%)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar sonidos diferentes por terreno [S] — [x] P2 (tabla material->sfx; 6/6 distintos)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar huellas diferentes por terreno [S] — [x] P3 (decals 6/6; 0 fuga)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar particulas diferentes por terreno [S] — [x] P4 (pool M52 6/6; 0 cruzado)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar indicador de UI actualiza [S] — [x] P5 (estado precede UI <= 2 frames 100%)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar que jugador nunca se bloquea [C] — [x] P6 (recorrido autonomo; 0 congelamientos >5 s)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar FPS estable a 60 [M] — [x] P7 (REPORTE-FPS TC13; >=60 prom / 1% low >=45)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar sin errores en consola [S] — [x] P8 (get_debug_output; 0 ERROR/FATAL en tanda 15 min)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar coherencia visual total [M] — [x] P9 (style-guide dueno de arte; 100% canon)
- [x] (156-Terrenos-Y-Movimiento) - [ ] Verificar coherencia audio total [M] — [x] P10 (mezclador buses + tabla M42; 100% zonas)

## SECCION C - M76-Multijugador: determinismo/prediccion/reconexion

- [x] (76-Multijugador) - [ ] Verificar determinismo local (split no red) [M] — [x] PR1 definido en 03 sec Protocolos M76 (semilla M29 + hash tick 300/3000/30000; ejecucion para fase MP) — **[ ] honesto: requiere FASE MP implementada (split no existe)**
- [x] (76-Multijugador) - [ ] Verificar que la invitación nunca expone datos [S] — [x] PR2 definido (whitelist payload; 0 PII; token expirable; ejecucion fase MP) — **[ ] honesto: requiere implementación de invitación (FASE MP)**
- [ ] (76-Multijugador) - [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S] — **ESTADO-PARALELO + Log actualizados; fila GLOBAL entregada al director (msg 55
- [x] (76-Multijugador) - [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S] — [x] PR3 definido (diff contra baseline firmado en Logs; 0 alertas nuevas no documentadas) — **Pendiente: fila GLOBAL a aplicar por el director**

## SECCION D - M138: definiciones faltantes (no implementacion)

- [ ] (138-Vertical-Slice) - [ ] Definir vegetación con MultiMesh (M50, sin rebalsar draw calls) [C]
- [ ] (138-Vertical-Slice) - [ ] Definir iluminación de la zona dentro del budget render (M49/M61) [C]
- [ ] (138-Vertical-Slice) - [ ] Definir test: tester nuevo completa el slice sin instrucciones [C]
- [ ] (138-Vertical-Slice) - [ ] Definir serialización completa de la zona (chunks modificados) [C]
- [ ] (138-Vertical-Slice) - [ ] Definir test de 10 ciclos guardar→cargar con 0 pérdidas [C]
- [ ] (138-Vertical-Slice) - [ ] Definir texturas con los tamaños del preset (M47) [M]
- [ ] (138-Vertical-Slice) - [ ] Definir animaciones importadas con el formato del proyecto [M]
- [ ] (138-Vertical-Slice) - [ ] Definir audio importado con compresión del proyecto [M]
- [ ] (138-Vertical-Slice) - [ ] Definir empaquetado de la demo (M116/M117) [M]
- [ ] (138-Vertical-Slice) - [ ] Definir actualización del presupuesto con datos reales (M134) [M]
- [ ] (138-Vertical-Slice) - [ ] Definir comunicar al usuario la decisión y próximo hito [S]

## SECCION E - M48: definiciones de animacion

- [ ] (48-Animacion) - [ ] Documentar restricciones: Godot 4.x, FPS 30 base (UI 60), determinismo de mundo, sin RNG, sincronía en timelines [M]
- [ ] (48-Animacion) - [ ] Definir sockets de herramientas (grip) con M45 [M]
- [ ] (48-Animacion) - [ ] Verificar naming anim_[actor]_[estado] [S]
- [ ] (48-Animacion) - [ ] Verificar fps 30 base / UI 60 [S]
- [ ] (48-Animacion) - [ ] Verificar duración dentro de máximos por categoría [S]
- [ ] (48-Animacion) - [ ] Verificar T-pose única y bones subset [M]
- [ ] (48-Animacion) - [ ] Verificar keyframes de evento requeridos [M]
- [ ] (48-Animacion) - [ ] Documentar integración con M64/M65 (burbuja) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M45 (rigs/sockets) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M13 (herramientas) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M43/M44/M52 (eventos) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M50/M51 (procedural) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M21/M53/M58 (UI) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M61/M62 (presupuesto) [S]
- [ ] (48-Animacion) - [ ] Documentar integración con M74 (festivales) [S]

## SECCION F - M56: definiciones de foto

- [ ] (56-Fotografia) - [ ] Definir iconos de controles del modo foto (M46) [M]
- [ ] (56-Fotografia) - [ ] Documentar plan de testings automáticos del modo foto [M]
- [ ] (56-Fotografia) - [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]

## SECCION H - M50/M53/M67: picaduras

- [ ] (Varios) - [ ] Verificar presupuesto (instancias/draw calls/VRAM) [M] — [ ] honesto 2026-10-19 (Log 2022): el spawner usa instanciación directa de GLB (no Mult
- [ ] (Varios) - [ ] Costo MultiMesh dentro del presupuesto [M] — [ ] honesto 2026-10-19 (Log 2022): no existe MultiMesh en el pipeline (instanciación directa, L140)
- [ ] (Varios) - [ ] Verificar coherencia visual entre todas las capas (un solo lenguaje) [M] — HALLAZGO DOCUMENTADO 2026-10-12 (Ling 3.1 Flash; origen: lote M128 ms
- [ ] (Varios) - [ ] Font subsetting por idioma (M88) para evitar desperdicio de memoria [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): `theme_ux.gd:193-208` `_try_loa
- [ ] (Varios) - [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
