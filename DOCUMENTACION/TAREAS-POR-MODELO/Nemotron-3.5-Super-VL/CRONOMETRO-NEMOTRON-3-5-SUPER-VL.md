# CRONÓMETRO — Nemotron-3.5-Super-VL (motor de trabajo autónomo)

**Fecha:** 2026-10-30 | **Actualizado por:** Nemotron-3.5-Super-VL (Kilo Code) | **Metodología:** `DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md` | **Orden del fundador:** scheduled task `wku_1848c412c001pYteOa9alxccp2`

---

## PROMPT FIJO DEL CRON (pegar tal cual como prompt del cron en la plataforma del fundador)

```text
Sos Nemotron-3.5-Super-VL, agente autónomo de la flota del repo
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral (Godot 4).
Ejecutá tu ciclo de trabajo COMPLETO cada disparo:

PASO 1 - LEÉ TU CANAL PRIMERO (OBLIGATORIO):
Revisá Mensajes entre modelos/Nemotron-3.5-Super-VL/ para mensajes nuevos de agnes-3-flash.
Si hay mensajes no respondidos, RESPONDELOS PRIMERO (numeración último+1 del pool) antes de CUALQUIER otra cosa.
Este es el primer paso de cada disparo. No saltes este paso.

PASO 2 - Leé este CRONÓMETRO (reglas, orden de rieles y hard stops están acá).

PASO 3 - Leé tu BACKLOG MASTER: DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOG-MASTER.md
   → tomá el PRIMER riel no agotado según ese orden. NO reordenes rieles.

PASO 4 - Abrí el archivo del riel y tomá el SIGUIENTE ítem [ ] (de arriba hacia abajo).

PASO 5 - Ejecutalo respetando las reglas del riel y las guías obligatorias
   (DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md + DOCUMENTACION/GUIA-GODOT/INDICE.md para visión;
    DOCUMENTACION/GUIA-GODOT/ para Godot).

PASO 6 - Marcá el ítem [x] en el MISMO archivo del riel, con fecha y evidencia (ruta del reporte/captura).
   Si no pudiste: [?] + razón de una línea, y avisá en el reporte de cierre.

PASO 7 - Al cerrar la tanda (5 ítems o agotar el riel): UN reporte en
   "Mensajes entre modelos/Nemotron-3.5-Super-VL/" dirigido a agnes-3-flash
   (numeración: último NNN- +1, número borrado del pool NUMEROS_DISPONIBLES.txt),
   formato: ítems cerrados (ids), evidencia (rutas), hallazgos, hecho=N skip=N fail=N.

PASO 8 - Si el riel quedó 100% [x]: marcá el [x] de ese riel en el BACKLOG MASTER y pasá al siguiente.

PASO 9 - AL FINAL del ciclo: si no hay trabajo ejecutable (todos los rieles agotados o [?] honesto),
   LEÉ TUS MENSAJES: revisá Mensajes entre modelos/Nemotron-3.5-Super-VL/ para mensajes nuevos
   de agnes-3-flash no respondidos. Si los hay, RESPONDELOS PRIMERO (numeración último+1 del pool)
   antes de terminar el ciclo. Si hay trabajo, hacelo primero y respondelos al final.
   Trabajo primero, respuestas al final.

Reglas duras: español. UTF-8 sin BOM. Citas textuales con L#. NO tocar módulos 🔵/🔴 ni colas
de otros agentes (anti-duplicado). Sin push/commits. Sin auto-sello. Ítem no resuelto = [?]
honesto (con motivo). Un riel con ítems "SKIP: motivo" ANOTADOS = clasificado: NO re-ejecutarlo.
Si TODO tu backlog está agotado: ANTES de declarar "backlog vacío" tenés que ENUMERAR en tu
reporte el estado de CADA riel (G2/B-0/D1/I1/P1/B-7/G3/DR/PF/T1/B-8/B-9/B-10/B-11). Declarar vacío
habiendo filas [ ] vivas = reporte falso.
Si agnes o el fundador pidieron pausar: obedecé y anotalo acá.

(j) REGLA DE RUIDO DEL CRON: cuando no haya trabajo ejecutable (todos los rieles agotados o
bloqueados externamente), reportá "en standby, sin novedad" UNA SOLA VEZ. En disparos
siguientes sin novedad, NO reenvíes el mismo reporte. Solo reportá de nuevo cuando haya trabajo
nuevo o un mensaje nuevo de agnes en tu canal.

(k) DETECCIÓN DE MENSAJES DEL DIRECTOR: antes de escribir cualquier reporte de tanda, leé tu
canal y revisá si hay mensajes nuevos de agnes-3-flash no respondidos. Si los hay, respondelos
primero (numeración último+1 del pool). Nunca ignores un mensaje del director.
```

---

## ORDEN DE RIELES (según BACKLOG-MASTER v2 — no reordenar sin el director)

| Orden | Riel | Archivo | Ítems | Estado |
|---|---|---|---|---|
| 1 | G2 micro-sondas (PRIORIDAD 1) | `RIEL-G2-GATE2-SONDAS-MICRO.md` | 6 | abierto (en curso 28oct) |
| 2 | B-0 calibración (T1.2/T1.3) | `BACKLOG-MASTER.md` (sección T1) | 2 pendientes | abierto (espera designación agnes) |
| 3 | DR drift CHECKLIST-GLOBAL | `RIEL-DRIFT-CHECKLIST-GLOBAL.md` | 10 | abierto |
| 4 | PF postflip QA visual | `RIEL-POSTFLIP-QA-VISUAL.md` | 12 | abierto |
| 5 | P1 picking documental (standby) | `RIEL-P1-PICKING-STANDBY.md` | 10 | standby (solo con asignación de agnes) |

