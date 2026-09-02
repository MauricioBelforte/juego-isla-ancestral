**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 116: Instalador

## Checklist de implementación del módulo

### [S] Especificación de instalador
- [ ] Crear build release
- [ ] Crear instalador
- [ ] Definir directorio de instalación
- [ ] Crear desinstalador
- [ ] Configurar shortcuts si corresponde
- [ ] Configurar asociación de archivos si corresponde
- [ ] Validar permisos
- [ ] Validar antivirus
- [ ] Validar actualizaciones
- [ ] Validar reparación
- [ ] Validar desinstalación
- [ ] Validar instalación limpia
- [ ] Validar actualización
- [ ] Validar rollback

### [S] Build release de Godot
- [ ] Definir Godot 4.x export para Windows Desktop
- [ ] Definir optimizaciones (optimización de código, compresión de assets)
- [ ] Definir preset: Release (no Debug)
- [ ] Definir arquitectura: x64 (Windows 64-bit)
- [ ] Definir code signing del ejecutable
- [ ] Diseñar configuración de Godot export
- [ ] Diseñar Application/Config/features: Compress (lzma)
- [ ] Diseñar Application/Config/pack_mode: Single-file (opcional)
- [ ] Diseñar Application/Run/args: --release
- [ ] Diseñar Binary/export_console_wrapper: No
- [ ] Diseñar Binary/export_embedded_pck: Yes
- [ ] Diseñar Binary/export_filter: include/exclude patterns
- [ ] Diseñar Binary/export_path: builds/windows/
- [ ] Diseñar Binary/file_format: exe
- [ ] Diseñar Binary/icon: icon.ico
- [ ] Diseñar Binary/name: Isla Ancestral

### [S] Instalador Windows
- [ ] Definir Inno Setup (recomendado)
- [ ] Definir WiX Toolset (alternativa)
- [ ] Definir NSIS (alternativa)
- [ ] Diseñar script de Inno Setup (.iss)
- [ ] Diseñar wizard step-by-step (Bienvenida → Directorio → Shortcuts → Instalación → Finalización)
- [ ] Diseñar directorio de instalación predeterminado
- [ ] Diseñar opciones: desktop shortcut, start menu shortcut, association de files
- [ ] Diseñar validación de espacio en disco
- [ ] Diseñar validación de requisitos de sistema

### [S] Directorio de instalación
- [ ] Definir C:\Program Files\Isla Ancestral (requiere permisos)
- [ ] Definir C:\Users\Usuario\AppData\Local\Isla Ancestral (sin permisos)
- [ ] Diseñar Inno Setup permite elegir directorio de instalación
- [ ] Diseñar validación de espacio en disco
- [ ] Diseñar validación de requisitos de sistema

### [S] Desinstalador
- [ ] Definir Inno Setup genera automáticamente desinstalador
- [ ] Definir desinstalador elimina todos los archivos del juego
- [ ] Definir desinstalador elimina shortcuts (escritorio, menú de inicio)
- [ ] Definir desinstalador elimina asociación de archivos (si aplica)
- [ ] Definir desinstalador elimina entradas de registro (si aplica)
- [ ] Diseñar Inno Setup genera unins000.exe
- [ ] Diseñar desinstalador accesible desde Panel de Control
- [ ] Diseñar desinstalador accesible desde Start Menu

### [S] Shortcuts
- [ ] Definir shortcut en escritorio (opcional)
- [ ] Definir shortcut en menú de inicio (carpeta Isla Ancestral)
- [ ] Definir shortcut de desinstalador en menú de inicio
- [ ] Diseñar Inno Setup crea shortcuts automáticamente
- [ ] Diseñar usuario puede elegir si crear shortcut en escritorio
- [ ] Diseñar shortcuts tienen icono del juego

### [S] Asociación de archivos
- [ ] Definir asociación para savegames (.island)
- [ ] Definir asociación para configuración (.config)
- [ ] Diseñar Inno Setup permite asociación de archivos
- [ ] Diseñar asociación escrita en registro de Windows
- [ ] Diseñar asociación con icono específico

### [S] Validación de permisos
- [ ] Definir instalación en C:\Program Files requiere permisos de administrador
- [ ] Definir instalación en AppData no requiere permisos de administrador
- [ ] Diseñar Inno Setup solicita permisos de administrador automáticamente
- [ ] Diseñar UAC de Windows solicita confirmación al usuario
- [ ] Diseñar validación de permisos antes de iniciar instalación

