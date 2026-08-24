**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 160: Diseño de Ubicaciones del Mundo

## 1. Mapa Conceptual del Mundo

```
                    ┌─────────────────────┐
                    │    Isla Aurora (AUR) │
                    │  Encantamiento       │
                    │  Templos, Ruinas     │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │    Isla Ceniza (CEN) │
                    │  Herrería Avanzada   │
                    │  Montañas, Minas     │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │    Isla Coral (COR)  │
                    │  Herrería            │
                    │  Selva, Playa        │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │   Isla Raíz (RIZ)   │
                    │  Carpintería         │
                    │  Pueblo, Bosque      │
                    └─────────────────────┘
```

## 2. Isla Raíz (RIZ) — Detalle Completo (18 ubicaciones)

### 2.1 Mapa Conceptual

```
                        ┌──────────────────────┐
                        │   LOC-RIZ-MON-001    │
                        │ Monte de la Tribu    │
                        │ (Chamán del Monte)   │
                        └──────────┬───────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────┴────────┐    ┌───────────┴───────────┐    ┌────────┴────────┐
│ LOC-RIZ-BOS-003 │    │    LOC-RIZ-BOS-001    │    │ LOC-RIZ-RUI-001 │
│ Árbol Grande    │◄──►│    Bosque Principal   │◄──►│ Ruinas Antiguas │
└────────┬────────┘    └───────────┬───────────┘    └─────────────────┘
         │                         │
┌────────┴────────┐    ┌───────────┴───────────┐
│ LOC-RIZ-BOS-002 │    │    LOC-RIZ-PUB-001    │
│ Claros Bosque   │◄──►│    Plaza del Pueblo   │
└─────────────────┘    └───┬───┬───┬───┬───────┘
                           │   │   │   │
              ┌────────────┘   │   │   └────────────┐
              │                │   │                │
    ┌─────────┴──────┐  ┌─────┴───┴─────┐  ┌───────┴──────────┐
    │ LOC-RIZ-TAL-001│  │ LOC-RIZ-CASA  │  │ LOC-RIZ-TIE-001  │
    │ Carpintería    │  │ -001 Jugador  │  │ Tienda General   │
    └────────────────┘  └───────────────┘  └──────────────────┘
              │                                   │
    ┌─────────┴──────┐                  ┌─────────┴──────────┐
    │ LOC-RIZ-CASA   │                  │ LOC-RIZ-CASA-004   │
    │ -002 Luna      │                  │ Merc (Mercader)    │
    └────────────────┘                  └────────────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                             │
                          ┌─────────┴──────┐            ┌─────────┴──────┐
                          │ LOC-RIZ-PUER   │            │ LOC-RIZ-PLA    │
                          │ -001 Puerto    │◄──────────►│ -001 Playa     │
                          └────────────────┘            └───────┬────────┘
                                                              │
                                                    ┌─────────┴──────┐
                                                    │ LOC-RIZ-PLA    │
                                                    │ -002 Cueva     │
                                                    │ Playa          │
                                                    └───────┬────────┘
                                                            │
                                                    ┌───────┴────────┐
                                                    │ LOC-RIZ-CUE    │
                                                    │ -001 Tutorial  │
                                                    └────────────────┘
```

### 2.2 Todas las Ubicaciones (18)

#### LOC-RIZ-PUB-001 — Plaza del Pueblo

**Tipo:** Pueblo
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno (punto de inicio)
**Descripción:** Plaza central del pueblo con fuente, bancos y árboles. Punto de encuentro de NPCs.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-EXT-002 | Fuente | (0, 0, 0) | 0° | Centro de la plaza |
| 2 | OBJ-EXT-001 | Banco Jardín | (-2, 0, 1) | 0° | Lado norte |
| 3 | OBJ-EXT-001 | Banco Jardín | (2, 0, 1) | 0° | Lado este |
| 4 | OBJ-NAT-001 | Árbol Grande | (-3, 0, -2) | 0° | Esquina noroeste |
| 5 | OBJ-NAT-001 | Árbol Grande | (3, 0, -2) | 0° | Esquina noreste |
| 6 | OBJ-EXT-003 | Farol Jardín | (-1, 0, 2) | 0° | Iluminación |
| 7 | OBJ-EXT-003 | Farol Jardín | (1, 0, 2) | 0° | Iluminación |
| 8 | OBJ-EXT-010 | Paso Piedra | (0, 0, 3) | 0° | Camino a puerto |

**Objetos Decorativos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-015 | Flor Roja | (-1, 0, -1) | Jardín |
| 2 | OBJ-NAT-015 | Flor Azul | (1, 0, -1) | Jardín |
| 3 | OBJ-NAT-017 | Musgo | (-2, 0, 2) | Borde fuente |

**Conexiones:**
- Norte: LOC-RIZ-BOS-001 (Bosque Principal)
- Este: LOC-RIZ-PUER-001 (Puerto)
- Sur: LOC-RIZ-TIE-001 (Tienda General)
- Oeste: LOC-RIZ-TAL-001 (Carpintería)

---

#### LOC-RIZ-CASA-001 — Casa del Jugador

**Tipo:** Casa
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno (casa inicial)
**Descripción:** Choza básica de madera con 1 habitación (sala). Punto de spawn del jugador.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | 0° | Spawn point |
| 2 | OBJ-EST-001 | Estantería Baja | (0, 0, 0) | 0° | Almacenamiento |
| 3 | OBJ-COC-008 | Alacena | (4, 0, 0) | 0° | Cocina básica |
| 4 | OBJ-COC-001 | Mesón Cocina | (4, 0, 2) | 0° | Preparación comida |
| 5 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | 0° | Iluminación |
| 6 | OBJ-SIL-001 | Silla Básica | (3, 0, 1) | 0° | Sentarse |
| 7 | OBJ-MES-001 | Mesa Redonda | (3, 0, 2) | 0° | Comer |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormir | Descansar |
| 2 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | Encender/Apagar | — |
| 3 | OBJ-EST-001 | Estantería Baja | (0, 0, 0) | Abrir/Cerrar | Almacenamiento |

**Objetos Decorativos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-PLA-001 | Maceta Clásica | (0, 0, 3) | Decoración |
| 2 | OBJ-CUA-001 | Cuadro Paisaje | (2, 2, 0) | Pared norte |

**Conexiones:**
- Puerta: LOC-RIZ-PUB-001 (Plaza del Pueblo)

**Ampliable:** Sí (M18 — mejoras de casa)

---

#### LOC-RIZ-CASA-002 — Casa de Luna (Pintora)

