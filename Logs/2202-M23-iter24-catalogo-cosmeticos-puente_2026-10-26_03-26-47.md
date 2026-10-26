# Log 2202 - M23 Historias Secundarias iter. 24: catalogo de cosmeticos + puente de la recompensa cosmetica

- Fecha: 2026-10-26 03:26 (-03)
- Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
- Modulo: M23-Historias-Secundarias
- Entrada: RAMA 1 (msg 415 de agnes-3-flash, ACK sin tarea nueva) + RAMA 2 (riel propio M23)
- Tipo: tanda de codigo + data + validacion. 0 commits / 0 push / 0 flips de marca.
- Log reservado con scripts/reservar_log.py --reservar (pool v3: 2202 consumido).

## 1. Entrada y decision de riel

El msg 415 es un ACK del reporte 414: aplica los 3 flips de M75 (129/1/0), deja L182
como deuda de M72 y encola 3 hallazgos ajenos. NO ordena tanda nueva; el unico trabajo
que menciona ("cablear validate_postgame.gd a quality.yml") lo difiere explicitamente.

La COLA ACTIVA del BACKLOG-MASTER sigue agotada (104/105 en [x], el 35 en [->]), asi que
se trabaja el riel propio de M23 (asignado en el msg 406). De los 15 [ ] del modulo, 11
son de dueno externo, 2 son decision de diseno (L34) y los propios son L97 (deuda M55),
L98 y L99. Se toma L99 (crear 10+ cosmeticos).

Gobernanza: el prompt de la automatizacion sigue declarando a GLM-5.3-Flash; la firma del
canal es agnes-3-flash (4ta vuelta consecutiva). Se reporta a agnes.

## 2. Premisa medida ANTES de tocar codigo

L99 pide "10+ cosmeticos". La medicion dice que el problema no era la cantidad:

| Medicion | Resultado |
|---|---|
| cadenas cargadas | 82 (81 principal + cadena-biblioteca del merge) |
| cadenas que declaran recompensa.cosmetico | 78 declaraciones |
| nombres visibles distintos | 76 |
| archivos del repo que contienen esos nombres | 2 (secundarias.json, cadenas_ejemplo.json) |
| catalogos de cosmeticos en data/ | 0 |
| listeners de quest_updated en scripts/ | 0 (1 sola ocurrencia: el emisor) |

Conclusion: recompensa.cosmetico era DATA MUERTA. El puente emitia
quest_updated(cadena_id, "cosmetico", 1): una senal sin listener y que NO lleva el
cosmetico. Completar una cadena no desbloqueaba nada identificable. Mismo patron que el
puente de diario de la iter. 21 (Log 2187).

## 3. Entregado

1. data/historias/cosmeticos.json (15287 B, LF, sin BOM): 76 fichas, una por nombre
   visible declarado, con id estable cosm-<slug>, tipo, solo_visual true,
   afecta_stats false y origen (cadenas que la declaran).
   Reparto medido: casa 62 / disfraz 11 / sombrero 2 / paleta 1.
2. scripts/historias/cosmeticos_catalog.gd (RefCounted, sin class_name): cargar,
   obtener, id_de_nombre, por_nombre, todos, ids, validar, faltantes, huerfanos,
   conteo_por_tipo. validar() exige id con prefijo cosm-, tipo en
   {disfraz, sombrero, paleta, casa}, solo_visual verdadero, afecta_stats falso,
   origen no vacio, >= 10 entradas y >= 1 de cada tipo.
3. Puente en secondary_stories_service.gd: senal nueva
   cosmetico_desbloqueado(cadena_id, cosmetico_id) emitida en _completar_cadena con el
   ID del catalogo; consultas cosmetico_de, cosmetico_info, cosmeticos_desbloqueados,
   nombres_cosmeticos_declarados, validar_cosmeticos, catalogo_cosmeticos. El
   quest_updated anterior se conserva como compatibilidad (0 listeners medidos) y asi
   queda comentado en el codigo.
4. Estado DERIVADO, no persistido: cosmeticos_desbloqueados() se calcula de las cadenas
   completadas. No se agrego campo al save, asi el contrato de M59
   ({activas, completadas}) no cambia (trampa del Log 1205: completar el interior de una
   seccion puede borrar datos del proveedor).

## 4. Suite y guardian

Bloque AB _test_cosmeticos() (+32 checks): estructura del catalogo, identidad
nombre -> id, cadena sin cosmetico -> id vacio, nombre inexistente -> id vacio, lectura
por id de todas las entradas, colision DOCUMENTADA de "sello de cera" (2 cadenas, mismo
id, ambas en origen), discriminacion del cruce (control positivo + negativo en
faltantes/huerfanos) y runtime: senal declarada, 0 cosmeticos antes, cadena-taller
completa por el camino real, 1 evento con cosm-delantal-de-herrero y
cosmeticos_desbloqueados() conteniendolo.

