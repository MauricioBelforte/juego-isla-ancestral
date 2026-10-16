# CRON DEL DIRECTOR — cómo crearlo (receta del 2026-10-16)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 (directiva del fundador: "guarda como creaste el cronometro de hoy asi mañana lo implementamos de nuevo. create un archivo md en tu carpeta")
**Cadencia actual:** cada **15 minutos** (cambio ordenado por el fundador a las 04:38 — antes era 5 min)

## 1. Comando exacto (usado hoy)

Herramienta: `cron_create` del entorno Kilo Code. Parámetros:

```
cron:   */15 * * * *
prompt: (ver §2 — el texto completo del bucle)
```

- **ID activo al guardar esta receta:** `wku_143c11b91001aCkBnEoUaDsyig` (próximo disparo 08:15Z).
- El cron expira a los 7 días de creado — **renovarlo cada semana** (borrar el viejo y crear de nuevo con este mismo prompt).
- **Para cambiar cadencia / re-crear:** `cron_delete <id-viejo>` → `cron_create` con el nuevo `cron:` — el prompt no cambia.

## 2. Prompt completo del bucle (copiar tal cual)

```text
BUCLE DEL DIRECTOR (directiva del fundador 2026-10-16, cadencia 15 min): 1) Leer TODAS las carpetas de canales en 'Mensajes entre modelos/' — detectar todo mensaje nuevo dirigido a mí (GLM-5.3 Flash-Director) y RESPONDER A TODOS en el canal correspondiente con numeración de hilo (último mensaje del canal + 1, borrar SOLO ese número del pool del canal; pool de agnes re-base reactivo si su barrido colisiona — el patrón es conocido: agnes toma números bajos de la serie 6xx que yo ya uso). Atender primero lo del fundador si hay orden directa. 2) PROHIBIDO informar al fundador 'no hay mensajes' o 'sin nada que delegar' — si no hay nada, seguir directo al punto 3 sin comentario. 3) En tiempo libre (sin mensajes que responder): a) Mantener los 5 backlogs activos en 'DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/BACKLOG-100-TAREAS-*.md': marcar tareas que los modelos ya completan (de sus canales y del CHECKLIST-GLOBAL.md), y AGREGAR tareas nuevas para que cada archivo mantenga 100+ tareas delegables siempre. b) Mantener y afinar 'DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/ROLES-DE-AGENTES.md': rol de cada agente según GUIA-COMPARATIVA-MODELOS (web+benchmarks) y evidencia empírica del repo — delego a cada uno lo que hace MEJOR que yo. 4) Disponibilidad de flota (declarada por el fundador): SOLO agnes-3-flash, DeepSeek-V4.1-Flash, Step-5-WorkBuddy, Hy3, DS-V4.1-Flash-Opencode. NO disponibles: Ling-3.1-Flash, s2, s3, atria-dawn, kimi-k3, Claude-Haiku-5.5, muse-spark. 5) No delegar por delegar: solo tareas del backlog activo con el nicho del modelo (matriz ROLES-DE-AGENTES). 6) Independencia de modelo: DeepSeek-WB y DS-OpenCode no hacen QA mutuo; módulos cerrados por GLM-5.3-Flash-agente no los sello yo (Hy3/agnes los verifican). 7) Al cerrar ciclos con cierre real: log en 'Logs/' con número del pool global, firmas, UTF-8 estricto (§28). 8) Informar al fundador SOLO novedad material (cierre de módulo, encargo directo, bloqueo).
```

(Receta completa y sin cortes — copiar tal cual al `cron_create`.)

## 3. Recetas operativas aprendidas hoy (obligatorias en cada ciclo)

### 3.1 Numeración de TODOS los canales (regla Log 1875 + corrección del fundador)

1. **Listar físicamente TODOS los archivos numerados del canal** (no confiar en snapshots ni en el nombre del último visto — me equivoqué 2 veces: QA de Hy3 "225" debía ser 227; cola de agnes).
2. `NN = (último numerado del canal) + 1` — y verificar que esté en `NUMEROS_DISPONIBLES.txt` del canal.
3. Borrar SOLO ese número del pool del canal.
4. committed/pushed el mensaje antes del próximo ciclo.

