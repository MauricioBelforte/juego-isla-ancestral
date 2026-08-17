**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 28: Viajes

## 1. Dominio del Problema

Mover al jugador entre islas (M27) requiere decidir **cómo se presenta el desplazamiento** y **qué reglas gobiernan el acceso**. El tono cozy descarta estrés, esperas largas y castigos. El Gran Vapor es el vehículo principal: un barco de vapor con horario y rutas que conecta puertos. El clima (M32) y el streaming (M63) condicionan la experiencia percibida.

## 2. Alternativas Consideradas

### A1. Travesía simulada en tiempo real (mundo continuo)
El barco es un vehículo pilotable en el mar abierto del mundo voxel; el jugador navega físicamente hasta la isla destino.
- **Ventajas:** inmersión total, coherencia total con el mundo.
- **Desventajas:** requiere mundo oceánico enorme y streaming continuo M63 muy agresivo; riesgo de aburrimiento en trayectos largos; colisiones con el agua voxel; coste alto de desarrollo y rendimiento.
- **Veredicto:** descartado como viaje principal por coste y riesgo de fricción (lo opuesto del tono cozy).

### A2. Travesía simulada corta y guionada (SELECCIONADA)
El jugador aborda el vapor; la cámara pasa a cinematográfica y el barco recorre una **ruta definida** (BoatRoute) por el mar durante 20–60 s. El jugador puede caminar a cubierta mientras el barco avanza solo; hay eventos suaves opcionales.
- **Ventajas:** espectáculo y sensación de viaje real con coste técnico bajo; el destino se precarga mediante M63 durante el trayecto (sin pantalla de carga percibida); integra clima de forma visual (olas, lluvia, niebla).
- **Desventajas:** el viaje no es libre (el jugador no controla el barco); el trayecto debe limitarse a 20–60 s para no aburrir.
- **Veredicto:** SELECCIONADA como experiencia principal. Equilibra inmersión, coste y tono.

### A3. Pantalla de carga / fade directo
El jugador compra el boleto, la pantalla se funde en negro y aparece en la isla destino.
- **Ventajas:** máximo simple, cero riesgo técnico.
- **Desventajas:** rompe la fantasía del mundo vivo; el viaje "no existe" como experiencia; pierde la oportunidad narrativa del Gran Vapor.
- **Veredicto:** descartada como única opción; se conserva únicamente como *viaje rápido* (M69), donde la instantaneidad es una característica pagada (costosa), no un atajo gratis.

### A4. Híbrido (A2 + A3 por contexto)
Travesía simulada corta por defecto; si el jugador activa la accesibilidad "travesía acelerada" (M57) o usa la habilidad de viaje rápido con "condición de regreso", se aplica fade directo.
- **Ventajas:** cubre accesibilidad y el caso nocturno repetitivo.
- **Desventajas:** dos caminos que mantener.
- **Veredicto:** ADOPTADO como complemento de A2 (no como reemplazo).

## 3. Decisiones Justificadas

### D1. Travesía simulada corta (20–60 s)
- **Justificación:** tiempo suficiente para que la isla destino termine de streamear (M63) sin que el jugador perciba carga, y breve para no volverse tedioso en viajes repetidos. La opción de accesibilidad lo reduce a la mitad.
- **Regla:** la duración se calcula con la fórmula `duracion_s = 20 + distancia_km * factor` con tope de 90 s.

### D2. Clima retrasa, nunca bloquea (M32)
- **Justificación:** el tono cozy prohíbe frustración; un vapor que "no sale por tormenta" es una barrera dura que castiga la planificación del jugador. En su lugar, el clima **retrasa** la salida o alarga el trayecto unos segundos con diálogo amable del capitán, y el trayecto se anima con olas y lluvia.
- **Regla:** retraso aleatorio de 5–15 s (PRNG M29) o extensión del 25 % de la duración; nunca impide el viaje. En caso extremo (tormenta tropical), el barco igualmente zarpa pero el retraso es mayor y la cámara muestra cielo oscuro.

### D3. Viaje rápido costoso (M69)
- **Justificación:** el viaje rápido por fade instantáneo debe ser una **mejora opcional** que el jugador paga (moneda del juego), no una mecánica gratuita que vuelva irrelevante el Gran Vapor y la travesía simulada.
- **Regla:** requisitos: haber visitado el destino al menos una vez + coste en monedas; no disponible en clima extremo (se muestra aviso).

### D4. Muelle ocupado == cola de espera, no error
- **Justificación:** dos barcos (NPC o jugador) pueden coincidir en el muelle; bloqueando la llegada se crearía un soft-lock. La regla es: el vapor espera en el agua 5–10 s (animado) hasta que el muelle se libera, o usa un muelle secundario.
- **Regla:** reserva de muelle al zarpar (HarborDock.lock()); llegada con muelle ocupado → espera con giro a la vista.

### D5. Boleto con devolución
- **Justificación:** permitir cancelar antes de zarpar sin castigo fuerte mantiene el espíritu relajado.
- **Regla:** antes del embarque → devolución del 100 %; en cubierta antes de zarpar → 50 %. El capitán confirma con diálogo.

### D6. Sin control del timón
- **Justificación:** el jugador camina a cubierta pero no pilota (coherente con un servicio de vapor con horario); evita colisiones y simplifica la ruta.
- **Regla:** movimiento a cubierta libre dentro del barco; el barco avanza por curva de BoatRoute.

## 4. Riesgos y Mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Travesía tediosa en viajes repetidos | Alto | Accesibilidad acelerada + viaje rápido M69 pagado + variar eventos de trayecto |
| Streaming tardío de la isla destino (M63) | Alto | Precarga al confirmar boleto; tiempo mínimo de travesía 20 s como colchón |
| Clima bloqueante por mal diseño (M32) | Medio | Regla dura: retraso máximo 15 s, jamás cancelación |
| Muelle ocupado generando soft-lock | Medio | Cola de espera + muelle secundario + timeout con re-anclaje |
| Guardado en medio de travesía (M58) | Medio | Estado de viaje serializable; al restaurar, el barco reaparece en el punto medio con el tiempo restante intacto |
| Doble entrada (embarque duplicado) | Bajo | Estado de viaje exclusivo + deshabilitar botones (sección 8 AGENTS.md) |

## 5. Conclusión

El sistema se construye sobre **travesía simulada corta** con el Gran Vapor como protagonista, **clima que retrasa pero no bloquea**, **viaje rápido pagado** como comodidad opcional y **reglas de cortesía** (cola de espera, devoluciones) que protegen al jugador de cualquier callejón sin salida. Esta combinación maximiza la sensación de mundo vivo con el menor coste técnico y cero fricción.