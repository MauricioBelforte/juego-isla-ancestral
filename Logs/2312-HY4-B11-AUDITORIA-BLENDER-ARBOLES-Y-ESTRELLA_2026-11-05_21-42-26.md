# Log 2312 - HY4 - B11: auditoria de lo pendiente en Blender

**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-05 21:42:26 -0300
**Modulo:** auditoria Blender (M50 vegetacion, M45 estrella de mar, checklist de objetos)
**Responde a:** fundador - "revisa que queda por hacer en blender... unos arboles estaban mal hechos, y una estrella de mar en el piso estaba sin terminar"
**Rol:** parcheo de huecos / auditoria de tooling. No sella, no hace QA 21.8, no aprueba visualmente, no modifica assets.
**Log:** 2312 (reservado en la vuelta anterior, cortada por 429; sin archivo hasta ahora)
**Canal:** mensaje 06 del canal HY4

## 0. Alcance y limite

AUDITORIA, no implementacion. No se toco ningun .blend, GLB, generador ni ficha.
Motivo: el re-horneado de los 10 GLB de M50 y el rework de la estrella son
cambios de modelo; el Log 278 L152 exige confirmacion previa y la directora
indica en P-02 que la decision es del dueno de M36/M50. M50 esta "con dudas".

## 1. Arboles y vegetacion M50: regresion de escala MEDIDA

### 1.1 El recuerdo del fundador esta documentado

- DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md L219: "Hay arboles que
  son gigantes, parecen piedras verdes, esos deberian cambiar el diseno...".
- L223: arbol_frutal a 6 m se ve como "piedra verde gigante", es un blob sin
  forma de tronco + copa.
- L250 (Iter. 10): medicion de 10 GLB antes del horneado: arbol_frutal 10.9 m,
  arbusto_redondo 12.2 m, palmera 9.6 m.
- L251: "[x] 10/10 GLBs horneados a su altura objetivo" (reescalar_v5.py).
- L252: verificacion visual post-horneado, arbol_frutal 6 m exacto.
- L254: FLIP 2026-10-19 (Log 2022, msg 096): los 3 multiplicadores de
  escalas.json fuera de 1.0 pasan a 1.0 para evitar doble escala.

### 1.2 Medicion real de hoy (eje Y glTF, transformaciones de nodo aplicadas)

Fuente de objetivos: tabla OBJETIVOS de
tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py (10 pares).

  asset                 objetivo    ALTA   MEDIA    BAJA    delta   estado
  arbol_frutal              6.00   3.880   3.880   3.878   -2.120  FUERA
  arbusto_redondo           1.00   1.679   1.679   1.686   +0.679  FUERA
  arbusto_floral            1.00   0.998   0.998   0.993   -0.002  OK
  flor_isla                 1.20   1.266   1.194   1.183   -0.006  OK
  hierba_alta               0.60   0.416   0.416   0.416   -0.184  FUERA
  helecho_chico             0.70   0.300   0.300   0.300   -0.400  FUERA
  helecho_gigante           2.50   0.400   0.400   0.400   -2.100  FUERA
  palmera_joven             3.00   2.533   2.533   2.536   -0.467  FUERA
  palmera                   7.00   4.619   4.619   4.622   -2.381  FUERA
  palmera_inclinada         7.00   4.252   4.252   4.255   -2.748  FUERA

  CUMPLEN: 2/10. FUERA DE OBJETIVO: 8/10.

escalas.json: los 10 multiplicadores estan en 1.0 (medido). El runtime ya no
compensa: renderiza la altura cruda del GLB. La direccion del defecto cambio:
ya NO son gigantes, ahora estan POR DEBAJO de escala (helecho_gigante 0.40 m
contra 2.5 m; arbol_frutal 3.88 m contra 6.0 m).

La FORMA si fue arreglada: la hoja de contacto
tools/mcp/blender-mcp/50-Vegetacion/capturas/_hoja_cap_50_arbol_frutal_lowpoly.jpg
muestra tronco + copa + frutos, no un blob verde. "Piedras verdes" ya no aplica;
lo pendiente es la escala y la documentacion que la declara cerrada.

### 1.3 Causa raiz con traza de commits

