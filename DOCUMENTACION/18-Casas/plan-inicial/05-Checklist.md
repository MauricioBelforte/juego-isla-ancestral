**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 18: Casas

## A. Requisitos del módulo (10)

- [ ] Definir el problema: casa del jugador como centro cozy de vida, almacenamiento, decoración y socialización [S]
- [ ] Registrar dependencias: M17 (construcción), M14 (inventario), M19 (NPC y vecinos), M29 (tiempo); relaciones M21, M58, M61 [S]
- [ ] Catalogar los 25 puntos de la sección 17 (CASAS) del plan maestro [S]
- [ ] RF1: sistema de parcelas con huella validada por M17 [S]
- [ ] RF2: casa del jugador construible desde el modo construcción [S]
- [ ] RF3: ampliaciones por etapas con costes y materiales [S]
- [ ] RF4: interior con habitaciones desbloqueables por etapa [S]
- [ ] RF5: almacenamiento doméstico integrado con el inventario M14 [S]
- [ ] RF6+RF7: decoración en grid y muebles interactivos [S]
- [ ] RF10+RF12: visitas de vecinos M19 y casas de vecinos del pueblo [S]

## B. Resolución de los 25 puntos del plan maestro (25)

- [ ] P1: sistema de parcelas — parcelas únicas por jugador, registradas por HouseManager [S]
- [ ] P2: casas de vecinos — parcelas del pueblo gestionadas junto con M19 [S]
- [ ] P3: casa del jugador — nodo exterior con puerta e interior instanciado [S]
- [ ] P4: ampliaciones — etapas 1 a 5 definidas en HouseUpgradeData [S]
- [ ] P5: habitaciones — prefabs por sala agregables al interior [S]
- [ ] P6: almacenamiento — muebles-contenedor con slots (HouseStorage) [S]
- [ ] P7: cocina — habitación funcional con interacción y recetas M16 [M]
- [ ] P8: taller — habitación funcional con recetas de M16 [M]
- [ ] P9: jardín — zona exterior de la casa con plantas (M33) [M]
- [ ] P10: sótano — etapa 5 como profundización con habitación extra [M]
- [ ] P11: ático — etapa 5 alternativa con cámara interior especial [M]
- [ ] P12: exteriores — modelo exterior que cambia de aspecto por etapa [M]
- [ ] P13: interiores — escenas por casa, persisten por IDs [S]
- [ ] P14: muebles interactivos — camas, sillas, lámparas, electrodomésticos [M]
- [ ] P15: camas — dormir avanza la hora según M29 y restaura energía [M]
- [ ] P16: mesas — soporte para colocar objetos encima [M]
- [ ] P17: sillas — sentarse con animación y salida [S]
- [ ] P18: lámparas — encendido/apagado e iluminación interior [S]
- [ ] P19: electrodomésticos — horno, fregadero con interacción simple [M]
- [ ] P20: objetos decorativos — celdas del grid con preview y validación [S]
- [ ] P21: objetos de pared — cuadros y colgantes en celdas de pared [M]
- [ ] P22: cuadros — decoración de pared con rotación y reubicación [S]
- [ ] P23: plantas — macetas interiores y plantas de jardín [S]
- [ ] P24: colecciones — catálogo de muebles por estilo (set completo premia) [M]
- [ ] P25: estilos de decoración — presets ancestral, floral, oceánico, cénit [M]

## C. Casa del jugador y parcelas (8)

- [ ] Validación de parcela despejada (sin voxels ni objetos encima) [M]
- [ ] Cimientos visibles con la huella de la casa en el modo construcción [M]
- [ ] Puerta exterior interactiva con prompt contextual [S]
- [ ] Registro de la casa en HouseManager al crearse [S]
- [ ] Reubicación de la casa con coste y confirmación [M]
- [ ] Reubicación con interior intacto (no se pierde decoración) [M]
- [ ] Costes iniciales equilibrados (madera, piedra) con M14 [S]
- [ ] Visual del exterior (choza, obra, etapa) coherente con el estado [M]

## D. Interior y habitaciones (8)

- [ ] Escena interior instanciada bajo demanda (portal) [S]
- [ ] Habitación base: living + dormitorio inicial [M]
- [ ] Cocina, taller, sótano y ático como prefabs reutilizables [C]
- [ ] Límite de habitaciones por etapa (tabla en HouseUpgradeData) [S]
- [ ] Cámara interior con límites por habitación (M12) [M]
- [ ] Transición de entrada/salida con fundido y carga asíncrona [M]
- [ ] Colisiones y navegación mínima interior para jugador y vecinos [M]
- [ ] Interior bloqueado mientras la casa esté en obra [S]

## E. Almacenamiento doméstico (8)

- [ ] Cofres y estanterías reutilizables con slots [M]
- [ ] Capacidad por mueble configurable en FurnitureData [S]
- [ ] Stacks y categorías respetando el contrato de M14 [S]
- [ ] Panel de transferencia sin acoplar UI-logica [M]
- [ ] Transferencia rápida de un click y por lotes [M]
- [ ] Feedback de almacenamiento lleno al recoger [S]
- [ ] Transferencia segura (sin pérdida de items en mitad de transacción) [M]
- [ ] Persistencia del contenido por mueble_id [S]

