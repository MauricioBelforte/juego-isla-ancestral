**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 02-Analisis.md — Módulo 116: Instalador

## 1. Análisis de los puntos del plan maestro (sección 115)

| # | Punto | Resolución |
|---|---|---|
| 1 | Crear build release | ✅ Build release de Godot para Windows con optimizaciones |
| 2 | Crear instalador | ✅ Instalador Windows (MSI o EXE) con Inno Setup o WiX |
| 3 | Definir directorio de instalación | ✅ Directorio predeterminado: C:\Program Files\Isla Ancestral |
| 4 | Crear desinstalador | ✅ Desinstalador que elimina todos los archivos del juego |
| 5 | Configurar shortcuts | ✅ Shortcuts en escritorio y menú de inicio |
| 6 | Configurar asociación de archivos | ✅ Asociación de archivos (opcional, .island para savegames) |
| 7 | Validar permisos | ✅ Validación de permisos de administrador para instalación |
| 8 | Validar antivirus | ✅ Code signing para evitar marcas de antivirus |
| 9 | Validar actualizaciones | ✅ Instalador soporta actualizaciones incrementales |
| 10 | Validar reparación | ✅ Instalador soporta reparación de instalación corrupta |
| 11 | Validar desinstalación | ✅ Desinstalador elimina todos los archivos del juego |
| 12 | Validar instalación limpia | ✅ Instalación limpia funciona en máquina sin el juego |
| 13 | Validar actualización | ✅ Actualización desde versión anterior funciona |
| 14 | Validar rollback | ✅ Rollback a versión anterior funciona si actualización falla |

## 2. Build release de Godot

**Build release:**
- Godot 4.x export para Windows Desktop
- Optimizaciones: optimización de código, compresión de assets
- Export presets: Release (no Debug)
- Arquitectura: x64 (Windows 64-bit)
- Firma digital del ejecutable (code signing)

**Implementación:**
- Godot Editor → Export → Windows Desktop
- Preset: Release
- Opciones: Optimize Size, Export With Debug off
- Code signing del ejecutable con certificado digital

## 3. Instalador Windows

**Herramientas:**
- Inno Setup (recomendado para simplicidad)
- WiX Toolset (alternativa para MSI profesional)
- NSIS (alternativa open source)

**Selección:**
- Inno Setup es la opción recomendada para simplicidad y buen soporte de Windows
- WiX Toolset es más profesional pero más complejo
- NSIS es open source pero con sintaxis más compleja

**Implementación con Inno Setup:**
- Script de Inno Setup (.iss)
- Wizard step-by-step (Bienvenida → Directorio → Shortcuts → Instalación → Finalización)
- Directorio de instalación predeterminado: C:\Program Files\Isla Ancestral
- Opciones: desktop shortcut, start menu shortcut, association de archivos

## 4. Directorio de instalación

**Directorio predeterminado:**
- C:\Program Files\Isla Ancestral (requiere permisos de administrador)
- Alternativa: C:\Users\Usuario\AppData\Local\Isla Ancestral (no requiere permisos)

**Implementación:**
- Inno Setup permite elegir directorio de instalación
- Validación de espacio en disco
- Validación de requisitos de sistema

## 5. Desinstalador

**Desinstalador:**
- Inno Setup genera automáticamente desinstalador
- Desinstalador elimina todos los archivos del juego
- Desinstalador elimina shortcuts (escritorio, menú de inicio)
- Desinstalador elimina asociación de archivos (si aplica)
- Desinstalador elimina entradas de registro (si aplica)

**Implementación:**
- Inno Setup genera unins000.exe
- Desinstalador accesible desde Panel de Control
- Desinstalador accesible desde Start Menu

## 6. Shortcuts

**Shortcuts:**
- Shortcut en escritorio (opcional, usuario puede elegir)
- Shortcut en menú de inicio (carpeta Isla Ancestral)
- Shortcut de desinstalador en menú de inicio

**Implementación:**
- Inno Setup crea shortcuts automáticamente
- Usuario puede elegir si crear shortcut en escritorio
- Shortcuts tienen icono del juego