**Tipo:** Casa NPC
**Isla:** Raíz
**Requisitos de Acceso:** Amistad ≥ 1 con Luna
**NPC Dueño:** Luna (M19)
**Descripción:** Choza colorida con cuadros en las paredes y un estudio con caballetes.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-ART-003 | Caballete | (0, 0, 0) | Estudio |
| 3 | OBJ-ART-005 | Lienzo en Blanco | (0, 1.5, 0) | En caballete |
| 4 | OBJ-ART-006 | Paleta de Pintura | (1, 0, 0) | Mesa |
| 5 | OBJ-EST-001 | Estantería Baja | (4, 0, 0) | Libros de arte |
| 6 | OBJ-CUA-002 | Cuadro Paisaje | (2, 2, 0) | Pared norte |
| 7 | OBJ-CUA-003 | Cuadro Retrato | (4, 2, 0) | Pared este |
| 8 | OBJ-PLA-001 | Maceta Clásica | (0, 0, 3) | Ventana |
| 9 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | Iluminación estudio |

**Conexiones:**
- Sur: LOC-RIZ-PUB-001 (Plaza del Pueblo)

---

#### LOC-RIZ-CASA-003 — Casa de Rocky (Herrero)

**Tipo:** Casa NPC
**Isla:** Raíz
**Requisitos de Acceso:** Amistad ≥ 1 con Rocky
**NPC Dueño:** Rocky (M19)
**Descripción:** Casa robusta de piedra y madera, con herramientas colgadas y un horno pequeño.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | Pared norte |
| 3 | OBJ-TAL-009 | Banco Herramientas | (2, 0, 0) | Trabajo |
| 4 | OBJ-EST-002 | Estantería Alta | (4, 0, 0) | Lingotes |
| 5 | OBJ-FUE-001 | Horno Pequeño | (0, 0, 2) | Fundición |
| 6 | OBJ-MES-002 | Mesa Rectangular | (3, 0, 1) | Comedor |
| 7 | OBJ-SIL-001 | Silla Básica | (3, 0, 2) | Sentarse |

**Conexiones:**
- Este: LOC-RIZ-PUB-001 (Plaza del Pueblo)

---

#### LOC-RIZ-MON-001 — Monte de la Tribu (Chamán)

**Tipo:** Monte
**Isla:** Raíz
**Requisitos de Acceso:** Amistad ≥ 3 con al menos 3 NPCs
**NPC Dueño:** Chamán del Monte (M163)
**Descripción:** Monte remoto con una cabaña de chamanes. Aquí se encantan herramientas con incienso.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-ART-004 | Estatuilla Ancestral | (0, 2, 0) | Centro ritual |
| 2 | OBJ-FUE-002 | Fogata Ritual | (2, 0, 1) | Incienso |
| 3 | OBJ-ART-011 | Calendario Piedra | (0, 3, 0) | Pared cabaña |
| 4 | OBJ-PLA-002 | Hierbas Raras | (-1, 0, 0) | Jardín chamán |
| 5 | OBJ-PLA-002 | Hierbas Raras | (1, 0, 0) | Jardín chamán |
| 6 | OBJ-NAT-014 | Roca Ancestral | (3, 0, -1) | Glifos |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-FUE-002 | Fogata Ritual | (2, 0, 1) | Encantar herramienta | M163 encantamientos |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (0, 2, 0) | Inspeccionar | Lore |

**Conexiones:**
- Sur: LOC-RIZ-BOS-001 (Bosque Principal)

---

#### LOC-RIZ-TIE-001 — Tienda General

**Tipo:** Tienda
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Comerciante General (M19)
**Horario:** 08:00 - 20:00, cerrado los domingos
**Descripción:** Tienda que vende semillas, herramientas básicas, comida y materiales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-EST-002 | Estantería Alta | (0, 0, 0) | 0° | Productos a la venta |
| 2 | OBJ-EST-002 | Estantería Alta | (2, 0, 0) | 0° | Productos a la venta |
| 3 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | 0° | Mostrador |
| 4 | OBJ-SIL-001 | Silla Básica | (1, 0, 3) | 180° | Para el comerciante |
| 5 | OBJ-COC-008 | Alacena | (4, 0, 0) | 0° | Almacenamiento stock |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-EST-002 | Estantería Alta | (0, 0, 0) | Comprar/Inspeccionar | Catálogo tienda |
| 2 | OBJ-EST-002 | Estantería Alta | (2, 0, 0) | Comprar/Inspeccionar | Catálogo tienda |
| 3 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | Vender |Mostrador venta |

**Conexiones:**
- Norte: LOC-RIZ-PUB-001 (Plaza del Pueblo)

---

#### LOC-RIZ-TAL-001 — Carpintería

**Tipo:** Taller
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Carpintero (M19)
**Horario:** 07:00 - 18:00, cerrado los domingos
**Descripción:** Taller de carpintería donde se fabrican herramientas T1 y se dan cursos básicos.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-TAL-001 | Mesa de Trabajo | (0, 0, 0) | 0° | Principal |
| 2 | OBJ-TAL-009 | Banco Herramientas | (2, 0, 0) | 0° | Almacenamiento |
| 3 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | 0° | Organización |
| 4 | OBJ-EST-002 | Estantería Alta | (4, 0, 0) | 0° | Materiales |
| 5 | OBJ-MES-002 | Mesa Rectangular | (2, 0, 2) | 0° | Ensamblaje |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-TAL-001 | Mesa de Trabajo | (0, 0, 0) | Fabricar | Crafting T1 |
| 2 | OBJ-TAL-009 | Banco Herramientas | (2, 0, 0) | Tomar herramientas | Prestar |

**Conexiones:**
- Este: LOC-RIZ-PUB-001 (Plaza del Pueblo)

---

#### LOC-RIZ-PUER-001 — Puerto

**Tipo:** Puerto
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Punto de embarque/desembarque. Conecta con otras islas vía barco (M28).

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-EXT-014 | Mesa Exterior | (0, 0, 0) | 0° | Consultar mapa |
| 2 | OBJ-EXT-003 | Farol Jardín | (-2, 0, 0) | 0° | Iluminación |
| 3 | OBJ-EXT-003 | Farol Jardín | (2, 0, 0) | 0° | Iluminación |
| 4 | OBJ-EXT-010 | Paso Piedra | (0, 0, 2) | 0° | Camino a muelle |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | — | Barco | (0, 0, -2) | Embarcar | M28 viajes |

**Conexiones:**
- Oeste: LOC-RIZ-PUB-001 (Plaza del Pueblo)
- Mar: Océano navegable a otras islas

---

#### LOC-RIZ-BOS-001 — Bosque Principal

