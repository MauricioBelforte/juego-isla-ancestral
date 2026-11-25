**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25

# 08-Plan-De-Submissions.md — M82 Clasificación por Edades

> Artefacto real de la sección D "Proceso de Submission" (checklist L64/L65/L71/L72):
> timeline de submissions, responsable por sistema, checklist de pre-submission y
> proceso de QA interno. Fuente de datos: `03-Diseno.md` (tabla de plataformas §4,
> sistemas regionales §1) y `scripts/legal/rating_validator.gd` (validación automática,
> test `test_rating_m82.gd`). Este documento NO sustituye al código: define el
> PROCESO que la ejecución humana (fundador) debe seguir.

## 1. Timeline de submissions (L64)

Los ratings se obtienen en **4 ventanas del roadmap** (M136 Roadmap / M139 Pre-Alpha / M140 Alpha / M141 Beta / M142 RC):

| Ventana | Momento | Qué se submitte | Por qué entonces |
|---|---|---|---|
| **W1 — Post-Alpha** | Alpha cerrada, contenido principal estable | **IARC (cuestionario único, gratis)** | Es la base de casi todo: Steam/Google Play/Microsoft Store/Nintendo lo aceptan directo (§4 de 03-Diseno). Con el cuestionario respondido con honestidad, IARC emite rating automático por plataforma. Cambios de contenido entre Alpha y Beta → re-submit IARC (es gratis, sin penalización). |
| **W2 — Inicio de Beta** | Al congelar el alcance de contenido | **PEGI (Europa)** — formulario online (~500 € una vez) | Steam Europa, PlayStation EU, Xbox EU, Nintendo EU. Debe existir ANTES de la store page de M97 (Steam exige rating en la página). |
| **W3 — Inicio de RC** | Build candidata, trailers ya cortados | **ESRB (EE.UU./Canadá)** — short-form digital (~3.000 USD + descriptores) | PlayStation NA lo exige directo (§4). Steam NA acepta IARC/ESRB — ESRB da visibilidad en la store. Trailer de M98 ya debe respetar el rating (marketing coherente). |
| **W4 — Pre-lanzamiento (≥3 meses antes de la fecha de salida)** | Fecha de lanzamiento fijada | **CERO (Japón)**, **GRAC (Corea)**, **ACB (Australia)**, **USK (Alemania, ~2.400 €/año título), ClassInd (Brasil)** — solo si se publica en esos territorios | Los plazos de respuesta regionales son largos (USK/ClassInd ~4-8 semanas; CERO ~2 meses). Submittear 3 meses antes da margen para appeal sin mover la fecha (proceso de appeal: 05-Checklist sección D, ítem ya cerrado). |

**Regla de oro del timeline:** ninguna store page (M97), trailer (M98) ni material de marketing (M99) se publica con rating vacío o provisional en el territorio de esa store. El build metadata (M117) lleva el rating por región como dato de configuración.

**Recertificación:** IARC exige re-submit si el contenido cambia de forma material (nuevos descriptores). Cada vez que se agrega una feature con potencial de descriptor (combate visible, chat, compras, gambling, microtransacciones), el rating profile (`rating_profile.gd`, 03-Diseno §2) debe actualizarse en el MISMO commit de la feature.

## 2. Responsable por submission (L65)

| Rol | Responsabilidad |
|---|---|
| **Fundador / dueño del proyecto** (único responsable legal) | Cuenta de cada board, firma de formularios, pago de fees, decisión final de submittear. Las leyes de clasificación exigen una persona física/jurídica: ninguna IA o agente puede firmar. |
| **Agente de módulo legal (rol documental, ej: M82 en su turno)** | Prepara el material de cada submission: rating profile al día (descriptores), screenshots/builds de contenido requeridos por el board, checklist pre-submission ejecutado (§3), validación `rating_validator.gd` en verde. NO submitte por sí. |
| **Verificador cruzado (QA §21.8, modelo distinto)** | Revisa que el rating declarado en el submission data concuerda con el contenido real (descriptores ↔ features) antes de que el fundador firme. |
| **M97/M98/M99 (consumidores del rating)** | Aplican el rating en store pages, trailers y marketing. No deciden el rating. |

**Cadena de responsabilidad:** agente prepara → verificador cruza → fundador firma y submitte → resultado se registra en el rating profile (estado de submission, 03-Diseno §2).

## 3. Checklist de pre-submission por sistema (L71)

Checklist a ejecutar ANTES de cualquier submission. Aplica a todos los sistemas; los pasos marcados por sistema son adiciones específicas.

### 3.1 Checklist universal (todos los sistemas)

