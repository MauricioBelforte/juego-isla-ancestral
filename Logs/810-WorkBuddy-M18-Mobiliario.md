# Log 810 — M18 mobiliario interior: cama, velador, silla, mesa CERRADOS

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Módulo:** M18 — Mobiliario interior interactivo (RF7 P14)
**Reserva:** `Logs/reservas/810-WorkBuddy-M18-Mobiliario.txt` (se borra al cerrar este log)

---

## 0. Contexto

Continuación directa del log 809: la auditoría había marcado **14 ítems de
"Mobiliario interior"** como `[x]` sin tener script, `.blend` ni GLB. Reverir
14 sin reemplazarlos no resolvía el problema; encaro los 4 más críticos
(dormir/sentarse/comer) para esta vuelta y dejo los 10 restantes pendientes
de autoría. Siguiente vuelta (o siguiente modelo): los otros 10.

| Item | Por qué arranca primero |
|---|---|
| Cama básica | dormir — central en cualquier vivienda |
| Velador | la "viñeta hero" del dormitorio de la casa mediana (log 806) |
| Silla de madera | sentarse — la base de toda interacción social |
| Mesa de madera | colocar items — necesaria para la mayoría de los minijuegos |

---

## 1. Helper compartido `mobiliario_util.py`

Para no repetir el bloque de 100 líneas (limpieza, paleta, caja, cilindro,
join, asentar, guardar…) en cada generador — exactamente el problema que
`plantilla_asset.py` vino a evitar — se creó
`tools/mcp/blender-mcp/18-Casas/scripts/mobiliario_util.py`. Convención de
firma: `caja(nombre, mat, sx, sy, sz, cx, cy, cz)`, **dimensiones primero,
centro después** (E-100).

**Bug atrapado en seco:** la primera versión tenía `RAIZ = os.path.join(..., 4*'..')`
y el primer `guardar` falló con `Cannot open file .../tools/tools/mcp/...`. Es
**exactamente E-101** del log 809: contar `..` a mano. La receta que documenté
("buscar `AGENTS.md` hacia arriba") se aplicó en limpio y resolvió.

## 2. Resultados numéricos (verificados por `auditar_mobiliario.py`)

| Asset        | ALTA SM_/tris/mats | MEDIA | BAJA | huella | z_min | toca | vol_firm ALTA |
|--------------|--------------------|-------|------|--------|-------|------|---------------|
| cama_basica  | 15/180/5           | 5/180/5 | 5/124/4 | 1.98×0.94 | 0.0450 | 24 | +0.6283 m³ |
| velador      |  9/160/5           | 4/160/5 | 4/108/4 | 0.43×0.43 | 0.0450 | 16 | +0.0280 m³ |
| silla_madera | 11/132/2           | 2/132/2 | 2/90/2  | 0.42×0.42 | 0.0450 | 16 | +0.0215 m³ |
| mesa_madera  |  9/108/2           | 2/108/2 | 2/74/2  | 1.15×0.75 | 0.0450 | 16 | +0.1104 m³ |

**0 fallos sobre los 12.** Todos dentro del presupuesto M166 §3.3 (ALTA ≤16/6000/12,
MEDIA ≤8/1500/8, BAJA ≤6/700/4) y con volumen firmado positivo (E-92), z_min
0.0450 (E-12), huella mínima 0.42 m (E-50) y al menos 12 vértices apoyando (E-50).

## 3. La llama del velador (E-96 aplicado a la inversa)

`generar_variante.py` corre la poda de BAJA y elimina la pieza con menos
caras: la llama (cilindro r=0.016, 8 lados) se fue en la primera pasada. El
velador perdía la única razón de ser un velador en el LOD lejano.

**Fix:** unir vela y llama en un solo mesh con dos slots de material
(cera + llama). La poda ya no puede llevársela sin llevarse la vela entera.
En BAJA ahora quedan 4 materiales (madera_oscura, madera_clara, cera, llama)
y 0 piezas eliminadas. El tirador de bronce (12 tris) es la pieza "barata"
que se funde con el cajón en BAJA, que es el trade-off correcto.

## 4. Capturas (6 orbitales × 3 variantes = 72 PNG + 12 hojas de contacto)

Guardadas en `tools/mcp/blender-mcp/18-Casas/capturas/`. Leí las 4 hojas ALTA:

- **Cama**: cabecera con panel y dos postes que llegan al piso, manta roja
  drapeada, almohada blanca. Cuatro patas robustas apoyadas en la arena.
  Nada flota. La manta cubre del pie hacia el centro y CAE 3 cm por los
  costados (no es un rectángulo flotante sobre el colchón).
- **Velador**: tablero, cuatro patas, repisa inferior, cajón con tirador
  de bronce, vela y llama visibles. El farolito de noche.
