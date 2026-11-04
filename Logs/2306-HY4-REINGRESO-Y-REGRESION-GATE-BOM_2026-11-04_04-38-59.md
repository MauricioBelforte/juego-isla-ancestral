# Log 2306 - HY4 - Reingreso y regresion del gate de BOM

**Fecha:** 2026-11-04_04-38-59
**Agente:** HY4 (confirmado por el backlog DOCUMENTACION/TAREAS-POR-MODELO/HY4/
y por los commits 0abeab6 / 77e476d / 1b42656 / a0dd230 / 6b0622c).
**Alcance:** parche de hueco. No se toca QA 21.8 ni se voltean marcas.

## 1. Estado medido al volver (no heredado de la memoria)

- HEAD al llegar: 58f23fc (2-nov 06:05). Hoy 4-nov, 0 commits desde entonces,
  pero hay trabajo ajeno en vuelo de hoy 04:32 (log 2304 de DS-V4.1-Flash).
- Logs: mi ultimo fue 1189 (2-oct). Maximo real ahora: 2305. 2222 archivos .md.
- MEMORY.md del workspace fue consolidado por otro modelo el 2-nov 01:00; mis
  notas HY4 de octubre ya no estan ahi, pero el BACKLOG-MASTER de HY4 si las
  conserva (B0..B6, trampa 62). No se reescribio MEMORY.md: es ajeno.
- Protocolo nuevo adoptado: reservar_log.py (pool v3), log ASCII puro + CRLF,
  mensajes con canal propio y cabecera "Responde a:".
- Regla nueva respetada: NO TOCAR sin orden CHECKLIST-GLOBAL.md, quality.yml,
  AGENTS.md, project.godot ni 05-Checklist ajenos.
- CI: el job encoding-guard que deje en a0dd230 sigue vivo (quality.yml:835) y
  el verificador fue blindado por DeepSeek-WB en d25580a (UTF-16 + U+FEFF).

## 2. Hueco: el gate de BOM estaba en ROJO en HEAD

verificar_bom.py: 96 archivos con BOM, exit=1.
  91 Mensajes entre modelos / 2 game / 2 tools / 1 DOCUMENTACION.
Conteo crudo sobre git ls-files: 160. La diferencia son ~64 backups en
Obsoletos/encoding-backup-*, que el verificador excluye a proposito. No son
texto vivo y no se tocaron.

## 3. Accion (commit 3614c45)

--fix con pathspec exacto sobre 95 archivos (los 96 menos el protegido).
Resultado medido:

- 94 versionados con diff 1:1 (solo los 3 bytes EF BB BF de la linea 1).
- 74 byte-exactos contra HEAD[3:]; 20 iguales salvo normalizacion CRLF de
  git (core.autocrlf=true). Verificado que HEAD quedo con 0 BOM en los 94.
- 1 archivo NO versionado: NUMEROS_DISPONIBLES.txt de Reflection-Beam-1.0,
  ignorado por .gitignore:269. El --fix le quito el BOM igual. No se
  commitea; queda documentado como efecto colateral del escaneo.
- staged=0 antes y despues; add+commit encadenados con pathspec-from-file.

NO tocado:

- DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md (unico BOM
  que sigue viendo el gate). Es 05-Checklist ajeno: requiere orden del
  director. El gate sigue en rojo por ese archivo.
- 4 archivos con U+FEFF embebido (aviso, no bloquean).
- 12 colisiones de numeracion heredadas que reporta --estado (1290..2120).
- Las entradas del worktree ajeno.

## 4. Trampa nueva (63): medir un diff con rutas con espacios

Mi primer numstat dio "1 archivo" cuando habia 94. Causa: el shell partio los
pathspec de "Mensajes entre modelos/..." con el word splitting de
$(cat lista | tr '\n' ' '). No fue un fallo del fix, fue un fallo de la
MEDICION. Correccion: pasar los paths como argv desde python, o usar
git diff -z / --pathspec-from-file --pathspec-file-nul.

Corolario: comparar el disco contra `git show HEAD:<p>` tambien da un falso
fallo cuando core.autocrlf=true (el blob esta en LF y el disco en CRLF).
La guarda byte a byte debe normalizar CRLF antes de comparar, o apoyarse en
git diff --numstat.

Corolario 2: verificar_bom.py --fix no respeta .gitignore; puede tocar pools
de numeros no versionados. Es inofensivo aqui (quitar BOM a un .txt de
numeros), pero hay que saberlo antes de auditar el resultado.

## 5. Discrepancia de canal (reportar, no resolver)

No existe Mensajes entre modelos/HY4/. Si existen:

- DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOG-MASTER.md (mi backlog)
- 2 mensajes firmados HY4 en la RAIZ de Mensajes entre modelos/ (2-oct)
- columna Agente = Hy4 en CHECKLIST-GLOBAL (M137/138/139/140/142/143)

AGENTS.md 10.2 regla 1 dice que la carpeta de canal la CREA EL DIRECTOR al
asignar trabajo. No la cree. Queda pendiente de orden: si hay encargo nuevo,
pedir que se abra el canal y su archivo 01.

## 6. NO hice

- No voltee ningun [x] ni selle nada (QA 21.8, fuera del perfil Hy4).
- No toque CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md ni project.godot.
- No reescribi las 662 rutas desactualizadas del B6 (riesgo trampa 60).
- No resolvi H-1 (autoloads de localizacion duplicados): requiere dueno.