Trazado sobre game/isla-ancestral/assets/3d/media/50-Vegetacion_arbol_frutal.glb:

  10926a6  2026-09-01  alto=3.880 m  (original pre-horneado)
  39f4c5e  2026-09-06  alto=10.861 m (actualizacion de assets 3d)
  9e378d6  2026-09-06  alto=6.000 m  (HORNEADO CORRECTO)
  841afaf  2026-09-08  alto=3.880 m  (REVERSION: "sistema de horizonte y
                       vision lejana") - no hay commits posteriores sobre el GLB

El respaldo Obsoletos/glbs_vegetacion_pre_reescalar_v5/ mide 3.880 m, identico
al GLB actual. El horneado se perdio en 841afaf y nunca se reaplico. El flip de
escalas.json de 2026-10-19 asumio que el horneado seguia presente.

## 2. Estrella de mar M45: correccion a medias y fuente no reproducible

### 2.1 Historial contradictorio

- Logs/278 L89: estrella_mar = IRRECONOCIBLE, RECHAZADO, "no se distingue forma
  de estrella en ningun angulo". L127: rehacer geometria, prioridad alta.
  L152: NO re-trabajar sin confirmacion.
- Logs/231 L92: "plana 45mm" -> "volumen 220mm, 5 puntas".
- game/isla-ancestral/assets/fichas/45-Arte3D_estrella_mar.md: APROBADO.
- Hoja vieja cap_45_2026-08-28_18-47-30_estrella-orbita_contact.jpg: mancha
  plana pegada al piso. Hoja nueva _hoja_cap_45_estrella_mar_lowpoly_04-28-30.jpg
  (2026-08-31): si se lee estrella de 5 puntas, pero los 5 bultos parecen cuernos.

### 2.2 Causa medida en el GLB

game/isla-ancestral/assets/3d/alta/45-Arte3D_estrella_mar.glb:

  n5 SM_Estrella_Mar         scale=[1, 3, 1]  translation=[0, 0.045, 0]
  n0..n4 SM_EstrellaMar_Bulto_1..5 = HIJOS de n5, translation Y=0.0514,
         mesh Icosphere con dz=0.037
  mesh SM_Estrella_Mar: min Y=0, max Y=0.040 (cuerpo plano de 40 mm)
  bbox global: X=0.468  Y=0.220  Z=0.488

La "correccion a volumen 220 mm" NO reconstruyo la geometria: aplico una escala
no uniforme x3 en Y al nodo padre. Los 5 bultos heredan esa escala, se estiran
de 0.037 a 0.111 m y se desplazan: de ahi los cuernos. El bbox de 0.220 m que
Log 231 uso como metrica de aprobacion INCLUYE el estiramiento de los bultos;
el cuerpo real sigue siendo una lamina de 0.040 m. La metrica mide el artefacto
del defecto, no el volumen de la estrella.

### 2.3 Deriva de generador

tools/mcp/blender-mcp/45-Arte3D/scripts/crear_estrella_mar_lowpoly.py:
  L54  ALTO = 0.040
  L158 z_min medido con cuerpo.bound_box
  L162 z_min_final medido con cuerpo.bound_box

No contiene la escala x3 ni ninguna reconstruccion de volumen. Si se re-ejecuta,
reproduce la estrella PLANA de 40 mm que fue rechazada en Log 278. El .blend y el
GLB que hay en disco NO se pueden regenerar desde la fuente versionada. Ademas
usa bound_box en vez de vertices reales (convencion zmin_real()).

## 3. CHECKLIST-OBJETOS-BLENDER.md: deriva documental

Recuento estricto con patron ^\s*(?:\d+\.|[-*])\s+\[([ x?/])\]:
  142 [x] / 27 [ ] / 43 [/] / 0 [?] = 212 marcas.

De los 27 [ ]:
  - 12 HUECOS REALES (0 blend/py y 0 GLB): L50 semillero, L175 columna entera
    con capitel, L176 bloque de piedra tallada, L177 dintel caido, L187 estructura
    sumergida, L194 valla de madera, L205 lagarto, L207 cabra, L208 gallina,
    L209 mariposa, L224 cana de pescar, L230 carrito de vias.
  - 13 OBSOLETOS (ya hay artefacto): L48/49/51/52/53/54/55/56 de M33,
    L91/92 casas de MiMo (RESERVADAS, no tocar), L174 columna rota (cerrada en
    B10), L182 palanca, L226 cangrejo.
  - 2 PARCIALES: L204/L225 pez (hay pez_cozy.blend y sm_pez_rio.blend, 0 GLB,
    sin las 2 variantes de color pedidas).

De los 43 [/]: 11 citan un crear_*.py y 11/11 tienen GLB. Muestra directa de 8
nombres (pared_madera, pared_ventana, pared_puerta, piso_madera,
techo_dos_aguas, techo_paja, puerta_articulada, ventana_marco): 3 GLB cada uno.
La nota "pendiente MEDIA/BAJA + GLB (requieren Blender GUI por socket)" es
obsoleta al menos en esos 11. LIMITE: los otros 32 no citan script y no se
pueden verificar automaticamente; no se afirma nada sobre ellos.

BACKLOGS/02-Backlog-Pendientes-Assets.md sigue listando "Columna rota" como [ ]
aunque B10 la cerro: deriva del split de la directora. No se flippeo ninguna
marca (regla de la directora: 0 flips ajenos).

## 4. Guardia nueva: scripts/auditar_escalas_vegetacion.py

- Parse la tabla OBJETIVOS de reescalar_v5.py: fuente unica, no copia los numeros.
- Mide altura Y real de los 10 GLB en alta/media/baja aplicando matrices de nodo.
- --check: tabla + "cumplen N/10"; exit 0 si 10/10, 2 si hay deriva, 3 si CIEGO.
- --self-test: CHECKS_MINIMOS=21 MEDIDO en verde, guardia de ceguera y de
  alcanzabilidad de bloques, GLB sintetico con escala conocida.

Resultados MEDIDOS:
  verde: checks=21 fallos=0 minimo=21 deriva_hoy=8/10, exit 0
  --check: 2/10 cumplen, 8 fuera, exit 2 (deriva detectada; es el estado actual)
  rojo por inyeccion (sin mutar el archivo, via monkeypatch en memoria): 4/4
    R1 comparador always-True      -> exit 1, 2 fallos
    R2 medicion vacia              -> exit 3, CIEGO
    R3 transformaciones ignoradas  -> exit 1, 2 fallos
    R4 piso de checks imposible    -> exit 3, CIEGO
  formato: 10292 bytes, ASCII puro, LF, sin BOM, sin U+FFFD.

NO se conecto a quality.yml (archivo protegido; P-01 tiene GO pero se deja para
la vuelta siguiente). El auditor hoy sale 2 a proposito: es un detector, no un gate.

## 5. Numeracion y protocolo

- Log 2312: consumido por reservar_log.py en la vuelta anterior, cortada por 429;
  quedo sin archivo. Se usa ahora. Pool Logs/NUMEROS_DISPONIBLES.txt: el worktree
  perdio 2309..2313 (saneo ajeno en vuelo), head=2314. NO se toca.
- Canal HY4: proximo_numero.py --consume consumio el 4 en la vuelta cortada; la
  directora escribio 04 y 05 a mano. Pool head=5 pero 05 ya existe: POOL ROTO.
  Proximo real = max(archivos reales)+1 = 06. Se reporta, NO se toca el pool
  (esta ignorado por .gitignore).
- Directora vigente: agnes-3-flash. El prompt de automatizacion sigue diciendo
  GLM-5.3-Flash: discrepencia registrada, aviso nro 30.
- Acuse: recibidos #04 (TANDA T-01..T-04) y #05 (P-01..P-06). P-01 tiene GO;
  P-02 se reporta al fundador y no se resuelve solo (esta auditoria aporta
  evidencia nueva para esa decision). No se mezclo la tanda con B11.

## 6. Propuestas (NO aplicadas, esperan decision)

  Q1 Re-hornear los 8 GLB fuera de objetivo con reescalar_v5.py (o corregir
     escalas.json). Requiere dueno M50: las dos soluciones son incompatibles
     entre si y el flip de 2026-10-19 ya eligio una.
  Q2 Reconstruir la estrella en el GENERADOR (volumen real en la malla, bultos
     sin escala heredada, zmin_real) y re-exportar. Requiere confirmacion del
     fundador segun Log 278 L152.
  Q3 Actualizar las 13 marcas [ ] obsoletas y las 11 notas [/] del checklist:
     son flips de marca, competencia de la directora.
  Q4 Prioridad: T-01a (Barquita de Aurora) vs Q1/Q2. Pregunto en el canal.

## 7. Cierre

B11 = AUDITORIA CERRADA, SIN CAMBIOS EN ASSETS. Un script nuevo, un log, un
mensaje de canal y una entrada de backlog. Cero flips, cero QA 21.8, cero sellos,
cero push.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy - 2026-11-05 21:42:26 -0300
