**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 160: Diseño de Ubicaciones del Mundo

## 1. Análisis del Dominio

### 1.1 Jerarquía de Ubicaciones

```
MUNDO (Archipiélago)
├── Isla Raíz (RIZ) — Tutorial, carpintería
│   ├── Pueblo Raíz
│   │   ├── LOC-RIZ-CASA-001 (Casa del Jugador)
│   │   ├── LOC-RIZ-TIE-001 (Tienda General)
│   │   ├── LOC-RIZ-TAL-001 (Carpintería)
│   │   ├── LOC-RIZ-PUB-001 (Plaza del Pueblo)
│   │   ├── LOC-RIZ-CASA-002 (Casa del Carpintero)
│   │   ├── LOC-RIZ-CASA-003 (Casa del Viejo Sabio)
│   │   └── LOC-RIZ-PUER-001 (Puerto)
│   ├── Bosque Raíz
│   │   ├── LOC-RIZ-BOS-001 (Bosque Principal)
│   │   ├── LOC-RIZ-BOS-002 (Claros del Bosque)
│   │   └── LOC-RIZ-BOS-003 (Árbol Grande)
│   ├── Playa Raíz
│   │   ├── LOC-RIZ-PLA-001 (Playa Principal)
│   │   └── LOC-RIZ-PLA-002 (Cueva de la Playa)
│   ├── Cueva Raíz
│   │   └── LOC-RIZ-CUE-001 (Cueva de Tutorial)
│   └── Ruinas Raíz
│       └── LOC-RIZ-RUI-001 (Ruinas Antiguas)
├── Isla Coral (COR) — Herrería, pesca tropical
│   ├── Pueblo Coral
│   │   ├── LOC-COR-TIE-001 (Ferretería)
│   │   ├── LOC-COR-TIE-002 (Pescadería)
│   │   ├── LOC-COR-TAL-001 (Herrería)
│   │   ├── LOC-COR-PUB-001 (Plaza del Puerto)
│   │   ├── LOC-COR-CASA-001 (Casa del Herrero)
│   │   └── LOC-COR-PUER-001 (Puerto Tropical)
│   ├── Selva Coral
│   │   ├── LOC-COR-SEL-001 (Selva Tropical)
│   │   └── LOC-COR-SEL-002 (Cataratas)
│   ├── Playa Coral
│   │   ├── LOC-COR-PLA-001 (Playa de Coral)
│   │   └── LOC-COR-PLA-002 (Arrecife)
│   ├── Cueva Coral
│   │   └── LOC-COR-CUE-001 (Cueva del Coral)
│   └── Monte Coral
│       └── LOC-COR-MON-001 (Monte Vigía)
├── Isla Ceniza (CEN) — Herrería avanzada, recursos
│   ├── Pueblo Ceniza
│   │   ├── LOC-CEN-TIE-001 (Tienda de Minerales)
│   │   ├── LOC-CEN-TAL-001 (Herrería Avanzada)
│   │   ├── LOC-CEN-PUB-001 (Plaza de la Forja)
│   │   ├── LOC-CEN-CASA-001 (Casa del Herrero Avanzado)
│   │   └── LOC-CEN-PUER-001 (Puerto Minero)
│   ├── Montaña Ceniza
│   │   ├── LOC-CEN-MON-001 (Montaña Principal)
│   │   └── LOC-CEN-MON-002 (Mina Abandonada)
│   ├── Bosque Ceniza
│   │   └── LOC-CEN-BOS-001 (Bosque de Cenizas)
│   ├── Cueva Ceniza
│   │   ├── LOC-CEN-CUE-001 (Cueva de Minerales)
│   │   └── LOC-CEN-CUE-002 (Cueva Profunda)
│   └── Ruinas Ceniza
│       └── LOC-CEN-RUI-001 (Ruinas de la Forja)
└── Isla Aurora (AUR) — Encantamiento, historia principal
    ├── Pueblo Aurora
    │   ├── LOC-AUR-TIE-001 (Tienda de Encantamientos)
    │   ├── LOC-AUR-TAL-001 (Taller del Encantador)
    │   ├── LOC-AUR-PUB-001 (Plaza Ancestral)
    │   ├── LOC-AUR-CASA-001 (Casa del Encantador)
    │   └── LOC-AUR-PUER-001 (Puerto Ancestral)
    ├── Selva Aurora
    │   └── LOC-AUR-SEL-001 (Selva Ancestral)
    ├── Templo Aurora
    │   ├── LOC-AUR-TEM-001 (Templo de la Brisa)
    │   ├── LOC-AUR-TEM-002 (Templo del Sol)
    │   └── LOC-AUR-TEM-003 (Templo de la Luna)
    ├── Cueva Aurora
    │   └── LOC-AUR-CUE-001 (Cueva de las Estrellas)
    └── Ruinas Aurora
        └── LOC-AUR-RUI-001 (Ruinas del Archivo)
```

### 1.2 Sistema de IDs

**Formato:** `LOC-[ISLA]-[TIPO]-[NÚMERO]`

