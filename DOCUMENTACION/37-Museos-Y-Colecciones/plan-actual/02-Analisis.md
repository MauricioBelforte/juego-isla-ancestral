**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 37: Museos y Colecciones

## 1. Analisis del Dominio

En los cozy games, la coleccion es uno de los motores de progresion mas potentes porque convierte la exploracion en descubrimiento. El plan maestro pide: disenar museo, salas, vitrinas, fosiles, peces, plantas, minerales, objetos ancestrales, artefactos, documentos, mapas, coleccion de muebles/ropa, trofeos, recompensas, porcentaje completado, etiquetas, descripciones, navegacion, curaduria, exposiciones temporales, eventos, logros, secretos y descubrimientos.

El alcance establecido para M37 cubre cuatro familias de piezas: fauna avistada (M36), peces capturados (M34), fosiles y piezas de ruinas (M25) y arte ancestral. Cada familia es una exposicion que se completa, con recompensa unica por coleccion completa y registro en M55 Diario.

## 2. Dominio de Datos

- **Pieza (ExhibitData):** id unico (exposicion + indice), nombre, descripcion, procedencia, modelo/mesh voxel, icono, categoria, desbloqueable o secreta.
- **Exposicion (ExhibitionData):** id, nombre de sala, lista de piezas, recompensa (item id), porcentaje requerido (100%).
- **Registro (CollectionRegistry):** mapa exposicion-id -> piezas registradas; cuenta completada; recompensas otorgadas.
- **Slot (ExhibitSlot):** posicion espacial de exhibicion con estado libre/ocupado y pieza actual.

## 3. Alternativas Consideradas

| # | Alternativa | Ventajas | Desventajas | Decision |
|---|---|---|---|---|
| A | Colecciones solo con logros (menu/estadisticas, sin edificio) | Casi cero assets; simple | Sin lugar visitable, pierde la fantasy de "mi museo"; poco gratificante visualmente | Descartada |
| B | Museo fisico visitable con vitrinas instanciadas | Fantasy fuerte; el jugador "ve" su progreso; paseo cozy; incentiva exploracion; coherente con el plan (salas, vitrinas, curaduria) | Mas assets, escena interior, rendimiento a controlar | ELEGIDA |
| C | Tour guiado con camara fija (galeria cinematica) | Bonito, barato en IA | El jugador no camina ni interactua; rompe la agencia cozy | Descartada |
| D | Catalogo integrado solo en M55 Diario (sin museo) | Cero trabajo extra de escena | El diario pierde su rol; sin recompensa visual; duplica funcion del registro | Descartada |

## 4. Decisiones Justificadas

1. **Edificio visitable con vitrinas instanciadas (Alternativa B).** Justificacion: es la unica que cumple simultaneamente "disenar museo, salas y vitrinas" del plan, da gratificacion visual durable (el progreso se ve en el mundo) y respeta el ritmo cozy (visitar el museo es voluntario y pausado). Las vitrinas se instancian por pieza registrada para no sobrecargar la escena.
2. **Cuatro exposiciones iniciales** (fauna, peces, fosiles, arte) alineadas con las dependencias reales M36/M34/M25; el resto de familias del plan (plantas, minerales, documentos, mapas, muebles, ropa) quedan como exposiciones futuras extensibles sin cambio de arquitectura.
3. **Registro central (CollectionRegistry) como autoridad de progreso.** Justificacion: la UI, el museo y el diario consultan una unica fuente; evita desincronizacion entre vitrinas visibles y porcentaje.
4. **DonationService como servicio de validacion y consumo.** Justificacion: separa la logica de negocio (propiedad, duplicado, sala) de la escena; cualquier UI futura (venta, intercambio) reutiliza la validacion.
5. **Recompensa unica por exposicion + trofeo global.** Justificacion: premia el completado sin grind; el marcador "otorgada" se persiste para evitar duplicados tras guardado.
6. **Registro en M55 Diario mediante senales desacopladas.** Justificacion: el diario vive en otro modulo; M37 solo emite eventos y el diario decide como mostrarlos.
7. **Slot generico con variantes visuales** (diorama, acuario, pedestal, marco). Justificacion: un solo componente logico con skin por familia; menos codigo y pruebas, facil extension a nuevas exposiciones.
8. **Persistencia atomica.** Justificacion: una donacion o recompensa se escribe completo o no se escribe; evita guardados corruptos en el momento exacto del cierre.

## 5. Riesgos y Mitigaciones

| Riesgo | Impacto | Mitigacion |
|---|---|---|
| Muchas vitrinas instanciadas a la vez | Rendimiento | Instanciar solo piezas registradas; culling de salas; LOD en modelos |
| Duplicados por doble confirmacion | Integridad | Clave unica (exposicion + id) + validacion antes y despues del consumo |
| Desincronizacion registro vs vitrinas | Experiencia | Registry como fuente unica; reconstruccion de vitrinas al cargar |
| Recompensa duplicada tras guardado | Economia | Marcador persistido "otorgada"; entrega de recompensa idempotente |
| Acuario pesado (nado de peces) | Rendimiento | Nado simplificado con splines; sin fisicas por pez |
| Fondos sin restaurar (M39) | Flujo | Museo usable desde el inicio; restauracion agrega salas nuevas, no bloquea las base |

## 6. Alcance y No-Alcance

- **Alcance:** edificio, 4 exposiciones, donaciones, recompensas, registro en diario, persistencia, UI de progreso, vitrinas con inspeccion.
- **No-alcance (futuro, extensible):** exposiciones temporales con eventos (M73), secretos ocultos, curaduria por estaciones, coleccion de muebles/ropa/documentos, restauracion progresiva del edificio (M39). La arquitectura los soporta sin cambios estructurales.