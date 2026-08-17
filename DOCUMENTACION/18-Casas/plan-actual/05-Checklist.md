**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 18: Casas

## A. Requisitos del módulo (10)

- [x] Definir el problema: casa del jugador como centro cozy de vida, almacenamiento, decoración y socialización [S]
- [x] Registrar dependencias: M17 (construcción), M14 (inventario), M19 (NPC y vecinos), M29 (tiempo); relaciones M21, M58, M61 [S]
- [x] Catalogar los 25 puntos de la sección 17 (CASAS) del plan maestro [S]
- [x] RF1: sistema de parcelas con huella validada por M17 [S]
- [x] RF2: casa del jugador construible desde el modo construcción [S]
- [x] RF3: ampliaciones por etapas con costes y materiales [S]
- [x] RF4: interior con habitaciones desbloqueables por etapa [S]
- [x] RF5: almacenamiento doméstico integrado con el inventario M14 [S]
- [x] RF6+RF7: decoración en grid y muebles interactivos [S]
- [x] RF10+RF12: visitas de vecinos M19 y casas de vecinos del pueblo [S]

## B. Resolución de los 25 puntos del plan maestro (25)

- [x] P1: sistema de parcelas — parcelas únicas por jugador, registradas por HouseManager [S]
- [x] P2: casas de vecinos — parcelas del pueblo gestionadas junto con M19 [S]
- [x] P3: casa del jugador — nodo exterior con puerta e interior instanciado [S]
- [x] P4: ampliaciones — etapas 1 a 5 definidas en HouseUpgradeData [S]
- [x] P5: habitaciones — prefabs por sala agregables al interior [S]
- [x] P6: almacenamiento — muebles-contenedor con slots (HouseStorage) [S]
- [x] P7: cocina — habitación funcional con interacción y recetas M16 [M]
- [x] P8: taller — habitación funcional con recetas de M16 [M]
- [x] P9: jardín — zona exterior de la casa con plantas (M33) [M]
- [x] P10: sótano — etapa 5 como profundización con habitación extra [M]
- [x] P11: ático — etapa 5 alternativa con cámara interior especial [M]
- [x] P12: exteriores — modelo exterior que cambia de aspecto por etapa [M]
- [x] P13: interiores — escenas por casa, persisten por IDs [S]
- [x] P14: muebles interactivos — camas, sillas, lámparas, electrodomésticos [M]
- [x] P15: camas — dormir avanza la hora según M29 y restaura energía [M]
- [x] P16: mesas — soporte para colocar objetos encima [M]
- [x] P17: sillas — sentarse con animación y salida [S]
- [x] P18: lámparas — encendido/apagado e iluminación interior [S]
- [x] P19: electrodomésticos — horno, fregadero con interacción simple [M]
- [x] P20: objetos decorativos — celdas del grid con preview y validación [S]
- [x] P21: objetos de pared — cuadros y colgantes en celdas de pared [M]
- [x] P22: cuadros — decoración de pared con rotación y reubicación [S]
- [x] P23: plantas — macetas interiores y plantas de jardín [S]
- [x] P24: colecciones — catálogo de muebles por estilo (set completo premia) [M]
- [x] P25: estilos de decoración — presets ancestral, floral, oceánico, cénit [M]

## C. Casa del jugador y parcelas (8)

- [x] Validación de parcela despejada (sin voxels ni objetos encima) [M]
- [x] Cimientos visibles con la huella de la casa en el modo construcción [M]
- [x] Puerta exterior interactiva con prompt contextual [S]
- [x] Registro de la casa en HouseManager al crearse [S]
- [x] Reubicación de la casa con coste y confirmación [M]
- [x] Reubicación con interior intacto (no se pierde decoración) [M]
- [x] Costes iniciales equilibrados (madera, piedra) con M14 [S]
- [x] Visual del exterior (choza, obra, etapa) coherente con el estado [M]

## D. Interior y habitaciones (8)

- [x] Escena interior instanciada bajo demanda (portal) [S]
- [x] Habitación base: living + dormitorio inicial [M]
- [x] Cocina, taller, sótano y ático como prefabs reutilizables [C]
- [x] Límite de habitaciones por etapa (tabla en HouseUpgradeData) [S]
- [x] Cámara interior con límites por habitación (M12) [M]
- [x] Transición de entrada/salida con fundido y carga asíncrona [M]
- [x] Colisiones y navegación mínima interior para jugador y vecinos [M]
- [x] Interior bloqueado mientras la casa esté en obra [S]

## E. Almacenamiento doméstico (8)

- [x] Cofres y estanterías reutilizables con slots [M]
- [x] Capacidad por mueble configurable en FurnitureData [S]
- [x] Stacks y categorías respetando el contrato de M14 [S]
- [x] Panel de transferencia sin acoplar UI-logica [M]
- [x] Transferencia rápida de un click y por lotes [M]
- [x] Feedback de almacenamiento lleno al recoger [S]
- [x] Transferencia segura (sin pérdida de items en mitad de transacción) [M]
- [x] Persistencia del contenido por mueble_id [S]

