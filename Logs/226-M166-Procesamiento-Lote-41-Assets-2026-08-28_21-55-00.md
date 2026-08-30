# Log 226 — M166 · Procesamiento en lote de los 41 assets (MEDIA + BAJA)

**Fecha:** 2026-08-28 21:55 ART · **Módulo:** 166 · **Agente:** MiniMax-M3

## Resumen

Se cerró la deuda de optimización de todo el catálogo 3D: los **41 assets source** del proyecto
ya tienen su versión **MEDIA** (merge por material, sin pérdida de geometría) y su versión
**BAJA** (poda + merge + decimate 0.7). Antes de este log había **1 optimizado de 41**; ahora
hay **41 de 41** y la auditoría devuelve código de salida 0.

Resultado del lote:

```
--- RESULTADO ---
Exitosos : 40
Fallidos : 0
Tiempo   : 168.0 s
```

(El asset 41, `cofre_ancestral_lowpoly`, ya estaba optimizado por ser el piloto del módulo;
el lote es idempotente y lo saltea.)

## Directiva del usuario que originó este trabajo

> "bueno ahora te pido que crees las 2 versiones de cada objeto. se me ocurre separarlos en
> carpetas las versiones baja calidad que son las que hicimos, y las de alta calidad que
> tienen mas detalles. las que tienen mas detalles vas a tener que mejorar las que ya
> tenemos. si se te ocurre otra idea me decis"

Tres partes:

1. **Crear las 2 versiones de cada objeto** → HECHO (40 nuevos + el piloto = 41).
2. **Separarlas en carpetas** → adoptado con una modificación (ver D8 más abajo).
3. **Mejorar las existentes para la versión de alta calidad** → PENDIENTE, es trabajo artístico
   manual recetado en `03-Diseno.md §3.3`.

## Scripts nuevos

### `auditar_optimizacion.py`

Responde a la inquietud del usuario "no vamos a dejar los objetos sin optimizar solo para que
ocupen recursos". Escanea el sistema de archivos (no necesita Blender) y reporta, por módulo y
asset, si existe la versión mergeada.

- `python auditar_optimizacion.py` → tabla completa + resumen.
- `python auditar_optimizacion.py --falta` → solo los pendientes.
- **Código de salida 1 si falta algún merge**, 0 si está todo bien. Pensado para CI.
- Expone `recolectar()` → lista de dicts `{'modulo', 'base', 'media', 'baja'}`.

Regla de detección de "source":

```python
SUFIJOS_VARIANTE = ('_media', '_baja', '_alta')

def es_source(nombre):
    if not nombre.endswith('.blend'):
        return False
    base = nombre[:-len('.blend')]
    return not any(base.endswith(s) for s in SUFIJOS_VARIANTE)
```

### `procesar_lote.py`

En lugar de invocar `generar_variante.py` 80 veces a mano. Reutiliza `recolectar()` (de la
auditoría) y `generar()` (del generador):

```python
from auditar_optimizacion import recolectar
from generar_variante import generar
```

Uso:

```bash
python procesar_lote.py                       # todos los módulos, --media --baja
python procesar_lote.py 50-Vegetacion         # un módulo
python procesar_lote.py 15-Recursos --media   # solo MEDIA
```

Es **idempotente**: saltea los assets que ya tienen `_media`. Se puede relanzar sin miedo.

## Ajuste importante: `CRITICAS_NO_FUNDIR` ahora vacío por defecto

En el piloto del cofre se excluyeron del merge las piezas finas (costillas, cerradura, gema,
falleba, asas, tirador) por miedo a que el decimate las destruyera. Al medirlo:

| Configuración | Objetos (draw calls) | Triángulos | ¿Cumple presupuesto BAJA (≤6)? |
|---|---|---|---|
| Con críticas excluidas | 14 | 681 | ❌ NO |
| `CRITICAS_NO_FUNDIR = ()` | 6 | 571 | ✅ SÍ |

Conclusión: **el merge por material no pierde geometría**, y con ratio 0.7 (E-23) las piezas
finas sobreviven intactas. Excluirlas costaba 8 draw calls a cambio de nada. Quedó así:

