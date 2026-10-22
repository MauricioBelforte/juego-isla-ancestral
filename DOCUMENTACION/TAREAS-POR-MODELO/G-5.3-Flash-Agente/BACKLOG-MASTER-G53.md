# BACKLOG-MASTER DE G-5.3-FLASH-AGENTE (generado por el director 2026-10-22 23:35 - RECLAMO DEL FUNDADOR: nunca se le genero)

Regla: [x] al flipar EN el 05 fuente con cita espejo; [?] si gated; re-poblar cuando queden < 20.
Fuera de asignacion: gated M156 (wav/escenas), M51/M45 visual, M72 (agnes), M77/M99/M16 (Beam), M23 (Step-5), M113 (DS-WB), flags L195-L227 de M151 (fundador).

## SECCION A - M151 Bateria 6 (definibles; SIN los flags del fundador)

- [ ] (151-Control-Final) - [ ] Definir verificación de backup/reintento de cloud (M60) [M]
- [ ] (151-Control-Final) - [ ] Definir verificación de disponibilidad de nombre en plataformas [S]
- [ ] (151-Control-Final) - [ ] Definir política de uso de la marca para la comunidad [S]
- [ ] (151-Control-Final) - [ ] Definir lista de mejoras de comunidad priorizada (5-FUTURAS-MEJORAS) [S]
- [ ] (151-Control-Final) - [ ] Definir dueño por función del post-lanzamiento [S]
- [ ] (151-Control-Final) - [ ] Definir fecha de revisión del plan (M144) [S]

## SECCION B - M156-Terrenos: protocolos de medicion en papel

- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar que audio no causa lag [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar sonidos diferentes por terreno [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar huellas diferentes por terreno [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar particulas diferentes por terreno [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar indicador de UI actualiza [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar que jugador nunca se bloquea [C]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar FPS estable a 60 [M]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar sin errores en consola [S]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar coherencia visual total [M]
- [ ] (156-Terrenos-Y-Movimiento) - [ ] Verificar coherencia audio total [M]

## SECCION C - M76-Multijugador: determinismo/prediccion/reconexion

- [ ] (76-Multijugador) - [ ] Verificar determinismo local (split no red) [M] — **[ ] honesto: requiere FASE MP implementada (split no existe)**
- [ ] (76-Multijugador) - [ ] Verificar que la invitación nunca expone datos [S] — **[ ] honesto: requiere implementación de invitación (FASE MP)**
- [ ] (76-Multijugador) - [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S] — **ESTADO-PARALELO + Log actualizados; fila GLOBAL entregada al director (msg 55
- [ ] (76-Multijugador) - [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S] — **Pendiente: fila GLOBAL a aplicar por el director**

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
