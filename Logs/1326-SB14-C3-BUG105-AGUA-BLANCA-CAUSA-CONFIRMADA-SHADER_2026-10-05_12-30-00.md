# Log 1326: SB-14 (C3) — BUG-105: el agua blanca la produce el SHADER (confirmado por A/B)

**Fecha:** 2026-10-05
**Hora:** 12:30:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

## Resumen

C3 aprobado (canal 26). **Confirmé experimentally que el agua blanca la produce el shader
`agua_olas.gdshader` de M51**, y **no** el albedo/textura como suponía el encargo. No hice fix
porque **no logré confirmar la línea exacta** — y la condición 3 del director fue explícita: no
afirmar causa.

| Pregunta | Respuesta | Cómo lo sé |
|---|---|---|
| ¿Es el shader? | **SÍ, confirmado** | A/B controlado: ocultando solo `AguaAnimada`, la banda blanca pasa a **azul claro** |
| ¿Es albedo/textura? | **NO** | eloceano es `Color(0.08, 0.35, 0.62)` azul profundo medido en runtime |
| ¿Qué línea exacta? | **NO CONFIRMADA** | hipótesis acotada abajo; requiere otro ciclo de prueba |
| ¿Hice fix? | **NO** | sin causa confirmada no hay fix honesto |

## 1. Hechos medidos (runtime, no lectura de código)

Sonda headless que instancia `main_island.tscn` e imprime el estado real:

| Nodo | y | Tamaño | Material | Color medido |
|---|---:|---|---|---|
| `AguaAnimada` | **4.05** | 6200×6200 | **ShaderMaterial** (`agua_olas.gdshader`) | uniforms **todos por defecto** |
| `Oceano` | 1.20 | 4096×4096 | StandardMaterial3D | albedo **(0.08, 0.35, 0.62)** azul profundo |
| `BaseArenaBlancaIsla` | 2.95 | cilindro **r=242** | StandardMaterial3D | albedo **(0.96, 0.94, 0.88)** blanco cálido |

`MundoRaiz`: `RADIO_ISLA = 1800`, `RADIO_ORILLA = 1700`.

**Descartado por medición, no por suposición:**
- **El shader SÍ está aplicado** (a `AguaAnimada`, plano de 6200, no al `Oceano`).
- **`hint_depth_texture` funciona**: el proyecto usa el renderer por defecto (`forward_plus`;
  `project.godot` `[rendering]` solo define `rendering_device/driver.windows="d3d12"`). **Descarté
  la hipótesis «no hay depth texture».**
- **El disco de arena blanca es r=242** (radio viejo), **no** se reescaló con la ampliación ×10
  (isla 2560). **No es la causa del blanco** (ver A/B).

## 2. El A/B que sí decide

Una sola variable cambió, sin tocar código de producción:

```gdscript
# test temporal (ya BORRADO), instanciaba la escena real y:
c.visible = false   # nodo "AguaAnimada"
```

| Captura | Banda donde debería estar el agua |
|---|---|
| **ANTES** (juego normal) | **blanco** (23,0 % de la pantalla, RGB medio 228/234/241, **R−B = −14**, frío) |
| **TEST** (mismo shader oculto) | **azul claro** |

**Conclusión: el blanco lo introduce el shader.** El `Oceano` de abajo es azul; el shader de
arriba lo convierte en blanco.

**Sobre el color:** la banda observada es **fría** (R−B = −14), lo que descarta al disco de
arena (cálido, R−B ≈ +9) y apunta a `color_espuma = vec4(0.92, 0.97, 1.0, 0.85)` del shader.

**⚠️ Límite honesto de esta medición:** el A/B visual es concluyente, pero **las dos capturas no
tienen la misma cámara** (mi test la puso en `(3860, 12, 3860)` mirando a la isla; el juego usa la
cámara del jugador). Por eso **no presento la comparación de composición de píxeles como
corroboración numérica**: los porcentajes no son apples-to-apples. **Lo concluyente es la
comparación visual de la misma región.**

## 3. Hipótesis acotada (NO confirmada) — por qué el shader pinta todo de blanco

`agua_olas.gdshader`:

```glsl
float profundidad_agua = VERTEX.z - fondo_view.z;          // L53
float costa = 1.0 - smoothstep(profundidad_min, profundidad_max, profundidad_agua);  // L54
float espuma_orilla = (1.0 - smoothstep(0.0, profundidad_max * 0.22, profundidad_agua)) * vaiven;  // L68
ALBEDO = mix(ALBEDO, color_espuma.rgb, espuma * 0.85);     // L70
```

Con `profundidad_min=0.15`, `profundidad_max=2.2` y `profundidad_max*0.22 = 0.484` (defaults; el
script no setea ningún uniform).

Si `profundidad_agua` sale **≈0 en casi toda la superficie**, entonces:
- `costa = 1` → `espuma_orilla = 1.0 * vaiven` (0,6–1,0) → `espuma ≈ 1`
- → `ALBEDO = mix(albedo, blanco, 0.85)` ≈ **blanco**, y `ALPHA` → `color_espuma.a = 0.85` (opaco).

**Por qué `profundidad_agua` podría salir ≈0:** el plano está en **y=4.05** y el comentario de
`agua_animada.gd:15-17` dice que se puso «ENCIMA del top del agua **voxel** (4.0)». Si los tiles de
agua voxel (4.0) son geometría **opaca**, el `depth_texture` devuelve **la profundidad del agua
voxel justo debajo**, no el fondo del océano a y=1.20 → caída de **0,05 m** → `espuma_orilla` se
dispara en todas partes.

