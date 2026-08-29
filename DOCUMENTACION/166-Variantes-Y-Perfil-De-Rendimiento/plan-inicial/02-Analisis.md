# 02 — Análisis · M166 Variantes de Assets por Perfil de Rendimiento

**Módulo:** 166 · **Estado:** plan-inicial · **Fecha:** 2026-08-28
**Agente:** MiniMax-M3 · WorkBuddy AI

---

## 1. La medición que define el módulo

Cofre ancestral v2.2, medido con `stats_asset.py` sobre la escena real de Blender:

```
Objetos / draw calls : 33
Triangulos           : 784
Vertices             : 841
Materiales usados    : 6
```

Desglose por objeto (los 6 más caros):

| Objeto | Tris | Nota |
|---|---|---|
| `SM_Cofre_Tapa` | 152 | medio cilindro, 10×13 |
| `SM_Cofre_Remaches` | 132 | 22 remaches en 1 malla |
| `SM_Cofre_Gema` | 80 | icoesfera subdiv 2 |
| `SM_Cofre_Costilla_1/2/3` | 48 c/u | 3 toroides |
| `SM_Cofre_Asa_I/D` | 40 c/u | toroides |
| `SM_Cofre_Tirador` | 32 | toroide |
| Los 25 restantes | 6 c/u | cajas de 6 caras |

## 2. Hallazgo: los triángulos no son el problema

**784 triángulos es nada.** Como referencia:

| Referencia | Triángulos |
|---|---|
| Cofre ancestral (este proyecto) | 784 |
| Un personaje de Animal Crossing | ~5.000 |
| Un arma de un shooter AAA | ~20.000 |
| Un personaje de un AAA moderno | 50.000 – 150.000 |
| Presupuesto típico de frame en Switch | ~500.000 |

Reducir el cofre de 784 a 400 triángulos **no se mide**. Ni en una GPU integrada. El vertex shader procesa 400 triángulos en microsegundos. **Si la variante "liviana" se definiera como "menos triángulos", el módulo entero sería inútil.**

## 3. Hallazgo: los draw calls sí son el problema

Cada objeto `SM_*` es, al importarse en Godot, un `MeshInstance3D` que genera **un draw call por material**. 33 objetos = **33 draw calls por cofre**.

Coste de un draw call: cambio de estado, bind de shader, bind de buffers, validación. Es coste de **CPU**, no de GPU, y **no se paraleliza**. El hilo de render se satura mucho antes que la GPU.

| Escena | Cofres | Draw calls solo de cofres |
|---|---|---|
| Una habitación con 3 cofres | 3 | 99 |
| Un almacén | 20 | 660 |
| Un templo con sala de recompensas | 50 | 1.650 |

En Godot 4 el hilo de render empieza a sufrir seriamente pasados **~1.000–2.000 draw calls** en hardware modesto. Un solo tipo de prop puede comerse todo el presupuesto.

**Conclusión: el eje de optimización correcto es la CANTIDAD DE MALLAS, no la cantidad de triángulos.**

## 4. Segundo hallazgo: los materiales son el multiplicador

6 materiales × 33 objetos. Cada material es un `Principled BSDF` completo: en Godot eso son uniforms, bindings y potencialmente un cambio de programa. Si dos objetos comparten material pueden (a veces) agruparse; si no, no.

Reducir materiales de 6 a 4 reduce tanto draw calls como cambios de estado.

## 5. La distinción que faltaba: **merge ≠ variante**

**Este es el error de la primera versión del módulo.** Se trató el merge por material como si definiera una variante, y no es así:

| | Qué cambia | Se ve | Se mide |
|---|---|---|---|
| **Merge por material** | Cuántas llamadas de dibujado hace el motor | ❌ No | ✅ FPS |
| **Nivel de detalle** | Triángulos, suavidad, biselados, piezas pequeñas | ✅ Sí | ✅ Triángulos |

