# Log 1580: Director — BUG-052 limpieza autorizada · M11 núcleo 81/0 · M107 blq2 · player.gd sucio derivado a s2

**Fecha:** 2026-10-10
**Hora:** 05:30
**Modelo:** atria-dawn (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Tres entregas procesadas con verificación independiente. BUG-052 medido y limpieza autorizada
(434=418+16 confirmado por el director). M11-Personaje-Del-Jugador: núcleo aditivo de DeepSeek
aceptado (81/0) con dos correcciones de premisa al director y resolución de 3 divergencias de
diseño. M107 bloque 2 de Hy3 aceptado (25 LEGIT / 5 BORDE / 0 SIN RESPALDO). Hallazgo crítico:
player.gd sucio por refactor de M156 sin commitear — derivado a s2.

## Cambios Realizados

### BUG-052 — Limpieza AUTORIZADA (mimo, Log 1575)

Medición de mimo verificada de forma independiente por el director:
- `.glb` totales en `assets/3d`: **434** ✓
- En `media/Obsoletos/`: **16** ✓
- Activos: **418** ✓

Auditoría de los 16: 15 con MD5 idéntico a su homónimo activo (duplicados byte a byte) + 1 versión
previa (`conejo_v5` → `36-Fauna_conejo.glb` en `alta/`+`media/`) + **0 referencias** en todo
`game/isla-ancestral/` + tracked en git.

**Decisión: LIMPIAR, NO subir el trinquete.** El razonamiento de mimo es correcto: el validador
excluye Obsoletos y siempre cuenta 418; subir `max` a 434 regalaría +16 de holgura fantasma (16
GLBs nuevos sin copyright pasarían sin que `--check` falle). Mover deja techo=conteo=418.

Autorizado: `Move-Item media/Obsoletos → Obsoletos/2026-10-10_...glb-respaldos-assets-3d -Recurse`
+ 3 verificaciones obligatorias (disco 418, validador 418/418 EXIT 0, runner EXIT 0). **El flip de
BUG-052 lo hace el director cuando mimo reporte las verificaciones verdes.**

### M11-Personaje-Del-Jugador — núcleo aditivo aceptado (DeepSeek, Log 1576)

**Dos correcciones de premisa al director, ambas verificadas y aceptadas:**
1. M11 **no** es "Sistema-De-Combate" — es **11-Personaje-Del-Jugador** (GLOBAL fila 89). El combate
   vive en **M164**. Error del director.
2. Los 70 pendientes son **`[?]`**, no `[ ]` — M11 tiene **0 huecos reales** (53/70/0 = 123
   verificado).

**Núcleo aditivo en 3 scripts nuevos** (`player_fsm.gd`, `player_energy.gd`,
`character_selector.gd`) + suite `test_player_core_m11.gd` **81 checks, 0 fallos, EXIT 0 ×3**. Los
4 artefactos verificados por el director.

**Decisión de no tocar player.gd aprobada y elevada a regla:** cuando un archivo del worktree esté
sucio por trabajo ajeno sin commitear, **nunca mezclar el trabajo ahí** — escribir código aditivo en
archivos nuevos.

**Resolución de divergencias:**
- **D1 energía: 1/minuto gana.** `01-Requerimientos.md:70` fija la regla cozy del fundador ("la
  energía NUNCA llega a cero por caminar o correr"); 12/s del diseño la contradice (100/12 = 8,3 s).
  DeepSeek debe cambiar las constantes. `03-Diseno.md:18` queda como deuda de corrección documental.
- **D2 estados: 11 gana.** RF4 lista 9 (mínimos); `03-Diseno §2` enumera 11 (expansión de
  implementación). RF4 queda como deuda: actualizar a 11.
- **D3 rango interacción (4m vs 2.5m):** es de M70, no de M11. Derivada a su dueño.

### M107-Backups — bloque 2 aceptado (Hy3)

30 ítems (L66-L105): **25 LEGIT / 5 BORDE / 0 SIN RESPALDO.**
- **Hallazgo central: el patrón de inflación del bloque 1 NO se repite.** Los 22 ítems del salto en
  C/D/E/F tienen 17 LEGIT y 5 BORDE — 0 fabricados. La inflación se concentró en las secciones A/B
  (ítems declarativos fáciles de inflar); las de implementación con artefactos reales no se
  inflaron.
- **5 BORDE quedan `[x]`** (L67-69: mapeo por-tipo en `backup_categories.json` no §4; L90:
  `RetentionCount` no `RetentionDays`; L93: `tar.exe` no `Compress-Archive`). Corrección de texto de
  citas autorizada de forma opcional.
- **M107 sin cambios de marcas este bloque: sigue 149/6/21.**
- Distinción base-47 vs salto confirmada como la señal más fiable de la auditoría.

### player.gd sucio — derivado a s2 (URGENTE, bloquea M11)

`git diff HEAD --numstat` = **42/13 en player.gd**, refactor de M156 **sin commitear** que **borró
`_equip_speed_mult`**. Consecuencias: `test_player_m11.gd` ROJA en el worktree (bloque C5,
`[FALLO] Bloque faltante: C`, EXIT 1; en HEAD sí existe) y DeepSeek no puede cablear su núcleo a
`Player.tscn`. s2 debe commitear o descartar + restaurar/actualizar la suite. Derivado como urgente.

### Colisión de pool 1559 (histórica)

DeepSeek reportó colisión nueva: `1559-m100-bloque-3` vs `1559-qa-21-8-m156`. Anterior a los fixes
anti-colisión (s2 57d1605) y anti-fantasma (s3 061258d) — es histórico, no activo. Registrado.

## Respuestas enviadas (4)

- **mimo #97**: BUG-052 limpieza autorizada con plan + 3 verificaciones obligatorias, trinquete
  intacto en 418, cola (M3 CJK/BOM, BUG-119 opcional).
- **DeepSeek #135**: núcleo aceptado, 2 correcciones de premisa aceptadas, D1/D2 resueltas, M156
  derivado (no le bloquea), próximo paso: cambiar constantes a 1/minuto y re-correr suite.
- **Hy3 #125**: bloque 2 aceptado (0 SIN RESPALDO), 5 BORDE mantenidos `[x]` con corrección de
  texto opcional, bloque 3 asignado (L106-L139) con alerta sobre "15 puntos sección 106".
- **atria-dawn-s2 #195**: player.gd sucio derivado como urgente — commitear o descartar + suite
  verde, bloquea a DeepSeek.

## Reglas nuevas

1. **Archivo sucio por trabajo ajeno = código aditivo, nunca mezcla.** (De la decisión de DeepSeek
   en M11, elevada a regla.)
2. **Directivas del usuario en `01-Requerimientos.md` ganan sobre `03-Diseno.md`** ante
   contradicción (D1: regla cozy). El Diseño queda como deuda de corrección documental.
3. **RF4 fija mínimos, no techo:** cuando Requerimientos lista N y Diseño expande a N+k, gana el
   Diseño para implementación; RF4 queda como deuda de actualización.
4. **"0 hits del término literal" ≠ "no respaldado".** (Caso L112 de M113: rechazado por término
   literal, reaceptado con evidencia conceptual.)

## Archivos Modificados/Creados

- 4 mensajes en canales + este log.
- **Sin flips de marcas este ciclo** (las 3 entregas eran reportes/decisiones; BUG-052 se flipea al
  recibir las verificaciones de mimo).

## Pendientes

- **mimo**: ejecutar limpieza BUG-052 + 3 verificaciones → director flipea.
- **DeepSeek**: cambiar energía a 1/minuto + re-correr suite 81 → reportar nuevo conteo.
- **s2 (URGENTE)**: resolver player.gd sucio → después QA §21.8 M156.
- **Hy3**: M107 bloque 3 (L106-L139).
- **agnes**: M107 ronda 3 (6 `[ ]`) → M113 bloque 3.
- **Step 5**: BUG-034 (42 filas QA-SEALS).
- **s3**: QA §21.8 de M110.
- **BUG-119** (race terreno M163); **BUG-120** (M112, sin dueño).
- **PUSH CENTRALIZADO** pendiente de confirmación del usuario.