1. [ ] `rating_profile.gd` (03-Diseno §2) actualizado: descriptores de contenido al día con el contenido REAL de la build (features nuevas → descriptores nuevos, regla de recertificación §1).
2. [ ] `python`/headless: `rating_validator.gd` ejecutado y en verde (`test_rating_m82.gd` EXIT 0) — valida catalogo↔rating objetivo.
3. [ ] Inventario de contenido sensible verificado: violencia (combate/pesca/minería tienen variantes "cozy"), sustancias (¿juegos con bebida/brebajes?), gambling (¿apuestas?, ¿loot boxes?), chat/comunicación (multijugador M76 — filtro PII), compras in-app (M95 Monetización).
4. [ ] Screenshots/vídeo de las escenas que el board pide para cada descriptor (guía de captura: `tools/mcp/godot-mcp/capturas/`).
5. [ ] Builds de demo/vídeo gameplay sin placeholder en contenido declarado (los boards evaluán lo que se muestra).
6. [ ] Plan B documentado (ítem ya cerrado en sección C): si el board sube el rating, ¿qué se recorta/oculta? (worst-case: agregar combate/peligro → Teen; el diseño cozy mantiene Everyone).
7. [ ] Presupuesto del fee cubierto (costes ya estimados: ítem "costo total estimado" cerrado) y cuenta de la board activa.

### 3.2 Adiciones por sistema

| Sistema | Adiciones específicas |
|---|---|
| **IARC** | Cuestionario completo por plataforma destino (Steam/Play/MS Store/Nintendo responden del mismo IARC). Verificar que el email de contacto es el del fundador. Re-submit completo si cambió algún descriptor. |
| **PEGI** | Formulario de contenido VSC/IARC-wrapped + declaración de clasificación de compra in-game. Fee único por título. |
| **ESRB** | Short-form digital + vídeo gameplay NO editado (60 min) si el board lo pide + descriptores de compras/ads. |
| **CERO** | Formulario japonés + material físico en algunos casos. Prever ~2 meses de plazo. |
| **GRAC** | Registro de servidor de juego (multijugador M76/M77) + política de moderación de chat. |
| **USK** | Build Germany-ready (verificar que el contenido bloqueado en Alemania no rompe la build — preset de export región). |
| **ACB / ClassInd** | Formulario local + fee; verificar clasificación del DLC/futuras expansiones (M120). |

### 3.3 Cierre de cada submission (post-envío)

1. [ ] Estado de submission registrado en el rating profile (`submission_state`).
2. [ ] Copia del submission data guardada en el módulo (evidencia).
3. [ ] Resultado aplicado a store pages (M97), trailer (M98), marketing (M99) y build metadata (M117) en ≤1 semana.
4. [ ] Si el rating NO es el esperado → proceso de appeal ya definido (sección D, ítem cerrado); NO publicar material con rating en disputa.

## 4. QA interno antes de cada submission (L72 — definición del proceso)

**Objetivo del proceso:** que NINGÚN submission llegue al fundador sin haber pasado dos filtros automáticos y uno humano.

1. **Filtro automático de datos (cada commit):** `test_rating_m82.gd` (headless EXIT 0) valida que el catálogo de rating y el rating objetivo sean consistentes. Forma parte de la batería del módulo; un rojo bloquea la preparación del submission.
2. **Filtro automático de contenido (cada vez que se prepara un submission):** revisión de descriptores vs features REALES de la build: tabla de contenido sensible (§3.1 paso 3) + capturas de las escenas relevantes (evidencia visual, V2/V4 del M154 — el agente que prepara DEBE mirar las escenas, no solo el código).
3. **Filtro humano (el fundador, firma final):** el fundador revisa el paquete preparado (rating profile + capturas + checklist §3 marcado) y decide. El agente NO submitte solo.

**Registro:** cada submission preparado deja su checklist marcado como evidencia en este módulo (o en una subcarpeta `submissions/` del plan-actual cuando haya más de uno). Sin el checklist marcado, el fundador no firma.

---

## Notas del Agente

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25 15:20
**Estado:** Completado (tanda documental)

### Lo que hice
- Artefacto único `08-Plan-De-Submissions.md` cubriendo los 4 ítems revertidos por la auditoría BUG-070 lote 6: L64 timeline (4 ventanas del roadmap W1-W4), L65 responsable (fundador firma; agente prepara; verificador cruza), L71 checklist pre-submission universal + adiciones por sistema (IARC/PEGI/ESRB/CERO/GRAC/USK/ACB/ClassInd), L72 definición de QA interno (2 filtros automáticos + 1 humano, con rating_validator como filtro de datos).
- Datos tomados de los artefactos reales existentes: 03-Diseno.md §1/§4 (sistemas y plataformas), rating_validator.gd + test_rating_m82.gd (en disco), ítems ya cerrados de la misma sección D (appeal, plazos, emergencia, costes — el timeline los REFERENCIA, no los duplica).