**Tipo:** Bosque
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Bosque denso con árboles grandes, arbustos y flora多样性. Recursos de madera.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-NAT-001 | Árbol Grande | (0, 0, 0) | 0° | Centro |
| 2 | OBJ-NAT-002 | Árbol Mediano | (-3, 0, -2) | 0° | — |
| 3 | OBJ-NAT-003 | Árbol Pequeño | (2, 0, -3) | 0° | — |
| 4 | OBJ-NAT-006 | Sauce | (-1, 0, 3) | 0° | Cerca agua |
| 5 | OBJ-NAT-009 | Arbusto Redondo | (3, 0, 1) | 0° | — |
| 6 | OBJ-NAT-012 | Roca Grande | (-2, 0, 2) | 0° | — |
| 7 | OBJ-NAT-013 | Roca Mediana | (1, 0, -1) | 0° | — |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-001 | Árbol Grande | (0, 0, 0) | Madera | Tala |
| 2 | OBJ-NAT-009 | Arbusto Redondo | (3, 0, 1) | Bayas | Recoger |
| 3 | OBJ-NAT-015 | Flor Roja | (-1, 0, -1) | Flor | Recoger |
| 4 | OBJ-NAT-016 | Flor Azul | (2, 0, 2) | Flor | Recoger |

**Conexiones:**
- Sur: LOC-RIZ-PUB-001 (Plaza del Pueblo)
- Este: LOC-RIZ-BOS-002 (Claros del Bosque)

---

#### LOC-RIZ-BOS-002 — Claros del Bosque

**Tipo:** Bosque
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Zona abierta dentro del bosque con pasto alto y flores. Buen lugar para pescar.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-NAT-004 | Árbol Pequeño | (-2, 0, -2) | 0° | — |
| 2 | OBJ-NAT-010 | Arbusto Bajo | (3, 0, 0) | 0° | — |
| 3 | OBJ-NAT-018 | Hierba Alta | (0, 0, 1) | 0° | Zona pesca |
| 4 | OBJ-NAT-019 | Hierba Alta | (1, 0, 2) | 0° | Zona pesca |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-018 | Hierba Alta | (0, 0, 1) | Paja | Recoger |
| 2 | OBJ-NAT-020 | Musgo | (-1, 0, 0) | Musgo | Recoger |

**Conexiones:**
- Oeste: LOC-RIZ-BOS-001 (Bosque Principal)
- Norte: LOC-RIZ-BOS-003 (Árbol Grande)

---

#### LOC-RIZ-BOS-003 — Árbol Grande

**Tipo:** Bosque
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Ubicación del Árbol Grande ancestral. Punto de referencia visual importante.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-NAT-008 | Árbol Ancestral | (0, 0, 0) | 0° | Centro, enorme |
| 2 | OBJ-NAT-014 | Roca Ancestral | (2, 0, 1) | 0° | Glifos |
| 3 | OBJ-NAT-020 | Musgo | (-1, 0, 0) | 0° | Base del árbol |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-008 | Árbol Ancestral | (0, 0, 0) | Madera Ancestral | Solo con T3 |

**Conexiones:**
- Sur: LOC-RIZ-BOS-002 (Claros del Bosque)

---

#### LOC-RIZ-PLA-001 — Playa Principal

**Tipo:** Playa
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Playa de arena con vista al mar. Punto de pesca y relax.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-EXT-012 | Mesa Exterior | (0, 0, 0) | 0° | Sombrilla |
| 2 | OBJ-EXT-011 | Sombrilla | (0, 1, 0) | 0° | Sombra |
| 3 | OBJ-NAT-012 | Roca Grande | (3, 0, 1) | 0° | — |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-PLA-001 | Playa | (0, 0, 2) | Conchas | Recoger |
| 2 | OBJ-PLA-001 | Playa | (1, 0, 3) | Arena | Recoger |

**Conexiones:**
- Norte: LOC-RIZ-PUB-001 (Plaza del Pueblo)
- Este: LOC-RIZ-PLA-002 (Cueva de la Playa)

---

#### LOC-RIZ-PLA-002 — Cueva de la Playa

**Tipo:** Cueva
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno
**Descripción:** Pequeña cueva en la costa con conchas y caracoles.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | 0° | Entrada |
| 2 | OBJ-NAT-013 | Roca Mediana | (2, 0, 1) | 0° | Interior |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-023 | Concha | (1, 0, 0) | Concha | Recoger |
| 2 | OBJ-NAT-024 | Caracol | (2, 0, 0) | Caracol | Recoger |

**Conexiones:**
- Oeste: LOC-RIZ-PLA-001 (Playa Principal)

---

#### LOC-RIZ-CUE-001 — Cueva de Tutorial

**Tipo:** Cueva
**Isla:** Raíz
**Requisitos de Acceso:** Ninguno (tutorial)
**Descripción:** Cueva pequeña donde el jugador aprende a minar. Primer encuentro con minerales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | 0° | Entrada |
| 2 | OBJ-NAT-013 | Roca Mediana | (3, 0, 2) | 0° | Interior |
| 3 | OBJ-NAT-014 | Roca Ancestral | (1, 0, 3) | 0° | Tutorial |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-002 | Piedra | (2, 0, 1) | Piedra | Mina con T1 |
| 2 | OBJ-ITE-003 | Hierro | (3, 0, 0) | Hierro | Mina con T1 |
| 3 | OBJ-ITE-004 | Cobre | (1, 0, 2) | Cobre | Mina con T1 |

**Conexiones:**
- Sur: LOC-RIZ-PLA-001 (Playa Principal)

---

#### LOC-RIZ-RUI-001 — Ruinas Antiguas

**Tipo:** Ruinas
**Isla:** Raíz
**Requisitos de Acceso:** Herramienta T1 (para entrar)
**Descripción:** Ruinas de una civilización antigua. Puzzles básicos y lore.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Rotación | Notas |
|---|---------|--------|----------|----------|-------|
| 1 | OBJ-ART-001 | Glifo Humano | (0, 2, 0) | 0° | Pared |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | 0° | Pedestal |
| 3 | OBJ-ART-011 | Calendario Piedra | (4, 1, 0) | 0° | Pared |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-ART-001 | Glifo Humano | (0, 2, 0) | Inspeccionar | Lore |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | Recoger | Item puzzle |

**Conexiones:**
- Norte: LOC-RIZ-BOS-001 (Bosque Principal)

---

## 3. Isla Coral (COR) — Detalle Completo (15 ubicaciones)

### 3.1 Mapa Conceptual