## F. Decoración y muebles (8)

- [ ] Grid fino de 0.25 bloques sobre el plano de cada habitación [M]
- [ ] Colocación con preview fantasma valido/invalido [M]
- [ ] Rotación en pasos de 90 grados [S]
- [ ] Recolocación y levantado de muebles ya colocados [M]
- [ ] Muebles de pared (cuadros, colgantes) en celdas verticales [M]
- [ ] Plantas y macetas con requisitos de superficie [S]
- [ ] Sets de colección por estilo con bonus de visita [M]
- [ ] Catálogo de estilos con presets visuales [M]

## G. Mejoras por etapas (8)

- [ ] Etapa 1: choza base con living pequeño [M]
- [ ] Etapa 2: ampliación del living y primer dormitorio [M]
- [ ] Etapa 3: cocina funcional desbloqueada [M]
- [ ] Etapa 4: taller desbloqueado [M]
- [ ] Etapa 5: sótano o ático según elección del jugador [C]
- [ ] Costes y materiales por etapa desde M14 [S]
- [ ] Requisitos de misión o amistad para etapas tardías (M21/M19) [M]
- [ ] Progreso de obra por días de juego (M29) con cartel visible [M]

## H. Visitas de vecinos (M19) (8)

- [ ] Solicitud de visita validada (casa accesible, no en obra) [S]
- [ ] Vecino instanciado dentro del interior al llegar [M]
- [ ] Vecino reacciona a la decoración (comentarios M21) [M]
- [ ] Vecino usa muebles aptos (sentarse, admirar) [M]
- [ ] Puntos de amistad calculados por valor de decoración [M]
- [ ] Visita sin bloquear la puerta (salida siempre posible) [S]
- [ ] Fin de visita ordenado (salida por la puerta, sin teletransportes raros) [M]
- [ ] Visitas coordinadas por agenda horaria M29 [S]

## I. Integraciones (M17, M14, M29) (10)

- [ ] Obra de casa iniciada mediante el patrón de construcción M17 [M]
- [ ] Materiales descontados del inventario M14 al confirmar [S]
- [ ] Objetos del hotbar M14 colocados como muebles o decoracion [M]
- [ ] Almacenamiento doméstico integrado con los stacks de M14 [S]
- [ ] Progreso de obra avanza con tick_diario de M29 [S]
- [ ] Horas de visita de vecinos respetan el reloj M29 [S]
- [ ] Iluminación interior propia (independiente del ciclo M31) [M]
- [ ] PRNG de partida M29 para preferencias y variaciones de visita [S]
- [ ] Guardado sincronizado con GameState (M58) al crear/mutar la casa [S]
- [ ] Eventos M29 (cumpleaños, festivales) generan visitas especiales [M]

## J. Edge cases (10)

- [ ] Casa en construcción: interior inaccesible con aviso [S]
- [ ] Casa en construcción: cartel de obra no bloquea el mapa [S]
- [ ] Mudanza de mueble contenedor con objetos dentro: se avisa y se intercepta el contenido [M]
- [ ] Mudanza de mueble sin contenido: se levanta directo [S]
- [ ] Reubicación con obra en curso: se cancela o se pospone con aviso [M]
- [ ] Almacenamiento lleno al recoger la producción del día: queda en el suelo protegido [M]
- [ ] Vecino en visita mientras se reubica la casa: visita cancelada con diálogo [M]
- [ ] Jugador duerme en la cama con una visita activa: la visita se despide [M]
- [ ] Ampliación con muebles en la zona de la nueva pared: se recolocan o se avisa [M]
- [ ] Sin materiales suficientes: la UI no permite confirmar y no descuenta nada [S]

## K. Optimización (6)

- [ ] Interior instanciado = cero coste de render en el mundo exterior [S]
- [ ] Grid de decoración sin allocs en el bucle de validación por frame [M]
- [ ] Culling de muebles dentro de la habitación [S]
- [ ] Guardado compacto por IDs (sin duplicar nombres ni paths) [S]
- [ ] Carga asíncrona del interior sin congelar el frame [M]
- [ ] Presupuesto de vecinos interiores: 1 visita activa a la vez [M]

## L. Polish (6)

- [ ] Fundido suave de transición con deshabilitar input (regla 8) [M]
- [ ] Sonidos de puerta, muebles y pasos interiores (M42) [S]
- [ ] Iluminación cálida interior por habitación [M]
- [ ] Musica interior diferenciada (M41) [M]
- [ ] Partículas de obra y destello al completar una etapa [S]
- [ ] Microfeedback del mueble colocado (chirrido/martillito) [S]

## M. Documentación, QA y cierre (10)

- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [ ] 03-Diseno creado y firmado (arquitectura y contratos API) [S]
- [ ] 04-Codigo creado y firmado (rutas res:// y firmas) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] API estable para consumo de M17, M14 y M19 [S]
- [ ] Test: flujo completo construir, entrar, ampliar, decorar, almacenar [C]
- [ ] Test: 3 días simulados con visitas de vecinos sin fallos [C]
- [ ] Test: mudanza de muebles contenedores sin perdida de items [M]
- [ ] Test: obra en curso sin softlocks (M66) [M]