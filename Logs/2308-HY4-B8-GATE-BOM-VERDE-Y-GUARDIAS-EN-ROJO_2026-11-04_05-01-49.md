# Log 2308: HY4 - B8 - gate de BOM en verde, causa raiz y guardias probadas en rojo

**Fecha:** 2026-11-04
**Hora:** 05:01
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Canal:** `Mensajes entre modelos/HY4/` (mensaje 01, apertura autorizada por el fundador)
**Rol:** parcheo de huecos / auditoria de tooling. No sella, no hace QA cruzado.
**Reserva:** 2308, pool v3 (`reservar_log.py --reservar --agente HY4 --modulo BOM-GATE`)

## 1. Estado medido al iniciar

- HEAD `95aab9d`, staged 0. Worktree con 4 entradas ajenas, todas intactas.
- `verificar_bom.py` -> exit 1, 1 archivo con BOM:
  `DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md`.
- 25 carpetas de canal, ninguna HY4. Backlog HY4 de 505 lineas con B7 cerrado.
- Pool de logs: 693 libres (primero 2308). `Logs/*.md`: 2212 numeros.
- Ultimo mensaje vivo de la flota: 241 (4-nov 07:30), firmado
  "agnes-3-flash (directora)".

## 2. Autorizaciones del fundador (chat, 2026-11-04)

1. Limpiar los 3 bytes de BOM del `05-Checklist` ajeno de M138.
2. Crear el canal `Mensajes entre modelos/HY4/`.
3. Elegir el hueco siguiente segun las capacidades medidas de Hy4 en la guia
   comparativa (sec. 15), investigando en la web solo si no estuviera en ella.

Hy4 YA ESTABA en la guia (sec. 15 + ficha 5.G). No hizo falta investigar
capacidades en la web ni adjudicarse areas nuevas: se verificaron con numeros
las fortalezas que el propio sec. 15 declaraba el 2026-09-06 (diagnostico de
causa raiz de tooling y cadenas multi-paso con verificacion al final).

## 3. Cerrado en esta tanda

1. **BOM de M138**: quitados exactamente 3 bytes (`EF BB BF`), diff 1:1 medido
   byte a byte, 28967 -> 28964 bytes. `verificar_bom.py` sobre el repo real
   paso a **exit 0** (verde). Permanecen 4 avisos de `U+FEFF` embebido, que no
   bloquean por diseno (fixtures/citas legitimas, ver docstring del verificador).
2. **Causa raiz de la reincidencia, MEDIDA**: sobre los ultimos 25 commits se
   midio que los BOM se reintroducen mayoritariamente en mensajes de canal
   escritos por otros agentes (hasta 6 por commit: `6c9eee8`, `b90440a`,
   `8677142`; tambien `58f23fc`, `2ec24b0`, `22c2bcf`, `88196e6`) y en 2 pools.
   No es un defecto de codigo. La limpieza masiva de B7 (94 archivos) trato el
   sintoma; el gate de CI es la contencion, no la cura.
3. **`scripts/verificar_bom.py` endurecido**: `--fix` ahora filtra con
   `git check-ignore -z --stdin` (antes mutaba archivos ignorados que CI nunca
   ve: caso real `Reflection-Beam-1.0/NUMEROS_DISPONIBLES.txt`), **falla
   cerrado** si git no responde (aborta antes de mutar nada) y escribe con
   `os.replace` atomico en vez de `open('wb')` in-place (trampa 18). El modo
   informe que usa CI no cambio: mismos exit 0/1 y mismas exclusiones.
4. **`scripts/test_verificar_bom.py` (nuevo)**: prueba end-to-end por RUTA REAL,
   no de funciones sueltas. Copia el CLI a un repo temporal con marcador
   `AGENTS.md`, inyecta 9 fixtures y mide exit codes. Resultado **26 checks /
   0 fallos**; `CHECKS_MINIMOS=26` medido en verde y fijado despues de medir.
   Incluye control negativo (archivo limpio NO se reporta), guardia en rojo
   (BOM inyectado -> rc 1), verde (rc 0), `--estricto` (rc 1) y `--fix`.
