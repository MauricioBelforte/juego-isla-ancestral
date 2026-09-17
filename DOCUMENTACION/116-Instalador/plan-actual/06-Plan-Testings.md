**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 116: Instalador

> **Corrección (iter. 2, Log 877):** el `04-Codigo.md` de la iteración de diseño
> declaraba "06-Plan-Testings.md: NO APLICA (módulo de instalador, sin código de
> gameplay)". Eso es falso: la parte verificable del módulo (coherencia del
> pipeline de distribución, encoding, regresiones) **sí** es testeable de forma
> headless y determinista. Este archivo reemplaza aquella afirmación.

## 1. Alcance

Se testea la **coherencia del pipeline de distribución**, no la ejecución de un
instalador real (eso requiere Inno Setup, Windows SDK y una máquina limpia).

Lo que **sí** se verifica headless, sin dependencias externas:

- estructura y claves de `installer/IslaAncestral.iss`
- coherencia de versión entre `.iss` y `project.godot`
- presencia de los `#include` y de sus declaraciones Pascal
- que los `.ps1` tengan contenido real y declaren sus parámetros
- que `export_presets.cfg` tenga el preset de Windows correcto
- que la carpeta de build sea la MISMA en preset, `.iss` y `.ps1`
- que `[UninstallDelete]` no borre datos del usuario
- licencia, scripts de firma y de build
- encoding sin BOM de todos los artefactos
- **que el propio validador detecte** cada uno de esos fallos (meta-tests)

## 2. Herramientas

| Herramienta | Ruta |
|---|---|
| Validador | `game/isla-ancestral/scripts/build/validador_instalador.gd` |
| Test | `game/isla-ancestral/scripts/build/test_instalador_m116.gd` |
| Parser de PowerShell | `[System.Management.Automation.Language.Parser]::ParseFile` |
| Smoke funcional | ejecución in-process de los `.ps1` con `-DryRun` |

Ejecución:

```bash
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/build/test_instalador_m116.gd
```

## 3. Casos de prueba

| CP | Bloque | Qué comprueba | Resultado esperado |
|---|---|---|---|
| CP-01 | A | El repo real pasa el validador | 0 errores |
| CP-02 | A | El validador ejecuta >= 40 checks | sí (61) |
| CP-03 | B | Detecta un `.iss` sin secciones requeridas | error V1 |
| CP-04 | C | Detecta un `.ps1` vacío (BOM de 3 bytes) | errores V5 + V11 |
| CP-05 | D | Detecta `[UninstallDelete]` que borraría las partidas | error V8 |
| CP-06 | E | Detecta `AppVersion` desalineada con `project.godot` | error V3 |
| CP-07 | F | Detecta un preset sin `Windows Desktop` | error V6 |
| CP-08 | G | Ningún artefacto de `installer/` lleva BOM | 0 con BOM |
| CP-09 | — | Los 2 `.ps1` parsean sin `ParserError` | 0 errores |
| CP-10 | — | `setup_windows.ps1 -DryRun` | RC=0, 0 errores, sin efectos |
| CP-11 | — | `uninstall_windows.ps1 -DryRun -Force` | RC=0, 0 errores, sin efectos |
| CP-12 | — | `setup_windows.ps1` con build inexistente | aborta (validación RF12) |
| CP-13 | — | Regresión M117 tras añadir el preset | 14 checks, 0 fallos |
| CP-14 | — | Determinismo: 3 corridas consecutivas | mismo resultado |

## 4. Casos NO cubiertos (con motivo)

| Caso | Motivo |
|---|---|
| Compilación real con `ISCC.exe` | Inno Setup no está instalado en el entorno |
| Firma real con `signtool` | requiere un certificado .pfx de una CA |
| Instalación real en `%LocalAppData%` | el host de agentes bloquea procesos hijos y no debe modificar el sistema del usuario |
| Instalación limpia en máquina sin el juego | requiere una máquina/VM limpia |
| Detección de antivirus | requiere SmartScreen/Defender reales |

Estos casos quedan como **validación manual** en la máquina de release.

## 5. Criterio de aceptación

El módulo se considera verificado en su parte automatizable si:

1. `test_instalador_m116.gd` reporta **0 fallos** y **0 SCRIPT ERROR**.
2. El resultado es idéntico en 3 corridas consecutivas (determinismo).
3. No hay regresión en `test_build_m117.gd`.
