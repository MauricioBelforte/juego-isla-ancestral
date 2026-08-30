# Log 237 — M166: Rotación de las 3 herramientas tumbadas + fix E-26 en `capturar_angulos.py`

**Fecha:** 2026-08-29 15:20 GMT-3
**Módulo:** M166 (Variantes y perfil de rendimiento)
**Continuación de:** log 234 (promoción de la frontera)

---

## Resumen ejecutivo

Pendientes del log 234 cerrados para las 3 herramientas de mano. Ahora `pico_hierro`, `pico_piedra` y `hacha_piedra` tienen las 4 variantes (`_baja`, `_media`, `_alta`, `_alta_media`) con pose **vertical**, cabeza arriba, pomo abajo, sin flotación.

Adicionalmente se descubrió y corrigió el bug **E-26** en `capturar_angulos.py`: el script renderizaba lo que Blender tuviera cargado en ese momento, sin abrir el archivo pasado por argumento. Eso producía auditorías visuales sobre el asset equivocado.

---

## 1. Estado inicial (al retomar este log)

| Asset | Estado del source | Veredicto del pose-audit |
|---|---|---|
| `pico_hierro_lowpoly` | dimX=0.893, **horizontal tumbado** (mango a lo largo de X, cabeza en -X, pomo en +X) | TUMBADO |
| `pico_piedra_lowpoly` | dimX=0.179, dimY=0.700, dimZ=0.893 — Z mayor, **vertical** (mango a lo largo de Z) | TUMBADO ❌ (falso positivo — el audit se equivocó) |
| `hacha_piedra_lowpoly` | dimX=0.122, dimY=0.390, dimZ=0.792 — Z mayor, **vertical** (mango a lo largo de Z) | TUMBADO ❌ (falso positivo) |

De las 3, **solo pico_hierro estaba realmente tumbado**. Las otras 2 ya estaban verticales en el source; el pose-audit las marcó mal por un bug en su criterio de orientación (ver §5).

## 2. Rotación de `pico_hierro`

El source tumbado tiene:
- Mango a lo largo de X, de -0.43 a +0.43 (largo 0.86)
- Puntas (cabeza) en x≈-0.34
- Pomo en x≈+0.43

Tras rotar -90° en Y sobre el origen del mundo, la cabeza quedaría en +Z (abajo) y el pomo en -Z (arriba). Eso fue lo que pasó en el primer intento y se vio en la captura — pico_hierro parado PERO CON LA CABEZA ABA APOYADA EN LA ARENA. Invertido como un paraguas.

**Fix:** aplicar +180° en Y (no -90°). Esto voltea la herramienta 180° sobre el eje vertical: lo que estaba en -X va a +X (sigue tumbado por sí solo, no resuelve nada); pero combinado con la rotación previa o usándolo solo sobre un estado ya vertical, deja la cabeza arriba.

Decisión final: aplicar +180° al estado vertical actual (que ya viene de haber roto -90° sobre el tumbado original, ahora en estado "cabeza abajo parado"). Resultado: cabeza arriba, pomo abajo.

Verificación con diag en vivo (`C:/Users/Maury-New/AppData/Local/Temp/rotar_pico_hierro3.py`):

```
ANTES dimX=0.171 dimY=0.736 dimZ=0.893 z_min=-0.430
  SM_PicoHierro_BloqueCabeza   cx=+0.000 cz=-0.340  ← cabeza ABAJO
  SM_PicoHierro_Punta_A/B      cx=+0.000 cz=-0.340  ← cabeza ABAJO
  SM_PicoHierro_Pomo           cx=+0.000 cz=+0.430  ← pomo ARRIBA
DESPUES dimX=0.171 dimY=0.736 dimZ=0.893 z_min=-0.463
  SM_PicoHierro_BloqueCabeza   cx=-0.000 cz=+0.340  ← cabeza ARRIBA ✓
  SM_PicoHierro_Punta_A/B      cx=-0.000 cz=+0.340  ← cabeza ARRIBA ✓
  SM_PicoHierro_Pomo           cx=+0.000 cz=-0.430  ← pomo ABAJO ✓
```

Después regenerar las 4 variantes (`_media`, `_baja`, `_alta`, `_alta_media`); todas con `z_min = 0.045`.

## 3. `pico_piedra` y `hacha_piedra` — no había que rotar

Ambas ya estaban verticales (handle a lo largo de Z). El audit las marcó TUMBADO por un bug de su lógica. La "rotación" previa (en el log 234-235) fue un no-op — la matriz world rotada volvía a la identidad o no se guardaba correctamente.

