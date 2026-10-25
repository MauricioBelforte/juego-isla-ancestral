# Log 2173 - M23 iter. 18: clusters Pesca (4) + Coleccion (6) - bloque W

- **Agente:** Step-5-WorkBuddy
- **Modulo:** M23 (Historias Secundarias)
- **Fecha:** 2026-10-24 20:45:00 (GMT-3)
- **Tanda:** items L77 (Crear 4 misiones de pesca) y L78 (Crear 6 misiones de
  coleccion) del 05-Checklist, acumulados en UN reporte (regla del fundador).
  Riel declarado en mi msg 205/209 y confirmado por la directora en su 210
  ("tu riel M23 sigue en curso").

## Dato

- data/historias/secundarias.json: 67 -> 77 cadenas (+10, +6704 B, aditivo).
  Formato preservado (tabs, pasos en una linea), LF puro sin BOM.
- Pesca (4) - 03-Diseno L42 nombra 3 temas -> 3 nombrados + 1 de extension
  declarada (nocturna), mismo patron que Exploracion (3+5) e Investigacion
  (4+1):
  - cadena-pesca-trofeos: finneas_zorro (pescador) + OBJ-HER-011 Cana de oro
  - cadena-pesca-documentacion: sofia_buho (bibliotecaria) + OBJ-ART-002 Pergamino mistico
  - cadena-pesca-suelta: teo_conejo (herbolario) + OBJ-HER-010 Cana mejorada
  - cadena-pesca-nocturna (extension): finneas_zorro + OBJ-LUZ-012 Linterna
- Coleccion (6) - 03-Diseno L43 nombra los 6 temas, 6/6 con cadena:
  - cadena-coleccion-murales: luna_zorra (artesana) + OBJ-CUA-010 Obra maestra
  - cadena-coleccion-glifos: sofia_buho + OBJ-ART-001 Estatuilla antigua
  - cadena-coleccion-sellos: olivia_nutria (sastra) + OBJ-ART-005 Joya de la isla
  - cadena-coleccion-minerales: ramon_tejon (herrero) + mineral_cobre Mineral de Cobre
  - cadena-coleccion-peces: finneas_zorro + OBJ-ITE-023 Pescado
  - cadena-coleccion-plantas: teo_conejo + OBJ-PLA-004 Orquidea
- Las 10 nacen visibles (oculta:false). 0 colisiones de id/flag/capitulo.
- Titulo de cadena-coleccion-sellos renombrado a "Los Sellos de los Oficios"
  por colision medida con cadena-cofradia (iter. 6, mismo titulo; lo detecto
  el validador de la suite en la 1a corrida: 691 checks / 1 fallo / EXIT 1).
  Contexto ajustado (sello del panadero, no el de la cofradia) y ref del
  puzzle renombrado sello-del-panadero. 77/77 titulos unicos verificado.

## Evidencia (binario real)

- Suite scripts/historias/test_historias.gd: **691 checks / 0 fallos /
  EXIT 0 x3**, 0 SCRIPT ERROR. Piso 624 -> 691 MEDIDO en verde.
- Bloque W _test_pesca_coleccion() NUEVO (+67 checks): 30 carga/fuente/
  no-oculta + 1 expuestas + 2 unicidad local + 1 capitulos + 1 NPC distintos
  + 6 NPC reales + 1 objetos distintos + 10 objetos reales + 2x7
  end-to-end (pesca-trofeos y coleccion-plantas) + 1 puente diario.
- 4 asserts de conteo REPARADOS (67->77 x2, 68->78 x2, mismos valores en
  los mensajes): cadenas_count, principal.size(), cargadas, unicidad global.
- BLOQUES de la guarda: "W" agregado (sin el, el guardian detectaba el piso
  pero no nombraba el bloque).
- Guardian EN ROJO por inyeccion de runtime sobre el bloque W (valor
  dinamico via subscript; un literal es PARSE ERROR estatico): EXIT 1,
  "[FAIL] el bloque W NO se ejecuto" + "[FAIL] solo 625 checks ejecutados
  (minimo 691)", 2 fallos. Sonda borrada y suite restaurada (sha256
  baa223ed684c852126b98e5c9add9c55006d50a66389f4d5cf0c23f002924c7d).
- Realidad independiente: 10/10 NPC REALES por campo id en data/villagers/
  (profesiones medidas: pescador, bibliotecaria x2, herbolario x2, artesana,
  sastra, herrero) y 10/10 objetos REALES por campo id en data/items/.
- Regresiones EXIT 0: M59 carga idempotente 28/0, autosave 0, fecha/diario/
  cola 45/0, slots/perfiles 41/0, carga NPC/misiones 63/0; M71 flujo XP
  37/0; M55 diario 0 fallos + persistencia 0 fallos.

## Flips con cita (05-Checklist)

- L77 "Crear 4 misiones de pesca" -> [x]
- L78 "Crear 6 misiones de coleccion" -> [x]
- L80 "Documentar misiones de pesca y coleccion" -> [x] (04-Codigo sec. Iter. 18)
- M23 = **79 [x] / 24 [ ] / 2 [?] = 105** (prefijo de linea; Totales sync).
  Ofrecidos a revertir.

## Documentacion

- 04-Codigo.md sec. Iter. 18; 06-Plan-Testings (bloque W, piso 691, guardian
  17 veces); 07-Resultados-Testings sec. Iter. 18; BACKLOG-MASTER (cola +
  registro de vuelta).

## Limites

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos.

## Pedidos a la directora

- Ronda de commit de los paths de la tanda.
- Sync fila 23 del GLOBAL a 79/105.
- Visto bueno de los 3 flips (ofrecidos a revertir).
- Ruteo proxima: quedan 24 [ ]; M33-Agricultura (sistema de cultivos) si lo
  confirma tras el batch [C] del Cron D, o siguiente cluster del 03.
