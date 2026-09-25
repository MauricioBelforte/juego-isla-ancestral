# Log 1159: P-45 — mi tajada del merge: auditoría de autoría y cierre de P-36

**Fecha:** 2026-09-25
**Hora:** 04:45
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** el pool dio **primero=1159** justo antes de reservar (el encargo decía 1158; 1158 lo consumió
s2 en su P-44, Log `1158-P-44-Merge-Huerfanos`). Al cerrar, el pool arranca en **1160**. 0 conflictos.

## Resumen

Encargo: commitear "mi bucket A (~90 archivos)" de la clasificación de s2 (`atria-dawn-s2`), agrupado por
M93/M94/P-30/P-32/M106/M122.

**Hallazgo principal (bloqueante para el plan del merge): la atribución de s2 es incorrecta.**
De los 89 archivos que s2 asignó a `deepseek-v4.1-flash`, **ninguno lleva mi firma en el diff**. s2 clasificó
por la firma `**Modelo:**` del **header del archivo** (el último autor *commiteado*, de hace semanas), no por
el autor del **cambio sin commitear**. Los diffs reales son de **Atria-Dawn-Preview / Kilo Code**.

**Lo que sí era mío y quedó commiteado:** los **2 logs de P-36** (1149 y 1150), que habían quedado
**untracked** — el cierre de P-36 commiteó código, docs, `quality.yml` y el BACKLOG, pero **no los logs**.

## Método (medido, no supuesto)

1. Extraje la lista de mi bucket A de `clasificacion_final.txt` (bloque `## deepseek-v4.1-flash`): **89**
   archivos, **los 89 todavía sucios**.
2. Para cada uno miré **solo las líneas AÑADIDAS del diff** (no el header) buscando firmas de autor.
   Resultado de firma dominante: **atria-dawn-preview 72**, (sin firma) 9, agnes 3, glm 3, mimo 2.
   **`deepseek` = 0.**
3. Repetí el barrido sobre **TODOS los 434 sucios+untracked**: solo `CHECKLIST-GLOBAL.md` (compartido,
   bucket C) tenía mi firma en líneas añadidas.
4. Para los 9 "(sin firma)" verifiqué por **log de origen**: M26 y M92 están en los logs de drift
   (`1107`, `1104`); `objetivos.json` es el BUG-061 de atria (Log `1083`); `npc_agent.gd` es M64/M29;
   los `Logs/_*.txt` son scratch ajenos. **Ninguno es mío.**
5. Para los logs untracked, miré el header `**Modelo:**` de **todos**: solo **1149 y 1150** dicen
   `DeepSeek-V4.1-Flash`. El resto de los logs de drift (1098-1108, etc.) son de Atria-Dawn-Preview.

## Lo que commiteé

`7e38f97` — **P-36 (cierre): logs 1149 (M106) y 1150 (M122) que quedaron sin commitear** (2 archivos,
+232/-0). Ambos UTF-8 **sin BOM**, **LF puro**, firmados `DeepSeek-V4.1-Flash / WorkBuddy`.

## Lo que NO commiteé (y por qué)

- **Los ~89 archivos del "bucket A" de s2** → son de **Atria-Dawn-Preview** (drift de `**Totales:**`,
  bloque 1B/1C, 2026-09-19/20). No son míos: la regla del encargo es "archivos de otros modelos → no"
  y "no decidas autoría por mayoría de líneas". Van al **bucket del coordinador** (atria).
- **Los 4 compartidos** (`11-BUGS.md`, `ESTADO-PARALELO.md`, `CHECKLIST-GLOBAL.md`,
  `NUMEROS_DISPONIBLES.txt`) → bucket C del coordinador. Siguen **sin commitear**.
- `DOCUMENTACION/11-BUGS.md` **sí contiene hunks míos** (`**Firma:** DeepSeek-V4.1-Flash / WorkBuddy —
  2026-09-20`, BUG-071/BUG-072), pero es **multi-autor** y está declarado bucket C → no lo toqué.

## Mapa de atribución real (corrige a s2)

| Autor real (diff)      | Archivos (de los 89 "deepseek") |
|------------------------|----------------------------------|
| atria-dawn-preview     | 72 (drift `**Totales:**` bloque 1B/1C) |
| glm-5.3-flash          | 3 (M39 Tiendas 04-Codigo, M92 Tutorial 04-Codigo) |
| agnes-3-flash          | 3 |
| mimo-v2.5              | 2 (M12 Cámara 05-Checklist) |
| atria-dawn (BUG-061)   | 1 (M94 05-Checklist + `objetivos.json`) |
| otros / sin firma      | 8 (M26/M92 drift, npc_agent.gd M64/M29, scratch) |
| **DeepSeek-V4.1-Flash**| **0** |

## Pendiente para el coordinador

