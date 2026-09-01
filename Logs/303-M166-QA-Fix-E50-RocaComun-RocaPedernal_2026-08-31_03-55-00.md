# M166 · QA visual MEDIA completo + fix E-50 en roca_comun/roca_pedernal

**Fecha:** 2026-08-31 03:55
**Estado:** MEDIA barrido completo; roca_comun fixed; roca_pedernal fixed;
capturas de verificacion pendientes (socket muerto al cierre).

## 1. Barrido QA visual MEDIA (52 assets)

`qa_lote.py` para los 8 modulos, --variante media --angulos 6. 4 lotes
encadenados. Resultado: **52/52 corridas, 0 fallidas**, 14.4 min total.

| Lote | Modulos                               | Assets | Tiempo | Fallidas |
|------|---------------------------------------|--------|--------|----------|
| 1    | 50-Vegetacion                         |     12 |  199 s |        0 |
| 2    | 15-Recursos 16-Crafting               |     14 |  232 s |        0 |
| 3    | 25-Ruinas-Templos 40-Infraestructura  |     12 |  199 s |        0 |
| 4    | 13-Herramientas 45-Arte3D 70-Interacciones | 14 |  227 s |        0 |

Los 52 dieron `z_min 0.0450 -> apoyo OK` en el test numerico. Log completo
en `Logs/_tmp_barrido_media.log`.

## 2. E-50 cazado con diag_apoyo sobre los 52 MEDIA

`diag_apoyo.py` (antes `_diag_apoyo_tmp.py`) mide z_min REAL, cuenta
vertices que tocan y reporta el footprint XY. Log completo en
`Logs/_tmp_diag_media.log`.

**E-50 confirmado y VISUALMENTE flotante** (capturas lo muestran):
- `roca_comun` SM_Roca_M_Roca — toca=2, fp=1.291x0.667 (apoyo en linea, no area)
- `roca_pedernal` SM_Roca_M_Pedernal — toca=1, fp=0.000x0.000
- `roca_pedernal` SM_Roca_M_Pedernal_C — toca=1, fp=0.000x0.000

**E-50 latente pero visualmente OK** (la silueta oculta el problema):
- `veta_cobre` SM_Roca_M_Roca_Cobre — toca=1, fp=0.000x0.000. La "roca"
  visible ES el ecuador del huso, la punta enterrada en la arena. El ojo
  lee un disco de roca con espigas de cobre encima. Aceptable.
- `hongo_luminoso` SM_Piedra_M_Piedra_Cueva — toca=1, fp=0.000x0.000. La
  roca base del hongo es un poliedro simple, visualmente convincente.
  Aceptable.
- `monolito_glifos` SM_Monolito_M_Piedra_Monolito — toca=1, fp=0.000x0.000.
  El monolito es un paralelepipedo vertical, el ojo lee "de pie". Aceptable.

## 3. Mi error de juicio en log 301

En log 301 declare "roca_comun / roca_pedernal / veta_cobre E-50 latente
pero aceptable" porque "el anillo ecuatorial plano hace que el ojo lea un
disco". **Era incorrecto.** Mirando bien las capturas:
- roca_comun: NO es un disco, es un bolon irregular. Toca=2 en linea de
  1.3m con cuerpo arriba. **Flota visualmente.**
- roca_pedernal: roca alta con base puntiaguda, solo 1 vertice toca.
  **Flota visualmente.**
- veta_cobre: SI es un disco con espigas, E-50 escondido bajo la arena.
  Si es aceptable.

Lección: **E-31/E-37 se aplican tambien al DIAGNOSTICO**, no solo a la
correccion. "Pasa z_min" no es "se ve apoyado". Hay que mirar las capturas.

## 4. Fix aplicado: roca_comun (3 variantes)

`aplanar_dome.py` (antes `_fix_dome_tmp.py`) con K=2, Z=0.045, patron
`SM_Roca` (toma la primera coincidencia, que es el SM_Roca principal).

| Variante  | Pre                                | Post                                  |
|-----------|------------------------------------|---------------------------------------|
| source    | toca=1, fp=0.000x0.000             | toca=16, fp=1.994x1.817               |
| _media    | toca=2, fp=1.291x0.667             | toca=12, fp=1.835x1.070               |
| _baja     | toca=2, fp=1.291x0.667             | toca=12, fp=2.559x1.056               |

