# Revisión Legal de Marketing - Isla Ancestral

> **Estado del documento:** revisión de diseño (no es asesoramiento legal profesional).
> **Módulo:** M126-Marketing-Legal (`DOCUMENTACION/126-Marketing-Legal/`).
> **Origen:** ítem `Diseñar legal/marketing_legal_review.md` de
> `plan-actual/05-Checklist.md` (único `[?]` del módulo; artefacto inexistente medido el
> 2026-10-12, barrido Step 5 msg 250). La estructura sigue la plantilla de
> `03-Diseno.md` §2; el contenido se reconcilió contra los datos reales del repositorio
> (medidos el 2026-10-18, Step-5-WorkBuddy).
> **Fecha de esta pasada:** 2026-10-18.

## Convención de estados

- ✅ Verificado: hay artefacto/medición en el repo que respalda la decisión.
- ⏳ Pendiente: falta acción humana, externa o de otro módulo (dueño nombrado).
- ❌ Prohibido: la decisión es "no usar sin requisito".

---

## 1. Derechos de Screenshots

- Screenshots creados in-house (build oficial): ✅ Legal para usar. Política documentada
  en `game/isla-ancestral/data/legal/marketing_legal.json` → `screenshots.in_house`
  (propiedad del desarrollador; obra derivada del propio videojuego).
- Screenshots de mods/UGC: ❌ Requiere autorización escrita del creador antes de cualquier
  uso promocional (`screenshots.terceros_mods_ugc`). Excepción: capturas de la propia
  funcionalidad tomadas por el equipo siguen siendo in-house.
- Screenshots de plataformas: ✅ Permitido bajo las guidelines de cada tienda
  (`screenshots.plataformas`: Steamworks Guidelines y políticas de consola; sin texto
  superpuesto engañoso ni HUD falsificado).

## 2. Derechos de Música

- Música original del estudio: ✅ Legal para usar en marketing
  (`marketing_legal.json` → `musica.original`; cesión de derechos por contrato).
- Música de terceros: ⏳ Solo con licencia de sincronización por pista, documentada antes
  del uso en trailer (`musica.terceros`). Catálogo actual
  (`game/isla-ancestral/data/legal/audio_licenses.json`, 3 pistas):

  | id | licencia | obligación |
  |---|---|---|
  | `aurora_main` | propia | crédito al compositor en créditos del juego |
  | `ost_piano_01` | CC-BY | atribución visible en créditos del trailer |
  | `sfx_ambiente_01` | CC0 | sin obligación |

- Nota CC: las licencias Creative Commons NoComercial ❌ no son válidas para marketing
  comercial (salvo CC-BY/CC0) — regla documentada en `musica.licencias_comerciales`.
- Pendiente: dueño M41/M84 — registrar en `audio_licenses.json` cada pista nueva antes de
  usarla en material público.

## 3. Derechos de Terceros

- Assets originales: ✅ Propiedad del desarrollador. Catálogo de 7 elementos en
  `game/isla-ancestral/data/legal/copyright.json` (código, assets visuales, música,
  narrativa, motor voxel, nombre, logo).
- Fuentes tipográficas: ✅ Licencias comerciales verificadas — Fredoka One y Nunito, ambas
  **SIL Open Font License (OFL) 1.1** (`data/legal/identidad_marca.json` →
  `tipografia`; `data/legal/legal_data.json`). Archivos en disco:
  `game/isla-ancestral/assets/fonts/FredokaOne-Regular.ttf`, `Nunito-Regular.ttf`,
  `Nunito-Bold.ttf`, `Nunito-Variable.ttf`. OFL exige conservar el aviso de licencia y
  prohíbe vender la fuente por separado.
- Software: ✅ Godot Engine — MIT (`THIRD-PARTY-NOTICES.md`; también
  `data/legal/licencias.json`: godot, voxel_tools, gdscript).
- Software de producción (Blender, GIMP): ⏳ La plantilla de `03-Diseno.md` §2 los declara
  GPL; **`THIRD-PARTY-NOTICES.md` (el archivo que se distribuye con el juego) solo cubre
  Godot y Voxel Tools** — medido 2026-10-18, 0 menciones a Blender/GIMP. Pendiente: añadir
  los avisos si el material distribuido los requiere (dueño M126/M06).
