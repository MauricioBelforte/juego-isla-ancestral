## Verificación SB-01 (space-bunny-alpha, 2026-10-04)

**Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-04 07:45 → 09:10
**Encargo:** SB-01 (director atria-Dawn-Preview, canal `space-bunny-alpha/01` §4) · **Log:** 1270
**Método:** los 87 `[ ]` se verificaron **por familia**, cargando en un solo contexto (1M, sin
chunking) los `plan-actual/03-Diseno.md` de los 2-4 módulos relacionado por familia. Cada `[x]`
exige evidencia contra **diseño real** (no contra la intención declarada). Sin evidencia, o con el
diseño violando el principio → `[?]`.

**Resultado:** **173 `[x]` · 29 `[?]` = 202.** De los 87 verificados: **58 `[x]` · 29 `[?]`.**
Ningún `[?]` tiene dueño externo: es deuda del propio M152 (confirmado por
`atria-dawn-s2/06-2026-10-04_02-35-00-m152-deuda-limpia-bug091-verificado.md` §1).

**Artefacto núcleo verificado:** `game/isla-ancestral/data/principios.json` (56 líneas, 8 principios
con reglas validables + `auditoria.prohibido_totalmente`) — respalda los 115 `[x]` previos.

---

## Tabla de evidencia por familia

### Familia A — Especificación de principios innegociables (15 → 12 `[x]` / 3 `[?]`)

