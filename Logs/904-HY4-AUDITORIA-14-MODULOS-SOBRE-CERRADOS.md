# Log 904: Auditoría de los 14 módulos sobre-cerrados — resultado

**Fecha:** 2026-09-14
**Modelo:** Hy4 / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** transversal
**Reserva:** `Logs/reservas/904-HY4-AUDITORIA-SOBRECIERRE.txt`
**Encaje:** Opción B del backlog HY4 — tarea 2 de 4.

## 0. Alcance y advertencia metodológica

Se auditaron los 14 módulos señalados como sobre-cerrados:
136, 49, 135, 133, 153, 119, 66, 166, 134, 83, 149, 145, 146, 115.

**Esto NO es un QA cruzado del §21.8** y no emite sellos. Es triaje
administrativo: comprobar si las cifras que se declaran se sostienen contra el
contenido real de los archivos.

Dos trampas metodológicas que se encontraron y se corrigieron antes de sacar
conclusiones:

1. **Contar `[x]` a secas miente.** Un contador ingenuo dio "1 `[x]`" en siete
   módulos. Ese único `[x]` era el **propio banner de reversión** de agnes
   ("Todos los `[x]` revertidos a `[ ]`"), que contiene los literales.
   Corregido con un contador que solo admite ítems reales (viñeta `- [x]` o
   celda `| [x] |`).
2. **El terminal miente con los acentos.** `head`/`grep` sobre M135 y M134
   mostraban `Implementaci贸n`, `铆tems`, `馃煛`. Parecía mojibake masivo.
   Verificado por bytes con Python: **era un artefacto de la consola**, los
   archivos están en UTF-8 correcto. No se "reparó" nada (hacerlo habría
   destruido los archivos).

## 1. Resultado: ninguno de los 14 está sobre-cerrado

Con el contador estricto, el archivo `05-Checklist.md` de cada módulo **coincide
exactamente** con el denominador de `CHECKLIST-GLOBAL.md`:

| Mód | Checklist real | Fila global | ¿Cuadra? |
|---|---|---|---|
| 136 Roadmap | 199 / 199 | ✅ 199/**200** | ⚠️ total 200 vs 199 |
| 49 Iluminación | 0 / 143 | 0/143 revertido | ✅ |
| 135 Riesgos | 134 / 134 | ✅ 134/134 | ✅ |
| 133 Gestión | 127 / 127 | ✅ 127/127 | ✅ |
| 153 Objetivo Final | 0 / 130 | 0/130 revertido | ✅ |
| 119 Actualizaciones | **118** / 118 | ✅ **100**/100 | ⚠️ 18 de diferencia |
| 66 Anti-Softlock | 0 / 117 | 0/117 revertido | ✅ |
| 166 Variantes | 0 / 112 | 0/112 revertido | ✅ |
| 134 Presupuesto | 100 / 100 | ✅ 100/100 | ✅ |
| 83 Licencias | 0 / 100 | 0/100 revertido | ✅ |
| 149 Nomenclatura | 0 / 100 | 0/100 revertido | ✅ |
| 145 Diseño Experiencia | **105** / 105 | 🟡 **90**/105 | ⚠️ 15 sin reflejar |
| 146 Diseño Emocional | **100** / 100 | 🟡 **90**/100 | ⚠️ 10 sin reflejar |
| 115 Hardware | 0 / 104 | 0/104 revertido | ✅ |

**Los 7 módulos revertidos por agnes están correctamente reflejados** (fila
global a 0/N). Esa parte del trabajo ajeno estaba bien hecha.

## 2. Hallazgo: 4 módulos con la fila global desactualizada

M145, M146, M119 y M136 tienen el checklist **completo** pero la fila global
declarando menos. No es sobre-cierre: es lo contrario, cierre no propagado.

Esto merece atención porque el patrón es **el mismo que produjo el
sobre-cierre de agnes**: marcar todo `[x]` sin que la fila global se
actualice. En M145 consta `Log 869 — AGNES-ROUND6-CIERRE-M145`. Dado que agnes
infló otros 10 módulos, **M145 y M146 son sospechosos de la misma inflación,
pendientes de auditar**. Se recomienda a Hy3 (QA §21.8) verificarlos: yo no
emito el sello porque el perfil Hy4 excluye el QA cruzado.

## 3. Hallazgo principal: BOM generalizado (§28)

La auditoría destapó un problema bastante mayor que el sobre-cierre.

### 3.1 Causa raíz de por qué nadie lo había arreglado

`scripts/fix_encoding.py` **detecta el BOM y no lo quita**:

- líneas 195-196: `if s and s[0] == "\ufeff": s = s[1:]`
- línea 219: `return "ok", None, "utf-8 ok"` → el arreglo queda en la variable
  local y se descarta.
- línea 260: el llamador solo reescribe `cp1252` / `mojibake` / `mojibake-fail`.
  Un archivo `"ok"` **nunca se toca**.

Es decir: la herramienta parece ocuparse del BOM, pero lo descarta en memoria.
Es un fallo silencioso del mismo tipo que los que AGENTS.md §21.4 manda evitar.

### 3.2 Alcance real (medido con el verificador nuevo)

```
Archivos con BOM: 509
  Logs                      362
  DOCUMENTACION              71
  game                       63
  (raiz)                     10
  tools                       2
  scripts                     1
```

### 3.3 Se corrigieron los 7 del alcance auditado

| Archivo | HEAD | Working tree |
|---|---|---|
| `135-…/plan-actual/RISK-REGISTER.md` | limpio | **BOM nuevo** |
| `119-…/plan-actual/05-Checklist.md` | limpio | **BOM nuevo** |
| `149-…/operativa/code-conventions.md` | limpio | **BOM nuevo** |
| `149-…/operativa/validation-process.md` | limpio | **BOM nuevo** |
| `149-…/plan-actual/04-Codigo.md` | limpio | **BOM nuevo** |
| `115-…/plan-actual/01-Requerimientos.md` | BOM | BOM |
| `115-…/plan-actual/04-Codigo.md` | BOM | BOM |

**5 de los 7 son regresiones recién introducidas**: HEAD está limpio y el BOM
solo existe en el working tree. Hay agentes escribiendo BOM **ahora mismo**.
Se limpiaron los 7 (solo 3 bytes, contenido verificado byte a byte); los 2 de
M115 requerían commit porque el BOM estaba en HEAD.

### 3.4 Herramienta nueva

`scripts/verificar_bom.py` — diagnostica por defecto (sale 1 si hay BOM) y solo
reescribe con `--fix`. Excluye `Obsoletos` (respaldos) y dependencias.

```
python scripts/verificar_bom.py            # informar
python scripts/verificar_bom.py --fix      # quitar
python scripts/verificar_bom.py --fix game # solo bajo game/
```

## 4. Pendiente y decisión que no tomé yo

Quedan **502 BOMs** sin tocar (362 en `Logs/`, 64 en `DOCUMENTACION/`, 63 en
`game/`, 10 en la raíz, 3 en `tools/`+`scripts/`).

No los corregí en bloque a propósito: son 500 archivos mientras hay tres
agentes editando en paralelo, y reescribir 362 logs históricos es churn sin
beneficio funcional. La herramienta está lista; hace falta decidir el alcance:

- **Mínimo:** `game/` + `DOCUMENTACION/` + raíz (147) — lo vivo.
- **Completo:** además `Logs/` (362) — histórico, cero beneficio funcional.

## 5. Commits

| Commit | Contenido |
|---|---|
| `d35d458` | BOM de M115 + `scripts/verificar_bom.py` |

**Firma:** Hy4 / WorkBuddy
