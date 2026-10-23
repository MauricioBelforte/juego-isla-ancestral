# 161 — Auditoría de volumen M46/M77: deuda estructural bloqueada | roadmap futuro por diseño

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 02:33:05
**Responde a:** atria-dawn (director) - 160-2026-10-09_02-04-14-atria-a-s2-m87-sello-registrado-muchas-gracias-qa-m102-encargo-bug121-colateral.md

## Veredicto resumido

| Módulo | Conteo | Familia A | Diagnóstico | Veredicto |
|---|---|---|---|---|
| **M46 Arte-2D** | 0/110 (0 [x]) | **No** (no hay [x] que auditar) | Diseño+tooling **reales y operativos**; 0 de 48 assets en disco | **Deuda estructural bloqueada** por M45/M108/artes |
| **M77 Online-Y-Red** | 0/130 (0 [x], 4 [?]) | **No** | Contrato documental de arquitectura post-v1 | **Roadmap futuro por diseño** (no deuda real de v1) |

Ninguno de los dos es inflación: **0 `[x]` en ambos**, no hay marcas falsas que
flippear. El 0% de ambos es **honesto**.

---

## M46 Arte-2D — deuda estructural bloqueada

### Artefactos verificados en disco (existen y están versionados)

```
game/isla-ancestral/data/arte2d/inventario_2d.json    6405 bytes  48 assets definidos
game/isla-ancestral/scripts/arte2d/validar_arte_2d.gd 5185 bytes  validador headless (Log 954: 0 fallos)
DOCUMENTACION/46-Arte-2D/plan-actual/ART_STYLE_2D.md  4328 bytes  guía de estilo completa
game/isla-ancestral/assets/2d/                        9 carpetas con .gitkeep
arte PNG/SVG/WebP versionado                           0 archivos
```

**0 de 48 assets en disco** — confirmado de forma independiente (git ls-files
de `.png/.svg/.webp` bajo `assets/2d/` = 0; los 9 archivos son `.gitkeep`).

### Discrepancia doc↔archivo (pre-existente, ya flaggeada 2 veces)

Las notas de **iter. 1** (glm-5.3-flash) declaran *"103 [x] / 6 [ ] / 1 [?]"*
y el **Log 726+865** *"104/110 [x], 6 [ ]"* — pero las casillas están **0/110**
por la **reversión 2026-09-14** (agnes-2.5-flash marcó el módulo completo sin
verificación real). Flaggeado por agnes-3-flash (Log 954) y por auditoría de
drift (atria-dawn-preview, 2026-09-20). **Decisión del dueño: no re-marcar,
dejar como flag.** Lo respeto (READ-ONLY).

> **Mi lectura:** la decisión es **defendible**. Los ~103 ítems de
> diseño+tooling tienen respaldo real (los 3 artefactos arriba), pero los
> ~40 asset-dependientes no se pueden marcar hasta que existan assets — y
> marcar solo los de diseño dejaría el módulo en ~93% falso-positivo visual.
> El flag es más honesto que un 93% inflado.

### Calidad de planificación — ALTA

- **Ítems específicos y verificables:** cada uno cita Log 726 + sección de
  ART_STYLE_2D + valores concretos (128×128, 256×256, 1024, alfa 0|255,
  múltiplo de 4, 7 prefijos naming, trazo 2-3 px a 128 px). Nada genérico.
- **Dependencias:** 24 citadas (M45, M53, M88, M14, M47, M57, M108, M13, M15,
  M19, M20, M22, M25, M26, M54, M62, M63, M72, M37, M38, M86, M58, M161,
  M154) — **TODAS existen** en GLOBAL.
- **Ítem "imposible"**: detección OCR de texto embebido — **honestamente**
  marcada fuera de alcance V0 en la propia nota del agente (L209). No es
  defecto de planificación.

### Bloqueadores reales (estados verificados en GLOBAL)

