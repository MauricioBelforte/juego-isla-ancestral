# 2174 - M45-Arte-3D: validador de malla RF14 implementado (headless) + eje UP medido + hallazgo de eje en el auditor de flotacion

- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M45-Arte-3D (RF14 / RF5 / RF6 / RF7 / RF9 / RF4)
- **Fecha:** 2026-10-24 22:06
- **Entrada:** mensajes de canal 387 (GLM: 386 ratificada), 388 y 389 (agnes-3-flash: relevo
  de direccion + nudge de estado). RAMA 1.
- **Log reservado:** 2174 (medido con `reservar_log.py --estado` justo antes: primero=2174).
- **Commits:** 0. **Push:** 0. **Flips aplicados:** 0 (se proponen con cita).

## 1) Premisa medida antes de trabajar

El item L145 de `05-Checklist.md` de M45 pide `[?] Definir script validate_mesh.gd en
Assets/_Project/Editor/`. Medido:

- `find . -iname "*validate_mesh*"` = **0** -> el validador NO existe en el repo.
- La ruta que pide el item (`Assets/_Project/Editor/`) es de la era **Unity**; el
  proyecto es Godot 4.7.2 y esa carpeta no existe.
- El `03-Diseno.md` seccion 7 (L171) afirmaba que la validacion estaba bloqueada por
  "validate_mesh.gd (MISS) + **0/23 GLB en disco**". **Premisa VENCIDA:** hay
  **418** .glb en `assets/3d/{alta,media,baja}` (git ls-files, todos parseables), no 0/23.

## 2) Entregado

### 2.1 `scripts/validar_malla_glb.py` (NUEVO, solo lectura, stdlib pura)

Parsea el contenedor GLB (chunk JSON + chunk BIN), aplica la cadena de TRS de los
nodos (traslacion/rotacion/escala con padres) y mide por archivo:

| Clase | Nivel | Medido hoy (418 archivos) |
|---|---|---|
| PARSE | violacion | 0 |
| SIN_GEOMETRIA | violacion | 0 |
| ESCALA_NO_UNIFORME | violacion | **95** |
| ESCALA_NO_APLICADA | aviso | 98 |
| UV_FUERA_RANGO | violacion | **3** |
| SIN_UV (solo LOD0) | aviso | 31 |
| TOPO_DEGENERADO | violacion | **4** |
| ORIGEN_BAJO_SUELO | violacion | **285** |
| ORIGEN_SIN_CONVENCION | aviso | 16 |
| RF4_EXCEDIDO | aviso | 58 |
| LOD_FALTANTE | violacion | **10** |

CLI: `--json` (tools/legal/malla_glb.json), `--check` (exit 1 si hay violaciones),
`--archivo`, `--limite`, `--eje`, `--selftest`. **exit 3 = validador CIEGO** (0
archivos) para que un glob roto no publique un verde.

### 2.2 Suite de autoprueba: 27 checks / 0 fallos / EXIT 0 x3

Piso `CHECKS_MINIMOS = 27` **MEDIDO** en verde (no estimado): si una refactorizacion
deja de ejecutar un bloque, el conteo baja y la suite falla con exit 1.
Construye GLB sinteticos en memoria (no depende de assets del repo) y cubre: parseo,
conteo de vertices/tris, bounds, UV fuera de rango, escala anisotropa, contenedor
corrupto, triangulo colineal (degenerado), vertice duplicado, categoria por prefijo de
modulo, LOD0/LOD1/LOD2, LOD_FALTANTE con 900 tris y sin con 400, origen bajo suelo,
origen sin convencion, y que RF4 excedido sea AVISO y no violacion.

### 2.3 Prueba EN ROJO por inyeccion (6 checks / 0 fallos / EXIT 0)

Sobre **copia** de un asset real (`18-Casas_cama_basica.glb`, 360 verts / 180 tris):

- control: la copia limpia parsea y no tiene violaciones;
- inyeccion 1: `nodes[0].scale = [1,1,1.5]` -> `ESCALA_NO_UNIFORME` en **15** nodos;
- inyeccion 2: primer `u` de TEXCOORD_0 = 1.7 -> `uv_fuera_rango = 1`;
- inyeccion 3: contenedor corrupto -> `PARSE`;
- el asset original queda **byte-exacto** (sha256 359123c2c398d4b3 antes y despues).

## 3) Hallazgos

### 3.1 Eje UP = Y (medido, no supuesto)

Tres senales independientes sobre los 418 assets:

| Senal | Y | Z |
|---|---|---|
| ancla en 0 (min == 0 +- 1e-3) | 3 | 1 (414 no anclan en ningun eje) |
| contacto en 0.045 +- 0.020 | **66** | **0** |
| extension mayor en ese eje | 227 | 191 |

Corroboracion morfologica: `18-Casas_alfombra.glb` dim = [3.200, 0.038, 3.200]
(una alfombra es plana en Y); `50-Vegetacion_canas_bambu.glb` dim = [0.720, 3.145,
0.604] (una cana es alta en Y). El propio `03-Diseno.md` 7.4 ya dice "footprint Y=0".

### 3.2 HAY UN DEFECTO DE EJE EN `scripts/auditar_flotacion_glb.py` (M166)

Ese auditor mide el componente **Z** (`m[2]`, `t[2]`) mientras el eje UP es **Y**.
Su propia corrida da **ASENTADO = 0 de 694** archivos, lo que es imposible si el
criterio estuviera bien aplicado: con el eje correcto hay **66** en 0.045 +- 0.020.
Las categorias FLOTA / HUNDIDO / ORIGEN-CENTRADO (3 / 495 / 589) no describen altura.
**NO se modifico** ese script (frente M166): se reporta para decision.

