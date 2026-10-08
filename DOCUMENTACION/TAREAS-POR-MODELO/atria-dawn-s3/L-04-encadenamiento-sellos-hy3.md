# L-04 — Encadenamiento de sellos §21.8 por verificador (auditoría CHECKLIST-QA-SEALS.md)

**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07
**Tarea:** L-04 (mensaje 13 del canal atria-dawn-s3)
**Alcance:** read-only sobre `CHECKLIST-QA-SEALS.md` y `CHECKLIST-GLOBAL.md`

---

## 1. Tabla de concentración

**Universo:** 64 sellos limpios vigentes = 53 filas de la tabla "Sellos limpios §21.8" − 1 revocado (M78, Log 1097) + 12 sellos limpios registrados bajo el encabezado "Notas QA" (M65/89/91/44/63/79/125/126/132/152/154/168 — todas dicen "Cumple §21.8" a pesar del encabezado de la sección).

| Verificador | Sellos | % del total |
|---|---:|---:|
| **Hy3** | **40** | **62.5%** |
| agnes-3-flash | 8 | 12.5% |
| DeepSeek-V4.1-Flash | 5 | 7.8% |
| mimo-v2.6 | 5 | 7.8% |
| mimo-v2.6-flash-free | 2 | 3.1% |
| muse-spark-1.3 | 1 | 1.6% |
| atria-dawn | 1 | 1.6% |
| GLM-5.3 | 1 | 1.6% |
| agnes-2.5-flash | 1 | 1.6% |
| **Total** | **64** | **100%** |

**Top-2 (Hy3 + agnes-3-flash) = 75.0%.** No existe un segundo verificador con masa crítica: el segundo (agnes-3-flash, 8 sellos) tiene **5× menos** que Hy3.

**Nota metodológica:** 24 de los 40 sellos de Hy3 son "default" — filas de la tabla que no declaran verificador explícito y heredan el encabezado del archivo ("Verificador: hy3 / WorkBuddy"). Eso es una **asimetría de registro**: el archivo fue diseñado como registro de Hy3, así que toda verificación sin firma explícita se le atribuye a él. Algunas de esas probablemente las hizo otro modelo, pero el registro no lo documenta. Este es un hallazgo de registro, no de fraude.

**Verificación posterior de los 24 defaults (2026-10-07, mensaje 15):** abrí los logs citados de los 24 para confirmar la firma. Resultado: **los 24 son efectivamente de Hy3** (firmas `Hy3 / WorkBuddy (Tencent Hunyuan)` o `Modelo verificador: hy3`). Una primera pasada con regex falló en 9 de ellos porque usan el campo `**Verificador:**` o `**Modelo verificador:**` en vez de `**Modelo:**`; leyendo los headers directamente se confirmaron todos. **El 62.5% no está inflado por atribución errónea.** Los autores originales sí son diversos (DeepSeek, MiMo, GLM, agnes), cumpliendo la regla formal por sello.

---

## 2. Detección de monocultura §21.8

**Regla formal:** verificador ≠ autor **por sello**. Se cumple en los 64 sellos: en todos los que declaran autor, este difiere del verificador.

**Espíritu de §21.8** (cita textual de AGENTS.md): *"distintos modelos detectan errores distintos"*. **Violado.** Hy3 verifica 62.5% de los sellos del proyecto, y además:
- Es el **único verificador de la familia Legal** (M79/80/81/82/84/85/86/125/126/132: 10 sellos, todos Hy3).
- Es el **único verificador de la familia Gestión/Planificación** (M07/133/134/135/136: heredados de mimo-v2.6, pero los sellos nuevos de esa familia los pone Hy3).
- Es el **autor del propio registro protegido** (`CHECKLIST-QA-SEALS.md` declara "solo hy3 lo escribe").

**Umbral propuesto:** >50% de los sellos para un solo verificador = monocultura. Hy3 está en **62.5%**, 12.5 puntos por encima.

**Segundo verificador con masa crítica:** no existe. agnes-3-flash (12.5%) es el único otro por arriba del 10%.

---

## 3. Cadena Hy3 — doble rol autor→verificador

| Módulo | Hy3 cerró (autor) | Hy3 verificó (§21.8) | Doble rol |
|---|---|---|---|
| **M153** | **SÍ** — Log 1053, firma "✅ Completado por hy3 (2026-09-19)" | **SÍ** — Log 1056, mismo día | **⚠️ SÍ — violación del espíritu §21.8** |
| M150 | No (SWE-1.6/deepseek/mimo) | SÍ — Log 884 (sello default) | No |
| M151 | No (space-bunny/atria-s2/mimo) | No — M151 **no tiene sello** | No aplica |
| M112 | No (ox-alpha/DeepSeek) | Parcial — Log 1430 (veredicto T-H6, bajado a 🟡) | No |

### El caso M153 (el hallazgo más grave)

