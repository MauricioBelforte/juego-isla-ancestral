# Tareas M116 — Instalador

**Modelo:** agnes-2.5-flash
**Fecha inicio:** 2026-09-02
**Fuente:** DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md

## Tareas pendientes

[ ] T-001 Crear build release
[ ] T-002 Crear instalador
[ ] T-003 Definir directorio de instalación
[ ] T-004 Crear desinstalador
[ ] T-005 Validar permisos
[ ] T-006 Validar antivirus
[ ] T-007 Validar actualizaciones
[ ] T-008 Validar reparación
[ ] T-009 Validar desinstalación
[ ] T-010 Validar instalación limpia
[ ] T-011 Validar actualización
[ ] T-012 Validar rollback
[ ] T-013 Definir Godot 4.x export para Windows Desktop
[ ] T-014 Definir optimizaciones (optimización de código, compresión de assets)
[ ] T-015 Definir preset: Release (no Debug)
[ ] T-016 Definir arquitectura: x64 (Windows 64-bit)
[ ] T-017 Definir code signing del ejecutable
[ ] T-018 Diseñar Application/Run/args: --release
[ ] T-019 Diseñar Binary/export_console_wrapper: No
[ ] T-020 Diseñar Binary/export_embedded_pck: Yes
[ ] T-021 Diseñar Binary/export_filter: include/exclude patterns
[ ] T-022 Diseñar Binary/export_path: builds/windows/
[ ] T-023 Diseñar Binary/file_format: exe
[ ] T-024 Diseñar Binary/icon: icon.ico
[ ] T-025 Diseñar Binary/name: Isla Ancestral
[ ] T-026 Definir Inno Setup (recomendado)
[ ] T-027 Definir WiX Toolset (alternativa)
[ ] T-028 Definir NSIS (alternativa)
[ ] T-029 Diseñar wizard step-by-step (Bienvenida → Directorio → Shortcuts → Instalación → Finalización)
[ ] T-030 Diseñar directorio de instalación predeterminado
[ ] T-031 Diseñar opciones: desktop shortcut, start menu shortcut, association de files
[ ] T-032 Diseñar validación de espacio en disco
[ ] T-033 Diseñar validación de requisitos de sistema
[ ] T-034 Definir C:\Program Files\Isla Ancestral (requiere permisos)
[ ] T-035 Definir C:\Users\Usuario\AppData\Local\Isla Ancestral (sin permisos)
[ ] T-036 Diseñar Inno Setup permite elegir directorio de instalación
[ ] T-037 Diseñar validación de espacio en disco
[ ] T-038 Diseñar validación de requisitos de sistema
[ ] T-039 Definir Inno Setup genera automáticamente desinstalador
[ ] T-040 Definir desinstalador elimina todos los archivos del juego
[ ] T-041 Definir desinstalador elimina shortcuts (escritorio, menú de inicio)
[ ] T-042 Definir desinstalador elimina asociación de archivos (si aplica)
[ ] T-043 Diseñar Inno Setup genera unins000.exe
[ ] T-044 Diseñar desinstalador accesible desde Panel de Control
[ ] T-045 Diseñar desinstalador accesible desde Start Menu
[ ] T-046 Definir shortcut en escritorio (opcional)
[ ] T-047 Definir shortcut en menú de inicio (carpeta Isla Ancestral)
[ ] T-048 Definir shortcut de desinstalador en menú de inicio
[ ] T-049 Diseñar Inno Setup crea shortcuts automáticamente
[ ] T-050 Diseñar usuario puede elegir si crear shortcut en escritorio
[ ] T-051 Diseñar shortcuts tienen icono del juego
[ ] T-052 Definir asociación para savegames (.island)
[ ] T-053 Diseñar Inno Setup permite asociación de archivos
[ ] T-054 Diseñar asociación con icono específico
[ ] T-055 Definir instalación en C:\Program Files requiere permisos de administrador
[ ] T-056 Definir instalación en AppData no requiere permisos de administrador
[ ] T-057 Diseñar Inno Setup solicita permisos de administrador automáticamente
[ ] T-058 Diseñar UAC de Windows solicita confirmación al usuario
[ ] T-059 Diseñar validación de permisos antes de iniciar instalación
[ ] T-060 Definir firma digital del ejecutable del juego (.exe)
[ ] T-061 Definir firma digital del instalador (.exe o .msi)
[ ] T-062 Definir certificado digital de autoridad de confianza
[ ] T-063 Definir code signing reduce falsos positivos de antivirus
[ ] T-064 Diseñar code signing con signtool.exe (Windows SDK)
[ ] T-065 Diseñar code signing del ejecutable de Godot export
[ ] T-066 Diseñar code signing del instalador de Inno Setup
[ ] T-067 Diseñar timestamp del code signing para validez a largo plazo
[ ] T-068 Definir instalador puede actualizar desde versión anterior
[ ] T-069 Definir instalador detecta versión instalada
[ ] T-070 Definir instalador descarga e instala nueva versión
[ ] T-071 Diseñar Inno Setup soporta actualizaciones
[ ] T-072 Diseñar actualización incremental (solo archivos modificados)
[ ] T-073 Definir instalador puede reparar instalación corrupta
[ ] T-074 Definir reparación reinstala archivos corruptos
[ ] T-075 Definir reparación accesible desde Panel de Control
[ ] T-076 Diseñar Inno Setup soporta reparación
[ ] T-077 Diseñar validación de integridad de archivos
[ ] T-078 Diseñar reinstalación de archivos corruptos
[ ] T-079 Diseñar conservación de datos del usuario
[ ] T-080 Definir desinstalador elimina todos los archivos del juego
[ ] T-081 Definir desinstalador elimina shortcuts
[ ] T-082 Definir desinstalador elimina asociación de archivos
[ ] T-083 Diseñar Inno Setup genera desinstalador automáticamente
[ ] T-084 Diseñar desinstalador elimina todos los archivos del directorio de instalación
[ ] T-085 Diseñar desinstalador elimina shortcuts y asociación de archivos
[ ] T-086 Definir instalación funciona en máquina sin el juego
[ ] T-087 Definir instalación no requiere dependencias externas
[ ] T-088 Definir instalación valida requisitos de sistema (Windows 10/11, GPU, RAM)
[ ] T-089 Definir instalación muestra error si requisitos no se cumplen
[ ] T-090 Diseñar validación de sistema operativo (Windows 10/11)
[ ] T-091 Diseñar validación de GPU (DirectX 11 compatible)
[ ] T-092 Diseñar validación de RAM (mínimo 8GB)
[ ] T-093 Diseñar validación de espacio en disco (mínimo 5GB)
[ ] T-094 Definir actualización desde versión X a versión Y funciona
[ ] T-095 Definir actualización actualiza shortcuts y asociación de archivos
[ ] T-096 Diseñar actualización incremental (solo archivos modificados)
[ ] T-097 Diseñar conservación de datos del usuario
[ ] T-098 Diseñar actualización de shortcuts y asociación de archivos
[ ] T-099 Definir rollback a versión anterior funciona si actualización falla
[ ] T-100 Definir rollback restaura versión anterior del juego
[ ] T-101 Definir rollback accesible desde Panel de Control
[ ] T-102 Diseñar backup de versión anterior antes de actualizar
[ ] T-103 Diseñar rollback automático si actualización falla
[ ] T-104 Diseñar restauración de versión anterior
[ ] T-105 Diseñar conservación de datos del usuario
[ ] T-106 Diseñar [Setup] con AppName, AppVersion, DefaultDirName, etc.
[ ] T-107 Diseñar [Files] con Source, DestDir, Flags
[ ] T-108 Diseñar [Icons] con Name, Filename, Tasks
[ ] T-109 Diseñar [Registry] con Root, Subkey, ValueType, ValueName, ValueData, Flags
[ ] T-110 Diseñar [UninstallDelete] con Type, Name
[ ] T-111 Diseñar función IsWindows10Or11()
[ ] T-112 Diseñar función IsDirectX11Available()
[ ] T-113 Diseñar función HasEnoughRAM()
[ ] T-114 Diseñar función HasEnoughDiskSpace()
[ ] T-115 Diseñar función InitializeSetup()
[ ] T-116 Diseñar validación de Windows 10/11
[ ] T-117 Diseñar validación de DirectX 11 compatible
[ ] T-118 Diseñar validación de RAM (mínimo 8GB)
[ ] T-119 Diseñar validación de espacio en disco (mínimo 5GB)
[ ] T-120 Diseñar función GetInstalledVersion()
[ ] T-121 Diseñar función IsUpdate()
[ ] T-122 Diseñar procedimiento CurStepChanged()
[ ] T-123 Diseñar actualización incremental (solo archivos modificados)
[ ] T-124 Diseñar conservación de datos del usuario
[ ] T-125 Diseñar actualización de shortcuts y asociación de archivos
[ ] T-126 Diseñar función ValidateFileIntegrity()
[ ] T-127 Diseñar procedimiento RepairInstallation()
[ ] T-128 Diseñar validación de integridad de archivos
[ ] T-129 Diseñar reinstalación de archivos corruptos
[ ] T-130 Diseñar conservación de datos del usuario
[ ] T-131 Diseñar procedimiento BackupPreviousVersion()
[ ] T-132 Diseñar procedimiento RollbackToPreviousVersion()
[ ] T-133 Diseñar backup de versión anterior antes de actualizar
[ ] T-134 Diseñar rollback automático si actualización falla
[ ] T-135 Diseñar restauración de versión anterior
[ ] T-136 Diseñar conservación de datos del usuario
[ ] T-137 Diseñar code signing del ejecutable de Godot export
[ ] T-138 Diseñar code signing del instalador de Inno Setup
[ ] T-139 Diseñar uso de signtool.exe (Windows SDK)
[ ] T-140 Diseñar timestamp del code signing
[ ] T-141 Diseñar build release de Godot
[ ] T-142 Diseñar code signing del ejecutable
[ ] T-143 Diseñar build del instalador con Inno Setup
[ ] T-144 Diseñar code signing del instalador
[ ] T-145 Diseñar icon.ico
[ ] T-146 Diseñar icono para el ejecutable
[ ] T-147 Diseñar icono para el instalador
[ ] T-148 Diseñar icono para shortcuts
[ ] T-149 Diseñar resoluciones: 16x16, 32x32, 48x48, 64x64, 256x256
[ ] T-150 Diseñar installer/IslaAncestral.iss
[ ] T-151 Diseñar installer/system_requirements.iss
[ ] T-152 Diseñar installer/update.iss
[ ] T-153 Diseñar installer/repair.iss
[ ] T-154 Diseñar installer/rollback.iss
[ ] T-155 Diseñar installer/code_signing.bat
[ ] T-156 Diseñar icon.ico
[ ] T-157 Diseñar license.txt
[ ] T-158 Diseñar prueba de instalación limpia en máquina sin el juego
[ ] T-159 Diseñar prueba de actualización desde versión anterior
[ ] T-160 Diseñar prueba de reparación de instalación corrupta
[ ] T-161 Diseñar prueba de desinstalación completa
[ ] T-162 Diseñar prueba de shortcuts (escritorio, menú de inicio)
[ ] T-163 Diseñar prueba de asociación de archivos
[ ] T-164 Diseñar prueba de validación de requisitos de sistema
[ ] T-165 Diseñar prueba de validación de antivirus (code signing)
[ ] T-166 Diseñar prueba de rollback a versión anterior
[?] T-167 Smoke de ejecución en consola real (ventana PowerShell nativa) — el host de agentes no captura el host-stream de scripts .ps1 (dueño: deepseek-v4-flash-vision-exp)
[?] T-168 RF6-RF13 (asociación, permisos, antivirus, actualizaciones, reparación, desinstalación real, instalación limpia/actualización): iter 2 con build release de M117/M118