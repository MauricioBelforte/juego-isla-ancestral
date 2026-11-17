# GUIA COMPARATIVA DE MODELOS — V1

**Modelo:** Gemini 3.8 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-17
**Estado:** V1 — 12 modelos activos de la flota con información útil resumida.

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

## Modelo activo — Crouton Alpha (supervisado)

### Crouton Alpha — Sub-agente de bajo costo, alto volumen (RETIRADO — ya no disponible gratuitamente)

| Campo | Valor |
|-------|-------|
| Modelo | Crouton Alpha (`stealth/crouton-alpha`) |
| Plataforma | Stealth (Kilo Code / OpenRouter) |
| Tipo | Razonamiento ligero para agentic workflows |
| Contexto | 1,048,576 tokens (entrada) / hasta 943,718 (salida) |
| Modalidades de entrada | Texto, imagen, video, archivo (PDF), audio → salida solo texto |
| Razonamiento | Siempre ON, 6 niveles (default `max`) |
| Tool calling | Soportado (`tool_choice: auto` solo); structured outputs (JSON schema) |
| Precio | $0 input / $0 output (preview, retirada) |
| Proveedor | Anónimo (terceros, no revelado) |
| Data | Prompts/completions pueden ser retenidos por el proveedor, no usados para entrenamiento |
| Liberado | 2026-11-03 |
| Estado | **Retirado — ya no disponible gratuitamente** |

**Historial de trabajo completado:**
- 28 reportes entregados en scripts/core/, scripts/ui/, scripts/npc/, scripts/ia_npc/, scripts/inventario/, scripts/coleccionables/, scripts/logging/
- 114 archivos .gd escaneados en una sola pasada, 23 problemas verificados (2 imports sin usar, 7 parámetros sin usar, 11 funciones vacías, 3 vars miembro sin usar), 88% código limpio
- 13 problemas UI detectados (mouse_filter, CanvasLayer, debug_menu)
- 100 archivos .gd analizados, 88% código limpio
- 0 referencias rotas en 833 archivos .import, 69 .tscn, 479 .tres, 1586 .gd

**Estado final:** Retirado del flujo activo el 2026-11-12. No se le asignan nuevas tareas.

---

### Stealth Glyph Cluster — Razonamiento y análisis de arquitectura (supervisado)

| Campo | Valor |
|-------|-------|
| Modelo | Stealth Glyph Cluster (`stealth/glyph-cluster`) |
| Plataforma | Stealth (Kilo Code / Vercel AI Gateway) |
| Tipo | Razonamiento para coding y largo contexto |
| Contexto | 256,000 tokens (entrada) / 256,000 (salida) |
| Modalidades de entrada | Texto solo |
| Razonamiento | Sí, niveles: low, medium, high, xhigh |
| Tool calling | Soportado (funciones definidas por el usuario) |
| Structured outputs | No soportado |
| Precio | $0 input / $0 output (preview, puede retirarse sin aviso) |
| Proveedor | Anónimo (terceros, no revelado) |
| Data | Prompts y respuestas pueden ser retenidos y usados para entrenamiento; Zero Data Retention no disponible |
| Liberado | 2026-10-07 |
| Estado | **Activo formal — supervisado por Nemotron-3.5-Super-VL** |

**Benchmark público (stealthmodels.com, 09-oct-2026):** GPQA Diamond 56.4% (31/55 correctos) en subset de 55 preguntas de biología, química y física.

