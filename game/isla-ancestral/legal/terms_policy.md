# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-18

# Política de Términos — Isla Ancestral

**Versión:** 1
**Fecha de vigencia de la versión 1:** 2026-01-01
**Fecha de redacción de este documento:** 2026-10-18
**Desarrollador:** [Estudio Independiente] — Argentina
**Ámbito:** sitio web oficial (versión pública y resumida)

---

## 0. Qué es este documento (y qué no es)

Este archivo es la **versión pública y resumida** de los términos de *Isla Ancestral*, pensada
para el sitio web: lenguaje llano, una materia por sección, sin cláusulas de detalle.

**No sustituye** al documento contractual del juego:
`game/isla-ancestral/legal/terms_of_service.md` (en adelante, **ToS**). Ante cualquier
discrepancia, omisión o diferencia de redacción **prevalece el ToS**.

Consecuencias prácticas de esa jerarquía:

- Este documento **no crea derechos** que el ToS no reconozca.
- Este documento **no relaja** ninguna obligación del ToS (una política web más generosa que el
  contrato sería un pasivo legal, no un beneficio).
- Si el ToS cambia, este documento se re-redacta; mientras eso no ocurra, el ToS es la fuente.

Este documento **no es asesoramiento legal** y no reemplaza la revisión por un abogado (ver §13).

### Correspondencia con el ToS

| Materia | ToS | Este documento |
|---|---|---|
| 1. Aceptación | §1 | §1 |
| 2. Licencia de uso | §2 | §2 |
| 3. Cuentas de usuario | §3 | §3 |
| 4. Conductas prohibidas | §4 | §4 |
| 5. Contenido generado por el usuario | §5 | §5 |
| 6. Cancelación y reembolsos | §6 | §6 |
| 7. Responsabilidad | §7 | §7 |
| 8. Cambios del servicio | §8 | §8 |
| 9. Terminación | §9 | §9 |
| 10. Jurisdicción | §10 | §10 |
| 11. Contacto | §11 | §11 |

---

## Versión y fechas (declarado, no inferido)

| Fuente | Valor | Qué significa |
|---|---|---|
| `scripts/legal/terms_config.gd:11` | `terms_version = 1` | versión que exige el runtime |
| `scripts/legal/terms_config.gd:12` | `terms_date = "2026-01-01"` | fecha que el runtime asocia a la versión 1 |
| `legal/terms_of_service.md` (cabecera) | `Versión 1.0` · `Fecha: 2026-10-03` | redacción del ToS |
| `data/legal/terminos.json` | 5 secciones + `version_fechada` / `aceptacion_explicita_al_iniciar` | contenido que muestra el juego |
| este documento | `Versión 1` · redacción 2026-10-18 | resumen público del ToS v1 |

**Diferencia declarada:** el runtime configura `terms_date = "2026-01-01"` mientras el ToS está
fechado `2026-10-03`. Este documento **no elige una fecha por su cuenta**: reproduce `2026-01-01`
como fecha de vigencia de la versión 1 (es la que el juego asocia a esa versión) y declara
`2026-10-03` como fecha de redacción del ToS. **La unificación de ambas fechas es un pendiente del
módulo M125, no de este resumen**; si se unifican, este bloque debe actualizarse en el mismo acto.

El número de versión coincide en las tres fuentes (`1`): no hay discrepancia de versión.

---

## Resumen ejecutivo (TL;DR)

*Isla Ancestral* es un juego **gratuito de jugar** y **offline-first**: se puede jugar sin crear
cuenta. Al iniciarlo por primera vez se muestra una pantalla de aceptación; si no estás de
acuerdo, se cierra el juego y no se juega.

- Licencia personal, no comercial, revocable y no transferible.
- Se permiten capturas, clips, streams, reseñas y mods no comerciales.
- En v1.0 no hay cuentas ni contenido generado por usuarios: el juego es single-player.
- Las devoluciones se rigen por la política de la tienda donde se compró (Steam), no por este sitio.
- Jurisdicción: Argentina. GDPR/CCPA para usuarios de la UE y de California.
- El juego se entrega "tal cual", con la limitación de responsabilidad del ToS §7.

---

## 1. Aceptación de los términos

**En el sitio:** al descargar, ejecutar o utilizar el juego o sus materiales aceptás el ToS. La
aceptación explícita ocurre en la pantalla de primer lanzamiento; este sitio no recoge una
aceptación distinta ni adicional.

