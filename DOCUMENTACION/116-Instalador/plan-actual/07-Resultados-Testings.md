**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 116: Instalador

## 1. Resumen de la iteración 2 (2026-09-13, Log 877)

| Suite | Checks | Fallos | SCRIPT ERROR | Veredicto |
|---|---|---|---|---|
| `test_instalador_m116.gd` (corrida 1) | 15 | 0 | 0 | ✅ |
| `test_instalador_m116.gd` (corrida 2) | 15 | 0 | 0 | ✅ |
| `test_instalador_m116.gd` (corrida 3) | 15 | 0 | 0 | ✅ |
| `test_build_m117.gd` (regresión) | 14 | 0 | 0 | ✅ |
| Parse check PowerShell (2 scripts) | 2 | 0 | — | ✅ |
| Smoke `-DryRun` (setup + uninstall) | 2 | 0 | — | ✅ |

**Total: 0 fallos, 0 SCRIPT ERROR.** Resultado idéntico en las 3 corridas.

## 2. Validador sobre el repo real (bloque A)

```
[M116] ValidadorInstalador: 61 checks, 0 error(es), 0 aviso(s)
  -> pipeline de distribucion COHERENTE
```

Cubre las 11 familias de reglas (V1..V11) descritas en el validador.

## 3. Meta-tests: el validador detecta los fallos (bloques B-F)

Cada bloque construye un repo falso **en memoria** (fixtures), rompe una cosa y
comprueba que el validador lo detecta. Sin esto, un validador que siempre
devolviera "OK" pasaría el bloque A.

| Bloque | Falla inyectada | Detectada |
|---|---|---|
| B | `.iss` sin secciones | ✅ error V1 |
| C | `.ps1` con solo un BOM de 3 bytes | ✅ errores V5 + V11 |
| D | `[UninstallDelete]` con `{app}\savegames` | ✅ error V8 |
| E | `AppVersion` = 9.9.9 vs 0.0.2 del proyecto | ✅ error V3 |
| F | preset `Web` en lugar de `Windows Desktop` | ✅ error V6 |

El bloque C reproduce **exactamente** el defecto de la iteración 1.

## 4. Smoke funcional de los scripts (CP-10/CP-11/CP-12)

```
===== setup_windows.ps1 -DryRun -NoShortcuts =====
  -- Validacion del build --
    [DRY-RUN] ejecutable valido
    [AVISO]   no hay isla-ancestral.pck suelto; se asume .pck embebido
  -- Requisitos del sistema --
    [DRY-RUN] Windows 10.0 compatible
    [DRY-RUN] sistema x64 compatible (proceso 64-bit)
    [DRY-RUN] espacio libre suficiente
  -- Instalacion --
    [DRY-RUN] 1 archivo(s) copiados
  -- Registro de desinstalacion --
    [DRY-RUN] registrar en HKCU\...\Uninstall\IslaAncestral
  Acciones: 9 | Errores: 0
  >>> RC = 0

===== uninstall_windows.ps1 -DryRun -Force =====
  -- Datos del usuario --
    [DRY-RUN] conservados: %APPDATA%\Godot\app_userdata\isla-ancestral
  Acciones: 1 | Errores: 0
  >>> RC = 0

DryRun creo el destino? False   (debe ser False)
```

Esto cierra el `[?]` de la iteración 1, que afirmaba que el smoke era imposible
porque "el host de agentes no captura el host-stream de scripts .ps1". **Sí era
posible**: ejecutando el script in-process y redirigiendo la salida a un archivo.

### 4.1 Bugs reales que encontró el smoke

| # | Síntoma | Causa | Corrección |
|---|---|---|---|
| 1 | `[ERROR] se requiere x64 (detectado )` — abortaba en un sistema válido | `$env:PROCESSOR_ARCHITECTURE` llega **vacío** según el host | usar `[System.Environment]::Is64BitOperatingSystem` / `Is64BitProcess` |
| 2 | El desinstalador no imprimía **nada** y moría antes del primer mensaje | `$env:APPDATA` nulo → `Join-Path` lanza y `$ErrorActionPreference="Stop"` aborta | usar `[Environment]::GetFolderPath("ApplicationData"/"LocalApplicationData")` |

Ninguno de los dos se habría detectado sin ejecutar el script.

## 5. Bugs del propio validador (encontrados por el test)

| # | Síntoma | Causa | Corrección |
|---|---|---|---|
| 1 | V7 fallaba con `game/build/web` | `_valor_cfg` leía el **primer** `export_path` del archivo (el del preset `Web`) | `_export_path_windows()` acota la búsqueda al bloque del preset de Windows |
| 2 | V7 fallaba comparando rutas | `simplify_path()` **no resuelve** `..\` escrito con barras invertidas | `_norm()` normaliza `\` → `/` antes de simplificar |
| 3 | V8 daba falso positivo | el comentario `;` del `[UninstallDelete]` decía "no borrar los savegames" y contenía las palabras prohibidas | `_bloque()` descarta las líneas de comentario antes de comprobar |

## 6. Errores del proceso de test (para no repetirlos)

| # | Síntoma | Causa | Corrección |
|---|---|---|---|
| 1 | El test agotó el tiempo de ejecución | `_repo_falso()` copiaba el árbol `scripts/` completo 5 veces | fixtures construidos en memoria, sin copiar el repo |
| 2 | `-- Repo: .../juego-isla-ancestral/game` | `res://` apunta a `game/isla-ancestral/`: la raíz está **dos** niveles arriba, no uno | `path_join("..").path_join("..")` |
| 3 | El splatting `@($array)` no pasaba argumentos | `@(expr)` no es splatting válido en PowerShell | pasar los parámetros explícitamente |

## 7. Pendiente de validación manual

Compilación real con Inno Setup, firma con certificado, instalación limpia en una
máquina sin el juego, y verificación con antivirus. Requieren herramientas y
entorno que no están disponibles aquí.

## 8. Conclusión

La parte automatizable del pipeline de distribución queda **verificada y
protegida contra regresión**: el validador impide que vuelva a colarse un script
vacío, un `[UninstallDelete]` destructivo, una versión desalineada o un preset
ausente. Lo que no se puede verificar sin Inno Setup ni certificado queda
explícitamente listado en §7.
