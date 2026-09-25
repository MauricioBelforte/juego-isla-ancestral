**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — nex-n2.5-pro

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** Tareas atomicas con verificacion obligatoria (contexto chico)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente nex-n2.5-pro --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 87-Localizacion (7 pendientes)

- [?] **T-001 87:** Respetar los ajustes de accesibilidad de texto de M58 sin romper layouts [M] -- **M53**. iter. 6: medido con `AnalizadorLayout` a los tamaños equiv...
- [?] **T-002 87:** Garantizar revisión humana de las traducciones antes del lanzamiento [C] -- **revisión humana (usuario)**. No es automatizable: el módulo aporta la...
- [?] **T-003 87:** Integrar M53: labels de UI usando tr_key en vez de texto estático [M] -- **M53**. iter. 6: el mecanismo de M87 está provisto y probado — un nodo de...
- [?] **T-004 87:** Integrar M53: tooltips y descripciones traducidos [S] -- **M53**. iter. 6: `RetraductorUI` ya soporta la propiedad `tooltip_text` vía el metadato `...
- [?] **T-005 87:** Integrar M58: el tamaño de texto ajustable no rompe la traducción [M] -- **M53**. iter. 6: el análisis responde a la escala de forma monótona (bloq...
- [?] **T-006 87:** Integrar módulos de contenido (M14-M39): items, misiones, tiendas y diarios con claves M87 [C] -- **M14-M39 (26 módulos de contenido)**. El catálog...
- [?] **T-007 87:** Integrar M29/M30: fechas y horas mostradas en formato localizado [M] -- **M29/M30**. La API está lista y probada en M87: `LocaleUtils.format_date()...

---

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

- [ ] **T-D01:** M149 Nombres (hy3 dejó 99/1, decía 100/0 — **ya corregido por atria, verificalo**)
- [ ] **T-D02:** M09 Terreno (atria corrigió 100/5 vs 98/7 — verificar)
- [ ] **T-D03:** M11 Personaje (nex: 50/73/0 vs Totales — tú lo hiciste, verifica)
- [ ] **T-D04:** M12 Cámara (57/45 vs Totales)
- [ ] **T-D05:** M31 Ciclo-Día-Noche (115/54/0 vs Totales)
- [ ] **T-D06:** M106 Seguridad (145/0/61 vs Totales)
- [ ] **T-D07:** M122 Crash-Reporting (185/0/80 vs Totales)
- [ ] **T-D08:** M52 Partículas (137/1/10 vs Totales)
- [ ] **T-D09:** M66 Anti-Softlock (109/8/0 vs Totales)
- [ ] **T-D10:** M25 Ruinas (107/0/15 vs Totales)
- [ ] **T-D11:** M60 Datos-Y-Serializacion (189/4/3 vs Totales)
- [ ] **T-D12:** M117 Build-System (92/18/0 vs Totales)
- [ ] **T-D13:** M87 Localizacion (129/7/0 vs Totales)
- [ ] **T-D14:** M38 Economia (158/0/? vs Totales)
- [ ] **T-D15:** M64 IA-De-NPC (100/?/? vs Totales)

**Después de esos 15, extendé el barrido al resto de módulos 🟡** (~40 más). Reportá
lotes de 10 en un log.

**⚠️ Regla obligatoria:** cualquier cambio que hagas se verifica — tú mismo eres la
verificación aquí (conteo regex es objetivo). **No toques marcas `[x]`/`[?]`, solo la
línea `**Totales:**`.** Si una marca te genera dudas, repórtala en el log **sin
cambiarla**.

---

## Meta

7 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