| Principio | Veredicto | Evidencia (archivo + sección) |
|---|---|---|
| No survival de hambre | `[x]` | `15-Recursos/03-Diseno.md` §2.6 decisión **F1** («la comida es buff, **jamás** necesidad letal») y F3 marcado «**Prohibido** por la visión cozy»; `15-Recursos/03-Diseno.md` §6.2 norma cozy; `principios.json` → `sin_castigos_irreversibles` |
| No castigar por jugar poco | `[x]` | `94-Retencion-Sin-FOMO/03-Diseno.md` §2 **R3** «0 penalización de ausencia» + R1 «0 streaks» + R5; `29-Tiempo/03-Diseno.md` §4 «El reloj **NO** corre offline»; `93-Balance/03-Diseno.md` §2.2 regla 9 «sin decaimiento por ausencia»; `02-Vision/03-Diseno.md` §9.7 |
| No obligar a optimizar | `[x]` | `93-Balance` §2.2 regla 10 «**Sin exponencial** en ninguna curva de progresión (pendiente decreciente)» + regla 8; `71-Progresion/03-Diseno.md` §1 reputación «**nunca bloqueante**»; `93-Balance` §2.3 simula el escenario «**minimalista** (1 sesión/semana)» |
| NPC no todos iguales | `[x]` | `19-NPC-Y-Vecinos/03-Diseno.md` §3.1 `VillagerProfile` (personalidad, historia, profesión, gustos/disgustos/hobbies, silueta, edad, hogar) + 3 líneas propias; §1.2 `VillagerCatalog` «registro de **todos** los candidatos (mayor al límite activo)»; §3.4 `VillagerMood` |
| Mundo no solo procedural vacío | `[x]` | `10-Generacion/03-Diseno.md` §5 «Estructuras pre-generadas» (9 prefabs con colocación fija); §2 regla 3 «su interior **NO** se re-randomiza»; `02-Vision` §4 |
| No puzzles arbitrarios | `[x]` | `24-Templos/03-Diseno.md` «**Validación de arbitrary/ambigüedad**»: 0 o 2+ soluciones alcanzables → «el puzzle **falla la suite** y no entra al build»; §Sistema de ayuda «toda pista está anclada a una regla del grafo»; `93-Balance` §2.2 regla 5 (≤20 min con ayuda); `01-Fundamentos` §6 regla 4 |
| No esconder información esencial | `[x]` | `24-Templos` §Sistema de ayuda (4 niveles redundantes: ambiental → familia → emisor exacto → solución paso a paso; «**Nunca** se penaliza usar ayuda»); `94` §5 «al no participar no hay pérdida: el siguiente ciclo lo repite»; `02-Vision` §7 «UI diegética reducida» |
| Economía no alrededor del grind | `[x]` | `93-Balance` §2.2 reglas 8 («Sellos: **sin requisito de grind repetitivo**») y 11 (tope anti-inflación); `38-Economia/03-Diseno.md` §4.2 anti-arbitraje + §8 «venta nunca supera el 50-60 % de la compra» + §2.2 `limite_diario`; `16-Crafting` §1.3 regla 4 «El conocimiento de recetas es acumulativo y persistente; **nada lo borra**»; `principios.json` → `diversion_sostenida.no_grind_obligatorio` |
| Performance > visuals | `[x]` | `61-Rendimiento/03-Diseno.md` §3.1 tabla de presupuestos (16,7 ms, tolerancia CI 10 %) + §2.3 técnicas obligatorias por sistema + §3.2 `validate_budget.gd` + gate CI (§2 «falla PR si excede»); `90-Configuracion-Grafica` §1 presets + detección automática de hardware; `50-Vegetacion` §1 `vegetation_budget.json` + `validate_vegetation.gd` en CI |
| **No ampliar el mapa por hacerlo grande** | `[?]` | El principio **no se sostiene contra el estado real**: `AGENTS.md` §26 P-39 + `167-Isla-Raiz/01-Requerimientos.md` §Alcance documentan **radio 2560 / mundo 5120²** (ampliación ×10, commit `c107419`) **sin que exista desviación registrada**. El propio ejemplo 3 de M152 (§10) condicionaba la ampliación a «agregar NPCs, recursos, misiones en nuevas áreas», y esa condición nunca se evaluó. `02-Vision` §11 acota la v1.0 a 1-2 islas → la ampliación es un cambio de alcance sin registro. |
| No confundir cantidad con profundidad | `[x]` | `93-Balance` §2.2 reglas 6/8/10; `10-Generacion` §2 (determinismo); `07-Arquitectura/03-Diseno.md` §7 «Reglas anti-circulares (**verificables**)»; `02-Vision` §5 P4 «La facilidad de cada interacción está pulida **antes** de agregar complejidad» |
| No monetización destructiva | `[x]` | `95-Monetizacion/03-Diseno.md` §2 **R1** 0 P2W / **R2** 0 loot boxes / **R3** historia 100 % en base / **R4** 0 microtransacciones; §8 «Lo que NO se hace»; `principios.json` → `salud_jugador.no_pay2win/no_lootbox` |
| **No depender de servicios externos sin plan de contingencia** | `[?]` | Evidencia mixta y **error de categoría**: (a) el lado proyecto **sí** tiene plan de contingencia (`107-Backups/03-Diseno.md` §10, 4 escenarios de desastre con verificación); (b) pero el principio en M152 §4 se define como «el juego debe funcionar sin conexión» y la integración declarada es **M107**, que es de **backups del proyecto** (git/Drive/proyectos DAW), no del juego; (c) `77-Online-Y-Red/03-Diseno.md` §1 declara «**No hay código de red en v1**» y §4 «el save local (M59) sigue siendo la fuente single-player» → el juego **sí** es offline-first, pero eso no está conectado a M152; (d) `59-Guardado/03-Diseno.md` §4 promete «M107 Backups 3-2-1 externos» para **saves**, y el `03-Diseno.md` de M107 **no menciona saves en ningún momento** → contrato declarado y roto. |
| No usar assets sin licencia clara | `[x]` | `tools/legal/validate_asset_metadata.py` + `asset_metadata_scope.json` (gate duro en CI, baseline **trinquete**: 418 `.glb` sin atribución embebida, dueño pipeline M166/M09); registros reales `game/isla-ancestral/data/legal/{licencias,audio_licenses,copyright,modelos_3d}.json`; `83-Licencias/03-Diseno.md` §1 (`LicenseValidator` → **build FAIL**) y §4; `131-Creditos/03-Diseno.md` §3 categoría «Assets de Terceros». Salvedad registrada: los `.glb` son obra propia (licencia declarada `Propietaria` en `copyright.json`); lo que falta es la **atribución embebida**, no la claridad de licencia. Deuda abierta con dueño (BUG-052). |
| **No depender de una sola persona para conocimiento crítico** | `[?]` | El proceso es real (`AGENTS.md` §21 + §21.8 QA cruzado, canales por modelo §10.2, `docs/developers/guia_desarrolladores.md` 12,7 KB, `docs/codigo_de_calidad/deuda_tecnica.md` 9,5 KB, `111-Codigo/03-Diseno.md` §6/§7, ADRs de M133). PERO: (a) `docs/knowledge_sharing.md` **no existe** (artefacto pedido por M152); (b) `docs/codigo_de_calidad/proceso_code_review.md` y `guia_estilo_gdscript.md`, que M111 §2/§6 especifican, **no existen en disco** (la carpeta solo tiene `checklist_commit.md` y `deuda_tecnica.md`); (c) **pair programming no existe como práctica** (el proyecto es 1 humano + agentes). |

