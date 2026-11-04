# LOG 2311 - HY4 - B10: AUTORIA HEADLESS "COLUMNA ROTA" (M25)

Fecha: 2026-11-04 18:43
Agente: HY4 - perfil Blender/3D, parcheo de huecos
Modulo: BLENDER-M25 / 25-Ruinas-Templos
Estado: CERRADO (autoria + auditoria numerica + capturas). SIN sello, SIN QA 21.8.
Canal: mensaje 03 de "Mensajes entre modelos/HY4/".

## 0. Origen y por que M25

El fundador pidio retomar el hilo de Blender INDEPENDIENTE (el trabajo viejo
de ~93 assets hecho "sin el protocolo", sin registro en TAREAS-POR-MODELO).
Medido 2026-11-04: CHECKLIST-OBJETOS-BLENDER.md L174 seguia en [ ] con
"Columna rota (2 variantes de altura)" y en M25 habia 0 .blend y 0 GLB con
columna/dintel/bloque. Diseno M25 03-Diseno.md: pieza 17 `pilar_roto`
1x1x1.5 (soporte) y pieza 31 `fuste_columna` (fragmento horizontal).
No se toco M19 ni M18-BIS (reservados por MiMo). M25 no tenia dueno activo
en la tabla medida de CHECKLIST-GLOBAL.md.

## 1. Entregable VERSIONABLE (uno solo)

tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_columna_rota_lowpoly.py

