# Log 1966 - M125 - Terms Policy: version publica para el sitio web

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-18 01:23 (GMT-3)
**Modulo:** M125-Terminos-De-Servicio
**Origen:** RAMA 2 (sin mensajes nuevos del director). Item **149** de la COLA ACTIVA del
`BACKLOG-MASTER.md`, escrito por el director: "Escribir legal/terms_policy.md (spec del
DeepSeek 301 4.1)". Spec propia: `Logs/1950-...` seccion 5.1.
**Tracker al iniciar:** 306. Barrido recursivo de mi canal (raiz + `0-99/` + `100-199/`):
NN entrante maximo del director = **305** (ya procesado). 0 mensajes nuevos.

---

## 1. Por que este item

El item L135 del `05-Checklist.md` de M125 estaba en `[?]` desde el barrido del Log 1944: el
artefacto `legal/terms_policy.md` **no existia en ninguna ruta** del repo y su propio
`04-Codigo.md:227` lo declaraba "IMPLEMENTACION INMEDIATA". Este log entrega el artefacto y mide
los 5 criterios de cierre que la spec habia fijado para que el director pueda flipear L135.

**No aplico el flip.** La marca la mueve el director (regla dura del ciclo).

## 2. Medido ANTES de escribir (contrato, no memoria)

| Fuente | Valor medido |
|---|---|
| `scripts/legal/terms_config.gd:11` | `terms_version = 1` |
| `scripts/legal/terms_config.gd:12` | `terms_date = "2026-01-01"` |
| `scripts/legal/terms_config.gd:13` | `terms_file = "res://data/legal/terminos.json"` |
| `data/legal/terminos.json` | 5 secciones + 2 politicas (`version_fechada`, `aceptacion_explicita_al_iniciar`) |
| `legal/terms_of_service.md` | 159 lineas, 6554 B, LF puro, sin BOM, Version 1.0, Fecha 2026-10-03 |
| `legal/` antes del cambio | 2 archivos: `contracts_templates.md`, `terms_of_service.md` |
| consumidores de `.md` en `scripts/legal/` | **0** (grep de `.md` sobre `terms_*.gd` y `test_terms_m125.gd`: solo aparece `user://terminos_aceptados.json`) |
| `04-Codigo.md` seccion 11 | correo `legal@islaancestral.com` |
| `terms_of_service.md` seccion 11 | correo `soporte@islaancestral.example` (placeholder, M121) |
| `build/web/index.html` + `index.wasm` | existe export web (39,5 MB de wasm) -> el juego puede correr en el navegador |

Consecuencia de diseno: `terms_policy.md` es un artefacto **documental** para el sitio. No se valida
con test headless (nada lo lee): se valida **por contenido**, como ya decia la spec del Log 1950.

## 3. Artefacto entregado

`game/isla-ancestral/legal/terms_policy.md` (**nuevo**, 12.144 B, 279 lineas).

Estructura: cabecera de procedencia (convencion del hermano) + bloque 0 ("que es y que no es") +
tabla de correspondencia de las 11 materias + bloque "Version y fechas (declarado)" + TL;DR +
secciones 1..11 (una por materia) + 12 Prevalencia + 13 Estado legal + 14 Trazabilidad (interno, se
quita al publicar).

Decisiones de contenido, todas trazables:

- **Criterio 2 (no sustituye al ToS):** seccion 0 y seccion 12 fijan la jerarquia
  ToS > politica > textos del juego, con la regla "ante discrepancia prevalece el ToS" y la
  prohibicion explicita de relajar obligaciones.
- **Criterio 3 (11 materias o N/A):** las 11 estan presentes, numeradas igual que el ToS, con 3
  `N/A` explicitos: seccion 3 (cuentas, v1.0 no tiene), seccion 5 (UGC, v1.0 no tiene) y seccion 6
  (reembolsos **para las compras hechas en el sitio**, porque el sitio no vende; la devolucion la
  gestiona Steam). Ninguna materia queda muda.
- **Criterio 4 (version/fecha):** bloque propio con las 4 fuentes medidas. La version coincide en
  las 3 fuentes (1). La **fecha NO coincide** y se declara: `terms_date = 2026-01-01` (runtime) vs
  `2026-10-03` (ToS). El documento **no elige por su cuenta**: reproduce la del runtime como fecha
  de vigencia de la v1 y declara la del ToS como fecha de redaccion, y deja la unificacion como
  pendiente del modulo.
- **Criterio 5 (sin promesas nuevas):** ver seccion 5 de este log.

## 4. Verificacion de los 5 criterios (medida, no declarada)

| # | Criterio | Resultado |
|---|---|---|
| 1 | Existe `game/isla-ancestral/legal/terms_policy.md`, UTF-8 sin BOM, LF | **CUMPLE** (bytes medidos en la seccion 6) |
| 2 | Declara version publica/resumida y que NO sustituye al ToS | **CUMPLE** (seccion 0 + seccion 12) |
| 3 | Cubre las 11 materias o marca N/A explicito | **CUMPLE** (11/11 secciones + 3 N/A) |
| 4 | Version y fecha coherentes o diferencia explicada | **CUMPLE** (version 1 en 3 fuentes; diferencia de fecha declarada) |
| 5 | No introduce promesas que el ToS no haga | **CUMPLE** (cruce programatico, seccion 5) |

Estructura medida con regex sobre el archivo escrito: 15 secciones `## N.` (0..14), materias 1..11
todas presentes, 3 marcas `**N/A`.

## 5. Criterio 5 - cruce programatico contra el ToS

Se extrajeron 16 afirmaciones concretas de la politica y se busco cada una en el ToS:

```
personal              ToS=SI  pol=SI      no comercial   ToS=SI  pol=SI
revocable             ToS=SI  pol=SI      no transferible ToS=SI  pol=SI
14 d                  ToS=SI  pol=SI      2 horas        ToS=SI  pol=SI
30 d                  ToS=SI  pol=SI      Argentina      ToS=SI  pol=SI
GDPR                  ToS=SI  pol=SI      CCPA           ToS=SI  pol=SI
tal cual              ToS=SI  pol=SI      mods no comerciales ToS=SI pol=SI
Streaming             ToS=SI  pol=SI      Resenas        ToS=SI  pol=SI
assets                ToS=SI  pol=SI
```

**Afirmaciones de la politica SIN respaldo en el ToS: NINGUNA.**

Control negativo (frases que el ToS no hace y que una politica web "generosa" agregaria):
`garantizamos`, `garantia de`, `sin limite`, `ilimitad`, `24/7`, `siempre gratis`,
`reembolso garantizado`, `soporte 24` -> **0 apariciones**.

El unico valor del ToS que la politica NO repite es "6 meses" (aviso de EOL); omitirlo no crea
derecho, y el documento remite al ToS seccion 8.

## 6. Higiene de bytes (medida por bytes, no por vista)

```
bytes    : 12144
bom      : False
crlf     : 0
lf_only  : 279
cr_total : 0
nul      : 0
utf8     : OK
fffd     : 0
```

EOL del hermano respetado: `git ls-files --eol game/isla-ancestral/legal/` da `w/lf` en los 2
archivos preexistentes, asi que el nuevo va **LF puro** (no CRLF).

## 7. Gates del repo

| Gate | Resultado |
|---|---|
| `python scripts/diagnosticar_mojibake.py` | **EXIT 0**, SUCIO 0 / IRREVERSIBLE 0 / EXCLUIDO 364, "LIMPIO". Mi archivo no aparece en ninguna categoria de problema |
| `python scripts/verificar_bom.py` | **EXIT 1** por **1 archivo AJENO**: `Mensajes entre modelos/agnes-3-flash/.ultima-revision-agnes.txt`. **No lo toco** (tracker de otro canal). Mi archivo no figura |

## 8. Regresion - la suite del modulo sigue verde

`godot --headless --path game/isla-ancestral --script res://scripts/legal/test_terms_m125.gd`
x3 corridas: **18 checks / 0 fallos / EXIT 0** en las 3.

No es una regresion posible por construccion: ningun `.gd` del modulo abre `.md` (grep medido), y el
error de la seccion 9 esta en `test_terms_m125.gd:97`, en codigo que no depende del artefacto.

## 9. Hallazgo (AJENO, NO tocado): falso verde LATENTE en `test_terms_m125.gd`

La suite imprime `SCRIPT ERROR: Attempted to free a RefCounted object.` en
`test_terms_m125.gd:97` (`cfg.free()` sobre un `TermsConfig`, que `extends Resource`).

Medido y acotado:

- El aborto cae en la **ultima linea** de `_test_terms_config()`, despues de sus 4 checks: el
  conteo real (18) coincide con el teorico (5 + 4 + 5 + 4), asi que **hoy no se pierde ningun
  check**. No es un falso verde consumado.
- **Pero la suite no tiene ninguna de las 3 capas** del guardian anti-falso-verde: no hay
  `CHECKS_MINIMOS`, no hay `_fin()` por bloque, no hay `_terminado`. Si un aborto cae **dentro** de
  un bloque (como ya paso en M72/M64), la suite imprimiria "0 fallos" y `quit(0)` igual.
- Ademas ensucia el criterio "0 SCRIPT ERROR" de cualquier barrido que incluya este modulo.

**No lo arreglo:** es un modulo con otro dueno (agnes-2.5/agnes-3-flash) y modificar su suite sin
autorizacion es exactamente el pisado que la regla 21.4 prohibe. Se reporta para que el director
asigne dueno. Fix de 1 linea: borrar `cfg.free()` (un `Resource` es `RefCounted`, se libera solo).

## 10. Divergencias declaradas (no resueltas por mi)

1. **Fecha:** `terms_date = "2026-01-01"` (runtime) vs `Fecha: 2026-10-03` (ToS). Declarada en el
   documento; la unificacion es del dueno de M125.
2. **Correo:** `soporte@islaancestral.example` (ToS 11, placeholder M121) vs
   `legal@islaancestral.com` (`04-Codigo.md` 11). El documento reproduce el del **ToS** (es el
   contractual) y declara la divergencia; no inventa un tercer correo.

## 11. Limites de esta vuelta

- **0 commits / 0 push** (no hay autorizacion escrita en esta vuelta).
- **0 flips**: L135 de M125 sigue en `[?]`; el GLOBAL de M125 sigue 105/105 (que ya no refleja el
  conteo real 104/0/1 desde el Log 1963; la celda es del director).
- **0 ediciones** a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`,
  `05-Checklist.md` de M125 ni a la suite ajena.
- **0 auto-sellos** 21.8.

## 12. Pedidos al director

1. Aplicar el flip de **M125 L135** `[?]` -> `[x]` (los 5 criterios estan medidos) y actualizar la
   fila del GLOBAL (hoy dice 105/105; el real es 104/0/1 -> pasaria a 105/0/0).
2. Decidir dueno del hallazgo de la seccion 9 (fix de 1 linea en `test_terms_m125.gd`).
3. Decidir la unificacion de `terms_date` y del correo de contacto (dueno M125).
4. Autorizar commit del artefacto nuevo (1 path) cuando corresponda.

---

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) - 2026-10-18 01:23 (GMT-3) - Log 1966
