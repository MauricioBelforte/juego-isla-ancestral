**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Modulo 163: Sistema de Encantamientos

## 1. Analisis del Dominio

###flujo del jugador

```
Jugador tiene herramienta de cualquier tier
  → Recolecta incienso (cultivo de plantas especiales o eventos)
  → Visita chaman del monte (Isla Raiz, zona remota)
  → Paga incienso + monedas
  → Herramienta se encanta permanentemente
  → Habilidad unica activada
  → Puede vender en tienda especializada (opcional)
```

### Recursos del sistema

| Recurso | Origen | Renovable | Coste aprox |
|---------|--------|-----------|-------------|
| Incienso basico | Cultivo de plantas de montaña | Si (cada 3 dias) | 10 monedas/siembra |
| Incienso raro | Eventos estacionales | Parcial | Gratis (evento) |
| Monedas de encantamiento | Pago al chaman | No | 200-1000 segun tier |

### Decisiones de diseno

**D1: Encantamiento es lateral, no obligatorio.** Ningun contenido del juego requiere encantamiento para completarse. Es una mejora opcional que agrega profundidad.

**D2: Cualquier tier se puede encantar.** No hay restriccion de tier minimo. Un jugador con T1 puede encantar desde el inicio si tiene incienso.

**D3: Incienso es renovable.** El jugador nunca se queda sin posibilidad de encantar. El incienso se cultiva o se obtiene en eventos.

**D4: Encantamientos se pueden vender.** Las tiendas especializadas compran herramientas encantadas a precio premium. Esto crea un mercado activo.

**D5: El chaman esta en Isla Raiz.** Es accesible desde el inicio, no requiere viaje a islas lejanas. Esto permite encantar temprano.

## 2. Analisis de Alternativas

**Alternativa A: Encantamiento por crafting** - Descartada (requiere materiales raros, puede frustrar)

**Alternativa B: Encantamiento por chaman con incienso** - ELEGIDA (accesible, renovable, tematicamente coherente)

**Alternativa C: Encantamiento aleatorio** - Descartada (no cozy, puede frustrar)

## 3. Matriz de Dependencias

- M13 (Herramientas) → M163 (Encantamientos modulan herramientas)
- M158 (Tiers) → M163 (Encantamientos por tier)
- M159 (Catalogo) → M163 (Items encantados en catalogo)
- M163 → M39 (Tiendas compran encantados)
- M163 → M38 (Economia: precios premium)