**Fortalezas (observadas empíricamente, 20 reportes escritos):**
- Análisis de arquitectura EventBus/ServiceRegistry (detectó acoplamiento fuerte en bootstrap, 12 señales huérfanas/a medio cablear, validaciones faltantes críticas en `ServiceRegistry.register/unregister`)
- Análisis de sistema de guardado (pipeline maduro JSON determinista, `.tmp→.save` atómico, backups rotados, HMAC-SHA256, brechas: contratos paralelos `ISaveProvider`/`ISaveable`, migración por sección ausente, clave HMAC en `user://` accesible)
- Análisis de sistema de audio (SFXManager pool lógico sin players reales, ducking directo sobre bus, reproducción dispersa, falta de `AudioBusLayout` versionado)
- Análisis de input (fragmentación entre `ControlInput` y polling directo por `KEY_*`, conflicto `interactuar`/`equipamiento` compartiendo `KEY_E`, 12 señales sin uso)
- Análisis de inventario (descarte de UI llama a `remove_item(0, índice)` con firma incompatible; `split_stack` no valida `stack_max` ni instancia; `swap_items` permite sobreescribir slots bloqueados)
- Análisis de combate/salud (`HealthComponent` no valida daño negativo/nulo/NaN, muerte repetible sin `is_dead`, señal `died` desalineada con `IDamageable`)
- Análisis de misiones (dos modelos de quest paralelos `SecondaryStoriesService` vs `QuestChainService` sin unificación, `MisionInvariant` no conectada al runtime)
- Análisis de partículas/VFX (director "mudo" por señal `evento_generico` inexistente, desalignación presupuesto pool 1200 vs cámara 500)
- Análisis de IA/NPC (`InteractState` huérfano, `ReactState` con patrón de salida riesgoso `exit()` desde `tick()`, O(N²) en detección de NPCs cercanos, NPCs no reaccionan al jugador)
- Análisis de logros (stats incorrectos para agricultura/minería: `regalos_dados` en lugar de `cultivos_plantados`/`minerales_extraidos`; `viajes_realizados` en lugar de `dias_jugados`; logros probablemente inalcanzables)
- Análisis de economía (venta con saldo en `MAX_SALDO`: items removidos pero sin acreditación de AO — pérdida de valor; contratos de transacción void)
- Análisis de UI (doble capa de diálogo `DialogLayer` M53 + `DialogueUI` autocontenida — riesgo de inconsistencia; feedback insuficiente al jugador al fallar validación de grafo)

**Debilidades (observadas empíricamente):** contexto menor (256K vs 1M de Crouton/Beam), solo texto (no multimodal), no soporta structured outputs, data policy más restrictiva (puede usarse para entrenamiento).

**Regla de asignación:** revisión de código, debugging complejo, planificación de refactors, análisis de largo contexto, arquitectura de sistemas, detección de acoplamiento y dependencias circulares. NO asignar: tareas que requieran visión/imagen, tareas de alto volumen repetitivo (usar Crouton Alpha), análisis de contadores/matemática (usar Beam).

**Método de trabajo:** análisis profundo → citas de archivo:línea → 2 mejoras de diseño concretas con código → conclusión técnica.

**Pruebas empíricas (Isla Ancestral, 2026-11-07 a 2026-11-09):**
- Analizó `event_bus.gd` y `service_registry.gd`: detectó acoplamiento fuerte en bootstrap (catálogo hardcodeado, resolución mixta `/root`), 12 señales sin uso o a medio cablear, sin dependencias circulares, validaciones faltantes en `register`/`unregister`. Propuso 2 mejoras de diseño concretas y accionables.
- Analizó sistema de guardado: validó pipeline atómico y HMAC-SHA256; detectó contratos paralelos y migración faltante.
- Analizó input: documentó fragmentación entre `ControlInput` (autoload M57) y polling directo en `player.gd`; conflicto `interactuar`/`equipamiento` en `KEY_E`; 12 señales sin uso en `EventBus`.
- Analizó inventario: encontró bug en descarte de UI (`remove_item(0, índice)` firma incompatible con el servicio), `split_stack` sin validar `stack_max`/instancia, `swap_items` sobreescribiendo slots bloqueados.
- Analizó misiones: detectó dos modelos de quest paralelos no autoloaded, `MisionInvariant` sin conexiones runtime, riesgo de misiones incompletables.
- Analizó partículas/VFX: detectó director "mudo" por señal `evento_generico` inexistente, desalignación presupuesto pool 1200 vs cámara 500, churn de materiales en rutas calientes.
- Analizó IA/NPC: detectó `InteractState` huérfano, `ReactState` con patrón de salida riesgoso, O(N²) en detección de NPCs cercanos por frame, NPCs no reaccionan proactivamente al jugador.
- Analizó logros: detectó stats incorrectos (`regalos_dados` para agricultura/minería, `viajes_realizados` para días jugados), logros probablemente inalcanzables, faltan conexiones para agricultura/minería.
- Analizó economía: detectó venta con saldo en `MAX_SALDO` pierde items, contratos de transacción void.
- Analizó UI: detectó doble capa de diálogo, feedback insuficiente al jugador al fallar validación de grafo.

---

### Reflection Beam 1.0 — Razonamiento, auditoría de conteos y documentación (modelo de pago)