- Assets de stock: ⏳ Requiere licencia específica por asset + comprobante de compra
  (`musica.licencias_comerciales` y `terceros` del JSON).

## 4. Branding

- Nombre "Isla Ancestral": ✅ Uso propio protegido por copyright automático (Convenio de
  Berna) y registrado en `copyright.json` (`nombre_juego`, tipo marca_y_copyright).
- Logo: ⏳ Registro formal de marca pendiente pre-lanzamiento
  (`legal/copyright_register.md` §2: `logo_marca` — "pendiente";ver
  `tools/legal/generate_copyright_register.py`).
- Verificación de marcas de terceros: ⏳ **Parcial.** La búsqueda de marcas gratuitas está
  documentada solo para **USPTO** en el módulo M78 (`03-Diseno.md` §5, fila
  "Isla Ancestral", L121); EUIPO/WIPO/INPI siguen sin cobertura — deuda ya degradada a
  `[?]` en M78 (director, msg 305, 2026-10-18). No afirmar clearance global hasta cubrirlos.

## 5. Influencers

- Disclosure (#ad / #sponsored): ✅ Política documentada
  (`marketing_legal.json` → `cumplimientos.influencers_divulgacion`, regla FTC) +
  comunicado a creadores con pautas de embargo:
  `game/isla-ancestral/data/legal/comunicado_creadores_embargo.md` (creado 2026-10-12).
- Protocolo ante retirada del disclosure: ✅ Definido (edge case del checklist de M126).
- Contratos con influencers y pagos documentados: ⏳ Plantillas pendientes de revisión
  legal humana antes de uso (KnownIssue no bloqueante, dueño M126/humano).

## 6. Contratos Promocionales

- Contratos con prensa / plataformas / PR agencies: ⏳ Plantillas pendientes de redacción
  legal (dueño M126/humano). Lineamientos de plataforma (Steamworks) documentados como
  requisito de complimiento.
- Exclusividad y licencias de uso de contenido: ⏳ Según contrato específico.

## 7. Giveaways

- Normativas locales (FTC, GDPR, CAP Code): ✅ Documentadas
  (`marketing_legal.json` → `giveaways`).
- Restricciones (edad, jurisdicción, impuestos) y reglas claras: ✅ Documentadas.
- Participación y confirmación: ✅ Plantilla de confirmación existente —
  `game/isla-ancestral/data/legal/confirmacion_sorteo.md` (creado 2026-10-12).
- Bases de datos de participantes (GDPR/CCPA): ✅ Diseño documentado; ejecución sujeta a
  M80 (Privacidad).

---

## Resumen de la revisión

| Área | Estado | Próxima acción (dueño) |
|---|---|---|
| 1. Screenshots | ✅ | — |
| 2. Música | ⏳ parcial | registrar licencias nuevas (M41/M84) |
| 3. Terceros | ⏳ parcial | avisos Blender/GIMP en THIRD-PARTY (M126/M06) |
| 4. Branding | ⏳ parcial | EUIPO/WIPO/INPI (M78); registro de marca (M126) |
| 5. Influencers | ⏳ parcial | plantillas de contrato (humano/M126) |
| 6. Contratos promocionales | ⏳ | redacción legal (humano/M126) |
| 7. Giveaways | ✅ | — |

**Revisiones que requieren acción humana (no automatizable):** firma de contratos,
registro formal de marca, búsqueda de marcas en EUIPO/WIPO/INPI, redacción de plantillas
legales. Quedan como KnownIssue no bloqueante del DoD §21.6 con dueño nombrado.

**Validación automática existente:** `scripts/legal/marketing_legal_validator.gd` valida
`data/legal/marketing_legal.json` (4 cumplimientos + 2 políticas + 9 secciones de contenido)
con `test_marketing_legal_m126.gd` (9 checks / 0 fallos, gate duro en CI).

---

**Firma:** Step-5-WorkBuddy — 2026-10-18 (evidencia: Log 1968).