El merge agrupa piezas que comparten material para dibujarlas de una sola vez. **La imagen resultante es idéntica.** Por eso las tres variantes de la primera versión (33 / 15 / 14 objetos, todas con ~784 tris) se veían iguales: estábamos variando la columna equivocada.

**Corrección:** el merge es una **etapa de exportación** que se aplica a las tres variantes. La variante la define el **nivel de detalle del modelado**.

## 6. Alternativas evaluadas

| # | Alternativa | Veredicto |
|---|---|---|
| A | **Dos versiones modeladas a mano** (propuesta original del usuario) | ✅ **Válida con matices.** Si la ALTA es trabajo artístico nuevo planificado (una pasada de mejora), no hay desperdicio: el arte actual se conserva como versión liviana en lugar de descartarse. **Peligro:** las dos versiones divergen si se editan por separado. Mitigado por R7 (comparten silueta, paleta y `z_min`). |
| B | **Decimate automático** (reducir triángulos) | ⚠️ **Insuficiente solo.** En un asset de 784 tris es imperceptible (−13 %). Útil para BAJA, nunca como eje principal. |
| C | **Merge por material** | ✅ **Elegida, pero como optimización de exportación, no como variante.** Baja draw calls un 55-82 % sin tocar la imagen. Se aplica a las 3 variantes. |
| D | **LOD por distancia** | ⚠️ **Complementario.** Ayuda con triángulos de lejos, no con draw calls. |
| E | **MultiMesh** para props repetidos | ✅ **Complementario, obligatorio para vegetación.** Miles de instancias en 1 draw call. |
| F | **Impostores / billboards** | ❌ Descartado. Rompe el estilo. |

### 6.1 Por qué A gana ahora: la prueba numérica

| Variante | Tris | Draw calls (tras merge) | Diferencia visual |
|---|---|---|---|
| **ALTA** (pasada artística) | ~4.000 | ~12 | **Referencia** |
| **MEDIA** (asset actual) | 784 | ~6 | Menos suavidad, sin biselados |
| **BAJA** (actual + decimate + poda) | 681 | ~6 | Ídem + sin remaches/glifos |

**ALTA tiene ~5× los triángulos de MEDIA.** Eso sí se ve: curvas suaves en lugar de facetas, aristas biseladas en lugar de filos vivos, remaches redondos en lugar de cajas.

## 7. Decisión: tres variantes, dos fuentes de arte

```
   ┌──────────────────────────┐        ┌──────────────────────────┐
   │ ALTA  (pasada artística) │        │ MEDIA (asset actual)     │
   │ modelado nuevo, futuro   │        │ lowpoly ya aprobado      │
   │ ~80 obj / ~4.000 tris    │        │ 33 obj / 784 tris        │
   └────────────┬─────────────┘        └────────────┬─────────────┘
                │ merge por material                │ merge
                ▼                                   ├──────────────┐
      ┌───────────────────┐                         ▼              ▼
      │ ALTA exportada    │              ┌──────────────┐  ┌──────────────┐
      │ ~12 obj / 4k tris │              │ MEDIA        │  │ BAJA         │
      │ perfil Alto       │              │ 6 obj/784 tr │  │ 6 obj/681 tr │
      └───────────────────┘              │ (default)    │  │ + decimate   │
                                         └──────────────┘  └──────────────┘
```

- **ALTA** — la pasada artística futura. Más subdivisiones, biselados, remaches individuales, detalles modelados. Perfil "Alto".
- **MEDIA** — el asset actual tal cual. **Default** para todos los perfiles salvo "Alto" y "Bajo".
- **BAJA** — el asset actual + merge + decimate + poda. Perfil "Bajo".

**Regla de convivencia (R7):** ALTA y MEDIA comparten silueta, paleta de materiales y `z_min`. La ALTA añade detalle; no rediseña. Si la silueta cambia, no es una variante: es otro asset.

## 8. Tabla de presupuestos por perfil

Presupuesto **por asset**, no por escena (el presupuesto de escena es trabajo de M61/M138).

