**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 158: Herramientas y Desbloqueo de Zonas

## 1. Análisis del Dominio

### Progresión de herramientas por isla

| Tier | Material | Isla | Profesional | Costo aprox | Contenido desbloqueado |
|------|----------|------|-------------|-------------|------------------------|
| T1 | Madera/Piedra | Principal | Auto-colección | Gratis | Ramas, piedras, jarrones, árboles |
| T2 | Cobre | Isla 2 | Herrero | 500 monedas + 10 cobre | Muros piedra, raíces, caminos ocultos |
| T3 | Hierro | Isla 3 | Herrero avanzado | 2000 monedas + 20 hierro | Sellos, puertas templo, historia |
| T4 | Encantada | Isla 4 | Encantador | 5000 monedas + 5 cristales | Cámaras secretas, zonas encantadas |

### Fuentes de ingreso del jugador

| Fuente | Cantidad | Frecuencia | Esfuerzo |
|--------|----------|------------|----------|
| Jarrones | 5-15 monedas | Semanal (se repone) | Explorar |
| Pescar oro | 1-5 monedas | Diario | Mini-juego pesca |
| Arboles (frutos) | 2-8 monedas | Diario | Cortar arboles |
| Vender herramientas | 10-50 monedas | 1x/dia (NPC visitante) | Tener tienda + curso |
| Resolver puzzles | 50-200 monedas | Unico por puzzle | Exploracion |
| Vender en tienda | Variable | Diario | Tener items |
| Premium (Steam) | Variable | Instantaneo | Pagar dinero real |

### Diferencia con Zelda (anti-copia)

| Zelda | Isla Ancestral |
|-------|----------------|
| Llaves que abren puertas | Herramientas que extraen/modifican el mundo |
| Puerta = 1 llave especifica | Gate = tier de herramienta general |
| Lineal (isla por isla) | No lineal (el jugador elige orden) |
| Combate obligatorio | Exploracion cozy, sin combate |
| Contenido bloqueado hasta llave | Contenido OPCIONAL; vida diaria nunca se bloquea |

### Decisiones de diseno

**D1: No hay bloqueo permanente.** El jugador que quiere vivir en su pueblo y pescar puede hacerlo. Las herramientas desbloquean contenido OPCIONAL, no la vida diaria.

**D2: La historia SI requiere T4.** Para completar los 7 sellos y el final, el jugador necesita herramientas encantadas.

**D3: Premium acelera, no reemplaza.** El jugador premium compra monedas pero SIEMPRE debe recorrer el mapa. No puede comprar herramientas directamente.

**D4: Cursos son inversiones.** Aprender carpinteria/herreria/encantamiento cuesta mucho, pero permite vender herramientas y recuperar la inversion.

**D5: Islas como profesiones, no como niveles.** Cada isla tiene identidad propia pero no son niveles que obliguen a un orden.

## 2. Analisis de Alternativas

**Alternativa A: Lineal tipo Zelda** - Descartada (copia, no cozy)

**Alternativa B: Tier global por isla** - ELEGIDA (no copia, cozy, libertad, progresion clara)

**Alternativa C: Recetas descubiertas** - Complementaria (descubrimiento como recompensa secundaria)

## 3. Matriz de Dependencias

- M13 (Herramientas base) → M158 (Tiers y gates) → M22 (Historia requiere T4)
- M38 (Economia) → M158 (Costos de forja) → M39 (Tiendas expandir)
- M27 (Islas) → M158 (Profesiones por isla) → M28 (Viajes con boleto)
- M71 (Progresion) → M158 (Hitos de tier) → M72 (Logros)
- M95 (Monetizacion) → M158 (Compra de monedas premium)
