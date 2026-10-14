# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """
### 2.1.1 Definicion del bioma Aurora (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 2 del `05-Checklist.md` (Primer bioma — Aurora) con lo que ya existe en disco
mas la definicion de lo que faltaba. Regla: donde un modulo dueno ya tiene el sistema, la
definicion se apoya en el; donde no existe, se define aqui y queda marcado el dueeno.

**Geografia (5 sectores, definidos):**

| Sector | Ubicacion | Contenido | Modulos |
|---|---|---|---|
| Costa E | borde este | Puerto y muelle de salida a Coral | M28/M67 |
| Pradera central | centro | Pueblo, plaza, talleres, tienda | M17/M39/M53 |
| Bosque W | oeste | Lena, setas, fauna de bosque | M09/M50/M36 |
| Colina N | norte | Templo de Brisa en la cima | M26/M24/M13 |
| Acantilados S | sur | Faro y mirador | M09/M42 |

**Area navegable: ~2 km2** (definida; limite mar-tierra por el nivel de mar de M51).

**6 zonas de streaming (M63):** Costa-E, Pradera, Bosque-W, Colina-N, Acantilados-S y Puerto
(transicion). Base real: `scripts/stream/stream_manager.gd` con suite M63 (6 iteraciones de test).

**POIs por sector (definidos):** muelle (Costa-E), plaza + talleres + tienda (Pradera), mina
(Bosque-W, ver M35), templo (Colina-N), faro (Acantilados-S). Sin catalogo de POIs en disco
todavia: la definicion queda aqui y su implementacion es de M22/M64.

**Vegetacion (M50, con respaldo real en `data/vegetacion/vegetacion_config.json` v2):** palmeras
(3 tipos en playa), bambu (`canas_bambu` en ribera), pasto alto (`hierba_alta` en pradera y
cercanias). **Hibisco: no existe con ese nombre** — los equivalentes son `flor_isla` y
`arbusto_floral`; queda anotado como deuda de nombrado de M50.

**Litoral pescable (M51/M34):** el sistema de pesca existe (`scripts/fishing/`, spots con
`bioma` informado por M51) y el agua es de M51; la definicion de que todo el litoral de Aurora es
pescable queda aqui, sujeta a que M51 integre los voxels de agua (stub `es_agua_pescable()`
documentada en M34).

**Flora transmisora de estado (M09):** flora registrada existe (`baya_roja` en el registro del
museo M37); la definicion de que la flora de Aurora transmite estados (ej. baya = energia)
requiere el catalogo de M09, que no esta en disco. **Queda `[ ]` con esa nota.**

**Puntos de descanso / cama (M11/M18):** camas existen como muebles
(`data/houses/cama_madera.tres`, catalogo M18); la definicion de los puntos de descanso de Aurora
(mas uno en la Pradera y uno en el Puerto) queda aqui. Implementacion: M18.

**Ciclo dia/noche (M31):** el modulo M31 existe (`DOCUMENTACION/31-Ciclo-Dia-Noche`) y el
`TimeCalendar` es autoload; Aurora usa el ciclo global sin variacion propia. **Definicion:**

**Clima base (M32):** tropical suave — sin datos de clima en disco (`data/clima/` no existe); la
definicion (lluvia ligara ocasional, sin tormentas salvo evento) queda aqui para que M32 la
consuma. **Queda `[ ]` hasta que M32 tenga datos.**

**Fauna inicial (M36, con respaldo real en `data/fauna/catalog.json`, 7 especies):** aves —
`gaviota_playera` (playa), `lechuza_bosque` (bosque), `halcon_montana` (montana) — visibles en
Aurora. **Peces costeros: no estan en el catalogo de fauna** (son del sistema de pesca M34,
`data/balance/fishing.json`); quedan como deuda de catalogo de M36.
"""

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t.rstrip("\n") + "\n" + seccion)
print("seccion 2.1.1 agregada a 03-Diseno.md")
