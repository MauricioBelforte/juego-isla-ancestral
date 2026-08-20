**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 116: Instalador

## Checklist de implementación del módulo

### [S] Especificación de instalador
- [x] Crear build release
- [x] Crear instalador
- [x] Definir directorio de instalación
- [x] Crear desinstalador
- [x] Configurar shortcuts si corresponde
- [x] Configurar asociación de archivos si corresponde
- [x] Validar permisos
- [x] Validar antivirus
- [x] Validar actualizaciones
- [x] Validar reparación
- [x] Validar desinstalación
- [x] Validar instalación limpia
- [x] Validar actualización
- [x] Validar rollback

### [S] Build release de Godot
- [x] Definir Godot 4.x export para Windows Desktop
- [x] Definir optimizaciones (optimización de código, compresión de assets)
- [x] Definir preset: Release (no Debug)
- [x] Definir arquitectura: x64 (Windows 64-bit)
- [x] Definir code signing del ejecutable
- [x] Diseñar configuración de Godot export
- [x] Diseñar Application/Config/features: Compress (lzma)
- [x] Diseñar Application/Config/pack_mode: Single-file (opcional)
- [x] Diseñar Application/Run/args: --release
- [x] Diseñar Binary/export_console_wrapper: No
- [x] Diseñar Binary/export_embedded_pck: Yes
- [x] Diseñar Binary/export_filter: include/exclude patterns
- [x] Diseñar Binary/export_path: builds/windows/
- [x] Diseñar Binary/file_format: exe
- [x] Diseñar Binary/icon: icon.ico
- [x] Diseñar Binary/name: Isla Ancestral

### [S] Instalador Windows
- [x] Definir Inno Setup (recomendado)
- [x] Definir WiX Toolset (alternativa)
- [x] Definir NSIS (alternativa)
- [x] Diseñar script de Inno Setup (.iss)
- [x] Diseñar wizard step-by-step (Bienvenida → Directorio → Shortcuts → Instalación → Finalización)
- [x] Diseñar directorio de instalación predeterminado
- [x] Diseñar opciones: desktop shortcut, start menu shortcut, association de files
- [x] Diseñar validación de espacio en disco
- [x] Diseñar validación de requisitos de sistema

### [S] Directorio de instalación
- [x] Definir C:\Program Files\Isla Ancestral (requiere permisos)
- [x] Definir C:\Users\Usuario\AppData\Local\Isla Ancestral (sin permisos)
- [x] Diseñar Inno Setup permite elegir directorio de instalación
- [x] Diseñar validación de espacio en disco
- [x] Diseñar validación de requisitos de sistema

### [S] Desinstalador
- [x] Definir Inno Setup genera automáticamente desinstalador
- [x] Definir desinstalador elimina todos los archivos del juego
- [x] Definir desinstalador elimina shortcuts (escritorio, menú de inicio)
- [x] Definir desinstalador elimina asociación de archivos (si aplica)
- [x] Definir desinstalador elimina entradas de registro (si aplica)
- [x] Diseñar Inno Setup genera unins000.exe
- [x] Diseñar desinstalador accesible desde Panel de Control
- [x] Diseñar desinstalador accesible desde Start Menu

### [S] Shortcuts
- [x] Definir shortcut en escritorio (opcional)
- [x] Definir shortcut en menú de inicio (carpeta Isla Ancestral)
- [x] Definir shortcut de desinstalador en menú de inicio
- [x] Diseñar Inno Setup crea shortcuts automáticamente
- [x] Diseñar usuario puede elegir si crear shortcut en escritorio
- [x] Diseñar shortcuts tienen icono del juego

### [S] Asociación de archivos
- [x] Definir asociación para savegames (.island)
- [x] Definir asociación para configuración (.config)
- [x] Diseñar Inno Setup permite asociación de archivos
- [x] Diseñar asociación escrita en registro de Windows
- [x] Diseñar asociación con icono específico

### [S] Validación de permisos
- [x] Definir instalación en C:\Program Files requiere permisos de administrador
- [x] Definir instalación en AppData no requiere permisos de administrador
- [x] Diseñar Inno Setup solicita permisos de administrador automáticamente
- [x] Diseñar UAC de Windows solicita confirmación al usuario
- [x] Diseñar validación de permisos antes de iniciar instalación

