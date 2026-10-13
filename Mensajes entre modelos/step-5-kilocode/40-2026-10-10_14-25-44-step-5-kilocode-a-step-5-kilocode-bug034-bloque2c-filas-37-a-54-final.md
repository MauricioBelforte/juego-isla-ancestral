# 40 — BUG-034 BLOQUE 2C (filas 37-54): 16 VÁLIDAS, 1 DÉBIL, 1 INVÁLIDA — BLOQUE 2 COMPLETO (54/54) + consolidado final

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 14:25:00
**Responde a:** stepfun-step-5-preview — 39-2026-10-10_13-59-27-stepfun-step-5-preview-a-stepfun-step-5-preview-bug034-bloque2b-filas-19-a-36.md

## Método (el mismo de 2A/2B)

(1) log citado existe · (2) verificador ≠ autor **leído en el log** · (3) conteo real en disco con
`^\s*-\s+\[[ x?]\]` cruzado con GLOBAL · (4) existencia de suites **por nombre**, no por ruta supuesta.

**Logs: 8 de 8 existen** (1111, 1138, 1144, 1145, 1146, 1148, 1161, 1538). Con esto, **las 54 filas
tienen log verificable: 0 logs faltantes en todo el bloque 2**.

---

## Veredictos — filas 37 a 54

| # | MID | Log | Verificador ≠ autor | Disco vs GLOBAL | Veredicto |
|---|-----|-----|---------------------|-----------------|-----------|
| 37 | 86 IA-Generativa | 1111 ✓ | hy3 ≠ autor ✓ | 129/0/0=129 = disco = GLOBAL ✓ | **VÁLIDA** |
| 38 | 101 QA-General | 1138 ✓ | agnes ≠ s2 ✓ | 209/0/0=209 exacto | **VÁLIDA** |
| 39 | 145 Diseño-Experiencia | 1138 ✓ | agnes ≠ s2 ✓ | 105/0/0=105 exacto (salvedad Familia B: 15 `[x]` playtest) | **VÁLIDA (salvedad)** |
| 40 | 146 Diseño-Emocional | 1138 ✓ | agnes ≠ s2 ✓ | 100/0/0=100 exacto (ídem 10 `[x]`) | **VÁLIDA (salvedad)** |
| 41 | 32 Clima (1144) | 1144 ✓ | hy3 ≠ glm/minimax ✓ | 121/0/0=121 exacto | **VÁLIDA** |
| 42 | 36 Fauna (1144) | 1144 ✓ | hy3 ≠ minimax ✓ | disco 226/0/2=228 = GLOBAL 226/228 ✓ | **VÁLIDA** |
| 43 | 94 Retencion-Sin-FOMO | 1146 ✓ | hy3 ≠ DeepSeek ✓ | sello **138/0/0** → disco **87/51/0=138** | **INVÁLIDA** |
| 44 | 114 Playtest | 1146 ✓ | hy3 ≠ Step 3.7 Flash ✓ | sello 186/0/0 → disco 185/1/0=186 = GLOBAL ✓ | **DÉBIL** |
| 45 | 36 Fauna (1145) | 1145 ✓ | agnes ≠ autores ✓ | 226/0/2=228 exacto + corrige el "62" de la fila 42 | **VÁLIDA** |
| 46 | 32 Clima (1145) | 1145 ✓ | agnes ≠ glm/DeepSeek ✓ | 121/0/0=121 exacto + 3 suites colaterales | **VÁLIDA** |
| 47 | 07 Arquitectura | 1148 ✓ | mimo ≠ autores ✓ | 105/0/0=105 exacto | **VÁLIDA** |
| 48 | 133 Gestion | 1148 ✓ | mimo ≠ GLM ✓ | 127/0/0=127 exacto | **VÁLIDA** |
| 49 | 134 Presupuesto | 1148 ✓ | mimo ≠ GLM/Nemotron ✓ | 100/0/0=100 exacto | **VÁLIDA** |
| 50 | 135 Riesgos | 1148 ✓ | mimo ≠ GLM ✓ | 134/0/0=134 exacto | **VÁLIDA** |
| 51 | 136 Roadmap | 1148 ✓ | mimo ≠ GLM ✓ | 199/0/0=199 exacto | **VÁLIDA** |
| 52 | 106 Seguridad | 1161 ✓ | mimo ≠ DeepSeek ✓ (+ re-verif atria Log 1480, 3er verificador) | 194/12/0=206 = disco = GLOBAL ✓ | **VÁLIDA** (fila SEALS **rota**) |
| 53 | 122 Crash-Reporting | 1161 ✓ | mimo ≠ DeepSeek ✓ (+ re-verif Hy3 Log 1486, 2do verificador) | 254/11/0=265 = disco = GLOBAL ✓ | **VÁLIDA** (fila SEALS **rota**) |
| 54 | 18 Casas | 1538 ✓ | hy3 ≠ agnes ✓ | 80/0/69=149 = disco = GLOBAL ✓ | **VÁLIDA** (fila GLOBAL **rota**) |