```python
CRITICAS_NO_FUNDIR = ()      # override opt-in por asset, no la regla
```

El usuario verificó visualmente las 6 capturas orbitales de la BAJA del cofre: cerradura, gema,
costillas, anillo y vetas siguen ahí.

## Correcciones automáticas de altura (E-12 aplicadas por el lote)

El re-asentado a `z_min = 0.045` destapó varios assets que estaban hundidos o flotando en el
source y nunca se habían medido:

| Asset | z_min original | z_min corregido | Delta |
|---|---|---|---|
| `palanca_madera_lowpoly` (70) | −0.396 | 0.045 | +0.441 |
| `palmera_lowpoly` (50) | −0.300 | 0.045 | +0.345 |
| `hongo_luminoso_lowpoly` (50) | −0.064 | 0.045 | +0.109 |

Esto confirma la regla que el usuario pidió documentar en la guía: **siempre hay que corregir
las alturas; ningún objeto debe flotar ni hundirse en la base**.

## Reducción de draw calls obtenida

Muestras representativas del lote:

| Asset | Objetos source | Objetos MEDIA | Objetos BAJA |
|---|---|---|---|
| `palmera_lowpoly` | 13 | 5 | 5 |
| `palmera_inclinada_lowpoly` | 11 | 4 | 4 |
| `liana_colgante_lowpoly` | 19 | 4 | 4 |
| `palmera_joven_lowpoly` | 8 | 3 | 3 |
| `palanca_madera_lowpoly` | 5 | 3 | 3 |
| `hongo_luminoso_lowpoly` | 9 | 5 | 5 |

La vegetación era la más beneficiada (hasta 19 → 4 = −79 %), que es justo donde más instancias
hay en escena.

## Decisión D8 — respuesta alternativa a la propuesta de carpetas del usuario

El usuario propuso separar las versiones en carpetas. Se adopta **con una modificación**:

| Lugar | Estructura | Motivo |
|---|---|---|
| **Blender** | Plano, con sufijos (`_media`, `_alta`, `_baja`) | ALTA y MEDIA deben compartir silueta, paleta y `z_min` (R7). En carpetas separadas divergen: editás una y la otra queda vieja sin que nada lo delate. Juntas, el diff salta a la vista. |
| **Godot** | Carpetas `alta/` `media/` `baja/` | Es donde el runtime **elige** qué cargar según el perfil. Ahí la separación sí tiene sentido operativo. |

**Carpetas donde se consume, sufijos donde se edita.**

## Restricción R9 — cuándo se optimiza

Respuesta a "¿creamos los objetos optimizados de una vez, o un módulo para optimizarlos al
aprobarlos?":

> **Se optimiza al aprobar.** El `.blend` source (N objetos separados) es el archivo de
> **autoría** — el equivalente a un `.psd` — y **nunca se exporta a Godot**. Solo llegan
> `_media.blend` y `_baja.blend`.

Tres razones para NO meter el merge dentro del script de creación:

1. **Se pierde la editabilidad justo cuando más se itera.** Durante el modelado se ajustan
   piezas individuales; un mergeado no se puede editar cómodamente.
2. **Mejorar el algoritmo tocaría 117 archivos en vez de 1.** Se comprobó con el fix de E-23
   (ratio 0.5 → 0.7): un solo cambio en `generar_variante.py` + relanzar el lote (168 s).
3. **El merge es idempotente y barato.** Cuesta 168 s regenerar los 41 assets; sale más barato
   eso que mantener 117 scripts con la optimización incrustada.

El `auditar_optimizacion.py` con exit code 1 es el candado: si un asset llega aprobado sin
mergear, el CI lo marca.

## Decisión D9 — no todos los assets necesitan pasada ALTA

El usuario pidió "mejorar las que ya tenemos" para la versión de alta calidad. **La otra idea: no hace
falta mejorar las 41.**

**Argumento numérico.** La vegetación se instancia con MultiMesh, así que el coste de una ALTA se
multiplica por la cantidad de instancias:

| Asset | Tris MEDIA | Tris ALTA | × 300 instancias |
|---|---|---|---|
| `palmera_lowpoly` | ~700 | ~4.000 | 210.000 → **1.200.000** |
| `hierba_alta_lowpoly` | ~300 | ~2.000 | 90.000 → **600.000** |

