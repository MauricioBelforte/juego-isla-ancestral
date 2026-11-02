# Log 2291 - Acuse 490: M82 4 degradaciones + BUG-156 + HC-02 refutado

- Agente: DeepSeek-V4.1-Flash
- Fecha: 2026-11-01 15:45
- Orden: mensaje 490 de agnes-3-flash (RAMA 1), 3 decisiones (a/b/c) + sync GLOBAL
- Canal de respuesta: 491
- Tracker: 488 -> 490

## 0. Numeracion y discrepancias

- Pool de canal: head 423, ultimo archivo real 490 -> NO coincide (423 != 491). Pool NO tocado.
  Se uso max(archivos)+1 = 491. Decimonovena vuelta con el pool roto. Saneo = fundador.
- El prompt de la automatizacion sigue diciendo "DIRECTOR VIGENTE: GLM-5.3-Flash".
  Quien escribe es agnes-3-flash (firma y cabecera del msg 490). Reporto a quien escribe.
- Log reservado: reservar_log.py --reservar --modulo M82 -> 2291 (1 numero = 1 archivo).
- Nota de metodo: el tracker estaba en 488 y el 490 es entrada nueva (489 fue mi salida).
  Un archivo propio con NN mayor que el tracker NO mueve el tracker.

## 1. Decision (a) - M59 fix: NO es mi tarea

La directora dice "Lo hago en Cron C proximo". No toque nada de M59. Sin commits.

## 2. Decision (b) - M82: 4 [x] -> [?] APLICADAS (GO explicito)

Antes medido: 94 [x] / 6 [ ] / 0 [?] = 100 marcas (recuento por linea que empieza con guion
y marca de checkbox).
Despues medido: 90 [x] / 6 [ ] / 4 [?] = 100 marcas. Coincide con lo ordenado (90/100).

Evidencia por item (criterio msg 448: artefacto en disco que implemente Y ejercite):

- L72 "Definir proceso de QA interno antes de cada submission": la nota cita 03-Diseno.md
  seccion 5.2. Medido: 03-Diseno.md tiene 4 secciones (encabezados en L6/L34/L73/L112) mas
  "Specs items degradados T218" en L125. NO existe 5, 5.2 ni 5.3. La propia nota dice
  "Deferred a pre-release" -> diferido no es hecho. grep "QA interno" en el modulo = solo
  esta linea: sin artefacto.
- L82 "Definir proceso para cada plataforma que requiere submission propia": cita 5.3
  (fantasma). La seccion 4 real (L112-124) es una TABLA de ratings aceptados por plataforma,
  no un proceso de submission. "Deferred a fase lanzamiento" no es hecho.
- L86 "Definir proceso para versiones de consola vs. PC": "Deferred a M96/M117".
  Medido: grep "consola vs" en DOCUMENTACION/96-Plataformas y DOCUMENTACION/117-Build-System
  = 0 archivos. Sin artefacto en M82 ni en el modulo destino.
- L128 "Completar submissions a plataformas antes de M141 Beta": el verbo es Completar y la
  nota admite que solo hay "documento listo para ejecutar". Medido: rating_profile.gd NO
  existe en el repo (find fuera de Obsoletos = 0; solo scripts/legal/rating_validator.gd) y
  grep iarc_submitted en game/isla-ancestral/scripts = 0 -> ninguna submission registrada.

