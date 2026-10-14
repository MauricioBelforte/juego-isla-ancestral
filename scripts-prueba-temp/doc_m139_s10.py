# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.7.1 Save v3 + menu de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 10 del checklist. **El motor de save ya esta implementado y verificado:**

| Componente | Archivo | Cubre |
|---|---|---|
| Schema versionado | `scripts/saving/save_schema.gd` | `schema_version` por save (M60) |
| Escritura | `scripts/saving/save_writer.gd` | escritura + temp/rename (transaccional) |
| Carga | `scripts/saving/save_loader.gd` | carga por slots |
| Snapshots | `scripts/saving/save_snapshot.gd` | estado consistente por guardado |
| Integridad | `scripts/saving/validate_save.gd` + `test_checksum_hmac.gd` | validacion y checksum HMAC (M66) |
| Backups | `scripts/saving/save_backup.gd` + `test_backup_rotations.gd`, `test_rotate_m59.gd` | rotacion y recuperacion (M107) |
| Slots | `test_slots_m59.gd`, `test_slot_range.gd` | multiples partidas |
| Proveedores | `save_provider.gd`, `player_save_provider.gd`, `buildings_save_provider.gd` | ISaveProvider por sistema (M59) |
| Limites | `test_save_size_cap.gd` | tope de tamano de save |

**Versionado de schema (M60):** cada save guarda `schema_version`. Al cargar, si la version es
menor se migra en cadena (`migrar_v1_a_v2`, `migrar_v2_a_v3`); si es mayor, se rechaza con mensaje
claro. La version actual de fase es **3**.

**Escritura transaccional:** el writer escribe a `.tmp`, hace `rename()` atomico y solo despues
borra el backup previo. Verificado por el fix BUG-112 (rotate devuelve false si algun rename falla).

**Verificacion de integridad al continuar (M66):** `validate_save.gd` valida manifest y checksum
HMAC antes de entrar al mundo. Si falla, se ofrece recuperar la copia alternativa; si tambien
falla, se ofrece empezar partida nueva (nunca se pierde el acceso al juego).

**Recuperacion con copia alternativa:** la rotacion guarda la ultima version valida como
`backup`. La secuencia es: intentar save actual -> intentar backup -> ofrecer partida nueva.
Tests: `test_backup_rotations.gd` y `test_rotate_m59.gd`.

**Carga < 2 s en 20/20 ciclos:** criterio de fase. Los ciclos guardar/cargar estan cubiertos por
`test_autosave_m59.gd` y `test_close_save.gd`; el umbral de 2 s se mide con el StreamManager y la
pantalla de carga existente (la barra refleja progreso real).

**Menu principal (definido, M53/M92):** 4 opciones — **Continuar** (ultimo slot), **Nuevo juego**,
**Ajustes** (M57/M58: idioma, audio, accesibilidad) y **Creditos**. Fondo: la escena del puerto de
Aurora con camara lenta. No existe aun en disco: es la pieza de UI que falta para la fase.

**UI deshabilitada durante cargas (regla §8 AGENTS.md):** `scripts/stream/pantalla_carga.gd`
(M63 P1) ya es un CanvasLayer con barra ColorRect y bloqueo de input; la regla se mantiene — la UI
nunca recibe eventos mientras la barra esta activa.

**Pantalla de carga con barra y mensajes:** ya implementada — barra de progreso **real** del
StreamManager + consejos de mundo rotando (`tips.txt` via `ConsejosCarga`) + fundido. Sin
`tips.txt`, la pantalla funciona igual.

**Flujo "nuevo juego" con confirmacion:** si hay save en el slot, se pide confirmacion explicita
("¿Sobrescribir la partida guardada?") con el tiempo de juego y la fecha del save. No se sobrescribe
nunca en un solo click.

**Navegacion con gamepad y teclado (M57/M58):** `menu_navigator.gd` existe (con test M64). Regla:
todo elemento del menu es alcanzable con flechas + A/Enter, con focus visible y sin trampas de
foco; el gamepad se puede usar en todo momento (nunca se exige mouse).

**Tutorial visual sin texto (M92):** `tutorial_manager.gd` (autoload "Tutorial") ya orquesta
capitulos con pasos PISTA/SECUENCIA/CONSEJO y triggers por senal. La fase exige que los **primeros
3 pasos sean 100% visuales** (mover -> mirar -> interactuar: iconos en mundo, sin texto). Los
consejos de texto quedan para despues del tercer paso.
"""

ancla = "### 2.8 Audio global (M41-M44)"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.7.1 insertada")
else:
    print("AVISO: ancla no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
