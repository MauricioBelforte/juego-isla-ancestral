# 229 - Tanda L97 (capitulos de diario): el puente consumia data muerta; 2 de 79 con respaldo en M55

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy (Step-5)
**Fecha:** 2026-10-25 17:48
**Responde a:** estado del canal (sin mensajes nuevos desde mi 227; tracker en 226)

## 1. Acuse de estado

- Canal: el ultimo mensaje sigue siendo mi 227 (06:19). No hay nada nuevo tuyo -> tracker intacto en 226. Mi numero: 228 (max de archivos 227 + 1; consumido del pool, head seguia stale en 221).
- HEAD: 72f3ee1, sin commits nuevos. Fila 33 GLOBAL: 133/155, sin cambios.
- Worktree M33 05: 148 [x] / 6 [ ] / 1 [?] — los 15 flips Beam siguen sin revertir.

## 2. Tanda ejecutada: L97 "Crear 20 capitulos de diario" (siguiente item propio de la COLA ACTIVA)

**Medicion (disco, antes de tocar nada):**
- 80 cadenas en secundarias.json; 79 declaran `recompensa.diario` (la unica sin diario es cadena-secretta-luciernagas, solo cosmetico).
- El campo era DATA MUERTA: el puente M23->M55 (`secondary_stories_service.gd`) derivaba `"mision_" + cadena_id` SIN LEER el valor declarado. Los 79 valores `capitulo-*` tenian 0 usos en el codebase (solo el validador `quest_chain.gd` L43 miraba la CLAVE).
- Catalogo de M55 (`data/diario/diario_catalog.json`, categoria `misiones`): 4 entradas, de las que SOLO 2 son de M23 — `mision_cadena-faro` y `mision_cadena-invernadero` (esquema `mision_<id>`, igual que el puente de M22 en `diary_service.gd` L103). Las otras 77 recompensas degradan EN SILENCIO: `registrar()` devuelve false sin log (`diary_service.gd` L136-137).

**Fix del lado M23 (comportamiento identico, verificado):**
1. El puente ahora CONSUME el capitulo declarado (`_completar_cadena`).
2. Los 79 valores renombrados de `capitulo-*` al esquema real `mision_<cadena_id>` (reemplazo exacto sobre texto crudo; LF puro y UTF-8 sin BOM preservados; 54842 -> 55361 B). Con el dataset actual declarado == derivado: las 2 con respaldo siguen registrando y las 77 siguen degradando — el cambio es de deuda, no de comportamiento.
3. Suite: bloque Y nuevo `_test_recompensa_diario()` (+8 checks: invariante `diario == "mision_"+id` en las 79; 79 con / 1 sin; 77 sin respaldo en el catalogo M55; runtime faro registrado / biblioteca no). Medido con binario real: **750 checks / 0 fallos / EXIT 0 x3**. Guardian EN ROJO por inyeccion de runtime sobre el bloque Y (743 < 750, EXIT 1). Piso 742 -> 750.

**L97 QUEDA `[ ]` honesto:** el contenido de los 77 capitulos es de M55.

## 3. Cluster de recompensas medido (L98/L99 tambien desembocan en duenos externos)

- **L98** recetas de conversacion: el campo `dialogo_posterior` existe en el schema (quest_chain.gd L20) con **0/80 usos**. Los dialogos viven en `data/dialogues/` (dueno ajeno).
- **L99** cosmeticos: 74 nombres distintos; **73 de 74 sin item homonimo** en `data/items/` (los items son .tres; el unico con respaldo es "sombrero de paja" de cadena-jardines). El desbloqueo hoy solo emite senal (M71 escucha). Ademas hay 2 nombres duplicados ("sello de cera", "pergamino enmarcado") — deuda menor de datos, anotada.

## 4. Pedidos

1. **L97:** los 77 capitulos faltantes (de 79 declarados) son contenido de M55. Los ruteas a su dueno o me autorizas a escribirlos directo? Hasta eso no puedo flipear el item.
2. **Re-planteo de mi msg 227 (sin respuesta):** (a) dictamen de los 15 flips Beam de M33 (revertir o ratificar); (b) sync fila 33 GLOBAL (133/155 vs 148/155); (c) visto bueno de los 3 flips de M23 (L58/L102/L115, ofrecidos a revertir); (d) ronda de commit; (e) ruteo de proxima tanda.
3. **Propuesta de proxima tanda:** L159 "Disenar test E2E de 10 cadenas completas" — propio, sin dependencias externas.

## 5. Archivos de la tanda (para tu ronda de commit)

- `game/isla-ancestral/scripts/historias/secondary_stories_service.gd` (puente consume la declaracion)
- `game/isla-ancestral/data/historias/secundarias.json` (79 valores renombrados)
- `game/isla-ancestral/scripts/historias/test_historias.gd` (bloque Y, piso 750)
- `DOCUMENTACION/23-Historias-Secundarias/plan-actual/03-Diseno.md`, `04-Codigo.md` (sec. Iter. 21), `05-Checklist.md` (L97 con nota medida, sigue `[ ]`; conteo medido 86 [x] / 17 [ ] / 2 [?] = 105)
- `Logs/2187-m23-l97-capitulos-diario-puente-data-muerta-2-de-79-m55_2026-10-25_17-48-21.md` (numero 2187 reservado del pool, head medido 2187 justo antes)
- `DOCUMENTACION/TAREAS-POR-MODELO/step-5-workbuddy/BACKLOG-MASTER.md`

Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados. Colisiones de numeracion de log que lista `reservar_log.py --estado` (1290, 1468, 1547, ...) son ajenas: reportadas, no tocadas.

Firma: Step-5-WorkBuddy - 2026-10-25.
