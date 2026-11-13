======================================================================
LOG 2412 - HY4 - B27: AUDITORIA DE LA NUEVA COLA ACTIVA (ACUSE 71)
======================================================================
Fecha      : 2026-11-13 15:50:00 -0300
Agente     : Hy4 (Tencent Hunyuan Hy) / WorkBuddy
Canal      : mensaje 72 (acuse a 71 + SEGUNDA INSTANCIA), mensaje 73 (cierre)
Acta       : 37-Backlog-B27-Auditoria-Cola-Activa.md
Estado     : EJECUTADO. AUDITORIA DE EVIDENCIA + 1 GUARDIA POSITIVA NUEVA.
            0 assets nuevos, 0 GLB nuevos, CERO flips.

Log 2412 reservado y escrito EN EL MISMO TURNO (pool 2412 -> 2413).
EL POOL NO SE COMMITEA. 1 numero = 1 archivo. El 2411 lo consumio Hy3
(Logs/2411-hy3-qa-tanda17nov-medido_2026-11-13_15-45-00.md, ajeno,
untracked al cierre): NO es un gap y NO se toca.

----------------------------------------------------------------------
1. ESTADO VIVO RE-MEDIDO
----------------------------------------------------------------------
HEAD cd8306a (preservacion del fundador, 2026-11-13 15:39:15 -0300):
  absorbio B26 mariposa M36 CERRADO + TANDA 17nov Hy3 + M18 ventanas
  ERNIE + Ling v93-99 + flips L19-L23. MEDIDO: cd8306a NO absorbio NADA
  de B27 (ni mensaje 72, ni guardia, ni sonda): los 3 paths propios
  estaban SIN_VERSIONAR al cierre.
Worktree COMPARTIDO: 11 entradas sucias al cierre, TODAS ajenas salvo
  los artefactos propios de B27. 0 staged. Ninguna entrada ajena se
  arrastra al commit.
Canal HY4: 70 (cierre B26) -> 71 (director) -> 72 (PRIMERA INSTANCIA) ->
  73 (cierre). SIN mensaje nuevo >72. max(real)+1 en cada paso.
  Pool de canal INTACTO, NO tocado. Persisten DOS archivos 56-*.
Pool de logs: 2411 al reingresar (15:37) -> Hy3 escribio 2411 -> 2412
  reservado aqui -> 2413. Logs 2408 ERNIE-5.5, 2409 Hy3, 2410 B26.
GLB de runtime: 490 trackeados ANTES y DESPUES (B27 NO exporta nada).

----------------------------------------------------------------------
2. ACUSE 71: GO B26, FLIPS Y TRES DISCREPANCIAS PUBLICADAS
----------------------------------------------------------------------
71-2026-11-12_04-05-00-agnes-3-flash-a-hy4-acuse-70-b26-mariposa-
  m36-cerrado.md (541 B, UTF-8/LF/sin BOM, con "Responde a: HY4 - 70",
  untracked => ajeno, intacto para el fundador, NO se versiona).
  GO export B26 APROBADO; "Flip: L23 flippeado"; "M36 COLA ACTIVA
  AGOTADA. 8/8 cerrados"; "Siguientes: Columnas M25 + Semillero +
  Palanca. TANDA nueva cuando estes listo".
FLIPS VERIFICADOS EN DISCO (diff del worktree = 1 linea por archivo):
  02 L23 [ ] -> [x]; COBJ L209 [ ] -> [x].
  36-Fauna/checklist.md L23-L27 SIGUEN [ ] (cinco cierres sin flip).
Recount estricto (re.MULTILINE): 02 = 29 [x] / 6 [ ]; COBJ = 163 / 6;
  36 = 16 / 5; 07-Backlog-Tanda-Blender = 0 / 17 (stale);
  35-Mineria = 3 / 4. REGLA CERO: Hy4 NO aplica flips.
TRES DISCREPANCIAS PUBLICADAS CON CITA EN EL MENSAJE 72, SIN CORREGIR:
  (a) NAMING: el 71 dice "3 GLB mariposa_lunar"; el artefacto real es
      36-Fauna_mariposa.glb x 3 LOD (cfc292e). No existe GLB
      mariposa_lunar. Propuesta reversible al director, sin renombrar.
  (b) "8/8 cerrados" INEXACTO: los 6 items M36 (L19-L23 + L39
      Cangrejo) estan [x], pero 02 L38 "Pez capturable" y L30
      "Palanca de puzzle" SIGUEN [ ]. Los 2 citados como cerrados no
      lo estan en ese espejo.
  (c) CONTRADICCION: "Palanca" aparece como "fuera de M36" en el mismo
      renglon de los 8/8 y a la vez en "Siguientes: ... + Palanca".
      Hy4 no decide cual prevalece.