Verificación con diag en vivo (`diag_rot.py`):
```
ANTES  dimX=0.179 dimY=0.700 dimZ=0.893 z_min=-0.463
DESPUES_BG dimX=0.893 dimY=0.700 dimZ=0.179 z_min=-0.127
DESPUES_BAKE dimX=0.893 dimY=0.700 dimZ=0.179 z_min=-0.127
RELOAD  dimX=0.893 dimY=0.700 dimZ=0.179 z_min=-0.127
```

Eso confirmó que la rotación -90° SÍ funciona (y al aplicarla deja horizontal). Pero como el source YA estaba vertical, la rotación lo tumbaba. Se aplicó +90° (des-rotar) y se confirmó el regreso a vertical con reload.

Estado final de los 3 sources:

| Asset | dimX | dimY | dimZ | z_min | Pose |
|---|---|---|---|---|---|
| `pico_hierro_lowpoly` | 0.171 | 0.736 | 0.893 | -0.463 | vertical ✓ |
| `pico_piedra_lowpoly` | 0.179 | 0.700 | 0.893 | -0.463 | vertical ✓ |
| `hacha_piedra_lowpoly` | 0.122 | 0.390 | 0.792 | -0.667 | vertical ✓ |

## 4. Variantes regeneradas y verificación E-13

Las 4 variantes (`_media`, `_baja`, `_alta`, `_alta_media`) regeneradas para los 3 assets, con sus mallas finales post-merge:

| Asset | _media | _baja | _alta | _alta_media |
|---|---|---|---|---|
| `pico_hierro` | 3 obj / 92 tris | 3 obj / 86 tris | 8 obj / 956 tris | 3 obj / 1920 tris |
| `pico_piedra` | 3 obj / 82 tris | 3 obj / 77 tris | 7 obj / 716 tris | 3 obj / 1440 tris |
| `hacha_piedra` | 3 obj / 278 tris | 3 obj / 229 tris | 6 obj / 1228 tris | 3 obj / 2448 tris |

**Capturas orbitales (6 cada una) en `tools/mcp/blender-mcp/{13-Herramientas,16-Crafting}/capturas/`:**
- `pico_hierro_{baja,media,alta_media}_15-19-05_az{000,060,…,300}.png`
- `pico_piedra_{baja,media,alta_media}_15-XX-XX_az{000,…}.png`
- `hacha_piedra_{baja,media,alta_media}_15-XX-XX_az{000,…}.png`

Aprobación E-13: las 3 herramientas en sus 4 variantes:
- Verticales ✓
- Cabeza (piedra/hierro) arriba ✓
- Pomo abajo ✓
- En contacto con la arena, sin flotación (`z_min = 0.045`) ✓
- Sin gaps ni piezas desconectadas

Pequeño defecto de modelado heredado del source (no resuelto aquí):
- `hacha_piedra`: la cabeza (cuchilla) está desplazada lateralmente respecto al eje del mango. Estéticamente no es ideal, pero el asset está apoyado y la rotación no lo empeora.

## 5. Bug E-26 — `capturar_angulos.py` renderizaba el archivo equivocado

**Síntoma:** la captura orbital podía mostrar un asset mientras Blender tenía OTRO `.blend` cargado, y la auditoría E-13 daba un falso positivo (veredicto "vertical y apoyado" sobre el asset equivocado).

**Causa:** el script aceptaba un argumento de prefijo y de ruta de salida pero NO abría el archivo del asset a auditar. Renderizaba la escena activa.

**Fix aplicado** (en `tools/mcp/blender-mcp/scripts-reutilizables/capturar_angulos.py`):

1. **Nuevo flag `--blend RUTA`**, opcional pero muy recomendado. Abre ese `.blend` antes de cualquier medición.
2. **Trazas de auditoría obligatorias** dentro del script: siempre imprime `ARCHIVO_ABIERTO:` (qué .blend está cargado) y `OBJETOS_ENCUADRADOS: N (prefijo 'X')` con los nombres de los primeros 12 objetos. Si la línea no corresponde al asset esperado, las capturas son inútiles y el veredicto debe rechazarse.
3. Documentación actualizada: nuevo docstring explica E-26 con un caso real.

Uso actual obligatorio:
```bash
python capturar_angulos.py SM_ ../capturas/<asset>_media_HH-MM-SS.png 6 \
  --blend ../<modulo>/<asset>_lowpoly_media.blend
```

## 6. Auditoría final de los 17 héroes (`*_alta_media.blend`)