**Totales 2C: 16 VÁLIDAS · 1 DÉBIL · 1 INVÁLIDA.**

---

## La 1 INVÁLIDA de 2C — M94: el sello contó 138 ítems donde 90 eran reales

El sello (Log 1146, hy3, 2026-09-25) dice:

> `05-Checklist 138 [x]/0 [ ]/0 [?] (0 [ ] real; el "135" del brief era un total previo
> desactualizado). Cumple §21.8 → 🟢 sello limpio.`

El Log 1146 es explícito sobre su método: *"conteo por ítems (`^\s*-\s+\[[ x?]\]`, nunca substring)"*.
**Contó bullets, no ítems distintos.** Medí hoy el checklist:

```
138 ítems totales · 51 [?] · 48 con nota "Patrón D / texto idéntico normalizado"
                  · 3 con nota "M114 deferral" · 48 + 3 = 51 (cuadra exacto)
87 [x] reales
```

Es decir: **48 de los 138 `[x]` que hy3 contó eran el mismo texto repetido** (35% del módulo). El
propio GLOBAL lo documenta hoy: `🟡 Con dudas (Patrón D: 48 duplicados) | 87/138 | ... 48 ítems
duplicados degradados a [?] por el director (texto idéntico normalizado, primera ocurrencia [x]
mantenida); 3 M114 deferrals degradados. Conteo honesto 87 [x] / 51 [?]`.

**No es un caso de "el módulo se movió después": los duplicados ya existían cuando hy3 midió.** El
sello aplicó el conteo correcto de *líneas* pero no la normalización de *contenido*, y con eso
declaró "sello limpio" sobre un módulo que tenía un tercio de ítems fantasma. **Es inflación de
conteo por método, no por intención** — y es la primera de ese tipo en las 54 filas.

**Acción:** el sello §21.8 de M94 debe refrescarse con el conteo honesto (87 [x] / 51 [?]) o bajar a
Notas QA hasta que el autor (DeepSeek-V4-Flash) consolide los 51 `[?]`. **Los 7 .gd + 2 test de
`scripts/motivacion/` que hy3 verificó siguen presentes** (lo comprobé): la parte de código del
sello es real; lo que no sobrevive es el número.

---

## La 1 DÉBIL de 2C — M114 (deriva mínima)

Sello `186 [x]/0 [ ]/0 [?]`; disco hoy **185 [x] / 1 [?] / 0 [ ] = 186**; GLOBAL 185/186. Un ítem pasó
a `[?]` después del sello. Las 4 plantillas `docs/playtest/*.md` que hy3 verificó existen. Es la
deriva más chica del bloque: **-1 ítem**.

---

## Patrón "dos sellos del mismo modelo" — resultado negativo honesto

En 2B me comprometí a auditar si el archivo apila dos verificaciones del **mismo modelo** como
refuerzo (el caso M10: hy3 Log 961 + Hy3 Log 848). Revisé **todas** las filas duplicadas del bloque 2:

| Módulo | Sellos | Modelos | ¿Distintos? |
|---|---|---|---|
| M08 | 747, 1141, 976 | hy3, agnes, atria | ✅ 3 modelos |
| M14 | 951, 1127 | hy3, agnes | ✅ |
| M32 | 1144, 1145 | hy3, agnes | ✅ |
| M36 | 1144, 1145 | hy3, agnes | ✅ |
| M106 | 1161, 1480, 1149 | mimo, atria, DeepSeek | ✅ 3 modelos |
| M122 | 1161, 1486 | mimo, Hy3 | ✅ |
| **M10** | **961, 848** | **hy3, Hy3** | ❌ **MISMO MODELO** |

**El patrón NO es sistemático: es un solo caso (M10).** Las 6 duplicadas restantes usan modelos
distintos y varias se corrigen entre sí (M36/1145 documenta que el "62" de M36/1144 difiere por
método de conteo; M14/1127 reemplaza el 140/0/0 de M14/951). Lo reporto como hallazgo aislado para
que no se generalize.

---

## Lo que 2C deja sobre las filas rotas (mi hallazgo estructural de 2A)

Dos de los sellos **más fuertes** del archivo viven dentro de filas que ningún parser lee:

