# B5 - Scratch relocalizado desde `game/` (NO BORRAR)

**Fecha:** 2026-11-04.
**Motivo:** B5 (Log 1190 / reauditoria HY4). Estos 22 scripts son de un solo
uso: flips de checklist, parches y diagnosticos con rutas absolutas de esta
maquina. Godot ignora los `.py`, pero ensucian el arbol de runtime y el conteo
de scripts del proyecto.

**Regla aplicada:** el scratch se **relocaliza**, nunca se borra. Se uso
`git mv` a una carpeta **versionada** (no `Obsoletos/raiz-temporales-*/`, que
esta ignorada por `.gitignore:246` y sacaria los bytes del historial).

**Criterio de seleccion (medido):** cero referencias en los 19870 archivos
versionados del repo (incluidos `.gd`, `Logs/` y `Mensajes entre modelos/`),
sin cambios ajenos en el worktree y sin uso relativo a su propia ubicacion.
Quedan en `game/` los scripts de autoria Blender (29, territorio M36/M50),
los generadores M162, las herramientas M100/M88 y `validate_dialogues.py`
(resuelve `data/dialogues` con `os.path.dirname(__file__)`).

| Origen (`game/isla-ancestral/` +) | Destino (esta carpeta +) | sha256 | Bytes | mtime |
|---|---|---|---|---|
| `scripts/saving/_bis_rw.py` | `scripts/saving/_bis_rw.py` | `f12cb06ce26aa5ec` | 2102 | 2026-10-22 00:30 |
| `scripts/saving/_bloque_f.py` | `scripts/saving/_bloque_f.py` | `3e870d6c0b006dd8` | 1760 | 2026-10-21 21:49 |
| `scripts/saving/_chk_opts.py` | `scripts/saving/_chk_opts.py` | `3ed1af7585d05fee` | 993 | 2026-10-20 02:21 |
| `scripts/saving/_cron_doc.py` | `scripts/saving/_cron_doc.py` | `f66685046e85bc05` | 1819 | 2026-10-22 00:27 |
| `scripts/saving/_ext_k32.py` | `scripts/saving/_ext_k32.py` | `49ccd4f463bd9bc1` | 1259 | 2026-10-20 02:53 |
| `scripts/saving/_filas3.py` | `scripts/saving/_filas3.py` | `6603cbdafb80bc45` | 702 | 2026-10-21 19:43 |
| `scripts/saving/_flip_item8.py` | `scripts/saving/_flip_item8.py` | `715cd06f5396a267` | 3305 | 2026-10-20 06:10 |
| `scripts/saving/_flip_item8b.py` | `scripts/saving/_flip_item8b.py` | `0d87a6f66c1049a0` | 3237 | 2026-10-20 06:11 |
| `scripts/saving/_flip_item8c.py` | `scripts/saving/_flip_item8c.py` | `8be2a63b1f21fb2a` | 3676 | 2026-10-20 06:11 |
| `scripts/saving/_flip_item8d.py` | `scripts/saving/_flip_item8d.py` | `ce1c5b3006c8f999` | 3265 | 2026-10-20 06:11 |
| `scripts/saving/_flips_prov.py` | `scripts/saving/_flips_prov.py` | `d4a93bd28a2dc303` | 2454 | 2026-10-21 16:22 |
| `scripts/saving/_flips_t17.py` | `scripts/saving/_flips_t17.py` | `76eb9d15fa843bf2` | 4353 | 2026-10-20 01:53 |
| `scripts/saving/_item4.py` | `scripts/saving/_item4.py` | `787f1426dbe73ec4` | 2550 | 2026-10-21 14:50 |
| `scripts/saving/_mec63.py` | `scripts/saving/_mec63.py` | `c79038d7d01beb4a` | 635 | 2026-10-20 02:21 |
| `scripts/saving/_paso0.py` | `scripts/saving/_paso0.py` | `18b094437df26e57` | 630 | 2026-10-21 18:20 |
| `scripts/saving/_pid_r1.py` | `scripts/saving/_pid_r1.py` | `ab3524d181b38e74` | 926 | 2026-10-20 06:09 |
| `scripts/saving/_qa_bm_v3.py` | `scripts/saving/_qa_bm_v3.py` | `fc59f8ce09015254` | 5103 | 2026-10-21 14:34 |
| `scripts/fasttravel/_flips_t9.py` | `scripts/fasttravel/_flips_t9.py` | `e1bafca6406bcc15` | 3238 | 2026-10-20 00:31 |
| `scripts/crafting/_parche_test_m16.py` | `scripts/crafting/_parche_test_m16.py` | `4dfc705c686eec01` | 1430 | 2026-10-20 01:04 |
| `scripts/expandir_hitos.py` | `scripts/expandir_hitos.py` | `174596a3a1d15f0a` | 4010 | 2026-09-05 22:18 |
| `scripts/debug_imposibles.py` | `scripts/debug_imposibles.py` | `262e9147d4a3f2d1` | 505 | 2026-09-05 22:20 |
| `scripts/debug_stats_validos.py` | `scripts/debug_stats_validos.py` | `14ffc49d5b38d148` | 510 | 2026-09-05 22:20 |

Los `sha256` completos se verificaron byte a byte con el origen antes de
aceptar cada `git mv`. Cualquier restablecimiento se hace con `git mv` inverso.

**No se toco:** M18-BIS (MiMo), M19-NPCs, `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot`, ni `05-Checklist.md` ajenos.

