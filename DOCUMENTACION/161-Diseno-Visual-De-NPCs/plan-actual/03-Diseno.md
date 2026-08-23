**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 161: Diseño Visual de NPCs

## 1. Paleta de Colores de Piel

| Tone ID | Nombre | HEX | Uso |
|---------|--------|-----|-----|
| SK-01 | Claro | #F5D6C4 | Piel clara |
| SK-02 | Medio | #D4A882 | Piel media |
| SK-03 | Bronceado | #C49A6C | Piel bronceada |
| SK-04 | Moreno | #8B6914 | Piel morena |
| SK-05 | Oscuro | #5C4033 | Piel oscura |

## 2. Paleta de Colores de Cabello

| Hair ID | Nombre | HEX |
|---------|--------|-----|
| HR-01 | Rubio | #F5DEB3 |
| HR-02 | Castaño Claro | #C4A882 |
| HR-03 | Castaño | #8B6914 |
| HR-04 | Pelirrojo | #B22222 |
| HR-05 | Negro | #2C2C2C |
| HR-06 | Canoso | #9E9E9E |
| HR-07 | Blanco | #F5F5DC |
| HR-08 | Pelirojo Claro | #CD853F |

## 3. Paleta de Colores de Ojos

| Eye ID | Nombre | HEX |
|--------|--------|-----|
| EY-01 | Marrón | #5C4033 |
| EY-02 | Verde | #228B22 |
| EY-03 | Azul | #5F9EA0 |
| EY-04 | Ámbar | #FFBF00 |
| EY-05 | Gris | #808080 |

---

## 4. ISLA RAÍZ (RIZ) — 8 NPCs

### 4.1 Mayor del Pueblo

**Rol:** Líder del pueblo, da misiones principales
**Piel:** SK-02 (Medio)
**Cabello:** HR-06 (Canoso), corto, peinado hacia atrás
**Ojos:** EY-01 (Marrón)
**Complexión:** Media, algo encorvado por la edad

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Gorro de alcalde, ala ancha | #2E5A4C (Azul Bosque) | Placa dorada al frente |
| Camisa | Larga, manga arremangada | #F5F0E8 (Blanco Perla) | Cuello abierto |
| Chaleco | Encima de camisa | #8B6914 (Madera Oscura) | Botones dorados |
| Pantalón | Largo, tejido grueso | #36454F (Gris Oscuro) | — |
| Botas | Altas, cuero | #5C4033 (Marrón) | Suelas gruesas |

**Herramienta en Mano:** Bastón de madera con punta dorada (OBJ-ART-005 Reliquia Luz como referencia)
**Accesorios:** Cadena con medalla dorada al cuello, reloj de bolsillo

---

### 4.2 Carpintero

**Rol:** Dueño de la carpintería, vende herramientas T1
**Piel:** SK-03 (Bronceado)
**Cabello:** HR-03 (Castaño), medio, desordenado
**Ojos:** EY-04 (Ámbar)
**Complexión:** Musculosa por el trabajo manual

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Fedora de paja | #F5DEB3 (Paja) | Ala ancha, cinta marrón |
| Camisa | Manga corta, tejido grueso | #C4A882 (Lino) | Arremangada |
| Delantal | Cuero, largo hasta rodillas | #A0522D (Cuero) | Bolsillos para herramientas |
| Pantalón | Largo, resistente | #8B6914 (Madera Oscura) | Manchas de aserrín |
| Botas | Altas, cuero grueso | #5C4033 (Marrón) | Sin cordones |

**Herramienta en Mano:** Hacha de madera (OBJ-HER-001 Hacha Madera T1)
**Accesorios:** Cinta métrica en cinturón, lápiz detrás de la oreja

---

### 4.3 Vendedora de la Tienda General

**Rol:** Dueña de la tienda, vende de todo
**Piel:** SK-01 (Clara)
**Cabello:** HR-02 (Castaño Claro), largo, recogido en moño
**Ojos:** EY-02 (Verde)
**Complexión:** Media, sonriente

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Bufanda ligera en la cabeza | #E2725B (Terracota) | Anudada atrás |
| Camisa | Básica, manga media | #FFFDD0 (Crema) | Limada |
| Mandil | Telado, corto | #FFFDD0 (Crema) | Bolsillo delantero |
| Falda | Hasta rodillas | #E2725B (Terracota) | Cómoda |
| Botas | Bajas, cuero suave | #C4A882 (Marrón Claro) | — |

