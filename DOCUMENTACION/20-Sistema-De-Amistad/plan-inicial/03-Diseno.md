**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 20: Sistema de Amistad

## 1. Arquitectura

```
                FriendshipService.gd (autoload, unica autoridad de amistad)
   ┌──────────────┬───────────────┬──────────────┬──────────────┐
   ▼              ▼               ▼              ▼              ▼
FriendshipLevel GiftEvaluator  FriendshipEvent  VecinoData   Persistencia
(Resources:   (reglas puras, (organizador de  (gustos M19,  (schema M26,
 umbrales,     gustos M19 +   reuniones,       historial,    guardar/
 recompensas)  metadatos M14) cartas, cumple)  memoria)      cargar)
   │              │               │              │              │
   └──────────────┴───────┬───────┴──────────────┴──────────────┘
                          ▼
              Logs DOM-AMISTAD (regalos, niveles, eventos)
                          ▼
              Señales: regalo_entregado / charla_realizada /
                       carta_enviada / nivel_subido / evento_celebrado
```

- **FriendshipService (autoload):** unica autoridad; conocen todos los vecinos, evalua acciones, aplica puntos, emite senales.
- **Logica pura separada de UI:** la UI (Canvas) solo suscribe senales y llama metodos publicos expuestos.

## 2. Flujos en texto

### Flujo 2.1 — Regalar un objeto
1. Jugador abre dialogo con vecino (M21) y elige "Regalar" con un objeto del Inventario (M14).
2. `FriendshipService.regalar(vecino_id, item_id)` valida limites: queda 1 regalo efectivo por dia (M29) para ese vecino.
3. `GiftEvaluator.evaluar(vecino, item)` consulta gustos de M19 y metadatos de M14; clasifica: amado / gusta / neutral / duplicado.
4. Se aplican puntos segun clase (amado maximo, duplicado minimo pero siempre > 0).
5. El objeto sale del inventario (el vecino se lo queda; se registra en memoria si era duplicado).
6. `FriendshipService` emite `regalo_entregado(vecino, item, clase, puntos)`; la UI muestra reaccion del vecino (expresion + texto M21).
7. Si los puntos alcanzaron el umbral -> `nivel_subido(vecino, nivel)` -> se entregan recompensas (recetas a M14, decorativos a inventario, frases a M21, historias a M23).

### Flujo 2.2 — Charlar
1. Jugador conversa (M21) con el vecino; el servicio registra 1 charla efectiva por dia.
2. Puntos base fijos + puntos extra segun nivel (confianza) + variantes de dialogo por nivel.
3. El vecino puede mencionar un recuerdo (primer regalo, cumpleanos) si existe en su memoria.

### Flujo 2.3 — Enviar carta
1. Jugador redacta/elige carta (buzon o escritorio) con opcion de adjuntar un objeto (M14).
2. `FriendshipService.enviar_carta(vecino, texto_id, adjunto)` registra la carta; limite diario.
3. Al dia siguiente de juego (M29) el vecino responde por correo: texto respuesta + posible objeto adjunto de retorno.
4. Puntos de la carta se aplican al entregar la respuesta (el jugador recibe la contestacion).

### Flujo 2.4 — Evento con amigos
1. `FriendshipEvent` define tipo (visita, picnic, reunion, cumpleanos, festival M73), requisitos (nivel minimo, dia/hora M29, lugar).
2. El jugador acepta/convoca el evento desde el vecino o correo.
3. Se celebran escenas breves (M21/M19) y todos los participantes ganan puntos; posibilidad de +1 regalo de cumpleanos sin contar el limite diario.
4. Registro en memoria del vecino (recuerdo conmemorativo).

### Flujo 2.5 — Subir de nivel
1. Al superar el umbral del nivel actual se congela el excedente (no se pierde).
2. Recompensas por nivel (data en FriendshipLevel): objetos, recetas, frases, acceso a eventos, contenido de M23.
3. UI muestra animacion de nivel y lista de desbloqueos pendientes por reclamar (sin FOMO: quedan en correo/bandeja si el jugador no las toma).

## 3. Contratos API GDScript (Godot 4.x)