**Detalle contractual:** ToS §1. Si el ToS cambia, se avisa con 30 días de antelación y hay que
re-aceptar; el progreso local se conserva.

---

## 2. Licencia de uso del juego

**En el sitio:** el juego y los materiales de este sitio se ofrecen bajo una licencia **personal,
no comercial, revocable y no transferible**. Comprar, descargar o jugar no transfiere propiedad
intelectual.

**Qué está permitido:** capturas de pantalla, clips, streaming, reseñas y mods no comerciales.
**Qué no está permitido:** uso comercial de los assets, redistribución del juego, y uso de assets
del juego para entrenar o alimentar sistemas de IA generativa.

**Detalle contractual:** ToS §2 (incluye la tabla de excepciones explícitas).

---

## 3. Cuentas de usuario

**En el sitio:** **N/A en v1.0** — el juego no requiere cuenta y no hay registro en este sitio.

El progreso se guarda localmente en el dispositivo. Si el juego se ejecuta en el navegador (el
repositorio incluye un export web en `build/web/`), ese guardado local usa el almacenamiento del
propio navegador y se pierde si se borran los datos del sitio.

Si en el futuro se agregan componentes online, aplican las reglas de cuentas del ToS §3 y la
política de privacidad (M80).

**Detalle contractual:** ToS §3.

---

## 4. Conductas prohibidas

**En el sitio:** las mismas conductas que el ToS, sin agregados: cheating (exploits, hacks,
trainers), explotación intencional de bugs, acoso o discriminación, contenido inapropiado,
violación de copyright de terceros y violación de la privacidad de otras personas.

**Alcance en v1.0:** al ser single-player, las consecuencias disciplinarias del ToS §4 (avisos,
suspensiones, bans) **no tienen hoy un mecanismo de aplicación en el juego**; quedan previstas para
cuando exista multiplayer. Lo que sí aplica hoy es la prohibición de redistribuir el juego o
comercializar sus assets (§2).

**Detalle contractual:** ToS §4.

---

## 5. Contenido generado por el usuario (UGC)

**En el sitio:** **N/A en v1.0** — no hay UGC: el juego es single-player y este sitio no aloja
publicaciones de usuarios.

Los **mods no comerciales** están permitidos por la licencia (§2), pero un mod no es contenido
alojado por nosotros: no lo moderamos, no lo distribuimos y no lo respaldamos.

**Detalle contractual:** ToS §5 (reglas previstas para versiones futuras con UGC).

---

## 6. Cancelación y reembolsos

**En el sitio:** **N/A para las compras hechas en este sitio, porque este sitio no vende el juego.**
La venta y la devolución se gestionan en la tienda correspondiente (Steam), según su política
(14 días / menos de 2 horas de juego).

- No hay suscripciones ni cobros recurrentes que cancelar en este sitio.
- No hay cuenta que eliminar en v1.0 (§3).
- Si en el futuro este sitio vendiera el juego o merchandising, esta sección debe re-redactarse
  **antes** de habilitar la venta.

**Detalle contractual:** ToS §6.

---

## 7. Responsabilidad

**En el sitio:** el juego se entrega **"tal cual"**. La responsabilidad máxima se limita al precio
pagado por el juego; no se responde por daños indirectos (pérdida de datos, lucro cesante) ni por
eventos de fuerza mayor. La negligencia grave y la violación de leyes locales sí generan
responsabilidad, como dice el ToS.

**Nota para el lector web:** como el juego es gratuito, en la práctica el límite es el monto
efectivamente pagado, que puede ser cero. Eso **no amplía** ningún derecho ni elimina las
excepciones del ToS.

**Detalle contractual:** ToS §7.

---

## 8. Cambios del servicio

**En el sitio:** los cambios significativos se notifican con 30 días de antelación; las
actualizaciones del juego se distribuyen por la tienda; el fin de vida (EOL) se notifica con 6
meses y el juego puede descargarse antes. Los hotfixes y parches menores no requieren aviso.

Este documento se re-redacta cuando cambia el ToS; la fecha de redacción de la cabecera indica la
última revisión de este resumen.

**Detalle contractual:** ToS §8.

---

## 9. Terminación del servicio