```
                        ┌──────────────────────┐
                        │  LOC-COR-MON-001     │
                        │  Monte Vigía         │
                        └──────────┬───────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────┴────────┐    ┌───────────┴───────────┐    ┌────────┴────────┐
│ LOC-COR-SEL-001 │    │    LOC-COR-PUB-001    │    │ LOC-COR-PLA     │
│ Selva Tropical  │◄──►│    Plaza del Puerto   │◄──►│ -001 Playa Coral│
└────────┬────────┘    └───┬───┬───┬───────────┘    └────────┬────────┘
         │                 │   │   │                          │
┌────────┴────────┐  ┌─────┴───┴───┴─────┐          ┌───────┴────────┐
│ LOC-COR-SEL-002 │  │ LOC-COR-TIE-001   │          │ LOC-COR-PLA    │
│ Cataratas       │  │ Ferretería        │          │ -002 Arrecife  │
└─────────────────┘  └───────────────────┘          └───────┬────────┘
                                                          │
                                              ┌────────────┴────────────┐
                                              │                         │
                                    ┌─────────┴──────┐          ┌───────┴────────┐
                                    │ LOC-COR-CUE    │          │ LOC-COR-PUER   │
                                    │ -001 Cueva     │          │ -001 Puerto    │
                                    │ Coral          │          │ Tropical       │
                                    └────────────────┘          └────────────────┘
```

### 3.2 Ubicaciones (15)

#### LOC-COR-PUB-001 — Plaza del Puerto

**Tipo:** Pueblo
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Plaza costera con mercado al aire libre, puestos de frutas tropicales y vista al mar.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-002 | Fuente | (0, 0, 0) | Centro plaza |
| 2 | OBJ-EXT-001 | Banco Jardín | (-2, 0, 1) | Sombra |
| 3 | OBJ-EXT-003 | Farol Jardín | (2, 0, 1) | Iluminación |
| 4 | OBJ-EXT-014 | Mesa Exterior | (0, 0, -2) | Mercado |
| 5 | OBJ-NAT-006 | Sauce | (-3, 0, 0) | Cerca agua |

**Conexiones:**
- Norte: LOC-COR-MON-001 (Monte Vigía)
- Oeste: LOC-COR-SEL-001 (Selva Tropical)
- Este: LOC-COR-PLA-001 (Playa de Coral)
- Sur: LOC-COR-PUER-001 (Puerto Tropical)

---

#### LOC-COR-TIE-001 — Ferretería Tropical

**Tipo:** Tienda
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Nácar (M19)
**Horario:** 07:00 - 19:00, cerrado los domingos
**Descripción:** Ferretería que vende herramientas T2 de hierro y materiales de construcción.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-TAL-009 | Banco Herramientas | (0, 0, 0) | Herramientas T2 |
| 2 | OBJ-EST-002 | Estantería Alta | (2, 0, 0) | Materiales |
| 3 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | Mostrador |
| 4 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | Exhibición |

**Conexiones:**
- Norte: LOC-COR-PUB-001 (Plaza del Puerto)

---

#### LOC-COR-TIE-002 — Pescadería

**Tipo:** Tienda
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Concha (M19)
**Horario:** 06:00 - 18:00, cerrado los lunes
**Descripción:** Pescadería fresca con peces del día y cebos para pescar.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EST-003 | Hielera | (0, 0, 0) | Pescados frescos |
| 2 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | Mostrador |
| 3 | OBJ-COC-008 | Alacena | (3, 0, 0) | Cebos |

**Conexiones:**
- Norte: LOC-COR-PLA-001 (Playa de Coral)

---

#### LOC-COR-CASA-001 — Casa de Perla (Joyera)

**Tipo:** Casa NPC
**Isla:** Coral
**Requisitos de Acceso:** Amistad ≥ 1 con Perla
**NPC Dueño:** Perla (M19)
**Descripción:** Taller de joyería con vitrinas de gemas y collares terminados.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-TAL-002 | Mesa de Trabajo | (0, 0, 0) | Joyería |
| 3 | OBJ-EST-001 | Estantería Baja | (4, 0, 0) | Gemas |
| 4 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | Iluminación trabajo |
| 5 | OBJ-PLA-001 | Maceta Clásica | (0, 0, 3) | Decoración |

**Conexiones:**
- Norte: LOC-COR-PUB-001 (Plaza del Puerto)

---

#### LOC-COR-CASA-002 — Casa de Ola (Pescador Maestro)

**Tipo:** Casa NPC
**Isla:** Coral
**Requisitos de Acceso:** Amistad ≥ 1 con Ola
**NPC Dueño:** Ola (M19)
**Descripción:** Palafito con vista al mar, red de pesca colgada y baúl de tesoros.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-EXT-015 | Red de Pesca | (0, 2, 0) | Pared |
| 3 | OBJ-EST-001 | Estantería Baja | (4, 0, 0) | Conchas, perlas |
| 4 | OBJ-MES-002 | Mesa Rectangular | (3, 0, 1) | Comedor |
| 5 | OBJ-CAJ-001 | Baúl | (0, 0, 2) | Tesoros |

**Conexiones:**
- Sur: LOC-COR-PUER-001 (Puerto Tropical)

---

#### LOC-COR-PUER-001 — Puerto Tropical

**Tipo:** Puerto
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Puerto con barcos de pesca y madera de coco. Embarque a otras islas.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-014 | Mesa Exterior | (0, 0, 0) | Mapa de rutas |
| 2 | OBJ-EXT-003 | Farol Jardín | (-2, 0, 0) | Iluminación |
| 3 | OBJ-EXT-010 | Paso Piedra | (0, 0, 2) | Camino a muelle |

**Conexiones:**
- Norte: LOC-COR-PUB-001 (Plaza del Puerto)
- Mar: Océano navegable a otras islas

---

#### LOC-COR-SEL-001 — Selva Tropical

**Tipo:** Selva
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Selva densa con árboles exóticos, lianas y frutas tropicales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-001 | Árbol Grande | (0, 0, 0) | Centro |
| 2 | OBJ-NAT-002 | Árbol Mediano | (-3, 0, -2) | Tropical |
| 3 | OBJ-NAT-009 | Arbusto Redondo | (3, 0, 1) | Frutas |
| 4 | OBJ-NAT-012 | Roca Grande | (-2, 0, 2) | Sendero |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-009 | Arbusto Redondo | (3, 0, 1) | Coco, Naranja | Recoger |
| 2 | OBJ-NAT-015 | Flor Tropical | (-1, 0, -1) | Flor rara | Recoger |

**Conexiones:**
- Este: LOC-COR-PUB-001 (Plaza del Puerto)
- Norte: LOC-COR-SEL-002 (Cataratas)

---

#### LOC-COR-SEL-002 — Cataratas