**Herramienta en Mano:** Bolsa de tela con mercancía (mochila pequeña)
**Accesorios: | Collar de conchas, aretes pequeños

---

### 4.4 Viejo Sabio (Ermitaño)

**Rol:** NPC misterioso, da pistas sobre ruinas
**Piel:** SK-04 (Moreno)
**Cabello:** HR-07 (Blanco), largo, barba larga
**Ojos:** EY-03 (Azul)
**Complexión:** Delgada, algo encorvado

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Sombrero de ala ancha gastado | #36454F (Gris Oscuro) | Desgastado, agujeros |
| Túnica | Larga, tejido áspero | #36454F (Gris Oscuro) | Remendada |
| Cinturón | Cuero con semana | #A0522D (Cuero) | Con frascos |
| Pantalón | Largo, suelto | #9E9E9E (Gris) | — |
| Botas | Altas, cuero gastado | #5C4033 (Marrón) | Sucias |

**Herramienta en Mano:** Bastón de madera retorcida (decorativo, no M159)
**Accesorios:** Gafas redondas, mochila vieja con pergaminos, frascos en cinturón

---

### 4.5 Pescador del Puerto

**Rol:** Vende cebo y enseña a pescar
**Piel:** SK-03 (Bronceado)
**Cabello:** HR-05 (Negro), corto, greñas
**Ojos:** EY-01 (Marrón)
**Complexión:** Musculosa, bronceada

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Gorro de pescador | #87CEEB (Cielo) | Con red al cuello |
| Camisa | Rayas azul y blanco | #87CEEB + #FFFDD0 | Manga corta |
| Chaleco | Salvavidas acolchado | #FF8C00 (Naranja) | Flotador |
| Pantalón | Corto, tejido resistente | #FFFDD0 (Crema) | — |
| Botas | Botas de agua | #36454F (Gris Oscuro) | Largas, impermeables |

**Herramienta en Mano:** Caña de pescar (OBJ-HER-006 Caña Pescar T1)
**Accesorios:** Cinta en el cuello con anzuelos, cubo pequeño

---

### 4.6 Agricultora

**Rol:** Vende semillas, enseña cultivo
**Piel:** SK-02 (Medio)
**Cabello:** HR-08 (Pelirojo Claro), largo, trenza
**Ojos:** EY-02 (Verde)
**Complexión:** Media, fuerte

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Sombrero de paja con cinta | #F5DEB3 (Paja) + #FF69B4 (Rosa) | Flores decorativas |
| Camisa | Básica, manga corta | #FF69B4 (Rosa) | Estampado floral |
| Mandil | Largo, con bolsillos | #FFFDD0 (Crema) | Lleno de semillas |
| Pantalón | Largo, cómodo | #228B22 (Verde) | Manchas de tierra |
| Botas | Bajas, cuero | #A0522D (Cuero) | Para jardín |

**Herramienta en Mano:** Rastrillo de madera (OBJ-HER-004 Azada Madera T1)
**Accesorios:** Cesta de semillas en cadera, guantes de jardín

---

### 4.7 Niña del Pueblo (NPC niño)

**Rol:** NPC decorativo, da quests simples
**Piel:** SK-01 (Clara)
**Cabello:** HR-01 (Rubio), coletas
**Ojos:** EY-03 (Azul)
**Complexión:** Pequeña, delgada

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cinta | Lazo en el cabello | #FF69B4 (Rosa) | — |
| Camisa | Básica, manga corta | #87CEEB (Cielo) | Estampado de estrellas |
| Falda | Corta, plisada | #FFFDD0 (Crema) | — |
| Medias | Largas, rayadas | #FF69B4 + #FFFDD0 | Rosa y crema |
| Zapatillas | Blandas, tela | #FF69B4 (Rosa) | — |

**Herramienta en Mano:** Pelota de tela (decorativa)
**Accesorios:** Cinta en cabello, mochila pequeña de tela

