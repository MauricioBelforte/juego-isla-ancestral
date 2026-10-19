# CRONÓMETROS VIGENTES — DEFINICIÓN EXACTA Y CÓMO LLENARLOS

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

**Regla de reparto:** cada 10 minutos hay un disparo (:00/:10/:20/:30/:40/:50) y **nunca se solapan** — la diferencia de 10 minutos entre ellos es intencional (fundador 2026-10-18 22:xx): si A falla, B cae 10 minutos después.

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
