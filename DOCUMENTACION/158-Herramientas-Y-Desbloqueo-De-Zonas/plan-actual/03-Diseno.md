**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Modulo 158: Herramientas y Desbloqueo de Zonas

## 1. Arquitectura del Sistema

```
ToolTierSystem (autoload)
├── ToolTierDefinition (Resource)     <- definicion de cada tier
├── ZoneGateDefinition (Resource)     <- que tier necesita cada zona
├── ForgeRecipe (Resource)            <- receta de forja por isla
├── CourseDefinition (Resource)       <- cursos de oficio por isla
└── PlayerToolProgress (persistencia) <- tiers alcanzados, cursos aprendidos
```

## 2. Definicion de Tiers

| Tier | Nombre | Color | Dano | Velocidad | Area | Material |
|------|--------|-------|------|-----------|------|----------|
| T1 | Cobre | Naranja | 1.0 | 1.0 | 1x1 | Gratis (regalo del carpintero) |
| T2 | Hierro | Gris | 2.0 | 1.5 | 1x1 | 10 hierro + 500 monedas |
| T3 | Oro | Dorado | 3.5 | 2.0 | 2x2 | 20 oro + 2000 monedas |
| T4 | Cristal | Azul claro | 5.0 | 3.0 | 2x2 | 5 cristales + 5000 monedas |

## 3. Sistema de Gates por Zona

| Tipo de Gate | Ejemplo | Tier Requerido | Bloquea Historia |
|-------------|---------|----------------|------------------|
| Rama gruesa | Paso en sendero | T1 (hacha cobre) | No |
| Muro de piedra | Camino a pueblo | T2 (pico hierro) | Parcial |
| Raiz anciana | Entrada a templo | T2 (hacha hierro) | Si |
| Sello ancestral | Puerta de templo | T3 (pico oro) | Si |
| Cristal bloqueado | Camara secreta | T4 (herramienta cristal) | Final secreto |
| Tumba ancestral | Zona lore oculto | T4 (herramienta cristal) | No |

## 4. Sistema de Forja por Isla

| Isla | Tier Forjado | Materiales | Monedas | Curso |
|------|-------------|------------|---------|-------|
| Raiz | T1 Cobre | Gratis (regalo) | 0 | 300 monedas |
| Ceniza | T2 Hierro | 10 hierro | 500 | 1500 monedas |
| Coral | T3 Oro | 20 oro | 2000 | 5000 monedas |
| Aurora | T4 Cristal | 5 cristales | 5000 | 10000 monedas |

## 5. Progresion de Cursos

1. **Carpinteria (Raiz)** - 300 monedas: vende T1, precio 10-15
2. **Herreria (Ceniza)** - 1500 monedas: vende T1-T2, precio 15-30
3. **Herreria Avanzada (Coral)** - 5000 monedas: vende T1-T3, precio 20-50
4. **Cristaleria (Aurora)** - 10000 monedas: vende T1-T4, precio 30-80

## 6. NPCs Visitantes

- 1 NPC por dia maximo
- Compra 1-3 items del stock del jugador
- Prefiere items de la profesion del NPC
- Si no hay tienda abierta, no vienen
- Paga precio de M38

## 7. Fuentes de Ingreso

| Fuente | Cantidad | Frecuencia | Maximo |
|--------|----------|------------|--------|
| Jarrones | 5-15 monedas | Semanal | ~150/semana |
| Pescar oro | 1-5 monedas | Diario | ~15/dia |
| Arboles frutos | 2-8 monedas | Diario | ~40/dia |
| Puzzles | 50-200 monedas | Unico | ~3000 total |
| Vender herramientas | 10-80 monedas | 1x/dia | ~80/dia |
| Premium (Steam) | Variable | Instantaneo | Sin limite |

## 8. Integracion con Historia (M22)

| Capitulo | Sellos | Tier Minimo | Isla Necesaria |
|----------|--------|------------|----------------|
| Prologo | 0 | T1 | Principal |
| Cap 1-2 | 1-2 | T2 | Isla 2 |
| Cap 3-4 | 3-4 | T3 | Isla 3 |
| Cap 5-6 | 5-6 | T4 | Isla 4 |
| Cap 7 (final) | 7 | T4 | Isla 4 |

## 9. Anti-Copia de Zelda

| Zelda | Isla Ancestral |
|-------|----------------|
| Llaves que abren puertas | Herramientas que extraen/modifican |
| Puerta = 1 llave | Gate = tier general |
| Lineal | No lineal |
| Combate obligatorio | Exploracion cozy |
| Contenido bloqueado hasta llave | Contenido OPCIONAL |
