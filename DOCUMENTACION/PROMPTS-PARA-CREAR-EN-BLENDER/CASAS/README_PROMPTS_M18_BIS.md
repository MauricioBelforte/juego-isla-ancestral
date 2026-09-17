# PROMPTS M18-BIS — Casas Grandes Habitables

**Modelo:** Acompanante
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

> Instrucciones para el modelo que creara las casas en Blender.
> Cada prompt es independiente. El modelo NO tiene contexto del proyecto,
> asi que toda la info esta en el prompt.

---

## CONTEXTO GENERAL DEL JUEGO (leer una vez)

Juego de estilo **"Cozy Voxel"**: el terreno es de bloques cúbicos de 1 metro, pero los objetos de decoracion, muebles, vegetacion y personajes son modelos 3D stylizados, redondeados y detallados (NO cubicos). El estilo visual es **isla tropical ancestral** — imagina una aldea polinesia o del sudeste asiatico, con madera rústica, techos de paja, piedra natural y toques ancestrales tallados.

### Escala de referencia
- **Personaje (NPC):** 1.75 m de alto
- **Puerta interior:** 1.00 m ancho × 2.10 m alto (el personaje entra sin agacharse)
- **Techo minimo interior:** 2.60 m (para que no se sienta estrecho)
- **Cama:** 2.00 × 0.90 m
- **Mesa:** 0.80 m alto (plano de trabajo)
- **Silla:** asiento a 0.45 m, respaldo a 0.90 m
- **Holgura minima entre muebles:** 0.90 m (para que el personaje camine entre ellos)
- **Bloque del terreno:** 1×1×1 m

### Paleta de materiales (sin electricidad — todo es rustico)
- **Madera clara:** troncos pelados, tonos miel/ocre claro (paredes, vigas, muebles)
- **Madera oscura:** troncos envejecidos, tonos cafecino (postes, Marcos de puertas)
- **Paja seca:** ambar claro a ambar oscuro (techos, colchones, esteras)
- **Piedra natural:** gris cenizo a gris oscuro (cimientos, zocalos, chimeneas)
- **Piedra musgosa:** gris con toques verdes (piedras de rio, bordes)
- **Tela/crudo:** beige a blanco roto (cortinas, mantas, toldos)
- **Cuero:** marron tostado (correas, manijas, detalles)
- **Cobre/bronce:** tonos anaranjados-metalicos (remaches, cierres, accesorios)
- **Vegetal verde:** verde hoja para plantas interiores

### Convenciones de modelado
- Usar **bpy** (Blender Python API)
- Todos los nombres de objetos deben empezar con `SM_` (ej: `SM_Pared_Madera`)
- Todos los nombres de materiales deben empezar con `MAT_` (ej: `MAT_MaderaClara`)
- Geometria lowpoly: minimos poligonos pero con silueta clara
- **z_min del grupo completo debe ser 0.045** (接触 el suelo ligeramente elevado, como si hubiera una base de cimiento)
- Las casas son **STANDALONE** (completas, no modulares) — se crean como una sola composicion
- Orientacion: eje X = largo, eje Y = ancho, eje Z = alto
- Las puertas miran hacia +Y (frente de la casa)

### Presupuesto por casa
- **Objetos (SM_):**|maximo 16 por habitacion (una casa puede tener mas, documentar)
- **Triangulos:** ALTA <= 6000, MEDIA <= 1500, BAJA <= 700
- **Materiales (MAT_):** ALTA <= 8, MEDIA <= 6, BAJA <= 4

