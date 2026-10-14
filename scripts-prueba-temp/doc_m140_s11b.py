# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """
### 4.1 Save y persistencia de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 11 del checklist. Verificado contra disco:

**Extension por providers (ISaveProvider):** 6 providers verificados — `combat_island`, `gem`,
`buildings`, `lore`, `player`, `tools`. La arquitectura de extension existe y funciona por proveedor,
no por mundo entero.

**Hallazgo honesto de version (importante):** `save_schema.gd` declara **`SCHEMA_VERSION = 1`** y
`save_loader.gd` documenta *"v1 es la primera version, sin migraciones por ahora"*. Es decir: el save
**esta en v1, no en v3** — la infraestructura de migracion (M60) existe pero **no hay migraciones
registradas**. Los items que hablan de "v3" se evaluan contra esa realidad.

**Migracion versionada (v3 -> v3.1):** **ausente** — v1 no tiene migraciones. Queda `[ ]` con nota:
cuando se agreguen sellos/colecciones/almanaque al save habra que versionar a v2 con migracion
solo-hacia-adelante (regla ya escrita en `save_loader.gd`).

**Flags globales de historia y artefactos:** **ausentes** — no hay un registro de flags globales; hoy
el estado vive por proveedor. Queda `[ ]` con nota: se resuelve con el mismo versionado (v2) cuando
el sistema de sellos (1.4) necesite persistir.

**30 ciclos de guardar/cargar sin perdidas:** **superado** — `SaveLoadStress` (M113, en
`scripts/stress/escenarios/`) corre **100 ciclos** midiendo integridad de cada uno (0 corrupcion).
Supera el umbral de 30.

**Recuperacion de save corrupto con copia (M66):** presente — `backup_manager.gd` + la secuencia
save actual -> backup -> partida nueva definida en M139 2.7.1, con checksum HMAC de `validate_save.gd`.

**Telemetria de tamano de save por zona:** definida aca — cada provider reporta el tamano de su bloque
al telemetro local (M104/M105); el dashboard (2.8.1) muestra el top de bloques mas pesados. Hoy existe
`test_save_size_cap.gd` (tope de tamano) como base.
"""

t = t.rstrip("\n") + "\n" + seccion
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("seccion 4.1 insertada al final")