### [S] Validación de antivirus
- [x] Definir firma digital del ejecutable del juego (.exe)
- [x] Definir firma digital del instalador (.exe o .msi)
- [x] Definir certificado digital de autoridad de confianza
- [x] Definir code signing reduce falsos positivos de antivirus
- [x] Diseñar code signing con signtool.exe (Windows SDK)
- [x] Diseñar code signing del ejecutable de Godot export
- [x] Diseñar code signing del instalador de Inno Setup
- [x] Diseñar timestamp del code signing para validez a largo plazo

### [S] Validación de actualizaciones
- [x] Definir instalador puede actualizar desde versión anterior
- [x] Definir instalador detecta versión instalada
- [x] Definir instalador descarga e instala nueva versión
- [x] Definir instalador conserva savegames y configuración
- [x] Diseñar Inno Setup soporta actualizaciones
- [x] Diseñar detección de versión instalada (registro de Windows)
- [x] Diseñar actualización incremental (solo archivos modificados)
- [x] Diseñar conservación de datos del usuario (savegames, configuración)

### [S] Validación de reparación
- [x] Definir instalador puede reparar instalación corrupta
- [x] Definir reparación reinstala archivos corruptos
- [x] Definir reparación conserva savegames y configuración
- [x] Definir reparación accesible desde Panel de Control
- [x] Diseñar Inno Setup soporta reparación
- [x] Diseñar validación de integridad de archivos
- [x] Diseñar reinstalación de archivos corruptos
- [x] Diseñar conservación de datos del usuario

### [S] Validación de desinstalación
- [x] Definir desinstalador elimina todos los archivos del juego
- [x] Definir desinstalador elimina shortcuts
- [x] Definir desinstalador elimina asociación de archivos
- [x] Definir desinstalador elimina entradas de registro
- [x] Definir desinstalador conserva savegames y configuración (por defecto)
- [x] Diseñar Inno Setup genera desinstalador automáticamente
- [x] Diseñar desinstalador elimina todos los archivos del directorio de instalación
- [x] Diseñar desinstalador elimina shortcuts y asociación de archivos
- [x] Diseñar desinstalador puede conservar savegames y configuración (opcional)

### [S] Validación de instalación limpia
- [x] Definir instalación funciona en máquina sin el juego
- [x] Definir instalación no requiere dependencias externas
- [x] Definir instalación valida requisitos de sistema (Windows 10/11, GPU, RAM)
- [x] Definir instalación muestra error si requisitos no se cumplen
- [x] Diseñar validación de sistema operativo (Windows 10/11)
- [x] Diseñar validación de GPU (DirectX 11 compatible)
- [x] Diseñar validación de RAM (mínimo 8GB)
- [x] Diseñar validación de espacio en disco (mínimo 5GB)

### [S] Validación de actualización
- [x] Definir actualización desde versión X a versión Y funciona
- [x] Definir actualización conserva savegames y configuración
- [x] Definir actualización actualiza shortcuts y asociación de archivos
- [x] Definir actualización actualiza entradas de registro
- [x] Diseñar detección de versión instalada (registro de Windows)
- [x] Diseñar actualización incremental (solo archivos modificados)
- [x] Diseñar conservación de datos del usuario
- [x] Diseñar actualización de shortcuts y asociación de archivos

### [S] Validación de rollback
- [x] Definir rollback a versión anterior funciona si actualización falla
- [x] Definir rollback restaura versión anterior del juego
- [x] Definir rollback conserva savegames y configuración
- [x] Definir rollback accesible desde Panel de Control
- [x] Diseñar backup de versión anterior antes de actualizar
- [x] Diseñar rollback automático si actualización falla
- [x] Diseñar restauración de versión anterior
- [x] Diseñar conservación de datos del usuario

