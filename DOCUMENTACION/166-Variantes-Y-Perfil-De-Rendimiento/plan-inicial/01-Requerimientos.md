# 01 — Requerimientos · M166 Variantes de Assets por Perfil de Rendimiento

**Módulo:** 166 · **Estado:** plan-inicial · **Fecha:** 2026-08-28
**Agente:** MiniMax-M3 · WorkBuddy AI · Windows
**Origen:** directiva del usuario 2026-08-28 — *"podriamos crear 2 versiones de cada objeto, la liviana y la detallada? entonces por si en un futuro alguien tiene pocos recursos puede cargar estos objetos livianos y si tiene mas recursos objetos mas pesados"*

---

## 1. Problema

El proyecto tiene **117 assets 3D planificados** (`CHECKLIST-OBJETOS-BLENDER.md`), de los cuales **40 ya están modelados**. Ninguno tiene una declaración de coste, ni existe un criterio para decidir qué se carga en una máquina modesta frente a una potente.

Medición real del **cofre ancestral v2.2** (el asset más detallado hasta ahora, tomado como caso de referencia):

| Métrica | Valor medido |
|---|---|
| Objetos `SM_*` (= draw calls) | **33** |
| Triángulos | **784** |
| Vértices | 841 |
| Materiales | 6 (de 9 en escena) |

**El desequilibrio es el hallazgo central:** 33 draw calls para 784 triángulos. El cofre es visualmente rico pero estructuralmente carísimo, y el coste **no está donde uno esperaría**.

Si una escena tiene 50 cofres (un almacén, una tienda, un templo con recompensas): **1.650 draw calls solo de cofres**, antes de contar terreno, NPCs, vegetación y UI. En una GPU integrada o en Steam Deck eso es inasumible; en una GPU dedicada es irrelevante. **El mismo contenido no puede servirse igual a los dos.**

## 2. Objetivos

| # | Objetivo | Criterio de éxito |
|---|---|---|
| O1 | Todo asset declara su coste medible | `stats_asset.py` corre sobre cada asset y el número queda en su documentación |
| O2 | Tres variantes por asset: ALTA / MEDIA / BAJA | MEDIA y BAJA se derivan del asset actual con un script; ALTA es la pasada artística futura |
| O3 | **Diferencia VISIBLE entre perfiles** | ALTA tiene ≥ 3× los triángulos de MEDIA. Si no se ve la diferencia, el perfil no sirve |
| O4 | **Cero trabajo artístico desperdiciado** | Los lowpoly actuales (40 assets ya aprobados) se reutilizan tal cual como MEDIA/BAJA. La ALTA es trabajo nuevo planificado, no una copia |
| O5 | Presupuesto por perfil verificable | `stats_asset.py` imprime OK/NO contra la tabla de presupuestos |
| O6 | Selección automática en runtime | Godot elige la carpeta según el perfil detectado, con override manual |
| O7 | Draw calls optimizados en las 3 variantes | El merge por material se aplica a TODAS, incluida ALTA (una ALTA de 80 piezas sin mergear sería peor que la actual) |

### 2.1 Reencuadre (2026-08-28 21:20) — corrección del eje del módulo

**Directiva del usuario:** *"mi idea era usar como Baja o media las que tenemos, y en alta porque vamos a hacer una pasada de nuevo agregando detalles"*

La primera versión de M166 puso el eje en los **draw calls** (merge por material): ALTA 33 obj, MEDIA 15 obj, BAJA 14 obj — todos con ~784 triángulos. Resultado: **las tres variantes eran visualmente idénticas.** El usuario lo detectó de inmediato: *"prácticamente no veo diferencia entre los objetos"*.

El diagnóstico es correcto y el módulo estaba mal encuadrado:

- El merge por material **no es una variante, es una optimización de exportación**. No cambia la imagen: cambia cuántas llamadas de dibujado hace el motor. Eso se mide en FPS, no se ve.
- Una "variante" tiene que diferir en **nivel de detalle**: triángulos, suavidad de curvas, biselados, cantidad de piezas pequeñas. Eso sí se ve.

**Nuevo encuadre:**

| Perfil | Qué es | Origen | Cuándo existe |
|---|---|---|---|
| **ALTA** | Pasada artística con más detalle: subdivisiones, biselados, remaches individuales, curvas suaves | Modelado nuevo (trabajo planificado) | Futuro |
| **MEDIA** | El asset lowpoly actual | Ya existe, se reutiliza | Hoy |
| **BAJA** | El asset actual + merge + decimate + poda de detalles | Derivado de MEDIA | Hoy |

El merge por material se aplica a **las tres** como etapa de exportación, no como definidor de variante.

**Por qué esto no duplica trabajo:** la ALTA no es una copia de la actual — es la mejora artística que el proyecto ya planea hacer. Y la actual, en lugar de descartarse al ser reemplazada, se conserva como versión liviana. El arte ya pagado se aprovecha.