### Límites honestos
- Los fees y plazos citados son ordenes de magnitud documentales (W1-W4); la cifra contractual exacta se confirma al contratar cada board (fuera del alcance de un agente).
- La ejecución de submissions es del fundador (ley de los boards); este documento define el proceso, no la ejecuta.

## 5. Recordatorio de recertificación anual (L132)

**Regla:** los ratings de los boards NO caducan, pero el CONSUMO del rating sí debe re-auditar 1 vez al año y en cada evento de contenido material:

| Disparador | Acción |
|---|---|
| **Aniversario del último submission aprobado** (fecha registrada en el rating profile) | Re-ejecutar el checklist §3 completo contra la build actual. Si el contenido cambió de forma material (nuevos descriptores), re-submit IARC (gratis) + actualizar los regionales que apliquen. Si NO cambió: registrar "re-auditoría anual: sin cambios" como evidencia en este módulo (una línea basta, pero debe EXISTIR). |
| **Feature con potencial de descriptor** (combate visible, chat/UGC M124, compras M95, gambling) | Re-submit INMEDIATO (no anual): regla del §1 — el rating profile se actualiza en el MISMO commit de la feature. |
| **Pre-lanzamiento de DLC/expansión (M120)** | Cada expansión re-pasa el checklist §3.2 del board correspondiente antes de su release. |

**Mecanismo del recordatorio:** la fecha del último submission aprobado vive en `rating_profile.gd` (`submission_state`, 03-Diseno §2). En el aniversario, el CI no puede decidir por sí (el contenido es humano): el recordatorio es PROCEDIMENTAL — la re-auditoría anual es la primera tarea del plan de mantenimiento anual (M121 Soporte Post-Lanzamiento, plan de release maintenance). Este documento es el artefacto al que apunta el recordatorio; sin evidencia de re-auditoría en el módulo, el proceso NO está cumplido.

## 6. Resumen ejecutivo para stakeholders (L119)

**Estado (2026-11-25):**
- **Rating objetivo:** Everyone/PEGI 3 (diseño cozy, sin contenido forzado — validado con M81; worst-case documentado en sección C: agregar combate/peligro subiría a Teen/PEGI 7).
- **Sistemas cubiertos por el plan:** IARC (base global, gratis, alimenta Steam/Play/MS Store/Nintendo), PEGI (EU), ESRB (NA), CERO (JP), GRAC (KR), ACB (AU), USK (DE), ClassInd (BR) — submission directa solo donde la store no acepta IARC (PlayStation NA→ESRB, PlayStation EU→PEGI).
- **Timeline:** W1 post-Alpha (IARC) → W2 inicio Beta (PEGI) → W3 inicio RC (ESRB) → W4 pre-lanzamiento ≥3 meses (regionales según territorio de lanzamiento).
- **Coste:** IARC gratis; PEGI ~500 €; ESRB short-form ~3.000 USD; USK ~2.400 €/título; regionales restantes con fee menor (cifras de orden de magnitud; la cifra contractual se confirma al contratar).
- **Gates ya en CI:** `test_rating_m82.gd` cableado en `.github/workflows/quality.yml` (job test-suite) — el build FALLA si el rating declarado es inconsistente con el catálogo (L92).
- **Responsable:** el fundador firma y submitte (único responsable legal); el agente legal prepara el paquete y el verificador cruzado revisa descriptores↔contenido (§2).
- **Riesgo principal:** contenido nuevo con descriptor no declarado → recertificación fuera de ventana (mitigado por la regla del commit + W4 con 3 meses de margen).

**Para el fundador:** las únicas decisiones que te pide este plan son W2/W3/W4 (confirmar ventanas según el roadmap real de M136) y firmar cada submission — el resto está preparado y automatizado en CI.

---

## Notas del Agente (ampliación tanda)

**Modelo:** GLM-5.3-Flash · **Plataforma:** Kilo Code · **Fecha:** 2026-11-25 15:25
- Ampliación del mismo artefacto con §5 (recordatorio de recertificación anual, L132) y §6 (resumen ejecutivo para stakeholders, L119) — ambos antes revertidos por falta de artefacto (BUG-070 lote 6 y patrón M114 L48). El gate de CI (L92) quedó cableado en `.github/workflows/quality.yml` (suite 9/0 medida en verde ANTES de cablear, gate duro `suite()` del job test-suite).
- Límite honesto: el "recordatorio" es procedimental (fecha viva en rating_profile + primera tarea del mantenimiento anual M121); el CI no puede decidir contenido humano.
