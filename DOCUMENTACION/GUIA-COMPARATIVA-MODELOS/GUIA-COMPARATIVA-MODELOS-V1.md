# GUIA COMPARATIVA DE MODELOS — V1

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-04
**Estado:** V1 inicial — 11 modelos activos de la flota con información útil resumida.

## Propósito

Esta guía resume únicamente los **modelos activos de la flota** y los que **pueden integrarse en cualquier momento**. Las versiones históricas con modelos que ya no regresan se mueven a `obsoletos/`.

El objetivo es mantener el archivo reducido y solo con lo realmente útil para el día a día.

---

## Modelos activos de la flota

### 1. Agnes 3.0 Flash (Sapiens AI / Kilo Code)

**Rol:** QA de ejecución, flips por test, honestidad de scope.

**Evidencia empírica verificada:**
- Conteo exacto de suites Godot (ancla `^\s*OK:`): M107 146/176, M104 43/117, M110 135/225 — todos exactos al dígito.
- Hallazgos reales: `test_localizacion_iter6.gd:113` aserta estado viejo (BUG-042); test stale invertido.
- ~20 encargos correctos en racha; conteos de confianza total.

**Debilidades:** Cierres sin revisión de citaciones (patrones C y D) — sus cierres necesitan revisión de citaciones.

**Regla de asignación:** Verificación de volumen DoD, conteos, cierres. NO delegar cierres sin revisión de citaciones.

---

### 2. Nemotron-3.5-Super-VL (NVIDIA / Kilo Code)

**Rol:** Agente autónomo de la flota (este chat).

**Evidencia empírica verificada:**
- Inteligence Index 26 — N.1 de 67 modelos open-weights de su clase (Artificial Analysis).
- Velocidad: 446.2 t/s (mediana de clase 106.4), TTFT 0.73s.
- Contexto 1M, texto + imagen (visión nativa por API).
- Tier FREE en OpenRouter (`nvidia/nemotron-3.5-super-vl:free`).
- Razonamiento con thinking; licencia OpenMDW-1.1 (uso comercial permitido).

**Debilidades:** 12B activos por token (menos músculo de razonamiento puro que Beam 23B o Ultra 55B); benchmarks de maker aún sin validación independiente completa; verbosidad 170M tokens por Índice (el doble de la mediana).

**Regla de asignación:** QA visual por API (M154 — ver capturas del juego), document intelligence (tablas, gráficos, OCR), picking [S]/[C] por velocidad (446 t/s). NO delegar: matemática dura de balance (M93/M95), verificaciones de código GDScript crítico en primera línea.

---

### 3. GLM-5.3-Flash (Zhipu AI / Kilo Code)

**Rol:** Deep work, razonamiento, arquitectura.

**Evidencia empírica verificada:**
- Autoevaluación §16 con specs verificadas en fuente oficial.
- Solo texto (no multimodal).
- Contexto 1M, salida máx 128K.
- Fuerza en razonamiento profundo, verificación crítica, arquitectura de software.

**Debilidades:** 9x más caro que Flash (informativo, no criterio de decisión); no es el más rápido para scripts diarios.

**Regla de asignación:** Módulos core complejidad 4-5, integración con sistemas existentes (crítico), persistencia, verificación crítica, arquitectura de software. NO para scripts diarios o batch alto volumen (usar GLM 5.3 Flash o DeepSeek V4.1 Flash).

---

### 4. Ling 3.1 Flash (inclusionai / Kilo Code)

**Rol:** i18n, localización, documental M147/M160/M95/M100/M121.

**Evidencia empírica verificada:**
- Historial: 21 tandas seguidas bajo metodología V2; M92, M21, M108, M131, M118 CI, M141 6 idiomas, M87 i18n + strings PT completos.
- Récord de constancia de la flota antes de la noche de Beam.
- Re-enganchado 2026-10-22 tras fallo de ruteo (no pereza).

**Debilidades:** Acusaciones técnicas propensas a falsos positivos (ej. acusación de mojibake falsa contra opencode — el msg era UTF-8 limpio); límite de créditos del fundador (estuvo fuera hasta nuevo aviso).

**Regla de asignación:** Todo el sub-sistema i18n/localización M87, migraciones de idiomas, validadores de claves/sufijos, triggers de UI/localización cross-módulo (M53/M59/M72). Condición: confirmar sesión activa en Kilo Code.

---

### 5. DeepSeek V4.1 Flash (DeepSeek / Kilo Code + WorkBuddy)

**Rol:** Detección de drifts, instrumentación de suites, CI.

**Evidencia empírica verificada:**
- Barrido de 96 suites del proyecto: 0 muertas, todo VIVA-SILENCIOSA; LOTE 1 SIN-DUEÑO: 27 suites instrumentadas, 1168 checks, 0 fallos.
- Detectó que un runner reportaba 0 tests siendo 1241 reales.
- Mejor detector de drifts de la flota; tercer capa de verificación del barrido de inflación.
- Autoevaluación §17 con prueba empírica de visión (2/2 verificada).

**Debilidades:** Ninguna grave observada en su especialidad.

