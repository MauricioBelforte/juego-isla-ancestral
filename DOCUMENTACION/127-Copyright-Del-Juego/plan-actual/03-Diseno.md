**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 127: Copyright del Juego

## 1. Estructura del módulo

```
Copyright del Juego (registro de copyright)
├── Copyright automatico
│   ├── Código (automatico en creacion)
│   ├── Arte (automatico en creacion)
│   ├── Música (automatico en creacion)
│   ├── Narrativa (automatico en creacion)
│   └── Logos (automatico en creacion)
├── Registro formal (opcional)
│   ├── Registro de código (USCO: Source Code)
│   ├── Registro de arte (USCO: Visual Arts)
│   ├── Registro de música (USCO: Sound Recording)
│   ├── Registro de narrativa (USCO: Literary Work)
│   └── Registro de logos (USCO: Visual Arts)
└── Evidencia de autoría
    ├── Git logs (commits, autores, fechas)
    ├── Timestamps (archivos, commits)
    ├── Borradores (sketches, iteraciones)
    └── Metadata (EXIF, IPTC, tags)
```

## 2. Sistema de registro de copyright

**Archivo: legal/copyright_register.md**

**Estructura:**
```markdown
# Registro de Copyright - Isla Ancestral

## 1. Copyright Automatico
- Código: ✅ Copyright automatico en creacion
- Arte: ✅ Copyright automatico en creacion
- Música: ✅ Copyright automatico en creacion
- Narrativa: ✅ Copyright automatico en creacion
- Logos: ✅ Copyright automatico en creacion

## 2. Registro Formal (Opcional)
- Código: ⏳ Registro USCO: Source Code (USD 35-85)
- Arte: ⏳ Registro USCO: Visual Arts (USD 35-85)
- Música: ⏳ Registro USCO: Sound Recording (USD 35-85)
- Narrativa: ⏳ Registro USCO: Literary Work (USD 35-85)
- Logos: ⏳ Registro USCO: Visual Arts (USD 35-85)

## 3. Evidencia de Autoría
- Git logs: ✅ Commits con autoría
- Timestamps: ✅ Timestamps de archivos y commits
- Borradores: ✅ Borradores de arte, música, narrativa
- Metadata: ✅ Metadata de archivos y proyectos
```

## 3. Pruebas de copyright

**Pruebas manuales:**
- Probar que git logs muestren autoría correcta
- Probar que timestamps sean consistentes
- Probar que borradores estén accesibles
- Probar que metadata esté presente

**Pruebas automáticas:**
- Tests de verificación de git logs
- Tests de verificación de timestamps
- Tests de verificación de metadata

## 4. Empaquetado para el depósito USCO (registro formal)

> **Esta sección no existía hasta la iter. 4 (Log 1119).** Tres ítems de
> `05-Checklist.md` citaban `§2.3`, `§4.2` y `§4.3` de **este** documento:
> **ninguna existe** (el documento sólo tenía §1, §2 y §3). Es exactamente el
> defecto que provocó la reversión del 2026-09-14 (citas a `2.3/3.1/3.2/4.2/4.3`),
> así que acá se escribe la especificación real y se corrigen las citas.

Fuente normativa: **37 CFR § 202.20(c)(2)(vii)** — depósito de programas de
computadora fijados o publicados sólo en soportes legibles por máquina.

### 4.1 Código fuente — (c)(2)(vii)(A)(1)

| Caso | Depósito exigido |
|------|------------------|
| Programa de **≤ 50 páginas** | **Todo** el código fuente |
| Programa de **> 50 páginas** | **Primeras 25** + **últimas 25** páginas (o unidades equivalentes) **+** la página que contiene el aviso de copyright |
| Revisión que ocurre en todo el programa | Página del aviso + primeras y últimas 25 páginas |
| Revisión que **no** cae en las primeras/últimas 25 | Página del aviso + **cualesquiera 50** páginas representativas del material revisado |