### Capturas
- 6 vistas orbitales (0°, 60°, 120°, 180°, 240°, 300°)
- Altura de camara: ~45° sobre el horizonte
- Fondo: gris neutro (#808080)
- Guardar como JPG quality 90

---

## CASA 1 — Choza Ampliada (1 ambiente, 5×4 m)

**Concepto:** Una choza sencilla pero acogedora de un granjero o artesano. Un solo ambiente rectangular con todo lo basico: area de dormir, area de trabajo y pequena almacen. Techos de paja inclinada, paredes de madera rústica, suelo de tierra apretada o tablones.

### Dimensiones
- **Huella exterior:** 5.00 m (largo X) × 4.00 m (ancho Y)
- **Paredes:** grosor 0.12 m (tabla simple de 12 cm)
- **Techo interior minimo:** 2.60 m (累计 desde el suelo)
- **Cumbrera del techo:** ~3.20 m (inclinacion suave)
- **Puerta:** frontal centro, 1.00 × 2.10 m
- **Ventanas:** 2 ventanas laterales (0.60 × 0.60 m cada una)

### Estructura exterior
1. **Cimiento de piedra** — anillo perimetral de piedras irregulares (z_min 0.045, alto 0.20 m)
2. **Paredes** — tablones verticales de madera clara con postes de esquina de madera oscura (4 postes 0.10×0.10 m en las esquinas)
3. **Techo a dos aguas** — dos planos inclinados de paja (material MAT_PajaClara), cumbrera en el centro del largo (X=2.50), aleros de 0.30 m por cada lado. Los planos de paja deben tener un leve texturado de "capas" (3-4 franjas horizontales de diferentes tonos de paja)
4. **Marco de puerta** — madera oscura, con dintel y dos jambas
5. **2 ventanas** — marcos de madera con anteojos de tela cruda (alpha 0.7)

### Interior
- **Suelo** — tablones de madera clara (3-5 tablas largas paralelas al eje X)
- **Cama** — marinera simple: tablero de madera a 0.45 m + colchon de paja + manta beige (interactiva)
- **Mesa de trabajo** — tablero rectangular 1.20×0.60 m a 0.80 m alto + 4 patas robustas (interactiva)
- **Silla** — banco alto con respaldo (interactiva)
- **Estanteria de pared** — 2 tablas horizontales con libros/frascos (interactiva)
- **Hogar de leña** — rincon opuesto a la puerta: piedra empotrada + brasero metalico + chimney de piedra que sube por la pared hasta el techo (NO funcional, solo decorativo)

### Materiales
- `MAT_MaderaClara` — (180, 140, 90) roughness 0.85
- `MAT_MaderaOscura` — (90, 65, 40) roughness 0.90
- `MAT_PajaClara` — (210, 180, 120) roughness 0.95
- `MAT_Piedra` — (130, 125, 120) roughness 0.95
- `MAT_TelaCrudo` — (200, 190, 170) roughness 0.80
- `MAT_PiedraMoss` — (110, 120, 100) roughness 0.95
- `MAT_Cuero` — (120, 80, 45) roughness 0.75

### SM_ esperados (max 14)
1. `SM_Cimiento_Piedra` — anillo de piedras
2. `SM_Pared_Norte` — pared trasera
3. `SM_Pared_Sur` — pared frontal (con hueco de puerta)
4. `SM_Pared_Este` — pared lateral derecha (con hueco de ventana)
5. `SM_Pared_Oeste` — pared lateral izquierda (con hueco de ventana)
6. `SM_Techo_Izq` — plano inclinado izquierdo de paja
7. `SM_Techo_Der` — plano inclinado derecho de paja
8. `SM_Cumbrera` — viga horizontal superior
9. `SM_Suelo` — tablones del piso
10. `SM_Cama` — marinera con colchon
11. `SM_Mesa` — mesa de trabajo
12. `SM_Estanteria` — estanteria de pared
13. `SM_Hogar` — conjunto piedra+brasero
14. `SM_Silla` — banco alto

---

## CASA 2 — Casa Mediana (2 ambientes, 8×6 m)

**Concepto:** Una casa de pareja o familia pequena. Dos ambientes separados por una pared interior con puerta: una sala-comedor-cocina (lado izquierdo) y un dormitorio (lado derecho). Mas espacio, mas muebles, pero sigue siendo cozy y rustico.

### Dimensiones
- **Huella exterior:** 8.00 m (largo X) × 6.00 m (ancho Y)
- **Paredes:** grosor 0.12 m
- **Techo interior:** >= 2.60 m
- **Cumbrera:** ~3.40 m
- **Puerta principal:** frontal, desplazada a la derecha (X=5.50), 1.00 × 2.10 m
- **Puerta interior:** entre ambientes, 0.90 × 2.10 m
- **Ventanas:** 4 totales (2 por ambiente)

### Estructura exterior
1. **Cimiento de piedra** — anillo perimetral + division interior (alto 0.25 m)
2. **Paredes** — tablones verticales, postes cada 2.00 m
3. **Techo a dos aguas** — paja con 2 ventanas de gato (claraboyas triangulares, 0.40×0.40 m) en el plano frontal
4. **Chimenea** — tubo de piedra que asoma por el techo del lado izquierdo (sala)
5. **Macetas** — 2 macetas con plantas tropicales en la entrada

### Interior — Sala/Cocina (lado izquierdo, ~4×6 m)
- **Suelo** — tablones de madera
- **Mesa de comedor** — rectangular 1.40×0.80 m + 4 sillas (interactiva)
- **Cocina de leña** — base de piedra + plancha metalica + chimenea conectada al tubo exterior (interactiva)
- **Nevera rustica** — bloque de piedra con tapa de madera, sin electricidad (interactiva)
- **Estanteria** — 3 tablas con vasijas, libros, frascos (interactiva)
- **Alfombra** — rectangular tejida, tonos tierra (decorativa)
- **Lampara de pie** — farol de madera con vela (interactiva)

### Interior — Dormitorio (lado derecho, ~4×6 m)
- **Suelo** — tablones de madera
- **Cama doble** — marco de madera + colchon + 2 almohadas + manta azulada (interactiva)
- **Velador** — mesa chica junto a la cama (interactiva)
- **Comoda** — cajonera baja con 3 cajones (interactiva)
- **Cuadro ancestral** — mascara tallada en madera oscura sobre la pared (interactiva)
- **Maceta interior** — planta hoja verde en maceta de barro (interactiva)
- **Ventana con vista** — ventana mas grande (0.80×0.60 m)

### Materiales
- `MAT_MaderaClara` — (180, 140, 90)
- `MAT_MaderaOscura` — (90, 65, 40)
- `MAT_MaderaMedia` — (140, 105, 65) (nuevo, para muebles)
- `MAT_PajaClara` — (210, 180, 120)
- `MAT_PajaOscura` — (170, 140, 80) (para el techo)
- `MAT_Piedra` — (130, 125, 120)
- `MAT_TelaCrudo` — (200, 190, 170)
- `MAT_TelaAzul` — (120, 140, 170) (manta, cortinas)
- `MAT_Cuero` — (120, 80, 45)
- `MAT_Barro` — (150, 110, 70) (macetas)
- `MAT_Verdura` — (80, 140, 60) (plantas)

### SM_ esperados (max 18)
1. `SM_Cimiento_Perimetral`
2. `SM_Cimiento_Division`
3. `SM_Pared_Norte`
4. `SM_Pared_Sur` (con huecos de puerta principal)
5. `SM_Pared_Este`
6. `SM_Pared_Oeste`
7. `SM_Pared_Interior` (con hueco de puerta interna)
8. `SM_Techo_Izq`
9. `SM_Techo_Der`
10. `SM_Cumbrera`
11. `SM_Chimenea_Exterior`
12. `SM_Suelo_Sala`
13. `SM_Suelo_Dormitorio`
14. `SM_Mesa_Comedor`
15. `SM_Cama_Doble`
16. `SM_Cocina_Leña`
17. `SM_Nevera_Rustica`
18. `SM_Comoda`

---

## CASA 3 — Casa Amplia / Casona (3-4 ambientes, 10×8 m)

**Concepto:** Una casa para una familia numerosa o un artesano próspero. Cuatro ambientes: sala de estar amplia (frente izquierda), cocina-comedor (frente derecha), dormitorio principal (tras izquierda) y dormitorio secundario/taller (tras derecha). Fachada con portico de entrada.

### Dimensiones
- **Huella exterior:** 10.00 m (largo X) × 8.00 m (ancho Y)
- **Paredes:** grosor 0.12 m
- **Techo interior:** >= 2.60 m
- **Cumbrera:** ~3.60 m
- **Portico de entrada** — toldo de lona sobre 2 postes, 2.00 m × 1.50 m, front delantero
- **Puerta principal:** frontal centro, 1.00 × 2.10 m, doble hoja de madera
- **Puertas interiores:** 3 puertas (0.90 × 2.10 m cada una)
- **Ventanas:** 6 totales (2 por ambiente frontal, 1 por ambiente trasero)

### Estructura exterior
1. **Zocalo de piedra** — bloque de piedra alta 0.30 m, con relieve de bloques (como los zocalos modulares M18)
2. **Paredes** — tablones con refill vertical (cada 0.50 m), postes de madera oscura cada 2.50 m
3. **Techo a dos aguas** — paja densa, con 2 claraboyas frontales mas grandes (0.50×0.50 m)
4. **Portico** — 2 postes de madera oscura + toldo de lona cruda + viga superior
5. **Chimenea doble** — 2 tubos de piedra (sala + cocina)
6. **Banco exterior** — junto a la puerta, asiento de madera con cojin de tela
7. **Farol exterior** — farol de piedra con brasero, junto a la entrada

### Interior — Sala de Estar (frente izq, ~5×4 m)
- **Suelo** — tablones de madera
- **Sillon / sofa** — 2-3 asientos con tapizado de tela cruda (interactivo)
- **Mesa baja** — para poner bebidas/libros, 1.00×0.60 m a 0.35 m alto (interactivo)
- **Estanteria grande** — pared completa, 3 niveles con libros, vasijas, ceramica (interactivo)
- **Lampara de pie** — farol alto con pantalla de tela (interactivo)
- **Alfombra redonda** — tejida, tonos cálidos (decorativa)
- **Cuadro floral** — lienzo con ramo de flores tropicales (interactivo)

### Interior — Cocina-Comedor (frente der, ~5×4 m)
- **Suelo** — piedra (diferente al dormitorio)
- **Mesa de comedor** — 1.60×0.90 m + 6 sillas (interactivo)
- **Cocina de leña completa** — base de piedra + 2 hornallas + horno + chimenea (interactivo)
- **Nevera rustica** — bloque de piedra con tapa (interactivo)
- **Estanteria de cocina** — ollas, platos, vasijas (interactivo)
- **Jarron de agua** — ceramica con asa, junto a la cocina (interactivo)

### Interior — Dormitorio Principal (tras izq, ~5×4 m)
- **Suelo** — tablones de madera
- **Cama doble** — marco alto + colchon + 2 almohadas + manta floral (interactivo)
- **2 veladores** — mesas chicas a cada lado de la cama (interactivo)
- **Comoda** — cajonera alta 5 cajones (interactivo)
- **Espejo de pared** — marco de madera con cristal azul translucido (interactivo)
- **Maceta** — planta hoja grande (interactivo)

### Interior — Dormitorio Secundario/Taller (tras der, ~5×4 m)
- **Suelo** — tablones de madera
- **Cama simple** — marinera (interactivo)
- **Mesa de trabajo** — 1.20×0.80 m con herramientas (interactivo)
- **Estanteria de herramientas** — herramientas colgadas, cajas (interactivo)
- **Banco de trabajo** — asiento alto sin respaldo (interactivo)

### Materiales
- Todos los anteriores mas:
- `MAT_Lona` — (190, 175, 150) roughness 0.85
- `MAT_PiedraOscura` — (90, 85, 80) (zocalo, chimenea)
- `MAT_Hierro` — (70, 70, 75) roughness 0.60 (herramientas, cierres)
- `MAT_Vidrio` — (150, 170, 200) alpha 0.50 (espejo, ventanas)

### SM_ esperados (max 20)
1. `SM_Zocalo_Piedra`
2. `SM_Pared_Norte`
3. `SM_Pared_Sur` (con 2 huecos de puerta)
4. `SM_Pared_Este`
5. `SM_Pared_Oeste`
6. `SM_Pared_Interior_1` (div sala/dorm-principal)
7. `SM_Pared_Interior_2` (div sala/dorm-secundario)
8. `SM_Pared_Interior_3` (div cocina/dorm-secundario)
9. `SM_Techo_Izq`
10. `SM_Techo_Der`
11. `SM_Cumbrera`
12. `SM_Portico_Postes`
13. `SM_Portico_Toldo`
14. `SM_Chimenea_1`
15. `SM_Chimenea_2`
16. `SM_Sillon`
17. `SM_Mesa_Comedor`
18. `SM_Cama_Doble`
19. `SM_Cocina_Completa`
20. `SM_Estanteria_Grande`

---

## CASA 4 — Mansion (multi-habitacion, 14×10 m)

**Concepto:** La casa mas grande de la aldea, para un personaje importante (lider, sabio, o familiar numeroso). Cinco ambientes: gran sala de recepcion (frente), cocina amplia (frente der), comedor (centro), biblioteca/sala de lectura (tras izq) y dormitorio principal con vestidor (tras der). Fachada imponente con doble techo y torre-cilindro decorativa en una esquina.

### Dimensiones
- **Huella exterior:** 14.00 m (largo X) × 10.00 m (ancho Y)
- **Paredes:** grosor 0.15 m (un poco mas gruesas para la mansion)
- **Techo interior:** >= 2.80 m (mas alto que las demas)
- **Cumbrera:** ~3.80 m
- **Torre-cilindro** — esquina trasera derecha, radio 1.50 m, alto hasta 4.50 m, techo-cono
- **Puerta principal:** frontal centro, 1.20 × 2.20 m (mas ancha), doble hoja tallada
- **Puertas interiores:** 4 puertas
- **Ventanas:** 8 totales, mas grandes que las otras casas (0.80×0.70 m)
- **Columnas del portico** — 4 columnas de piedra en la entrada

### Estructura exterior
1. **Zocalo de piedra alta** — 0.40 m, bloques mas grandes y regulares
2. **Paredes** — tablones con Postes cada 3.00 m, 2 paneles decorativos tallados en la fachada frontal (motivos ancestrales: espirales, olas)
3. **Techo doble** — nivel inferior (alero 0.50 m) + nivel superior (cumbrera 0.30 m mas alta), ambos de paja
4. **Portico de entrada** — 4 columnas de piedra + viga de madera + toldo de lona
5. **Torre-cilindro** — paredes de piedra cilindrica, 3 ventanas estrechas, techo-cono de paja
6. **2 chimeneas** — una para la cocina, una para la gran sala
7. **Terraza lateral** — area pavimentada con piedra, 3.00×2.00 m, con banco y maceta

### Interior — Gran Sala de Recepcion (frente izq, ~7×5 m)
- **Suelo** — tablones de madera con alfombra grande rectangular
- **Sillon grande** — L-shaped o 3 asientos grandes (interactivo)
- **Mesa central** — 1.20×0.80 m a 0.35 m (interactivo)
- **Estanteria monumental** — pared completa, 4 niveles, libros + ceramica + trofeos (interactivo)
- **2 lamparas de pie** — faroles altos a ambos lados de la estanteria (interactivo)
- **Mascara ancestral grande** — tallada en madera oscura, sobre la pared principal (interactivo)
- **Planta interior grande** — palmera enana en maceta de barro (interactivo)

### Interior — Cocina Amplia (frente der, ~5×5 m)
- **Suelo** — piedra
- **Mesa de trabajo** — isla central 1.40×0.80 m (interactivo)
- **Cocina de leña completa** — con horno grande + 3 hornallas (interactivo)
- **Nevera doble** — 2 bloques de piedra (interactivo)
- **Estanteria de cocina** — ollas, sartenes, vasijas (interactivo)
- **Lavadero** — pila de piedra con agua (interactivo)

### Interior — Comedor (centro, ~5×4 m)
- **Suelo** — tablones de madera
- **Mesa para 8** — rectangular 2.00×1.00 m + 8 sillas (interactivo)
- **Lampara de techo** — colgante con 5 eslabones de cuerda + platillo (interactivo)
- **Cuadro o mascara** — decoracion de pared (interactivo)

### Interior — Biblioteca/Sala de Lectura (tras izq, ~5×5 m)
- **Suelo** — tablones con alfombra redonda
- **Sillon tapizado** — 1 asiento grande con tapizado de tela oscura + reposapiernas (interactivo)
- **Mesa de lectura** — 0.80×0.60 m a 0.80 m alto + lampara de vela (interactivo)
- **Estanteria de pared** — 4 niveles, solo libros (interactivo)
- **Cuadro ancestral** — mapa o glifo tallado (interactivo)

### Interior — Dormitorio Principal + Vestidor (tras der, ~5×6 m)
- **Suelo** — tablones de madera
- **Cama king-size** — 2.20×1.80 m + dosel de tela (interactivo)
- **2 veladores grandes** — mesas con cajon (interactivo)
- **Vestidor** — estanteria abierta con ropa colgada (percha de madera + piezas de tela) + espejo de cuerpo entero (interactivo)
- **Mecedora** — silla con rockers + cojin (interactivo)
- **Maceta grande** — planta hoja ancha (interactivo)

### Torre-cilindro (acceso desde dormitorio)
- **Escalera de caracol** — rampa helicoidal de madera alrededor de un poste central
- **Plataforma superior** — mirador con vistas, banco circular, techo abierto

### Materiales
- Todos los anteriores mas:
- `MAT_PiedraClara` — (160, 155, 150) (columnas, torre)
- `MAT_MaderaTallada` — (100, 70, 40) roughness 0.80 (paneles decorativos, puerta principal)
- `MAT_TelaOscura` — (70, 60, 55) (tapizado sillon, dosel)
- `MAT_Cuerda` — (140, 120, 80) (lamparas colgantes)

### SM_ esperados (max 24)
1. `SM_Zocalo_Piedra`
2. `SM_Pared_Norte`
3. `SM_Pared_Sur` (con 2 huecos puertas)
4. `SM_Pared_Este`
5. `SM_Pared_Oeste`
6. `SM_Pared_Interior_1`
7. `SM_Pared_Interior_2`
8. `SM_Pared_Interior_3`
9. `SM_Pared_Interior_4`
10. `SM_Techo_Inferior_Izq`
11. `SM_Techo_Inferior_Der`
12. `SM_Techo_Superior`
13. `SM_Cumbrera`
14. `SM_Portico_Columnas`
15. `SM_Portico_Techo`
16. `SM_Torre_Cilindro`
17. `SM_Torre_Cono`
18. `SM_Chimenea_1`
19. `SM_Chimenea_2`
20. `SM_Terraza`
21. `SM_Sillon_Grande`
22. `SM_Mesa_Comedor`
23. `SM_Cama_King`
24. `SM_Estanteria_Monumental`

---

## CASA 5 — Casa de Vecino (variante cozy, ~7×5 m)

**Concepto:** Una casa generica que puede repetirse en la aldea como vivienda de NPC vecino. Basada en la Casa Mediana pero con variantes que la hacen unica: colores diferentes en la paja, distribucion ligeramente distinta, muebles minimos pero funcionales. Es la "casa estandar" del pueblo.

### Dimensiones
- **Huella exterior:** 7.00 m (largo X) × 5.00 m (ancho Y)
- **Paredes:** grosor 0.12 m
- **Techo interior:** >= 2.60 m
- **Cumbrera:** ~3.20 m
- **Puerta:** frontal, ligeramente a la izquierda (X=2.50), 1.00 × 2.10 m
- **Ventanas:** 3 (1 frontal a la derecha de la puerta, 1 lateral trasera, 1 lateral frontal)

### Estructura exterior
1. **Cimiento de piedra** — anillo bajo (alto 0.15 m, mas bajo que las demas)
2. **Paredes** — tablones verticales, mas uniformes que la choza (pueblo prospero)
3. **Techo a dos aguas** — paja con color ligeramente diferente (mas anaranjada)
4. **Toldo sobre la puerta** — pequeno toldo de lona sobre 2 soportes de madera
5. **Cercado de madera** — valla baja (0.80 m) con postes y 2 travesanos, delimita un patio frontal pequeno
6. **Mascara de pared** — decoracion ancestral sobre la puerta

### Interior — Ambiente Unico (~7×4 m interior)
- **Suelo** — tablones de madera
- **Cama doble** — contra la pared trasera (interactivo)
- **Mesa pequena** — 2 sillas, para comer/charlar (interactivo)
- **Cocina de leña** — esquina derecha, base piedra + hornalla (interactivo)
- **Estanteria** — 2 niveles con basics (interactivo)
- **Alfombra** — rectangular, tonos tierra (decorativa)
- **Farol de pie** — iluminacion (interactivo)
- **Maceta** — planta junto a la ventana (interactivo)

### Materiales
- Mismos que Casa 1 pero:
- `MAT_PajaAnaranjada` — (200, 160, 100) (paja mas anaranjada que la choza)
- `MAT_MaderaUniforme` — (170, 130, 85) (paredes mas uniformes)

### SM_ esperados (max 14)
1. `SM_Cimiento_Piedra`
2. `SM_Pared_Norte`
3. `SM_Pared_Sur` (con hueco puerta)
4. `SM_Pared_Este`
5. `SM_Pared_Oeste`
6. `SM_Techo_Izq`
7. `SM_Techo_Der`
8. `SM_Cumbrera`
9. `SM_Suelo`
10. `SM_Toldo_Puerta`
11. `SM_Valla_Patio`
12. `SM_Cama`
13. `SM_Mesa_Sillas`
14. `SM_Cocina`

---

## CHECKLIST POR CASA (repeter para cada una)

Para cada casa, el modelo debe:

- [ ] Crear el .blend con todos los SM_
- [ ] Verificar z_min del grupo = 0.045
- [ ] Verificar que la puerta mide 1.00×2.10 m
- [ ] Verificar que el techo interior >= 2.60 m
- [ ] Verificar que los muebles caben en el espacio
- [ ] Generar 6 capturas orbitales (0°, 60°, 120°, 180°, 240°, 300°)
- [ ] Generar variante MEDIA (decimate ~50%)
- [ ] Generar variante BAJA (decimate ~75%)
- [ ] Exportar 3 GLB (source, media, baja)
- [ ] Guardar capturas como JPG quality 90
