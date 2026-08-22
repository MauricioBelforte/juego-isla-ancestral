**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 02-Analisis.md — Módulo 159: Catálogo de Objetos

## 1. Análisis del Dominio

El catálogo de objetos es el **inventario maestro** del juego. Cada objeto que el jugador puede encontrar, recoger, colocar o intercambiar debe estar documentado aquí.

### Jerarquía de Objetos

```
JUEGO
├── OBJETOS DEL MUNDO (no recogibles)
│   ├── Naturaleza (árboles, rocas, arbustos)
│   ├── Estructuras (puertas, ventanas, escaleras)
│   └── Decoración fija (faroles, carteles)
├── OBJETOS RECOGIBLES (van al inventario)
│   ├── Materiales (madera, piedra, hierro)
│   ├── Comida (pescado, fruta, pastel)
│   ├── Herramientas (hacha, pico, caña)
│   ├── Ropa (sombrero, camisa, zapatos)
│   └── Tokens (monedas, gemas, llaves)
├── OBJETOS COLOCABLES (se ponen en grid)
│   ├── Mobiliario (mesas, sillas, camas)
│   ├── Decoración (cuadros, macetas, alfombras)
│   ├── Iluminación (lámparas, velas)
│   └── Funcionales (cocina, taller, cofre)
└── OBJETOS ESPECIALES
    ├── Arte ancestral (glifos, estatuas)
    ├── Items de evento (festivales)
    └── Items secretos (legendarios)
```

## 2. Análisis de Fuentes

### Fuentes de Obtención

| Fuente | Tipo de objetos | Cantidad | Módulo |
|--------|----------------|----------|--------|
| Tiendas del pueblo | Mobiliario, decoración, herramientas | 100+ | M39 |
| Crafting (M16) | Herramientas, muebles, comida | 80+ | M16 |
| Exploración | Materiales, tesoros, arte ancestral | 60+ | M25 |
| Regalos de NPCs | Items exclusivos, recetas | 20+ | M19/M20 |
| Pesca (M34) | Peces, conchas, tesoros marinos | 30+ | M34 |
| Minería | Minerales, gemas, fósiles | 25+ | M13 |
| Agricultura | Cultivos, hierbas, flores | 30+ | M33 |
| Festivales | Items exclusivos de evento | 15+ | M29 |
| Ruinas (M25) | Arte ancestral, glifos, reliquias | 20+ | M25 |
| Tesoros ocultos | Items legendarios | 15+ | M25 |

## 3. Análisis de Interacciones

### Tipos de Interacción

| Interacción | Descripción | Objetos que la tienen |
|-------------|-------------|----------------------|
| Sentarse | El personaje se sienta | Sillas, bancos, sofás |
| Dormir | Descansa y avanza tiempo | Camas |
| Almacenar | Guarda items | Cofres, estanterías |
| Cocinar | Crea comida | Mesón, horno |
| Fabricar | Crea herramientas/items | Mesa de trabajo, yunque |
| Encender/apagar | Cambia iluminación | Lámparas, faroles |
| Regar | Crecen plantas | Macetas, jardines |
| Colocar item | Pone un objeto encima | Mesas, repisas |
| Mirar | Muestra información | Cuadros, estatuas |
| Escuchar | Cambia música | Radio, instrumento |
| Recoger | Va al inventario | Hierbas, minerales, frutas |
| Romper | Obtienes materiales | Árboles, rocas, barriles |
| Abrir/cerrar | Acceso a interior | Puertas, ventanas |

## 4. Análisis de Tamaños

### Ocupación de Grid

| Tamaño | Ejemplos | Uso |
|--------|----------|-----|
| 1×1 | Silla, maceta, lámpara, velador | Objetos pequeños |
| 2×1 | Mesa pequeña, estantería baja | Objetos medianos |
| 2×2 | Mesa grande, cama, sofá | Objetos grandes |
| 3×2 | Mesa de comedor, armario | Objetos muy grandes |
| 3×3 | Mesa de trabajo, cocina | Estaciones de trabajo |
| 1×3 | Estantería alta, escultura | Objetos altos |
| 2×3 | Mueble de pared, vitrina | Objetos de pared grandes |

## 5. Análisis de Rareza

| Rareza | Color | Frecuencia | Ejemplos |
|--------|-------|------------|----------|
| Común | Gris | 60% | Mesa de madera, silla, maceta básica |
| Poco común | Verde | 25% | Mesa tallada, lámpara de cristal |
| Raro | Azul | 12% | Mueble ancestral, escultura |
| Legendario | Dorado | 3% | Glifo iluminado, trono ancestral |

## 6. Decisiones de Diseño

1. **Un objeto = una entrada en el catálogo**: cada variante de color/especial es una entrada separada
2. **Los objetos del mundo (no recogibles) también se documentan**: para que el equipo de arte sepa qué crear
3. **Los objetos recogibles tienen stats de inventario**: precio, stack, rareza
4. **Los objetos colocables tienen stats de grid**: tamaño, rotación, interacción
5. **Los objetos funcionales tienen stats de uso**: qué hacen, qué necesitan, qué producen

## 7. Integración con Otros Módulos

| Módulo | Consumo del catálogo |
|--------|---------------------|
| M14 (Inventario) | Lista de objetos que se pueden guardar |
| M16 (Crafting) | Recetas: qué objetos se necesitan y qué se crea |
| M18 (Casas) | Objetos que se pueden colocar en el grid |
| M39 (Tiendas) | Objetos que se venden y sus precios |
| M45 (Arte 3D) | Lista de assets a modelar |
| M58 (Guardado) | IDs de objetos para serializar |
| M155 (Vestimenta) | Prendas que afectan movimiento |
| M158 (Herramientas) | Herramientas con tiers |