| Componente | Valores | Descripción |
|------------|---------|-------------|
| ISLA | RIZ, COR, CEN, AUR | Código de la isla |
| TIPO | PUB, CASA, TIE, TAL, CUE, BOS, PLA, RUI, PUER, MON, SEL, TEM | Tipo de ubicación |
| NÚMERO | 001-999 | Secuencial por tipo en cada isla |

### 1.3 Formato de Documentación por Ubicación

Cada ubicación se documenta con:

- **ID:** Identificador único (LOC-ISLA-TIPO-NÚMERO)
- **Tipo:** Tipo de ubicación
- **Isla:** Isla donde se encuentra
- **Requisitos de Acceso:** Herramientas, monedas o items necesarios
- **Descripción:** Descripción breve del lugar
- **Objetos Fijos:** Objetos que no se mueven (muebles, estructuras)
- **Objetos Interactuables:** Objetos con interacción (encender, usar, recoger)
- **Objetos Decorativos:** Objetos estéticos sin interacción
- **Objetos de Recolección:** Recursos naturales que se pueden recoger
- **NPCs Asociados:** NPCs que viven o trabajan aquí
- **Conexiones:** Ubicaciones conectadas (salidas/entradas)
- **Notas:** Detalles adicionales para artistas/programadores

### 1.4 Formato de Referencia a Objetos M159

Cada objeto se referencia con su ID del catálogo M159:

```
OBJ-[CATEGORÍA]-[NÚMERO]
```

Ejemplos:
- `OBJ-CAM-001` = Cama Simple (M159)
- `OBJ-MES-001` = Mesa Redonda (M159)
- `OBJ-LUZ-001` = Lámpara de Mesa (M159)
- `OBJ-HER-001` = Hacha Madera T1 (M159)

### 1.5 Categorías de Objetos por Ubicación

| Categoría | Descripción | Ejemplos |
|-----------|-------------|----------|
| Estructura | Paredes, techos, pisos | Pared Madera, Techo Tejas |
| Mobiliario | Mesas, sillas, camas | Mesa Redonda, Silla Básica |
| Decoración | Cuadros, espejos, plantas | Cuadro Paisaje, Maceta Clásica |
| Iluminación | Lámparas, faroles, velas | Lámpara de Mesa, Vela Simple |
| Herramientas | Hachas, picos, palas | Hacha Madera T1, Pico Cobre T2 |
| Almacenamiento | Cofres, estanterías | Cofre Básico, Estantería Baja |
| Naturaleza | Árboles, rocas, plantas | Árbol Grande, Roca Mediana |
| Comida | Alimentos y bebidas | Manzana, Pan, Leche |
| Materiales | Recursos procesados | Tabla Madera, Ladrillo, Cuerda |
| Ropa | Vestimenta del jugador | Sombrero Paja, Camisa Básica |

## 2. Análisis de Integración

### 2.1 Conexiones entre Módulos

| Módulo | Conexión con M160 |
|--------|-------------------|
| M27 (Islas) | Define las islas; M160 define las ubicaciones dentro de cada isla |
| M17 (Construcción) | Edificios construibles por el jugador se marcan como ampliables |
| M18 (Casas) | Casas del jugador y NPC se documentan en M160 |
| M39 (Tiendas) | Tiendas tienen dueño NPC y catálogo asociado |
| M159 (Catálogo) | Cada objeto referenciado tiene ID válido en M159 |
| M158 (Herramientas) | Herramientas requeridas por ubicación se alinean con tiers |
| M19 (NPC) | NPCs asociados a cada ubicación |
| M25 (Ruinas) | Ruinas documentadas en M160 |
| M28 (Viajes) | Puertos integrados con sistema de viajes |
| M38 (Economía) | Precios de tiendas delegados a M38 |
| M45 (Arte 3D) | M160 es input para producción de assets |
| M58 (Guardado) | Ubicaciones se guardan con el estado del mundo |

### 2.2 Flujo de Datos

```
M27 (Islas) → M160 (Ubicaciones) → M159 (Objetos)
                    ↓
            M17/M18 (Construcción/Casas)
            M39 (Tiendas)
            M45 (Arte 3D)
            M58 (Guardado)
```

## 3. Decisiones de Diseño

### 3.1 ¿Por qué un módulo separado?

- **Separación de responsabilidades:** M27 define QUÉ islas existen; M160 define QUÉ hay en cada isla
- **Ampliable:** se pueden agregar ubicaciones sin modificar islas existentes
- **Específico para artistas:** artistas necesitan saber qué objetos crear y dónde colocarlos
- **Específico para programadores:** programadores necesitan saber qué systems integrar en cada ubicación

### 3.2 ¿Por qué no en M27?

- M27 ya es grande (define 13 islas con biomas, clima, contenido exclusivo)
- Agregar distribución de objetos lo haría inmanejable
- La distribución de objetos es un nivel de detalle diferente al diseño de islas

### 3.3 ¿Por qué no en M159?

- M159 define QUÉ objetos existen; M160 define DÓNDE van
- M159 es un catálogo genérico; M160 es específico del mundo
- Mantener separados permite reutilizar M159 en otros contextos
