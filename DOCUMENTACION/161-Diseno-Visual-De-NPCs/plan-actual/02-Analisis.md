**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# 02-Analisis.md — Módulo 161: Diseño Visual de NPCs

## 1. Análisis del Dominio

### 1.1 Jerarquía de Elementos Visuales por NPC

```
NPC
├── Cuerpo
│   ├── Piel (tono, textura)
│   ├── Cabello (estilo, color)
│   └── Ojos (color, forma)
├── Ropa
│   ├── Cabeza (sombrero, cofia, turbante, casco)
│   ├── Torso (camisa, chaleco, túnica, armadura)
│   ├── Cintura (cinturón, mandil)
│   ├── Piernas (pantalón, falda)
│   └── Pies (botas, sandalias, zapatillas)
├── Accesorios
│   ├── Cuello (collar, medalla)
│   ├── Manos (guantes, anillos)
│   └── Cinturón (herramientas, bolsas)
└── Herramienta en Mano
    ├── Derecha (herramienta principal)
    └── Izquierda (secundaria, opcional)
```

### 1.2 Formato de Diseño por NPC

Cada NPC se documenta con:
- **Nombre y rol**
- **Rasgos físicos:** piel (SK-XX), cabello (HR-XX), ojos (EY-XX), complexión
- **Ropa completa:** sombrero, camisa, pantalón, botas (con color HEX)
- **Herramienta en mano:** ID de M159 o descripción
- **Accesorios:** detalles adicionales
- **Variantes estacionales:** cambios por estación

### 1.3 IDs de Rasgos Físicos

**Piel (SK):**
- SK-01: Clara #F5D6C4
- SK-02: Medio #D4A882
- SK-03: Bronceado #C49A6C
- SK-04: Moreno #8B6914
- SK-05: Oscuro #5C4033

**Cabello (HR):**
- HR-01: Rubio #F5DEB3
- HR-02: Castaño Claro #C4A882
- HR-03: Castaño #8B6914
- HR-04: Pelirrojo #B22222
- HR-05: Negro #2C2C2C
- HR-06: Canoso #9E9E9E
- HR-07: Blanco #F5F5DC
- HR-08: Pelirojo Claro #CD853F

**Ojos (EY):**
- EY-01: Marrón #5C4033
- EY-02: Verde #228B22
- EY-03: Azul #5F9EA0
- EY-04: Ámbar #FFBF00
- EY-05: Gris #808080

## 2. Análisis de Integración

### 2.1 Conexiones entre Módulos

| Módulo | Conexión con M161 |
|--------|-------------------|
| M19 (NPC) | Define quiénes son; M161 define cómo se ven |
| M159 (Catálogo) | Herramientas en mano usan IDs de M159 |
| M45 (Arte 3D) | M161 es input para modelado de NPCs |
| M46 (Arte 2D) | Retratos 2D se basan en M161 |
| M155 (Vestimenta) | Ropa del NPC puede coincidir con prendas del jugador |
| M160 (Ubicaciones) | NPCs aparecen en sus ubicaciones |
| M27 (Islas) | Colores y estilo reflejan la isla |
| M29 (Tiempo) | Variantes estacionales |
| M39 (Tiendas) | NPCs comerciantes con su tienda |

### 2.2 Flujo de Datos

```
M19 (NPC: quién es) → M161 (Visual: cómo se ve) → M45/M46 (Arte 3D/2D)
                              ↓
                    M159 (Herramientas en mano)
                    M155 (Ropa compartida)
                    M160 (Ubicaciones)
```

## 3. Decisiones de Diseño

### 3.1 ¿Por qué un módulo separado?

- **Separación de responsabilidades:** M19 define personalidad; M161 define apariencia
- **Específico para artistas:** artistas necesitan saber qué modelar
- **Consistencia visual:** todos los NPCs de una isla deben ser coherentes
- **Reutilización:** retratos 2D (M46) y modelos 3D (M45) consumen M161

### 3.2 ¿Por qué no en M19?

- M19 ya es grande (25 NPCs con personalidad, rutinas, diálogos)
- Agregar diseño visual lo haría inmanejable
- El diseño visual es un nivel de detalle diferente al comportamiento

### 3.3 ¿Por qué no en M45?

- M45 define polígonos y técnicas; M161 define QUÉ modelar
- M45 es genérico para todos los assets; M161 es específico de NPCs
- Mantener separados permite cambiar el estilo visual sin reescribir M45
