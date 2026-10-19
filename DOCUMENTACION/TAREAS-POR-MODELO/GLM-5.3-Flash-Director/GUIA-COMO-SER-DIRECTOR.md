# GUÍA: CÓMO SER DIRECTOR (recetario de tareas recurrentes)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 07:57
**Propósito:** cuando el fundador pida "las cosas de siempre" (renumerar, leer canales, repoblar, preservar...), esta guía dice EXACTAMENTE dónde buscar: qué archivo, qué script, qué pasos. Nada de improvisar ni repetir errores ya documentados.

---

## 0. Reglas de oro (valen para TODA tarea)

1. **Escritura SIEMPRE Python UTF-8 sin BOM, LF** (`io.open(p,'w',encoding='utf-8',newline='\n')`). PROHIBIDO PowerShell `>`, `Set-Content` (escribe UTF-16/BOM) y la herramienta Write cuando corrompe UTF-8. Reparación masiva: `python scripts/fix_encoding.py` (primero `--dry-run`), verificador: `python scripts/diagnosticar_mojibake.py`.
2. **Numeración de mensajes SIEMPRE del pool** `NUMEROS_DISPONIBLES.txt` de la CARPETA DESTINO (la comparten el agente y el director): tomar el número, BORRARLO del pool, y ESCRIBIR en el mismo acto (nunca "tomar hoy y escribir mañana").
3. **3 cifras SIEMPRE**: nombres de archivo, líneas de pool, punteros.
4. **Nunca push** — push solo por orden expresa del fundador. Guión por defecto: commit local clasificado.
5. **Fundador = fuente de verdad.** Sus correcciones se documentan y se propagan; acusaciones sin evidencia no se heredan (caso registrado: "abortó el fundador" era falso).
6. El detalle va a los archivos; por el chat solo la línea clave (REGLA CERO).

---

## 1. "Leé los canales / hay mensajes nuevos?" — DETECCIÓN

| | |
|---|---|
| Script | `python scripts/verificar_mensajes_nuevos.py` (exit 0 al día / 1 = lista de pendientes por canal) |
| Método | **V3 por LAG** — `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/METODO-DETECCION-V3-LAG.md` |
| Regla central | Comparar mi último acuse (slug `glm-5.3-flash-director-a-`) con el mayor NN del agente. **NO usar `.ultima-revision` como prueba de respuesta** (falla documentada: DS-OC 131-133, Ling 177) |
| Fallas históricas | V1 filtraba por slug del receptor (perdió Hy3 259); V2 seguía filtrando (perdió DS-OC 131-133) |
| Cron | A (:00/:20/:40) y B (:10/:30/:50) — ver `CRONOMETROS-VIGENTES-COMO-CREARLOS.md` |

Al responder: número del pool de la carpeta destina, consumido al escribir; nombre `NNN-fecha_hora-glm-5.3-flash-director-a-<agente>-tema.md` (slug COMPLETO, con emisor: sin emisor el detector lo clasifica como mensaje de otro).

## 2. "Renumerá el canal X" — ESTRATEGIA COMPLETA (7 pasos, ejecutar TODOS)

Doc fuente: `COMO-CORREGIR-NUMERACION-MENSAJES.md` (numeración) + patrón aplicado a DS-OC (001-108) y G-5.3-Agente (001-093).

1. **Inventario cronológico**: listar archivos `NN-fecha_hora-*` ordenados por la fecha del nombre (desempate por NN, luego nombre).
2. **Renumerar 001..N** por orden cronológico vía renames con archivo temporal (evitar colisiones), normalizando a 3 dígitos.
3. **Títulos internos**: reemplazar el `# NN` del cuerpo por el nuevo número (segunda pasada: cualquier `^#\s*\d+` que no coincida).
4. **Referencias**: corregir `"Responde a"` y citas con fecha (`patrón <viejo>-<fecha> -> <nuevo>-<fecha>`) — 23 archivos en G-5.3.
5. **Informe al agente** con el mapping viejo→nuevo (extraerlo de `git diff-tree --name-status -M <commit>`, NUNCA de memoria) + instrucciones (pool, helper, actualizar sus ayudas).
6. **Saneo final**: pool `max+1 … max+100`, puntero `NNN`, verificación UTF-8 sin BOM, secuencia consecutiva sin huecos/duplicados.
7. **Commits** del canal + de la anotación en el método. Huecos del medio se ELIMINAN con reorden cronológico (nunca se reutilizan si queda alguno).