## 5. Fix aplicado: roca_pedernal (3 variantes)

Mismo K=2, Z=0.045. **CUIDADO**: el source usa nombres SIN el sufijo
`_M_` (`SM_Roca_Pedernal`, `SM_Roca_Pedernal_Chica`) mientras que
media/baja usan `SM_Roca_M_Pedernal` y `SM_Roca_M_Pedernal_C`. Por eso
se aplicó via CLI headless iterando sobre todos los SM_, no por patron.

| Variante  | Objeto                       | Pre                              | Post                                |
|-----------|------------------------------|----------------------------------|-------------------------------------|
| source    | SM_Roca_Pedernal             | toca=1, fp=0.000x0.000           | toca=18, fp=1.104x1.090             |
| source    | SM_Roca_Pedernal_Chica       | toca=1, fp=0.000x0.000           | toca=11, fp=0.837x0.960             |
| _media    | SM_Roca_M_Pedernal           | toca=1, fp=0.000x0.000           | toca=18, fp=1.104x1.090             |
| _media    | SM_Roca_M_Pedernal_C         | toca=1, fp=0.000x0.000           | toca=11, fp=0.837x0.960             |
| _baja     | SM_Roca_M_Pedernal           | toca=1, fp=0.000x0.000           | toca=14, fp=1.149x0.976             |
| _baja     | SM_Roca_M_Pedernal_C         | zmin=0.0717 (no toca)            | SKIP (no toca, no necesita fix)     |

## 6. Re-export Godot

`exportar_godot.py` con `EXPORT_FORZAR=1 EXPORT_MODULOS=15-Recursos`,
vía CLI headless (socket muerto, no se podía usar MCP).

- 1ra pasada (con roca_comun ya fixed): 30 exportados, 0 errores.
- 2da pasada (con roca_pedernal tambien fixed): 29 exportados, 1 error
  transitorio en `veta_oro_baja`. Re-ejecutado en aislado: OK.
- `auditar_desincronizados.py`: 69 auditados, **0 desincronizadas**, exit 0.

GLBs modificados en este turno (mtime 2026-08-31 03:55):
- `game/isla-ancestral/assets/3d/{alta,media,baja}/15-Recursos_roca_comun.glb`
- `game/isla-ancestral/assets/3d/{alta,media,baja}/15-Recursos_roca_pedernal.glb`

## 7. Capturas de verificacion visual: PENDIENTES

Socket Blender murió a las 03:53 antes de poder re-capturar roca_comun y
roca_pedernal. **Al re-abrir Blender**, ejecutar:
```
cd tools/mcp/blender-mcp/scripts-reutilizables
PY=.../python.exe
$PY qa_lote.py 15-Recursos --variante media --angulos 6
$PY qa_lote.py 15-Recursos --variante baja --angulos 6
$PY qa_lote.py 15-Recursos --variante alta --angulos 6
```
Y leer las nuevas hojas para confirmar visualmente.

## 8. Limpieza realizada

- Borrados los 3 GLBs temporales de prueba (`_test_cristal*.glb`,
  md5 byte-identico: 5505f9428b4ca289ee20000575bfd4f0).
- Renombrados temporales a herramientas definitivas:
  - `_diag_apoyo_tmp.py` -> `diag_apoyo.py` (cabecera reescrita)
  - `_fix_dome_tmp.py` -> `aplanar_dome.py` (cabecera reescrita)
  - `_dump_verts_tmp.py` -> `dump_anillos.py`
  - `_diag_glb_tmp.py` -> `dump_glb.py`
- Borrados `_diag_tmp.py` y `_diag_parent.py` (superseded).
- Actualizadas 24 referencias en CHECKLIST-OBJETOS-BLENDER.md, logs
  301/302 y 09-GUIA-BLENDER.md.

## 9. Estado del proyecto

- **M166**: MEDIA y BAJA barridos completos (104 assets visuales).
- E-50 corregido en: veta_hierro (log 302), veta_oro (log 302),
  roca_comun (log 303), roca_pedernal (log 303).
- ALTA sin barrer (17 hero assets).
- Cristal ancestral MEDIA: defecto exportador documentado (72 vertices
  degenerados en origen), no resuelto.