**Tipo:** Selva
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Cataratas espectaculares con poza de pesca premium.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-021 | Cascada | (0, 3, 0) | Centro |
| 2 | OBJ-NAT-012 | Roca Grande | (2, 0, 1) | Orilla poza |
| 3 | OBJ-NAT-006 | Sauce | (-2, 0, 0) | Sombra |

**Conexiones:**
- Sur: LOC-COR-SEL-001 (Selva Tropical)

---

#### LOC-COR-PLA-001 — Playa de Coral

**Tipo:** Playa
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Playa de arena blanca con conchas de coral y vista al arrecife.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-011 | Sombrilla | (0, 1, 0) | Sombra |
| 2 | OBJ-EXT-012 | Mesa Exterior | (0, 0, 0) | Relax |
| 3 | OBJ-NAT-012 | Roca Grande | (3, 0, 1) | Decorativa |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-PLA-001 | Concha | (1, 0, 2) | Concha coral | Recoger |
| 2 | OBJ-PLA-001 | Coral | (2, 0, 3) | Coral | Recoger |

**Conexiones:**
- Oeste: LOC-COR-PUB-001 (Plaza del Puerto)
- Este: LOC-COR-PLA-002 (Arrecife)

---

#### LOC-COR-PLA-002 — Arrecife de Coral

**Tipo:** Playa
**Isla:** Coral
**Requisitos de Acceso:** Herramienta T2 (para buceo)
**Descripción:** Zona de buceo con arrecife colorido y peces tropicales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-022 | Coral Vivos | (0, 0, 0) | Arrecife |
| 2 | OBJ-NAT-023 | Conchas Grandes | (2, 0, 1) | Fondo marino |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-022 | Coral Vivos | (0, 0, 0) | Coral raro | Buceo |
| 2 | OBJ-NAT-023 | Conchas Grandes | (2, 0, 1) | Perla | Buceo |

**Conexiones:**
- Oeste: LOC-COR-PLA-001 (Playa de Coral)

---

#### LOC-COR-CUE-001 — Cueva del Coral

**Tipo:** Cueva
**Isla:** Coral
**Requisitos de Acceso:** Herramienta T2
**Descripción:** Cueva marina con cristales de coral bioluminiscente.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | Entrada |
| 2 | OBJ-ITE-006 | Cristal Coral | (2, 0, 1) | Bioluminiscente |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-006 | Cristal Coral | (2, 0, 1) | Cristal raro | Mina T2 |

**Conexiones:**
- Sur: LOC-COR-PLA-001 (Playa de Coral)

---

#### LOC-COR-MON-001 — Monte Vigía

**Tipo:** Montaña
**Isla:** Coral
**Requisitos de Acceso:** Ninguno
**Descripción:** Monte con vista panorámica de toda la isla. Punto de observación.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-014 | Mesa Exterior | (0, 3, 0) | Observación |
| 2 | OBJ-NAT-012 | Roca Grande | (2, 3, 1) | Mirador |

**Conexiones:**
- Sur: LOC-COR-PUB-001 (Plaza del Puerto)

---

## 4. Isla Ceniza (CEN) — Detalle Completo (14 ubicaciones)

### 4.1 Mapa Conceptual

```
                        ┌──────────────────────┐
                        │  LOC-CEN-MON-001     │
                        │ Montaña Principal    │
                        └──────────┬───────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────┴────────┐    ┌───────────┴───────────┐    ┌────────┴────────┐
│ LOC-CEN-BOS-001 │    │    LOC-CEN-PUB-001    │    │ LOC-CEN-RUI     │
│ Bosque Cenizas  │◄──►│    Plaza de la Forja  │◄──►│ -001 Ruinas     │
└────────┬────────┘    └───┬───┬───┬───────────┘    │ Forja           │
         │                 │   │   │                └─────────────────┘
┌────────┴────────┐  ┌─────┴───┴───┴─────┐
│ LOC-CEN-MON-002 │  │ LOC-CEN-TIE-001   │
│ Mina Abandonada │  │ Tienda Minerales  │
└─────────────────┘  └───────────────────┘
                                   │
                      ┌────────────┴────────────┐
                      │                         │
            ┌─────────┴──────┐          ┌───────┴────────┐
            │ LOC-CEN-CUE    │          │ LOC-CEN-PUER   │
            │ -001 Cueva     │          │ -001 Puerto    │
            │ Minerales      │          │ Minero         │
            └────────────────┘          └────────────────┘
```

### 4.2 Ubicaciones (14)

#### LOC-CEN-PUB-001 — Plaza de la Forja

**Tipo:** Pueblo
**Isla:** Ceniza
**Requisitos de Acceso:** Ninguno
**Descripción:** Plaza rocosa con una forja gigante en el centro. Humo y chispas constantes.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-FUE-003 | Forja Gigante | (0, 0, 0) | Centro plaza |
| 2 | OBJ-TAL-003 | Herramientas Parede | (-2, 2, 0) | Exhibición |
| 3 | OBJ-EXT-001 | Banco Jardín | (2, 0, 1) | Descanso |
| 4 | OBJ-EXT-003 | Farol Jardín | (-1, 0, 2) | Iluminación |
| 5 | OBJ-NAT-012 | Roca Grande | (3, 0, -1) | Decorativa |

**Conexiones:**
- Norte: LOC-CEN-MON-001 (Montaña Principal)
- Oeste: LOC-CEN-BOS-001 (Bosque de Cenizas)
- Este: LOC-CEN-RUI-001 (Ruinas de la Forja)
- Sur: LOC-CEN-PUER-001 (Puerto Minero)

---

#### LOC-CEN-TIE-001 — Tienda de Minerales

**Tipo:** Tienda
**Isla:** Ceniza
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Chispa (M19)
**Horario:** 08:00 - 18:00, cerrado los domingos
**Descripción:** Tienda con estanterías de minerales, lingotes y gemas.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EST-002 | Estantería Alta | (0, 0, 0) | Minerales |
| 2 | OBJ-EST-002 | Estantería Alta | (2, 0, 0) | Lingotes |
| 3 | OBJ-EST-001 | Estantería Baja | (4, 0, 0) | Gemas |
| 4 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | Mostrador |

**Conexiones:**
- Norte: LOC-CEN-PUB-001 (Plaza de la Forja)

---

#### LOC-CEN-TAL-001 — Herrería Avanzada

