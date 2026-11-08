# Reporte de consistencia — AGENTS.md vs CHECKLIST-GLOBAL.md

**Fecha:** 2026-11-08  
**Modelo:** Reflection-Beam-1.0  
**Plataforma:** Kilo Code  
**Archivos comparados:** `AGENTS.md` (1752 líneas) y `CHECKLIST-GLOBAL.md` (225 líneas)  
**Proyecto:** `game/isla-ancestral/` (raíz del repositorio)

---

## 1. Alcance y método

Se revisaron ambos documentos completos. Se extrajeron los identificadores de módulo (`M###` / `NN-Nombre`) mencionados en `AGENTS.md` y se verificó su existencia en la tabla de `CHECKLIST-GLOBAL.md`. Se contrastaron conteos globales, estados, rutas de archivos y nombres de modelos/agentes. Las líneas citadas corresponden a `AGENTS.md` salvo que se indique lo contrario.

---

## 2. (1) Instrucciones desactualizadas en AGENTS.md

1. **Línea 144 — "radio 256" obsoleto.**  
   `AGENTS.md:144` describe `DOCUMENTACION/167-Isla-Raiz/` con "config fija: radio 256, ...". Sin embargo, `AGENTS.md:1329-1337` (sección "Reglas de oro heredadas (CORREGIDAS 2026-09-25, P-39)") ya establece que la Isla Raíz es **5120×5120 con centro (2560,2560)** desde el rework "Isla 10x" y que la migración de `main_island.gd` aún tiene pendientes L184 (spawn player) y L205 (océano).  
   → La línea 144 contradice la corrección posterior dentro del mismo archivo.

2. **Línea 971 — "los 100 módulos" desactualizado.**  
   `AGENTS.md:971` dice: "El proyecto se considera completo cuando **los 100 módulos** (o el total definido) estén `✅`."  
   `CHECKLIST-GLOBAL.md` (Resumen del Proyecto) declara **Total de módulos: 167** (y 31 `✅` completados al snapshot). El criterio de "100" no coincide con el total real.

3. **Línea 189 (contexto de checklist por módulo) — "100+ ítems".**  
   No es inconsistencia directa con `CHECKLIST-GLOBAL.md`, pero el conteo de subitems del resumen (10565/23965) proviene de un snapshot antiguo (2026-08-28) y `AGENTS.md` no refleja la necesidad de regenerar con `scripts/generar_checklist_global.py`.

---

## 3. (2) Módulos mencionados en AGENTS.md vs CHECKLIST-GLOBAL.md

- **Módulos citados en AGENTS.md:** M01, M09, M19, M20, M22, M23, M28, M31, M34, M35, M53, M56, M59, M64, M67, M82, M88, M91, M95, M98, M101, M102, M103, M106, M107, M108, M111, M114, M126, M128, M129, M130, M132, M146, M147, M151, M154, M156, M158, M162, M167, M168.  
  **Verificación:** todos existen en `CHECKLIST-GLOBAL.md` (0 ausencias).

- **Viceversa:** `CHECKLIST-GLOBAL.md` contiene **167 módulos** (IDs 01–168, falta el 62). `AGENTS.md` solo documenta un **subconjunto** (≈40 IDs). No hay módulos "inventados" en `AGENTS.md`, pero tampoco hay una referencia al catálogo completo, por lo que la guía no refleja el alcance real del proyecto.

---

## 4. (3) Estados de módulos inconsistentes entre ambos documentos

1. **M167-Isla-Raiz.**  
   `CHECKLIST-GLOBAL.md` fila 167: estado `🟡 Con dudas` (113/114), sello Hy3.  
   `AGENTS.md:143-145` lo presenta como "fuente de verdad del terreno" sin reflejar su estado `🟡` ni la migración pendiente documentada en `AGENTS.md:1336-1337` (L184/L205 en centro viejo).

2. **Criterio de completado.**  
   `AGENTS.md:971` fija "100 módulos ✅" como meta de proyecto completo.  
   `CHECKLIST-GLOBAL.md` Resumen: **Completados (`✅`): 31**, En curso (`🔵`): 50, Con dudas (`🟡`): 121, Disponibles (`🟢`): 12, Sin iniciar (`⬜`): 0, total 167.  
   → El umbral documentado en `AGENTS.md` es inalcanzable/inconsistente con el estado real (31/167).

