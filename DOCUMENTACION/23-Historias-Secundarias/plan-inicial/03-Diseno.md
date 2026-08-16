# 03 — Diseño — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Esquema de cadena (datos, validado)

```yaml
id: cadena-faro
titulo: "El Faro de las Memorias"
contexto: "El farero recuerda la noche del eclipse; quiere encender el faro una vez más"
pasos:
  - id: p1  tipo: hablar       npc: farero   condicion: estado_mundo.faro_apagado
  - id: p2  tipo: explorar     lugar: faro    requisito: mejor_interior
  - id: p3  tipo: puzzle       ref: M25-faro-linterna
  - id: p4  tipo: entregar     objeto: farol_cargado
recompensa: { diario: "capitulo-faro", cosmetico: "farol de atardecer" }
consecuencia: estado_mundo.faro_encendido = true
dialogo_posterior: "farero_final"
oculta: false
postgame: false
```

- **Validador:** `contexto` no vacío (anti-repetición), `pasos >= 3`, referencias a NPC/lugares/objetos reales, requisitos alcanzables (M66), recompensa y consecuencia únicas.

## Catálogo (60 cadenas)

| Tipo | Cantidad | Ejemplos |
|---|---|---|
| Vecinos | 8 | panadera, farero, doctora, carpintero, tejedora, pescador, guarda, alquimista |
| Lugares | 6 | faro, biblioteca, jardines, plaza, molino, cofradía |
| Ruinas | 4 | biblioteca quemada, observatorio, estación, puente |
| Objetos | 6 | relicto, gema, carta, llave, farol, brújula |
| Familias | 3 | molinera, pescadores, guardas |
| Comerciantes | 3 | rutas y secretos (M37) |
| Estacionales | 4 | siembra, vendimia, marea, eclipse (M32) |
| Secretas (ocultas) | 5 | desbloqueadas por mundo |
| Exploración | 8 | brújula, fauna (M65), cronitado de ruinas |
| Construcción | 6 | puentes (M28), cofradía, plaza, senderos, kiosko, jardín |
| Agricultura | 5 | invernadero, cruces de semillas, variantes M32 |
| Pesca | 4 | peces-trofeo (M36), documentación y suelta |
| Colección | 6 | murales, glifos, sellos decorativos, minerales, peces, plantas (M36) |
| Amistad | 6 | regalo favorito, sentadilla de pesca, paseos, ficción |
| Investigación | 5 | faro, biblioteca, geodesia, mapas |
| Puzzles | 6 | templos 24/25/26, ruinas con puzzles ocultos |
| Postgame | 4 | reconstrucción, memorial, epílogo del poblado |

## Recompensas y consecuencias

- **Narrativas:** 20 capítulos de diario (desbloqueo bajo condición), recetas de conversación (diálogos posteriores).
- **Cosméticas:** 10+ disfraces/sombreros/paletas de casa; nunca stats (visión cozy).
- **Consecuencias (12):** faro encendido, jardín florecido, taller abierto, plaza decorada, puente cruzable, cofradía activa, kiosko abierto, molino funcionando, estación reparada, biblioteca iluminada, camino al faro despejado, puerto ampliado.
- Cada consecuencia cambia el mundo visualmente y desbloquea diálogos posteriores (guardado por NPC + estado de mundo).

## Misiones ocultas y postgame

- **Ocultas (5):** sin marcador en el mapa hasta el primer paso; se descubren por pistas del mundo (M22) o al leer un objeto.
- **Postgame (4):** tras el final de M22 (cualquier final, con variantes por elección): reconstrucción de la plaza, memorial del Sello, epílogo de la aldea y epílogo del guardián (final secreto).

## Anti-repetición (regla dura)

- El schema exige `contexto` narrativo; prohibido `recoge N` genéricos.
- Validación en Editor/CI: si una cadena carece de contexto o repite el mismo patrón 1-1 sin variación, falla.

## Integración

- **M68 (misiones):** cada cadena se registra como conjunto de objetivos; M68 evalúa.
- **M22:** los hooks de consecuencia siguen al estado del mundo; el postgame depende del final elegido.
- **M32:** las cadenas estacionales varían con las estaciones.
- **M36:** el museo alimenta misiones de colección (minerales, peces, murales).
- **M37:** los comerciantes ofrecen misiones; recompensas en especie (nunca duplicadas — M66).
- **M66:** todo requisito y referencia es verificable (sin softlocks de cadena).

## QA

- Suite: validador de cadenas (contexto, referencias, alcanzabilidad), recorrido E2E de 10 cadenas, consecuencias aplicadas y persistidas, recompensas únicas, postgame tras cada final (4 variaciones).