---

### 4.8 Animador de la Plaza

**Rol:** Organiza eventos, anima festivales
**Piel:** SK-02 (Medio)
**Cabello:** HR-04 (Pelirrojo), crespo, grande
**Ojos:** EY-04 (Ámbar)
**Complexión:** Media, expresiva

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Sombrero de copa pequeño | #FFD700 (Dorado) | Con cinta roja |
| Camisa | Havana, manga larga | #FF4500 (Rojo Fuego) | Arremangada |
| Chaleco | Brilloso, negro | #2C2C2C | Botones dorados |
| Pantalón | Largo, tejido fino | #2C2C2C | — |
| Botas | Altas, cuero pulido | #5C4033 (Marrón) | Brillantes |

**Herramienta en Mano:** Cencerro pequeño decorativo
**Accesorios:** Pajarita roja, guantes blancos, campana en cinturón

---

## 5. ISLA CORAL (COR) — 5 NPCs

### 5.1 Herrero de Coral

**Rol:** Forja herramientas T2, enseña herrería básica
**Piel:** SK-04 (Moreno)
**Cabello:** HR-05 (Negro), rapado a los lados
**Ojos:** EY-01 (Marrón)
**Complexión:** Muy musculosa, brazos grandes

**Ropa:**
| Prenda | Estalo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cabeza | Pelada, sin sombrero | — | Cicatriz en frente |
| Camisa | Sin mangas, tejido grueso | #B87333 (Cobre) | Manchas de tinta |
| Delantal | Cuero pesado, largo | #36454F (Gris Oscuro) | Quemado parcialmente |
| Pantalón | Largo, resistente | #36454F (Gris Oscuro) | — |
| Botas | Altas, cuero reforzado | #2C2C2C (Negro) | Con placas metálicas |

**Herramienta en Mano:** Martillo de fragua (OBJ-TAL-002 Yunque como referencia)
**Accesorios:** Gafas de protección en la frente, cadenas de metal en cinturón

---

### 5.2 Pescadora de Coral

**Rol:** Vende pescado tropical, recetas de mar
**Piel:** SK-03 (Bronceado)
**Cabello:** HR-01 (Rubio), largo, ondulado
**Ojos:** EY-03 (Azul)
**Complexión:** Media, atlética

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Paja ancha, cinta azul | #F5DEB3 + #5F9EA0 | Concha decorativa |
| Camisa | Sin mangas, tejido ligero | #5F9EA0 (Agua) | Estampado de olas |
| Falda | Largo hasta tobillos | #FFFDD0 (Crema) | Cortable para nadar |
| Cinturón | Cuero con anzuelos | #A0522D | — |
| Sandalias | Tiras de cuero | #C4A882 | — |

**Herramienta en Mano:** Red de pesca pequeña
**Accesorios:** Collar de perlas, aretes de concha, pulsera de coral

---

### 5.3 Comerciante Viajero

**Rol:** Mercader ambulante, aparece en ferias
**Piel:** SK-02 (Medio)
**Cabello:** HR-02 (Castaño Claro), tapado por turbante
**Ojos:** EY-05 (Gris)
**Complexión:** Media, sigilosa

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Turbante | Enrollado, con pluma | #FFD700 + #FF4500 | Pluma roja |
| Camisa | Túnica fluida, manga amplia | #FFD700 (Dorado) | Bordados |
| Chaleco | Corto, abierto | #B87333 (Cobre) | Monedas cosidas |
| Pantalón | Bombachos, sueltos | #FFFDD0 (Crema) | — |
| Botas | Bajas, suaves | #A0522D (Cuero) | Silenciosas |

**Herramienta en Mano:** Bolsa de cuero con mercancía (OBJ-SEC-007 Cofre Antiguo como referencia)
**Accesorios:** Anillos en dedos, pulseras, cinturón con monedas

---

### 5.4 Guardia del Puerto