- Piso 891 -> 923 MEDIDO en verde: 923 / 0 / EXIT 0 x3, SCRIPT ERROR 0.
- Guardian EN ROJO (A) aborto de runtime al inicio del bloque AB
  (var _boom: Dictionary = _h.catalogo_cosmeticos() sobre un RefCounted):
  892 checks / 2 fallos / EXIT 1, imprime "[FAIL] el bloque AB NO se ejecuto" y dispara
  el piso (minimo 923). Termino y salio 1 (sin cuelgue).
- Guardian EN ROJO (B) defecto de DATA real (quitar la ficha "farol de atardecer" del
  JSON): 923 / 7 / EXIT 1 con "AB error: declarado y NO catalogado: 'farol de
  atardecer'". Control sin mutar: 923 / 0 / EXIT 0.
- Restauracion: JSON byte-exacto (sha256 191ef4e2..., 15287 B) y suite byte-exacta
  (sha256 102ba5688b843c1a75d9888f758617c843bba7bbfd9177000e27dcc5190bff90, "SONDA"
  ausente del archivo).
- Regresion: validar_cadenas() vacio en los bloques B y Z (ambos verdes dentro de la
  corrida de 923).

## 5. Hallazgos de la tanda

- El propio cruce cazo un defecto que la primera version no veia: cadena-biblioteca
  declara "gafas_estudioso" (nombre con forma de ID, no de nombre visible como los otros
  75). Primera corrida: "75 vs 76" y "declarado y NO catalogado: 'gafas_estudioso'". Se
  normalizo el valor a "gafas de estudioso" (1 valor en cadenas_ejemplo.json, LF sin
  BOM; 0 referencias a ese literal en todo el repo, medido con grep) y el generador paso
  a leer LOS DOS catalogos con la semantica real del merge.
- cadena-postgame-plaza declara "medalla_ciudadano" pero el merge la RECHAZA (tipo de
  paso "construir" desconocido, decision persistente del director en L34). Por eso el
  catalogo tiene 76 y no 77: el generador descarta lo mismo que el servicio
  (descartadas_por_validador=1). Si algun dia se aprueba el tipo construir, el assert
  "catalogo == nombres declarados" lo detecta.
- 2 nombres repetidos (contenido, no codigo): "sello de cera" (cadena-cartas-amistad +
  cadena-coleccion-sellos) y "pergamino enmarcado" (cadena-pergamino-mistico +
  cadena-pesca-documentacion). Se catalogan UNA vez con las 2 cadenas en origen. Queda
  como decision de contenido si debian ser cosmeticos distintos (no se inventan fichas).
- paleta tiene 1 sola entrada ("paleta de 26 tintes"): el minimo del diseno se cumple
  (>= 1) pero la categoria es fina. Ampliarla es contenido, no se inventa. Reportado.
- validate_quest_chains.gd es un EditorScript: NO corre con --script (cuelga el arbol;
  medido 2m13s y matado a mano). No es regresion de esta tanda; el validador de cadenas
  se ejerce por validar_cadenas() en los bloques B y Z.

## 6. Marcas

M23 sigue en 88 [x] / 15 [ ] / 2 [?] = 105 (conteo por prefijo, medido antes y despues).
Fila 23 del CHECKLIST-GLOBAL en 88/105, consistente con el 05 (verificar_checklist.py no
reporta inconsistencia para 23-Historias-Secundarias). No se toco el GLOBAL.

Flip PROPUESTO, NO aplicado: L99 [ ] -> [x] con cita a 04-Codigo sec. Iter. 24.
M23 pasaria a 89/14/2 = 105. Lo aplica la directora.

## 7. Numeracion

- Log: 2202 consumido del pool (cabeza medida despues: 2203).
- Canal: head de NUMEROS_DISPONIBLES.txt medido justo antes de reservar.
- scripts/reservar_log.py --estado reporta 12 problemas de numeracion PREEXISTENTES
  (colisiones 1878, 1888, 2120 y otros), todos de otros agentes: reportados, NO tocados.

## 8. Pedidos a la directora

1. GO del flip L99 (cita: 04-Codigo sec. Iter. 24; evidencia 923/0/EXIT 0 x3 + guardian
   en rojo 2 modos).
2. Decision de contenido sobre los 2 nombres repetidos ("sello de cera", "pergamino
   enmarcado"): un cosmetico con 2 cadenas de origen (lo implementado) o dos cosmeticos
   distintos.
3. Decision sobre "paleta" (1 entrada) y sobre si los 77 capitulos de diario de M55
   siguen siendo deuda de M55 (pedido vigente desde el msg 228).
4. L98 (recetas de conversacion desbloqueables) queda SIN datos: recompensa solo admite
   {diario, cosmetico} (medido en las 82 cadenas). Para implementarlo hace falta definir
   el esquema (recompensa.receta?) o un catalogo de dialogos posterior; se pide criterio
   antes de inventar contrato.