| Perfil | Objetos (tras merge) | Triángulos | Materiales | Público objetivo |
|---|---|---|---|---|
| **ALTA** | ≤ 16 | **≤ 6.000** | ≤ 12 | GPU dedicada, desktop |
| **MEDIA** | ≤ 8 | ≤ 1.500 | ≤ 8 | **Default.** Steam Deck, laptops, GPU integrada moderna |
| **BAJA** | ≤ 6 | ≤ 700 | ≤ 4 | GPU integrada vieja, gama muy baja |

**Regla de oro:** el presupuesto de **triángulos** es el que define la variante; el de **objetos** es el que define la viabilidad. Los dos se deben cumplir.

### 8.1 Justificación de los números

- **≤ 6.000 tris (ALTA):** ~7,6× el cofre actual (784). Suficiente para subdivisiones, biselados y remaches individuales sin llegar a números de AAA. Un personaje de Animal Crossing ronda los 5.000, así que un prop muy detallado en 6.000 es coherente con el estilo.
- **≤ 1.500 tris (MEDIA):** holgura sobre los 784 actuales. Deja margen para assets futuros más ambiciosos sin renegociar el presupuesto.
- **≤ 700 tris (BAJA):** ~50 % de MEDIA, coherente con decimate a ratio 0.7 + poda.
- **Salto ALTA/MEDIA de 4×:** es el mínimo para que la diferencia sea perceptible a la distancia de juego. Por debajo de 3× el jugador no nota el cambio y el perfil no se justifica.

## 9. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| **ALTA y MEDIA divergen** (se edita una y no la otra) | **Alta** | **Alto** | **R7:** comparten silueta, paleta y `z_min`. La ALTA añade detalle, no rediseña. Si cambia la silueta, se regeneran MEDIA y BAJA desde cero. Revisión visual comparativa obligatoria (capturas lado a lado). |
| **La ALTA nunca se hace** (queda como deuda pendiente) | Media | Medio | La ALTA es trabajo planificado, no bloqueante: MEDIA y BAJA funcionan desde el día 1. Cada asset decide cuándo recibe su pasada. |
| El merge por material rompe animaciones futuras (cajón que se abre) | Media | Alto | **Los objetos que se animan NO se fusionan.** Se marcan con sufijo `_NOFUNDIR` y quedan fuera del merge. |
| El decimate produce artefactos en piezas finas | Media | Medio | Decimate solo sobre la variante BAJA, ratio 0.7 (no 0.5, ver E-23). Revisión visual obligatoria de las 6 capturas orbitales (E-13). |
| Las variantes derivadas quedan desincronizadas | Alta si se versionan | Medio | **No se versionan.** Se regeneran con un comando. El `.gitignore` las excluye. |
| El merge cambia el centro del objeto y rompe el asentado | Media | Alto | El merge se aplica con `bmesh` en coordenadas de mundo y el objeto resultante queda en `location=(0,0,0)`. El `z_min` se re-verifica después (E-12). |
| Sobre-optimización prematura | Alta | Bajo | El presupuesto se mide, no se adivina. Si un asset cumple MEDIA sin merge, no se le genera variante. |
| La ALTA se pasa de draw calls ( muchas piezas pequeñas) | Media | Medio | **R8:** el merge por material se aplica también a la ALTA. 80 piezas → ~12 draw calls. |

## 10. Dependencias

| Módulo | Relación |
|---|---|
| M108 Pipeline de Assets | M166 es una etapa más del pipeline; M108 define el flujo general |
| M45 Arte 3D | Productor de los assets a los que se aplica |
| M159 Catálogo de Objetos | Consumidor: cada `ItemData` referencia las 3 variantes |
| M61 Rendimiento / M138 Vertical Slice | Consumidores del presupuesto de escena |
| M154 Visión del Agente | Las capturas de QA se hacen sobre ALTA |
| M109 Herramientas Internas | Dónde vive el script de generación |