**Rol:** Vigila el puerto, tutorial de viajes
**Piel:** SK-04 (Moreno)
**Cabello:** HR-05 (Negro), corto, uniforme
**Ojos:** EY-01 (Marrón)
**Complexión:** Alta, musculosa

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Casco | Metalico, con visera | #71797E (Hierro) | Placa frontal |
| Camisa | Uniforme, manga larga | #191970 (Azul Profundo) | Botones plateados |
| Chaleco | Protección, cuero | #36454F (Gris Oscuro) | — |
| Pantalón | Largo, uniforme | #191970 (Azul Profundo) | — |
| Botas | Altas, cuero reforzado | #2C2C2C (Negro) | — |

**Herramienta en Mano:** Lanza de guardia (decorativa)
**Accesorios:** Silbato en cuello, guantes de cuero, cinturón con llaves

---

### 5.5 Niña de la Playa

**Rol:** NPC decorativo, recolecta conchas
**Piel:** SK-03 (Bronceado)
**Cabello:** HR-01 (Rubio), trenzas con conchas
**Ojos:** EY-03 (Azul)
**Complexión:** Pequeña, delgada

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Flor | Plumeros en el cabello | #FF69B4 + #FFD700 | Rosa y dorado |
| Camisa | Sin mangas, ligera | #87CEEB (Cielo) | Estampado de peces |
| Falda | Corta, tejido ligero | #FFFDD0 (Crema) | — |
| Pies | Descalza | — | — |

**Herramienta en Mano:** Cubo de arena pequeño
**Accesorios: | Flores en cabello, collar de caracoles

---

## 6. ISLA CENIZA (CEN) — 5 NPCs

### 6.1 Herrero Avanzado

**Rol:** Forja herramientas T3, experto en metales
**Piel:** SK-05 (Oscura)
**Cabello:** HR-05 (Negro), crespo, grande
**Ojos:** EY-01 (Marrón)
**Complexión:** Muy musculosa, cicatrices de fragua

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cabeza | Sin sombrero, gafas en frente | — | Gafas de soldador |
| Camisa | Sin mangas, tejido resistente | #36454F (Gris Oscuro) | Manchas de ceniza |
| Delantal | Cuero pesado, largo | #2C2C2C (Negro) | Quemado, placas metálicas |
| Pantalón | Largo, resistente | #2C2C2C (Negro) | — |
| Botas | Altas, cuero reforzado | #2C2C2C (Negro) | Con placas de hierro |

**Herramienta en Mano:** Martillo de forja pesado (OBJ-TAL-002 Yunque como referencia)
**Accesorios:** Cadena de metal en cinturón, brazaletes de hierro, cicatrices visibles

---

### 6.2 Minero

**Rol:** Trabaja en la mina, vende minerales
**Piel:** SK-04 (Moreno)
**Cabello:** HR-05 (Negro), corto, sucio
**Ojos:** EY-01 (Marrón)
**Complexión:** Musculosa, sucia de carbón

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Casco | Minero, con luz frontal | #71797E + #FFD700 | Linterna integrada |
| Camisa | Manga corta, tejido grueso | #A0522D (Tierra) | Manchas de carbón |
| Chaleco | Cuero con herramientas | #36454F (Gris Oscuro) | Bolsillos múltiples |
| Pantalón | Largo, resistente | #36454F (Gris Oscuro) | — |
| Botas | Altas, cuero reforzado | #2C2C2C (Negro) | Con placas |

**Herramienta en Mano:** Pico de minero (OBJ-HER-002 Pico Madera T1 como referencia)
**Accesorios:** Linterna en casco, cinturón con herramientas, guantes de cuero

---

### 6.3 Cocinera del Pueblo

**Rol:** Vende comida preparada, enseña recetas
**Piel:** SK-02 (Medio)
**Cabello:** HR-03 (Castaño), recogido bajo cofia
**Ojos:** EY-02 (Verde)
**Complexión:** Media, redonda, acogedora

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cofia | Tela blanca, cubre cabello | #FFFDD0 (Crema) | Limpia |
| Camisa | Blusa, manga larga | #FFFDD0 (Crema) | Arremangada |
| Delantal | Largo, tejido grueso | #E2725B (Terracota) | Manchas de comida |
| Falda | Largo hasta tobillos | #E2725B (Terracota) | — |
| Botas | Bajas, cuero suave | #C4A882 (Marrón Claro) | — |

