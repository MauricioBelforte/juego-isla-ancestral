**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 77: Online y Red

## 1. Archivos Involucrados

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `net_contract.json` | `Assets/_Project/Data/Net/` | Manifiesto técnico (máquina) | Prototipo de diseño (sin editor Godot) |
| `validate_net_contract.gd` | `Assets/_Project/Editor/` | Validación de coherencia | Prototipo de diseño (sin editor Godot) |

**Sin código de runtime de red en v1** (decisión M76): cero sockets, cero puertos. El módulo es contrato + verificador.

## 2. Funciones Clave

### 2.1 `validate_net_contract.gd` — Validación de coherencia

| Método | Propósito |
|---|---|
| `check_coherencia_m76()` | `topologia` == "cliente-servidor-dedicado"; `p2p` == false |
| `check_chat()` | `chat_texto_libre` == false (cozy) |
| `check_presupuesto()` | `presupuesto_kbps_por_jugador` <= 64 |
| `check_sesion()` | `reconexion_segundos` <= 10 |
| `check_backups()` | `rpo_min` <= 15 y `rto_horas` <= 2 |
| `check_hit()` | `hit_apertura_downloads` coincide con `mp_contract.json` (M76) |

### 2.2 `net_contract.json` — Manifiesto

```json
{
  "topologia": "cliente-servidor-dedicado",
  "p2p": false,
  "autoridad": "servidor",
  "snapshot_hz": 10,
  "buffer_interpolacion_ms": 150,
  "prediccion": true,
  "presupuesto_kbps_por_jugador": 64,
  "token_jwt_min": 15,
  "reconexion_segundos": 10,
  "tls": "1.3",
  "ccu_por_instancia": 200,
  "rpo_min": 15,
  "rto_horas": 2,
  "chat_texto_libre": false,
  "hit_apertura_downloads": 10000
}
```

## 3. Fragmento de Núcleo (prototipo de diseño — solo validación)

```gdscript
# validate_net_contract.gd — verificador del contrato de red (M77)
extends Node

## Verifica coherencia con el manifiesto de producto (M76).
func check_coherencia_m76() -> Array[String]:
    var problemas: Array[String] = []
    var net := _load_json("res://Assets/_Project/Data/Net/net_contract.json")
    var mp := _load_json("res://Assets/_Project/Data/Postgame/mp_contract.json")
    if net["topologia"] != "cliente-servidor-dedicado":
        problemas.append("topologia debe ser cliente-servidor-dedicado")
    if net["p2p"] != false:
        problemas.append("p2p debe ser false (online); local no usa red")
    if net["chat_texto_libre"] != false:
        problemas.append("sin texto libre en el cozy")
    if net["hit_apertura_downloads"] != mp["online_hit"]:
        problemas.append("hit de apertura inconsistente con M76")
    return problemas

func _load_json(ruta: String) -> Dictionary:
    var texto := FileAccess.get_file_as_string(ruta)
    return JSON.parse_string(texto) if texto else {}
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

Sin editor/binary Godot en el entorno: el verificador es **prototipo de diseño**; la ejecución (parse de JSON + validación) queda para el entorno destino. Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- M77 **no modifica NINGÚN módulo**: es contrato + verificador de coherencia.
- El núcleo single-player no abre sockets: la FASE ONLINE se implementa como capa nueva cuando M76 la autorice.

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 76 "ONLINE Y RED" (23 ítems).
- TABLA GLOBAL: ID 77 — Online y Red (depende de 76). Desfase = +1.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Completado (contrato de arquitectura; implementación BLOQUEADA por M76)

### Lo que hice
- Documenté el contrato de red completo (23 puntos del plan maestro): cliente-servidor dedicado elegido sobre P2P, snapshot @ 10 Hz por área, interpolación + predicción, reconexión con JWT, anti-trampas por autoridad, seguridad API, telemetría (M64), escalabilidad, backups (M65) y costes (~$230-370/mes con hit >10k descargas).
- Entregué `net_contract.json` (manifiesto técnico) y `validate_net_contract.gd` (coherencia con M76).
- Cero código de runtime de red en v1 (sin puertos abiertos).

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Implementación de red (ninguna): BLOQUEADA por M76 (hit >10k descargas no alcanzado).
- `[?]` Sin editor Godot ni build: `validate_net_contract.gd` no se ejecutó (JSON parse para entorno destino).
- `[?]` Costes de servicios de hosting: estimaciones de referencia (región us-east-1); cotizaciones reales al abrir la fase.
- `[?]` Regla de reconciliación offline→online (save local vs servidor) definida a alto nivel ("servidor gana en multi, local en single"); pendiente de decisión al implementar M59-MP.

### Intentos fallidos / decisiones
- Descarté P2P para online (NAT, host offline, trampas): solo local (M76).
- Descarté rollback netcode y state-sync de deltas: sobre-ingeniería para un cozy (snapshot + interpolación basta).

### Recomendaciones para el próximo agente
- No abrir M77-MP sin el hit de M76; el manifiesto `net_contract.json` es la fuente de verdad técnica.
- Al implementar, empezar por el canal reliable (inventario/economía) y después snapshots unreliable.
- El `validate_net_contract.gd` debe correrse en CI junto con el de M76 (ambos son baratos).