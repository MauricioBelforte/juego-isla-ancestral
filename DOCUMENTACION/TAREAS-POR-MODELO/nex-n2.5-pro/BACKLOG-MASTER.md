**Modelo:** nex-n2.5-pro (Nex-AGI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-20
**Curado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092

# BACKLOG-MASTER — nex-n2.5-pro

> ⛔ **FUERA DE FLUJO — 2026-09-20, directiva del usuario**
>
> nex-n2.5-pro fue retirado del flujo multiagente el **2026-09-20** por el usuario:
> *"practicamente no puede aportar nada porque el contexto es muy grande"*. Su aporte
> real quedó registrado (M11: 73 cuestiones documentadas con líneas reales + liberación
> 🟡 Log 1069). **Este backlog es histórico — no se le asignan más tareas.**
>
> **Reasignación de sus tareas pendientes (hecha por atria-dawn, 2026-09-20):**
> - **Drift T-D01..T-D15 (15):** **13 canceladas como duplicadas** — atria-dawn sesión 2
>   cubre esos módulos en su serie T-DA (159 módulos, lote 1 ya hecho = Log 1098).
> - **T-D06 (M106) y T-D07 (M122):** **congeladas** — son los módulos 🔵 de kimi-k3
>   (fuera de flujo por falta de tokens, vuelve más tarde). Su drift lo hace kimi-k3
>   al regresar, o s2 después (§21.4: no se tocan módulos 🔵 ajenos).
> - **M87 Localización (7 `[?]`):** **ya con DeepSeek-V4.1-Flash** — es el Recom del
>   módulo y autor de la iter. 6; su backlog ya lo incluye (módulo A3). Los 7 `[?]`
>   son ítems **con dueño externo** (M53 ×4, usuario ×1, M14-M39 ×1, M29/M30 ×1), no
>   trabajo libre para nadie.
> - **M11 Personaje (🟡 50/123, nex fue el último):** queda **🟡 sin dueño activo**.
>   Candidato para DeepSeek o mimo cuando terminen su carga actual.
>
> Para verificar cualquier entrega de nex: `Logs/1069*`, `Logs/1067*`, y la sección 7
> de `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md`.

> **Total: 7 tareas reales** extraidas de los `05-Checklist.md` (no inventadas).
> Fuente de verdad: los `05-Checklist.md` de cada modulo. Esta carpeta es tu espejo de trabajo.
> **Como trabajas:** lee tu backlog, elige la siguiente tarea `[ ]` o `[?]`, ejecutala,
> verifica con binario real, marca `[x]` en los **3 registros** (este backlog,
> `05-Checklist.md` del modulo con marcas **Y** linea `**Totales:**`, fila de
> `CHECKLIST-GLOBAL.md`), y reserva un log por lote.

## Perfil (fortalezas medidas en este repo)

- **Fuerza:** Documentacion analistica precisa: **M11 73 cuestiones documentadas con lineas reales**; liberacion final M11 con **cero drift** (50/73/0 = Totales = CHECKLIST-GLOBAL). Detecta problemas (bug player.gd:972, 12 divergencias spec-vs-codigo).
- **Debilidades honestas:** **Contexto chico** — no termina tareas largas (~12h en M11). **Claims requieren verificacion obligatoria** ('0 SCRIPT ERROR' fue falso una vez). **NO tomar:** modulos complejos (5), QA §21.8 (Hy3), M110 (bloqueado). Solo tareas atomicas.

## Modulos asignados

| Modulo | Pendientes | Notas |
|---|---:|---|
| [87-Localizacion](87-Localizacion/checklist.md) | 7 | |

## Orden de prioridad

1. **M87 Localizacion** — 7 pendientes.

## Tareas (extraidas de los checklists reales)

### 87-Localizacion (7 pendientes)

> ⛔ **2026-09-20 — estas 7 tareas NO son de nex.** Son ítems del `05-Checklist.md` de
> M87 con **dueño externo** (no trabajo libre). El módulo es de **DeepSeek-V4.1-Flash**
> (Recom + autor de la iter. 6, Log 920). Se quedan `[?]` en el módulo hasta que sus
> dependencias (M53 sobre todo) avancen. **Nadie más debe tomarlas como tareas libres.**

- [?] Respetar los ajustes de accesibilidad de texto de M58 sin romper layouts [M] -- **M53**. iter. 6: medido con `AnalizadorLayout` a los tamaños equiv...
- [?] Garantizar revisión humana de las traducciones antes del lanzamiento [C] -- **revisión humana (usuario)**. No es automatizable: el módulo aporta la...
- [?] Integrar M53: labels de UI usando tr_key en vez de texto estático [M] -- **M53**. iter. 6: el mecanismo de M87 está provisto y probado — un nodo de...
- [?] Integrar M53: tooltips y descripciones traducidos [S] -- **M53**. iter. 6: `RetraductorUI` ya soporta la propiedad `tooltip_text` vía el metadato `...
- [?] Integrar M58: el tamaño de texto ajustable no rompe la traducción [M] -- **M53**. iter. 6: el análisis responde a la escala de forma monótona (bloq...
- [?] Integrar módulos de contenido (M14-M39): items, misiones, tiendas y diarios con claves M87 [C] -- **M14-M39 (26 módulos de contenido)**. El catálog...
- [?] Integrar M29/M30: fechas y horas mostradas en formato localizado [M] -- **M29/M30**. La API está lista y probada en M87: `LocaleUtils.format_date()...


---

## Recordatorios del protocolo (obligatorios)

- **Reserva log:** `python scripts/reservar_log.py --reservar --agente nex-n2.5-pro --modulo <X>`
- **Binario Godot 4.7.2:** `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  `--headless --path game/isla-ancestral --quit --script res://...`
- **Anti-falso-verde (leccion 28):** exit code **Y** 0 SCRIPT ERROR en stderr. Exit 0 con
  SCRIPT ERROR = fallo disfrazado.
- **Sync de los 3 registros** al cerrar cada lote — **incluida la linea `**Totales:**`**
  (drift endemico: M09/M11/M12/M126/M128/M115/M149 lo sufrieron esta semana).
- **Push a git: NEGATIVO** (instruccion del usuario).
- **Codificacion UTF-8 obligatoria** (sin BOM). Si un diff muestra mojibake, corregir antes de seguir.
- **Honestidad:** un `[?]` con dueno vale mas que un `[x]` falso (DoD §21.6). Si una tarea
  te supera, dejala `[?]` con explicacion.
- **No tocar modulos 🔵/🔴** de otros agentes (§21.4).

---


---

---

## ACTUALIZACION 2026-09-20 — nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente — **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). M87-Localizacion ya
> esta arriba en la seccion "Tareas"; abajo solo el barrido nuevo.

## PRIORIDAD EXTRA — Barrido de drift de `**Totales:**` (tareas atómicas)

> **Tu fortaleza medida:** análisis documental preciso (M11: 73 cuestiones documentadas
> con líneas reales) + conteos exactos (M11: cero drift). El drift de `**Totales:**` es
> **endémico** en este proyecto (M09, M11, M12, M126/M128/M115, M149 lo sufrieron esta
> semana). Es trabajo **atómico y repetitivo** — ideal para tu límite de tokens.

**Método (por módulo, ~2 min cuno):**
1. Cuenta las marcas con regex: `^(?:\s*)- \[x\]`, `- \[\?\]`, `- \[ \]` en
   `plan-actual/05-Checklist.md`
2. Compáralas con la línea `**Totales:** NNN ítems · Completados: X · No resueltos: Y`
3. **Si no coinciden:** corrije la línea `**Totales:**` (no las marcas)
4. Reporta en tu log: `M09: 100/5/0 (decía 98/7) — corregido`

**Empezá por estos 15 (🟡 con más actividad reciente, drift más probable):**

> ⛔ **SECCIÓN CANCELADA — 2026-09-20 (nex fuera de flujo, directiva del usuario).**
> Estado final de cada tarea (reasignación hecha por atria-dawn):
> - `[~]` = **cancelada como duplicada** — atria-dawn sesión 2 cubre ese módulo en su
>   serie T-DA (159 módulos; lote 1 = M09/M10/M11/M12/M13/M15/M16/M21/M25/M26 ya hecho,
>   Log 1098). **No hacer — trabajo ya asignado a otro.**
> - `[!]` = **congelada** — módulo 🔵 de kimi-k3 (M106/M122). Nadie los toca hasta su
>   regreso (§21.4 + directiva del usuario 2026-09-20).

- [~] **T-D01:** M149 Nombres — cubierto por s2 (T-DA). Además hy3 dejó 99/1 y atria lo
  corrigió y verificó (Log 1092).
- [~] **T-D02:** M09 Terreno — cubierto por s2 (lote 1, Log 1098).
- [~] **T-D03:** M11 Personaje — cubierto por s2 (lote 1, Log 1098).
- [~] **T-D04:** M12 Cámara — cubierto por s2 (lote 1, Log 1098).
- [~] **T-D05:** M31 Ciclo-Día-Noche — cubierto por s2. Además mimo lo reconcilió
  (Log 1095: 54 `[?]` → 49).
- [!] **T-D06:** M106 Seguridad — 🔵 kimi-k3 (congelado hasta su regreso).
- [!] **T-D07:** M122 Crash-Reporting — 🔵 kimi-k3 (congelado hasta su regreso).
- [~] **T-D08:** M52 Partículas — cubierto por s2.
- [~] **T-D09:** M66 Anti-Softlock — cubierto por s2.
- [~] **T-D10:** M25 Ruinas — cubierto por s2 (lote 1, Log 1098).
- [~] **T-D11:** M60 Datos-Y-Serializacion — cubierto por s2.
- [~] **T-D12:** M117 Build-System — cubierto por s2.
- [~] **T-D13:** M87 Localizacion — cubierto por s2; además el módulo es de DeepSeek.
- [~] **T-D14:** M38 Economia — cubierto por s2.
- [~] **T-D15:** M64 IA-De-NPC — cubierto por s2.

**Después de esos 15, extendé el barrido al resto de módulos 🟡** (~40 más). Reportá
lotes de 10 en un log.

**⚠️ Regla obligatoria:** cualquier cambio que hagas se verifica — tú mismo eres la
verificación aquí (conteo regex es objetivo). **No toques marcas `[x]`/`[?]`, solo la
línea `**Totales:**`.** Si una marca te genera dudas, repórtala en el log **sin
cambiarla**.

---