### Familia B — Filosofía cozy (1 → 1 `[x]`)

`principios.json` (`sin_fomo`/`sin_castigos_irreversibles`/`eventos_repetibles` + `auditoria.prohibido_totalmente`),
`94/03-Diseno.md` §2 (5 reglas **inmutables** R1-R5), `29/03-Diseno.md` §4 («Regla anti-frustración
(cozy roja)»), `15-Recursos/03-Diseno.md` §6 (5 normas cozy), `02-Vision` §5 P3/P4.

### Familia C — Proceso de revisión (6 → 4 `[x]` / 2 `[?]`)

| Ítem | Veredicto | Evidencia |
|---|---|---|
| Formato de revisión de decisión | `[x]` | **Reusar M133, no crear otro**: `133-Gestion/plan-actual/adrs/0001-README-adrs.md` §Plantilla (Contexto / Decisión / Opciones descartadas / Consecuencias / Firma) + numeración `NNNN` + ciclo de vida. Hay 2 ADRs reales (`0001`, `0002`). |
| Campo de justificación | `[x]` | M152 `03-Diseno.md` §5 «### Justificación (si alguna casilla no está marcada)»; M133 ADR §Contexto + §Opciones descartadas |
| Campo de aprobación | `[x]` | M152 §5 «### Aprobación / **Aprobado por:** / **Fecha:**»; M133 ADR §Ciclo de vida («esperando confirmación del fundador o de otro agente») |
| Registro de desviaciones justificadas | `[x]` | M152 §5 tabla de 6 columnas + `133/.../adrs/` como registro real en disco |
| Objetivo: 100 % de decisiones críticas revisadas | `[?]` | Sin instrumento de medición y **sin definición de «decisión crítica»** en ningún documento. Dueño: director (definición del denominador). |
| Objetivo: < 5 % de desviaciones justificadas por mes | `[?]` | Sin denominador definido. Además **contradice** el objetivo ya `[x]` de «0 % de principios violados sin justificación»: si toda desviación debe justificarse, la métrica útil es 0 % sin justificar, no < 5 % con justificar. |

### Familia D — Documentación de principios (4 → 4 `[x]`)

`docs/licencias_assets.md` y `docs/knowledge_sharing.md`: **diseñados** (M152 `04-Codigo.md` §10/§11)
y **superados por artefactos reales** (M83 + M127 + M131 / M111 + M133 + AGENTS.md §21).
`Definir proceso de revisión` → M152 §5 + ADR M133. `Definir registro de desviaciones` → M152 §5.

> **Regla aplicada (AGENTS.md §3):** `docs/` es material **complementario** y **no** es destino de
> documentación nueva. Por eso estos 4 ítems se cierran como **diseñados** y **NO** se crean los
> archivos: el registro vivo ya existe en `game/isla-ancestral/data/legal/*.json` +
> `tools/legal/*` + `DOCUMENTACION/133-.../adrs/`.

### Familia E — Integración con otros módulos (15 → 10 `[x]` / 5 `[?]`)