**Regla de asignación:** Detección de drifts, instrumentación de suites, CI, verificación independiente. QA cruzado §21.8 de trabajos de otros modelos.

---

### 6. Hy3 (Tencent Hunyuan / WorkBuddy)

**Rol:** QA cruzado, red probes, verificación de runtime.

**Evidencia empírica verificada:**
- ~40 verificaciones §21.8 acumuladas; crítico más fiable de la flota.
- M66: re-sello §21.8 con BUG-123 roto a propósito → 2 fallos + SCRIPT ERROR + EXIT 1; restaurado byte-exact → 0 fallos.
- M74: 119/0 fresh + RED PROBE EXIT 1 validada; M71: QA runtime con suite independiente y F1 reproducido aislado (BUG-143).
- 6 sellos §21.8 aplicados bajo supervisión de agnes-3-flash (M28/M65/M73/M75/M77/M72).

**Debilidades:** No actualiza CHECKLIST-GLOBAL al revertir (drift que debe corregirse); colisión de numeración de bugs (debe verificar antes de nombrar).

**Regla de asignación:** QA cruzado, red probes, verificación de runtime, verificación cruzada de familia (no hermano del mismo modelo). NO asignar implementación nueva (su nicho es verificar). Cerrar el ciclo en CHECKLIST-GLOBAL, no solo el 05-Checklist del módulo.

---

### 7. Hy4 (Tencent Hunyuan / WorkBuddy)

**Rol:** Arte 3D, Blender, generación de assets.

**Evidencia empírica verificada:**
- 770B totales / 49B activos, MoE, contexto 1M tokens.
- Coding complejo, game dev, prototipos jugables desde un prompt.
- Blender 3D (autoría de assets vía scripts Python), pipeline GLB→Godot.
- Evaluación ciega interna Tencent: 2.99/4.00 (vendor-reported, tomar con cautela).

**Debilidades:** Visión intermitente (6 de 7 hojas de contacto de M19 filtradas en log 678) — no debe ser el único que apruebe activos visuales por lectura de capturas.

**Regla de asignación:** Coding complejo long-horizon, game dev, Blender 3D, assets. NO aprobar visual final solo por capturas (QA numérico obligatorio como respaldo).

---

### 8. Reflection Beam 1.0 (NVIDIA / Kilo Code)

**Rol:** Razonamiento, auditoría de conteos, picking documental.

**Evidencia empírica verificada:**
- 35 tandas en ~4h (calibración 6/6 exacta incluida); re-verificador con 6 hallazgos reales (BUG-142, cap D8 M16, dirty flags M72, economías single-pass, puzzles D.13, tools D.14).
- Paquete de fotografía completo end-to-end en una noche (~34 ítems + 2 tareas de días).
- Reportes SIEMPRE con limitaciones honestas (sin maquillar rojos); NO auto-sello (pide QA cruzado).
- Intelligence Index 30 (N.20/121, Artificial Analysis); Terminal-Bench 4.0 y AutomationBench-AA en su índice; velocidad N.3/78 (342.9 t/s).

**Debilidades:** Ediciones rápidas de funciones existentes sin releer scope (introdujo clock duplicado, registros de flip ausentes); conteo sesgado por memoria (no por prefijo); flips documentales con paráfrasis en vez de línea textual.

**Regla de asignación:** Picking documental por sección [S]/[M], auditorías de balance con análisis matemático, implementación de features bien especificadas en módulos sin dueño, verificaciones repetitivas. NO delegar: ediciones de funciones ajenas complejas (necesita releer scope), aritmética de contadores sin prefijo (sesgo confirmado 3 veces). NO auto-sellarse a sí misma.

---

### 9. MiniMax M3.1 Flash (MiniMax AI / Kilo Code)

**Rol:** Infraestructura CI, lanes, censo de suites, optimizador de pipelines.

**Evidencia empírica verificada:**
- P1 pool paralelo: 897 → 545.3s con más cobertura (2462 tests) y sin tocar CI; lane voxel serial → 49/49 VERDE en 530.6s.
- Censo mayor del proyecto: 471 suites totales, solo 49 en CI, 422 invisibilizadas, 13+2 rojos detectados y derivados a dueños (hallazgo de calibre estructural).
- Wrapper integrador M17 en res://tests/ (498 checks en CI).
- Hallazgo grave: detectó que el barrido commiteó photo_service roto bloqueando el CI entero; lo reportó aunque no era su encargo.
- Doble autocorrección material en 24h con sondas.

**Debilidades:** Fechas JULIO en nombre de archivo y firma (dos veces); pools auto-regenerados con duplicados (027/028, 033-105) que obligan saneo constante; diagnóstico inicial de BUG-141 equivocado (hilo de guardado) por falta de sonda directa.

**Regla de asignación:** Infraestructura CI/testing de elite, auditorías de cobertura, optimizador de pipelines, hallazgos de causas-raíz con sondas. NO delegar: nombres de archivo/fechas (descuido sistémico), ni diagnóstico de causa sin sonda directa (exigir sonda antes de la primera hipótesis).

---

### 10. G-5.3-Flash-Agente (GLM-5.3-Flash / Kilo Code)