```
# FriendshipService (autoload, clase "FriendshipService")
func get_nivel(vecino_id: String) -> int
func get_puntos(vecino_id: String) -> int
func get_puntos_para_siguiente(vecino_id: String) -> int
func get_progreso(vecino_id: String) -> float            # 0.0-1.0 en nivel actual
func get_limite_dia(vecino_id: String, tipo: String) -> Dictionary   # regalo/charla/carta
func regalar(vecino_id: String, item_id: String) -> Dictionary
func charlar(vecino_id: String) -> Dictionary
func enviar_carta(vecino_id: String, texto_id: String, adjunto_id: String) -> bool
func celebrar_evento(evento_id: String) -> Dictionary
func get_memoria(vecino_id: String) -> Array[Dictionary]  # recuerdos del vecino
func get_recompensas_pendientes() -> Array[Dictionary]    # bandeja sin FOMO
func reclamar_recompensa(uid: String) -> Dictionary
signal regalo_entregado(vecino_id: String, item_id: String, clase: String, puntos: int)
signal charla_realizada(vecino_id: String, puntos: int)
signal carta_recibida(vecino_id: String, respuesta_id: String)
signal nivel_subido(vecino_id: String, nivel: int)
signal evento_celebrado(evento_id: String, participantes: Array[String])

# FriendshipLevel (Resource)
class_name FriendshipLevel extends Resource
@export var nivel: int
@export var puntos_necesarios: int          # desde el nivel anterior
@export var nombre: String                  # Conocido, Amigo, Confidente, Mejor amigo
@export var recompensas: Array[RewardData]

# GiftEvaluator (clase estatica/util)
static func evaluar(vecino_data: VecinoData, item_meta: ItemData) -> Dictionary
# -> { clase: "amado|gusta|neutral|duplicado", puntos: int, reaccion_id: String }

# FriendshipEvent (Resource)
class_name FriendshipEvent extends Resource
@export var id: String
@export var tipo: String                    # visita, picnic, reunion, cumpleanos, festival
@export var nivel_minimo: int
@export var dia_semana: int                 # -1 = cualquier dia (M29)
@export var hora: Vector2                   # franja horaria
@export var lugar_id: String                # POI (M19/M08)
@export var puntos_otorgados: int
@export var participantes: Array[String]    # vecinos invitables
```

## 4. Reglas de balanceo (puntos, por nivel)

| Clase de regalo | Puntos | Nota |
|---|---|---|
| Amado | 20 | Regalo perfecto; provoca linea especial M21 |
| Gusta | 10 | Regalo correcto segun gustos M19 |
| Neutral | 5 | Objeto sin preferencia conocida |
| Duplicado | 2 | Cortesia; nunca 0 (sin frustracion) |
| Charla diaria | 5 + 1 por nivel (max +10) | Limite 1 por dia |
| Carta respondida | 8 | Limite 1 por dia |
| Evento (participante) | 15 | Segun FriendshipEvent |

- Umbral por nivel (curva ligera): nivel 1: 20, 2: 40, 3: 70, 4: 100, 5: 140, 6: 190, 7: 250, 8: 320, 9: 400, 10: 500.
- Con regalo amado + charla + carta el jugador sube ~1 nivel cada 2-3 dias por vecino; plausible completar los 10 niveles en 3-4 semanas de sesiones cortas.
- Excedente de puntos al subir de nivel se conserva (sin perdida).

## 5. Integracion con otros modulos

### M19 (NPC y Vecinos) — de solo lectura
- `VecinoData` expone: `gustos: Array[String]`, `disgustos: Array[String]`, `regalos_amados: Array[String]`, `personalidad: String`, `frases_por_nivel: Dictionary`, `casa/lugar_id`.
- M20 anade al vecino su estado de amistad (puntos, memoria) sin tocar la IA ni rutinas.

### M14 (Inventario)
- `ItemData` expone: `categoria: String`, `rareza: int`, `calidad: int`, `valor_oro: int`, `regalo_valido: bool`.
- El regalo se extrae del inventario (consume item) y las recompensas se insertan como objetos/recetas.

### M23 (Historias Secundarias)
- Las misiones de amistad consultan `get_nivel(vecino)` y `get_memoria(vecino)` como prerequisitos.
- Al completar historia de vecino se otorgan puntos bonus y recompensas exclusivas; el cierre de historia marca un recuerdo permanente.

### M21 (Dialogos), M29 (Reloj), M26 (Guardado), M73 (Festivales)
- M21: sustituye variables por nivel y reacciones del evaluador.
- M29: provee dia/hora para limites diarios y franjas de eventos; la pausa congela los contadores de dia.
- M26: serializa `estado_amistad.versiones` por vecino (puntos, nivel, historial de hoy, cartas, eventos, memoria).
- M73: los festivales ofrecen eventos convocables y puntos de cumpleanos sin contar limite diario.

## 6. QA

- Test M112-equivalente: regalo amado/neutral/duplicado devuelve puntos esperados; limite diario respetado; subida de nivel conserva excedente.
- Test de persistencia: guardar y cargar con puntos a mitad de nivel restaura exacto.
- Recorrido M114: 10 vecinos subidos a nivel 5+ en sesiones simuladas; sin FOMO verificado (ausencia de 30 dias no reduce nada).