| Módulo | Veredicto | Evidencia / motivo del `[?]` |
|---|---|---|
| M01 | `[x]` | `01-Fundamentos/03-Diseno.md` §11 decisión 1 «Cero violencia y cero penalizaciones violentas — **CERRADA**»; §2.1 bucle diario 20-45 min; §6 reglas de puzzles |
| M02 | `[x]` | §1 Filosofía «Ausencia total de combate, muerte o penalizaciones violentas»; §5 pilares P1-P4; §9.7 sin FOMO; §10 60 FPS. Es la fuente de la visión |
| **M07** | `[?]` | La integración existe pero **los principios nombrados no están en el diseño de M07**: `03-Diseno.md` no menciona ni *offline-first* ni *knowledge sharing*. Lo que M07 sí implementa es «sistemas con propósito / profundidad»: §2 contrato de integración de módulo nuevo + §7 reglas anti-circulares automatizadas. Corregir el emparejamiento |
| M10 | `[x]` | §5 estructuras pre-generadas + §2 reglas duras de determinismo |
| M13 | `[x]` | §7 «Durabilidad y reparación (**reglas cozy**)»: «La durabilidad baja de a 1 por uso; **NUNCA 0** → herramienta inservible hasta reparar (**no desaparece**)»; §6 «Sin herramientas atascadas» |
| **M14** | `[?]` | M14 cumple la parte cozy de **no pérdida permanente** (§2 «never se pierde», overflow → pickup flotante; §3 descarte con confirmación), pero su diseño **no enuncia economía cozy**: el principio económico vive en M38/M16/M93. El emparejamiento declarado es incorrecto |
| M16 | `[x]` | §1.3 regla 4 (conocimiento acumulativo, «nada lo borra»); §2.1 ROLLBACK honesto + «sin penalización»; §4.3 reparación como receta de estación; §4.5 recetas por evento «**no por dinero**» |
| M29 | `[x]` | §4 «Regla anti-frustración (cozy roja)»: todo evento importante repetible, el contenido NUNCA se destruye, el reloj NO corre offline, estaciones se anuncian 1 día antes |
| **M50** | `[?]` | **Etiqueta equivocada**: M152 dice «M50 (**Modelos 3D**)» pero M50 es **50-Vegetación** (los modelos 3D son M45-Arte-3D). El principio sí se cumple en M50 (§1 LOD 2 niveles + `vegetation_budget.json` + `validate_vegetation.gd` en CI), pero la integración apunta al módulo equivocado |
| M59 | `[x]` | §2.1 escritura atómica `.tmp`+fsync+rename + rotación `.bak`; §2.2 checksum SHA-256 + migración; §3.2 robustez (apagado en escritura, corrupción, disco lleno, **3+ perfiles**) |
| M61 | `[x]` | §3.1 presupuestos + §3.2 validador (tolerancia 10 %) + gate CI que falla el PR |
| **M64** | `[?]` | **Módulo equivocado**: M152 dice «M64 (NPC): variedad de NPCs», pero M64 es **64-IA-De-NPC** (FSM, necesidades, navegación, watchdog). La **variedad** está en **M19** (`VillagerProfile`) + M161 (diseño visual) + M162 (diálogos). M64 aporta el *comportamiento*, no la *variedad* |
| **M107** | `[?]` | Error de categoría (backups del proyecto ≠ offline del juego) + contrato roto con M59 (ver Familia A, principio de servicios externos) |
| M111 | `[x]` | §6 proceso de code review con checklist de 10 puntos + §7 registro de deuda técnica (archivo real `docs/codigo_de_calidad/deuda_tecnica.md`, 9,5 KB) + §2 límites y métricas. Salvedad: faltan `proceso_code_review.md` y `guia_estilo_gdscript.md` en disco (deuda de M111, no de M152) |
| M131 | `[x]` | §3 categoría «Assets de Terceros — Bibliotecas, texturas, modelos, sonido **con licencia**»; §1 `CreditsDirector` alimentado por el validador de licencias |

### Familia F — Revisión periódica (4 → 1 `[x]` / 3 `[?]`)