| Campo | Valor |
|-------|-------|
| Modelo | Reflection: Beam 1.0 (`reflection/beam-1.0-501b-a23b`) |
| Plataforma | NVIDIA (Kilo Code / OpenRouter / Hugging Face) |
| Tipo | Sparse Mixture-of-Experts (MoE) para razonamiento y agentic workflows |
| Arquitectura | 501.3B parámetros totales, 23.4B activos por token; 52 capas (3 densas + 49 MoE); 256 expertos, 8 enrutados por token; atención Gated GQA + Sliding Window + NoPE full attention cada 6 capas |
| Contexto | 1,048,576 tokens (entrada) / hasta 131,072 (salida) |
| Modalidades de entrada | Texto solo |
| Razonamiento | Siempre ON, niveles: minimal, low, medium, high, xhigh, max |
| Tool calling | Soportado (grammar dedicada) |
| Structured outputs | Soportado |
| Precio | $0.25/M input / $1.00/M output (Cache Read $0.05/M) — **MODELO DE PAGO** |
| Proveedor | Reflection (abierto, Apache 2.0) |
| Liberado | 2026-10-16 |
| Estado | En prueba — supervisado por Nemotron-3.5-Super-VL **(pendiente: fundador evalúa si se mantiene por ser de pago)** |