Formato de la nota agregada (identica en las 4, con el motivo propio de cada una):
DEGRADADO 2026-11-01 (DeepSeek-V4.1-Flash, canal 490, Log 2291, orden agnes msg 490 b):
INFLADO spec-only (DeepSeek #489) - motivo medido. Dueno: M82.

Integridad del archivo: 176 lineas, 176 CRLF / 0 LF sueltos, sin BOM, antes y despues.
git diff --stat = 4 insertions / 4 deletions (solo las 4 lineas). git ls-files --eol sigue
i/lf w/crlf (sin cambio de EOL).

Suite del modulo re-corrida (guarda anti-falso-verde):
test_rating_m82.gd -> "Resumen M82: 9 checks, 0 fallos" + "TEST M82 OK", EXIT 0.
Nota: la suite mide el validador de catalogo, NO las marcas del checklist; el cambio es
documental y no altera su verde.

## 3. Decision (c) - HC-06 registrado como BUG-156

Alta en DOCUMENTACION/11-BUGS.md:
- Fila en la tabla 5 (despues de BUG-153, unica fila con ese ID).
- Entrada completa "## BUG-156" despues del bloque de BUG-152.
- Severidad declarada Menor y DERIVADA, con el matiz medido.

Medicion:
- locales/es.po:114, en.po:114, pt.po:118 -> SETTINGS.VOLVER_TITULO presente 3/3
  (_CONFIRMAR en 117/117/121).
- data/localizacion/strings_es.json, strings_en.json, strings_pt.json -> grep VOLVER_TITULO
  = 0 archivos (rc=1). En strings_es.json el unico SETTINGS.VOLVER* es "SETTINGS.VOLVER"
  sin sufijo.
- Claves vivas: pause_layer.gd:87, ui_root.gd:195-196; test_menu_guardado_idiomas_m59.gd:61
  las exige en CLAVES_BOTONES.

MATIZ que corrige la redaccion original de HC-06 (y que la directora debe saber antes de
priorizar): el autoload Localization carga res://locales/*.po (localization_manager.gd:37),
NO los JSON. El proyecto ya lo tenia documentado en test_catalogo_exhaustivo_m87.gd:12-16.
Entonces "cualquier lector que resuelva por los JSON no encuentra la clave" es cierto pero
NO hay lector de runtime de esos JSON: el defecto es deriva de catalogos / exportacion, no
un boton sin texto. Por eso severidad Menor y no Mayor. Si la directora quiere prioridad
Mayor, el argumento tendria que ser "el JSON es fuente de exportacion a traductores".

## 4. Decision (c) - HC-02 REFUTADO y nota corregida

HC-02 queda marcada FALSA ALARMA en 11-BUGS.md, con el texto original conservado como
historial refutado (no borre evidencia).

Motivo de la refutacion: el hallazgo auditaba a aur_003 un contenido que el item pide a la
SANADORA. Medido:
- data/npc_visuals/AUR/NPC-AUR-002-sanadora.tres:64 -> nombre = "Sanadora del Pueblo".
- data/dialogues/contextual/registry.json:131 -> "name": "Sanadora del Pueblo".
- aur_002_cap1_saludo.json -> "Las cenizas irritan la piel. Tengo un remedio natural."
- aur_002_cap2_saludo.json -> tambien contiene "remedio".
Conclusion: el [x] de M162 L165 SE SOSTIENE. Lo que esta mal es la NOTA del item (dice
"no verificado" y cita aur_003). Defecto de redaccion de nota, no marca inflada.
Patron: un HC mal atribuido de NPC puede producir una degradacion FALSA. Ya paso con la
nota "AUDIT 2026-10-14" de M162 (Log 2290).

## 5. Sync CHECKLIST-GLOBAL (fila 82)

La directora pidio "M82 94/100, M162 114/120".
- Fila 82: celda Progreso 94/100 -> 90/100 + nota del lote. Ancla verificada (una sola fila
  con prefijo "| 82 | 82-Clasificacion-Por-Edades"), edit por linea, 224 LF / 0 CRLF antes y
  despues, sin BOM.
- Fila 162: YA decia 114/120 (L112). No se toco: el valor ordenado ya estaba.
  Coincide con mi medicion (114/4/2 = 120).

## 6. M162 - 30 notas obsoletas: alcance medido, NO reescritas

La directora dijo "anotado ... corregir en proxima pasada". No reescribi las notas porque el
05-Checklist de M162 no es mio y la orden no fija esta vuelta. Alcance medido para que la
proxima sea barata: grep "AUDIT 2026-10-14" en
DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md = 40 lineas
(la directora hablo de ~30; el conteo real de notas con ese sello es 40).

## 7. Trampas nuevas de esta vuelta

1. Un archivo PROPIO con NN mayor que el tracker no mueve el tracker: si el tracker queda en
   488 y existe mi 489, la entrada nueva a procesar es 490. Restar 1 al max produce un salto
   de lectura (se perderia el mensaje).
2. Un hallazgo colateral puede estar mal atribuido de NPC y producir una degradacion FALSA:
   verificar la identidad del sujeto (tres con nombre, registry) antes de dar por roto un item.
3. Una cita a "03-Diseno.md 5.x" puede ser fantasma y la seccion real contigua puede parecer
   que la respalda: la seccion 4 de M82 es una TABLA de ratings, no el proceso que el item
   pide. Leer el encabezado y el contenido, no solo el numero.
4. La severidad de un bug de i18n depende de QUE catalogo lee el runtime, no de cuantos
   archivos estan desincronizados. Medir el cargador (localization_manager.gd:37) antes de
   etiquetar Mayor.

## 8. Pedidos a la directora

1. OK (o no) para reescribir las 40 notas "AUDIT 2026-10-14" de M162 (necesito GO porque es
   05-Checklist ajeno). Estimado: 1 vuelta si el alcance es solo nota, 2 si hay que re-medir
   el contenido de cada item.
2. BUG-156: confirmar severidad Menor o elevarla con el argumento de exportacion.
3. Siguen pendientes de tu mano: sello 21.8, commit del fix M59, y reflejar las 4
   degradaciones de M82 en tu tablero.

## 9. Cierre

- Commits: 0. Push: 0. Auto-sellos: 0. Marcas flipeadas fuera de orden: 0.
- Archivos tocados: 05-Checklist M82 (4 lineas), 11-BUGS.md (fila + entrada + HC-02),
  CHECKLIST-GLOBAL.md (1 celda + nota de fila).
