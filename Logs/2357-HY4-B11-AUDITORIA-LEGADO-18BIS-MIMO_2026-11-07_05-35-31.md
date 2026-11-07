# 2357 - HY4 - B11 AUDITORIA MEDIDA LEGADO 18-BIS (BAJA DE MiMo) + GUARDIA 104/0

Fecha      : 2026-11-07 05:35:31 -0300
Agente     : HY4 (Tencent Hunyuan Hy) / WorkBuddy
Modulo     : tools/mcp/blender-mcp/18-BIS-Casas-Grandes (SOLO LECTURA)
Responde a : fundador - 'mi mo ya no es parte de la flota' (2026-11-07 05:27)
Canal      : mensaje 32
Acta       : DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/22-Backlog-B11-Auditoria-Legado-18BIS-MiMo.md
Estado     : EJECUTADO (auditoria de solo lectura). CERO FLIPS. Sin QA 21.8,
             sin sello, sin aprobacion visual, sin export, sin GO explicito.

--- 1. ORIGEN Y PRIMERA INSTANCIA ---

El fundador ratifico hoy la baja de MiMo. Ya existia la directiva del 6-nov
registrada en el mensaje 28 y el acta 20, mas el respaldo documental del
mensaje 271 de Nemotron (M64: MiMo inactivo; flota Hy3/Hy4/DS-OC/Nemotron/GLM).

No hay PRIMERA INSTANCIA pendiente: desde mi mensaje 31 no entro ningun escrito
nuevo de la directora en el canal HY4. El ultimo del director sigue siendo el 30
(solo 'Recibido.'), ya respondido en 31. Numeracion max(real)+1 = 31+1 = 32.
Colisiones vivas 22/27/28; acuse sin NN del 6-nov sin renombrar.

Incidente propio, publicado: al medir el numero invoque proximo_numero.py, que
REESCRIBIO el pool ignorado del canal (elimino 5..31). La regla es no tocar el
pool roto: lo restaure a su estado exacto anterior (5..200, 196 numeros, 684 B,
UTF-8/LF, sin BOM) y verifique que no genere entrada en git status.

--- 2. SEGUNDA INSTANCIA ---

COLA ACTIVA (07) sin reposicion: T-01a..T-01d y T-02 ejecutados sin flips,
T-03 CIEGO, T-04 referencia fantasma B-15-02, resto protegido/ajeno. Con MiMo
dado de baja tome el hueco medible sin dueno: el legado 18-BIS-Casas-Grandes.
NO exporte nada: hay equivalencias canonicas validas ya en Godot (seccion 5).

--- 3. GUARDIA NUEVA ---

Archivo: tools/mcp/blender-mcp/18-Casas/scripts/auditar_18bis_casas.py
Decodifica VERTICES REALES del BIN (glTF Y-up, matrices column-major
M[c*4+r], traslacion M[12..14]), cuenta triangulos por accessor, materiales,
nodos y verifica ALCANZABILIDAD desde las raices de escena. 8 checks x 13 GLB.

Dos capas separadas a proposito: los CHECKS solo prueban que el inventario se
midio de verdad; los HALLAZGOS de calidad se PUBLICAN como datos, no como
checks. Si un asset invalido hiciera fallar la guardia, un arreglo futuro
podria consagrar el defecto solo para volver al verde.

  PISO   (--piso 0) : CHECKS=104 PASADOS=104 FALLOS=0 BLOQUES=13 CASAS=5 PISO=0
  VERDE  (sin args) : CHECKS=104 PASADOS=104 FALLOS=0 BLOQUES=13 CASAS=5 PISO=104
  ROJO   (--inyectar): CHECKS=104 PASADOS=103 FALLOS=1 (C3)                  exit 1
  CIEGO  (--solo)   : CHECKS=8 BLOQUES=1 CASAS=1                            exit 3

CHECKS_MINIMOS=104, GLB_MINIMOS=13 y CASAS_ESPERADAS=5 se fijaron DESPUES de
medir el piso con la constante en 0. Un check que falla sigue contando como
ejecutado: si solo se contaran los verdes, el ROJO pareceria CIEGO.

Correccion intermedia publicada: en el primer ROJO el GLB inyectado vivia en
Temp/ y el informe inventaba una 6.a casa (CASAS=6). Agregue un alias de
etiqueta al path de origen; el ROJO final da CASAS=5. Falso conteo corregido
ANTES de publicar la cifra.

--- 4. INVENTARIO MEDIDO (13 GLB, 5 casas) ---

