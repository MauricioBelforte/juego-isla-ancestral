# Log 1444 - DeepSeek-V4.1-Flash - M78 QA cruzado 21.8 (verificador independiente)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07 22:32 (GMT-3)
**Modulo:** M78 - Legal - Propiedad Intelectual
**Rol:** QA cruzado AGENTS.md 21.8 (verificador independiente; distinto de mimo-v2.5 autor del nucleo, de agnes-3-flash que sano, y de Hy3 por la regla de familia Legal 10/10)
**Referencia:** mensaje canal 82 (atria-dawn, 2026-10-07 21:25) - responde a mi canal 81

## Alcance (los 4 criterios que pidio el director)

1. 05-Checklist.md del plan-actual: es 157/0/0 real?
2. Artefactos citados: existen y son sustantivos (no esqueletos)?
3. Estandar post-BUG-120: si hay runner, se corre.
4. P-39 / M24: nada que aplicar.

## Evidencia medida

### Criterio 1 - conteo (por PREFIJO de linea, no substring)

- `DOCUMENTACION/78-Legal-Propiedad-Intelectual/plan-actual/05-Checklist.md`:
  **157 [x] / 0 [ ] / 0 [?] = 157**. Coincide con la fila 78 del GLOBAL (157/157) y con su linea
  de Totales (L232). Conteo REAL, no heredado.
- Bytes/EOL del checklist: len 23275 | bom=False | crlf=236 | lf_sueltos=0 | nul=0 | fffd=0. CRLF puro.

### Criterio 2 - artefactos (11/11 existen; ninguno es esqueleto)

| Artefacto | Bytes | Nota |
|---|---|---|
| plan-actual/POLITICA-PROPIEDADES.md | 7232 | 176 lineas, 7 secciones reales (origen, escala, atribucion, compatibilidad, anti-plagio, terminos, marcas) |
| plan-actual/REGISTRO-MARCAS.md | 3836 | 99 lineas, 3 fases (busqueda preliminar COMPLETADA / solicitud PENDIENTE / internacional) |
| plan-actual/CHECKLIST-ATRIBUCION.md | 2540 | 72 lineas, checklist de 10 items por asset |
| plan-actual/03-Diseno.md | 9232 | 178 lineas, cubre las 5 licencias (CC-BY-SA, GPL, itch.io, Freesound, OGA) + formato de notices + tabla de activos |
| ASSETS-LICENSE.md (raiz) | 4231 | inventario 11 columnas (ID..Estado) |
| THIRD-PARTY-NOTICES.md (raiz) | 6510 | Godot (MIT) + Voxel Tools (MIT) + Nunito (OFL) |
| data/legal/legal_data.json | 8924 | 7 IPs / 5 assets_terceros / 7 assets_propios / 2 marcas / 10 claves de politicas |
| scripts/legal/legal_validator.gd | 7840 | validar() con 7 validadores; 3 listas de licencias |
| scripts/legal/asset_validation_m78.gd | 4771 | validar_assets_contra_registro + verificar_nc_nd |
| scripts/legal/test_legal_m78.gd | 8137 | suite 35 checks (ROJA, ver Hallazgo 1) |
| scripts/legal/test_legal_m78_v2.gd | 5635 | suite 60 checks (VERDE, ver Criterio 3) |

legal_data.json: marcas = "Isla Ancestral" (5 busquedas, con decision) + "Isla Aurora" (1 busqueda, con
decision). politicas trae checklist_atribucion_obligatorio, prohibido_nc_nd, prohibido_plagio,
escala_preferencia_licencias. Licencias de assets_terceros: MIT x3 + SIL OFL 1.1 x2. Datos REALES y coherentes.

### Criterio 3 - suites headless (x3 cada una, exit code del PROCESO, no de la tuberia)

| Suite | Checks | Fallos | EXIT | SCRIPT ERROR | Estabilidad |
|---|---|---|---|---|---|
| test_legal_m78_v2.gd | 60 | 0 | 0 | 0 | 3/3 identica |
| test_legal_m78.gd | 35 | 1 | 1 | 0 | 3/3 identica |

- `test_legal_m78_v2.gd` = **60/0 EXIT 0 x3, 0 SCRIPT ERROR**. La suite que cita el checklist (seccion L,
  items 188/189) esta VERDE.
- BUG-121 (SCRIPT ERROR `instantiate` sobre null, del autoload de fauna, no del test): **NO se reproduce**.
  El null-guard ya esta aplicado en el worktree (tortuga/cangrejo/jabali_npc.gd, +14/-2 lineas, sin commitear)
  y BUG-121 figura como Resuelto en 11-BUGS.md L230. Verificado por medicion: 0 SCRIPT ERROR.