RELOJ DEL 71: escrito 2026-11-12 04:05, mtime 2026-11-13 01:00:55
  => desfase +20 h 55 m 55 s, mismo patron inverso de los acuses 62/68.
Aviso de discrepancia: AGENTS.md seccion 31 nombra
  "GLM-5.3 Flash-Director"; quien escribe, acusa, da el GO y a quien se
  reporta es agnes-3-flash. Sin tocar archivos protegidos.

----------------------------------------------------------------------
3. HALLAZGO CENTRAL: LA NUEVA COLA ACTIVA YA ESTA EJECUTADA
----------------------------------------------------------------------
MEDICION (no suposicion), publicada en el mensaje 72:

  COLUMNAS M25
    9 GLB TRACKEADOS: 25-Ruinas-Templos_columna_entera.glb x3 LOD +
    columna_rota_alta.glb x3 + columna_rota_baja.glb x3 (las 2
    variantes de altura). Generadores crear_columna_entera_lowpoly.py /
    crear_columna_rota_lowpoly.py, .blend, capturas, logs 2311 / 2335
    / 2338. 02 L26/L27 y COBJ L174/L175 SIGUEN [ ].
    => asset EJECUTADO; falta FLIP.
  SEMILLERO
    33-Agricultura_cultivo_brote.glb x3 TRACKEADOS (10924 / 10160 /
    9004 B). HY4/33-Agricultura/checklist.md L7 [x] con
    cultivo_brote_lowpoly.blend. Acta 11 L27 documenta que B11 lo
    clasifico MAL como hueco real pese a tener GLB x3 + ficha.
    COBJ L50 SIGUE [ ]. => asset EJECUTADO; falta FLIP.
  PALANCA
    70-Interacciones_palanca_madera.glb x3, COBJ L182 [x] con ficha
    data/construccion/piezas/palanca_madera.tres y commit 787ab35;
    COBJ L262/L353 [x] (rediseno v3 horquilla). 02 L30 SIGUE [ ].
    => asset EJECUTADO Y RATIFICADO; falta FLIP.

  25-Ruinas-Templos, 33-Agricultura y 70-Interacciones ESTAN en
  MODULOS de exportar_godot.py: sin fallo E-63 / T-02 pendiente.

=> 0 HUECOS DE ASSET NUEVOS EN LA COLA ACTIVA. Lo pendiente son FLIPS
   (facultad EXCLUSIVA del director) y un HUECO DE VERIFICACION REAL:
   en TODO el repo solo existia verificar_columna_entera.py (guardia
   bpy sobre .blend, 27 checks); NO existia verificar_columna_rota.py,
   ni guardia de cultivo_brote, ni de palanca_madera. Los 6 GLB de
   columna rota (exportados en B10bis / log 2335) NUNCA habian sido
   verificados sobre su BIN.

----------------------------------------------------------------------
4. SEGUNDA INSTANCIA B27: QUE SE HIZO Y QUE NO
----------------------------------------------------------------------
Fuente de autorizacion: COLA ACTIVA del acuse 71 + orden directa del
  fundador ("continua trabajando", 15:36 -0300). Se toma el PRIMER item
  ("Columnas M25") en su hueco REAL de verificacion.
SI SE HIZO: sonda de calibracion sobre 12 GLB, 1 guardia positiva nueva
  sobre los 6 GLB de columna_rota, re-ejecucion de la guardia hermana,
  reporte de evidencia para los flips, cierre documental y commit.
NO SE HIZO: re-autorar assets, aplicar flips, editar 02 / COBJ /
  36-Fauna / 07, tocar CHECKLIST-GLOBAL.md / AGENTS.md / quality.yml /
  project.godot / exportar_godot.py / plantilla_asset.py / pool de canal.
NO se exporto ningun GLB: 490 antes y 490 despues.

----------------------------------------------------------------------
5. SONDA DE CALIBRACION (12 GLB, BIN REAL)
----------------------------------------------------------------------
Temp/hy4_b27_glb_probe_20261113.py (+ .json / .txt), decoder
  AUTOCONTENIDO de verificar_mariposa.py (B26). Ejes glTF Y-up:
  p[0]=X, p[1]=ALTURA, p[2]=LATERAL.

  columna_rota_alta   ALTA/MEDIA/BAJA: tris 464/464/303, mats 5/5/4,
    mallas 12/5/4, verts 857/857/605, altura 2.1450/2.1450/2.1457,
    tope 2.1900/2.1900/2.1907, apoyo 28/28/24.
  columna_rota_baja   ALTA/MEDIA/BAJA: tris 464/464/304, mats 5/5/4,
    mallas 12/5/4, verts 857/857/626, altura 1.4450/1.4450/1.4457,
    tope 1.4900/1.4900/1.4907, apoyo 28/28/24.
  DIFERENCIA ENTRE VARIANTES = 0.7000 m EXACTOS en los 3 LOD.
  Huella x[-0.5493..0.9051] = 1.4544 y lat[-0.4668..0.5542] = 1.0210
    => E-50 OK (>= 0.30 en ambos ejes).
  Materiales: 4 base (CorteFresco / Musgo / Piedra / PiedraOsc) +
    MAT_ColRota_Glifo SOLO en ALTA/MEDIA (poda deliberada).
  cultivo_brote: tris 152/152/102, mats 3/3/3, alt 0.045..0.1998,
    apoyo 13/13/10, sha e3cd5706e5ac / 0d847ae66853 / 6d74f6554016.
  palanca_madera: tris 516/516/66, mats 3/3/3, alt 0.045..0.6155,
    apoyo 4/4/4, sha c6cb92bbdf62 / 5540f6ef839e / 3d3f87a4cb5e.
  12 sha DISTINTOS medidos. TODO DATO MEDIDO, no estimado.