### 3.2 Re-base reactivo del tren de agnes (patrón recurrente)

- agnes escribe sus barridos tomando números bajos de la serie 6xx que YO ya usé (su motor cuenta su propio máx desfasado). Cada ciclo:
  1. Detectar prefijos duplicados físicos: `python -X utf8` con `re.match(r'(\d{1,3})-', f)` agrupando por número → los `len(v) > 1` son colisiones.
  2. Re-base el archivo nuevo de agnes al **siguiente número libre** (hoy: 632 por m148, 633 por m149, ... 634/635...); pool agnes consume el número usado.
  3. Commit + push por tanda.
- La secuencia coherente quedó: 600-602 (m148 renames), 603-605 (m12/m92/m93), 606 boletín, 607 relevo, 608 m135, 609 aviso, 610-613 (m127/128/129/aviso2), 614-623 (m130...m139), 624 (m143), 625 (m141), 626 (m142), 627-628 (m143/m144), 629-630 (m145/m146), 631 (m147), 632 (m148), 633 (m149), ... — agnes sigue desde **634+**.

### 3.3 Pools de canal — NO commitear (cambió hoy)

- Los `NUMEROS_DISPONIBLES.txt` de canales quedaron **destrackeados + gitignored** (commit `7788533`, decisión por hallazgo de DeepSeek 276 §3.2: 20 pools tracked con BOM/CRLF ponían el CI rojo sistemáticamente). Conservar el `.gitignore` línea `Mensajes entre modelos/**/NUMEROS_DISPONIBLES.txt`.
- Sanear BOM cuándo aparezca: leyer los bytes y reescribir sin los 3 primeros si son `EF BB BF`.

### 3.4 Aplicación de filas GLOBAL (11 celdas canónicas)

- Al reconstruir una fila: **11 celdas** (ID, Módulo, Estado, Progreso, Prioridad, Complejidad, Deps, Recom, Agente, Última, Notas) — me equivoqué 2 veces (76 y 55) dejando 10 — verificar conteo de celdas tras editar.
- Los sellos de QA se insertan ANTES del ` |` final, formato: `**✅ QA §21.8 VERIFICADO por Hy3/WorkBuddy 2026-10-16 (canal Hy3 msg NNN, Log ref): verificado SIN degradaciones...**`.

### 3.5 Catch-up de worktree compartido (regla nueva post-incidente)

- El worktree es COMPARTIDO: los agentes escriben en caliente y mis `git add -A` pueden borear/cometer WIP ajeno (le borré 2 .gd a Step — alerta 63, recuperables).
- **Nueva política: commits de catch-up con pathspec explícito** (carpeta/tema), NO `-A`, mientras haya WIP ajeno vivo.

### 3.6 T-19 aplicado con matiz (lección del falso positivo de Hy3)

- Mensajes plantilla vacíos: releer 2 veces antes de avisar; el aviso (234) se hace con las DOS salidas posibles (completar o avisar caído). El falso positivo (Hy3 escribió después de mi lectura) se cierre con acuse mutuo — sin reproches.

## 4. Estado operativo al guardar esta receta

- **Flota activa:** agnes (barrido M150+, tren 634+), DeepSeek-WB (M26 122/129 ✓ QA sellado), DS-Opencode (micro-lote M29 192/195 ✓ / M30 119/120 ✓ / M32 119/121 ✓ → M112 + fix economía M38 autorizado), Step-5 (M76 126/130 ✓ fila aplicada · M55 58/131 ✓ fila aplicada · lote rendimiento autorizado · alerta 63 recuperación pendiente suya), Hy3 (4 QAs sellados, cola libre, de a poco).
- **Cola de CI:** lote de DeepSeek commiteado (`4582b67`) — run `quality.yml` pendiente de VERDE (criterio de cierre de L199 de M118 y el reseteo global del pipeline).
- **Pendientes para mañana:** renovar este cron (expira 7 días), agnes continúa desde 634+, validar run CI, L199 flip si CI verde, el fix de economía de M38 si DS lo entrega, y el "sweep" del worktree que pida DS al cierre del micro-lote.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16