**Herramienta en Mano:** Cuchara de madera grande
**Accesorios:** Delantal con bolsillos, pañuelo en cuello

---

### 6.4 Bibliotecario

**Rol:** Guarda libros, da lore del juego
**Piel:** SK-01 (Clara)
**Cabello:** HR-06 (Canoso), recogido en moño bajo
**Ojos:** EY-05 (Gris)
**Complexión:** Delgada, elegante

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cabeza | Sin sombrero, lentes | — | Redondos |
| Camisa | Blusa formal, manga larga | #FFFDD0 (Crema) | Impecable |
| Chaleco | Formal, tejido fino | #36454F (Gris Oscuro) | Botones |
| Falda | Largo hasta tobillos | #36454F (Gris Oscuro) | Plisada |
| Botas | Bajas, cuero pulido | #2C2C2C (Negro) | — |

**Herramienta en Mano:** Libro antiguo abierto
**Accesorios:** Lentes redondos, broche de plata en cuello, guantes de seda

---

### 6.5 Guardia de la Mina

**Rol:** Vigila la entrada a la mina
**Piel:** SK-04 (Moreno)
**Cabello:** HR-05 (Negro), corto, bajo casco
**Ojos:** EY-01 (Marrón)
**Complexión:** Alta, musculosa

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Casco | Minero reforzado | #71797E + #FFD700 | Con visera |
| Camisa | Uniforme, manga larga | #36454F (Gris Oscuro) | — |
| Chaleco | Protección metálica | #71797E (Hierro) | Placas |
| Pantalón | Largo, uniforme | #36454F (Gris Oscuro) | — |
| Botas | Altas, cuero reforzado | #2C2C2C (Negro) | — |

**Herramienta en Mano:** Lanza de guardia (decorativa)
**Accesorios:** Silbato, guantes de cuero, linterna en cinturón

---

## 7. ISLA AURORA (AUR) — 5 NPCs

### 7.1 Encantador

**Rol:** Encanta herramientas T4, experto en magia
**Piel:** SK-01 (Clara)
**Cabello:** HR-07 (Blanco), largo, flotante
**Ojos:** EY-03 (Azul), brillantes
**Complexión:** Delgada, etérea

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Sombrero | Mágico, puntiagudo, ancho | #191970 (Azul Profundo) | Estrellas bordadas |
| Túnica | Larga, fluida | #191970 (Azul Profundo) | Constelaciones bordadas |
| Capa | Larga,forrada | #FFD700 (Dorado) | Forro plateado |
| Cinturón | Cuero con runas | #FFD700 (Dorado) | Brilla suavemente |
| Botas | Altas, cuero suave | #2C2C2C (Negro) | — |

**Herramienta en Mano:** Báculo de madera retorcida con cristal (OBJ-ART-005 Reliquia Luz como referencia)
**Accesorios:** Anillo con gema, collar de runas, guantes sin dedos

---

### 7.2 Sanadora del Pueblo

**Rol:** Cura enfermedades, vende pociones
**Piel:** SK-02 (Medio)
**Cabello:** HR-02 (Castaño Claro), largo, recogido
**Ojos:** EY-02 (Verde)
**Complexión:** Media, serena

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Cofia | Tela blanca con cruz verde | #FFFDD0 + #228B22 | — |
| Camisa | Blusa, manga larga | #FFFDD0 (Crema) | Limpia |
| Mandil | Largo, tejido suave | #228B22 (Verde) | Bolsillos para frascos |
| Falda | Largo hasta tobillos | #FFFDD0 (Crema) | — |
| Botas | Bajas, cuero suave | #C4A882 (Marrón Claro) | — |

**Herramienta en Mano:** Frasco de poción brillante
**Accesorios:** Collar con hierba seca, cinturón con frascos, pulsera de flores

---

### 7.3 Guardia Ancestral