DERIVA HEREDADA PUBLICADA COMO DATO, NO CONSAGRADA: las variantes BAJA
  de columna_rota tienen tope 2.1907 / 1.4907 (deriva +0.0007 m por
  decimate sobre cajas disjuntas, familia B18 / acta 28) y niveles de
  altura espurios. La guardia NO exige esos niveles: exige la FORMA
  ESENCIAL (altura dentro de 1e-3, apoyo, silueta, materiales, LOD por
  poda). No se corrige el asset legacy sin GO. La asercion que fijara
  el valor equivocado quedaria consagrando el bug (trampa conocida).

----------------------------------------------------------------------
6. GUARDIA POSITIVA NUEVA verificar_columna_rota.py
----------------------------------------------------------------------
tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_columna_rota.py:
  Python puro AUTOCONTENIDO (no depende del decoder de B26 ni de la
  guardia bpy hermana). Parsea GLB, lee accessors / bufferViews /
  byteStride, decodifica POSITION real del BIN, aplica matrices
  COLUMN-MAJOR de nodos. 18 checks x 6 GLB + 6 globales = 114.
CHECKS_MINIMOS = 114 y BLOQUES_MINIMOS = 6 se fijaron DESPUES de medir
  el PISO EN VERDE con --piso 0 (regla: medir antes de escribir la
  cifra): CHECKS=114 PASADOS=114 FALLOS=0 BLOQUES=6 RC=0.
CHECK CLAVE (anti-copia): C17 exige que cada GLB tenga la altura de SU
  PROPIA variante; G2 exige diferencia 0.7000 m en los 3 LOD; G5 exige
  6 sha distintos; G6 exige altura consistente entre LOD (deriva <=
  0.001 m, no colapso). "2 variantes de altura" no pueden ser 2 copias.
4 RUTAS EJERCITADAS:
  PISO     --piso 0     114/114/0 BLOQUES=6 RC=0
  VERDE    default      114/114/0 BLOQUES=6 PISO=114 RC=0
  ROJO     --inyectar   114/108/6 RC=1; 9 vertices mutados; fallos
                        C8/C9/C11/C17/G2/G6 = CONFUSION DE VARIANTES.
                        MEDIDO con precision: el tope RESULTANTE del GLB
                        inyectado es 2.1649 (NO 1.4907) porque otros
                        vertices del fuste quedan por encima; aun asi G2
                        cae a 0.6742. Se publica el dato real, no el
                        valor que "deberia" dar.
  CIEGO    --solo ...   24 checks / 19 pasados / 5 fallos / 1 bloque
                        / RC=3: no se hereda ningun verde.
  GLB PUBLICADOS INTACTOS tras el ROJO (6 sha sin cambios): la
  inyeccion escribe SOLO en Temp/.
FALSO ROJO MEDIDO Y CORREGIDO (C18): la primera version exigia los
  nodos Basa/Fuste/Corona en TODOS los LOD y fallaba en 4 bloques.
  MEDICION: la FASE 1 de generar_variante.py RENOMBRA los nodos a
  SM_ColRota_M_ColRota_<Material> en MEDIA (5 grupos) y BAJA (4).
  No se RELAJO el check: ahora exige la estructura REAL de cada LOD
  (nodos originales en ALTA, grupos por material en MEDIA/BAJA).

GUARDIA HERMANA RE-EJECUTADA EN BLENDER 4.2 (es bpy, NO corre con
  python): verificar_columna_entera.py -> CHECKS=27 PASADOS=27
  FALLOS=0 MINIMO=27 BLOQUES=3 RC=0, "VERDE: capitel integro en 3
  blends". Dato MEDIDO en este cierre, no heredado de 2026-11-06.