- `test_legal_m78.gd` esta ROJA (Hallazgo 1), pero por un defecto del FIXTURE del propio test, no del modulo.
- Ninguna de las 2 suites esta cableada en quality.yml (grep = 0 citas), consistente con BUG-121
  ("no rompen el CI actual, nadie los corre").

### Criterio 4 - P-39 / M24
Nada que aplicar. M24 (iter.5) es de mi frente y esta cerrado aparte (Log 1438).

## Hallazgos

### Hallazgo 1 (MENOR, no bloqueante) - test_legal_m78.gd ROJO por fixture defectuoso
`test_legal_m78.gd` (mimo-v2.5, 2026-09-15) da **35 checks / 1 FALLO / EXIT 1** de forma estable x3.
El check que falla es `_test_validator_errores()` L181:
`_check("marca sin busqueda detectada", str(errores).contains("busquedas"))`.
El fixture `malo` de ese bloque pasa `"marcas": {}` (VACIO), pero `LegalValidator._validar_marcas()`
itera `marcas.keys()` -> con `{}` no hay marca y no emite ningun error con "busquedas" -> el check no
puede pasar NUNCA. Es un **defecto del fixture**, no un bug de producto: para probar ese caso el payload
debe incluir una marca SIN `busquedas`. El validador se comporta correcto (los 3 checks hermanos del
mismo bloque -IP sin campos, licencia NC, sin politicas- pasan). Fix = 1 linea (agregar la marca al
fixture) o retirar el duplicado. NO lo edite: el archivo es de mimo-v2.5 (lock 21.4) y no fui autorizado.
Observacion secundaria: `_validar_marcas()` con `marcas` VACIO no reporta nada (un registro de marcas
vacio validaria limpio); es una decision de diseno del validador, no un bug medido.

### Hallazgo 2 (MENOR) - el banner REVERTIDO sigue en el checklist (no hay nota SANEADO)
El director (msg 74) valido "Banner REVERTIDO reemplazado por nota SANEADO: Header reescrito". MEDIDO:
la L1 de `05-Checklist.md` sigue siendo `> **REVERTIDO POR AUDITORIA (2026-09-14):** ... Todos los [x]
revertidos a [ ]` y **no existe la palabra SANEADO en ninguna copia** (repo principal ni
`.kilo/worktrees/phase-judge/`). `git status` del modulo = limpio (worktree == HEAD). Es drift
documental: el header contradice el estado real (157 [x]). El archivo lo edita el director.

### Hallazgo 3 (MENOR) - la "correccion" de lineas del director es erronea
El director corrigio a agnes diciendo que las lineas reales son 121/71/50/138. MEDIDO en el repo
principal: **POLITICA-PROPIEDADES 176 / REGISTRO-MARCAS 99 / CHECKLIST-ATRIBUCION 72 / 03-Diseno 178**.
O sea que las cifras de agnes eran correctas y la correccion del director no. (Medido con conteo de
lineas explicito, no `wc -l` ciego.)

### Hallazgo 4 (MENOR) - cita que no resuelve en 03-Diseno.md
`03-Diseno.md` L34 y L88 citan `POLITICA-PROPERTIES.md` (ingles) pero el archivo real es
`POLITICA-PROPIEDADES.md` (espanol). Cita que no resuelve (familia trampa 95). Drift de nombre.

## Veredicto

**M78 = SUSTENTADO. Apto para flip a Verificado 21.8.**

- Criterio 1: CUMPLIDO (157/0/0 real y medido).
- Criterio 2: CUMPLIDO (11/11 artefactos existen y son sustantivos; datos y docs coherentes).
- Criterio 3: CUMPLIDO (la suite que cita el checklist esta VERDE 60/0 EXIT 0 x3, 0 SCRIPT ERROR;
  BUG-121 no se reproduce). El rojo de `test_legal_m78.gd` es deuda del TEST (fixture), no del modulo.
- Criterio 4: N/A.

Ninguno de los 4 hallazgos invalida una sola de las 157 marcas: son deuda menor de test/documentacion.
**NO sello el 05-Checklist** (el director hace el flip; el sello es suyo en la nota). NO edite
CHECKLIST-GLOBAL.md, quality.yml, interaction_manager.gd ni el checklist del modulo. Sin commit ni push.

**Firma:** DeepSeek-V4.1-Flash - QA cruzado 21.8 - Log 1444 - 2026-10-07
