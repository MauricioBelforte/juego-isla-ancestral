# CRONÓMETROS VIGENTES — DEFINICIÓN EXACTA Y CÓMO LLENARLOS


> **VIGENTES (crear siempre ESTAS versiones): A v3, B v3, C v3 y D v2.**
> Las versiones anteriores (A/B v1-v2, C v1-v2, D v1) quedan SOLO como HISTORIAL documentado al final — no crearlas más.

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 04:32
**Estado:** VIGENTE — estos son los 2 cronómetros del director, validados por el fundador 04:29. Copiar la definición EXACTA (expresión cron + prompt) para recrearlos.

---

## 1. Los dos cronómetros del director (reparto de minutos)

| Cron | Expresión cron | Dispara a las | Función |
|---|---|---|---|
| **CRON A v3** | `0,20,40 * * * *` | :00, :20, :40 | Detección por SCRIPT (`scripts/verificar_mensajes_nuevos.py`) + responder pendientes + repoblar backlogs |
| **CRON B v3** | `10,30,50 * * * *` | :10, :30, :50 | Segunda red: detección por LAG de acuses (misma lógica sin script, lógica de comparación en vivo) |
| **CRON D v1** | `15,35,55 * * * *` | :15, :35, :55 | ASIGNADOR POR CAPACIDAD: solo investigación/repoblación por capacidad (fundador 2026-10-19 03:15) |
| **CRON C v3** | `5,25,45 * * * *` | :05, :25, :45 | PASO 0: GATE de padding (`scripts/verificar_padding_pools.py`, 3 cifras) + PRESERVACIÓN (commits por frente) — la investigación/repoblación se movió a Cron D |

**Regla de reparto:** cada 5 minutos hay un disparo en tela de juicio nula — el orden por hora queda **A (:00) → C (:05) → B (:10) → A (:20) → C (:25) → B (:30) → A (:40) → C (:45) → B (:50)** (fundador 2026-10-19 04:41: C intercalado cada 20 min desde :25 sin pisar a A ni B).

---

## 2bis. CRON C v2 — ⚠️ HISTORIAL (SUPERSEDED por C v3: la Tarea 2 migró al Cron D v2)

Definición original (creado 04:41, id `wku_152778f30001fWRhXBrjKMF1MZ`) — **ya no crear:**

**TAREA 1 — COMMITS DE PRESERVACIÓN** (NUNCA push; el push solo lo ordena el fundador):
- `git status --short` agrupado por AUTOR/PROPÓSITO leyendo mensajes nuevos de la ventana y `Logs/` — un commit = un frente coherente, NUNCA mega-commit de todo.
- Verificación por grupo antes de commit: encoding §28 (fix_encoding.py --dry-run si hay daño), sin secretos, sin binarios no pedidos.
- NO TOCAR: archivos con mtime < 5 min (escritura en vuelo), módulos 🔵 de otro agente, `NUMEROS_DISPONIBLES.txt`. Prohibido push/--force/--amend.
- Mensajes de commit en español, pasado impersonal, viñetas por archivo con atribución. Si nada: "CRON C: nada para preservar".

**TAREA 2 — INVESTIGACIÓN/REPOBLACIÓN INTELIGENTE** (solo modelos activos):
- ACTIVO = escribió en su canal en las últimas 2 horas.
- Backlog < 100 pendientes → `scripts/repoblar_backlog.py` con módulos elegidos por CAPACIDAD: repetida `10-GUIA-COMPARATIVA-MODELOS.md` (Recom, dificultad 1-5) + historial de su canal. Sin delegar por descarte, sin módulos 🔵 ajenos, fuente 05-Checklist reales.
- Reporte: a quién, qué módulos, por qué su capacidad.

---

## 2. CRON A v3 — prompt EXACTO (copiar tal cual en cron_create)

```
CRON A v3 — DETECCIÓN POR SCRIPT (fundador 2026-10-19 02:38: "podes ejecutar un script que detecte si hay nuevos archivos — es porque hay mensajes que leer — tenes que corregir"):

1. EJECUTÁ PRIMERO: `python scripts/verificar_mensajes_nuevos.py` (exit 0 = al día; exit 1 = hay pendientes listados por canal). El script compara mi último acuse (slug `glm-5.3-flash-director-a-`) contra los mensajes de cada agente — sin punteros y sin filtro de receptor. NO LO IGNORES: su salida es la tarea de esta vuelta.
2. Si exit 1: para CADA pendiente listado, leé el archivo COMPLETO y RESPONDE, sacando el número del `NUMEROS_DISPONIBLES.txt` DE ESA CARPETA y borrando el número del pool (el pool lo comparten el agente y yo — regla fundador 02:27). NUNCA inventar números.
3. Si el pool de un canal está desalineado de su secuencia (primer número != máximo+1), sanéalo ANTES de escribir (regla huecos del medio jamás se reutilizan) y reporta la anomalía.
4. Actualiza el puntero .ultima-revision SOLO como estado de lectura (nunca como prueba de respuesta).
5. Escribe respuestas/apuntes/journal SIEMPRE en UTF-8 sin BOM con Python (NUNCA PowerShell Set-Content/>).

CADENCIA — REGLA CERO: solo novedad material. Si el script dice TOTAL sin responder: 0 → respondé 1 línea: 'CRON A: sin mensajes pendientes (script al día)' y cerrá. Si respondiste algo: lista corta de canales y números respondidos.

Reglas: firma GLM-5.3 Flash-Director, español, independencia §21.8, pathspec explícito, numeración SOLO del pool del canal destino.
```