**Rol:** Vigila los templos, protege al pueblo
**Piel:** SK-05 (Oscura)
**Cabello:** HR-05 (Negro), corto, rizado
**Ojos:** EY-01 (Marrón)
**Complexión:** Alta, muy musculosa

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Casco | Ancestral, con cuernos | #FFD700 + #36454F | Cuernos dorados |
| Camisa | Armadura ligera, escamas | #FFD700 (Dorado) | Escamas superpuestas |
| Capa | Corta, roja | #FF4500 (Rojo Fuego) | Borde dorado |
| Pantalón | Largo, tejido resistente | #36454F (Gris Oscuro) | — |
| Botas | Altas, armadura | #FFD700 + #36454F | Placas metálicas |

**Herramienta en Mano:** Lanza ancestral dorada
**Accesorios:** Brazaletes dorados, medalla en cuello, capa roja

---

### 7.4 Artista del Pueblo

**Rol:** Crea arte, vende cuadros y esculturas
**Piel:** SK-01 (Clara)
**Cabello:** HR-04 (Pelirrojo), crespo, grande
**Ojos:** EY-04 (Ámbar)
**Complexión:** Media, expresiva

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Beret | Tela, inclinado | #2C2C2C (Negro) | — |
| Camisa | Manga larga, tejido suelto | #FFFDD0 (Crema) | Manchas de pintura |
| Chaleco | Corto, abierto | #B87333 (Cobre) | Botones |
| Pantalón | Largo, tejido suelto | #FFFDD0 (Crema) | Manchas de pintura |
| Botas | Bajas, cuero suave | #A0522D (Cuero) | Manchas de pintura |

**Herramienta en Mano:** Paleta de pintor con colores
**Accesorios:** Pinceles en bolsillo, pañuelo al cuello, delantal de pintor

---

### 7.5 Viajero Misterioso

**Rol:** NPC secreto, aparece solo de noche
**Piel:** SK-04 (Moreno)
**Cabello:** HR-05 (Negro), largo, tapado
**Ojos:** EY-05 (Gris), misteriosos
**Complexión:** Media, encapuchada

**Ropa:**
| Prenda | Estilo | Color HEX | Notas |
|--------|--------|-----------|-------|
| Capucha | Tapa cara, oscura | #36454F (Gris Oscuro) | Sombra sobre cara |
| Túnica | Larga, fluida | #36454F (Gris Oscuro) | Tejido misterioso |
| Capa | Larga, negra | #2C2C2C (Negro) | Cubre todo |
| Cinturón | Cuero con runas | #A0522D (Cuero) | Brilla débilmente |
| Botas | Altas, silenciosas | #2C2C2C (Negro) | Sin sonido |

**Herramienta en Mano:** Farol antiguo con luz azul
**Accesorios:** Anillo con gema oscura, collar de huesos, guantes negros

---

## 8. Tabla Resumen Visual por Isla

### 8.1 Isla Raíz — Colores Predominantes

| NPC | Sombrero | Camisa | Pantalón | Botas | Herramienta |
|-----|----------|--------|----------|-------|-------------|
| Mayor | #2E5A4C | #F5F0E8 | #36454F | #5C4033 | Bastón |
| Carpintero | #F5DEB3 | #C4A882 | #8B6914 | #5C4033 | Hacha T1 |
| Vendedora | #E2725B | #FFFDD0 | — Falda #E2725B | #C4A882 | Bolsa |
| Viejo Sabio | #36454F | #36454F | #9E9E9E | #5C4033 | Bastón |
| Pescador | #87CEEB | #87CEEB | #FFFDD0 | #36454F | Caña T1 |
| Agricultora | #F5DEB3 | #FF69B4 | #228B22 | #A0522D | Rastrillo T1 |
| Niña | Cinta #FF69B4 | #87CEEB | #FFFDD0 | — Zapatillas #FF69B4 | Pelota |
| Animador | #FFD700 | #FF4500 | #2C2C2C | #5C4033 | Cencerro |

### 8.2 Isla Coral — Colores Predominantes

| NPC | Cabeza | Camisa | Pantalón | Botas | Herramienta |
|-----|--------|--------|----------|-------|-------------|
| Herrero | Pelada | #B87333 | #36454F | #2C2C2C | Martillo |
| Pescadora | #F5DEB3 | #5F9EA0 | #FFFDD0 | — Sandalias | Red |
| Viajero | #FFD700 Turbante | #FFD700 | #FFFDD0 | #A0522D | Bolsa |
| Guardia | #71797E Casco | #191970 | #191970 | #2C2C2C | Lanza |
| Niña Playa | Flores #FF69B4 | #87CEEB | #FFFDD0 | Descalza | Cubo |