**Eso explicaría también por qué `profundidad_max = 2.2` (calibrado para medir hasta el fondo del
océano) nunca se alcanza: el plano no ve el fondo, ve la superficie voxel.**

**⚠️ ESTO SIGUE SIENDO HIPÓTESIS.** Para confirmarla falta un test dirigido: mover el plano a
y=6 (por encima de los tiles) y ver si el agua se pone azul, o escribir `profundidad_agua` a un
`COLOR` de debug y capturarlo. **No lo hice porque no tengo el ciclo de verificación para
sostener un fix no confirmado, y la condición 3 dice no afirmar la causa.**

**Contribución secundaria (menor):** aun con el shader fuera, el agua se ve **azul claro** y no azul
profundo. Eso es la **niebla** de `main_island.gd:222-230` (`fog_light_color = (0.75, 0.85, 0.95)`,
`fog_density = 0.00018`, `fog_aerial_perspective = 0.4`). **No lo toco**: la niebla está puesta a
propósito («adiós línea marrón del horizonte») y cambiarla es diseño, no fix.

## 4. Por qué no hice fix

Las condiciones que fijó el director:
1. ✅ Diagnóstico antes de fix — **hecho**, con A/B.
2. ✅ Captura antes → fix → después — **antes** hecha; **después** no, porque no hay fix.
3. ✅ **No afirmes la causa. Si no la encontrás, reportá lo que viste** — es lo que hago.
4. ✅ Dueño es M51/M167 — el shader es de M51, así que **estaba en scope**; no me frenó eso.

**No hice fix porque no tengo la causa confirmada.** Un fix «probemos Changing `profundidad_max` a
20 a ver qué pasa» sería cambio a ciegas sobre el agua de todo el juego, y esta vez tengo
**captura de antes** para comparar: si fuera a cambiar algo sin saber la causa, no podría ni
volver atrás con criterio.

## 5. Capturas (en `%TEMP%\kilo\`, fuera del repo)

| Archivo | Qué es |
|---|---|
| `sb14_ANTES_agua_blanca.png` (108.762 B) | línea base: juego normal, **FPS 60**, agua blanca |
| `sb14_TEST_sin_shader.png` (149.345 B) | A/B: `AguaAnimada` oculto → **azul claro** |

**No las metí al repo:** `tools/mcp/godot-mcp/capturas/` es la vía de M154 y no me la asignaron.
Decime si las querés versionadas y las copio.

## 6. Limpieza

- **Producción intacta** (verificado con `git status`): `agua_olas.gdshader`, `agua_animada.gd`,
  `main_island.gd`, `terrain_data.gd` — **sin modificar**.
- **Scripts temporales BORRADOS**: `_sonda_agua_sb14.gd`, `_test_sin_agua_sb14.gd`. No quedan en
  el repo.
- Juego cerrado (2 procesos).
- `CHECKLIST-GLOBAL.md`, `quality.yml`, `11-BUGS.md` (salvo la entrada de BUG-105) no tocados.

## 7. Mis errores en esta tarea (4)

| # | Error | Detección |
|---|---|---|
| 1 | **Mi primer muestreo de píxeles dio coordenadas inventadas** y clarinetó terreno/HUD como «agua» | los RGB salían `(144,169,94)` verde y `(92,113,60)` verde: no era la banda. Reemplacé por clasificación de toda la imagen |
| 2 | **`var e := env.environment` → Parse Error** (`:=` sobre Variant) | el propio `GUIA-GODOT/01` §28 lo documenta; **caí en la trampa que acabo de documentar** |
| 3 | **`add_child()` en `SceneTree`** → Parse Error | `SceneTree` no lo tiene; va en `get_root()` |
| 4 | Presenté la comparación de **composición de píxeles** como corroboración cuando las cámaras **no coinciden** | lo detecté al ver que el % de verde pasó de 42,7 % a 11,3 %: es otra cámara, no el shader |

**E1, E2 y E3 son la misma clase:** dati prisa con la primera versión de algo y el primer resultado
no significa nada. **E4 es la importante:** estuve a punto de dar un dato numérico que no
correspondía, y lo vi porque un número se veía raro. **Un número raro es información, no ruido.**

## 8. Recomendación

**Siguiente paso concreto para cerrar el fix** (no lo hago yo sin que lo pidas):

1. **Test dirigido (1 sola variable):** subir el plano de y=4.05 a y=6.0 en `agua_animada.gd`
   (constante `Y_SUPERFICIE`) y capturar. Si el agua se pone azul → **confirma la hipótesis** y el
   fix es esa constante (con el riesgo de que las olas se despeguen de la superficie).
2. **Alternativa más limpia:** en vez de medir profundidad de pantalla, calcular la profundidad
   **desde la distancia al centro de la isla** (ya está disponible vía `MundoRaiz`), que es
   determinista y no depende del depth buffer ni de la geometría voxel.
3. **Decisión de diseño aparte:** la niebla palidece el agua aunque el shader esté bien. Si el
   fundador quiere azul turquesa Maldivas real, hay que revisar `fog_density`/`fog_light_color`
   **con los ojos abiertos**, porque están puestos a propósito.

---

**Firma:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-05 12:30:00