---

## 3. CRON B v3 — prompt EXACTO (copiar tal cual en cron_create)

```
CRON B v3 — DETECCIÓN POR LAG DE RESPUESTA (fallo corregido 2026-10-19 02:36: el puntero mintió y las vueltas 131-133 de DS-OC quedaron horas sin acuse):

Para CADA canal de 'Mensajes entre modelos/' (agnes-3-flash, DS-V4.1-Flash-Opencode, Hy3, DeepSeek-V4.1-Flash, Step-5-WorkBuddy, Ling-3.1-Flash, G-5.3-Flash-Agente):
1. NN_MAX_DE_ÉL = el número más alto de archivo con mensaje cuyo emisor NO soy yo (todo slug que no empiece por `glm-5.3-flash-director-a-`). Sin filtro de receptor: si el emisor no soy yo, es mensaje de él.
2. MI ÚLTIMO ACUSE = el número más alto de archivo con slug `glm-5.3-flash-director-a-`.
3. LAG = NN_MAX_DE_ÉL - ÚLTIMO_ACUSE_MÍO. Si LAG > 0 hay mensajes SIN RESPONDER: leerlos COMPLETOS y responderles sacando el número del pool `NUMEROS_DISPONIBLES.txt` de esa carpeta (regla fundador: el pool lo comparten el agente y yo) — NUNCA inventar número. CONSUMIR el número en el MISMO acto de escribir (borrarlo del pool en el mismo script; entre tomar y escribir puede entrar otro mensaje y duplicar).
4. NO confíe en .ultima-revision para decidir responder: el puntero es solo estado de lectura, no prueba de acuse (fallo demostrado 02:36).
5. Tras responder: actualizar puntero SOLO de lectura.

CADENCIA — REGLA CERO: solo novedad material (mensajes respondidos en esta vuelta o anomalías de pool/numeración). Si LAG=0 en todos: 1 línea 'sin faltantes' y cerrar.
Reglas: numeración via NUMEROS_DISPONIBLES.txt del canal (consumir), UTF-8 §28 sin BOM con Python (NUNCA PowerShell), firma GLM-5.3 Flash-Director, independencia §21.8.
```

> Nota: este prompt es la versión v3 refinada (la que cubre el caso del literal que disparaba con caracteres BOM/encoding corrupto de la plataforma). El texto funcional es el mismo criterio del doc `METODO-DETECCION-V3-LAG.md`.

---

## 4. Cómo crearlos (receta de relleno)

**Si tenés el tool de calendario de tu plataforma (Kilo Code):**
1. `cron_create` con `cron = "0,20,40 * * * *"` y el prompt EXACTO de la sección 2 → es el Cron A. Anotá el `id` devuelto.
2. `cron_create` con `cron = "10,30,50 * * * *"` y el prompt EXACTO de la sección 3 → es el Cron B. Anotá el `id`.
3. Verificar con `cron_list` que ambos quedaron con next-fire en las franjas correctas (A en :00/:20/:40, B en :10/:30/:50).
4. Para borrar o corregir: `cron_list` → tomar el id → `cron_delete` → `cron_create` con la nueva definición (NUNCA editar mentalmente el que corre; borrar y recrear).

**Cuotas y límites del sistema:** máximo 10 tareas programadas por sesión; una tarea vence a los 7 días de creada (recrearla después); los disparos esperan a que la sesión esté inactiva (no interrumpen una vuelta en curso).

**Si sos un AGENTE de flota sin tool de cron:** el cronómetro por especialidad se crea/apaga con instrucciones del fundador o del director en tu canal — guía de relleno para agentes: `Mensajes entre modelos/G-5.3-Flash-Agente/COMO-CREAR-TU-CRONOMETRO.md`. Reglas iguales: leer canal primero, reportar en cada vuelta (REGLA CERO), nunca agotar la cola (backlog 100+).

---

## 5. Invariantes que NO se negocia en ningún cron

1. **Detección sin puntero y sin filtro de receptor** — el puntero solo es lectura; el slug del receptor se ignora (casos Hy3 259 / agnes-a-director 767-772).
2. **Número SIEMPRE del pool de la carpeta destino**, consumido en el mismo acto de escribir (100 números consecutivos libres, sin BOM, huecos del medio jamás se reutilizan).
3. **Escritura SIEMPRE Python UTF-8 sin BOM LF** — prohibido `>`, `Set-Content` (escribe UTF-16/BOM) y herramienta que corrompa UTF-8.
4. **REGLA CERO**: el cron reporta solo novedad material; si todo está al día, una línea y cerrar.
5. **Firma**: `GLM-5.3 Flash-Director / Kilo Code` (para crons del director) o la firma propia del agente (para crons de flota).
6. **Respuesta SIEMPRE en español.**
