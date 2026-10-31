# SOP-CHECKLIST-CONTRA-DISCO.md — Cómo armar/verificar un 05-Checklist contra disco (patrón anti-inflación)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 (encargo de agnes-3-flash msg 326, tarea #4 de la TANDA AUDITORÍA/DOC)
**Origen:** metodología validada en M157 (scaffold 8/132, 0 inflación, gate-1 agnes OK) y en auditorías de QA cruzado §21.8.2.b; complementa `GUIA-GODOT/` y el protocolo AGENTS.md §21.

---

## 0. Principio rector

> Un ítem `[x]` solo existe si su artefacto está en disco HOY, verificable por un tercero con un comando.
> "Está planificado", "va en la iteración 2", "el claim del agente dice que sí" = **NO** es `[x]` (es `[ ]` con spec, o `[?]` si el agente fue honesto sobre no poder verificarlo).

Inflación = la diferencia entre lo que el checklist DECLARA y lo que el disco SOSTIENE. Esta SOP existe para que esa diferencia sea 0 antes de que un QA cruzado la encuentre.

## 1. Fase 0 — Alcance y reglas de engagement

1. Un módulo por vez; no tocar módulos 🔵 de otros agentes (§21.4).
2. Leer primero: `plan-actual/05-Checklist.md` del módulo + fila del módulo en `CHECKLIST-GLOBAL.md` + últimas `## Notas del Agente` del `04-Codigo.md`.
3. Objetivos de la verificación: (a) ítems `[x]` sustentados, (b) conteos coherentes, (c) `[?]` honestos, (d) referencias futuras declaradas como tales.

## 2. Fase 1 — Conteos reales (drift)

Comandos (PowerShell-safe: usar Python o Grep tool, nunca `grep` de bash en este repo):

- Contar `^- \[x\]`, `^- \[ \]`, `^- \[\?\]` en el `05-Checklist.md` (regex multilínea).
- Comparar contra la línea **Totales** del propio checklist y contra el **Progreso** de la fila en `CHECKLIST-GLOBAL.md`.
- **Drift > 0 = señal de alarma**: alguien flipó sin actualizar totales (o viceversa). Discrepancia > 5 ítems se reporta aunque no haya inflación (regla §21.8.2.b).

## 3. Fase 2 — Muestreo (§21.8.2.b)

1. **Tamaño**: mínimo 5 ítems `[x]` o el 5% de los `[x]`, lo que sea mayor.
2. **Selección**: ítems con **verbos de creación** (crear, implementar, escribir, generar, agregar, configurar, integrar, conectar, construir, añadir) — NO ítems de revisión ni meta.
3. **Registrar**: ítem textual exacto + línea del checklist.

## 4. Fase 3 — Verificación por ítem (contra disco)

Por cada ítem muestreado, en este orden:

1. **¿El ítem cita un artefacto (ruta/archivo)?** → `glob` / `Test-Path` / `git ls-files`. No existe = ítem sin sustento.
2. **¿El ítem nombra función/clase/signal/nodo?** → `grep` sobre `scripts/` (y `scenes/` si aplica). **≥1 hit** = sustento; 0 hits = ítem NO hecho (regla de evidencia negativa).
3. **¿El ítem afirma un SISTEMA ("Agregar X al jugador", "conectar Y con Z")?** → grep del nombre del componente sobre `scripts/` + `scenes/`. 0 hits = ítem no hecho.
4. **¿El ítem es documental (firma, log, cita)?** → verificar el archivo/log citado existe y contiene lo afirmado (ej: firma `**Modelo:**` presente).
5. **Aritmética**: si el ítem afirma números (ej: "82 checks"), contrastar con el log/suite citado.

### Casos especiales (no son inflación)

- **Referencia futura honesta**: ítem que apunta a un archivo que se creará al ejecutar (ej: "06-Plan-Testings" antes de existir) es válido SOLO si el doc lo declara explícitamente ("crear al ejecutar; no existe aún"). Sin la declaración = ítem roto.
- **Normalización de formato**: "M01" vs "M019" vs "1" vs "01" — normalizar int↔int (cero-adelante) ANTES de declarar cita rota. Un falso positivo de formato desacredita la auditoría (lección v18 Ling: primer pase dio 1 cita rota falsa por comparar "1" vs "01"; corregido y re-verify).
- **Deferral honesto**: "planificado para iteración 2" NO rescata un ítem que afirma existencia hoy → degradar a `[?]` con razón (regla M114 / criterio L196: ¿el ítem afirma que algo EXISTE hoy?).