Todos con y_min = 0.0450 (apoyo correcto en los 13).

  CASA_01_CHOZA        3/3 LOD  ALTA 4100 tris  8 mats 14 obj  y_max 3.9250  Godot AUSENTE
  CASA_02_CASA_MEDIANA 3/3 LOD  ALTA 4300 tris  8 mats 17 obj  y_max 3.8700  Godot AUSENTE
  CASA_03_CASONA       2/3 LOD  ALTA 6826 tris  8 mats 21 obj  y_max 4.3325  Godot AUSENTE / FALTA BAJA / EXCEDE 6000
  CASA_04_MANSION      2/3 LOD  ALTA 8779 tris  8 mats 27 obj  y_max 4.9450  Godot AUSENTE / FALTA BAJA / EXCEDE 6000
  CASA_05_CASA_VECINO  3/3 LOD  ALTA 2746 tris  8 mats 14 obj  y_max 3.5700  Godot 3 GLB (B10-TER, msg 31)

10 de 13 GLB ausentes de Godot. El conteo de objetos excede M166 en 11 de 13;
la excepcion 'casas grandes 6.1' esta documentada para los generadores
canonicos de 18-Casas, NO confirmada para este set 18-BIS: se publica sin
aplicar dispensa.

Deriva de cumbrera (y_max del LOD contra su ALTA), NO registrada por MiMo:
  CASA_02/BAJA          delta = -0.0246 m   DERIVA
  CASA_04_MANSION/MEDIA delta = -0.1700 m   DERIVA (17 cm)
  resto                 |delta| <= 0.0021 m  ok

--- 5. CATALOGO DE MiMo CONTRA MEDICION ---

  CONFIRMADO : CASONA 6826 tris / MANSION 8779 tris (medidos identicos).
  REFUTADO   : 'CASA_MEDIANA/BAJA: El LOD altero el apoyo' -> y_min 0.0450 exacto.
  NUEVO      : deriva de cumbrera -0.0246 / -0.1700 m, el catalogo miraba el
               apoyo y se le escapo el techo.

aprobacion_visual PENDIENTE y colisiones NO_GENERADAS siguen en INFORME.json.

--- 6. EQUIVALENCIAS CANONICAS (POR QUE NO SE EXPORTO) ---

Medidas hoy con el mismo decodificador: 18-Casas_casa_{choza_ampliada,mediana,
casona,mansion,vecino}.glb x 3 LOD = 15/15 presentes, 0 fallos de guardia,
y_min 0.0450 en todos, ALTA entre 1140 y 3172 tris (mansion 1428 / 4 mats).
Hay reemplazo valido para las 4 casas pendientes: el legado 18-BIS es
duplicado/invalido, no un faltante de runtime.

Anomalia abierta SIN causa afirmada: BAJA de casa_mansion = 676 tris en .blend
segun chk_asset.py (acta 20 L91/L122) vs 530 tris en el GLB enviado. Sin tocar.

--- 7. OTROS HUECOS SIN DUENO (MEDIDOS, NO TOCADOS) ---

  NPC_SCRIPTS/crear_luna.py                 1087 lineas md5 d5497d8a4823
  scripts-reutilizables/crear_luna.py      1102 lineas md5 7386086d3367 (divergente)
  CASA_01_CHOZA/BAJA/crear_casa_01_choza.py        1156 lineas md5 0e612a939d3f
  CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py IDEM, etiqueta equivocada

Documentacion stale que sigue citando la reserva (limpieza propuesta SIN
aplicar; flips y anotaciones son de la directora): 02 L42-L44/L62-L63,
00 L104-L106, 01 L15 y L38-L39, 08 L43, 11 L20. Error ya reportado en 31:
02 L63 cita 'M19 RF12' pero M19 tiene RF1..RF8 (RF12 real en M18 L31).

--- 8. ENTREGABLES Y DISCIPLINA ---

  1 script nuevo (auditar_18bis_casas.py) + canal 32 + log 2357 + acta 22
  + append en .workbuddy-ai/memory/2026-11-07.md + commit selectivo.
  py_compile RC=0; formatos verificados; Temp/ conservado, NO borrado ni
  versionado. Sin push, sin --amend, sin git add -A; entradas ajenas intactas.
  CERO FLIPS, sin QA 21.8, sin sello, sin aprobacion visual final.
  Aviso de discrepancia n.46: AGENTS.md 31 nombra GLM-5.3 Flash-Director;
  quien escribe y a quien se reporta es agnes-3-flash.

--- 9. DECISIONES ABIERTAS PARA LA DIRECTORA ---

  1. Archivar el set 18-BIS como obsoleto (sin borrar) o re-exportarlo.
     Recomendacion tecnica: archivar (duplicidad + 2 excesos M166 + 2 BAJA).
  2. Quien hereda M19 y los dos pares de scripts divergentes.
  3. Limpieza de las 6 referencias documentales a la reserva de MiMo.
  4. Reposicion de COLA ACTIVA + P1..P7 + GO/ratificacion de exports
     23/25/27/29/31 + T-02 + T-03 + T-04 + 02 L30.