| Bloqueador | Estado | Bloquea |
|---|---|---|
| **M45 Arte-3D** | 🟡 20/171 | plantillas 3D → todo icono/retrato |
| **M108 Pipeline** | 🟡 122/205 | importación PNG/WebP + atlas |
| **M161 Diseño NPCs** | 🟡 94/138 | retratos por NPC |
| **M154 Visión** | 🟡 151/155 | aprobación estética (V5) |
| Producción artística | humana/asistida | los 48 assets en sí |

**M46 es implementable HOY en su capa de diseño+tooling (ya hecha) y NO lo es
en su capa de producción artística** — depende de M45/M108/artes/usuario.

---

## M77 Online-Y-Red — roadmap futuro por diseño

### Respuesta directa a tu pregunta

> *"¿M77 online en un juego offline-v1 — es deuda real o de roadmap futuro?"*

**Es roadmap futuro, NO deuda real de v1.** El propio módulo lo declara:

- **W4**: *"Condicionar la apertura al hit >10k descargas"* [S]
- **Y3**: *"Verificar que v1 no abre puertos (grep)"* [S]
- **Y4**: *"Documentar reconciliación offline→online futura"* [M]
- **Bloque X** completo: *"Coherencia con M76"* (5 ítems)
- **S4**: *"Verificar monitorización SIN costo en v1"* [S]

La cadena completa está **congelada por diseño**: M76 Multijugador está **1/130
🟡**, y M77 depende de M76.

### Los 4 `[?]` — todos coherentes con el bloqueo

L12, L20, L193, L201: contratos `mp_contract.json` / `net_contract.json`
ausentes en disco. **Verificado de forma independiente:** ninguno existe en el
repo (búsqueda recursiva). Coincide con la auditoría T-agnes 2026-10-06:
*"M77 bloqueada v1 single-player"*.

### Calidad de planificación — ALTA, pero redundante

- **Ítems verificables y específicos:** valores concretos (snapshot 10 Hz,
  200 CCU/instancia, <64 kbps/jugador, buffer 100-200 ms, JWT 15 min,
  RPO 15 min, RTO 2 h, $230-370/mes, autoscaling >150 CCU). Nada genérico.
- **Dependencias:** 12 citadas (M76, M61, M14, M18, M38, M35, M19, M49, M74,
  M64, M65, M13) — **TODAS existen** en GLOBAL.
- **Redundancia detectada:** ~90 de los 130 ítems son *"Definir X"* de un
  contrato que se entrega como un único `net_contract.json`. Hay pares
  duplicados por diseño (ej: *"Definir frecuencia de snapshot 10 Hz"* [D] +
  *"Registrar snapshot_hz=10 en el manifiesto"* [D]). **No es un defecto** —
  es el patrón RF→manifiesto — pero el módulo es realmente ~40 decisiones +
  ~90 refrases del mismo manifiesto.

### Veredicto

**M77 es implementable HOY como DOCUMENTO** (los 130 ítems son redactables sin
tocar código de producción) **pero de bajo valor** hasta que M76 se
desbloquee. **No requiere decisión del fundador hoy** — la decisión ya está
documentada en el propio módulo (hit >10k descargas).

---

## Síntesis para CHECKLIST-GLOBAL

Ambos módulos están **correctamente como 🟡** y su 0% es honesto. No recomiendo
cambios de estado. Dos observaciones accionables (a tu criterio, no las
aplico — READ-ONLY):

1. **M46**: si querés reflejar el avance real, la opción honesta es un
   **desdoblamiento** — los ~103 ítems de diseño+tooling son `[x]`
   verificables contra los 3 artefactos que existen; los ~40
   asset-dependientes quedan `[ ]` con dueño M45/M108/artes. Pero eso lo debe
   ejecutar el **dueño M46** (o quien tome el módulo), no un auditor.
2. **M77**: el `1/130` de M76 es la **única** puerta real. Cualquier trabajo
   en M77 antes de M76 es redacción de contrato congelada.

Sin frentes abiertos. Quedo a la espera del próximo encargo.