### 8.3 Isla Ceniza — Colores Predominantes

| NPC | Cabeza | Camisa | Pantalón | Botas | Herramienta |
|-----|--------|--------|----------|-------|-------------|
| Herrero Adv. | Gafas #71797E | #36454F | #2C2C2C | #2C2C2C | Martillo |
| Minero | #71797E Casco | #A0522D | #36454F | #2C2C2C | Pico T1 |
| Cocinera | #FFFDD0 Cofia | #FFFDD0 | #E2725B | #C4A882 | Cuchara |
| Bibliotecario | Lentes | #FFFDD0 | #36454F | #2C2C2C | Libro |
| Guardia Mina | #71797E Casco | #36454F | #36454F | #2C2C2C | Lanza |

### 8.4 Isla Aurora — Colores Predominantes

| NPC | Cabeza | Camisa | Pantalón | Botas | Herramienta |
|-----|--------|--------|----------|-------|-------------|
| Encantador | #191970 Sombrero | #191970 | — Túnica | #2C2C2C | Báculo |
| Sanadora | #FFFDD0 Cofia | #FFFDD0 | — Falda #FFFDD0 | #C4A882 | Poción |
| Guardia Anc. | #FFD700 Casco | #FFD700 | #36454F | #FFD700 | Lanza Dorada |
| Artista | #2C2C2C Beret | #FFFDD0 | #FFFDD0 | #A0522D | Paleta |
| Viajero | #36454F Capucha | #36454F | — Túnica | #2C2C2C | Farol |

---

## 9. Reglas de Diseño Visual

### 9.1 Identificación por Profesión

| Profesión | Elemento Clave | Color Asociado |
|-----------|----------------|----------------|
| Carpintero | Delantal de cuero + hacha | #A0522D, #C4A882 |
| Herrero | Delantal quemado + martillo | #36454F, #B87333 |
| Pescador | Sombrero de red + caña | #87CEEB, #5F9EA0 |
| Agricultor | Sombrero de paja + rastrillo | #F5DEB3, #228B22 |
| Comerciante | Bolsa de cuero + monedas | #FFD700, #B87333 |
| Encantador | Sombrero puntiagudo + báculo | #191970, #FFD700 |
| Sanador | Cofia blanca + frascos | #FFFDD0, #228B22 |
| Guardia | Casco + lanza | #71797E, #FFD700 |
| Cocinero | Cofia + cuchara | #FFFDD0, #E2725B |
| Artista | Beret + paleta | #2C2C2C, #B87333 |

### 9.2 Colores por Isla

| Isla | Colores Predominantes | Atmósfera |
|------|----------------------|-----------|
| Raíz | #C4A882, #8B6914, #F5DEB3 | Cálida, rústica, natural |
| Coral | #5F9EA0, #87CEEB, #B87333 | Tropical, acuática, brillante |
| Ceniza | #36454F, #71797E, #A0522D | Oscura, industrial, minerales |
| Aurora | #191970, #FFD700, #FF4500 | Mágica, etérea, ancestral |

### 9.3 Proporciones NPC

| Tipo | Altura | Ancho | Notas |
|------|--------|-------|-------|
| Adulto | 1.8 | 0.6 | Proporción estándar |
| Niño | 1.2 | 0.4 | 2/3 del adulto |
| Anciano | 1.7 | 0.55 | Ligeramente encorvado |
| Guardia | 1.9 | 0.7 | Más ancho por armadura |
| Encantador | 1.8 | 0.5 | Delgado, etéreo |

### 9.4 Variantes Estacionales

Cada NPC puede tener variantes de ropa por estación:

| Estación | Cambios Típicos |
|----------|-----------------|
| Primavera | Colores claros, mangas cortas, flores |
| Verano | Ropa ligera, sombreros grandes, sandalias |
| Otoño | Colores cálidos, mangas largas, capas |
| Invierno | Ropa gruesa, abrigos, bufandas, guantes |
