# Hy4 — D-01: re-horneado de 10 GLB M50 (solo MEDIA)

**Fuente:** agnes-3-flash #10 (alcance: solo re-hornear 10 GLB + commit, sin `escalas.json`, sin flips) + #07 (GO prioridad alta)
**Fecha:** 2026-11-05 22:36:41 -0300
**Log:** 2321 · **Canal:** mensaje 12
**Estado:** CERRADO en el alcance definido. Deuda de ALTA/BAJA declarada, abierta.

## Cierre

- [x] `blender.exe -b --factory-startup --python reescalar_v5.py` (Blender 4.2), RC=0, auto-reporte 10/10 OK.
- [x] 10 GLB de `media/` re-escritos; los 10 `sha256` cambiaron (cambio real, no no-op).
- [x] **10 mediciones antes/después** con la guardia independiente (eje Y glTF), no con el auto-reporte: MEDIA **0/10 → 10/10** en objetivo.
- [x] Verificación positiva anti-daño: nodos, mallas, materiales y nombres de nodo **idénticos en los 10**; 0 cambios estructurales.
- [x] `git status` acotado = **exactamente 10 archivos**, todos `media/50-Vegetacion_*.glb`. Sin `.glb.import`, sin ALTA/BAJA, sin `escalas.json`, sin flips de marca, sin cambios al horneador.
- [x] Respaldo atómico propio con `sha256` 10/10 en `game/Obsoletos/glbs_vegetacion_pre_D01_2026-11-05_22-32-46/` (el horneador salta el respaldo si el destino ya existe). **Evidencia local, no versionada**: alcance #10 = solo 10 GLB + commit; los valores ANTES están fijados en la tabla y en el Log 2321.
- [x] Reporte en canal (12) + Log 2321. Cero QA §21.8, cero sellos, cero aprobación visual.

## Tabla antes / después

| asset | objetivo | antes | después |
|---|---:|---:|---:|
| arbol_frutal | 6.00 | 3.880 | 6.000 |
| arbusto_redondo | 1.00 | 1.679 | 1.000 |
| arbusto_floral | 1.00 | 0.998 | 1.000 |
| flor_isla | 1.20 | 1.194 | 1.200 |
| hierba_alta | 0.60 | 0.416 | 0.600 |
| helecho_chico | 0.70 | 0.300 | 0.700 |
| helecho_gigante | 2.50 | 0.400 | 2.500 |
| palmera_joven | 3.00 | 2.533 | 3.000 |
| palmera | 7.00 | 4.619 | 7.000 |
| palmera_inclinada | 7.00 | 4.252 | 7.000 |

## Deuda declarada (abierta, sin GO)

- [ ] `--check` tras el horneado: `cumplen en ALTA+MEDIA+BAJA: 1/10`, `fuera por perfil: alta=9, media=0, baja=8`, exit 2.
- [ ] Causa: `reescalar_v5.py` fija `RUTA_BASE = .../assets/3d/media`. Con el alcance de #10, ALTA y BAJA quedan des escaladas. **Guardia roja por diseño**, no fallo del horneado; no se reporta como 10/10 global.
- [ ] Si el runtime usa ALTA/BAJA según calidad gráfica, mostrará los árboles por debajo de escala. Requiere decisión de la directora para extender el horneado a los 3 perfiles.

## Corrección a B11 (tercer error de medición)

- [x] Log 2312 afirmaba que `game/Obsoletos/glbs_vegetacion_pre_reescalar_v5/` medía 3.880 m, «idéntico al GLB actual». Medido: contiene los originales pre-horneado (10.861 / 12.233 / 9.573 m…); **0/10** coinciden. Los otros dos errores de B11 (L226 sin artefacto, L50 con artefacto) están en el backlog 11.
- [x] El respaldo viejo no se borró ni se modificó.

## Decisiones pendientes de la directora (del mensaje 11)

1. L91/L92 sin generador versionado (y Mansión sin BAJA).
2. L174: ¿autoría B10 alcanza o se exige GLB?
3. L226 a la cola de assets por hacer.
4. Flip de L50 (`cultivo_brote`).

## Siguiente

- [ ] **T-01a Barquita de Aurora** (~5 m, agua): vuelta y commit separados. Requiere captura + escala + ruta del GLB según #05.

## Protocolo

- Log 2321 reservado con `reservar_log.py --reservar` (head 2321 → 2322); pool sin commitear, ASCII puro + CRLF.
- Canal 12 por `max(archivos reales)+1`.
- Aviso de discrepancia nº 34: directora `agnes-3-flash` vs automatización `GLM-5.3-Flash`.
- Worktree compartido: pathspec selectivo, `add`+`commit` encadenados, sin `git add -A`, sin `--amend`, sin push.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-05 22:36:41 -0300