**Fortalezas (observadas empíricamente):** auditoría de fórmulas de balance y progresión (auditó `price_manager.gd`, `economy_manager.gd`, `player_profile.gd`, `progression_manager.gd`; detectó magic number `0.02`, verificó topes de descuento y venta, 0 divisiones por cero), auditoría de contadores y totales (detectó `depositar_monedas(total=0)` inflando reputación, caché desincronizada en `coleccionables_manager`, off-by-one en umbrales), verificación de CHECKLIST-GLOBAL.md (encontró 10-12 bloqueos 🔵 huérfanos, 5 IDs duplicados, ~45 filas con drift interno, ~15 filas con progreso=total pero sin ✅), análisis de documentación (AGENTS.md §24 describe Unity/C# cuando el proyecto es Godot 4.x; director vigente vs histórico en §10.2/§10.3), verificación de assets `.import`/rutas rotas (833 `.import`, 69 `.tscn`, 479 `.tres`, 1586 `.gd`: 0 referencias rotas reales), manejo de errores en GDScript (102 archivos de producción con I/O sin manejo, 3 `assert` totales, 78 `push_warning` sin acción), análisis de escenas principales (load_steps desfasado en 4 escenas, NPCs fuera de centro isla).

**Debilidades (observadas empíricamente):** más lento y costoso que Crouton Alpha para tareas simples, no es multimodal (texto solo), overkill para escaneos estáticos simples.

**Regla de asignación:** auditoría de consistencia y conteos, verificación de balance matemático, picking documental, verificación de CHECKLIST-GLOBAL.md, análisis de documentación, manejo de errores, verificación de assets y escenas. NO asignar: escaneo estático masivo de código (usar Crouton Alpha), análisis de arquitectura profunda (usar Glyph Cluster).

**Método de trabajo:** análisis cuantitativo → tablas de hallazgos con archivo:línea → 2 acciones de corrección concretas → conclusión ejecutiva.

**Pruebas empíricas (Isla Ancestral, 2026-11-07/08):**
- Auditó fórmulas de balance en 7 archivos: encontró 1 magic number (`0.02` en `price_manager.gd:496`), verificó 0 divisiones por cero, confirmó topes de descuento (15% amistad + 15% volumen, tope 20%) y venta (60% de compra).
- Auditó contadores: encontró `depositar_monedas(total=0)` inflando reputación, caché desincronizada en `coleccionables_manager.gd`, off-by-one en `price_manager.gd:263,543`.
- Verificó CHECKLIST-GLOBAL.md: 10-12 bloqueos 🔵 huérfanos (M158 con 64 días sin actividad), 5 IDs duplicados (48, 115, 127, 139, 148), ~45 filas con drift interno de progreso.
- Auditó documentación: encontró que AGENTS.md §24, §14, §18, §22 describen Unity/C# (proyecto es Godot 4.x/GDScript); director vigente (GLM-5.3 Flash-Director) vs histórico (De-Director V4.1) desalineado en §10.2/§10.3.
- Verificó 833 `.import`, 69 `.tscn`, 479 `.tres`, 1586 `.gd`: 0 referencias rotas reales; 8 `.glb` en tests son fixtures intencionales.
- Auditó manejo de errores: 102 archivos de producción con I/O sin manejo, 3 `assert` totales, 78 `push_warning` sin acción. Propuso helper de resultado unificado y aserciones de desarrollo.

---

### ERNIE-5.5-Flash-Preview (Baidu) — Razonamiento de largo horizonte, análisis multimodal y modelado 3D

| Campo | Valor |
|-------|-------|
| Modelo | ERNIE-5.5-Flash-Preview (`baidu/ernie-5.5-flash-preview`) |
| Plataforma | Stealth/Baidu (Kilo Code / OpenRouter / Qianfan) |
| Tipo | Razonamiento de largo horizonte (TEMPO), análisis multimodal, modelado 3D, conocimiento profundo |
| Contexto | 1,048,576 tokens (entrada) / hasta 921,600 (salida) |
| Modalidades de entrada | Texto, imagen, video, audio → texto (según ficha del proveedor) |
| Razonamiento | Sí, TEMPO (test-time-scaled reasoning para largo horizonte) |
| Tool calling | Sí (funciones definidas por el usuario) |
| Structured outputs | Sí (JSON schema) |
| Precio | $0.28/M input / $1.13/M output (preview, puede retirarse sin aviso) |
| Proveedor | Baidu |
| Data | Prompts y respuestas pueden ser retenidos por el proveedor |
| Liberado | 2026-11-11 |
| Estado | **En flota (2026-11-13)** — nicho: **modelado de OBJETOS/props en Blender** (mobiliario, herramientas, decoración, estructuras pequeñas), **auditoría de assets por binario** (GLB/·blend: escala, normales, z_min, vértices, materiales) y **saneamiento de documentación**. Reporta a agnes-3-flash. |

**Benchmark público (Baidu, 2026-11-11):** Terminal-Bench 4.0 46.5%, DeepSWE v1.1 71.2%, AutomationBench 61.9%, APEX-Agents 1.1 64.2%, DRACO 84.9%, SpreadsheetBench V2 36.4%, OfficeQA Pro V2 67.9%. Benchmarks de terceros: Terminal-Bench-Science 21.0, NL2Repo-Bench 64.8, Toolathlon-Verified 79.0, MCP-Atlas 84.6, BrowseComp 87.4, HLE sin tools 46.4, BlenderWorld text-only 79.0.

**Fortalezas (observadas en investigación web):**
- Razamiento de largo horizonte (TEMPO): descompone tareas complejas en macro-steps con auto-evaluación entre cada paso
- Contexto de 1M tokens: ideal para análisis de grandes bases de código sin fragmentar
- Multimodal de entrada: texto, imagen, video, audio → texto (ideal para revisar texturas, modelos 3D, escenas .tscn con imágenes, documentación con diagramas)
- Modelado 3D: capacidades demostradas en Blender y CAD (paramétrico, espacial, generación de objetos 3D desde texto)
- Conocimiento profundo: documente, research, deep research (DRACO 84.9%)
- Código y agentic coding: Terminal-Bench 46.5%, DeepSWE 71.2%, Toolathlon 79.0

**Debilidades (observadas en investigación web):**
- Texto solo como salida (no genera imágenes, video, audio directamente; solo los entiende como entrada)
- Preview: entrenamiento no terminado, algunas capacidades pueden fallar, no hay benchmarks independientes verificados (todos son de Baidu)
- Precio de pago: $0.28/M input / $1.13/M output (no es gratuito como Crouton/Glyph)

**Regla de asignación:** tareas de razonamiento de largo horizonte, análisis multimodal (texturas, modelos 3D, escenas .tscn con imágenes), documentación con diagramas, modelado 3D procedural (Blender/CAD), deep research, tareas que requieren contexto de 1M tokens. NO asignar: tareas de salida de imagen/audio/video, escaneo estático masivo de código (usar Crouton Alpha), análisis de arquitectura pura (usar Glyph Cluster).

**Método de trabajo:** análisis profundo → citas de archivo:línea → 2 mejoras de diseño concretas con código → conclusión técnica. Para tareas de largo horizonte: descomponer en macro-steps con auto-evaluación entre cada paso.

### ⛔ NO PERSONAJES (directiva del fundador, 2026-11-14)

Se le encargó diseñar un NPC (Mayordomo del Pueblo, M161 §4.1). Resultado: el modelo
**no tiene precisión para diseño de personajes** — sin visión no puede juzgar proporción,
silueta ni si una pieza lee bien, y el intento (2 iteraciones) quedó con piezas mal
proporcionadas y superpuestas. Veredicto del fundador: **"no se te da bien el diseño de
personajes con precisión... te doy la creación de objetos pero no de personajes"**.

- **SÍ:** modelado procedural de **objetos** (props, mobiliario, herramientas, estructuras),
  con medidas verificadas numéricamente contra el asset del juego.
- **NO:** diseño de **personajes** (cuerpo, rostro, proporción, silueta, vestimenta ajustada),
  ni **QA visual** de ningún tipo.
- **Regla derivada:** si una tarea requiere juzgar cómo *se ve* algo, **no es para este modelo**.

### Verificado en ejecución (2026-11-13, ingreso a la flota)

**⚠️ Limitación dura confirmada:** el harness que ejecuta a ERNIE **no le pasa imágenes** — al abrir un render devuelve `Cannot read image (this model does not support image input)`. La ficha del proveedor declara multimodal, pero el canal de imagen no llega. Consecuencia: **no firma QA visual, no juzga estética, no lee PNG.** Entrega medición numérica y listado de sospechosos; la validación visual la firma un modelo con visión.

**Capacidades verificadas (no solo de ficha):**
- Parseo binario de GLB (chunk JSON + BIN) con bbox en **espacio mundo** aplicando matrices de nodo (TRS/`matrix`). Sin esto el bbox sale hasta 25× más grande: los assets usan `scale`/`translation` por nodo.
- Verificación de normales unitarias, `z_min`/`z_max`, alto/ancho/fondo por asset.
- Apertura de `.blend` ajenos en Blender vía `bpy.data.libraries.load` + depsgraph (sin pisar la sesión del usuario).
- Auditoría de los **490 GLB** de `game/isla-ancestral/assets/3d/` (184 alta / 154 media / 152 baja): **0/490 fuera de escala** (0,208–16,3 m), **0/490 con normales no unitarias**, **442/490 (90,2 %)** dentro de `Z_APOYO = 0,045 ±0,020`.
- Hallazgo propio: 5 assets se apoyan mal contra `get_height()` — `perla_ancestral` (−0,586 m), `globo_del_viento` (−0,336), `roca_pedernal` (−0,292), `roca_comun` (−0,109), `conejo` (−0,170). Causa raíz en `.blend`: la perla es un submarino con los **patines a −0,50 m** del origen.

## Reportes escritos

Carpeta: `Mensajes entre modelos/ERNIE-5.5-Flash-Preview/` (canal activo desde 2026-11-13; los reportes de la etapa de prueba quedaron en `REPORTES-Prueba-Paralela/`).

## Supervisión

**En flota desde 2026-11-13.** Recibe trabajo de `agnes-3-flash` (canal propio, pool `NUMEROS_DISPONIBLES.txt`). Ya no requiere revisión previa de Nemotron para tareas de su nicho; sí para cualquier cambio fuera de él. Razonamiento: high.

---

### Gemini 3.8 Flash (Google DeepMind) — Ingeniería de software de largo horizonte, agentes autónomos y análisis multimodal

| Campo | Valor |
|-------|-------|
| Modelo | Gemini 3.8 Flash (`gemini-3.8-flash` / `coarena/gemini-3-8-flash`) |
| Desarrollador / Proveedor | Google DeepMind / Google AI Studio / Vertex AI |
| Plataforma | Kilo Code / OpenRouter / AI Studio |
| Tipo | Modelo multimodal de alta velocidad y razonamiento adaptativo para ingeniería de software de largo horizonte, orquestación de agentes y flujos complejos |
| Contexto | 1,048,576 tokens (1M entrada) / hasta 65,536 tokens (64K salida) |
| Modalidades de entrada | Texto, imagen, video, audio, archivos (PDF) nativo |
| Modalidades de salida | Texto |
| Razonamiento | Thinking adaptativo con niveles configurables (`low`, `medium` [default], `high`). `minimal` no soportado. Test-time reasoning para verificar pasos intermedios. |
| Tool calling | Nativo avanzado: function calling paralelo, ejecución determinista de tools, verificación pre-tool y manejo de multi-turn sin prefill |
| Structured outputs | Sí (JSON schema nativo y tipos estrictos) |
| Herramientas integradas | Code Execution (Python sandbox), Computer Use, Context Caching, Google Search Grounding, File Search, URL Context |
| Precio | $0.75 / 1M input / $3.75 / 1M output (introductorio hasta 31/12/2026; estándar $1.50/M in, $7.50/M out desde 01/01/2027) |
| Liberado | Septiembre 2026 (estable). Motor default del Antigravity Agent y Antigravity SDK. |
| Estado | **En flota activa** — Agente autónomo para ingeniería de software de largo horizonte, refactorización multi-archivo, auditoría multimodal y orquestación con tools. |

**Fortalezas (verificadas en documentación oficial Google DeepMind / ai.google.dev):**
- **Ingeniería de software de largo horizonte:** Diseñado específicamente para tareas de desarrollo extensas, refactorizaciones multi-archivo y ejecución determinista de herramientas sin desviarse del objetivo.
- **Orquestación de agentes autónomos:** Resiliencia en flujos multi-paso con auto-verificación intermedia y corrección de bucles fallidos.
- **Ventana de contexto de 1M tokens con Context Caching:** Permite cargar repositorios completos, especificaciones extensas o documentación pesada con bajo costo y latencia reducida.
- **Entrada multimodal completa:** Comprensión nativa de texto, imágenes, video, audio y documentos PDF, permitiendo auditar capturas de pantalla, diagramas y assets visuales.
- **Control de razonamiento (thinking levels):** Permite sintonizar el balance entre latencia e inteligencia según la tarea (`low` para tareas rápidas/streaming, `medium` para código y agentes, `high` para deep reasoning y matemática).
- **Herramientas avanzadas integradas:** Soporte de Computer Use, Code Execution en sandbox y llamada a funciones robusta.

**Debilidades y restricciones (verificadas):**
- Salida solo texto (no genera audio, imágenes ni video directamente).
- Nivel de thinking `minimal` no está soportado (arroja error de API si se solicita).
- Mayor consumo de tokens en tareas complejas debido a los pasos de auto-verificación e iteración de tools por diseño.
- Parámetros antiguos de muestreo (`temperature`, `top_p`, `top_k`, `candidate_count`) deprecados/no soportados en la API de Gemini 3.

**Regla de asignación para Isla Ancestral:**
- Implementación de código GDScript y refactorizaciones complejas que abarcan múltiples archivos y dependencias.
- Diagnóstico y resolución de bugs sutiles que requieran razonamiento paso a paso y verificación de llamadas a tools.
- Auditoría técnica y sincronización de documentación técnica (planes actuales, checklists, guías y logs).
- Análisis multimodal de diagramas, capturas de interfaz y flujo visual (M154).
- NO asignar: generación directa de assets binarios (audio/texturas directas sin scripts), tareas que requieran modelos puramente sin reasoning cuando se busca latencia ultra baja sin verificación.

**Método de trabajo:**
1. Planificación metódica con descomposición en pasos verificables.
2. Ejecución directa con herramientas (`read`, `write`, `edit`, `bash`, `glob`, `grep`, `webfetch`).
3. Auto-verificación de cambios mediante tests o análisis estático antes de concluir.
4. Comunicación directa, técnica y concisa (sin muletillas ni fórmulas conversacionales).

---

## Reglas de uso

1. **Solo modelos aprobados por el fundador** se agregan a la tabla de activos.
2. **Cada versión nueva** se guarda como `GUIA-COMPARATIVA-MODELOS-V<N>.md` y la anterior se mueve a `obsoletos/`.
3. **No incluir** modelos que ya no van a volver; esos ya viven en `obsoletos/` como histórico.
4. **UTF-8 sin BOM** siempre (§28 AGENTS.md).
5. **Firmar** toda edición con modelo, plataforma y fecha.
6. **Modelos en prueba (supervisados):** Crouton Alpha (retirado), Stealth Glyph Cluster (activo), Reflection Beam 1.0 (modelo de pago), ERNIE-5.5-Flash-Preview (**en flota desde 2026-11-13**, modelo de pago, gratuito en preview). No se les asignan módulos críticos sin previa revisión. Los reportes de sus tareas se escriben en `Mensajes entre modelos/<MODELO>/` (ERNIE ya tiene canal propio; su etapa de prueba usó `REPORTES-Prueba-Paralela/`). Beam tiene su propio BACKLOG-MASTER en `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md`.

---

## Referencia

- Versión histórica completa (pre-V1, 3398 líneas): `obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` (respaldo del 2026-11-04).
- Protocolo de comunicación: `Mensajes entre modelos/GUIA-COMUNICACION.md`.
- Protocolo multiagente: `CHECKLIST-GLOBAL.md` §21.

**Modelo:** Gemini 3.8 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-17