## 3. No-objetivos (fuera de alcance de M166)

- **Terreno voxel.** El coste del terreno (M08/M09/M10, ya completados) es de un orden de magnitud superior al de cualquier prop y se resuelve con `VoxelViewer.view_distance` y LOD del propio Voxel Tools. M166 no lo toca.
- **Vegetación repetida en masa.** Hierba alta, árboles y cañas se resuelven con `MultiMeshInstance3D`, no con variantes por asset. M166 documenta la regla pero la implementación vive en M50/M09.
- **Texturas.** El estilo vigente es **color plano sin texturas** (`09-GUIA-BLENDER.md` §7.3 regla 4). M166 no introduce atlases ni PBR. Si algún día se migrara a texturas, el presupuesto de memoria tendría que revisarse.
- **Audio, UI, partículas.** Fuera de alcance.

## 4. Restricciones

| # | Restricción | Motivo |
|---|---|---|
| R1 | Estilo lowpoly flat se mantiene en MEDIA y BAJA | Decisión de diseño vigente (§7.3 regla 4), no una carencia. La ALTA puede biselar y subdividir, pero sin salirse del estilo |
| R2 | **Nada de modelado a mano duplicado** | MEDIA y BAJA se derivan por script. La ALTA es modelado nuevo, no una segunda copia del mismo modelo |
| R3 | El set de captura (`Base_Arena`, `SOL`, `Mundo`, `CAM_*`) nunca se exporta | §7 de `09-GUIA-BLENDER.md` |
| R4 | Godot 4.7.2, GDScript | M04/M05 ya cerrados |
| R5 | Las variantes derivadas no se versionan a mano | Se regeneran con un comando; el `.gitignore` las excluye |
| R6 | Nomenclatura `SM_*` / `MAT_*` intacta | Todo el pipeline y `CHECKLIST-OBJETOS-BLENDER.md` dependen de ella |
| R7 | **ALTA y MEDIA comparten silueta, paleta y punto de apoyo** | Si difieren en silueta o en `z_min`, no son variantes del mismo asset: son assets distintos. La ALTA solo añade detalle, no cambia la forma |
| R8 | **El merge por material se aplica a las 3 variantes** | Sin mergear, una ALTA de 80 piezas daría 80 draw calls: peor que el asset actual |
| R9 | **El merge es obligatorio al aprobar un asset; el source nunca se exporta** | El `.blend` source (N objetos, editable) es el archivo de autoría. Solo `_media.blend` / `_baja.blend` llegan a Godot. Verificable con `auditar_optimizacion.py` (exit 1 si falta). Directiva del usuario 2026-08-28: *"si lo optimizamos no vamos a dejar los objetos sin optimizar"* |
| R10 | **No todos los assets reciben variante ALTA (D9)** | La pasada ALTA es trabajo artístico manual y solo se aplica a los 15 assets "héroe" (se interactúa, se sostiene en mano o es un hito). Los 23 de relleno —vegetación instanciada y decoración de fondo— quedan en MEDIA de forma permanente y se declaran con `variantes_disponibles = ["media", "baja"]`. Directiva del usuario 2026-08-28: *"si se te ocurre otra idea me decis"* |

## 5. Usuarios afectados y casos de uso

| Caso | Quién | Qué necesita |
|---|---|---|
| Jugador con GPU integrada / Steam Deck / portátil viejo | Final | Que el juego arranque y mantenga 30-60 fps |
| Jugador con GPU dedicada | Final | Que se vean los detalles por los que el arte se trabajó |
| Desarrollador añadiendo un asset | Equipo | No preocuparse por el rendimiento: el pipeline genera las variantes |
| QA | Equipo | Un número objetivo contra el cual decir "este asset se pasó" |

## 6. Criterios de aceptación del módulo

1. `stats_asset.py` existe, corre y da veredicto OK/NO por perfil.
2. `generar_variante.py` existe y produce MEDIA y BAJA desde un `.blend` sin modelado adicional.
3. Al menos **1 asset piloto** (cofre ancestral) tiene sus variantes MEDIA y BAJA generadas y verificadas.
4. La tabla de presupuestos está escrita y justificada con mediciones, no con intuición.
5. El layout de carpetas y la nomenclatura están definidos y documentados.
6. El checklist `05-Checklist.md` tiene ≥ 100 ítems verificables (regla de `AGENTS.md`).
7. **La tabla de presupuestos deja un salto VISIBLE entre perfiles**: ALTA ≥ 3× los triángulos de MEDIA. Si las tres variantes se ven igual, el módulo no cumple su propósito.
8. **La receta de la pasada ALTA está escrita**: qué se le agrega a un asset para promoverlo de MEDIA a ALTA (§3 de `03-Diseno.md`).
