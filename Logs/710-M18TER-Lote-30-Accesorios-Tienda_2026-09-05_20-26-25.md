# Log 710: M18-TER — Lote de 30 accesorios de decoración para la tienda

**Fecha:** 2026-09-05
**Hora:** 20:26
**Modelo:** glm-5.3-free
**Plataforma:** Kilo Code

## Resumen
Directiva del usuario: "crear muchos objetos/accesorios — hay una tienda
que vende artículos para decorar la casa". Generado un LOTE BATCH de 30
accesorios de decoración con un framework compartido, cada uno con su
.blend + stats + captura. Registrados en CHECKLIST-OBJETOS-BLENDER.md como
sección M18-TER. Pendientes de revisión visual del usuario (checkeo
prometido: "después checkeo si hay que corregir alguno").

## Cambios Realizados

### Framework batch (crear_decoracion_tienda_batch.py)
- Mini-framework compartido: 21 materiales cozy de la paleta de la casa,
  helpers (caja/cilindro/cono/esfera/toro/join), base de arena del set.
- sentar_y_guardar(): asentado E-12 del grupo con assert E-24 + stats
  impresos + .blend propio por ítem (decor_{nombre}_lowpoly.blend).
- 30 ítems organizados por sets del plan §5.5 (ver checklist M18-TER).

### Los 30 ítems (por set)
- Iluminación (4): lámpara de pie, farol de mesa con vela, vela en plato,
  lámpara de techo colgante (5 eslabones)
- Pared (5): cuadro floral, máscara ancestral, reloj de madera, espejo
  con marco, repisa flotante con velita+libro+concha
- Plantas (3): maceta palmera, helecho colgante (3 cuerdas), flor tropical
- Alfombras (2): floral redonda r0.80, tejida 1.60×1.00 con flecos
- Cocina (3): olla de barro con tapa, plato de frutas, jarrón de agua
- Ancestral (4): tótem de 3 caras, ídolo moai con musgo, vasija ritual con
  glifos azules, estatuilla de ave tallada
- Oceánico (3): concha grande, farol de coral con luz, cofre de perlas
- Floral (3): jarrón con flores secas, guirnalda de 8 flores con lazo
- Mobiliario (3): baúl de madera, mecedora con rockers y cojín,
  banco de jardín con 2 cojines
- Exteriores (2): fuentita de patio con agua alpha

### Bugs del batch corregidos en la sesión
1. **E-91 (nuevo):** matrix_world STALE en batch tras mover objetos en el
   mismo frame — assert de z_min daba 0.5080 con el grupo bien colocado.
   Fix: depsgraph.update() explícito antes de medir. Documentado inline.
2. **E-92 (nuevo):** tras open_mainfile en headless, las refs Python a
   cámara/luz de la escena previa quedan muertas ("StructRNA removed") —
   el capturador re-crea cámara+sol DESPUÉS de cada apertura.

### Capturas
30/30 capturas 3/4 frontal (cap_18_decor_*_2026-09-05_20-23-12.png),
encuadre automático por bounding del grupo. En 18-Casas/capturas/.

## Archivos Creados
- tools/mcp/blender-mcp/18-Casas/scripts/crear_decoracion_tienda_batch.py
- 30 × decor_{nombre}_lowpoly.blend en 18-Casas/
- 30 capturas PNG
- CHECKLIST-OBJETOS-BLENDER.md §M18-TER + contadores

## Pendiente
- REVISIÓN VISUAL del usuario (V1) ítem por ítem — corregir los que
  señale (el framework permite iterar rápido cada uno).
- Tras aprobación: exportar GLB individuales + variantes MEDIA/BAJA
  (exportar_godot.py) para el grid RF6 y el catálogo de la tienda (M38).
- E-91/E-92 documentados inline; faltan en la guía 09 §3 (registro).

## Addenda v2/v3 (feedback usuario: "algunos mal ensamblados con partes en el aire")
**Respuesta:** no delegado — resuelto por glm-5.3-free en la misma sesión.

**Correcciones de ensamblaje (v2):**
- Pilas recalculadas pieza a pieza: jarrón_agua (cuello 10 cm flotando),
  jarron_flores (boca 6.5 cm), olla_barro (cuello 7.5 cm), totem_chico
  (caras 16 cm + penacho 21 cm), idol_piedra (cabeza 4.5 cm), vasija
  (glifo 3 + tapa flotando), cofre_perlas (perla alta 5 cm), maceta
  palmera/flor (tierra 3-6 cm sobre el borde).
- alfombra_tejida: flecos colgando 12 cm bajo la alfombra la levantaban
  → horizontales.
- lampara_pie: poste medio enterrado y pantalla 60 cm arriba → pila real.
- mecedora: brazos sin nada debajo → postes asiento→brazo.
- Items de pared (6): flotaban sin contexto → Set_Pared (panel+postes)
  detrás, dorso de cada ítem apoyado en la cara; helecho con horca de
  set (viga) y gancho colgado real.
- concha_decor: abanico articulado desde la base.

**Validador nuevo (soportes_decor.py):** recorre los 30 .blend y exige
que cada pieza SM_ esté soportada (suelo / top de otra pieza / EMBEBIDA
con solape vertical+planta — tapas que abrazan cuellos, asas, musgo,
frondas al ras / set pared-horca / colgada). Resultado final:
**0 piezas en el aire en 30/30 ítems** (26 detectadas en la primera
pasada: 23 falsos positivos por criterio incompleto + 3 reales que se
corrigieron: campana del farol 5.5 cm, maceta-helecho cuerdas/gancho,
respaldo mecedora).

**E-93 (nuevo, documentado inline):** validadores geométricos deben
aceptar EMBEBIDO (solape vertical+planta) como soporte válido — el
ensamblaje lowpoly usa interpenetración controlada; exigir solo contacto
"top≈base" genera falsos positivos masivos.

## Addenda v4/v5 (feedback usuario: formas raras en 5 items + vasija)
1. **farol_mesa:** el "aro" era un torus R 0.10 ATRAVESANDO el farol.
   Ahora manija compacta (R 0.05) sobre el tope del vidrio, anclada al
   poste (asa vertical real de farol).
2. **alfombra_floral:** el anillo era un torus PARADO (rot X 90 = plano
   YZ) cortando la alfombra como órbita ("modelo atómico"). El torus de
   Blender YA es plano en XY — sin rotación es el aro correcto.
3. **fuente_chica:** idem — el borde era perpendicular al círculo.
   Ahora torus sin rotar, plano, al ras del tope de la pileta.
4. **vasija_ritual (detectado por el agente, mismo bug):** los 3 glifos
   eran aros parados cortando el cuerpo → bandas planas alrededor.
5. **maceta_palmera REDESÑO:** palmera real — maceta troncocónica
   invertida, tronco de 5 segmentos curvos, corona de hojas ARCADAS en
   dos alturas + 2 cocos. (18 SM_, 304 tris)
6. **maceta_helecho REDESÑO:** helecho en cascada — maceta cónica, 8
   frondas arco naciendo del borde y cayendo por fuera (dos capas),
   colgado de la horca con 3 cuerdas al gancho. (17 SM_)

**E-94 (nuevo, documentado inline):** el torus de Blender es PLANO en XY
por defecto — ot=(pi/2,0,0) lo PARA en vertical. Para aros/anillos/
bandas que rodean algo en el plano del suelo: SIN rotación. Para asas
laterales de ollas (plano XZ): rot Z 90. El aro parado fue la causa de
"órbitas atómicas" en alfombra/fuente/vasija y de la manija gigante.
Revalidado: soportes 0 piezas al aire, 30/30. Capturas regeneradas.