## F. Decoración y muebles (8)

- [x] Grid fino de 0.25 bloques sobre el plano de cada habitación [M]
- [x] Colocación con preview fantasma valido/invalido [M]
- [x] Rotación en pasos de 90 grados [S]
- [x] Recolocación y levantado de muebles ya colocados [M]
- [x] Muebles de pared (cuadros, colgantes) en celdas verticales [M]
- [x] Plantas y macetas con requisitos de superficie [S]
- [x] Sets de colección por estilo con bonus de visita [M]
- [x] Catálogo de estilos con presets visuales [M]

## G. Mejoras por etapas (8)

- [x] Etapa 1: choza base con living pequeño [M]
- [x] Etapa 2: ampliación del living y primer dormitorio [M]
- [x] Etapa 3: cocina funcional desbloqueada [M]
- [x] Etapa 4: taller desbloqueado [M]
- [x] Etapa 5: sótano o ático según elección del jugador [C]
- [x] Costes y materiales por etapa desde M14 [S]
- [x] Requisitos de misión o amistad para etapas tardías (M21/M19) [M]
- [x] Progreso de obra por días de juego (M29) con cartel visible [M]

## H. Visitas de vecinos (M19) (8)

- [x] Solicitud de visita validada (casa accesible, no en obra) [S]
- [x] Vecino instanciado dentro del interior al llegar [M]
- [x] Vecino reacciona a la decoración (comentarios M21) [M]
- [x] Vecino usa muebles aptos (sentarse, admirar) [M]
- [x] Puntos de amistad calculados por valor de decoración [M]
- [x] Visita sin bloquear la puerta (salida siempre posible) [S]
- [x] Fin de visita ordenado (salida por la puerta, sin teletransportes raros) [M]
- [x] Visitas coordinadas por agenda horaria M29 [S]

## I. Integraciones (M17, M14, M29) (10)

- [x] Obra de casa iniciada mediante el patrón de construcción M17 [M]
- [x] Materiales descontados del inventario M14 al confirmar [S]
- [x] Objetos del hotbar M14 colocados como muebles o decoracion [M]
- [x] Almacenamiento doméstico integrado con los stacks de M14 [S]
- [x] Progreso de obra avanza con tick_diario de M29 [S]
- [x] Horas de visita de vecinos respetan el reloj M29 [S]
- [x] Iluminación interior propia (independiente del ciclo M31) [M]
- [x] PRNG de partida M29 para preferencias y variaciones de visita [S]
- [x] Guardado sincronizado con GameState (M58) al crear/mutar la casa [S]
- [x] Eventos M29 (cumpleaños, festivales) generan visitas especiales [M]

## J. Edge cases (10)

- [x] Casa en construcción: interior inaccesible con aviso [S]
- [x] Casa en construcción: cartel de obra no bloquea el mapa [S]
- [x] Mudanza de mueble contenedor con objetos dentro: se avisa y se intercepta el contenido [M]
- [x] Mudanza de mueble sin contenido: se levanta directo [S]
- [x] Reubicación con obra en curso: se cancela o se pospone con aviso [M]
- [x] Almacenamiento lleno al recoger la producción del día: queda en el suelo protegido [M]
- [x] Vecino en visita mientras se reubica la casa: visita cancelada con diálogo [M]
- [x] Jugador duerme en la cama con una visita activa: la visita se despide [M]
- [x] Ampliación con muebles en la zona de la nueva pared: se recolocan o se avisa [M]
- [x] Sin materiales suficientes: la UI no permite confirmar y no descuenta nada [S]

## K. Optimización (6)

- [x] Interior instanciado = cero coste de render en el mundo exterior [S]
- [x] Grid de decoración sin allocs en el bucle de validación por frame [M]
- [x] Culling de muebles dentro de la habitación [S]
- [x] Guardado compacto por IDs (sin duplicar nombres ni paths) [S]
- [x] Carga asíncrona del interior sin congelar el frame [M]
- [x] Presupuesto de vecinos interiores: 1 visita activa a la vez [M]

## L. Polish (6)

- [x] Fundido suave de transición con deshabilitar input (regla 8) [M]
- [x] Sonidos de puerta, muebles y pasos interiores (M42) [S]
- [x] Iluminación cálida interior por habitación [M]
- [x] Musica interior diferenciada (M41) [M]
- [x] Partículas de obra y destello al completar una etapa [S]
- [x] Microfeedback del mueble colocado (chirrido/martillito) [S]

## M. Documentación, QA y cierre (10)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado (alternativas y decisiones) [S]
- [x] 03-Diseno creado y firmado (arquitectura y contratos API) [S]
- [x] 04-Codigo creado y firmado (rutas res:// y firmas) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] API estable para consumo de M17, M14 y M19 [S]
- [x] Test: flujo completo construir, entrar, ampliar, decorar, almacenar [C]
- [x] Test: 3 días simulados con visitas de vecinos sin fallos [C]
- [x] Test: mudanza de muebles contenedores sin perdida de items [M]
- [x] Test: obra en curso sin softlocks (M66) [M]