| Ítem | Veredicto | Evidencia / motivo |
|---|---|---|
| Frecuencia (cada 3 meses) | `[x]` | **Ya existe y es operativa**: `135-Riesgos/plan-actual/GUIA-REVISION-TRIMESTRAL.md` §1 «trimestral (obligatoria; RN9)» con fechas objetivo (28/11/2026, 28/02/2027…) y §4 paso que incluye «cambios de M136/**M152**». Reusar, no crear proceso paralelo |
| Responsable (equipo de diseño) | `[?]` | El responsable real es **fundador + 1 agente IA asistente** (`GUIA-REVISION-TRIMESTRAL.md` §2). No existe un «equipo de diseño»: el proyecto tiene 1 humano + agentes. M152 `04-Codigo.md` §12 asigna «COORDINADOR / EQUIPO DE DISEÑO», dueño **no identificable** |
| Proceso de documentación de cambios | `[?]` | Existe para *decisiones* (M133 ADR §Ciclo de vida: log en `Logs/` + actualizar el módulo afectado) y para *riesgos* (`GUIA-REVISION-TRIMESTRAL` pasos 5/8/9: append-only, firma, motivo si se omite). Falta el paso específico para **cambios en los principios** (qué pasa al agregar/eliminar un principio) |
| Proceso de comunicación de cambios | `[?]` | El mecanismo existe (Modo Canal AGENTS.md §10.2 + informe por log), pero no hay proceso de comunicación de **cambios de principios** al equipo; el README de ADR no lo cubre |

### Familia G — Ejemplos de aplicación (5 → 1 `[x]` / 4 `[?]`)

| Ítem | Veredicto | Evidencia / motivo |
|---|---|---|
| Ejemplo 1: decisión de agregar combate | `[?]` | El ejemplo **existe como diseño** (M152 §10) pero quedó **desactualizado**: el combate **sí se agregó** (`164-Isla-De-Combate-Endgame/03-Diseno.md` completo: 4 zonas, 8 mobs con HP/ataque, 2 jefes con fases, tienda de gemas, 6 recompensas) y **no hay desviación registrada**. Tensión viva con `02-Vision` §1 «ausencia total de combate» |
| Ejemplo 3: decisión de ampliar mapa | `[?]` | La ampliación ×10 ocurrió (radio 2560 / mundo 5120², `167-Isla-Raiz` + AGENTS.md §26 P-39) sin evaluar la condición del ejemplo («solo si se agregan NPCs, recursos, misiones en nuevas áreas») |
| Resultado de ejemplo 1 (aprobado) | `[?]` | No hay registro del resultado real. El resultado real es «combate agregado en M164 sin desviación registrada» |
| Resultado de ejemplo 2 (aprobado con modificación) | `[x]` | **Único ejemplo con resultado real documentado**: `15-Recursos/02-Analisis.md` §2.6 registra la decisión (F1) y su modificación exacta («Hambre reduce stamina, no mata; comida abundante»), coherente con M152 §10 Ejemplo 2 |
| Resultado de ejemplo 3 (aprobado con condición) | `[?]` | La condición nunca se evaluó ni se registró |

### Familia H — Definición de cozy (1 → 1 `[x]`)

M152 `04-Codigo.md` §5 «## Definición de cozy» (8 ítems) + `15-Recursos/03-Diseno.md` §6
«Regla Cozy» (5 normas) + `94/03-Diseno.md` §2 R1-R5. Tres capas concuerdan.

### Familia I — `proceso_revision.md` (5 → 5 `[x]`)

Formato/justificación/aprobación/fecha/responsable: todos presentes en M152 §5 + `04-Codigo.md` §8,
y superados por la plantilla ADR de M133 (`Contexto` / `Decisión` / `Opciones descartadas` /
`Consecuencias` / `**Firma:** {Modelo} / {Plataforma}`) y por `GUIA-REVISION-TRIMESTRAL.md` §3.8
(«firmar con modelo/plataforma»).

### Familia J — `desviaciones_justificadas.md` (2 → 1 `[x]` / 1 `[?]`)

- Tabla de desviaciones → `[x]`: M152 §5, 6 columnas (ID, Decisión, Principio desviado, Justificación, Aprobado por, Fecha).
- Ejemplo de desviación justificada → `[?]`: el ejemplo `D001` («Agregar combate para misiones específicas») es **ficticio**. Ya existen **2 desviaciones reales sin registrar**: (1) el combate de M164 vs `02-Vision` §1; (2) la ampliación ×10 del mapa sin la condición del ejemplo 3.

### Familia K — `licencias_assets.md` (7 → 6 `[x]` / 1 `[?]`)

| Ítem | Veredicto | Evidencia |
|---|---|---|
| Formato de registro | `[x]` | M152 §10 + **superado** por `83-Licencias/03-Diseno.md` §2.1 `LicenseProfile` (11 campos) |
| Campos asset/licencia/atribución/fuente | `[x]` | `LicenseProfile`: `dependency_name`, `version`, `license_type`, `license_text`, `license_url`, `commercial_use`, `attribution_required`, `source_offer_required`… (superset de los 4 pedidos) |
| Licencias comunes | `[x]` | `83` §2.2 enum `LicenseType` con **15** valores: incluye los 6 de M152 (MIT, CC0, CC_BY, CC_BY_NC, PROPRIETARY) + BSD_2/3, APACHE_2, GPL_2/3, LGPL, MPL_2, AGPL, UNKNOWN, DUAL |
| Proceso de verificación | `[x]` | `83` §1 (Scanner→Extractor→Validator→NoticeGenerator) + §4 (**build FAIL**) + real: `tools/legal/validate_asset_metadata.py --check` (gate duro) y `audit_dependencies.py` |
| Proceso de registro de assets | `[x]` | `108-Pipeline` + `tools/legal/generate_copyright_register.py` + `data/legal/*.json` |
| **Inclusión de archivo de licencia** | `[?]` | M83 §5 especifica `licenses/` + `THIRD_PARTY_LICENSES.txt` en el build y `licencias.json` declara `copiar_licencias_en_distribucion: true`, pero **no hay verificador de que exista un archivo de licencia junto a cada asset**: `validate_asset_metadata.py` comprueba **copyright embebido**, no presencia de LICENSE por asset. Falta esa pieza |
| Atribución en créditos | `[x]` | `131-Creditos` §3 + §1 (`CreditsDirector` ← validador de licencias) + `data/legal/creditos.json` y `audio_licenses.json` con campo `attribution` |

### Familia L — `knowledge_sharing.md` (7 → 3 `[x]` / 4 `[?]`)

| Ítem | Veredicto | Evidencia / motivo |
|---|---|---|
| Prácticas de documentación | `[x]` | M111 §10 `docs/codigo_de_calidad/guia_desarrolladores.md` — **real, 12,7 KB** |
| Prácticas de code reviews | `[x]` (previo) | M111 §6 |
| **Prácticas de pair programming** | `[?]` | El proyecto **no tiene** pair programming (1 humano + agentes de IA). El mecanismo equivalente es el **QA cruzado §21.8** (verificador ≠ autor) y el Modo Canal §10.2. El ítem no es irrealizable, pero su diseño no corresponde a la realidad del proyecto |
| **Prácticas de knowledge sharing sessions** | `[?]` | No existe reunión: el usuario es una persona. Equivalente real: informe por canal + `Log` en `Logs/` (§6) |
| Herramientas de knowledge sharing | `[x]` | M111 (`quality.yml` con 5 jobs + `code_quality_check.gd` + `.gdscriptlint`), M112 (GdUnit4 v6.2.1 + `test_runner.tscn`, 187 casos), M103 (Logging), `docs/qa/guia-para-agentes.md`, `AGENTS.md` §21 + `scripts/` (3 orquestadores + suite de tests). Múltiples y reales |
| Proceso de documentación de arquitectura | `[x]` | M07 `03-Diseno.md` completo (capas, EventBus con dominios, GameState, §7 reglas anti-circulares) + M05 patrones transversales |
| Proceso de documentation de sistemas | `[x]` (previo) | — |
| Proceso de code reviews | `[x]` (previo) | — |
| **Proceso de pair programming** | `[?]` | Ídem: la práctica no existe; debe redefinirse como «QA cruzado §21.8» o eliminarse del checklist |
| **Proceso de knowledge sharing sessions** | `[?]` | Ídem: la práctica no existe; debe redefinirse como «informe en canal §10.2 + Log §6» |

### Familia M — Checklist de revisión contra principios (8 → 8 `[x]`)

Los 8 ítems están **diseñados verbatim** en M152 `03-Diseno.md` §5 y `04-Codigo.md` §8. Además,
7 de los 8 tienen **evidencia de diseño real** detrás (ver Familias A/B). Los 2 cuyo respaldo es
parcial quedan anotados en su propia línea y sus principios de fondo están como `[?]` en Familia A:
- «¿no depende de servicios externos sin fallback?» → principio de fondo `[?]` (ver RF15).
- «¿no introduce dependencia crítica de una sola persona?» → principio de fondo `[?]` (ver RF17).

### Familia N — Métricas de cumplimiento (3 → 0 `[x]` / 3 `[?]`)

Ninguna de las 3 tiene instrumento:
- «número de desviaciones justificadas por mes» → no hay registro que lo produzca (el ADR registra decisiones, no desviaciones de principios).
- «100 % de decisiones críticas revisadas» → **«decisión crítica» no está definido** en ningún documento → denominador inexistente.
- «< 5 % de desviaciones justificadas por mes» → mismo problema de denominador + contradicción lógica con el objetivo ya `[x]` de 0 % sin justificar.

### Familia O — Proceso de revisión periódica (4 → 1 `[x]` / 3 `[?]`)

| Ítem | Veredicto | Evidencia / motivo |
|---|---|---|
| Frecuencia: cada 3 meses | `[x]` | `GUIA-REVISION-TRIMESTRAL.md` §1 (trimestral obligatoria, fechas objetivo, paso 9 «si se omite, registrar motivo y reprogramar en ≤ 30 días») |
| Responsable: equipo de diseño | `[?]` | Real = fundador (decide) + agente IA (prepara), `GUIA-REVISION-TRIMESTRAL.md` §2. No hay equipo de diseño |
| Paso 5: documentar cambios y justificaciones | `[?]` | El paso 5 de M135 existe pero es del **registro de riesgos** («cerrar riesgos superados con motivo y lección aprendida», append-only). Para **principios** la pieza equivalente sería el ciclo de vida del ADR + log; falta el paso específico |
| Paso 6: comunicar cambios al equipo | `[?]` | M135 paso 10 reporta a M133/M136; falta la comunicación de **cambios de principios**. Mecanismo reutilizable: Modo Canal §10.2 |

---

## Hallazgos colaterales (NO son de M152 — reportados, no tocados)

1. **`145-Diseno-De-Experiencia/plan-actual/03-Diseno.md` L52**: contiene **`自由`** (CJK) dentro de la  [cjk-gate: allow: cita intencional del bug CJK de M145]
   línea `└──自由 exploración`. Es corrupción de codificación en un doc en español → violation de  [cjk-gate: allow: cita intencional del bug CJK de M145]
   AGENTS.md §28. Corrige el dueño de M145 (agentes previos).
2. **`83-Licencias-De-Software/plan-actual/03-Diseno.md` §6**: cita «Integración con Inventario de
   Dependencias (**M55**)», pero M55 es **Diario Del Jugador**, no un inventario de dependencias.
   Cita interna incorrecta en M83.
3. **`164-Isla-De-Combate-Endgame/plan-actual/03-Diseno.md`**: L93 « mapa de la isla» sin sangría y
   L91/93 sin tildes; menor, puramente de formato.
4. **`59-Guardado` ↔ `107-Backups`**: M59 §4 declara que M107 aporta «Backups 3-2-1 externos» para
   saves; el diseño de M107 no menciona saves. Contrato declarado sin contraparte (ya marcado `[?]`
   en las dos familias afectadas).
5. **Contadores incoherentes en la fila 152 de `CHECKLIST-GLOBAL.md`**: el `Progreso` decía `115/202`
   mientras el `05-Checklist` decía «189 ítems». Corregido en este bloque (ver más abajo).

---

## Corrección aplicada a este archivo

El bloque de totales declaraba **«189 ítems · 189 resueltos por documentación · 0 pendientes»**,
cifra **falsa** que contradecía el conteo de marcas del propio archivo (115 `[x]` / 87 `[ ]`). Es el
mismo defecto de sobre-cierre detectado en M93 (mencionado por `atria-dawn-s2/06`). **Corregido** a
un conteo real y falsable:

- **202 marcas de ítem** · **173 `[x]`** · **29 `[?]`** · **0 `[ ]` sin dueño**.
- Los **115 `[x]` previos** se conservan (el núcleo `principios.json` es real).
- Los **29 `[?]`** están **todos justificados con evidencia** en las tablas de este apéndice.

**Conteo por familia de los 87 verificados:**

| Familia | `[x]` | `[?]` | Total |
|---|---:|---:|---:|
| A — Especificación de principios innegociables | 12 | 3 | 15 |
| B — Filosofía cozy | 1 | 0 | 1 |
| C — Proceso de revisión | 4 | 2 | 6 |
| D — Documentación de principios | 4 | 0 | 4 |
| E — Integración con otros módulos | 10 | 5 | 15 |
| F — Revisión periódica | 1 | 3 | 4 |
| G — Ejemplos de aplicación | 1 | 4 | 5 |
| H — Definición de cozy | 1 | 0 | 1 |
| I — `proceso_revision.md` | 5 | 0 | 5 |
| J — `desviaciones_justificadas.md` | 1 | 1 | 2 |
| K — `licencias_assets.md` | 6 | 1 | 7 |
| L — `knowledge_sharing.md` | 3 | 4 | 7 |
| M — Checklist de revisión (8 ítems) | 8 | 0 | 8 |
| N — Métricas de cumplimiento | 0 | 3 | 3 |
| O — Proceso de revisión periódica | 1 | 3 | 4 |
| **TOTAL** | **58** | **29** | **87** |

## Lo que NO pude hacer (honestidad obligatoria)

- **No ejecuté código ni tests.** El encargo es documental (`V0`): no toqué gameplay, ni `quality.yml`,
  ni ningún módulo `🔵`/`🔴` de otro agente. Mi evidencia es de **diseño documentado**, no de runtime.
- **No verifiqué los 115 `[x]` previos.** El encargo eran los 87 `[ ]`. Que los 115 se sostienen
  depende de otro verificador (el núcleo `principios.json` sí lo confirmé en disco).
- **No creé `docs/licencias_assets.md` ni `docs/knowledge_sharing.md`.** AGENTS.md §3 prohíbe
  documentación nueva en `docs/` (es material complementario). Cerré esos ítems como **diseñados y
  superados** por los registros reales, no como «archivo creado».
- **No resolví los `[?]` de las Familias F/G/N/O.** Requieren decisiones del **fundador** (definir
  «decisión crítica», el denominador de las métricas, el responsable real de la revisión, y registrar
  las 2 desviaciones reales: combate de M164 y ampliación ×10 del mapa). No son deuda técnica: son
  decisiones de gobernanza que no me corresponde tomar.
- **No verifiqué el estado real de las cifras de CHECKLIST-GLOBAL** más allá de la fila 152
  (el archivo tiene derivas de columnas documentadas por otros agentes).

## Recomendaciones para el siguiente agente

1. **Prioridad 1 — registrar las 2 desviaciones reales** en un registro de desviaciones (reusar la
   tabla de M152 §5 o abrir 2 ADRs en M133): (a) combate de M164 vs `02-Vision` §1; (b) mapa ×10
   (radio 2560 / mundo 5120²) vs el ejemplo 3. Mientras no estén registradas, el principio «0 % de
   principios violados sin justificación» (ya `[x]`) es **incumplible**.
2. **Prioridad 2 — corregir 4 emparejamientos erróneos** en M152 §6/§4: M50 es Vegetación (no
   «Modelos 3D»), M64 es IA (la variedad está en M19/M161), M07 no lleva offline-first ni knowledge
   sharing, M107 es de backups del proyecto (no offline del juego).
3. **Prioridad 3 — definir los denominadores** de las 3 métricas `[?]` y el responsable real de la
   revisión periódica (fundador + agente, como en M135 §2).
4. **Prioridad 4 — redefinir o eliminar** los 4 ítems de pair programming / KS sessions (Familia L),
   que describen prácticas que este proyecto no tiene.
5. **No hace falta crear los 8 archivos de `docs/principios/`**: la información vive mejor en
   `game/isla-ancestral/data/principios.json` (validable por código) + las guías del proyecto. Si se
   quiere un documento legible, el lugar correcto es `DOCUMENTACION/152-Principios-Innegociables/plan-actual/`.

---

**Firma de este bloque:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code ·
**Fecha:** 2026-10-04 · **Log:** 1270 · **Canal:** `Mensajes entre modelos/space-bunny-alpha/02-...`