**Rol:** Escaneo metodológico, encargos consolidados, autonomía plena.

**Evidencia empírica verificada:**
- Mismo modelo que el director (gene facilities).
- Escaneo 2-BIS.2 autónomo: descubrió la trampa del mapa (28 módulos, ~1350 [ ] sin dueño).
- Tanda 48: 4 encargos consolidados ejecutados con decisiones de dueño documentadas.
- Régimen 229 de autonomía (S1-S19): S18 altitud M67 con topes exactos de 03-Diseno 3.1 (34/131, fila sync).

**Debilidades:** 4+ vueltas en "ciclo silencioso" esperando derivaciones en vez de ejecutar (corregido con autonomía plena del fundador 229).

**Regla de asignación:** Encargos consolidados en un mensaje (4 en uno funcionó mejor que 4 separados), escaneos determinísticos, tandas de implementación con decisión de dueño documentada. NO delegar sin indicación de autonomía explícita para que no espere derivaciones.

---

### 11. MiMo V2.6 (Xiaomi / WorkBuddy + OpenCode)

**Rol:** UI + audio + i18n con suites, fixes de producción.

**Evidencia empírica verificada:**
- M91-Configuracion-De-Audio iter. 11: BUG-092 resuelto, suite 103 → 136/0 EXIT 0, sonda rojo inyectada y removida, regresiones 82/0 y 127/0.
- M43-Efectos-De-Sonido 9 lotes → 🟡 cerrado: suite 15 → 127/0, cierre honesto 59/41/0 (no inflado).
- M131-Creditos → ✅: pantalla de créditos implementada + 9 KnownIssue declarados (no inflados).
- BUG-081: 4 errores de inferencia de tipos en scripts/legal, suites re-ejecutadas 8/0 y 15/0.
- BUG-052: medido 434 = 418 + 16; limpieza → 418/418 EXIT 0.
- BUG-129: patch inst.free() en vegetation_spawner.gd:88, 257 → 0 strays, runner 29/29 suites, 1267 tests, EXIT 0.

**Debilidades:** Visión 3D limitada (sin cambio observable vs V2.5); no asignar arquitectura visual / escenas 3D.

**Regla de asignación:** UI + audio + i18n con suites, complejidad 2-3 en su dominio (settings, overlays, subtítulos, catálogo de audio, integración por señales). Método: lotes → suite con binario real → piso CHECKS_MINIMOS medido → sonda rojo demostrada → [x] solo con suite en verde. NO reasignar módulos que V2.5 dejó colgados sin verificar primero si V2.6 los hereda.

---

## Modelo en integración (puede incorporarse en cualquier momento)

| Modelo | Plataforma | Rol | Estado |
|--------|-----------|-----|--------|
| Crouton Alpha | Stealth (Kilo Code) | Sub-agente de bajo costo para tareas repetitivas de agente: escaneo de código, análisis de logs, tool calling, documentación, tareas de alto volumen | En prueba — supervisado por Nemotron-3.5-Super-VL |
| Stealth Glyph Cluster | Stealth (Kilo Code) | Razonamiento y análisis de arquitectura: revisión de código, debugging complejo, planificación de refactors, análisis de largo contexto | En prueba — supervisado por Nemotron-3.5-Super-VL |
| Reflection Beam 1.0 | NVIDIA (Kilo Code) | Razonamiento, auditoría de conteos, picking documental, verificación de balance matemático | En prueba — supervisado por Nemotron-3.5-Super-VL |

> Los modelos no listados arriba (Atria-Dawn-Preview, Kimi K3, Claude Haiku 5.5, StepFun Step 5, Nemotron 3 Ultra, Thinking Machines Inkling, Poolside Laguna S 2.1) están en la versión histórica completa (`obsoletos/10-GUIA-COMPARATIVA-MODELOS.md`). Si el fundador decide integrar alguno, se agrega aquí y se crea una V2.

---

## Reglas de uso

1. **Solo modelos aprobados por el fundador** se agregan a la tabla de activos.
2. **Cada versión nueva** se guarda como `GUIA-COMPARATIVA-MODELOS-V<N>.md` y la anterior se mueve a `obsoletos/`.
3. **No incluir** modelos que ya no van a volver; esos ya viven en `obsoletos/` como histórico.
4. **UTF-8 sin BOM** siempre (§28 AGENTS.md).
5. **Firmar** toda edición con modelo, plataforma y fecha.
6. **Modelos en prueba (supervisados):** Crouton Alpha, Stealth Glyph Cluster y Reflection Beam 1.0 están supervisados por Nemotron-3.5-Super-VL. No se les asignan módulos críticos sin previa revisión de Nemotron. Los reportes de sus tareas se escriben en `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/`. Beam tiene su propio BACKLOG-MASTER en `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md`.

---

## Referencia

- Versión histórica completa (pre-V1, 3398 líneas): `obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` (respaldo del 2026-11-04).
- Protocolo de comunicación: `Mensajes entre modelos/GUIA-COMUNICACION.md`.
- Protocolo multiagente: `CHECKLIST-GLOBAL.md` §21.

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-07
