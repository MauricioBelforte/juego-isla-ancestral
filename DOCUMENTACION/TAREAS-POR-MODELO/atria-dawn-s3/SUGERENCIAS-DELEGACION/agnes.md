# agnes-3-flash — Sugerencias de delegación

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Última actualización:** 2026-10-12 02:20

---

## Encargo actual

**M99-Marketing QA cruzado** (155/169) — asignado por el director (msg 307). Verificar los 155
`[x]` contra disco.

## Siguiente: M100-Community-Management

**Estado:** 184/221 (37 `[ ]`), cx 2, 🟡. **agnes es la autora histórica** — el módulo lleva su
marca desde el reclamo §21.4.7.

**Nota de QA propia (msg 160, 2026-10-10):** el núcleo real existe (CommunityManager autoload +
suite 8/0 EXIT 0), drift 0. **5 ítems degradados a `[?]` por el director** porque los artefactos
no están en disco: `roles.json`, `report_categories.json`, `roadmap.json`, `discord_setup.py`,
`steam_announcement.py`. `faq.json` y `changelog.md` SÍ existen.

**Por qué agnes:** es su módulo, conoce el diseño, y los 5 artefactos faltantes son exactamente
su nicho (datos declarativos + scripts de herramienta). Ella puede cerrar la deuda que el QA
propio detectó.

### Lote sugerido

1. **Cerrar los 5 `[?]`** creando los artefactos en disco (roles.json, report_categories.json,
   roadmap.json, discord_setup.py, steam_announcement.py) según el diseño de `03-Diseno.md`.
2. **Avanzar los 37 `[ ]`** restantes por bloques temáticos.

### Encargo listo para reenviar (post-QA M99)

> **Encargo: M100-Community-Management, cerrar 5 `[?]` + lote de `[ ]`.** Lee
> `DOCUMENTACION/100-Community-Management/plan-actual/05-Checklist.md`. Tu QA previo (s3 msg 160)
> dejó 5 `[?]` con artefactos inexistentes en disco: `roles.json`, `report_categories.json`,
> `roadmap.json`, `discord_setup.py`, `steam_announcement.py`. Creá esos 5 artefactos según el
> diseño de `03-Diseno.md` y luego avanzá los `[ ]` por bloques. El núcleo existe
> (CommunityManager autoload + suite 8/0). No toques CHECKLIST-GLOBAL, no commit, UTF-8. Reporta
> en tu canal.

---

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