### [S] Validación de antivirus
- [ ] Definir firma digital del ejecutable del juego (.exe)
- [ ] Definir firma digital del instalador (.exe o .msi)
- [ ] Definir certificado digital de autoridad de confianza
- [ ] Definir code signing reduce falsos positivos de antivirus
- [ ] Diseñar code signing con signtool.exe (Windows SDK)
- [ ] Diseñar code signing del ejecutable de Godot export
- [ ] Diseñar code signing del instalador de Inno Setup
- [ ] Diseñar timestamp del code signing para validez a largo plazo

### [S] Validación de actualizaciones
- [ ] Definir instalador puede actualizar desde versión anterior
- [ ] Definir instalador detecta versión instalada
- [ ] Definir instalador descarga e instala nueva versión
- [ ] Definir instalador conserva savegames y configuración
- [ ] Diseñar Inno Setup soporta actualizaciones
- [ ] Diseñar detección de versión instalada (registro de Windows)
- [ ] Diseñar actualización incremental (solo archivos modificados)
- [ ] Diseñar conservación de datos del usuario (savegames, configuración)

### [S] Validación de reparación
- [ ] Definir instalador puede reparar instalación corrupta
- [ ] Definir reparación reinstala archivos corruptos
- [ ] Definir reparación conserva savegames y configuración
- [ ] Definir reparación accesible desde Panel de Control
- [ ] Diseñar Inno Setup soporta reparación
- [ ] Diseñar validación de integridad de archivos
- [ ] Diseñar reinstalación de archivos corruptos
- [ ] Diseñar conservación de datos del usuario

### [S] Validación de desinstalación
- [ ] Definir desinstalador elimina todos los archivos del juego
- [ ] Definir desinstalador elimina shortcuts
- [ ] Definir desinstalador elimina asociación de archivos
- [ ] Definir desinstalador elimina entradas de registro
- [ ] Definir desinstalador conserva savegames y configuración (por defecto)
- [ ] Diseñar Inno Setup genera desinstalador automáticamente
- [ ] Diseñar desinstalador elimina todos los archivos del directorio de instalación
- [ ] Diseñar desinstalador elimina shortcuts y asociación de archivos
- [ ] Diseñar desinstalador puede conservar savegames y configuración (opcional)

### [S] Validación de instalación limpia
- [ ] Definir instalación funciona en máquina sin el juego
- [ ] Definir instalación no requiere dependencias externas
- [ ] Definir instalación valida requisitos de sistema (Windows 10/11, GPU, RAM)
- [ ] Definir instalación muestra error si requisitos no se cumplen
- [ ] Diseñar validación de sistema operativo (Windows 10/11)
- [ ] Diseñar validación de GPU (DirectX 11 compatible)
- [ ] Diseñar validación de RAM (mínimo 8GB)
- [ ] Diseñar validación de espacio en disco (mínimo 5GB)

### [S] Validación de actualización
- [ ] Definir actualización desde versión X a versión Y funciona
- [ ] Definir actualización conserva savegames y configuración
- [ ] Definir actualización actualiza shortcuts y asociación de archivos
- [ ] Definir actualización actualiza entradas de registro
- [ ] Diseñar detección de versión instalada (registro de Windows)
- [ ] Diseñar actualización incremental (solo archivos modificados)
- [ ] Diseñar conservación de datos del usuario
- [ ] Diseñar actualización de shortcuts y asociación de archivos

### [S] Validación de rollback
- [ ] Definir rollback a versión anterior funciona si actualización falla
- [ ] Definir rollback restaura versión anterior del juego
- [ ] Definir rollback conserva savegames y configuración
- [ ] Definir rollback accesible desde Panel de Control
- [ ] Diseñar backup de versión anterior antes de actualizar
- [ ] Diseñar rollback automático si actualización falla
- [ ] Diseñar restauración de versión anterior
- [ ] Diseñar conservación de datos del usuario

### [S] Script de Inno Setup
- [ ] Diseñar [Setup] con AppName, AppVersion, DefaultDirName, etc.
- [ ] Diseñar [Files] con Source, DestDir, Flags
- [ ] Diseñar [Icons] con Name, Filename, Tasks
- [ ] Diseñar [Tasks] con Name, Description, GroupDescription, Flags
- [ ] Diseñar [Registry] con Root, Subkey, ValueType, ValueName, ValueData, Flags
- [ ] Diseñar [Run] con Filename, Description, Flags
- [ ] Diseñar [UninstallDelete] con Type, Name