### 3.3 El corpus no tiene texturas ni UV en los LOD bajos

- 131 de 418 con `TEXCOORD_0` / **287 sin UV**: alta 129/160, media 2/130, baja **0/128**.
- **0 de 1.532 materiales** usa `baseColorTexture`: todo el corpus es color plano.
- Consecuencia: RF6 (padding >= 4 px, texel density) es **vacuo hoy**, y los LOD1/LOD2
  perdieron las UV que si tiene el LOD0 (si algun dia se texturiza, los LODs no sirven).

### 3.4 RF15 no se cumple y RF13 no existe -> RF4 no es automatizable por nombre

- **0 de 694** .glb cumple el prefijo RF15 (`chr_`, `prop_`, ...): el nombre es
  `<Modulo>_<nombre>.glb` y la carpeta es el **nivel de LOD**, no el modulo.
- `asset_catalog.json` (RF13) **no existe en disco** (ya reportado en la nota del L145).
- Por eso la categoria se infiere del prefijo de modulo y **RF4 queda como aviso, no
  como violacion**: `18-Casas_alfombra.glb` se inferiria `bld` (techo 15.000) cuando
  es `furn` (techo 1.200). Promoverlo a violacion seria inventar una categoria.

## 4) Limites declarados (no silenciados)

1. **n-gons:** glTF 2.0 solo admite TRIANGLES/TRIFAN/TRISTRIP; un n-gon NO puede
   sobrevivir a la exportacion. El validador mide el proxy medible (degenerados). La
   deteccion de n-gons exige leer el `.blend` fuente: **fuera de alcance**.
2. **vertices duplicados:** se cuentan (417/418 los tienen) pero NO se reportan como
   defecto: glTF obliga a partir vertices por costura de normal/UV. Un aviso ahi seria
   falso positivo en el 100% del corpus (defecto propio corregido antes de publicar).
3. **`--check` sale 1 hoy** (368/418 con violaciones): NO se cablea a CI sin baseline;
   cablearlo congelaria un rojo permanente. Decision del director.
4. El validador mide el `.glb` exportado, no el `.blend`: no ve n-gons ni modificadores.

## 5) Flips PROPUESTOS (no aplicados)

| Item | Linea | Propuesta | Cita |
|---|---|---|---|
| Definir script validate_mesh.gd | L145 | `[?]` -> `[x]` | `scripts/validar_malla_glb.py` + suite 27/0 + prueba en rojo; desvio declarado: headless Python, no `.gd` de editor Unity |
| Verificar escala 1:1 (< 1e-3) | L150 | `[ ]` -> `[x]` | criterio implementado (ESCALA_NO_UNIFORME, 95 hallazgos medidos) |
| Verificar topologia (n-gons, vertices duplicados) | L152 | `[ ]` -> `[?]` | n-gons no medibles en GLB (limite declarado); duplicados son artefacto de glTF |
| Verificar UVs (fuera de rango, padding) | L153 | `[ ]` -> `[x]` | UV_FUERA_RANGO implementado (3 hallazgos); padding: 287 assets sin UV |
| Verificar origen Y=0 para props de suelo | L154 | `[ ]` -> `[x]` | ORIGEN_BAJO_SUELO implementado (285 hallazgos); eje Y medido |
| Acumular errores y mensajes accionables | L156 | `[ ]` -> `[x]` | el validador acumula TODAS las violaciones por archivo y nombra archivo+valor |
| Conteo de tris por categoria <= tabla RF4 | L240 | `[ ]` -> `[?]` | medido pero categoria INFERIDA (RF13 ausente): no se puede afirmar cumplimiento |
| Tres assets pasan validate_mesh.gd | L238 | `[ ]` -> `[?]` | el validador corre sobre los 418; "pasan" solo 50 -> el criterio de "armonicos en Aurora" es visual, no headless |

**Totales del 05 NO se tocan** (los re-basea el director). Estado real medido hoy:
**157 [x] / 12 [ ] / 2 [?] = 171** (la linea `Totales` vigente L292 dice 157/12/2: coincide).

## 6) Pools y estado

- Log: **2174** consumido (cabeza medida antes: primero=2174). Cabeza tras reservar: 2175.
- Canal: tracker previo 385; se procesan 387/388/389; reporte = **390** (ultimo 389 + 1).
- `--estado` del pool de logs: 12 colisiones ajenas preexistentes reportadas (1290, 1468,
  1547, 1559, 1585, 1645, 1698, 1726, 1876, 1878, ...), no corregidas.

## 7) Archivos tocados

- `scripts/validar_malla_glb.py` (NUEVO, ~640 lineas).
- `DOCUMENTACION/45-Arte-3D/plan-actual/03-Diseno.md` (+121 lineas: seccion 8 nueva;
  EOL LF conservado, 0 CR, sin BOM, 0 U+FFFD).
- `tools/legal/malla_glb.json` (NUEVO, salida `--json`).
- Este log.

NO tocados: `05-Checklist.md` de M45 (prohibido sin orden), `CHECKLIST-GLOBAL.md`,
`quality.yml`, `auditar_flotacion_glb.py` (frente M166), ningun asset `.glb`.

## 8) Addendum (misma vuelta, medido despues del cierre)

- Defecto propio encontrado al verificar la guarda de ceguera: `--archivo no/existe.glb`
  salia **0** en vez de 3 (la guarda solo cubria el caso 'glob devolvio 0 archivos').
  Corregido: si el archivo pedido no existe -> mensaje 'VALIDADOR CIEGO' + **exit 3**.
  Verificado: inexistente -> EXIT 3; asset real -> EXIT 0 con 1 archivo medido; autoprueba
  sigue en **27 checks / 0 fallos / EXIT 0**.
