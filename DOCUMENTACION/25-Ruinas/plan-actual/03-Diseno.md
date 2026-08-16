# 03 — Diseño — M25: Ruinas

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Kit modular (≤ 40 piezas base)

| Grupo | Piezas (ej.) |
|---|---|
| Suelos | losa, losa rota, losa intermedia, umbral |
| Muros | muro recto, esquina, muro roto, muro con vano, muro alto |
| Aperturas | arco, puerta, ventana, pasaje |
| Soportes | columna, pilar roto, contrafuerte |
| Techos | techo a 2 aguas, techo plano, crestería |
| Escaleras | tramo recto, tramo en L, rampa |
| Decoración | balaustrada, cornisa, estela, altar, banco |
| Canal | canal de agua, compuerta seca |

Cada pieza: pivote en esquina inferior izquierda del lod 0 + snaps por cara (Config), validación de traslapes/huecos en Editor.

## Tipos de ruina (ensamblajes)

| Tipo | Piezas | Puzzles (M24) | Notas |
|---|---|---|---|
| Chozas/ermitas | 3-5 | 1 banda Exploración | entrada de bioma |
| Caseríos/atalayas | 8-15 | 1-2 banda Ritual | refugios, vistas |
| Templos/fortines | 25-60 | 2-3 + 1 multilateral | exigidos por lore |
| Ciudades antiguas | 3-5 bloques | 1 central | perimetral jugable |
| Observatorios | 12-20 | 1 alineación solar (M31) | domo y anillos |
| Estaciones | 6-12 | 0-1 | amarre de vehículos (M66) |
| Faros | 8-16 | 1 luz (M24) | haz visible |
| Puentes antiguos | 6-10 | 0 | arco y colgante |
| Jardines | 10-18 | 1 agua (M24) | canales y terrazas |
| Edificios abandonados | 12-24 | 0-1 | 2 plantas, balcón roto |
| Bibliotecas | 10-16 | 1 símbolos | cofre de lore |
| Talleres | 8-14 | 1 herramientas | clues de inventario |
| Cámaras secretas | 2-6 (adicionales) | 0-1 | 2+ caminos siempre |

## Murales, inscripciones y objetos arqueológicos

- **12 murales** (historia de la civilización en 3 épocas) → recompensa de descubrimiento; se registran en el diario y en M36 (museo).
- **Inscripciones (30-60 glifos)** → catálogo y glosario para M24 (familia símbolos).
- **25 objetos arqueológicos** con 3 estados: enterrado → expuesto → museo (M36); inventario de hallazgos con copia única (M66 cofre).
- Los objetos usan el "slot de vitrina" del museo; nunca se duplican.

## Sistemas de activación (8 reutilizables)

1. Palanca (cerrojo de puerta)
2. Anillo giratorio (sello de cámara)
3. Estrella giradora (puerta de templo)
4. Llave-runa (inscripción que "bebe" glifo)
5. Timón de agua (compuertas)
6. Martillo de piedra (percutir pedestal)
7. Vela triple (encender 3 velas en orden)
8. Puerta falsa (rodar a cámara secreta)

Los detalles de reglas viven en los datos de M24; aquí solo se definen los puntos de anclaje y animaciones.

## Progresión de descubrimiento (persistida)

`NoDescubierta → Descubierta → Explorada → Completada`

- **Descubierta:** al estar a 15 m (rango de render) o al ver el punto de interés en el horizonte (M63 hint).
- **Explorada:** al entrar al interior o resolver 50% de los puzzles.
- **Completada:** todos los puzzles resueltos y relicto guardado (M66 cofre) entregado.
- La transición emite eventos (diario, mapa M58, museo M36) y guarda atómico.

## Conexiones entre ruinas

- Caminos de 2-4 tramos entre ruinas cercanas (2-4 ruinas por bioma).
- Los tramos son nodos del sistema de caminos M28 y se validan con NavigationServer3D.
- Puentes antiguos conectan biomas separados (océano/ríos); faros marcan la ruta costera.

## Presupuestos

- Piezas estáticas: LOD 0-2 vía M63 (culling por región); sin simulación.
- Editor: validación de kit (pivotes, snaps, traslapes) en consola; error ⇒ no build.
- Runtime: solo transiciones de estado y eventos; cero Update por ruina (estática).