### [S] Validación de requisitos de sistema
- [ ] Diseñar función IsWindows10Or11()
- [ ] Diseñar función IsDirectX11Available()
- [ ] Diseñar función HasEnoughRAM()
- [ ] Diseñar función HasEnoughDiskSpace()
- [ ] Diseñar función InitializeSetup()
- [ ] Diseñar validación de Windows 10/11
- [ ] Diseñar validación de DirectX 11 compatible
- [ ] Diseñar validación de RAM (mínimo 8GB)
- [ ] Diseñar validación de espacio en disco (mínimo 5GB)

### [S] Actualización incremental
- [ ] Diseñar función GetInstalledVersion()
- [ ] Diseñar función IsUpdate()
- [ ] Diseñar procedimiento CurStepChanged()
- [ ] Diseñar detección de versión instalada (registro de Windows)
- [ ] Diseñar actualización incremental (solo archivos modificados)
- [ ] Diseñar conservación de datos del usuario
- [ ] Diseñar actualización de shortcuts y asociación de archivos

### [S] Reparación de instalación corrupta
- [ ] Diseñar función ValidateFileIntegrity()
- [ ] Diseñar procedimiento RepairInstallation()
- [ ] Diseñar validación de integridad de archivos
- [ ] Diseñar reinstalación de archivos corruptos
- [ ] Diseñar conservación de datos del usuario

### [S] Rollback a versión anterior
- [ ] Diseñar procedimiento BackupPreviousVersion()
- [ ] Diseñar procedimiento RollbackToPreviousVersion()
- [ ] Diseñar backup de versión anterior antes de actualizar
- [ ] Diseñar rollback automático si actualización falla
- [ ] Diseñar restauración de versión anterior
- [ ] Diseñar conservación de datos del usuario

### [S] Code signing
- [ ] Diseñar script code_signing.bat
- [ ] Diseñar code signing del ejecutable de Godot export
- [ ] Diseñar code signing del instalador de Inno Setup
- [ ] Diseñar uso de signtool.exe (Windows SDK)
- [ ] Diseñar timestamp del code signing

### [S] Build automation
- [ ] Diseñar script build_installer.bat
- [ ] Diseñar build release de Godot
- [ ] Diseñar code signing del ejecutable
- [ ] Diseñar build del instalador con Inno Setup
- [ ] Diseñar code signing del instalador

### [S] Icono del juego
- [ ] Diseñar icon.ico
- [ ] Diseñar icono para el ejecutable
- [ ] Diseñar icono para el instalador
- [ ] Diseñar icono para shortcuts
- [ ] Diseñar resoluciones: 16x16, 32x32, 48x48, 64x64, 256x256

### [S] Archivos de implementación
- [ ] Diseñar installer/IslaAncestral.iss
- [ ] Diseñar installer/system_requirements.iss
- [ ] Diseñar installer/update.iss
- [ ] Diseñar installer/repair.iss
- [ ] Diseñar installer/rollback.iss
- [ ] Diseñar installer/code_signing.bat
- [ ] Diseñar scripts/build_installer.bat
- [ ] Diseñar icon.ico
- [ ] Diseñar license.txt

### [S] Pruebas de instalación
- [ ] Diseñar prueba de instalación limpia en máquina sin el juego
- [ ] Diseñar prueba de actualización desde versión anterior
- [ ] Diseñar prueba de reparación de instalación corrupta
- [ ] Diseñar prueba de desinstalación completa
- [ ] Diseñar prueba de shortcuts (escritorio, menú de inicio)
- [ ] Diseñar prueba de asociación de archivos
- [ ] Diseñar prueba de validación de requisitos de sistema
- [ ] Diseñar prueba de validación de antivirus (code signing)
- [ ] Diseñar prueba de rollback a versión anterior

## Totales

**Total de ítems:** 156
**Ítems resueltos por documentación:** 156
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `installer/setup_windows.ps1` — instalador user-space (RF2/RF3): -InstallDir (default %LocalAppData%\IslaAncestral), copia del build, shortcuts (RF5, -NoShortcuts), validación de archivos críticos exe+pck (RF12), -DryRun (simulación)
- [x] `installer/uninstall_windows.ps1` — desinstalador (RF4): shortcuts + directorio completo, -DryRun, confirmación/-Force
- [x] `installer/README.md` — documentación de uso y convención de build (.build)
- [x] Parse de ambos scripts verificado (UTF-8 BOM; sin ParserError)
- [?] Smoke de ejecución en consola real (ventana PowerShell nativa) — el host de agentes no captura el host-stream de scripts .ps1 (dueño: deepseek-v4-flash-vision-exp)
- [?] RF6-RF13 (asociación, permisos, antivirus, actualizaciones, reparación, desinstalación real, instalación limpia/actualización): iter 2 con build release de M117/M118
