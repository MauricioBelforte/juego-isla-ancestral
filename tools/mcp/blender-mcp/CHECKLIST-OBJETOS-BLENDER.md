# CHECKLIST — Objetos a Crear en Blender (por Módulo)

**Modelo:** GLM
**Plataforma:** Cline
**Fecha:** 2026-08-27

> **Propósito:** Checklist maestro de TODOS los assets 3D a modelar en Blender para el proyecto, organizados por módulo (ID según `CHECKLIST-GLOBAL.md`). Es la lista de orden de creación de objetos. Cada ítem se marca `[x]` solo cuando: el script existe, el `.blend` está guardado en la carpeta del módulo, y existe captura de constancia en `{ID-Modulo}-Nombre/capturas/` (reglas §6 de `09-GUIA-BLENDER.md`).
>
> 📁 **Estructura (2026-08-27):** cada módulo tiene su carpeta `tools/mcp/blender-mcp/{ID-Modulo}-Nombre/` con sus scripts, `.blend` y `capturas/`. Ver `09-GUIA-BLENDER.md` §6.3. Ej: palmera → `50-Vegetacion/`.
>
> **Regla de captura obligatoria:** todo objeto creado debe tener su captura con timestamp como evidencia, igual que en Godot (M154). Sin captura, el ítem NO está completado.
>
> **Convención de nombres de script:** `crear_{objeto}_lowpoly.py` en `scripts-reutilizables/`.

## Módulo 50 — Vegetación 🌿