- **Silla**: respaldo con 2 montantes y 2 listones, asiento, 4 patas, 2
  travesaños laterales. Vista de costado (az 180) muestra el perfil
  completo del respaldo.
- **Mesa**: tablero con voladizo de 5 cm por lado sobre las patas, bastidor
  completo. Robusta.

## 5. Verificación Godot (E-65 / E-72)

- Export: 12/12 GLB nuevos (4 × ALTA/MEDIA/BAJA) ya en `game/isla-ancestral/assets/3d/`.
- Import: reimport headless con Godot 4.7.2 → 4 `reimport` por asset (1 ALTA + 1 MEDIA + 1 BAJA) = **12 reimports** sin errores.
- `.scn` en `.godot/imported/`: 3 por asset con **3 md5 distintos por asset** =
  **12 md5 únicos totales**, lo que confirma que las 3 variantes son
  **realmente distintas** (no la misma exportada con otra decoración). El
  audit cruzó por conteo, no por mtime (E-49).

## 6. Auditoría del checklist (log 809) recruzada

Estado del `CHECKLIST-OBJETOS-BLENDER.md` tras el cierre:
- **131 `[x]`** / 38 `[ ]` (de 127/42 antes).
- A) Falso pendiente: **0** (los 10 muebles que quedan son realmente pendientes — sus `decor_*` hermanos de M18-TER cuentan aparte y no solapan).
- B) Falso completo: **0**.
- E) Sidecar huérfano: **0**.

## 7. Lo que falta del mobiliario (10 ítems)

Pendientes de autoría en la checklist (todos anotados con "REVERTIDO log 809"
para que otros modelos no los re-marquen `[x]` por error):

- `cama_doble` (la de 2 plazas, distinta de `cama_basica` que es de 1 plaza)
- `sillon` (sofá para sala)
- `nevera_rustica` (pozo de conserva — el mundo no tiene electricidad, M147)
- `estufa_lena` (cocina/horno con hornallas y chimenea)
- `estanteria` (mueble de pared con libros)
- `comoda` (baúl de ropa)
- `lampara_pie` (farol de pie / de mesa)
- `alfombra` (redonda, decorativa)
- `cuadro_ancestral` (máscara/pintura de pared)
- `maceta_interior` (planta de interior)

## 8. Observaciones honestas (§21.4)

1. **No verifiqué BAJA visualmente** — solo ALTA (4 hojas leídas). El BAJA
   es un LOD lejano: confío en que el `asentar()` + signed volume + capturas
   ALTA son suficiente garantía, y la auditoría numérica los validó a todos.
2. **El tirador de bronce del velador se funde con el cajón en BAJA**
   (0 piezas eliminadas pero materiales 5→4). Es el trade-off correcto: a
   distancia el tirador no se ve, y mantener la llama sí vale.
3. **El checklist ganó 4 `[x]` pero perdió 4 notas explicativas** al
   reescribir (REVERTIDO). Se restauraron en las 10 líneas que SIGUEN
   pendientes; el resultado es: las 4 cerradas tienen la nota "CERRADO log
   810" y las 10 pendientes tienen la nota "REVERTIDO log 809".
4. **No se tocó M18-BIS casona/mansión/vecino** — la directiva "continúa con
   el resto de casas" sigue pendiente; el siguiente paso natural es retomar
   eso o seguir con los 10 muebles restantes.
5. **E-101 se confirmó en la práctica** dentro de este log: el primer `guardar`
   falló con la ruta `<repo>/tools/tools/mcp/...` por contar `..` a mano. La
   receta "buscar AGENTS.md" lo arregló en 5 segundos. Es un buen recordatorio
   de que la documentación no es opcional: se usa.

## 9. Artefactos

**Creados**
- `tools/mcp/blender-mcp/18-Casas/scripts/mobiliario_util.py`
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_cama_basica_lowpoly.py`
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_velador_lowpoly.py`
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_silla_madera_lowpoly.py`
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_mesa_madera_lowpoly.py`
- `tools/mcp/blender-mcp/18-Casas/scripts/auditar_mobiliario.py`
- 12 `.blend` (4 ALTA + 4 MEDIA + 4 BAJA)
- 72 capturas PNG + 12 hojas JPG
- 12 GLB + 12 `.glb.import` + 12 `.scn` con md5 distintos

**Modificados**
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`: 4 ítems → `[x]`, 10 → nota REVERTIDO.

## 10. Firma

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Estado:** 4/14 muebles cerrados. **Siguiente vuelta sugerida:** los 10
restantes del mobiliario (prioridad 2ª: `estufa_lena` porque es interactivo
de cocinar, y `lampara_pie`/`alfombra` que tienen decor gemelos que se
pueden reutilizar), o retomar M18-BIS casona (la más chica de las 3 casas
grandes que faltan).