3. **Nomenclatura de director.**  
   `AGENTS.md` (§31) identifica al director como **"GLM-5.3 Flash-Director"** y menciona históricamente **"De-Director V4.1"**.  
   `CHECKLIST-GLOBAL.md` usa "GLM-5.3 Flash-Director" (14 apariciones) y "GLM-5.3-Flash" (20), pero **0 apariciones de "De-Director"**. Hay deriva de nombres entre guía y tablero.

---

## 5. (4) Referencias a archivos o modelos que no coinciden con la realidad

1. **Rutas relativas a `scripts/`.**  
   `AGENTS.md:1321-1337` cita `scripts/world/mundo_raiz.gd` y `main_island.gd` (L147/L162/L296/L184/L205). Estos archivos existen, pero bajo `game/isla-ancestral/scripts/...` (no en la raíz del repositorio). La guía asume rutas relativas al proyecto de juego, lo cual es correcto para Godot pero debe aclararse para evitar confusión con la raíz del repo.

2. **Modelos/agentes.**  
   - `AGENTS.md` menciona "GLM-5.3-Flash (Kilo Code)" como agente histórico y "GLM-5.3 Flash-Director" como director actual. `CHECKLIST-GLOBAL.md` no usa "De-Director" (0 hits), aunque `AGENTS.md` lo documenta como director previo (2026-10-15 → 2026-10-16).  
   - `AGENTS.md` afirma que `atria-dawn` pasó a "deep work por excepción" y que `atria-dawn-s2` es verificador final / `s3` estratega. `CHECKLIST-GLOBAL.md` sí registra "atria-dawn", "atria-dawn-s2", "atria-dawn-s3" en filas y notas, por lo que esos nombres son consistentes.

3. **Archivos de documentación referenciados.**  
   Las rutas citadas en `AGENTS.md` (p. ej. `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `DOCUMENTACION/11-BUGS.md`, `Mensajes entre modelos/GUIA-COMUNICACION.md`, `docs/marketing/guion-trailer.md`) existen y coinciden (verificado). No se detectaron referencias rotas a esos archivos.

---

## 6. (5) Acciones de corrección sugeridas (2)

1. **Corregir datos técnicos y conteos en `AGENTS.md`.**  
   - `AGENTS.md:144`: reemplazar "radio 256" por "5120×5120, centro (2560,2560) (P-39), migración pendiente L184/L205".  
   - `AGENTS.md:971`: reemplazar "los 100 módulos" por "los 167 módulos (total definido en CHECKLIST-GLOBAL.md)" y ajustar el criterio de completado para que coincida con el resumen real (31/167 al snapshot).

2. **Sincronizar nomenclatura y catálogo de módulos.**  
   - Unificar en `AGENTS.md` el nombre del director vigente ("GLM-5.3 Flash-Director") y deprecar o mapear "De-Director V4.1" (0 hits en `CHECKLIST-GLOBAL.md`).  
   - Añadir en `AGENTS.md` una referencia explícita a `CHECKLIST-GLOBAL.md` como fuente de verdad del catálogo (167 módulos) en lugar de conteos fijos, y documentar que `AGENTS.md` solo cita un subconjunto representativo.

---

## 7. Conclusión final

`AGENTS.md` mantiene su valor como guía de protocolo, pero contiene **desfases numéricos y técnicos** respecto a `CHECKLIST-GLOBAL.md`: el total de módulos (100 vs 167) y el radio de la Isla Raíz (256 vs 5120) son los más evidentes. No se detectaron módulos citados en `AGENTS.md` que no existan en `CHECKLIST-GLOBAL.md`, ni referencias rotas a los archivos verificados. La principal acción recomendada es actualizar los conteos y la nomenclatura del director, y enlazar `CHECKLIST-GLOBAL.md` como fuente de verdad del catálogo y del estado de los módulos.  
**Veredicto:** inconsistencias menores-moderadas, corregibles con las 2 acciones anteriores; no afectan la integridad del protocolo multiagente.