**En el sitio:** la terminación por violación sigue el procedimiento del ToS (30 días de
notificación; inmediata solo en violación grave) y no genera reembolso. En v1.0 no hay cuentas, así
que la terminación alcanza al uso del juego y de los materiales, no a una cuenta.

**Detalle contractual:** ToS §9.

---

## 10. Jurisdicción aplicable

**En el sitio:** leyes de **Argentina**; tribunales de la Ciudad Autónoma de Buenos Aires. Idioma
del documento: español.

**Excepciones reconocidas:** GDPR (Reglamento UE 2016/679) para usuarios de la Unión Europea y
CCPA (California Consumer Privacy Act) para usuarios de California.

**Detalle contractual:** ToS §10.

---

## 11. Contacto

**En el sitio:** los canales son los del ToS §11 — correo de soporte
`soporte@islaancestral.example` (marcador de posición; el canal definitivo se define en M121) y los
canales comunitarios que defina M100.

**Divergencia declarada:** el diseño del módulo (`04-Codigo.md` §11) indica
`legal@islaancestral.com` como correo. Este documento **no elige** entre los dos: reproduce el del
ToS, que es el documento contractual, y deja constancia de que la unificación del correo es un
pendiente del módulo M125.

**Detalle contractual:** ToS §11.

---

## 12. Prevalencia, jerarquía y vigencia

1. **ToS** (`legal/terms_of_service.md`) — documento contractual.
2. **Este documento** — resumen público para el sitio; deriva del ToS y no lo modifica.
3. **Textos del juego** (`data/legal/terminos.json`) — lo que la pantalla de aceptación muestra al
   jugador; su contenido son las 5 secciones obligatorias declaradas en ese archivo.

Si cualquiera de los tres contradice a otro, **prevalece el ToS**. Cualquier contradicción debe
resolverse actualizando el documento inferior, nunca el superior.

---

## 13. Estado legal

> **Este documento requiere revisión por un abogado antes de su publicación, igual que el ToS.**
> No sustituye asesoramiento legal y no debe publicarse como política definitiva sin esa revisión.

Pendientes heredados del módulo M125 que afectan a este documento:

- Revisión por abogado (IMPLEMENTACIÓN MANUAL, dueño: M125).
- Unificar `terms_date` (`2026-01-01`) con la fecha del ToS (`2026-10-03`).
- Unificar el correo de contacto (`soporte@islaancestral.example` vs `legal@islaancestral.com`).
- Publicar en el sitio web (IMPLEMENTACIÓN MANUAL).

---

## 14. Trazabilidad y verificación de cierre (interno — quitar al publicar)

Criterios de cierre del ítem L135 del `05-Checklist.md` de M125 (spec del Log 1950 §4.1):

| # | Criterio | Cómo se cumple |
|---|---|---|
| 1 | Existe `game/isla-ancestral/legal/terms_policy.md`, UTF-8 sin BOM, LF | archivo creado; bytes medidos (sin BOM, 0 CRLF, 0 CR) |
| 2 | Declara que es la versión pública/resumida y que **no sustituye** al ToS | §0 y §12 |
| 3 | Cubre las 11 materias del molde o marca `N/A` explícito | §1 a §11, una por materia; `N/A` explícito en §3, §5 y §6 |
| 4 | Versión y fecha coherentes con `terms_version` / `terms_date`, o diferencia explicada | bloque "Versión y fechas (declarado)": versión `1` en las 3 fuentes; diferencia de fecha explicada |
| 5 | No introduce promesas que el ToS no haga | todo el documento remite al ToS; §12 fija la prevalencia y §0 prohíbe relajar obligaciones |

Evidencia de la medición (no de la intención):

- `terms_config.gd`: `terms_version = 1`, `terms_date = "2026-01-01"`, `terms_file = "res://data/legal/terminos.json"`.
- `data/legal/terminos.json`: 5 secciones (`aceptacion`, `licencia_juego`, `contenido_generado`, `responsabilidad`, `terminacion`) + `politicas`.
- `legal/terms_of_service.md`: 159 líneas, 11 secciones + bloque "Aprobación legal", fecha `2026-10-03`.
- Este archivo **no lo consume ningún script**: el runtime lee solo `res://data/legal/terminos.json`
  (`terms_config.gd:13`, `terms_manager.gd:21`). Es un artefacto documental para el sitio.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — 2026-10-18 — spec del mensaje 301 §4.1, ítem 149 del BACKLOG-MASTER.