Trampa conocida: al renombrar con slicing manual se pierde el guion (`0942026-...`) — verificar el nombre final antes de commitear. Y si se escribe un informe provisional fallido, ELIMINARLO antes de consolidar (quedó un duplicado 95/094 en G-5.3).

## 3. "Revisá la numeración de todos los canales" — GATE DE PADDING

| | |
|---|---|
| Script | `python scripts/verificar_padding_pools.py` (normaliza pools y punteros de TODOS los canales a 3 cifras; exit 1 si corrigió algo) |
| Lección | Mi primer barrido fue puntual: mis escrituras posteriores reintrodujeron 2 cifras (95 en G-5.3, 92 en Step-5). Por eso es CRON C paso 0 — automático, no memoria |
| Doc | Convención 3 cifras anotada en `COMO-CORREGIR-NUMERACION-MENSAJES.md` |

Verificación post: cada pool empieza en `max_archivo + 1`, 100 números consecutivos, sin BOM. Cada vuelta de Cron C re-verifica (Paso 0).

## 4. "Repoblá los backlogs / las colas" — TAREAS REALES

| | |
|---|---|
| Script | `python scripts/repoblar_backlog.py <carpeta-agente> M87,M91,... [--cota 100]` |
| Fuente | SOLO `05-Checklist.md` reales de los módulos (el script deja `<!-- fuente: ... -->` por ítem y deduplica contra lo existente) |
| Capacidad | Elegir módulos por `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (columna Recom + dificultad 1-5) + historial del canal. NUNCA por descarte |
| Escalón | Si el frente queda a techo (assets/vision/render bloqueados): documentar + saltar, como agnes en su M45 (789) — rotar al siguiente módulo headless |
| Backlogs | `DOCUMENTACION/TAREAS-POR-MODELO/<agente>/BACKLOG-MASTER.md` — objetivamente contables en secciones REPOBLACION V3 (casillas `[ ]`); formato numerado sin casillas NO es contable (lección DeepSeek §314) |

## 5. "Preservá el trabajo / hacé commits" — CRON C

| | |
|---|---|
| Cadencia | :05/:25/:45 (entre A y B, sin solaparse); definición completa en `CRONOMETROS-VIGENTES-COMO-CREARLOS.md` |
| Método | `git status --short` → agrupar por AUTOR/FRENTE (atribuir leyendo mensajes de la ventana y `Logs/`) → verificación encoding → commit por grupo con viñetas y atribución |
| NO TOCAR | mtime < 5 min (T-19 en disco), módulos 🔵 ajenos, `NUMEROS_DISPONIBLES.txt`; archivos "sin dueño" se preservan con atribución declarada o quedan flaggeados |
| Prohibido | push, --force, --amend, mega-commit "de todo lo que falta" |
| Basura | archivos 0-byte y residuos de redirects se eliminan (caso `0.5` / `30` en raíz) |

## 6. "Sella QA / verificá un módulo" — SELLOS §21.8

1. El sello NO procede si el 05 tiene `[?]` o `[ ]` > 0 (regla aplicada a M94 y M153; sello limpio solo a M102 y M112).
2. Verificadores independientes (Hy3, agnes...) entregan medición por bytes; MI rol = registrar sello en la fila de `CHECKLIST-GLOBAL.md` y confirmar al verificador por su canal (pool propio).
3. Drift de Totales detectado (105/0/1 vs 106/0/0) = corregir la línea Totales del 05 con conteo medido (caso M118; formato: "**Totales:** N ítems · Completados: X · Pendientes: Y · No resueltos: Z").
4. Cruces de universos con los agentes (paso a paso: Step-5 ítem 57) = mis 5 de cadencia post-acuse + los suyos de deuda >24h; ambas coexisten (documentado en ambos canales).

## 7. "Corregí qué dijiste / precisión de registro" — RETRACTACIONES

Heredar acusaciones sin evidencia = mi fallo documentado ("abortó el fundador" provenía de agnes 770/789 y lo propagué). Protocolo:
1. Corregir AL ORIGEN (canal del que afirmó el dato) sin cargárselo al que lo heredó.
2. Copy a quien lo heredó (DeepSeek 322: decisión runtime re-vuelta).
3. Publicar la liberdad que corresponda (runs de Godot/MCP/capturas: liberes salvo que el fundador diga "hoy no").
4. Si escribí basura de redacción en un mensaje enviado: limpiarlo inmediato (paso de restitución por replace, sin tocar numeración).

## 8. Mapa de archivos del directorio de dirección

Todos en `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/`:

| Archivo | Qué es |
|---|---|
| `GUIA-COMO-SER-DIRECTOR.md` | ESTE archivo (maestro) |
| `METODO-DETECCION-V3-LAG.md` | Detección de mensajes sin responder (script V3, obsoletos V1/V2, validación del fundador) |
| `CRONOMETROS-VIGENTES-COMO-CREARLOS.md` | Cron A/B/C: horarios, prompts exactos, receta cron_create |
| `ESTRATEGIAS-CRONO-A-B.md` | Historial de estrategia de cronometros (A/B + Cron C) |
| `COMO-CORREGIR-NUMERACION-MENSAJES.md` | Método de numeración: pools, huecos, 3 cifras, aplicaciones (Step-5, DS-OC, G-5.3) |
| `BACKLOG-MASTER.md` | Mi propia cola (si aplica) |

Scripts de soporte en `scripts/` (proyecto):

| Script | Uso |
|---|---|
| `verificar_mensajes_nuevos.py` | Detección V3 (lag por acuses) |
| `verificar_padding_pools.py` | Gate 3 cifras (pools + punteros, TODOS los canales) |
| `repoblar_backlog.py` | Repoblación real desde 05-Checklists |
| `proximo_numero.py` | Siguiente número de un canal (consume del pool) — obligatorio para agentes |
| `fix_encoding.py` / `diagnosticar_mojibake.py` | Reparación/verificación §28 |
| `verificar_checklist.py` | Estado de 05 vs GLOBAL (drifts, Totales, colgados) |
| `generar_checklist_global.py` | Regenerar tabla resumen GLOBAL |
| `test_scripts.py` | Suite de los scripts (correr antes de usarlos en producción) |

## 9. Guías fuera de mi carpeta (referencia cruzada)

- `Mensajes entre modelos/GUIA-COMUNICACION.md` — reglas de numeración por canal (V definitiva), detección V3, protocolo de canales.
- `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/CRONOMETROS-VIGENTES-COMO-CREARLOS.md` — cron A/B/C prompts exactos.
- `Mensajes entre modelos/G-5.3-Flash-Agente/COMO-CREAR-TU-CRONOMETRO.md` — receta para AGENTES sin tool de cron.
- `AGENTS.md` §10.2, §28, §29 — protocolo de canales, UTF-8, backlogs (respaldo canónico del proyecto).

## 10. Checklist de cierre de CUALQUIER tarea del director

- [ ] Respuestas enviadas por pool (número consumido, slug completo con emisor, 3 cifras)
- [ ] Padding de pools/punteros re-verificado (o gate del Cron C en verde)
- [ ] Preservación commiteada (grupos atribuidos, sin push)
- [ ] Documentación anotada (método/guía correspondiente)
- [ ] REGLA CERO respetada (chat: solo la línea clave)
- [ ] Sin promesas de memoria (todo dato citado = medido en disco o en git)
