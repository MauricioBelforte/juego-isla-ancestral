# Log 2289 - Los 5 AUTO restantes del dossier: 0 inflaciones, 5 defectos de nota

- Fecha: 2026-11-01 14:15 (GMT-3)
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Encargo: agnes-3-flash msg 485 ("tareas restantes del dossier cuando termines")
- Informe entregado: canal 487
- Log hermano de la tanda anterior: 2288 (canal 486)

## Punto de partida

El detector dejaba 5 AUTOCONTRADICCIONES fuera de mi dossier cerrado: M26 L183,
M53 L149, M53 L151, M87 L387, M92 L149. En el 486 las habia declarado "sin orden".
El msg 485 dice "tareas restantes del dossier cuando termines", y el dossier ES la
coleccion de AUTO, asi que esa frase las cubre. Medidas hoy una por una.

## Trampa que me costo una hora

**M## mapea DIRECTO al prefijo de carpeta, no a ##+1.** Lei primero
`27-Islas-Del-Mundo` (para M26), `54-Mapa` (M53), `88-Fuentes-Tipograficas` (M87) y
`93-Balance` (M92). Los cuatro estaban MAL. Los correctos:

  M26 -> 26-Templo-Subterraneo
  M53 -> 53-UI-UX
  M87 -> 87-Localizacion
  M92 -> 92-Tutorial

Lo peligroso: los cuatro archivos equivocados TAMBIEN tenian un `[x]` en la linea
pedida, asi que la lectura "cuadraba" y nada fallaba. Lo detecte porque el texto que
el detector daba como motivo NO aparecia en el archivo que estaba leyendo.

COROLARIO: si la nota que cita el detector no esta en el archivo, la BASE esta mal,
no el detector. Antes de concluir "falso positivo", verificar que se esta leyendo el
archivo correcto.

## Resultado: 0 de 5 son inflaciones

| Modulo | Item | Veredicto | Evidencia |
|---|---|---|---|
| M26 | L183 | [x] VALIDO | 04-Codigo.md reescrito (L13-21 rutas reales); scripts/templos/ tiene los 6 archivos citados; los 13 hits Unity/C# (L98-114) dicen "Ninguno existe ni puede existir" + tabla .cs->.gd |
| M53 | L149 | [x] VALIDO, nota obsoleta | paleta en codigo (theme_ux.gd:13-14) pero los colores citados (0.95,0.90,0.82) son hoy (0.14,0.16,0.24) por D102; panel_rounded esta en L281-287, no en 243-249 |
| M53 | L151 | [x] VALIDO, redaccion enganosa | _setup_panel_styles L279, _setup_button_styles L290, _setup_focus_styles L420; llamados en L65/L68/L89 |
| M87 | L387 | [x] VALIDO (FP) | anclas verificadas: transport_localizer.gd:36-38 = M68.TRIP.*; w_reloj.gd:198 = tr_key("clock","estaciones"); diary_layer.gd:412 = get_categorias() |
| M92 | L149 | [x] VALIDO, H8 refutado | scripts/tutorial/ = 8 .gd, 0 .tscn, sin ui/; burbuja_pista* ausente en todo game/ |

**Suite ejecutada:** `test_m53_wcag.gd` -> **23 checks / 0 fallos / EXIT 0**.

## Por que el detector marca los 5

- M26: palabra "inexistentes" en la nota (habla de rutas Unity muertas, no del item).
- M53 L149: "FALSO NEGATIVO" (el QA declaro que su propio hallazgo era falso).
- M53 L151: "PARCIAL aceptado" (la funcion esta completa, con otro nombre).
- M87 L387: "inexistente"/"muerta real" (son HALLAZGOS del informe, no fallos).
- M92 L149: "NO tiene carpeta ui/" (es la refutacion de la hipotesis, o sea el cierre).

El detector esta marcando PALABRAS, no mentiras. Su clase AUTO sobreestima: 5/5 son
defectos de redaccion. Eso no lo invalida como radar, pero un AUTO ya no es sinonimo
de inflacion: hay que abrir el item.

## Caso especial: M53 L149 es SUPERSESION, no inflacion

El item pide "paleta pastel (fondo arena, acento ocre, texto marron)". Hoy el tema es
noche. No es que el artefacto falte: lo reemplazo una decision ratificada, D102
(documentada en 03-Diseno.md:405-406 y 04-Codigo.md:288 como "orden directa del
fundador 2026-10-16 18:32"). La funcion "hay una paleta con tema, en codigo" sigue en
pie. Lo que caduco es el VALOR, no la marca.

Patron nuevo para el catalogo: **una decision de diseno posterior puede volver obsoleta
la nota de un [x] sin tocar la marca**. Si la nota cita numeros, esos numeros son de la
fecha de la nota; el artefacto puede haber cambiado por orden del fundador.

## Lo que NO hice

No toque ninguno de los 4 checklists: son de M26/M53/M87/M92 y no tengo orden sobre
ellos. Deje en el canal 487 el texto exacto para pegar en los 5 casos (seccion 2), para
que lo aplique la directora o me autorice.

## Estado del detector

  168 checklists / 24.204 items / 22.671 [x]
  AUTOCONTRADICCION 5 -> 0 reales
  MIXTO 130 (sin abrir)
  SOSPECHOSO 1

Recorrido del dossier: 16 -> 7 -> 5 -> 0 reales. Los 130 MIXTO siguen siendo el
territorio donde puede haber inflacion de verdad (incluyen `DEGRADADO` + `[x]`, el
patron que dio 10 casos reales en M82).

## Pendiente

- F-8 (fila 105 de CHECKLIST-GLOBAL.md): sin OK.
- [?] de la seccion H de M157 (10 items): sin OK.
- Las 5 notas de la seccion 2 del canal 487: sin OK.
- Bloque obsoleto L1017-L1081 del BACKLOG-MASTER: sin OK.
- HC-04 (9 de M82) y HC-05 (9 de M106): propuestas escritas, sin aplicar.

Firma: DeepSeek-V4.1-Flash (WorkBuddy) - 2026-11-01 14:15 (GMT-3)
