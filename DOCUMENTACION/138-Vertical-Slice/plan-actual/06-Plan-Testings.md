# 06-Plan-Testings — M138 Vertical Slice (plan-actual)

**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-22

Plan profesional de testings del slice (regla AGENTS 14), a ejecutar ANTES de
la primera prueba manual del jugador. Verificacion tecnica SOLO en headless
(G-5.3) o vision (V2/V4) para lo visual; QA cruzado §21.8 por Hy3/agnes.

## 1. Matriz de casos

| # | Caso | Tipo | Como se mide | Criterio de exito |
|---|------|------|--------------|-------------------|
| TC1 | Definiciones de cultivo (farming.json 5) cargan | Unitaria (headless) | qa_farm_pausas_m33 (35 checks 0 fallos ya vigente) | 5 CropDefinition en _definiciones |
| TC2 | Grafo finneas_slice carga y sin IDs rotos | Unitaria (headless) | validate_all_dialogues (CI-DGT) | 0 problemas, nodo fin detecta |
| TC3 | Hacha de Finneas: 30 usos, desbloquea arboleda | Unitaria | test de durabilidad (hito futura iteracion) | contiende >= 30; arbol viejo talable solo con ella |
| TC4 | Cooldown de build/cofre NO afectado por el slice | Regresion | BASE M17 134/0 + iter3 138/0 vigentes | EXIT 0 |
| TC5 | Mision 3 pasos completa en orden (madera -> afilar -> entrega) | Integracion (headless) | qa propio del contador de pasos (M21 flags) | flag_mision_finneas_pasos 1->2->3 chronologico sin salto |
| TC6 | Puzzle SOL/BRISA: 9 combinaciones (I-02) | **Combinatoria completa** (headless) | test_combinatoria_palancas (ver seccion 2) | solo (ocaso,alba) abre; otras 8 no.
| TC7 | Autosave en hitos (entrega / puzzle_resuelto) | Integracion | flag -> save v2 presente con schema_version | save.version == 2 y claves del slice |
| TC8 | Dialogo M21 <-> pausa NPC (puente M64) | Integracion | qa_m21_puente_m64 (8/0 vigente) | NPC congelado en dialogo activo |
| TC9 | Entregar madera ANTES del dialogo inicial | Edge case | orden inverso scriptado (flag_mision_finneas_aceptada false) | la entrega no marca paso 1 si no hubo aceptacion; mensaje de Finneas cubre el atajo |
| TC10 | Salir de la ruina sin resolver puzzle | Edge case | reload de escena | estado del puzzle persiste (discos en posiciones previas) |
| TC11 | Dormir sin haber aceptado nada (casa con entrada/cama) | Edge case | fade lado | dia pasa; mision intacta |
| TC12 | Flujo completo 20-30 min | Render/sesion | playtest V1 (usuario) | loop completo sin softlock; autosave en 2 hitos |
| TC13 | Budget de render (vegetacion M50 + luces M49/M61) | Performance | conteo draw calls en captured (cap_godot) | dentro del presupuesto L5 de Beam (no supera fila GLOBAL de M138) |

**TC6 (I-02, L46 del 05) en detalle - matriz completa de combinatoria:**
espacio = 3 posiciones de SOL x 3 de BRISA = 9 estados:
(SS,SB) (SM,SB) (SO,SB) | (SS,BM) (SM,BM) (**SO,BM**) | (SS,BO) (SM,BO) (SO,BO)
donde S/S/B = palanca_SOL x palanca_BRISA en s=alba/m=mediodia/o=ocaso.
UNICO estado que abre: (SO, BM) = SOL en ocaso, BRISA en alba (espejo del
horizonte, pista de la placa). Los otros 8 estados: reja cerrada, sin reset,
sin penalizacion (cozy). El test genera las 9 combinaciones por codigo, aplica
senal puzzle_sala_resuelta y cuenta aperturas = 1 entre 9, NO mas (anti-or).

## 2. Orden de ejecucion previsto

1. Suite definiciones/dialogos (TC1, TC2) — ya verdes en CI-DGT.
2. Suite integracion de mision (TC5, TC9) — proxima tanda headless.
3. Suite puzzle (TC6) + save (TC7/TC10) tras implementar la ruina.
4. Regresion global (TC4 + barrido de suites de 14 modulos).
5. Playtest manual (TC12) + perf (TC13) con capturas del set (M154 V2/V4).

## 3. Notas del agente (S28, 2026-10-22)

- L54 (save v2 schema_version) se define en el 03-Diseno (seccion Recompensa
  de la ruina menciona el autosave) + tabla TC7 arriba: claves del slice:
  mision_paso (int), hacha_finneas_duracion (int), estado_discos (par),
  puzzle_resuelto (bool), flags M21 de la conversa. Version = 2 con
  migracion desde v1 (mapa M60).
- TC12 y TC13 necesitan GO de integracion (escena del slice) y contenido de
  Beam (render) — marcados pendientes, no bloquean las definiciones de
  contenido.
- Coherencia con canon: recompensa AO ya validada (20 AO = 13.3% de
  taller_crafting 150, banda [8,22] de quests.json/unlocks.json).