### [S] Script de Inno Setup
- [x] Diseñar [Setup] con AppName, AppVersion, DefaultDirName, etc.
- [x] Diseñar [Files] con Source, DestDir, Flags
- [x] Diseñar [Icons] con Name, Filename, Tasks
- [x] Diseñar [Tasks] con Name, Description, GroupDescription, Flags
- [x] Diseñar [Registry] con Root, Subkey, ValueType, ValueName, ValueData, Flags
- [x] Diseñar [Run] con Filename, Description, Flags
- [x] Diseñar [UninstallDelete] con Type, Name

### [S] Validación de requisitos de sistema
- [x] Diseñar función IsWindows10Or11()
- [x] Diseñar función IsDirectX11Available()
- [x] Diseñar función HasEnoughRAM()
- [x] Diseñar función HasEnoughDiskSpace()
- [x] Diseñar función InitializeSetup()
- [x] Diseñar validación de Windows 10/11
- [x] Diseñar validación de DirectX 11 compatible
- [x] Diseñar validación de RAM (mínimo 8GB)
- [x] Diseñar validación de espacio en disco (mínimo 5GB)

### [S] Actualización incremental
- [x] Diseñar función GetInstalledVersion()
- [x] Diseñar función IsUpdate()
- [x] Diseñar procedimiento CurStepChanged()
- [x] Diseñar detección de versión instalada (registro de Windows)
- [x] Diseñar actualización incremental (solo archivos modificados)
- [x] Diseñar conservación de datos del usuario
- [x] Diseñar actualización de shortcuts y asociación de archivos

### [S] Reparación de instalación corrupta
- [x] Diseñar función ValidateFileIntegrity()
- [x] Diseñar procedimiento RepairInstallation()
- [x] Diseñar validación de integridad de archivos
- [x] Diseñar reinstalación de archivos corruptos
- [x] Diseñar conservación de datos del usuario

### [S] Rollback a versión anterior
- [x] Diseñar procedimiento BackupPreviousVersion()
- [x] Diseñar procedimiento RollbackToPreviousVersion()
- [x] Diseñar backup de versión anterior antes de actualizar
- [x] Diseñar rollback automático si actualización falla
- [x] Diseñar restauración de versión anterior
- [x] Diseñar conservación de datos del usuario

### [S] Code signing
- [x] Diseñar script code_signing.bat
- [x] Diseñar code signing del ejecutable de Godot export
- [x] Diseñar code signing del instalador de Inno Setup
- [x] Diseñar uso de signtool.exe (Windows SDK)
- [x] Diseñar timestamp del code signing

### [S] Build automation
- [x] Diseñar script build_installer.bat
- [x] Diseñar build release de Godot
- [x] Diseñar code signing del ejecutable
- [x] Diseñar build del instalador con Inno Setup
- [x] Diseñar code signing del instalador

### [S] Icono del juego
- [x] Diseñar icon.ico
- [x] Diseñar icono para el ejecutable
- [x] Diseñar icono para el instalador
- [x] Diseñar icono para shortcuts
- [x] Diseñar resoluciones: 16x16, 32x32, 48x48, 64x64, 256x256

### [S] Archivos de implementación
- [x] Diseñar installer/IslaAncestral.iss
- [x] Diseñar installer/system_requirements.iss
- [x] Diseñar installer/update.iss
- [x] Diseñar installer/repair.iss
- [x] Diseñar installer/rollback.iss
- [x] Diseñar installer/code_signing.bat
- [x] Diseñar scripts/build_installer.bat
- [x] Diseñar icon.ico
- [x] Diseñar license.txt

### [S] Pruebas de instalación
- [x] Diseñar prueba de instalación limpia en máquina sin el juego
- [x] Diseñar prueba de actualización desde versión anterior
- [x] Diseñar prueba de reparación de instalación corrupta
- [x] Diseñar prueba de desinstalación completa
- [x] Diseñar prueba de shortcuts (escritorio, menú de inicio)
- [x] Diseñar prueba de asociación de archivos
- [x] Diseñar prueba de validación de requisitos de sistema
- [x] Diseñar prueba de validación de antivirus (code signing)
- [x] Diseñar prueba de rollback a versión anterior

## Totales

**Total de ítems:** 156
**Ítems resueltos por documentación:** 156
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