**Tipo:** Taller
**Isla:** Ceniza
**Requisitos de Acceso:** Curso de herrería avanzada (M158)
**NPC Dueño:** Pedro (M19)
**Horario:** 07:00 - 18:00, cerrado los domingos
**Descripción:** Taller con hornos de alta temperatura para forjar herramientas T3 de oro.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-TAL-001 | Mesa de Trabajo | (0, 0, 0) | Forja T3 |
| 2 | OBJ-FUE-004 | Horno Alto | (2, 0, 0) | Alta temperatura |
| 3 | OBJ-TAL-009 | Banco Herramientas | (4, 0, 0) | Herramientas avanzadas |
| 4 | OBJ-EST-002 | Estantería Alta | (0, 0, 2) | Oro, metales raros |
| 5 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | Exhibición |

**Conexiones:**
- Este: LOC-CEN-PUB-001 (Plaza de la Forja)

---

#### LOC-CEN-CASA-001 — Casa del Herrero Avanzado

**Tipo:** Casa NPC
**Isla:** Ceniza
**Requisitos de Acceso:** Amistad ≥ 1 con Pedro
**NPC Dueño:** Pedro (M19)
**Descripción:** Casa de piedra volcánica con planos de construcción en las paredes.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-EST-001 | Estantería Baja | (0, 0, 0) | Planos |
| 3 | OBJ-MES-002 | Mesa Rectangular | (3, 0, 1) | Comedor |
| 4 | OBJ-FUE-001 | Horno Pequeño | (0, 0, 2) | Calefacción |

**Conexiones:**
- Norte: LOC-CEN-PUB-001 (Plaza de la Forja)

---

#### LOC-CEN-PUER-001 — Puerto Minero

**Tipo:** Puerto
**Isla:** Ceniza
**Requisitos de Acceso:** Ninguno
**Descripción:** Puerto roco con barcos de carga para transportar minerales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-014 | Mesa Exterior | (0, 0, 0) | Mapa de rutas |
| 2 | OBJ-EXT-003 | Farol Jardín | (-2, 0, 0) | Iluminación |
| 3 | OBJ-EXT-010 | Paso Piedra | (0, 0, 2) | Camino a muelle |

**Conexiones:**
- Norte: LOC-CEN-PUB-001 (Plaza de la Forja)
- Mar: Océano navegable a otras islas

---

#### LOC-CEN-MON-001 — Montaña Principal

**Tipo:** Montaña
**Isla:** Ceniza
**Requisitos de Acceso:** Ninguno
**Descripción:** Cumbre volcánica con vistas de toda la isla. Vapor y azufre.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 3, 0) | Cumbre |
| 2 | OBJ-NAT-025 | Volcán Activo | (0, 5, 0) | Fumarolas |

**Conexiones:**
- Sur: LOC-CEN-PUB-001 (Plaza de la Forja)

---

#### LOC-CEN-MON-002 — Mina Abandonada

**Tipo:** Montaña
**Isla:** Ceniza
**Requisitos de Acceso:** Herramienta T2
**Descripción:** Mina abandonada con minerales raros y riesgos de derrumbe.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | Entrada |
| 2 | OBJ-TAL-003 | Herramientas Parede | (2, 0, 1) | Herramientas viejas |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-003 | Hierro Bruto | (3, 0, 0) | Hierro | Mina T2 |
| 2 | OBJ-ITE-005 | Oro Bruto | (1, 0, 2) | Oro | Mina T2 |

**Conexiones:**
- Sur: LOC-CEN-BOS-001 (Bosque de Cenizas)

---

#### LOC-CEN-BOS-001 — Bosque de Cenizas

**Tipo:** Bosque
**Isla:** Ceniza
**Requisitos de Acceso:** Ninguno
**Descripción:** Bosque quemado con árboles negros y ceniza volcánica. Recursos de madera oscura.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-026 | Árbol Quemado | (0, 0, 0) | Centro |
| 2 | OBJ-NAT-026 | Árbol Quemado | (-3, 0, -2) | Muerto |
| 3 | OBJ-NAT-012 | Roca Grande | (2, 0, 1) | Ceniza |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-026 | Árbol Quemado | (0, 0, 0) | Madera Oscura | Tala T2 |
| 2 | OBJ-ITE-007 | Barro Volcánico | (1, 0, 2) | Barro | Recoger |

**Conexiones:**
- Este: LOC-CEN-PUB-001 (Plaza de la Forja)
- Norte: LOC-CEN-MON-002 (Mina Abandonada)

---

#### LOC-CEN-CUE-001 — Cueva de Minerales

**Tipo:** Cueva
**Isla:** Ceniza
**Requisitos de Acceso:** Herramienta T2
**Descripción:** Cueva con vetas de minerales básicos y cristales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | Entrada |
| 2 | OBJ-ITE-002 | Piedra Granel | (2, 0, 1) | Interior |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-003 | Hierro Bruto | (3, 0, 0) | Hierro | Mina T2 |
| 2 | OBJ-ITE-004 | Cobre Bruto | (1, 0, 2) | Cobre | Mina T2 |

**Conexiones:**
- Sur: LOC-CEN-PUER-001 (Puerto Minero)

---

#### LOC-CEN-CUE-002 — Cueva Profunda

**Tipo:** Cueva
**Isla:** Ceniza
**Requisitos de Acceso:** Herramienta T3 + Misión de Vulcania
**Descripción:** Cueva profunda con minerales raros y ruinas ancestrales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | Entrada |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (3, 0, 1) | Ruinas |
| 3 | OBJ-ITE-008 | Obsidiana | (1, 0, 2) | Rara |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-008 | Obsidiana | (1, 0, 2) | Obsidiana | Mina T3 |
| 2 | OBJ-ITE-009 | Azabache | (2, 0, 0) | Azabache | Mina T3 |

**Conexiones:**
- Sur: LOC-CEN-CUE-001 (Cueva de Minerales)

---

#### LOC-CEN-RUI-001 — Ruinas de la Forja

**Tipo:** Ruinas
**Isla:** Ceniza
**Requisitos de Acceso:** Herramienta T2 + Misión de Vulcania
**Descripción:** Ruinas de una forja ancestral con secretos de metalurgia.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-ART-001 | Glifo Humano | (0, 2, 0) | Pared |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | Pedestal |
| 3 | OBJ-FUE-005 | Forja Ancestral | (4, 0, 0) | Apagada |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-FUE-005 | Forja Ancestral | (4, 0, 0) | Activar | Receta secreta |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | Recoger | Item puzzle |

**Conexiones:**
- Oeste: LOC-CEN-PUB-001 (Plaza de la Forja)

---

## 5. Isla Aurora (AUR) — Detalle Completo (13 ubicaciones)

### 5.1 Mapa Conceptual