**Unidad equivalente.** El reglamento habla de "páginas o unidades equivalentes"
sin fijar el alto de página. Este proyecto adopta **50 líneas de código por
página** (`PAGINAS_POR_UNIDAD` en `tools/legal/empaquetar_deposito_usco.py`), que
es la convención de facto para depósitos de código. El valor es configurable y el
informe **siempre declara cuál se usó**: de ese número depende cuántas páginas
tiene el programa y, por lo tanto, **cuál de las dos reglas aplica**.

**Medido sobre el repo (iter. 4, Log 1119):** 891 fuentes en alcance
(`game/isla-ancestral`, excluyendo `addons/` de terceros) → 122 468 líneas →
**2 450 páginas** → aplica la regla de recorte: páginas **1..25**, la **página del
aviso (1109)** y **2 426..2 450** = **51 unidades**.

### 4.2 Código con secretos comerciales — (c)(2)(vii)(A)(2)

Si el programa contiene material secreto, el depósito es la página del aviso
**más una** de estas opciones:

| Opción | Contenido |
|--------|-----------|
| (a) | Primeras y últimas **25** páginas con las porciones secretas **tachadas**, siempre que lo tachado sea **proporcionalmente menos** que lo que queda y el depósito **revele una cantidad apreciable** de código original |
| (b) | Primeras y últimas **10** páginas, **sin** tachaduras |
| (c) | Primeras y últimas **25** páginas de **código objeto** + **10 o más** páginas consecutivas de código fuente sin tachaduras |
| (d) | Programa de **≤ 50** páginas: todo el código fuente con lo secreto tachado, bajo las mismas condiciones de proporción y cantidad apreciable |

**Invariante de admisibilidad** (no es una recomendación, es una condición):
`tachado < visible` **Y** `visible > 0`. El validador lo comprueba y **falla** en
cualquier otro caso, incluido `tachado == visible` (que no es "menor").

**Regla de la duda.** Un depósito basado en **código objeto** se registra bajo la
*rule of doubt*: la Oficina advierte que no se determinó la existencia de autoría
protegible.

### 4.3 Muestras visuales — (c)(2)(vii)(C)(1)

Cuando la solicitud incluye una reclamación específica sobre las **pantallas** del
programa, además del código hay que depositar reproducciones visuales
(impresiones, fotografías o dibujos):

- **no menores a 3 × 3 pulgadas**
- **no mayores a 9 × 12 pulgadas**

Es un límite de **tamaño físico de impresión**, no de píxeles: la conversión
px → pulgadas depende del **DPI**, y el validador lo **exige** en vez de
adivinarlo. El validador **lee las dimensiones de la cabecera real** del archivo
(PNG `IHDR` / JPEG `SOF`), nunca de metadatos declarados a mano — un archivo con
extensión válida puede ser otra cosa (BUG-042).

### 4.4 Formato de los paquetes

- **Código:** texto plano, con los recortes de página anotados, para que la
  Oficina pueda verificar el recorte.
- **Visual:** PNG/JPEG sin recomprimir.
- **Tamaño:** el paquete no debe engordar por metadata; el informe declara el
  peso y falla si el metadata supera el 10 % del total.

### 4.5 Herramienta

`tools/legal/empaquetar_deposito_usco.py` implementa 4.1–4.4:

```bash
python tools/legal/empaquetar_deposito_usco.py --plan             # que se depositaria
python tools/legal/empaquetar_deposito_usco.py --emitir <dir>     # construye el deposito
python tools/legal/empaquetar_deposito_usco.py --check            # gate
python tools/legal/empaquetar_deposito_usco.py --json
python tools/legal/empaquetar_deposito_usco.py --selftest
```

Salida: `0` = conforme · `1` = violación **nueva** · **`3` = CIEGO** (no resolvió
fuentes que medir: "0 hallazgos" sin haber mirado no es un aprobado).

**Techo de deuda:** los hallazgos conocidos se declaran en
`tools/legal/deposito_usco_scope.json` con `clave`/`motivo`/`dueño`; `--check`
sólo falla ante una `clave` **no declarada**. Una deuda que ya no ocurre se
reporta como obsoleta, para que el techo no se pudra en silencio.

