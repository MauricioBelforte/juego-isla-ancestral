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

## 2. Isla Raíz (RIZ) — Detalle Completo

### 2.1 Mapa Conceptual

```
┌─────────────────────────────────────────────────────┐
│                    ISLA RAÍZ                         │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Bosque   │  │ Pueblo   │  │ Playa    │          │
│  │ Principal│  │ Raíz     │  │ Principal│          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │              │              │                │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐          │
│  │ Claros   │  │ Puerto   │  │ Cueva    │          │
│  │ Bosque   │  │ Raíz     │  │ Playa    │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  ┌──────────┐  ┌──────────┐                         │
│  │ Ruinas   │  │ Cueva    │                         │
│  │ Antiguas │  │ Tutorial │                         │
│  └──────────┘  └──────────┘                         │
└─────────────────────────────────────────────────────┘
```

### 2.2 Todas las Ubicaciones

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

## 3. Isla Coral (COR) — Resumen

### 3.1 Mapa Conceptual

```
┌─────────────────────────────────────────────────────┐
│                    ISLA CORAL                        │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Selva    │  │ Pueblo   │  │ Playa    │          │
│  │ Tropical │  │ Coral    │  │ Coral    │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │              │              │                │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐          │
│  │ Cataratas│  │ Puerto   │  │ Arrecife │          │
│  └──────────┘  │ Tropical │  └──────────┘          │
│                └──────────┘                         │
│  ┌──────────┐  ┌──────────┐                         │
│  │ Cueva    │  │ Monte    │                         │
│  │ Coral    │  │ Vigía    │                         │
│  └──────────┘  └──────────┘                         │
└─────────────────────────────────────────────────────┘
```

### 3.2 Ubicaciones

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| LOC-COR-PUB-001 | Plaza del Puerto | PUB | Plaza costera con mercado |
| LOC-COR-TIE-001 | Ferretería | TIE | Vende herramientas T2 |
| LOC-COR-TIE-002 | Pescadería | TIE | Vende pescado y cebos |
| LOC-COR-TAL-001 | Herrería | TAL | Forja de herramientas T2 |
| LOC-COR-CASA-001 | Casa del Herrero | CASA | Residencia del herrero |
| LOC-COR-PUER-001 | Puerto Tropical | PUER | Embarque/desembarque |
| LOC-COR-SEL-001 | Selva Tropical | SEL | Vegetación densa, recursos |
| LOC-COR-SEL-002 | Cataratas | SEL | Zona de pesca premium |
| LOC-COR-PLA-001 | Playa de Coral | PLA | Arena blanca, conchas |
| LOC-COR-PLA-002 | Arrecife | PLA | Pesca submarina |
| LOC-COR-CUE-001 | Cueva del Coral | CUE | Cristales de coral |
| LOC-COR-MON-001 | Monte Vigía | MON | Vista panorámica |

---

## 4. Isla Ceniza (CEN) — Resumen

### 4.1 Mapa Conceptual

```
┌─────────────────────────────────────────────────────┐
│                    ISLA CENIZA                       │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Montaña  │  │ Pueblo   │  │ Bosque   │          │
│  │ Principal│  │ Ceniza   │  │ Cenizas  │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │              │              │                │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐          │
│  │ Mina     │  │ Puerto   │  │ Ruinas   │          │
│  │ Abandon. │  │ Minero   │  │ Forja    │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐                         │
│  │ Cueva    │  │ Cueva    │                         │
│  │ Minerales│  │ Profunda │                         │
│  └──────────┘  └──────────┘                         │
└─────────────────────────────────────────────────────┘
```

### 4.2 Ubicaciones

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| LOC-CEN-PUB-001 | Plaza de la Forja | PUB | Plaza con forja gigante |
| LOC-CEN-TIE-001 | Tienda de Minerales | TIE | Vende minerales y lingotes |
| LOC-CEN-TAL-001 | Herrería Avanzada | TAL | Forja herramientas T3 |
| LOC-CEN-CASA-001 | Casa del Herrero Avanzado | CASA | Residencia |
| LOC-CEN-PUER-001 | Puerto Minero | PUER | Embarque/desembarque |
| LOC-CEN-MON-001 | Montaña Principal | MON | Cumbre, vistas |
| LOC-CEN-MON-002 | Mina Abandonada | MON | Recursos raros |
| LOC-CEN-BOS-001 | Bosque de Cenizas | BOS | Árboles quemados |
| LOC-CEN-CUE-001 | Cueva de Minerales | CUE | Minerales básicos |
| LOC-CEN-CUE-002 | Cueva Profunda | CUE | Minerales raros |
| LOC-CEN-RUI-001 | Ruinas de la Forja | RUI | Forja ancestral |

---

## 5. Isla Aurora (AUR) — Resumen

### 5.1 Mapa Conceptual

```
┌─────────────────────────────────────────────────────┐
│                    ISLA AURORA                       │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Selva    │  │ Pueblo   │  │ Templo   │          │
│  │ Ancestral│  │ Aurora   │  │ Brisa    │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │              │              │                │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐          │
│  │ Cueva    │  │ Puerto   │  │ Templo   │          │
│  │ Estrellas│  │ Ancestral│  │ Sol      │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐                         │
│  │ Ruinas   │  │ Templo   │                         │
│  │ Archivo  │  │ Luna     │                         │
│  └──────────┘  └──────────┘                         │
└─────────────────────────────────────────────────────┘
```

### 5.2 Ubicaciones

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| LOC-AUR-PUB-001 | Plaza Ancestral | PUB | Plaza con obelisco central |
| LOC-AUR-TIE-001 | Tienda de Encantamientos | TIE | Vende herramientas T4 |
| LOC-AUR-TAL-001 | Taller del Encantador | TAL | Encantamiento de objetos |
| LOC-AUR-CASA-001 | Casa del Encantador | CASA | Residencia |
| LOC-AUR-PUER-001 | Puerto Ancestral | PUER | Embarque/desembarque |
| LOC-AUR-SEL-001 | Selva Ancestral | SEL | Vegetación mágica |
| LOC-AUR-TEM-001 | Templo de la Brisa | TEM | Puzzle de viento |
| LOC-AUR-TEM-002 | Templo del Sol | TEM | Puzzle de luz |
| LOC-AUR-TEM-003 | Templo de la Luna | TEM | Puzzle de sombra |
| LOC-AUR-CUE-001 | Cueva de las Estrellas | CUE | Cristales brillantes |
| LOC-AUR-RUI-001 | Ruinas del Archivo | RUI | Lore principal |

---

## 6. Resumen de Ubicaciones por Isla

| Isla | Total | PUB | CASA | TIE | TAL | CUE | BOS | PLA | RUI | PUER | MON | SEL | TEM |
|------|-------|-----|------|-----|-----|-----|-----|-----|-----|------|-----|-----|-----|
| RIZ | 12 | 1 | 3 | 1 | 1 | 1 | 3 | 2 | 1 | 1 | 0 | 0 | 0 |
| COR | 12 | 1 | 1 | 2 | 1 | 1 | 0 | 2 | 0 | 1 | 1 | 2 | 0 |
| CEN | 11 | 1 | 1 | 1 | 1 | 2 | 1 | 0 | 1 | 1 | 2 | 0 | 0 |
| AUR | 11 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 1 | 3 |
| **Total** | **46** | **4** | **6** | **5** | **4** | **5** | **4** | **4** | **3** | **4** | **3** | **3** | **3** |