----------------------------------------------------------------------
7. FORMATOS Y GATE 28
----------------------------------------------------------------------
Log 2412: ASCII PURO (0 bytes > 127), CRLF, SIN BOM.
Mensajes 72/73, acta 37, guardia, sonda y memoria: UTF-8, LF,
  SIN BOM, 0 CR sueltos, 0 U+FFFD.
py_compile de verificar_columna_rota.py y de la sonda: RC=0.
Gate 28 (python scripts/verificar_bom.py): ROJO en HEAD, RC=1, por
  BOM / U+FEFF de archivos AJENOS. Con filtro CORRECTO:
  0 paths propios de B27 en la lista roja.
  TRAMPA DE MEDICION DEL FILTRO (publicada): un primer grep
  '7[23]-' confundio DOS carpetas ajenas llamadas
  "73-Coleccionables/checklist.md" (Crouton Alpha y Glyph Cluster)
  con posibles mensajes propios 73-*. No eran falsos positivos DEL
  GATE sino de MI PATRON: esos archivos SI estan en rojo y SON ajenos.
  Re-medido con patron explicito -> 0 paths propios.
  REPORTADO, SIN TOCAR: saneo de BOM ajeno es del director.

----------------------------------------------------------------------
8. CIERRE: ALCANCE Y DEUDA ABIERTA
----------------------------------------------------------------------
SE VERSIONAN (commit selectivo, pathspec explicito, SIN git add -A):
  - verificar_columna_rota.py (guardia NUEVA)
  - Log 2412
  - Acta 37
  - Mensaje 72 (toma / PRIMERA INSTANCIA)
  - Mensaje 73 (cierre / reporte de evidencia)
  = 5 paths en total. NO hay GLB nuevos: B27 es auditoria, no autoria.
NO SE VERSIONAN (scratch conservado en Temp/, NO se borra):
  hy4_b27_glb_probe_20261113.py / .json / .txt y
  hy4_b27_rojo_20261113.glb.
  NOTA: el fundador ya absorbio scratch de B22/B25/B26 en commits
  ajenos; si vuelve a hacerlo, la afirmacion "no versionado" de este
  log quedara desactualizada POR UN COMMIT DE OTRO AGENTE, no por Hy4.
0 FLIPS. Sin QA seccion 21.8, sin sello, sin aprobacion visual final,
  sin integracion en escena, sin GO de export, sin push, sin --amend.
NO SE TOCO: 02-Backlog-Pendientes-Assets.md, 07-Backlog-Tanda-Blender,
  CHECKLIST-OBJETOS-BLENDER.md, HY4/36-Fauna/checklist.md,
  HY4/33-Agricultura/checklist.md, HY4/35-Mineria/checklist.md,
  AGENTS.md, quality.yml, CHECKLIST-GLOBAL.md, project.godot,
  exportar_godot.py, generar_variante.py, plantilla_asset.py,
  verificar_columna_entera.py, BACKLOG-MASTER.md, NUMEROS_DISPONIBLES.

PROPUESTA DE FLIPS AL DIRECTOR (CON CITA, SIN APLICAR):
  - 02 L26 "Columna rota (2 variantes de altura)" -> 9 GLB trackeados,
    logs 2311/2335/2338, guardia 114/114/0 nueva en este cierre.
  - 02 L27 "Columna entera con capitel" -> 3 GLB trackeados, guardia
    hermana 27/27/0 RE-EJECUTADA EN VERDE en este cierre.
  - 02 L30 "Palanca de puzzle" -> 3 GLB + ficha .tres + COBJ L182 [x].
  - COBJ L174 / L175 (columnas) y L50 (Semillero brotando) -> los 3
    GLB de cultivo_brote medidos por BIN en la seccion 5.
  - 36-Fauna/checklist.md L23-L27: CINCO cierres sin flip acumulados.
  - 35-Mineria L10-L13: deuda viva de B19/B20/B21 (L13 = Carrito de
    vias, Cangrejo = L12).
OTRAS DECISIONES ABIERTAS DEL DIRECTOR:
  - GO / ratificacion de export (B26 ya tiene GO del 71; B27 no exporta).
  - Naming mariposa_lunar vs 36-Fauna_mariposa.glb.
  - Ambiguedad de "Palanca" en el acuse 71 y exactitud del "8/8".
  - Dueno / naming / modulo de "Pez capturable" (34-Pesca NO esta en
    MODULOS: E-63 / T-02).
  - Fix del bug latente de plantilla_asset.py::mat(emisivo=...) (B26).
  - Gate 28 por BOM ajenos; acta 24 (casos 34-36 del corpus
    M166-runtime); contrato bimodo completo B26-bis.
  - "TANDA nueva cuando estes listo" del acuse 71: Hy4 NO toma ningun
    hueco nuevo sin nueva PRIMERA / SEGUNDA INSTANCIA.

======================================================================
FIN LOG 2412 - B27 AUDITORIA COLA ACTIVA - HY4
======================================================================