```
                        ┌──────────────────────┐
                        │  LOC-AUR-NIE-001     │
                        │  Nieve Alta          │
                        └──────────┬───────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────┴────────┐    ┌───────────┴───────────┐    ┌────────┴────────┐
│ LOC-AUR-NIE-002 │    │    LOC-AUR-PUB-001    │    │ LOC-AUR-LAG     │
│ Bosque Nieve    │◄──►│    Plaza de Aurora    │◄──►│ -001 Lago       │
│                 │    │                       │    │ Cristal         │
└────────┬────────┘    └───┬───┬───┬───────────┘    └────────┬────────┘
         │                 │   │   │                          │
┌────────┴────────┐  ┌─────┴───┴───┴─────┐          ┌───────┴────────┐
│ LOC-AUR-CUE     │  │ LOC-AUR-TIE-001   │          │ LOC-AUR-GLA    │
│ -001 Cueva      │  │ Tienda Cristal    │          │ -001 Glaciar   │
│ Hielo           │  └───────────────────┘          └───────┬────────┘
└─────────────────┘                                        │
                                              ┌────────────┴────────────┐
                                              │                         │
                                    ┌─────────┴──────┐          ┌───────┴────────┐
                                    │ LOC-AUR-TEM    │          │ LOC-AUR-PUER   │
                                    │ -001 Templo    │          │ -001 Puerto    │
                                    │ Ancestral      │          │ Ártico         │
                                    └────────────────┘          └────────────────┘
```

### 5.2 Ubicaciones (13)

#### LOC-AUR-PUB-001 — Plaza de Aurora

**Tipo:** Pueblo
**Isla:** Aurora
**Requisitos de Acceso:** Ninguno
**Descripción:** Pueblo nevado con casas de madera y piedra, humo de chimeneas, nieve eterna.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-001 | Banco Jardín | (0, 0, 0) | Cubierto de nieve |
| 2 | OBJ-EXT-003 | Farol Jardín | (-2, 0, 1) | Iluminación |
| 3 | OBJ-FUE-006 | Chimenea Comunal | (2, 0, -1) | Calor |
| 4 | OBJ-NAT-027 | Árbol Nevado | (3, 0, 2) | Decorativo |
| 5 | OBJ-EXT-010 | Paso Piedra | (0, 0, 2) | Camino principal |

**Conexiones:**
- Norte: LOC-AUR-NIE-001 (Nieve Alta)
- Oeste: LOC-AUR-NIE-002 (Bosque Nieve)
- Este: LOC-AUR-LAG-001 (Lago Cristal)
- Sur: LOC-AUR-PUER-001 (Puerto Ártico)

---

#### LOC-AUR-TIE-001 — Tienda Cristal

**Tipo:** Tienda
**Isla:** Aurora
**Requisitos de Acceso:** Ninguno
**NPC Dueño:** Elena (M19)
**Horario:** 09:00 - 18:00, cerrado domingos
**Descripción:** Tienda de herramientas T4 de cristal y materiales ancestrales.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EST-002 | Estantería Alta | (0, 0, 0) | Cristales T4 |
| 2 | OBJ-EST-001 | Estantería Baja | (2, 0, 0) | Gemas |
| 3 | OBJ-MES-002 | Mesa Rectangular | (1, 0, 2) | Mostrador |
| 4 | OBJ-ITE-011 | Cristal Bruto | (3, 0, 0) | Exhibición |

**Conexiones:**
- Norte: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-TAL-001 — Taller Cristal

**Tipo:** Taller
**Isla:** Aurora
**Requisitos de Acceso:** Curso de manipulación de cristal (M158)
**NPC Dueño:** Carlos (M19)
**Horario:** 08:00 - 18:00, cerrado domingos
**Descripción:** Taller con hornos especiales para trabajar cristal ancestral.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-TAL-002 | Mesa de Trabajo | (0, 0, 0) | Cristalería |
| 2 | OBJ-FUE-007 | Horno Cristal | (2, 0, 0) | Alta precisión |
| 3 | OBJ-EST-002 | Estantería Alta | (4, 0, 0) | Cristales trabajados |
| 4 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | Exhibición |

**Conexiones:**
- Este: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-CASA-001 — Casa de Elena (Joyera Ancestral)

**Tipo:** Casa NPC
**Isla:** Aurora
**Requisitos de Acceso:** Amistad ≥ 1 con Elena
**NPC Dueño:** Elena (M19)
**Descripción:** Taller joyero con vitrinas de cristales trabajados y collares.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-TAL-002 | Mesa de Trabajo | (0, 0, 0) | Joyería |
| 3 | OBJ-EST-001 | Estantería Baja | (4, 0, 0) | Cristales |
| 4 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | Iluminación trabajo |
| 5 | OBJ-PLA-001 | Maceta Clásica | (0, 0, 3) | Roca de nieve |

**Conexiones:**
- Norte: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-CASA-002 — Casa de Pedro (Minero de Profundidad)

**Tipo:** Casa NPC
**Isla:** Aurora
**Requisitos de Acceso:** Amistad ≥ 1 con Pedro
**NPC Dueño:** Pedro (M19)
**Descripción:** Casa excavada en la nieve con herramientas de minero profundo.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-TAL-003 | Herramientas Parede | (0, 2, 0) | Minero |
| 3 | OBJ-EST-002 | Estantería Alta | (4, 0, 0) | Cristales brutos |
| 4 | OBJ-FUE-001 | Horno Pequeño | (0, 0, 2) | Calefacción |

**Conexiones:**
- Este: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-CASA-003 — Casa de Carlos (Cristalero)

**Tipo:** Casa NPC
**Isla:** Aurora
**Requisitos de Acceso:** Amistad ≥ 1 con Carlos
**NPC Dueño:** Carlos (M19)
**Descripción:** Taller-laboratorio de cristalería con muestras de todas las variedades.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-CAM-001 | Cama Simple | (2, 0, 3) | Dormitorio |
| 2 | OBJ-TAL-002 | Mesa de Trabajo | (0, 0, 0) | Laboratorio |
| 3 | OBJ-EST-002 | Estantería Alta | (4, 0, 0) | Muestras |
| 4 | OBJ-LUZ-004 | Farol de Mesa | (1, 1, 0) | Iluminación |

**Conexiones:**
- Oeste: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-PUER-001 — Puerto Ártico

**Tipo:** Puerto
**Isla:** Aurora
**Requisitos de Acceso:** Ninguno
**Descripción:** Puerto helado con barcos de exploración polar.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-EXT-014 | Mesa Exterior | (0, 0, 0) | Mapa rutas polares |
| 2 | OBJ-EXT-003 | Farol Jardín | (-2, 0, 0) | Iluminación |
| 3 | OBJ-EXT-010 | Paso Piedra | (0, 0, 2) | Camino a muelle |

**Conexiones:**
- Norte: LOC-AUR-PUB-001 (Plaza de Aurora)
- Mar: Océano navegable a otras islas