Es la FUENTE: reproduce los 2 .blend de ALTA con un solo comando headless.
Los .blend estan en .gitignore:228 ("Assets pesados de Blender - usar Git LFS
si se necesitan") y las capturas en .gitignore:104 (**/capturas/). NO se hizo
`git add -f`: forzar binarios violaria la politica explicita del repo. Los
6 .blend, 12 PNG y 2 JPG quedan en disco como ARTEFACTOS LOCALES
REPRODUCIBLES, no versionados. Los .blend de assets viejos SI estan
trackeados, pero son herencia anterior a la regla; no se usa como precedente
para saltarsela.

## 2. Pipeline 100 % headless (sin GUI ni socket 9876)

Blender 4.2.23 LTS, `-b --factory-startup --python`.
  crear_columna_rota_lowpoly.py         -> 2 ALTA (H=1.50 / H=2.20)
  generar_variante_headless.py          -> MEDIA + BAJA de cada ALTA
  capturar_angulos_headless.py          -> 6 azimuts por variante (12 PNG)
  contact_sheet.py (py -3, PIL 12.2.0) -> 2 hojas 2x3, 6 capturas CADA una
  chk_asset.py                          -> auditoria numerica de los 6 .blend
No se uso bpy_cliente, socket MCP ni addon de GUI.

## 3. Mediciones REALES (chk_asset.py; ninguna estimada)

  perfil  variante  obj  tris  mats  z_min   bbox Z
  ALTA    baja      12   464   5     0.0450  0.045 .. 1.490 (alto 1.445)
  ALTA    alta      12   464   5     0.0450  0.045 .. 2.190 (alto 2.145)
  MEDIA   baja       5   464   5     0.0450  0.045 .. 1.490
  MEDIA   alta       5   464   5     0.0450  0.045 .. 2.190
  BAJA    baja       4   304   4     0.0450  0.045 .. 1.491
  BAJA    alta       4   303   4     0.0450  0.045 .. 2.191

Presupuesto M166: ALTA 16/6000/12, MEDIA 8/1500/8, BAJA 6/700/4. Cada
blend pasa SU perfil. chk_asset.py evalua los 3 perfiles contra CADA
archivo, asi que los "NO MEDIA"/"NO BAJA" impresos sobre un ALTA son
esperados y NO son fallos de este asset.

## 4. Guardias medidas en verde (todas por ejecucion real)

- E-12/E-24: z_min del grupo 0.0450 en los 6 blends.
- E-50: toca=28 vertices, huella 1.23 x 0.95 (> 0.30 en X e Y).
- Apoyo POR PIEZA (E-37/E-52): las 6 piezas que deben apoyar (Basa,
  Fragmento, Fragmento_Banda y 3 Escombro) miden z_min=0.0450 cada una.
- ALTURA_REAL: z_max medido 1.4900 y 2.1900. Necesario porque los dos
  .blend de ALTA tienen EXACTAMENTE el mismo tamanio en bytes (binario de
  floats de ancho fijo: cambian las coordenadas, no el tamanio). El tamanio
  NO prueba que existan dos variantes; el sha256, el bbox Z y esta guardia
  SI. chk_asset.py confirmo las alturas por fuera del generador.
- UNION_FUSTE_CORONA: tope del fuste = base de la corona = z1 (1.2200 baja /
  1.9200 alta), sin aire. La corona NO apoya en el suelo, asi que
  "z_min >= Z_APOYO" no alcanza para descartar que flote.

## 5. Iteraciones (todas con REGENERACION COMPLETA)

- v1: corona con onda suave +/-0.07 m -> el corte se leia como cilindro limpio.
- v2: DIENTES deterministico de 16 valores (min -0.24 m, corte real de
  23 cm), 3 escombros, piedra mas oscura, flutas de 0.040.
- v3: centro de la tapa BAJADO por debajo de todos los dientes (H-0.26) y
  perfil sin alternancia regular. Motivo MEDIDO: ampliando la corona se veian
  triangulos de la tapa asomando por las muescas como esquirlas
  aparentemente flotantes y un hueco oscuro. Era geometria, no iluminacion.
- v4: guardia positiva de union fuste/corona (no cambia geometria).

En cada vuelta se regeneraron fuentes + MEDIA/BAJA + 12 capturas + 2 hojas:
NO quedo ningun artefacto de una version anterior del generador.

## 6. Revision visual (tecnica, NO aprobacion estetica)

12 PNG 1200x800 (6 por variante) + 2 hojas de contacto con 6 capturas cada
una (guardia E-30/E-66: ninguna hoja de una sola captura disfrazada de QA).
Sin aire entre basa, fragmento caido, escombros y arena en los 6 angulos.
La franja clara vertical del fuste es una faceta iluminada del MISMO mesh,
no geometria separada. El triangulo claro que asoma por una muesca de la
corona es un diente del lado POSTERIOR: hay 12 objetos SM_ y la union
fuste/corona esta medida en z1; no hay malla suelta.
Caveat: exposicion/iluminacion vienen de iluminar() de plantilla_asset.py,
compartida por todos los assets; no se toco.

## 7. NO se hizo (limites del rol)

- Flip de CHECKLIST-OBJETOS-BLENDER.md L174: se PROPONE, no se aplica.
- QA 21.8, auto-QA, sellos, aprobacion visual final, GLB / export a game/.
- Tocar CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot,
  05-Checklist ajenos, M19, M18-BIS, ni los cambios en vuelo de Hy3.
- push, --amend, git add -A, git add -f de binarios ignorados.

## 8. Pendiente para la directora

- P1: flip de la marca L174 (las marcas son decision de direccion).
- P2: decidir si se configura Git LFS o los .blend siguen siendo locales.
- P3: si el asset debe entrar al juego, correr exportar_godot.py (no corrido).
- P4: aprobacion visual por otro modelo (QA cruzada, nunca auto-QA).
- Aviso de discrepancia de direccion: AGENTS.md seccion 31 nombra
  GLM-5.3-Flash-Director; el canal HY4 venia dirigido a agnes-3-flash y el
  mensaje 481 de Hy3 va a glm-5.3-flash-director. Reporto a quien escribe.

## 9. Cierre administrativo

Log 2311 reservado con reservar_log.py (pool v3, cabeza 2311, sin archivo
de reserva). Mensaje 03 reservado con proximo_numero.py HY4 --consume
(pool del canal: cabeza 3, sin colisiones). Se uso "03-" y no "003-"
para conservar el orden lexicografico con 01-/02-; el helper parsea
^(\d{1,3})- y sigue devolviendo 4.
Dos commits selectivos (codigo / documentacion), sin push.