5. **Guardias probados EN ROJO por inyeccion** (sobre copias temporales, sin
   tocar el repo): con `rutas_ignoradas()` rota para devolver vacio -> **6 FAIL,
   exit 1** (el archivo ignorado se muta y el fail-closed desaparece); con un
   bloque de la suite no llamado -> **CIEGO, exit 3**; control intacto -> 0.
   Sin esta prueba, un "26/0" no seria evidencia de nada.
6. **Canal HY4 abierto**: carpeta + pool 1..200 (UTF-8 sin BOM, LF; no
   versionado por `.gitignore:269`). `proximo_numero.py HY4 --consume` devolvio
   1 y lo quito del pool. Mensaje `01-...-hy4-a-agnes-3-flash-...md` escrito con
   acta de apertura + informe B8. Excepcion a sec. 10.2 regla 2 declarada en el
   propio archivo: el `01` normalmente lo escribe el director; aca lo autorizo
   el fundador y NO es el prompt de partida (el encargo sera el `02`).
7. **`DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` sec. 15.9**: evidencia
   medida de la sesion, sin areas nuevas y sin benchmarks sin validar.
8. **Backlog HY4**: B7 pendiente de autorizacion BOM marcado resuelto, seccion
   B8 agregada, `- [x] Log reservado: 2308`.

## 4. Trampa nueva (64)

**Un `--fix` que no distingue versionado de ignorado miente en verde local.**
CI corre sobre checkout limpio: nunca ve el archivo ignorado. El fix local si lo
veia y lo reescribia, asi que el estado "limpio" medido en local no era el mismo
que el de CI. Corolario: si `git check-ignore` falla, la unica salida honesta es
abortar sin mutar, no "seguir con todo". Corolario 2: el piso de checks hay que
medirlo en verde Y probarlo en rojo quitando un bloque; un test que no corre sus
bloques da 0 fallos y es un falso verde (regla del fundador 2026-09-19).

## 5. Discrepancias reportadas, NO corregidas

- `AGENTS.md` sec. 31 / 29.1 nombran director a `GLM-5.3 Flash-Director`, pero
  `estado_director.json` lo da por historico (descartado por el fundador el
  23-oct) y quien firma hoy como directora es `agnes-3-flash`. Se reporta a
  quien escribe. `AGENTS.md` esta protegido: no se toca.
- sec. 29.1 dice "backlogs en los canales del director"; GUIA-COMUNICACION
  corrige: viven en `DOCUMENTACION/TAREAS-POR-MODELO/`.
- sec. 7 manda marcar `[x]` en `CHECKLIST-GLOBAL.md`, protegido sin orden.
- `quality.yml` protegido y SIN tocar: `encoding-guard` sigue ejecutando solo
  `verificar_bom.py`. La suite nueva NO esta en CI todavia -> pedido a la
  directora.

## 6. Lo que NO hice

No flips de marcas ajenas, no QA cruzado sec. 21.8, no sellos, no aprobacion
visual final, no `git add -A`, no `--amend`, no push, no tocar `AGENTS.md`,
`CHECKLIST-GLOBAL.md`, `quality.yml`, `project.godot` ni otros `05-Checklist`
ajenos. Las entradas del worktree de otros agentes quedaron intactas. El pool
de logs y el pool del canal NO se commitean (protocolo v3 / `.gitignore`).

## 7. Verificacion de formato de este log

ASCII puro (0 bytes > 127), CRLF, sin BOM, sin U+FFFD. Codigo nuevo: UTF-8 sin
BOM, LF, sin U+FFFD. Mensaje de canal: UTF-8 sin BOM, LF.

**Firma:** Hy4 (WorkBuddy) - 2026-11-04 - Log 2308 - B8
