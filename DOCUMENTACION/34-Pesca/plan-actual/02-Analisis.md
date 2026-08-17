**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Modulo 34: Pesca

## 1. Analisis del Dominio

La pesca es un pilar cozy del proyecto (seccion 33 del plan maestro): debe ser relajante, permitir sesiones cortas, recompensar la observacion (estacion/hora/clima) y alimentar coleccion y economia sin presion. En un mundo voxel la dificultad tecnica esta en validar donde hay "agua pescable" (M51) y en mantener el sistema desacoplado de la UI y de los sistemas de tiempo (M29), ciclo (M31) y clima (M32).

## 2. Alternativas Consideradas

### Alternativa A — Timing puro estilo Animal Crossing (3 pulsaciones)
El flotador se hunde y el jugador pulsa el boton 3 veces con ventanas generosas; el pez escapa solo si falla todo.
- **Ventajas:** probado, relax, skill suave, familio para el genero.
- **Desventajas:** requiere aprendizaje inicial; jugadores novatos o con reflejos lentos pueden frustrarse si las ventanas son justas.

### Alternativa B — Captura automatica (espera y recepcion)
El jugador lanza, espera y el pez se captura solo.
- **Ventajas:** cero frustracion, perfecto para accesibilidad; minimo contenido de UI.
- **Desventajas:** sin agencia ni momento de triunfo; el "juguete" pierde engagement en sesiones largas.

### Alternativa C — Barra de esfuerzo tipo Stardew
Rellenar una barra que baja sola; el pez escapa si la barra se vacia.
- **Ventajas:** skill probada; recompensa el dominio.
- **Desventajas:** tension y estres; castiga el fallo; contradice la regla cozy del proyecto (M32: "bono si, bloqueo no").

### Alternativa D — Timing suave en 2 fases con tolerancia (ELEGIDA)
Fase 1: respuesta a la picada (pulsar cuando el flotador se hunde, ventana amplia). Fase 2: mantener/minipulsaciones con ventana por caña. El fallo solo hace que el pez huya; relanzado inmediato; la caña mejora ventana y reduce espera (nunca bloquea especies).
- **Ventajas:** equilibrio entre agencia y relax; anti-frustracion verificable; escalable por cañas y cebos.
- **Desventajas:** sigue exigiendo reflejos; mitigado con modo captura automatica (accesibilidad) y con ventanas que se amplian por caña.

### Alternativa E — Duelo de fuerza (estilo combate de pesca)
- **Desventajas decisivas:** asemeja combate (regla del proyecto: sin combate obligatorio), estresante y contradictorio con la vision cozy. Descartada.

## 3. Decisiones Justificadas

| # | Decision | Justificacion |
|---|---|---|
| D1 | Molde de juego D (timing suave 2 fases) + modo B opcional (captura automatica) | Maximo relax con agencia; el modo automatico cubre accesibilidad (M57) sin tocar la experiencia principal |
| D2 | Fallo = huida sin penalizaciones | Regla anti-frustracion central: no se pierden items, ni dinero, ni progreso; el relanzado es 1 clic |
| D3 | Espera de picada max 8 s sin cebo (rango 2-8 s) | Evita momentos muertos tediosos; el cebo reduce la espera (multiplicador) |
| D4 | Canas mejoran ventana y reducen espera; nunca bloquean especies | Progresion suave y no exclusiva; ninguna especie queda atrapada detras de equipo raro |
| D5 | Cebos = multiplicadores de probabilidad y espera, no exclusividad | Un pez raro siempre es pescable sin cebo (probabilidad baja); el cebo solo lo facilita; coherente con "bono si, bloqueo no" |
| D6 | Rarezas con distribucion ponderada por PRNG M29 | Comun 60%, poco comun 25%, raro 10%, legendario 4%, ancestral 1% (pesos ajustables en FishDefinition); determinismo por partida |
| D7 | Tablas por franjas horarias M31 (ALBA/DIA/ATARDECER/NOCHE/PROFUNDA) | Integra el ciclo M31 sin reacondicionarlo: cada especie declara franjas activas |
| D8 | Clima M32: bono de probabilidad segun clima (p.ej. lluvia + lluvia de peces calamar); cero bloqueos | Coherente con la regla de oro del clima M32 (bono si, bloqueo no) |
| D9 | Validacion de agua por voxels M51 (tipo AGUA + aire encima + orilla accesible), no por colliders | Mundo procedural voxel: la geometria de agua es voxel; los colliders de carga parcial no son confiables |
| D10 | Spots registrados por chunk y pooling | Escalable al streaming de chunks M51: los spots entran/salen con el chunk |
| D11 | Piezas opcionales para M37 (pez estatua, pez ancestral, catalogo) | El museo es objetivo secundario: duplicados no aceptados pero vendibles, sin frustracion |
| D12 | Pez como item M14 con calidad opcional | El pescado entra al inventario como objeto (venta, recetas, entrega M37) con sistema unico de ítems |
| D13 | Enciclopedia/registro y estadisticas siempre visibles | Recompensa la observacion (coleccionar por estacion/hora/clima) sin FOMO |

## 4. Analisis por Punto del Plan (seccion 33)

- **Especies/biomas:** agua dividida en biomas voxel: mar costero, rio, laguna, pozo ancestral (agua dulce vs salada); ~25 especies base.
- **Horarios/estaciones/clima:** franjas M31 + estaciones M29 (4 estaciones de 84 dias) + 9 climas M32; peces nocturnos (solo NOCHE/PROFUNDA) y estacionales (solo 1-2 estaciones).
- **Rareza/cebos/canas:** pesos PRNG; 4 cebos (gusano, pan, insecto, cebo dorado) y 3 canas (vieja, madera ancestral, caña de deidad).
- **Minijuego libre de frustracion:** 2 fases indulgentes; ventanas: caña vieja 0.35 s, madera 0.50 s, deidad 0.70 s; reloj del minijuego pausable con GameClock.
- **Animaciones/sonidos/VFX:** detalle cozy (splash, ondulaciones, brillo de pez raro, zoom suave) como publicable externo al system.
- **Coleccionario/museo:** registro M34 alimenta a M37; peces legendarios/ancentrales son la pieza fuerte del museo, pero opcional.
- **Recompensas/recetas/desafios/estadisticas:** pescado vendible (economia M37), recetas de coccion, desafios por catalogo completado sin obligacion.