A la distancia de cámara de un juego cozy, 4.000 triángulos en una palmera se ven igual que 700.
El detalle no se percibe; el coste sí.

**Clasificación de los 41:**

- **15 héroes → reciben ALTA.** Criterio: se interactúa con el objeto, se sostiene en mano, o es un
  hito visual de la isla.
  `pico_hierro`, `pico_piedra`, `antorcha_mano`, `cristal_ancestral`, `hacha_piedra`,
  `lingote_metal`, `cofre_ancestral`, `altar_ritual`, `puerta_templo`, `bote_pesca`,
  `farola_fuego`, `monolito_glifos`, `totem_isla`, `anillo_piedras_ritual`, `palanca_madera`.
- **3 frontera → se decide después.** `muelle_madera` (hito pero enorme), `losa_grabado` (los glifos
  piden detalle pero va en el piso), `concha_mar` (se mira de cerca pero es chica).
- **23 relleno → MEDIA permanente.** Los 12 de vegetación + `monton_ramas`, `nido_cocos`,
  `piedra_afilar`, `roca_comun`, `roca_pedernal`, `tronco_caido`, `veta_cobre`, `veta_hierro`,
  `veta_oro`, `tablon_madera`, `estrella_mar`.

**No hace falta programar nada nuevo para que esto funcione:** el campo `variantes_disponibles` de
`ItemData` (M159, diseñado desde la primera versión del módulo) ya resuelve el caso. Los de relleno
declaran `["media", "baja"]`; el runtime degrada al perfil más alto disponible.

**Y ningún asset queda sin optimizar por esto:** los 23 de relleno tienen igual su `_media` y su
`_baja` mergeadas (R9). Lo que no tienen es detalle extra, porque no lo necesitan.

## Documentación actualizada

- `09-GUIA-BLENDER.md`
  - §4 checklist: nuevos ítems "Optimización obligatoria al aprobar (M166)" y "Auditoría de
    optimización".
  - §7.4: regla 12 (R9: el source nunca se exporta) y regla 13 (por qué el merge no va en el
    script de creación).
- `166-Variantes-Y-Perfil-De-Rendimiento/plan-inicial/` — `01` (O3/O4/O7, R7/R8/R9, §2.1
  reencuadre), `02` (§5 merge ≠ variante, §8 presupuestos, §9 riesgos), `03` (§2.1 D8, §3.3
  receta de la pasada ALTA, §3.4 puerta de aprobación), `04` (reescrito con los dos ejes,
  E-22/E-23/E-20), `05` (100 ítems verificados con `grep -c "^- \["`).
- `plan-actual/` resincronizado con `plan-inicial/` (los 5 archivos).

## Pendiente

1. **QA visual de las 40 variantes BAJA nuevas** (E-13: 6 capturas orbitales por asset = 240
   imágenes). La MEDIA es lossless y por eso es de bajo riesgo; la BAJA pasa por decimate y sí
   necesita verificación antes de exportar. Actualmente bloqueado por E-10 (el modelo activo no
   puede leer imágenes), así que la verificación hecha fue numérica y geométrica.
2. **Crear las variantes ALTA de los 15 héroes** (D9, ya no 41) — trabajo artístico manual, receta
   en `03-Diseno.md §3.3` (biselados primero, después subdivisiones, detalles en relieve y remaches
   individuales; presupuesto ≤16 objetos / ≤6.000 tris / ≤12 materiales). Regla de oro: si
   `stats_asset.py` marca la ALTA como **OK en MEDIA**, la pasada no agregó suficiente detalle.
3. Crear el árbol `res://assets/props/{asset_id}/{perfil}/` en Godot — diseñado, no existe
   físicamente todavía.
4. Declarar `variantes_disponibles` en los `ItemData` de M159 según la clasificación D9.

## Receta

```bash
cd tools/mcp/blender-mcp/scripts-reutilizables

# Ver el estado antes
python auditar_optimizacion.py --falta

# Procesar todo (idempotente)
python procesar_lote.py

# Verificar
python auditar_optimizacion.py ; echo "exit=$?"
```