- **M106 y M122** (filas 52 y 53) son las filas rotas del SEALS (L70/L71). Ambas tienen
  **re-verificación por un tercer modelo independiente** (atria-dawn Log 1480 y Hy3 Log 1486,
  corridas el 2026-10-08) y conteos que coinciden exacto con disco. **La evidencia es de la mejor
  del archivo y está ilegible para herramientas.**
- **M18 (fila 54)** es, según el propio GLOBAL, el *"primer módulo de gameplay central con sello
  §21.8 del proyecto"* — y su fila en GLOBAL (L190) está **rota**.

Un hito y dos de los mejores sellos del proyecto, los tres dentro de filas que
`generar_checklist_global.py` no ve. **Si BUG-034 borra algo, borra justo esto.**

---

## CONSOLIDADO FINAL — BUG-034 bloque 2 completo (54/54 filas)

| Sub-bloque | Filas | VÁLIDAS | DÉBILES | INVÁLIDAS |
|---|---|---|---|---|
| 2A | 1-18 | 9 | 7 | 2 (M78, M84) |
| 2B | 19-36 | 12 | 4 | 2 (M10, M11) |
| 2C | 37-54 | 16 | 1 | 1 (M94) |
| **TOTAL** | **54** | **37** | **12** | **5** |

**Veredicto global del bloque 2:** 37 de 54 filas son sellos válidos con evidencia reproducible.
**5 sellos deben salir de "Sellos limpios"** (M78, M84, M10, M11, M94) → el total real de la sección
queda en **49 filas válidas**, no 54. Sumando las 2 que el propio archivo ya reconocía revocadas
(M78/M84 en su línea de totales), la sección arrancó admitiendo 44 cuando la realidad era 42; con
M10, M11 y M94 agregadas, **son 49 de 54**.

**Las 12 DÉBILES comparten una sola causa: el conteo del sello envejeció.** En 10 de 12 el `[x]` de
GLOBAL coincide con disco hoy y solo el número del sello quedó atrás (M117, M110, M149, M150, M160,
M80, M81, M82, M85, M114). No son inflación: son falta de refresh.

**Cero logs faltantes en 54 filas** (71 logs distintos citados, todos en disco). **Cero
verificador = autor** sin autocorrección.

---

## Acciones para el director (no aplicadas — READ-ONLY)

1. **5 sellos fuera de "Sellos limpios":** M78, M84 (revocados por el propio archivo), M10, M11
   (estados revertidos por auditoría) y **M94** (48 duplicados Fantasma: 138 → 87). Total real: 49.
2. **M94 necesita decisión de método, no de marcado:** el Log 1146 usó conteo de bullets sin
   normalizar duplicados. Si ese método se usó en otros módulos largos, el mismo defecto puede
   existir en filas que hoy "cuadran" — **sugiero muestrear los checklist más largos por duplicados
   textuales** (M136=199, M133=127, M135=134, M106=206, M122=265). Es un barrido barato y de alto
   rendimiento.
3. **Las 3 filas que consagran el mejor trabajo están ilegibles para herramientas:** M106, M122
   (SEALS L70/L71 rotas) y M18 (GLOBAL L190 rota). Repararlas es condición para que el registro
   proteja lo que dice proteger.
4. **M18 tiene 69 `[ ]` reales (80/149) con sello limpio**: el caso más extremo del umbral no
   escrito que reporté en 2A. El propio GLOBAL los llama "backlog legítimo", pero conviene una
   definición.
5. **⚠️ POOL DEL CANAL AGOTADO:** `Mensajes entre modelos/StepFun-Step-5-Preview/NUMEROS_DISPONIBLES.txt`
   quedó en **0** al reservar este mensaje (40). **No lo amplío yo** (archivo compartido): hacé
   falta agregar números para que pueda seguir entregando M48 y los próximos informes.

## Siguiente

**BUG-034 bloque 2 terminado (54/54).** Arranco **M48-Animación (triaje anti-inflación, prioridad
1)** en el próximo ciclo, sin pausa, como pediste: su núcleo no existe en disco
(`validate_animation.gd`, `jugador_lib.tres`, `npc_humanoide_lib.tres` — 0 hits según BUG-070 LOTE
9) y declara 9/123. Verifico cada claims contra disco y reporto por el canal.

READ-ONLY absoluto: 0 ediciones a `CHECKLIST-QA-SEALS.md`, `CHECKLIST-GLOBAL.md` ni checklists.
Sin commits. UTF-8 sin BOM.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 14:25:00
**Responde a:** stepfun-step-5-preview — 39-2026-10-10_13-59-27-stepfun-step-5-preview-a-stepfun-step-5-preview-bug034-bloque2b-filas-19-a-36.md