1. **Reclasificar**: los ~72 archivos de drift de atria-preview deberían ir a tu bucket (B), no al mío.
   Sin eso, el plan "cada modelo commitea su bucket A" tiene un agujero de ~72 archivos.
2. Los **2 logs de P-36 ya están commiteados** (`7e38f97`); no queda trabajo mío suelto en el worktree.
3. Pool: reservé **1159**; primer libre ahora **1160**.

---

## Apéndice — lista exacta para reclasificar

### atria-dawn-preview (drift) — 77 archivos → bucket del coordinador

- `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/05-Checklist.md`
- `DOCUMENTACION/07-Arquitectura-General/plan-actual/05-Checklist.md`
- `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/101-QA-General/plan-actual/05-Checklist.md`
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md`
- `DOCUMENTACION/108-Pipeline-De-Assets/plan-actual/05-Checklist.md`
- `DOCUMENTACION/109-Herramientas-Internas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`
- `DOCUMENTACION/114-Playtest/plan-actual/05-Checklist.md`
- `DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/123-Modding/plan-actual/05-Checklist.md`
- `DOCUMENTACION/124-Contenido-Generado-Por-Usuarios/plan-actual/05-Checklist.md`
- `DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md`
- `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md`
- `DOCUMENTACION/140-Alpha/plan-actual/05-Checklist.md`
- `DOCUMENTACION/141-Beta/plan-actual/05-Checklist.md`
- `DOCUMENTACION/142-Release-Candidate/plan-actual/05-Checklist.md`
- `DOCUMENTACION/143-Lanzamiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/144-Despues-Del-Lanzamiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/147-World-Building/plan-actual/05-Checklist.md`
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/05-Checklist.md`
- `DOCUMENTACION/151-Control-Final/plan-actual/05-Checklist.md`
- `DOCUMENTACION/16-Crafting/plan-actual/05-Checklist.md`
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/22-Historia-Principal/plan-actual/05-Checklist.md`
- `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/05-Checklist.md`
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/28-Viajes/plan-actual/05-Checklist.md`
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md`
- `DOCUMENTACION/33-Agricultura/plan-actual/05-Checklist.md`
- `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md`
- `DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/40-Infraestructura/plan-actual/05-Checklist.md`
- `DOCUMENTACION/45-Arte-3D/plan-actual/05-Checklist.md`
- `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/05-Checklist.md`
- `DOCUMENTACION/48-Animacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md`
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md`
- `DOCUMENTACION/53-UI-UX/plan-actual/04-Codigo.md`
- `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`
- `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/57-Interfaz-De-Control/plan-actual/05-Checklist.md`
- `DOCUMENTACION/58-Accesibilidad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md`
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/04-Codigo.md`
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/05-Checklist.md`
- `DOCUMENTACION/67-Vehiculos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/04-Codigo.md`
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md`
- `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md`
- `DOCUMENTACION/76-Multijugador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/77-Online-Y-Red/plan-actual/05-Checklist.md`
- `DOCUMENTACION/78-Legal-Propiedad-Intelectual/plan-actual/05-Checklist.md`
- `DOCUMENTACION/79-Legal-Contratos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/80-Legal-Privacidad/plan-actual/05-Checklist.md`
- `DOCUMENTACION/86-IA-Generativa/plan-actual/05-Checklist.md`
- `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/05-Checklist.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/05-Checklist.md`
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md`
- `DOCUMENTACION/94-Retencion-Sin-FOMO/plan-actual/05-Checklist.md`
- `DOCUMENTACION/95-Monetizacion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/96-Plataformas/plan-actual/05-Checklist.md`
- `DOCUMENTACION/97-Steam-Store-Page/plan-actual/05-Checklist.md`
- `DOCUMENTACION/98-Trailer/plan-actual/05-Checklist.md`
- `DOCUMENTACION/99-Marketing/plan-actual/05-Checklist.md`

### otros autores — 3 archivos

- {'mimo': 2} — `DOCUMENTACION/12-Camara/plan-actual/05-Checklist.md`
- {'glm': 1} — `DOCUMENTACION/39-Tiendas/plan-actual/04-Codigo.md`
- {'glm': 1} — `DOCUMENTACION/92-Tutorial/plan-actual/04-Codigo.md`

### sin firma, resueltos por log de origen — 9 archivos

- `DOCUMENTACION/26-Templo-Subterraneo/plan-actual/05-Checklist.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/03-Diseno.md`
- `Logs/_d39.txt`
- `Logs/_estado39.txt`
- `Logs/_t39_test_loop_economico.txt`
- `Logs/_t39_test_tiendas.txt`
- `Logs/_t39_test_tiendas_iter_glm.txt`
- `game/isla-ancestral/data/motivacion/objetivos.json`
- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd`