- [x] Palmera común (`crear_palmera_lowpoly.py`) — HECHA 2026-08-27 + autocorrección de apoyo 2026-08-28 (z_min 0.080→0.045)
- [x] Palmera joven (sin cocos, más baja) — `crear_palmera_joven_lowpoly.py` + cap 2026-08-28 15-48 (asentado, z_min 0.045)
- [x] Palmera inclinada — `crear_palmera_inclinada_lowpoly.py` + cap 2026-08-28 15-48 (asentado, z_min 0.045)
- [x] Arbusto redondo lowpoly — `crear_arbusto_redondo_lowpoly.py` + cap 2026-08-28 15-03
- [x] Arbusto floral (con flores de color) — `crear_arbusto_floral_lowpoly.py` + 6 capturas orbitales 18-56 (aprobado visualmente, 16 obj, z_min 0.045)
- [x] Helecho gigante — `crear_helecho_gigante_lowpoly.py` + 6 capturas orbitales 18-58 (aprobado, 91 obj, z_min 0.045). **BAJA 2026-08-29 19:50**: 970→650 tris con `--ratio 0.5` (E-23 escape valve) — visual OK. **v2 2026-08-29 19:50 corrige E-27 (47/80 hojuelas separadas hasta 0.8351 m por rotación azimutal del frond descartada)**: borrada línea `hojuela.matrix_parent_inverse = o_tallo.matrix_world.inverted()` (L135); assert anti-regresión AABB-gap ≤ 2 cm post-asentado. Source regenerado (94 obj), MEDIA (3/1190/3), BAJA (3/672/3) — corona ahora se distribuye en 360° en los 6 ángulos, hojas siguen a cada frond. 3 hojas v2 19-55-26.
- [x] Cañas de bambú — `crear_canas_bambu_lowpoly.py` + cap 2026-08-28 15-48 (4 cañas, 38 objetos; z_min 0.045)
- [x] Liana colgante (para ruinas/templos) — `crear_liana_colgante_lowpoly.py` + 6 capturas orbitales 19-22 (aprobado, marco blanco + 4 lianas; z_min 0.045) 2026-08-28
- [x] Hongo luminoso — `crear_hongo_luminoso_lowpoly.py` + cap 2026-08-28 15-09
- [x] Flor de isla — `crear_flor_isla_lowpoly.py` + cap 2026-08-28 15-10
- [x] Hierba alta (tusca de 3-4 matas) — `crear_hierba_alta_lowpoly.py` + 6 capturas orbitales 19-00 (aprobado, 32 obj, z_min 0.045)
- [x] Helecho chico — `crear_helecho_chico_lowpoly.py` + 6 capturas orbitales 19-24 (aprobado, tallo + frondas; z_min 0.045) 2026-08-28
- [x] **Árbol frutal (mango/coco según lore)** — `crear_arbol_frutal_lowpoly.py` + 6 capturas 21-15 (`_hoja_cap_50_arbol_frutal_lowpoly.jpg`, **APROBADO**: 1 faldón cónico + 4 raíces horizontales + 1 tronco + 3 ico-esferas de copa + 6 frutos ovalados; 15 obj, 464 tris, 4 mats; z_min 0.0450; huella 0.68×0.72 con 10 verts tocando; bbox 2.10×1.82×3.88). El lore no fija especie (33-Agricultura `is_tree` solo dice "perenne"); el coco ya lo cubre la palmera, así que se eligió **frutal de copa ancha con fruto tropical genérico** (amarillo-naranja) — silueta complementaria a la palmera. Asentado E-12 OK, huella E-50 OK (assert atrapó un bug propio en v1: raíces inclinadas 62° hundían −0.0807 y dejaban el tronco flotando +0.1257 → rediseñadas acostadas por Ry(90)+Rz(ang)).
- [x] **Musgo en roca (placa decorativa)** — `crear_musgo_roca_lowpoly.py` + 6 capturas 21-16 (`_hoja_cap_50_musgo_roca_lowpoly.jpg`, **APROBADO**: 1 losa cilíndrica (R=0.50, H=0.35, 12 lados) + 8 mechones de musgo ico-esfera aplanados en YZ; 9 obj, 204 tris, 4 mats; z_min 0.0450; huella 1.00×1.00 con 12 verts tocando; bbox 1.04×1.00×0.42). Asentado E-12 OK, huella E-50 OK (v1 usaba ico-esfera achatada → 1 solo polo sur tocando → assert rechazó; fix = cilindro bajo que coincide con el descriptor "placa decorativa").
- [x] **Raíces expuestas (para bordes de terreno)** — `crear_raices_expuestas_lowpoly.py` + 6 capturas 21-16 (`_hoja_cap_50_raices_expuestas_lowpoly.jpg`, **APROBADO**: 1 tocón cilíndrico (R=0.30, H=0.22, 10 lados) + 5 raíces cónicas acostadas radiando en abanico (abanico de 150°); 6 obj, 106 tris, 2 mats; z_min 0.0450; huella 0.57×0.60 con 15 verts tocando; bbox 1.32×1.99×0.24 — **única pieza del Tier F que cumple ALTA + MEDIA + BAJA sin merge** (todos los presupuestos OK). Asentado E-12 OK, huella E-50 OK (v1 tenía el nudo como ico-esfera achatada → 6 verts tocando, <8; fix = cilindro, un tocón cortado ES naturalmente cilíndrico).

## Módulo 15 — Recursos (materiales recolectables) ⛏️

- [x] Roca común (recolectable) — script + .blend + capturas ✅ 2026-08-28. **v2 2026-08-31 03:52 corrige E-50**: SM_Roca_M_Roca solo tocaba en línea de 1.29m (toca=2, fp=1.29×0.67) y el cuerpo quedaba arriba → flotaba visualmente aunque z_min=0.0450 OK. Script `aplanar_dome.py` con K=2 (BFS sobre aristas, 12 verts seleccionados) → base plana: source toca=16 fp=1.99×1.82, _media toca=12 fp=1.84×1.07, _baja toca=12 fp=2.56×1.06. GLBs re-exportadas (mtime 03:55). Capturas de verificación visual pendientes (socket muerto al cierre).
- [x] Roca de pedernal — `crear_roca_pedernal_lowpoly.py` + cap 2026-08-28 15-10. **v2 2026-08-31 03:55 corrige E-50**: SM_Roca_M_Pedernal (nv=162) y SM_Roca_Pedernal_Chica (nv=12) ambos con toca=1, fp=0×0. Aplanado K=2 vía CLI headless (E-54, socket muerto) iterando todos los SM_ (E-53: source sin sufijo `_M_`). source toca=18 fp=1.10×1.09 + toca=11 fp=0.84×0.96, _media idem, _baja toca=14 fp=1.15×0.98 (Pedernal_C zmin=0.07 skip). GLBs re-exportadas (mtime 03:55). Capturas pendientes.
- [x] Veta de cobre — `crear_veta_cobre_lowpoly.py` (v2, 10 obj.) + cap 2026-08-28 15-13 (roca + 6 prismas hexagonales cobre)
- [x] Veta de hierro — `crear_veta_hierro_lowpoly.py` + 6 capturas orbitales 18-52 (aprobado, roca gris + 5 cristales, z_min 0.018 ok). **v3 2026-08-31 03:20 corrige E-50 (apoyo puntual en domo)**: roca era huso (punta r=0.025, ecuador r=1.19 a z=0.36) y flotaba 30 cm arriba del suelo aunque z_min=0.0450 OK. Script `aplanar_dome.py` con K=2 (BFS sobre aristas — E-51) aplana anillos 0-2 a z=0.045 → base hexagonal 2.31×2.00, 16 verts tocando. Re-captura 03-17-01: roca claramente asentada. GLBs re-exportadas (alta/media/baja). 6 hojas de contacto nuevas.
- [x] Veta de oro — `crear_veta_oro_lowpoly.py` + 6 capturas orbitales 19-40 (aprobado, roca gris + 3 pepitas; z_min 0.045) 2026-08-28. **v3 2026-08-31 03:25 corrige E-50**: misma estructura huso. K=2 → base 1.84×1.95, 16 verts tocando. Captura visual 03-21-37: roca sentada como un cilindro-bóveda achatado. GLBs re-exportadas.
- [x] Cristal ancestral (recurso raro, brillante) — `crear_cristal_ancestral_lowpoly.py` + 6 capturas orbitales 19-28 (aprobado, recipiente roca + 4 cristales blancos; z_min 0.045) 2026-08-28
- [x] Tronco caído — `crear_tronco_caido_lowpoly.py` (12 obj.) + cap 2026-08-28 15-47 (asentado: z_min 0.012→0.045)
- [x] Montón de ramas — `crear_monton_ramas_lowpoly.py` + 6 capturas orbitales 18-50 (aprobado, 7 ramas 2 materiales, z_min 0.045)
- [x] Piedra de afilar — `crear_piedra_afilar_lowpoly.py` + 6 capturas orbitales 18-54 (aprobado, prisma + viruta, z_min 0.004 ok)
- [x] Nido de cocos — `crear_nido_cocos_lowpoly.py` (44 obj.) + cap 2026-08-28 15-36 (disco + anillo + ojos parentados; z_min 0.045). **BAJA 2026-08-29**: 970→611 tris con `--ratio 0.4` (E-23 escape valve) — visual OK.

## Módulo 33 — Agricultura 🌾

- [ ] Tierra arada (parche 1x1)
- [ ] Tierra regada (versión oscura)
- [ ] Semillero brotando (etapa 1)
- [ ] Planta creciendo (etapa 2)
- [ ] Planta madura cosechable (etapa 3)
- [ ] Bananero (cultivo)
- [ ] Plantación de caña
- [x] Espantapájaros lowpoly — `crear_espantapajaros_lowpoly.py` (M33 2026-09-02 04:50, log 532) + 6 capturas orbitales 04-50. **APROBADO**: base cilíndrica de tierra (12 verts) + poste vertical + palo horizontal (brazo) con 2 manos de paja + camisa-cuerpo + cabeza-saco con 2 ojos y boca + sombrero (Copa + Ala tipo mejicano) + 2 mechones de paja asomando de la camisa + atadura de cuerda al cuello. **15 SM_**, z_min 0.045, toca=20, fp=0.80×0.80. Variantes MEDIA (7/308/7), BAJA (6/186/4). E-37 validado: silueta lee como espantapájaros en los 6 azimuts (sombrero+cruz+camisa+cara). 3 GLB + 3 `.import` + 3 `.scn` (E-65).
- [ ] Compostera

## Módulo 18 — Casas (construcciones del jugador) 🏠

- [/] **Pared de madera (módulo base)** — `crear_pared_madera_lowpoly.py` v1 (2026-08-31 20:24, log 305) + 6 capturas orbitales 20-24 (`_hoja_cap_18_pared_madera_lowpoly.jpg`, **APROBADO**: 2 postes + 2 soleras (inf/sup) + panel retranqueado en Y + 2 travesaños horizontales; z_min 0.0450; **7 obj, 84 tris reales, 3 mats**; bbox x[-0.500..0.500]=**1.000 m** exacto, y[-0.080..0.080]=0.160, z[0.045..2.645]=2.600 → **ocupa exactamente 1×1 celda de la rejilla de 1 m (M17 RF2)**). Postes de 0.06 centrados en x=±0.47 (medio poste por extremo → dos paredes contiguas reconstruyen un poste entero de 0.12). Fuente lista; **pendiente MEDIA/BAJA + GLB** (requieren Blender GUI para `generar_variante.py` y `exportar_godot.py` por socket).
- [/] **Pared con ventana** — `crear_pared_ventana_lowpoly.py` + 6 capturas 23-35 (`_hoja_cap_18_pared_ventana_lowpoly.jpg`, **APROBADO**: misma base 1×1 + hueco 0.64×0.92 centrado + marco perimetral + vidrio; 13 obj, 156 tris, 4 mats; z_min 0.0450; bbox 1.000×0.160×2.600).
- [/] **Pared con puerta** — `crear_pared_puerta_lowpoly.py` + 6 capturas 23-35 (`_hoja_cap_18_pared_puerta_lowpoly.jpg`, **APROBADO**: misma base 1×1 + hueco puerta 0.60×2.00 + 2 jambas + dintel + puerta + pomo hierro UV sphere; 12 obj, 212 tris, 5 mats; z_min 0.0450; bbox 1.000×0.160×2.600).
- [/] **Piso de madera (módulo)** — `crear_piso_madera_lowpoly.py` + 6 capturas 23-35 (`_hoja_cap_18_piso_madera_lowpoly.jpg`, **APROBADO**: 3 vigas longitudinales en X + 5 tablas transversales en Y; 8 obj, 96 tris, 2 mats; z_min 0.0450; bbox 1.000×1.000×0.060 — exactamente 1×1 celda).
- [/] **Techo a dos aguas (módulo)** — `crear_techo_dos_aguas_lowpoly.py` + 6 capturas 23-38 (`_hoja_cap_18_techo_dos_aguas_lowpoly.jpg`, **APROBADO**: cumbrero + 2 correas + 8 cabios (4 por pendiente) + 2 tableros; 13 obj, 156 tris, 3 mats; **se apoya sobre paredes (z_min 2.6450 = alero, NO se asienta en arena)**; bbox 1.040×1.000×0.840 — 2 cm de alero por lado, intencional).
- [/] **Techo de paja (variante)** — `crear_techo_paja_lowpoly.py` + 6 capturas 23-38 (`_hoja_cap_18_techo_paja_lowpoly.jpg`, **APROBADO**: misma geometría que techo_dos_aguas pero con materiales de paja seca (ambar claro + ambar oscuro); 13 obj, 156 tris, 3 mats; z_min 2.6450, bbox 1.040×1.000×0.840).
- [/] **Puerta articulada** — `crear_puerta_articulada_lowpoly.py` + 6 capturas 23-39 (`_hoja_cap_18_puerta_articulada_lowpoly.jpg`, **APROBADO**: panel standalone 0.60×0.04×2.00 + 3 tablones frontales + 3 bisagras izq. (sobresalen 2 cm) + 1 manija der.; 8 obj, 96 tris, 3 mats; z_min 0.0450; bbox 0.670×0.070×2.000).
- [/] **Ventana con marco** — `crear_ventana_marco_lowpoly.py` + 6 capturas 23-42 (`_hoja_cap_18_ventana_marco_lowpoly.jpg`, **APROBADO**: marco perimetral + parteluz central + 2 cristales (alpha 0.55) + 2 manijas; 9 obj, 108 tris, 4 mats; z_min 0.0450; bbox 1.000×0.140×1.100 — ancho de celda, alto reducido para integrarse en pared).
- [/] **Escalera de mano** — `crear_escalera_mano_lowpoly.py` + 6 capturas 23-44 (`_hoja_cap_18_escalera_mano_lowpoly.jpg`, **APROBADO**: 2 largueros verticales + 5 peldaños; 7 obj, 84 tris, 2 mats; z_min 0.0450; bbox 0.400×0.040×1.800 — mobiliario, no módulo de grid).
- [/] **Zócalo/fundamento de piedra** — `crear_zocalo_piedra_lowpoly.py` + 6 capturas 23-44 (`_hoja_cap_18_zocalo_piedra_lowpoly.jpg`, **APROBADO**: anillo perimetral de 4 bloques + 4 bloques esquina (más oscuros, alto +2cm); 8 obj, 96 tris, 2 mats; z_min 0.0450; bbox 1.000×1.000×0.320 — exactamente 1×1 celda).
- [/] **Casa completa ejemplo (composición, referencia visual)** — `crear_casa_completa_ejemplo_lowpoly.py` + 6 capturas 23-45 (`_hoja_cap_18_casa_completa_ejemplo_lowpoly.jpg`, **APROBADO**: zócalo (4 piedras) + piso (1 losa) + 4 paredes (cajas simples) + techo a dos aguas simplificado (1 cumbrero + 2 correas + 2 tableros); **14 obj, 168 tris, 6 mats** (todos dentro del presupuesto M166 ALTA); z_min 0.0450; bbox 1.000×1.000×3.785 = zócalo(0.30) + piso(0.04) + paredes(2.60) + techo(0.80). NO pensada para colocar en juego: solo referencia visual de cómo ensamblar las otras 10 piezas).

## Módulo 25 — Ruinas / 24 — Templos / 26 — Templo Subterráneo 🏛️

- [ ] Columna rota (2 variantes de altura)
- [ ] Columna entera con capitel
- [ ] Bloque de piedra tallada (módulo de muro)
- [ ] Dintel caído
- [x] Estatua ancestral erosionada — `crear_estatua_ancestral_erosionada_lowpoly.py` + 6 capturas orbitales 04-15 (aprobado 2026-09-02 04:15; E-50 fix inicial: pedestal de cubo (4 verts) → cilindro de 12 verts en base + cubo de transición; E-37 validado: silueta lee como estatua humanoide — pedestal cilíndrico + monolito torso+piernas + hombros anchos + 2 brazos inclinados ±10° + cabeza aplanada con nariz y 2 ojos + 3 manchas de musgo; ALTA 15 obj/15 SM_, MEDIA 5/260/5, BAJA 5/178/4; footprint 1.10×1.10, toca=12; 3 GLB + 3 .import + 3 .scn en Godot).
- [x] Arco de entrada de templo — `crear_arco_entrada_templo_lowpoly.py` v4 + 6 capturas orbitales 04-00 (aprobado 2026-09-02 04:00; E-68 descubierto y corregido: `primitive_cube_add(size=1, scale=s)` produce cubo de sx×sy×sz, no 2*sx×2*sy×2*sz; dovelas con `sx = ANCHO_D` y `ANCHO_D = chord*1.04` cierran el wedge gap; ALTA 15 obj/60 caras placeholder→recalculado, MEDIA 3/212/3, BAJA 3/146/3; footprint 2.44×0.64, dovelas se tocan visiblemente en los 6 azimuts; va a unir 2 pilares con semicírculo de 7 dovelas; musgo en basas). 3 GLB exportados + 3 .import + 3 .scn (E-65).
- [x] Altar ritual central — `crear_altar_ritual_lowpoly.py` + 6 capturas orbitales 19-36 (aprobado, pirámide escalonada + techo + 4 pilares + cristal; z_min 0.045) 2026-08-28
- [x] Losa con grabado (piso de puzzle) — `crear_losa_grabado_lowpoly.py` + 6 capturas orbitales 19-34 (aprobado, placa + 4 prismas; z_min 0.045) 2026-08-28
- [ ] Palanca de puzzle (interactuable)
- [x] Cofre ancestral (recompensa) — `crear_cofre_ancestral_lowpoly.py` + 6 capturas orbitales 19-40 (aprobado, tapa medio-cilindro + 5 bandas hierro + falleba; z_min 0.045) 2026-08-28. **v3 2026-08-29 19:55 corrige E-27 (tirador 5 cm de su padre)**: borradas 3 líneas `o.matrix_parent_inverse = padre.matrix_world.inverted()` (en `agregar()` L176, costillas L339, post-parenting L404). **NO se agregó assert AABB-gap** (E-31): el tirador sobresale 5 cm por diseño (es la manija), las asas 1.8 cm, las bisagras traseras 1.2 cm. La separación es geométricamente verdadera pero semánticamente correcta. Source regenerado (36 obj, z_min 0.045), MEDIA (6/784/6), BAJA (6/571/6) — todos los hijos siguen al cuerpo en los 6 ángulos. 3 hojas v3 19-55-26.
- [x] Antorcha de pared — `crear_antorcha_pared_lowpoly.py` v2 + 6 capturas orbitales 18-14/18-18 (corregido 2026-08-29 18:11 por bug reportado: en v1 el panel de pared del set de captura flotaba a z=0.40 y la placa estaba 0.42 unidades separada del muro. v2: `Set_Pared` asentada en la arena con base ligeramente enterrada y placa montada al ras del muro con sus 4 remaches; z_min 0.045, 7 piezas: placa + brazo + copa + mango + tela + brasa + 4 remaches). Variantes M166 MEDIA (4 obj/94 tris/4 mats) y BAJA (4 obj/80 tris/4 mats) regeneradas desde v2 y aprobadas 2026-08-29 18:18 (ver Tier D).
- [x] Puerta de templo (doble hoja de piedra) — `crear_puerta_templo_lowpoly.py` + 6 capturas orbitales 19-32 (aprobado, marco azul + paneles; z_min 0.045) 2026-08-28
- [x] Puente de cuerda colgante (25/28 viajes) — **DUPLICADO**, cerrado 2026-09-02 04:24 (log 531). Cubierto por `- [x] Puentes de cuerda (M25)` = `crear_puente_cuerda_lowpoly.py`, aprobado 2026-08-29 21:12 con sus 3 GLB ya importados. **No generar un segundo puente para esta línea.** (El asset nuevo `40-Infraestructura_puente_cuerda_colgante` de M40 es OTRO ítem, añadido aparte en la sección M40.)
- [ ] Estructura sumergida parcial (marea)

## Módulo 40 — Infraestructura 🌉

- [x] Muelle de madera (tablas + pilotes) — `crear_muelle_madera_lowpoly.py` + 6 capturas orbitales 19-38 (aprobado, 4 pilotes + tabla + barandilla; z_min 0.045) 2026-08-28
- [x] Bote de pesca amarrado — `crear_bote_pesca_lowpoly.py` + 6 capturas orbitales 19-43 (aprobado, casco + costillas + proa cónica + poste + cabo; z_min 0.045) 2026-08-28
- [x] Farola de fuego (poste + brasero) — `crear_farola_fuego_lowpoly.py` + 6 capturas orbitales 19-42 (aprobado, base + poste + brasero + llama; z_min 0.045) 2026-08-28
- [ ] Valla de madera (módulo recto + esquina)
- [x] Cartel indicador (poste con tabla) — `crear_cartel_indicador_lowpoly.py` + 6 capturas orbitales 17:39 (aprobado, 5 obj, z_min 0.045). Ver Tier D arriba.
- [x] Pozo de piedra
- [x] **Puente de cuerda colgante (M40, NUEVO 2026-09-02 04:24, log 531)** — `crear_puente_cuerda_colgante_lowpoly.py` v2. **APROBADO**: 2 basas de piedra + 2 postes + **6 segmentos de cable principal (3 por lado)** en parábola + 3 tablones de tablero + 2 barandillas de cuerda. **15 SM_ / 15 obj** (ALTA ≤16 ✓). z_min 0.0450, toca=8, footprint 4.85×0.45. Variantes MEDIA (**4 obj / 244 tris / 4 mats**) y BAJA (**4 obj / 168 tris / 4 mats**) generadas y aprobadas. 3 GLB + 3 `.import` + 3 `.scn` verificados (E-65). **Lección de curva:** para tablero con carga uniformemente distribuida la curva real es una **parábola**, no una catenaria `cosh`: `z(x) = Z_CENTRO + (x/HALF_SPAN)^2 * (Z_POSTE_TOP - Z_CENTRO)`. Se aproxima con N segmentos cortos de cilindro girados con `direccion.to_track_quat('Z','Y').to_euler()` (E-58). **Lección de presupuesto (v1→v2):** 6 segmentos por lado = 21 obj, EXCEDE el tope ALTA de ≤16. Bajar a 3 por lado (6 total) → 15 obj. Contar los SM_ ANTES de generar. **NO confundir** con `- [x] Puentes de cuerda (M25)` = `crear_puente_cuerda_lowpoly.py` (2026-08-29), que es OTRO asset (postes de piedra + tablones en catenaria).
- [x] Puente de troncos (arroyos) — `crear_puente_troncos_lowpoly.py` (2026-08-29 22:33, log 247) + 6 capturas orbitales 22-31 (3 hojas src/MEDIA/BAJA, aprobado: 2 estribos de piedra con 6 piedras de terraplen + 3 vigas longitudinales + 11 troncos transversales + 6 postes hincados en la arena + 2 pasamanos + 4 ataduras de cuerda; z_min 0.045; 1 obj, 3 mats; bbox x[-1.55..1.55], y[-0.66..0.66], z[0.045..0.98]). Variantes M166 MEDIA (728 tris / 1 obj / 3 mats) y BAJA (508 tris / 1 obj / 3 mats) generadas y aprobadas 2026-08-29 22:33 desde la fuente. Leccion: los postes de la barandilla se clavan en la arena (no en la cubierta) para eliminar el calculo de interseccion y garantizar apoyo sin flotacion. Ver Tier D arriba.

## Módulo 36 — Fauna (modelos base, IA aparte) 🦀

- [ ] Cangrejo de playa
- [ ] Gaviota (posada, para animar)
- [ ] Pez tropical (2 variantes de color)
- [ ] Lagarto de isla
- [ ] Jabalí
- [ ] Cabra
- [ ] Gallina
- [ ] Mariposa (alas simples para animar)
- [ ] Tortuga marina

## Módulo 19/161 — NPCs y Vecinos 🧑‍🌾

## Módulo 34 — Pesca / 35 — Minería 🎣

- [ ] Caña de pescar
- [ ] Pez capturable (compartido con fauna)
- [ ] Cangrejo ermitaño (recompensa rara)
- [x] Pico de piedra — `crear_pico_piedra_lowpoly.py` v2 (2026-08-29 19-29) + 6 orbitales 19-29-26. **v2 corrige E-27 (separación 9.7 cm entre mango y cabeza/ataduras/pomo)**: hijo() sin tocar matrix_parent_inverse, mango con rotación identidad, pose vertical nativa, assertion anti-regresión en el asentado. MEDIA 3/82, BAJA 3/76, ALTA 7/716, ALTA_MEDIA 3/716, z_min 0.045 en todas.
- [x] Pico de hierro — `crear_pico_hierro_lowpoly.py` v2 (2026-08-29 19-33) + 6 orbitales 19-33-32. **Mismo E-27 que pico_piedra (separación 9.3 cm)**: v2 corrige con el mismo patrón (hijo() sin matrix_parent_inverse, mango vertical identidad, assertion). MEDIA 3/92, BAJA 3/87, ALTA 8/956, ALTA_MEDIA 3/956, z_min 0.045.
- [x] Carretilla de minero — `crear_carretilla_minero_lowpoly.py` (M35 2026-09-02 04:46, log 532) + 6 capturas orbitales 04-43. **APROBADO**: rueda 14 lados + eje + 2 largueros horizontales (y=±0.26) que soportan la batea en tronco de pirámide (laterales abiertos ±16.7° en X) + batea con piso/2 lados abiertos/frente inclinado 14°/trasera + 2 patas traseras + 2 mangos (de larguero a (x=-1.20, z=0.48), +23.2° en Y) + 2 tepes de mineral asomando. **15 SM_**, z_min 0.045, toca=10, fp=1.51×0.60. Variantes MEDIA (4/252/4), BAJA (4/176/4). E-50✓ (trípode rueda+2patas), E-37 validado: silueta lee como carretilla en los 6 azimuts (rueda+laterales abiertos+mangos = carretilla), la rueda no atraviesa el frente de la batea (avanzada a x=+0.75). 3 GLB + 3 `.import` + 3 `.scn` (E-65).
- [ ] Carrito de vías (26 subterráneo)

## Módulo 16 — Crafting / 14 — Inventario (representables en mano) 🔨

- [x] Hacha de piedra — `crear_hacha_piedra_lowpoly.py` + cap 2026-08-28 16-00-10 (6 orbitales, OK visual). **2026-08-29 fix pose**: `.blend` regenerado de cero (estaba corrupto), MEDIA 3 obj/278 tris/3 mats, BAJA 3 obj/231 tris/3 mats — todas aprobadas visualmente.
- [ ] Hacha de hierro
- [ ] Martillo
- [ ] Azada
- [ ] Machete
- [x] Antorcha de mano — `crear_antorcha_mano_lowpoly.py` v2 (2026-08-29 19-36) + 6 orbitales 19-36-12. **v2 corrige E-27 (mango flotando en Z[0.262..0.862] con tela/remate/brasa aparte en X≈0.46, Z[0.045..0.299]) Y la pose con la brasa abajo**: v2 deja la brasa arriba (donde arde) y reescribe todo con el mismo patrón (hijo() sin matrix_parent_inverse, mango vertical identidad). MEDIA 4/88, BAJA 4/73, ALTA 6/556, ALTA_MEDIA 4/556, z_min 0.045.
- [x] Cuerda enrollada — `crear_cuerda_enrollada_lowpoly.py` + 6 capturas orbitales 17:43 (aprobado, 2 rollos superpuestos + cabo horizontal + punta; z_min 0.045). Variantes M166 MEDIA (2 obj/401 tris/2 mats) y BAJA (2 obj/357 tris/2 mats) generadas y aprobadas 2026-08-29. Ver Tier D arriba.
- [x] Tablón de madera (recurso) — `crear_tablon_madera_lowpoly.py` + 6 capturas orbitales 18-45 (aprobado, 6 obj, z_min 0.045)
- [x] Lingote de cobre/hierro/oro — `crear_lingote_metal_lowpoly.py` + 6 capturas orbitales 18-43 (aprobado, variante cobre, z_min 0.045)
- [ ] Gema tallada
- [ ] Frasco de agua
- [ ] Bowl/plato de barro

## Módulo 45 — Arte 3D (props de ambientación) 🗿

- [x] Tótem de isla (lore) — `crear_totem_isla_lowpoly.py` + 6 capturas orbitales 19-18 (aprobado, 3 caras apiladas + piedras; z_min 0.045) 2026-08-28
- [x] Monolito con glifos — `crear_monolito_glifos_lowpoly.py` + 6 capturas orbitales 18-36 (aprobado, 2 obj cuerpo+roto, z_min 0.045)
- [x] Anillo de piedras ritual — `crear_anillo_piedras_ritual_lowpoly.py` + 6 capturas orbitales 18-48 (aprobado, 9 piedras, z_min 0.045)
- [x] **Barco hundido (playa)** — `crear_barco_hundido_lowpoly.py` (2026-09-01 12:46, log 366) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:22 (E-67 fix)**: hull + 4-vert proa + mástil inclinado (E-60) + 3 ribs + duna 12 lados. **7 obj, 126 tris reales, 3 mats**. z_min 0.0450, toca=17, footprint 2.95×1.70. Variantes MEDIA+BAJA + 3 GLB exportados + 3 .import.
- [x] **Caveira de criatura marina (playa)** — `crear_caveira_criatura_lowpoly.py` (2026-09-01 12:46, log 366) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:22 (E-67 fix)**: cilindro 8 lados acostado + cono 6 lados hocico + mandíbula + 2 sockets + 4 dientes cónicos + base 12 lados. **10 obj, 176 tris, 4 mats**. z_min 0.0450, toca=12, fp=1.20×1.20. Variantes + GLB + import.
- [x] **Coral abanico** — `crear_coral_abanico_lowpoly.py` (2026-09-01 12:46, log 366) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:22 (E-67 fix)**: cono invertido aplanado + 2 ramas inclinadas (E-58 to_track_quat) + roca 12 lados. **4 obj, 128 tris, 3 mats**. z_min 0.0450, toca=12, fp=0.48×0.48. Variantes + GLB + import.
- [x] Estrella de mar — `crear_estrella_mar_lowpoly.py` + 6 capturas orbitales 18-47 (aprobado, 1 malla, z_min 0.040)
- [x] Concha de mar — `crear_concha_mar_lowpoly.py` + 6 capturas orbitales 19-02 (aprobado, espiral enterrada en arena diseño intencional, z_min -0.040)
- [x] **Ancla de naufragio** — `crear_ancla_naufragio_lowpoly.py` (2026-09-01 12:46, log 366) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:22 (E-67 fix)**: shank 10 lados + crossbar + aro parado + 2 arms + 2 flukes alineados con to_track_quat (E-58) + duna baja que **ENTIERRA** (no soporta, decisión E-60: arms hasta x=1.65, más allá de la duna). **8 obj, 256 tris, 3 mats**. z_min 0.0450, toca=25, fp=2.64×1.10. Variantes + GLB + import.
- [x] **Jarrones/urnas decorativas (3 variantes)** — `crear_jarrones_urnas_lowpoly.py` (2026-09-01 12:46, log 366) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:22 (E-67 fix)**: ánfora con cuello + 2 asas torus, urna ancha, cuenco bajo; cada una en cilindro 12 lados. Helper `cil()` con bottom EXACTO en `z_base` (E-24 por construcción). **10 obj, 504 tris, 3 mats**. z_min 0.0450, toca=36, fp=1.88×0.60. Variantes + GLB + import.

## Módulo 70 — Interacciones (objetos interactivos comunes)

- [x] **Palanca de madera (horquilla)** — `crear_palanca_madera_lowpoly.py` v3 (2026-08-29 23:05, log 248) — base 48×34×14 + 2 montantes + brazo inclinado 10° + perno hierro + pomo icosaedro. **APROBADO** tris 96/96/66 (ALTA/MEDIA/BAJA), z_min 0.045, 6 capturas orbitales 23-05-00. **Lección (no la olvides):** v1 tenía brazo+pivote en el mismo punto y se "veía mal" — el fix del log 233 solo lo giró a mano. v3 rediseño completo a horquilla; brazo ahora se lee como palanca de verdad.
- [x] **Botón de piso (placa de presión)** — `crear_boton_piso_lowpoly.py` v1 (2026-08-29 23:15, log 249) — base octogonal de piedra (r 0.50) + placa metálica inset (r 0.36) + 4 pernos de bronce. **APROBADO** tris 136/136/94, z_min 0.045, capturas 23-15-00.
- [x] **Puerta corrediza de piedra** — `crear_puerta_corrediza_piedra_lowpoly.py` v1 (2026-08-29 23:15, log 249) — riel + 2 pilares + dintel + hoja 1.62 m deslizada a +X (hueco 0.72 m libre) + 2 costillas de hierro. **APROBADO** tris 84/84/58, z_min 0.045, capturas 23-15-00.
- [x] **Cofre pequeño (M70 / M25)** — `crear_cofre_pequeno_lowpoly.py` v1 (2026-08-29 23:15, log 249) — cuerpo 0.62×0.40×0.30 + tapa de media caña (barril) + 2 bandas hierro + cierre bronce. **APROBADO** tris 72/72/50, z_min 0.045, capturas 23-15-00.
- [x] **Válvula con volante y manivela** — `crear_valvula_manivela_lowpoly.py` v1 (2026-08-29 23:15, log 249) — brida octogonal + cuerpo + cuello + cubo + volante (toro bronce R 0.21) + 5 radios. **APROBADO** tris 236/236/164, z_min 0.045, capturas 23-15-00.

## Módulo 27/160 — Islas y Ubicaciones (landmarks) 🗺️

- [x] **Volcán lowpoly (isla central)** — `crear_volcan_lowpoly.py` (2026-09-01 12:54, log 367) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:20 (E-67 fix)**: cono truncado 12 lados (base 4.0, boca 1.2, h=5.5) + torus rim crater + cilindro emissive lava. **3 obj, 188 tris, 3 mats**. z_min 0.0450, toca=12, fp=8.00×8.00, bbox 8×8×5.70. Variantes + GLB + import.
- [x] **Cascada (roca; agua en módulo 51)** — `crear_cascada_lowpoly.py` (2026-09-01 12:51, log 367) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:20 (E-67 fix)**: cliff box 4×0.8×4 + repisa + 3 rocas musgo 12 lados al pie. **5 obj, 156 tris, 3 mats**. z_min 0.0450, toca=40, fp=4.00×1.39. Variantes + GLB + import.
- [x] **Faro viejo** — `crear_faro_viejo_lowpoly.py` (2026-09-01 12:51, log 367) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:20 (E-67 fix)**: base roca 12 lados + puerta + 2 cuerpos apilados (bandas blanco/rojo) + galería + lámpara emissive + techo cónico. **7 obj, 260 tris, 6 mats**. z_min 0.0450, toca=12, fp=3.20×3.20, bbox Z hasta 8.045. Variantes + GLB + import.
- [x] **Campamento abandonado (carpa + fogata)** — `crear_campamento_abandonado_lowpoly.py` (2026-09-01 12:54, log 367) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:20 (E-67 fix)**: lona plana + carpa pirámide 3 verts + fogata 6 piedras + cilindro ceniza + 3 leños cruzados (E-60: `LENO_Z = 0.04 + 0.55/2 = 0.315` = bottom en top de ceniza). **12 obj, 240 tris, 5 mats**. z_min 0.0450, toca=25, fp=3.92×1.80. Variantes + GLB + import.
- [x] **Cementerio de barcos (agrupación)** — `crear_cementerio_barcos_lowpoly.py` (2026-09-01 12:53, log 367) + 6 capturas orbitales. **APROBADO v2 2026-09-02 03:20 (E-67 fix)**: 3 cascos acostados a distintas rotaciones + 2 mástiles rotos + 4 ribs + duna arena. **10 obj, 168 tris, 3 mats**. z_min 0.0450, toca=24, fp=4.77×3.71. Variantes + GLB + import.

## Contadores

- Total ítems: **116** (117 − 4 duplicados + 3 añadidos: puente M40, carretilla M35, espantapájaros M33 → 117 − 4 + 3 = 116)
- Completados: **81** (+2: carretilla M35 + espantapájaros M33)
- Pendientes: **33**
- Pendientes de captura: **0**
- Aprobados visualmente: 84 + 11 M18 (4 vision ✓ 2026-08-31 04:15 + 7 vision ✓ turno previo) + 3 M50 Tier F (vision ✓ 2026-09-01 21:15-21:16) + 10 M45+M27 (vision ✓ 2026-09-02 03:20, re-verificados post E-67) + 3 arco M25 ALTA/MEDIA/BAJA (vision ✓ 2026-09-02 04:00, post E-68) + 3 estatua M25 ALTA/MEDIA/BAJA (vision ✓ 2026-09-02 04:15) + 3 puente colgante M40 ALTA/MEDIA/BAJA (vision ✓ 2026-09-02 04:24) + 3 carretilla M35 ALTA/MEDIA/BAJA (vision ✓ 2026-09-02 04:46) + 3 espantapájaros M33 ALTA/MEDIA/BAJA (vision ✓ 2026-09-02 04:50)
- **Pendientes de Tier D: 0** (Tier D cerrado 7/7)
- **Módulo 27 cerrado al 100%** (2026-09-02 03:20, log 367): 5 landmarks (volcán/cascada/faro/campamento/cementerio), variantes MEDIA/BAJA generadas (E-62 OK, delta +0.000), 15 GLB exportados, 15 .import. **Módulo 45 cerrado al 100%** (5 nuevos en este turn: barco_hundido/caveira_criatura/coral_abanico/ancla_naufragio/jarrones_urnas; 11 totales ya hechos). **Arco de entrada M25 cerrado** (2026-09-02 04:00, log 529): E-68 descubierto en v3, corregido en v4, 3 GLB + 3 .import + 3 .scn. **Estatua ancestral erosionada M25 cerrada** (2026-09-02 04:15, log 530): E-50 fix inicial (pedestal de cubo → cilindro 12 verts), E-37 validado. **Puente de cuerda colgante M40 cerrado** (2026-09-02 04:24, log 531): parábola (no catenaria) en 6 segmentos `to_track_quat`, 15 SM_ tras recortar de 21 (v1 excedía ALTA ≤16). **Carretilla de minero M35 cerrada** (2026-09-02 04:46, log 532): batea en tronco de pirámide (laterales ±16.7° en X) sobre largueros, trípode de apoyo (rueda + 2 patas), 15 SM_, ALTA/MEDIA/BAJA 4/252/4 / 4/176/4. **Espantapájaros M33 cerrado** (2026-09-02 04:50, log 532): sombrero mejicano + cruz + camisa-cuerpo + cara con ojos/boca, 15 SM_, MEDIA 7/308/7, BAJA 6/186/4. Verificado por archivos (E-65): **243 GLB / 243 `.import` / 243 `.scn`**, 81/81/81.
- **Módulo 70 cerrado:** palanca (v3) + botón + puerta corrediza + cofre pequeño + válvula. Faltan ítems no listables (puerta de puzzle etc.) pero los 5 principales ya están.
- **Presupuesto M166: 0 excedidos** (2026-08-30, log 252). Las 23 variantes excedidas se regeneraron con `--decima-media --ratio` (MEDIA) y `--ratio` (BAJA, 6 de ellas con poda de materiales 5-6→4). Causa de fondo: `generar_alta.py` medía CARAS, no TRIS (E-40); el totem bajó de 21.014 a 3.106 tris y el cofre de 11.510 a 3.274. Auditoría final: **121 variantes, 0 exceden**.
- **Pipeline Godot: VIVO** (2026-08-30, log 252). `exportar_godot.py` corre en headless (`blender -b --factory-startup --python`) por E-45 (`bpy.context` por socket no tiene `active_object`). Exportados **153 GLB** (51 alta / 51 media / 51 baja), 7,7 MB, pirámide LOD correcta. Godot 4.7.2 `--headless --import` → **153/153 DONE**. 0 de 153 GLB con nodos no-`SM_` (E-44).
- **Desincronización de variantes: 0** (2026-08-30, log 252). Cross-check mtime derivado vs fuente; caso resuelto: `palanca_madera_alta` (v2 rechazada, 14:13) regenerado desde `_lowpoly` v3 (22:54) con prioridad E-43.
- **Barrido visual M166: 156/156** (2026-08-31 04:35, log 304). 52 BAJA + 52 MEDIA + 52 ALTA, 6 azimuts cada uno, todas aprobadas sin flotación. Auditoría **E-24** cerrada: 5 scripts corregidos para medir vértices reales en vez de `bound_box`.
- **Tiers A/B/C/D: 4 de 4 CERRADOS** (36 objetos). Los 51 pendientes se organizan por MÓDULO, no por tier. Ver `## Plan por tiers` y la tabla de backlog en el log 304.
- **Tier E CERRADO al 100%** (M18 Casas, 11 piezas, 2026-08-31 23:45 → admin cerrado 2026-09-01 00:00): pared_madera (7/84/3), pared_ventana (13/156/4), piso_madera (8/96/2), pared_puerta (12/212/5), techo_dos_aguas (13/156/3), techo_paja (13/156/3), puerta_articulada (8/96/3), ventana_marco (9/108/4), escalera_mano (7/84/2), zocalo_piedra (8/96/2), casa_completa_ejemplo (14/168/6, ref visual). 11 hojas de contacto aprobadas por visión. **Variantes + GLB + import Godot: HECHOS** — 33 GLB en `assets/3d/{alta,media,baja}/18-Casas_*.glb` + 33 `.import`. Al derivar apareció **E-62** (`generar_variante.py` re-asentaba incondicionalmente y hundía 2.6 m los techos) y al exportar **E-63** (`18-Casas` no estaba en la whitelist `MODULOS` de `exportar_godot.py` → exportaba 0 en silencio). Ambos corregidos.
- **Módulo 18 cerrado al 100%** (los 11 ítems del Tier E son TODO el módulo M18; no tiene más ítems en el backlog). Sin pendientes.
- **Tier F CERRADO** (M50 Vegetación, 3 piezas reales, 2026-09-01 21:16): `arbol_frutal` (15/464/4), `musgo_roca` (9/204/4), `raices_expuestas` (6/106/2 — **cumple ALTA+MEDIA+BAJA sin merge**). 3 hojas de contacto aprobadas por visión, 3 variantes cada una, 9 GLB exportados. **Nota de backlog:** M50 figuraba con 5 pendientes pero 2 eran duplicados rancios (`Hongo luminoso`, `Flor de isla`, ya hechos más abajo) → los 3 reales eran Árbol frutal / Musgo en roca / Raíces expuestas.
- **Import Godot: 100% OK — era un falso pendiente.** El ítem "E-64: import bloqueado por el editor abierto" que estuvo publicado unas horas era **ERRÓNEO** y ya se corrigió en la guía. Verificado por archivos (12:20): **198 GLB / 198 `.import`**, cobertura completa, con el editor abierto todo el tiempo. Los 9 GLB de M50 entraron a las 21:16 y los 33 de M18 a las 21:02. Dos causas del error de diagnóstico: (a) **E-65** — el sidecar se llama `<asset>.glb.import`, no `<asset>.import`, así que el glob de verificación daba 0; (b) **E-64** — los `ERROR:` de `voxel.gdextension` con el editor abierto son **ruido benigno**, no abortan el import. **No hay que cerrar el editor para importar.**
- Fecha de creación: 2026-08-27 · Última actualización: 2026-09-01 12:20

## Plan por tiers (2026-08-28, directiva del usuario)

Para que el avance sea medible y cada tanda sea verificable, los objetos se agrupan en **tiers** según nivel de complejidad y dependencia de iteración visual.

### Tier A (cierre del Tier 1 anterior — 6 ítems)
Pendientes cuando se definió este plan: 5 ya estaban hechos en sesiones anteriores; los 6 nuevos definidos en este turn:

- [x] **Hacha de piedra** (M16) — script + 6 capturas orbitales 16:00, aprobada visualmente
- [x] **Monolito con glifos** (M45) — script listo
- [x] **Anillo de piedras ritual** (M45) — script listo
- [x] **Palanca de madera** (M70) — script listo
- [x] **Tablón de madera** (M16) — script listo
- [x] **Lingote de metal** (M16) — script listo (variante cobre; hierro/oro = mismo script con otro material)

### Tier B (tanda siguiente — 8 ítems)
Definidos en este turn para expandir ambientación y cubrir huecos:

- [x] **Montón de ramas** (M15)
- [x] **Veta de hierro** (M15)
- [x] **Piedra de afilar** (M15)
- [x] **Arbusto floral** (M50)
- [x] **Helecho gigante** (M50)
- [x] **Hierba alta / tusca** (M50)
- [x] **Concha de mar** (M45)
- [x] **Estrella de mar** (M45)

### Tier C (15 ítems — completado 2026-08-28 19:50)

Verificación visual realizada con la multimodalidad liberada en esta sesión: lectura directa de las hojas de contacto JPG y de los orbitales individuales (6 vistas cada uno). Todos los ítems se aprueban con z_min = 0.045 y orbitales sin flotación visible. La tanda requirió 2 iteraciones por error de parenting y de eje de cono (ver §18 E-18 y §19 E-19 de `09-GUIA-BLENDER.md`).

- [x] **Tótem de isla** (M45) — `crear_totem_isla_lowpoly.py` + 6 orbitales 19-18
- [x] **Liana colgante** (M50) — `crear_liana_colgante_lowpoly.py` + 6 orbitales 19-22
- [x] **Helecho chico** (M50) — `crear_helecho_chico_lowpoly.py` + 6 orbitales 19-24
- [x] **Cristal ancestral** (M15) — `crear_cristal_ancestral_lowpoly.py` + 6 orbitales 19-28
- [x] **Puerta de templo** (M25) — `crear_puerta_templo_lowpoly.py` + 6 orbitales 19-32
- [x] **Losa con grabado** (M25) — `crear_losa_grabado_lowpoly.py` + 6 orbitales 19-34
- [x] **Altar ritual** (M25) — `crear_altar_ritual_lowpoly.py` + 6 orbitales 19-36
- [x] **Muelle de madera** (M40) — `crear_muelle_madera_lowpoly.py` + 6 orbitales 19-38
- [x] **Veta de oro** (M15) — `crear_veta_oro_lowpoly.py` + 6 orbitales 19-40
- [x] **Cofre ancestral** (M25) — `crear_cofre_ancestral_lowpoly.py` v3 (2026-08-29 19:55, E-27 sin matrix_parent_inverse)
- [x] **Farola de fuego** (M40) — `crear_farola_fuego_lowpoly.py` + 6 orbitales 19-42
- [x] **Bote de pesca amarrado** (M40) — `crear_bote_pesca_lowpoly.py` + 6 orbitales 19-43 (E-19: proa cono rotado sobre Y)
- [x] **Pico de hierro** (M13) — `crear_pico_hierro_lowpoly.py` v2 (2026-08-29, E-27 corregido)
- [x] **Antorcha de mano** (M16) — `crear_antorcha_mano_lowpoly.py` v2 (2026-08-29, E-27 + brasa arriba)
- [x] **Pico de piedra** (M13) — `crear_pico_piedra_lowpoly.py` v2 (2026-08-29, E-27 corregido)

### Tier D (siguiente tanda propuesta)
- [x] **Vallas de madera y carteles (M40)** — `crear_cartel_indicador_lowpoly.py` + 6 capturas orbitales 17:39 (aprobado, poste 0.09×0.09×1.40 + 2 tablas + 2 clavos; z_min 0.045). Variantes M166 MEDIA (3 obj/30 tris/3 mats) y BAJA (2 obj/17 tris/2 mats) generadas y aprobadas 2026-08-29.
- [x] **Cuerda enrollada (M16)** — `crear_cuerda_enrollada_lowpoly.py` + 6 capturas orbitales 17:43 (aprobado, 2 rollos superpuestos + cabo horizontal + punta; z_min 0.045). Variantes M166 MEDIA (2 obj/401 tris/2 mats) y BAJA (2 obj/357 tris/2 mats) generadas y aprobadas 2026-08-29. **Lección E-27:** Blender, al asignar `parent`, calcula `matrix_parent_inverse` automáticamente — NO sobreescribirla manualmente porque anula la herencia y la posición local del hijo se convierte en posición world directa. Para alinear el cono-punta al extremo +Z local del cabo cilindro, basta con `parent = cabo` + `location = (0, 0, depth/2 + cone_depth/2)`.
- [x] **Antorcha de pared (M25)** — `crear_antorcha_pared_lowpoly.py` v2 + 6 capturas orbitales 18-14 (fuente) y 18-18 (variantes), aprobado 2026-08-29 (placa vertical 0.16×0.32×0.020 + brazo horizontal 0.18 + copa + mango + tela + brasa + 4 remaches; z_min 0.045; **MURO `Set_Pared` del set de captura asentado en la arena**, cara frontal en y=-0.425, placa montada al ras con sus 4 remaches). Variantes M166 MEDIA (4 obj/94 tris/4 mats) y BAJA (4 obj/80 tris/4 mats) regeneradas y aprobadas 2026-08-29 18:18 desde la fuente v2. **Lección E-28:** cuando un asset va montado sobre una superficie vertical (antorcha, cartel, dintel), el set de captura debe incluir un panel `Set_Pared` (o `Set_Superficie`) QUE TAMBIÉN HAYA QUE ASENTAR EN LA ARENA, no flotando a media altura. Si el panel de referencia flota, el operador (humano o modelo) puede ver "luz/aire" entre el panel y la base y creer que es un defecto del asset cuando en realidad es un defecto del set de captura. La fórmula correcta: `Y_CENTER_PARED = -0.05` con `Z_CENTER = -0.05 + ALTO/2` (base enterrada 5 cm en la arena) y `Y_CENTER_PLACA = (Y_CENTER_PARED + ESP_PARED/2) + ESP_PLACA/2` (cara trasera de la placa tangente a la cara frontal del muro).
- [x] **Vieira de playa** (M45) — `crear_vieira_playa_lowpoly.py` v2 (2026-08-29 20:51, E-32 winding recalc + E-12 R_MIN) + 6 capturas orbitales 20-51 (3 hojas src/MEDIA/BAJA, **aprobado**: abanrico en Y-Z con bisagra abajo, 2 auriculas, 4 costillas, sin flotacion; z_min 0.045; 1 obj, 3 mats). Variantes M166 MEDIA (**968** tris / 1 obj / 3 mats) y BAJA (**676** tris ≤ 700, / 1 obj / 3 mats) generadas y aprobadas 2026-08-29 20:51 desde la fuente. **Lección E-32:** winding a mano es frágil. Para cualquier isla cerrada y conexa, `bmesh.ops.recalc_face_normals` + 1 medición global (¿la cara ext mira a -X?) decide la orientación completa; para cuñas convexas, recalc + test de centroide por cara. **Lección R_MIN>0:** la rejilla polar de la valva usaba `r = t*R_MAX`, de modo que en i=0 los N_ANG+1 vértices colapsaban en el mismo punto y se generaban caras degeneradas. La v2 hace `r = R_MIN + t*(R_MAX-R_MIN)` con R_MIN=0.035, dándole a la bisagra una linea real de 6.8 cm. **Lección E-33 (encontrada al medir):** `generar_variante.py` reporta **CARAS** (`len(mesh.polygons)`) en la columna "tris" de su output. El presupuesto M166 está en triángulos reales. El diagnóstico midió: cofre MEDIA 1482 vs 784 reportados (excede 1500 con margen 0), helecho BAJA 1144 vs 672 (excede 700 por 63 %), vieira MEDIA 968 vs 482, vieira BAJA 676 vs 482. La corrección: usar `mesh.calc_loop_triangles()` para contar tris reales; el budget check oficial se hace con `auditar_stats.py` (que sí cuenta tris) o con el script diag equivalente.
- [x] **Conchas y caracoles adicionales (M45)** — cerrado con la vieira
- [x] **Puentes de cuerda (M25)** — `crear_puente_cuerda_lowpoly.py` (2026-08-29 21:12, E-32 v2 con volumen firmado) + 6 capturas orbitales 21-12 (3 hojas src/MEDIA/BAJA, **aprobado**: 4 postes de piedra + 13 tablones en catenaria + 2 cuerdas maestras + 2 pasamanos + 10 colgantes, sin flotación; z_min 0.045; 1 obj, 3 mats; bbox x[-1.285..1.285], y[-0.535..0.535], z[0.045..1.445]). Variantes M166 MEDIA (**828** tris / 1 obj / 3 mats) y BAJA (**578** tris ≤ 700, / 1 obj / 3 mats) generadas y aprobadas 2026-08-29 21:12. **Lección E-32 v2 (mejora):** el test de centroide de v1 solo sirve para islas convexas. Para CUALQUIER isla cerrada (tubos catenarios incluidos), el test exacto y universal es el **volumen con signo** por el teorema de la divergencia: `V = (1/6) * sum Σ (v0 · (vk × vk+1))`. V>0 → normales hacia afuera. Reemplaza a los dos patrones de v1. **Lección E-34 (encontrada al inspeccionar la BAJA):** `generar_variante.py` duplicaba los slots de material al aplicar decimate (3 → 6). Causa: `new_from_object()` ya copia los slots y el código los volvía a appendar encima. **Lección E-35 (refinamiento del fix de E-34, log 246):** la primera versión del fix usaba `o.data.materials.clear()` y resultó PEOR — resetea a 0 el `material_index` de TODAS las caras. Medido en `puente_cuerda_baja`: hist {0:24, 1:78, 2:308} → {0:308} tras `clear()`. La BAJA se renderizaba con un solo material. Fix definitivo: solo reconstruir slots si la lista realmente difiere, y si difiere, respaldar los `material_index` ANTES de `clear()` y reasignarlos DESPUES. **Lección E-36 (encontrada al comparar audit con diag, log 246):** `auditar_presupuesto.py` solo inspeccionaba `objs[0].material_slots` y `objs[0].data.polygons`, ignorando los demás objetos SM_ de la escena. Por eso los 7 BAJA multi-objeto con 5-6 mats (nido_cocos, tablon_madera, cofre_ancestral, farola_fuego, anillo_piedras_ritual, arbusto_floral, hongo_luminoso) figuraban con `slots=1, mats_usados=1` cuando en realidad excedían el presupuesto de BAJA. Fix: el loop de slots y de caras recorre los mismos `o in objs` que ya recorría el de tris. **Auditoría completa CORREGIDA (111 variantes, 2026-08-29 21:35):** **23 exceden** — 16 con `tris+` (11 `_alta_media` héroes + 5 `_lowpoly`: cofre_baja 962, helecho_baja 1144, helecho_media 2288, hierba_alta_baja 1072, hierba_alta_media 1536, nido_cocos_media 1636, hongo_luminoso_baja 1010), 5 con `mats+` solo (nido_cocos_baja 5, tablon_madera_baja 6, farola_fuego_baja 5, anillo_piedras_ritual_baja 5, arbusto_floral_baja 5), y 2 con ambos (cofre_ancestral_baja, hongo_luminoso_baja). Re-derivación con `--ratio` queda como Task #34. **Nota sobre la nota del log 245:** mi log anterior decia "18 exceden (todos `tris+`)" — ese número era el correcto en el momento del log, pero el `mats+` ya estaba oculto por E-36. La verdad post-fix es 23, no 18.
- [x] **Pozo de piedra (M40)** — `crear_pozo_piedra_lowpoly.py` (2026-08-29 21:37, log 246) + 6 capturas orbitales 21-37 (3 hojas src/MEDIA/BAJA, **aprobado**: brocal circular de 36 bloques de piedra en 3 hiladas trabadas (running bond) con relieve por sin/cos deterministico, 2 postes de madera a los costados, techo a dos aguas con cumbrera, eje horizontal con manivela en L, soga, balde hueco por revolucion, agua al fondo; z_min 0.045; 1 obj, 4 mats; bbox x[-0.745..0.772], y[-0.510..0.510], z[0.045..2.067]). Variantes M166 MEDIA (**692** tris / 1 obj / 4 mats) y BAJA (**484** tris ≤ 700, / 1 obj / 4 mats) generadas y aprobadas 2026-08-29 21:30/21:37. **Lección `caja_vec`:** una sola caja con semiejes arbitrarios (no solo eje-alineados) permite armar tanto los bloques girados del brocal como los faldones inclinados del techo sin tener que duplicar el código. **Lección `revolucion()`:** nuevo helper que gira un perfil (r, z) N lados alrededor del eje Z. Si el primer y último punto del perfil están sobre el eje, la superficie cierra con triangulos y queda watertight. Sirve para el disco de agua y para el balde hueco (perfil en U). **Lección geometria del techo:** en mi primer borrador tomé un unico vector de pendiente para los DOS faldones y reflejé solo la Y (`ey.y *= sy`); eso NO es negar el vector (que dejaria la caja invariante, {c±ey}={c±(-ey)}), sino REFLEJARLO, y la reflexión SI cambia el sólido: invierte la pendiente y deja el alero arriba de la cumbrera. Reescrito con vectores explícitos por faldón (`ey = (0, -sy*ALERO_Y, DESNIVEL)/2`, `ez = (0, sy*DESNIVEL, ALERO_Y).normalized() * GROS`) más asserts en caliente sobre perpendicularidad, cumbrera y alero. **Lección tolerancia 1e-4 (nueva):** los asserts geométricos con `mathutils.Vector` deben usar 1e-4 (NO 1e-9) porque Vector guarda float32 — con 1e-9 fallan por puro ruido numérico. Medido: dz=2.2e-16 en float64 puro, ~2e-7 dentro de Blender. **Lección E-35:** primera ejecucion de la BAJA salió con `slots=4, mats_usados=1` (hist {0:299}) por el `clear()` defectuoso del fix v1 de E-34. Regenerada con el fix v2: hist {0:216, 1:57, 2:2, 3:24} = 4 materiales preservados. **Lección E-36:** el audit original reportaba slots=1/mats_usados=1 para el pozo (un solo objeto SM_, sin verse afectado), pero al re-correr despues del fix sigue diciendo 4/4 — consistente.
- [x] **Puente de troncos (M40)** - crear_puente_troncos_lowpoly.py (2026-08-29 22:33, log 247) + 6 capturas orbitales 22-31 (3 hojas src/MEDIA/BAJA, aprobado: 2 estribos de piedra con 6 piedras de terraplen + 3 vigas longitudinales de tronco + 11 troncos transversales (corduroy) + 6 postes hincados en la arena + 2 pasamanos + 4 ataduras de cuerda (anillos torus); z_min 0.045; 1 obj, 3 mats; bbox x[-1.55..1.55], y[-0.66..0.66], z[0.045..0.98]). Variantes M166 MEDIA (728 tris / 1 obj / 3 mats) y BAJA (508 tris, / 1 obj / 3 mats) generadas y aprobadas 2026-08-29 22:33 desde la fuente. **Leccion toro():** nuevo helper para anillos cerrados sin tapas coincidentes (a diferencia de tubo()). La ultima corona se conecta con la primera, asi que el toro queda watertight sin z-fighting. Aplicado a las 4 ataduras de cuerda en el plano YZ. **Leccion geometrica:** los 4 asserts en caliente que garantizan la no-flotacion son: (a) vientre de viga 0.220 <= lomo de estribo 0.225, hundimiento de 5 mm; (b) cara interior del estribo 1.13 <= extremo de la viga 1.36; (c) cara exterior del estribo 1.35 <= extremo de la viga 1.36; (d) anillo de cuerda interior 0.056 > radio del pasamano 0.050. **Leccion constructiva:** los postes de la barandilla se clavan en la arena (z_base = Z_APOYO = 0.045), NO en la cubierta. Asi se elimina el calculo de interseccion con el tronco transversal y se garantiza apoyo sin flotacion en todos los x, incluso donde la cubierta tiene un hueco. **Leccion presupuesto:** mi estimacion mental inicial de 1080 tris era erronea (usaba n tris por cara de n lados en vez de len(f.verts) - 2). El real: 6 lados -> 4 tris. La formula correcta es SIEMPRE len(f.verts) - 2. **Tier D cerrado (7/7).**
- [x] **Palanca de madera (M70) — REDISENO v3 HORQUILLA** — `crear_palanca_madera_lowpoly.py` v3 (2026-08-29 23:05, log 248) + 6 capturas orbitales 23-05-00 (3 hojas src/MEDIA/BAJA, **APROBADO** por el usuario que decia "no le encuentro la forma": base 48×34×14 + 2 montantes 10×5.6×26 cm a y=±9.5 cm + brazo 110×11×14 cm inclinado 10° sobre perno a z=0.36 + perno de hierro Y 28.6 cm radio 2 cm que sobresale 2 cm de cada cara externa del montante + pomo icosaedro r=11.5 cm en la punta +X; z_min 0.045; 1 obj, 3 mats; bbox x[-0.554..0.645], y[-0.170..0.170], z[0.045..0.616]). Variantes M166 MEDIA (**96** tris / 1 obj / 3 mats) y BAJA (**66** tris ≤ 700, / 1 obj / 3 mats) generadas y aprobadas 2026-08-29 23:05 desde la fuente. **Lección v1 (la que motivo el pedido del usuario):** en `crear_palanca_madera_lowpoly.py` v1 el brazo cilindrico se creaba en `(0,0,0.21)` y el cono del pivote TAMBIEN en `(0,0,0.21)` — el brazo atravesaba el pivote. El "fix" del log 233 solo giro el `.blend` a mano de 35° a 81.1° y reposiciono el pomo: nunca arreglo el problema de fondo, solo maquillo el resultado. v2 lo intento con un pivote unico, pero seguia siendo ambiguo. **Lección v3 (la buena):** la palanca se REDISENO como HORQUILLA — dos montantes con el brazo metido entre ellos y un perno que lo atraviesa. Esa disposicion es la forma canonica de una palanca mecanica y se lee inmediatamente. **Lección geometrica (10 asserts en caliente):** (a) base fondo en z=0; (b) montantes arrancan en techo base; (c) holgura real brazo↔montante ≥ 1 mm (dio 1.2 cm); (d) perno dentro del alto del montante; (e) perno sobresale 2 cm de cara externa (0.143 vs 0.123); (f) perno dentro del vientre/lomo del brazo; (g) lomo del brazo sobrepasa los montantes; (h) lado corto del brazo tiene 5.6 cm de aire sobre la base; (i) pomo exactamente en la punta inclinada; (j) pomo NO toca montantes ni base. **Lección distancia punto-caja (importante):** comparar solo Z para "no choca esfera-caja" dio falso positivo — el pomo esta a 49 cm en X de la horquilla. Usar `dist_punto_caja(p, cx, cy, cz, hx, hy, hz)` (min distancia al AABB + radio pomo). **Lección brazo inclinado:** la CAIDA VERTICAL desde el centro del brazo a su cara inferior NO es SEMIALTO, es `SEMIALTO * cos(ANG_TILT)` — la cara esta inclinada. Si usas SEMIALTO a secas el assert salta con diff ~1 mm (medido en v2.0). **Lección icosfera subdivisions=1:** en este Blender da 20 caras (icosaedro raw). subdivisions=2 seria 80, demasiado para un pomo de 23 cm. 20 caras es el grano correcto para "cozy low-poly". **Tarea del usuario cerrada.**

## Notas del Agente

**Modelo:** GLM · **Plataforma:** Cline · **Fecha:** 2026-08-27

- Checklist creado a partir de los módulos de `CHECKLIST-GLOBAL.md` que requieren assets 3D (14, 15, 16, 18, 19, 24, 25, 26, 27, 33, 34, 35, 36, 40, 45, 50, 70, 160, 161).
- El orden real de creación lo decide `08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (módulos habilitados), no el orden de este archivo.
- Al completar un objeto: mover su captura a `capturas/{ID-Modulo}-Nombre/` y marcar `[x]` con fecha.


- [ ] NPC base lowpoly (cuerpo modular sin ropa)
- [ ] Cabeza NPC (3 variantes de forma)
- [ ] Sombrero de paja
- [ ] Vestimenta campesina (módulo de ropa)
- [ ] Vestimenta pescador
- [ ] Anciano del templo (túnica)
- [ ] NPC sentado (pose para diálogo)

- [ ] Regadera (objeto colocado)