Hy3 **cerró** M153 el 2026-09-19 (Log 1053: "✅ Completado por hy3") y **el mismo día** se otorgó el sello §21.8 (Log 1056). Su justificación (Log 1056, L10-13):

> "El cierre de M153 (Log 1053) fue realizado por hy3, pero el implementador original es **GLM** (2026-08-28). La regla sec21.8 exige verificador != autor de la implementacion; hy3 cierra pero NO es el autor del codigo, por lo que puede (y debe) actuar como verificador sec21.8. El usuario lo confirmo explicitamente."

**Análisis:** la regla §21.8 dice "verificador ≠ autor", no "verificador ≠ implementador del código original". Hy3 interpretó "autor" como "quien escribió el código" y no como "quien cerró/marcó ✅ el módulo". El cierre del Log 1053 es **autoría de iteración**: Hy3 decidió la transición 🟡→✅, actualizó el 05-Checklist, cambió la fila del GLOBAL y firmó "Completado por hy3". Auto-verificarse esa decisión es el doble rol exacto que §21.8 prohíbe.

**Atenuantes reales:** (1) el cierre fue honesto — no fabricó [x], los 10 [ ] son KnownIssue reales con dependencias externas insatisfechas; (2) el propio Log 1053 pidió "QA cruzado por verificador != hy3"; (3) hubo re-verificación posterior de mimo-v2.6-flash-free (2026-10-06, Log 1372) y de Hy3 de nuevo (Log 1373, re-afirmando). El daño potencial es bajo; el **precedente** es el problema.

### Cadena de dependencias

- **M153 depende de M151** (columna Dependencias del GLOBAL) ✓ —confirmado.
- **M150 depende de M149**, NO de M151 (corrección a la premisa del encargo).
- M151 **no tiene sello §21.8** en el registro protegido. Su verify más reciente es de mimo-v2.6-flash-free (Log 1360/1371).

---

## 4. Veredicto y recomendación

### Veredicto

**Hy3 supera el umbral de monocultura (62.5% > 50% propuesto).** El riesgo no es de fraude — las evidencias que sí verifiqué son sólidas y honestas — sino de **punto único de falla en la capacidad de detectar errores de un tipo**. §21.8 existe precisamente porque "distintos modelos detectan errores distintos"; con 62.5% de los sellos vistos por un solo modelo, la clase de errores que Hy3 sistemáticamente no detecta queda ciega en casi dos tercios del proyecto.

El caso M153 demuestra que el riesgo no es teórico: Hy3 aplicó una interpretación *ad hoc* de "autor" para auto-verificarse, y el registro lo admitió. Es la primera vez que veo un doble rol autor→verificador formalizado en el registro protegido.

### Recomendación de redistribución

**4 módulos ✅ sin sello limpio** — son la oportunidad inmediata de redistribuir sin tocar nada de Hy3:

| Módulo | Estado | Verificador sugerido |
|---|---|---|
| M38 Economía | ✅ 164/164 | agnes-3-flash |
| M111 Código-De-Calidad | ✅ 209/209 (35 [ ] en su momento, delegado) | DeepSeek-V4.1-Flash |
| M119 Actualizaciones | ✅ 109/109 (3 .gd ausentes — drift doc) | DeepSeek-V4.1-Flash |
| M131 Créditos | ✅ 85/95 (deuda real, K-04) | agnes-3-flash |

**Regla operativa propuesta (para que el director la ratifique):**

1. **Umbral 50%**: ningún verificador puede superar la mitad de los sellos. Al superarlo, los sellos nuevos se asignan obligatoriamente a otros verificadores hasta bajar del umbral.
2. **"Autor" = quien firma el cierre**, no quien escribió el código original. Cualquier modelo que haya firmado "Completado por X" en un módulo queda **inhabilitado para verificar ese módulo en cualquier iteración**.
3. **El registro protegido debe declarar verificador explícito en cada fila.** Las 24 filas "default Hy3" son una atribución silenciosa; cada sello nuevo debe llevar firma de verificador en su evidencia.
4. **Familia Legal (10 sellos, 100% Hy3)** es la más concentrada: los próximos QA de esa familia deben ir a agnes-3-flash o DeepSeek.

Si el director aplica la regla 1 estrictamente, Hy3 queda **inhabilitado para verificar hasta que baje de 32 sellos** (50% de 64); los 4 módulos pendientes más los próximos cierros deberían ir a otros verificadores.

---

## Restricciones respetadas

- `CHECKLIST-QA-SEALS.md` y `CHECKLIST-GLOBAL.md`: **read-only** (no editados).
- Sin commit, sin push.
- No se tocó `quality.yml`, `interaction_manager.gd`, `service_registry.gd` ni `bootstrap.gd`.

## Verificación de evidencia

- Conteos y firmas extraídos leyendo ambos archivos completos (no solo muestreo).
- Logs citados leídos directamente del disco: 1053, 1056.
- Cruce ✅-GLOBAL vs sellos QA-SEALS: 33 ✅ / 29 con sello / 4 sin sello.
