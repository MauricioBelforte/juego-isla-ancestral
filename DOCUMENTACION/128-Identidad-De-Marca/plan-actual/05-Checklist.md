# Módulo 128: Identidad de Marca — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:29:00

## A. Nombre y Trademark (10 ítems)

- [x] Cargar datos desde JSON (secciones/politicas/elementos) [S]
- [x] Detectar errores estructurales (id, nombre, etc) [S]
- [x] Test headless de validacion [M]
- [x] Datos data-driven en data/legal/ [S]
- [ ] Verificar disponibilidad de dominio web (islaancestral.com)
- [ ] Registrar redes sociales con nombre consistente
- [ ] Documentar proceso de registro de trademark
- [ ] Definir política de cease & desist
- [ ] Crear alertas de monitoreo de trademark
- [ ] Documentar territorios registrados y pendientes

## B. Logo (15 ítems)

- [ ] Diseñar logo principal del juego
- [ ] Crear variante mono (B/N) del logo
- [ ] Crear variante icono (app icon) 512x512
- [ ] Crear variante horizontal para headers
- [ ] Crear variante vertical para merchandise
- [ ] Definir espacio libre (clear space) mínimo
- [ ] Definir tamaño mínimo (32px digital, 10mm impresión)
- [ ] Documentar usos permitidos del logo
- [ ] Documentar usos PROHIBIDOS del logo
- [ ] Exportar en formatos: PNG, SVG, AI
- [ ] Crear versiones para fondo claro y oscuro
- [ ] Test de legibilidad en tamaños pequeños
- [ ] Test de impresión en merchandise
- [ ] Aprobar logo final con equipo
- [ ] Distribuir logo a partners y prensa

## C. Paleta de Colores (10 ítems)