| Héroe | obj | dimX | dimY | dimZ | z_min | tris | mats |
|---|---|---|---|---|---|---|---|
| `pico_hierro` | 3 | 0.17 | 0.74 | 0.89 | 0.045 | 1920 | 3 |
| `pico_piedra` | 3 | 0.18 | 0.70 | 0.89 | 0.045 | 1440 | 3 |
| `antorcha_mano` | 4 | 0.44 | 0.11 | 0.82 | 0.045 | 1108 | 4 |
| `cristal_ancestral` | 4 | 0.73 | 0.84 | 0.62 | 0.045 | 1319 | 4 |
| `hacha_piedra` | 3 | 0.12 | 0.39 | 0.78 | 0.045 | 2448 | 3 |
| `lingote_metal` | 2 | 0.35 | 0.13 | 0.06 | 0.045 | 1332 | 2 |
| `cofre_ancestral` | 6 | 0.77 | 0.50 | 0.63 | 0.045 | 11510 | 6 |
| `altar_ritual` | 4 | 1.20 | 1.04 | 0.69 | 0.045 | 2320 | 4 |
| `puerta_templo` | 3 | 1.80 | 0.18 | 2.88 | 0.045 | 2820 | 3 |
| `bote_pesca` | 4 | 1.33 | 0.44 | 0.60 | 0.045 | 2512 | 4 |
| `farola_fuego` | 5 | 0.40 | 0.67 | 1.60 | 0.045 | 2410 | 5 |
| `muelle_madera` | 3 | 1.96 | 1.50 | 1.42 | 0.045 | 3836 | 3 |
| `monolito_glifos` | 2 | 0.91 | 0.35 | 1.86 | 0.045 | 4656 | 2 |
| `totem_isla` | 4 | 1.11 | 1.47 | 2.20 | 0.045 | 21014 | 4 |
| `anillo_piedras_ritual` | 5 | 2.84 | 3.01 | 0.62 | 0.045 | 1242 | 5 |
| `concha_mar` | 2 | 0.43 | 0.30 | 0.28 | 0.045 | 2232 | 2 |
| `palanca_madera` | 3 | 0.40 | 1.50 | 0.38 | 0.045 | 1128 | 3 |

**17/17 con `z_min = 0.045`**. Las 2 excepciones reales al budget siguen siendo `totem_isla` (21.014 tris, hito visual) y `cofre_ancestral` (11.510 tris, geometría compleja justificada).

## 7. Cambios al sistema

- **`tools/mcp/blender-mcp/scripts-reutilizables/capturar_angulos.py`** — fix E-26 (--blend + trazas obligatorias)
- **`DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/03-Diseno.md`** — nueva línea en la verificación visual E-13 documentando la corrección de pose de los 3 hand tools y el veredicto por variante
- **`Logs/ULTIMO_NUMERO.txt`** — `236` → `237`

## 8. Pendientes para próximos logs

- **Re-derivar `_media`/`_baja` desde `_alta`** para los 17 héroes (R9 — ALTA es source of truth). Hoy todavía descienden del source lowpoly.
- **Limpiar scripts temporales** en `C:/Users/Maury-New/AppData/Local/Temp/` (~25 archivos `*.py` de este segmento).
- **Re-validar `diagnosticar_pose.py`** — el criterio de TUMBADO estaba mal para `pico_piedra` y `hacha_piedra`. La métrica actual es correcta pero la clasificación debería usar `z_max / max(dim)` o comparar contra el eje que tiene el mango en posición vertical conocida.
- **Decidir si se repara el offset lateral de la cabeza de `hacha_piedra`** (defecto de modelado del source, no de la pasada ALTA).
- **Crear carpetas Godot `res://assets/props/{asset}/{perfil}/`** (D8 — bloqueado desde log 234).
- **Declarar `variantes_disponibles` en M159** `ItemData` (D9 — bloqueado desde log 234).
- **Visual verification de los 6 fuentes con AABB < 0.045** (palmera ya hecho; restan: `roca_pedernal`, `arbusto_redondo`, `hongo_luminoso`, `flor_isla`, `veta_cobre`).
- **Reducir `nido_cocos_baja` (970 tris) y `helecho_gigante_baja` (936 tris)** bajo el budget BAJA de 700.
- **Investigar `piedra_afilar`** — 15 tris en todas las variantes, podría ser mesh degenerado.

---

**Próximo paso natural:** cualquiera de los pendientes. El más aislado es la limpieza de scripts temporales (5 min). El más impactante es la regeneración desde ALTA (R9) — afectaría a los 17 héroes en sus 4 variantes.