## 5. Fase 4 — Veredicto y acciones

| Resultado del muestreo | Veredicto | Acción |
|---|---|---|
| 0-1 fallas de 5 | Sello válido | Anotar fallas como deuda; no degradar |
| ≥2 fallas de 5 | **Sello DENEGADO** | Módulo vuelve a 🟡; ítems sin sustento → `[?]`; informar al director |

- **Drift de conteo**: reportar siempre (síntoma más fiable de edición de marcas sin actualizar totales).
- **Greps de evidencia negativa** obligatorios cuando el ítem afirma existencia de sistema.

## 6. Fase 5 — Escribir el checklist NUEVO (cuando toca crearlo, caso M157)

1. **Fuentes primarias obligatorias**: `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` (checklist maestro 600+) y `Plan-de-produccion.md` (desglose por disciplina).
2. **Granularidad verificable**: no "hacer el sistema" sino "implementar detección de colisión del jugador con objetos interactuables".
3. **Mínimo 100 ítems** (AGENTS §3), con estimación de esfuerzo `[S]/[M]/[C]` opcional.
4. **Marcas iniciales honestas**: solo `[x]` lo que YA existe en disco con cita (ej: M157 empezó 4/132 con los 4 ítems de documentación realmente creados + cita verificable); el resto `[ ]`. NUNCA `[x]` "por defecto" ni por ser parte del scaffold.
5. **Sección de trazabilidad** (índice de requisitos maestro → ítems) y **índice de conteos** (`Totales: N [x] / M [ ] / K [?] = T`) mantenidos al día en cada flip.

## 7. Fase 6 — Registro del informe

Todo informe de verificación incluye: conteos medidos (x/y/z=total), ítems muestreados con verbo, resultado por ítem (sustento/0 hits), veredicto, drifts, y firma `**Modelo:**` / `**Plataforma:**` / fecha. Sin firma = informe inválido (trazabilidad §3 AGENTS).

## 8. Lecciones duras (casos reales del proyecto)

- **M156 (2026-10-09)**: inflación confesa — el implementador marcó 7 `[x]` que NO hizo argumentando "mejor [x] que [x] falso". Regla reforzada: `[?]` honesto siempre gana sobre `[x]` falso; QA cruzado deniega sello con ≥2 fallas.
- **M157 (2026-10-29/30, este riel)**: scaffold 4→8/132 con cita+grep por ítem; auditoría de citas propia (0 rotas tras normalización int↔int); agnes gate-1: "0 inflación". Patrón bueno a replicar.
- **M01 (v18)**: falso positivo de formato (cero-adelante) — normalizar antes de gritar "cita rota".
- **Muestreador P-100 (Log 2249)**: la herramienta de QA también se audita — dio OK con muestra vacía y huecos falsos por extensión suelta; parcheada con corte CIEGO + exit 3. Toda herramienta de verificación necesita su sonda en rojo.
- **qa_dirty_item4 (BUG-152, Logs 2255/2259)**: suite muerta que termina sin fallar = cobertura FALSA. Verificar que las suites citadas como evidencia no estén muertas (grep de la función invocada en el target).

## 9. Comandos de referencia (repo actual)

```
# Conteos de marcas (Python, UTF-8):
python -X utf8 -c "import io,re; t=io.open(r'...05-Checklist.md',encoding='utf-8').read(); print(len(re.findall(r'^- \[x\]',t,re.M)), len(re.findall(r'^- \[ \]',t,re.M)), len(re.findall(r'^- \[\?\]',t,re.M)))"
# Evidencia de sistema (0 hits = no hecho):
# usar Grep tool sobre scripts/ y scenes/ con el nombre del componente
# Artefacto citado existe:
# usar Glob tool con la ruta citada
# Estado en git (committed vs WT):
git -C <repo> ls-files -- <path> ; git -C <repo> status --porcelain -- <path>
```

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-30 02:45 (local -03:00). Encargo agnes msg 326, tarea #4 de 5.