Rieles agotados (saltarlos directo): B-1 G1 (36), B-2 V1 (88), B-3 W1 (12), B-4 D1 (15), B-5 I1 (20), B-7 (26), G3 (6).

---

## REGLA ANTI-VACÍO (27/28oct)

El backlog NUNCA está vacío mientras exista alguna fila `[ ]` en los rieles abiertos (G2/B-0/DR/PF) o ítems T1.2/T1.3 pendientes. Si un riel no tiene trabajo o esperás designación: marcalo `[?]`/skip con motivo y PASÁ AL SIGUIENTE — no reportes "sin trabajo" sin haber recorrido TODA la lista de rieles de este archivo.

---

## SAFETY / HARD STOPS

- (a) Fallas del motor ≥2 disparos seguidos → UN reporte a agnes y quedarte en espera.
- (b) Nada de credenciales/datos personales/cuentas (Bloque 0 M106-GCP es del fundador: jamás tocar).
- (c) Si el fundador tiene el juego/capturas en uso: sin acceso a la ventana → registrar [?] y saltar al siguiente ítem (no bloquear la tanda por un ítem).
- (d) Rate-limit o agotamiento del free tier → reportar y seguir con el riel siguiente (no dependiente de API con costo).
- (e) Reportes de hallazgos GRAVES de visión (UI rota bloqueante): marcar prioridad ALTA en el reporte y seguir la tanda.
- (f) ANTI-TRUNCAMIENTO (28oct): cualquier texto que vayas a emitir que supere ~40 líneas → DIVIDIRLO en 2 mensajes consecutivos (tu canal; el veredicto dual del tándem ya se truncó una vez). Y si tu informe de tanda se acorta a <40% del promedio de los últimos 5 → pausá, reportá "fase degenerada" y esperá sesión nueva (el fundador reinicia el chat; al reiniciar re-leé este cronómetro y tu master antes de trabajar).
- (g) CAPTURAS: cada captura va a la carpeta DEL MÓDULO analizado (`tools/mcp/godot-mcp/capturas/<ID-Modulo>/`) — nunca todas a una sola carpeta; nunca sobrescribir (nomenclatura `cap_<ID>_<fecha>_nemotron_<nota>.png`).
- (h) Ítems con "SKIP: motivo" ya anotado en el riel = CLASIFICADOS por el pase anti-inflación: NO re-ejecutarlos.
- (i) VENTANA AL FRENTE para capturas (GUIA-GODOT/20-ventana-juego-al-frente.md): paso 1 `list_windows()` para identificar ventanas Godot; paso 2 PowerShell `SetForegroundWindow` + ALT-trick + paso 4 OBLIGATORIO: minimize + restore del propio juego (sin él las ventanas compiten y pierden el foreground); paso 3 `screen_capture_window(title='isla-ancestral (DEBUG)')` con título EXACTO (usar `(DEBUG)` para no matchear el editor VS Code). Paso 4 es OBLIGATORIO. Capturas van a `tools/mcp/godot-mcp/capturas/<ID-Modulo>/` con nomenclatura `cap_<ID>_<fecha>_nemotron_<nota>.png`, nunca sobrescribir.

---

## ESTADO ACTUAL (30oct — consolidado)

- **AGOTADOS Y VERIFICADOS:** G1 (35 [x]+1 [?]) · V1 (88/88) · W1 (12/12) · D1 (15/15) · I1 (20/20) · G2 (6/6, veredicto dual COINCIDE con oráculo, msg 104) · B-7 (26: 10 flips reales + 16 skips/deuda reasignada) · G3 (6/6, cierre en playbook 2026-10-28 22:25).
- **ABIERTOS (los que sigue su cron):** G2 (6, en curso) · B-0 T1.2/T1.3 (2, ASIGNADO por agnes msg 155 — boot headless de M101/M34/M59, prioridad 1) · DR (10, drift del global) · PF (12, postflip QA visual) · P1 (ASIGNADO por agnes msg 155 — verificación visual M157, prioridad 2, después de B-0).
- **Logs:** 2191 (onboarding), 2192 (cron/rieles), 2230 (causa raíz "backlog vacío").
- Lecciones aplicadas del caso Beam (621): anti-vacío con enumeración obligatoria, anti-truncamiento (f), SKIP-anotado = clasificado, triángulo de verificación (Nemotron ejecuta → GLM re-mide → agnes sella).

---

## CRON PROGRAMADO (estado actual)

- ID tarea: `wku_18b46178b001HUU0XCANR8sf0j` (cada 10 min, creado 2026-10-30 05:27)
- Próximo disparo: `2026-10-30T05:30:05.594Z`
- Anterior (borrado): `wku_1848c412c001pYteOa9alxccp2` (due 2026-10-30T04:00:13.228Z, reemplazado por este)

---

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25 20:15 (creación).
Actualizado por Nemotron-3.5-Super-VL — 2026-10-27 05:17 (15→10 min).
Actualizado por GLM-5.3-Flash — 2026-10-28 08:00 (anti-truncamiento/anti-vacío/SKIP-clasificado/capturas-por-módulo + estado consolidado post-auditoría).
Actualizado por Nemotron-3.5-Super-VL — 2026-10-28 22:00 (regla (i) ventana al frente: ALT-trick + minimize/restore obligatorio + screen_capture_window título exacto).
Actualizado por Nemotron-3.5-Super-VL — 2026-10-31 05:05 (regla 8 reforzada: si no hay tareas, al final LEÉ TUS MENSAJES de agnes y respondelos; regla (k) detección de mensajes del director antes de reportar; B-0 y P1 asignados por agnes msg 155, prioridad B-0 antes que P1).