---

#### LOC-AUR-NIE-001 — Nieve Alta

**Tipo:** Nieve
**Isla:** Aurora
**Requisitos de Acceso:** Herramienta T3
**Descripción:** Zona de alta montaña nevada con ventiscas y aves raras.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-027 | Árbol Nevado | (0, 0, 0) | Centro |
| 2 | OBJ-NAT-028 | Monte Nevado | (2, 0, 1) | Alta cumbre |
| 3 | OBJ-NAT-012 | Roca Grande | (-1, 0, 2) | Bajo nieve |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-002 | Piedra Granel | (3, 0, 0) | Piedra | Extracción T3 |
| 2 | OBJ-ITE-011 | Cristal Bruto | (1, 0, 2) | Cristal | Minas T3 |

**Conexiones:**
- Sur: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-NIE-002 — Bosque Nieve

**Tipo:** Nieve
**Isla:** Aurora
**Requisitos de Acceso:** Ninguno
**Descripción:** Bosque de pinos nevados con aves y mamíferos polares.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-027 | Árbol Nevado | (0, 0, 0) | Centro |
| 2 | OBJ-NAT-027 | Árbol Nevado | (-3, 0, -2) | Denso |
| 3 | OBJ-NAT-012 | Roca Grande | (2, 0, 1) | Bajo nieve |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-NAT-007 | Pino Nevado | (0, 0, 0) | Madera Nevada | Tala T3 |
| 2 | OBJ-NAT-029 | Baya Ártica | (1, 0, 2) | Baya rara | Recoger |

**Conexiones:**
- Este: LOC-AUR-PUB-001 (Plaza de Aurora)
- Norte: LOC-AUR-NIE-001 (Nieve Alta)

---

#### LOC-AUR-LAG-001 — Lago Cristal

**Tipo:** Lago
**Isla:** Aurora
**Requisitos de Acceso:** Ninguno
**Descripción:** Lago helado con peces bajo el hielo y aurora boreal visible.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-030 | Lago Helado | (0, 0, 0) | Centro |
| 2 | OBJ-NAT-012 | Roca Grande | (2, 0, 1) | Orilla |
| 3 | OBJ-NAT-027 | Árbol Nevado | (-2, 0, 0) | Orilla |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-PEZ-008 | Pez Hielo | (0, 0, 0) | Pez raro | Pesca hielo |
| 2 | OBJ-PEZ-009 | Pez Aurora | (1, 0, 1) | Pez legendario | Pesca hielo |

**Conexiones:**
- Oeste: LOC-AUR-PUB-001 (Plaza de Aurora)

---

#### LOC-AUR-GLA-001 — Glaciar

**Tipo:** Nieve
**Isla:** Aurora
**Requisitos de Acceso:** Herramienta T3
**Descripción:** Masa de hielo antiguo con cavernas y fósiles.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-031 | Masa de Hielo | (0, 0, 0) | Centro |
| 2 | OBJ-ITE-012 | Fósil | (2, 0, 1) | En hielo |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-012 | Fósil | (2, 0, 1) | Fósil raro | Extracción T3 |
| 2 | OBJ-ITE-011 | Cristal Bruto | (1, 0, 2) | Cristal | Minas T3 |

**Conexiones:**
- Norte: LOC-AUR-LAG-001 (Lago Cristal)

---

#### LOC-AUR-CUE-001 — Cueva de Hielo

**Tipo:** Cueva
**Isla:** Aurora
**Requisitos de Acceso:** Herramienta T3
**Descripción:** Cueva de hielo con cristales ancestrales y ruinas olvidadas.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-NAT-012 | Roca Grande | (0, 0, 0) | Entrada |
| 2 | OBJ-ITE-011 | Cristal Bruto | (2, 0, 1) | Interior |
| 3 | OBJ-ART-001 | Glifo Humano | (4, 0, 0) | Pared hielo |

**Objetos de Recolección:**
| # | ID M159 | Objeto | Posición | Recurso | Notas |
|---|---------|--------|----------|---------|-------|
| 1 | OBJ-ITE-011 | Cristal Bruto | (2, 0, 1) | Cristal | Minas T3 |
| 2 | OBJ-ITE-013 | Hielo Ancestral | (1, 0, 2) | Hielo raro | Minas T3 |

**Conexiones:**
- Sur: LOC-AUR-NIE-001 (Nieve Alta)

---

#### LOC-AUR-TEM-001 — Templo Ancestral

**Tipo:** Ruinas
**Isla:** Aurora
**Requisitos de Acceso:** Herramienta T4 + 4 Llaves Ancestrales
**Descripción:** Templo final con el mayor tesoro de la isla. Solo accesible con herramientas T4.

**Objetos Fijos:**
| # | ID M159 | Objeto | Posición | Notas |
|---|---------|--------|----------|-------|
| 1 | OBJ-ART-001 | Glifo Humano | (0, 3, 0) | Pared templo |
| 2 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | Centro altar |
| 3 | OBJ-ART-011 | Calendario Piedra | (4, 0, 0) | Calendario completo |
| 4 | OBJ-CAJ-002 | Baúl Lujoso | (0, 0, 2) | Tesoro mayor |

**Objetos Interactuables:**
| # | ID M159 | Objeto | Posición | Interacción | Notas |
|---|---------|--------|----------|-------------|-------|
| 1 | OBJ-ART-004 | Estatuilla Ancestral | (2, 0, 1) | Activar | Apertura tesoro |
| 2 | OBJ-CAJ-002 | Baúl Lujoso | (0, 0, 2) | Abrir | Item final |

**Conexiones:**
- Norte: LOC-AUR-GLA-001 (Glaciar)

---

## 6. Resumen de Ubicaciones por Isla

| Isla | Total | PUB | CASA | TIE | TAL | CUE | BOS | PLA | RUI | PUER | MON | NIE | LAG | GLA | TEM |
|------|-------|-----|------|-----|-----|-----|-----|-----|-----|------|-----|-----|-----|-----|-----|
| RIZ | 18 | 1 | 5 | 1 | 1 | 1 | 3 | 2 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |
| COR | 15 | 1 | 2 | 2 | 0 | 1 | 0 | 2 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| CEN | 14 | 1 | 1 | 1 | 1 | 2 | 1 | 0 | 1 | 1 | 2 | 0 | 0 | 0 | 0 |
| AUR | 13 | 1 | 3 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 0 | 2 | 1 | 1 | 1 |
| **Total** | **60** | **4** | **11** | **5** | **3** | **5** | **4** | **4** | **2** | **4** | **4** | **2** | **1** | **1** | **1** |