## 7. Asociación de archivos

**Asociación de archivos:**
- Asociación opcional para savegames (.island)
- Asociación permite abrir savegames doble-clickeando
- Asociación opcional para configuración (.config)

**Implementación:**
- Inno Setup permite asociación de archivos
- Asociación escrita en registro de Windows
- Asociación con icono específico

## 8. Validación de permisos

**Permisos de administrador:**
- Instalación en C:\Program Files requiere permisos de administrador
- Instalación en AppData no requiere permisos de administrador
- Inno Setup solicita permisos de administrador automáticamente si es necesario

**Implementación:**
- Inno Setup solicita elevación de privilegios automáticamente
- UAC de Windows solicita confirmación al usuario
- Validación de permisos antes de iniciar instalación

## 9. Validación de antivirus

**Code signing:**
- Firma digital del ejecutable del juego (.exe)
- Firma digital del instalador (.exe o .msi)
- Certificado digital de autoridad de confianza (DigiCert, Sectigo, etc.)
- Code signing reduce falsos positivos de antivirus

**Implementación:**
- Code signing con signtool.exe (Windows SDK)
- Code signing del ejecutable de Godot export
- Code signing del instalador de Inno Setup
- Timestamp del code signing para validez a largo plazo

## 10. Validación de actualizaciones

**Actualizaciones incrementales:**
- Instalador puede actualizar desde versión anterior
- Instalador detecta versión instalada
- Instalador descarga e instala nueva versión
- Instalador conserva savegames y configuración

**Implementación:**
- Inno Setup soporta actualizaciones
- Detección de versión instalada (registro de Windows)
- Actualización incremental (solo archivos modificados)
- Conservación de datos del usuario (savegames, configuración)

## 11. Validación de reparación

**Reparación de instalación corrupta:**
- Instalador puede reparar instalación corrupta
- Reparación reinstala archivos corruptos
- Reparación conserva savegames y configuración
- Reparación accesible desde Panel de Control

**Implementación:**
- Inno Setup soporta reparación
- Validación de integridad de archivos
- Reinstalación de archivos corruptos
- Conservación de datos del usuario

## 12. Validación de desinstalación

**Desinstalación completa:**
- Desinstalador elimina todos los archivos del juego
- Desinstalador elimina shortcuts
- Desinstalador elimina asociación de archivos
- Desinstalador elimina entradas de registro
- Desinstalador conserva savegames y configuración (por defecto)

**Implementación:**
- Inno Setup genera desinstalador automáticamente
- Desinstalador elimina todos los archivos del directorio de instalación
- Desinstalador elimina shortcuts y asociación de archivos
- Desinstalador puede conservar savegames y configuración (opcional)

## 13. Validación de instalación limpia

**Instalación limpia:**
- Instalación funciona en máquina sin el juego
- Instalación no requiere dependencias externas (Godot runtime incluido)
- Instalación valida requisitos de sistema (Windows 10/11, GPU, RAM)
- Instalación muestra error si requisitos no se cumplen

**Implementación:**
- Validación de sistema operativo (Windows 10/11)
- Validación de GPU (DirectX 11 compatible)
- Validación de RAM (mínimo 8GB)
- Validación de espacio en disco (mínimo 5GB)

## 14. Validación de actualización

**Actualización desde versión anterior:**
- Actualización desde versión X a versión Y funciona
- Actualización conserva savegames y configuración
- Actualización actualiza shortcuts y asociación de archivos
- Actualización actualiza entradas de registro

**Implementación:**
- Detección de versión instalada (registro de Windows)
- Actualización incremental (solo archivos modificados)
- Conservación de datos del usuario
- Actualización de shortcuts y asociación de archivos

## 15. Validación de rollback

**Rollback a versión anterior:**
- Rollback a versión anterior funciona si actualización falla
- Rollback restaura versión anterior del juego
- Rollback conserva savegames y configuración
- Rollback accesible desde Panel de Control

**Implementación:**
- Backup de versión anterior antes de actualizar
- Rollback automático si actualización falla
- Restauración de versión anterior
- Conservación de datos del usuario