- [ ] Definir color primario (Azul Bosque #2E5A4C)
- [ ] Definir color secundario (Dorado Anciano #D4A843)
- [ ] Definir color de acento (Blanco Perla #F5F0E8)
- [ ] Definir neutros (Carbón, Gris Piedra, Crema)
- [ ] Definir colores secundarios (Verde Hoja, Terracota, Cielo Claro)
- [ ] Verificar contraste WCAG AA para cada par de colores
- [ ] Crear paleta en formato ASE/CLR
- [ ] Documentar RGB, CMYK y HEX de cada color
- [ ] Crear variaciones para modo oscuro
- [ ] Distribuir paleta al equipo de diseño

## D. Tipografía (10 ítems)

- [ ] Seleccionar fuente principal (títulos)
- [ ] Seleccionar fuente secundaria (cuerpo)
- [ ] Seleccionar fuente monospace (código/datos)
- [ ] Verificar licencias de cada fuente
- [ ] Definir jerarquía de tamaños (H1-H6, body, caption)
- [ ] Definir pesos (regular, bold, light)
- [ ] Crear muestras de tipografía
- [ ] Documentar uso en interfaces
- [ ] Distribuir fuentes al equipo
- [ ] Verificar que fuentes son incluidas en builds

## E. Manual de Marca (10 ítems)

- [ ] Crear estructura del manual (10 secciones)
- [ ] Redactar introducción y propósito
- [ ] Documentar identidad de marca (nombre, tagline, valores)
- [ ] Documentar reglas de logo (variantes, clear space, usos)
- [ ] Documentar paleta de colores completa
- [ ] Documentar tipografía y jerarquía
- [ ] Documentar iconografía y fotografía
- [ ] Documentar uso en redes sociales
- [ ] Documentar restricciones de merchandise
- [ ] Incluir contacto para aprobación de uso

## F. Presencia Online (10 ítems)

- [ ] Registrar dominio islaancestral.com
- [ ] Crear sitio web con información del juego
- [ ] Crear perfiles en redes sociales principales
- [ ] Usar logo y paleta coherentes en toda la web
- [ ] Crear kit de prensa con assets de marca
- [ ] Documentar guidelines para redes sociales
- [ ] Crear plantillas de posts con marca
- [ ] Definir tono de comunicación
- [ ] Crear email corporativo (press@islaancestral.com)
- [ ] Monitorear menciones de la marca

## G. Merchandise (10 ítems)

- [ ] Definir qué productos de merchandise se permiten
- [ ] Documentar logo mínimo para impresión
- [ ] Crear template para proveedores de merchandise
- [ ] Definir proceso de aprobación de diseños
- [ ] Documentar restricciones de calidad
- [ ] Definir estándares de calidad para merchandise (textil, cerámica, papel)
- [ ] Crear guía de colores para impresión (CMYK vs. RGB)
- [ ] Documentar process de muestreo antes de producción
- [ ] Definir proveedores aprobados por región
- [ ] Crear checklist de QA para merchandise recibido

## H. Validación y Testing (10 ítems)

- [ ] Crear BrandConfig.gd con colores oficiales
- [ ] Crear BrandValidator.gd para validar coherencia
- [ ] Test de contraste WCAG AA para todos los pares de colores
- [ ] Test de logo en tamaños mínimos
- [ ] Test de legibilidad de tipografía
- [ ] Validar que UI del juego usa paleta de marca
- [ ] Validar que builds incluyen fuentes correctas
- [ ] Test de impresión de logo en merchandise
- [ ] Auditoría visual pre-lanzamiento
- [ ] Documentar hallazgos y correcciones

## I. Distribución y Mantenimiento (10 ítems)

- [ ] Crear brand/ con todos los assets
- [ ] Crear manual-de-marca.pdf
- [ ] Crear press kit descargable
- [ ] Distribuir manual a todos los socios
- [ ] Actualizar manual cuando cambien elementos
- [ ] Mantener backups de assets de marca
- [ ] Registrar fecha de última actualización
- [ ] Definir quién puede aprobar cambios de marca
- [ ] Crear changelog del manual de marca
- [ ] Documentar proceso para nuevos partners

## J. Coherencia con Otros Módulos (5 ítems)

- [ ] Verificar que M97 (Steam Store Page) usa identidad de marca correcta
- [ ] Verificar que M98 (Trailer) usa logo y colores de marca
- [ ] Verificar que M99 (Marketing) sigue manual de marca
- [ ] Verificar que M53 (UI/UX) usa paleta y tipografía de marca
- [ ] Verificar que M131 (Créditos) usa formato de marca

## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — especialidad validación / detección de bugs

### Resultado de tests (headless, Godot 4.7.2-stable)
- godot --headless --path <proyecto> -s res://scripts/legal/test_brand_m128.gd -> **8 checks, 0 fallos** (exit 0) ✅

### Artefactos verificados
- data/legal/identidad_marca.json — carga y estructura validada por el test.
- scripts/legal/brand_validator.gd — alidar() y 
eporte() funcionan y detectan datos corruptos.
- scripts/legal/test_brand_m128.gd — ejecuta sin errores, sin regresiones con M60 (66/0 OK según liberación).

### Hallazgo honesto (brecha de implementación)
El módulo fue liberado como "núcleo iter. 1" con JSON + Validator + Test. **No se implementaron** los autoloads de servicio del plan (BrandManager/BrandConfig), el Resource de configuración, ni los documentos .md (legal/128_*.md). El checklist de producto (espec. completa) permanece sin marcar: la capa de validación de datos SÍ existe y está verificada; la capa de servicio/docs NO.

### Veredicto QA
- DoD de la *capa de validación de datos*: **CUMPLIDO** (código existe, compila, tests 0 fallos, sin regresiones).
- Producto completo según plan: **INCOMPLETO** (falta capa de servicio + docs).
- Estado recomendado: **🟡 Con dudas** (scaffold de validación verificado; pendiente capa de servicio/docs).

**Firma:** Hy3 / Kilo Code — 2026-09-02
