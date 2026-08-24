**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 01-Requerimientos.md — Módulo 116: Instalador

## ID del Módulo
- **Código:** M116 (plan maestro: sección 115 — Instalador)
- **Carpeta:** `DOCUMENTACION/116-Instalador/`
- **Dependencias:** M117 (Build System), M119 (Actualizaciones), M96 (Plataformas)
- **Carácter:** Módulo de instalador para distribución del juego en Windows

## 1. Problema

El proyecto necesita un sistema de **instalador** para distribución del juego en Windows (plataforma principal). Debe crear build release, crear instalador, definir directorio de instalación, crear desinstalador, configurar shortcuts, configurar asociación de archivos (si corresponde), validar permisos, validar antivirus, validar actualizaciones, validar reparación, validar desinstalación, validar instalación limpia, validar actualización y validar rollback.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Crear build release | Crear build release optimizado de Godot para Windows |
| RF2 | Crear instalador | Crear instalador Windows (MSI o EXE) con configuración |
| RF3 | Definir directorio de instalación | Definir directorio de instalación predeterminado (ej: C:\Program Files\Isla Ancestral) |
| RF4 | Crear desinstalador | Crear desinstalador que elimine todos los archivos del juego |
| RF5 | Configurar shortcuts | Configurar shortcuts en escritorio y menú de inicio |
| RF6 | Configurar asociación de archivos | Configurar asociación de archivos (si corresponde, ej: .island) |
| RF7 | Validar permisos | Validar permisos de administrador para instalación |
| RF8 | Validar antivirus | Validar que el instalador no sea marcado como malicioso por antivirus |
| RF9 | Validar actualizaciones | Validar que el instalador pueda manejar actualizaciones |
| RF10 | Validar reparación | Validar que el instalador pueda reparar una instalación corrupta |
| RF11 | Validar desinstalación | Validar que el desinstalador elimine todos los archivos |
| RF12 | Validar instalación limpia | Validar instalación limpia en máquina sin el juego |
| RF13 | Validar actualización | Validar actualización desde versión anterior |
| RF14 | Validar rollback | Validar rollback a versión anterior si actualización falla |

## 3. Requisitos No Funcionales

- Instalador debe ser simple y amigable (wizard step-by-step)
- Instalador debe mostrar progreso visual durante instalación
- Instalador debe ser firmado digitalmente (code signing)
- Instalador debe soportar reparación y desinstalación
- Instalador debe soportar actualizaciones y rollback
- Instalador debe soportar instalación silenciosa (para admins)
- Instalador debe validar requisitos de sistema (Windows 10/11, GPU, RAM)

## 4. Criterios de Aceptación

1. Los 14 puntos de la sección 115 del plan maestro resueltos.
2. Build release de Godot para Windows optimizado.
3. Instalador Windows (MSI o EXE) con wizard step-by-step.
4. Directorio de instalación predeterminado configurado.
5. Desinstalador que elimina todos los archivos del juego.
6. Shortcuts en escritorio y menú de inicio.
7. Asociación de archivos (si corresponde).
8. Validación de permisos de administrador.
9. Validación de antivirus (instalador no marcado como malicioso).
10. Validación de actualizaciones (instalador puede manejar actualizaciones).
11. Validación de reparación (instalador puede reparar instalación corrupta).
12. Validación de desinstalación (desinstalador elimina todos los archivos).
13. Validación de instalación limpia (instalación funciona en máquina sin el juego).
14. Validación de actualización (actualización desde versión anterior funciona).
15. Validación de rollback (rollback a versión anterior funciona si actualización falla).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M117** — Build System | Usado por build system |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M117** — Build System | Este módulo lo necesita |

