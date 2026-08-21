# Módulo 83: Licencias de Software — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## 1. Análisis del Dominio

### Gestión de Licencias de Software en Proyectos de Juegos

El desarrollo moderno reutiliza cientos de dependencias. Un módulo de licencias debe:

| Capa | Descripción |
|------|-------------|
| **Inventario** | Registro de cada dependencia + versión + licencia |
| **Validación** | Compatibilidad entre licencias (GPL no mixing con propietario) |
| **Generación** | Archivos de attribución (NOTICE, LICENSE) para cada build |
| **Auditoría** | Detección de nuevas dependencias sin licencia asignada |
| **Cumplimiento** | Obligaciones de distribución (source offer para GPL/LGPL) |

### Categorías de Licencias en Juegos

| Categoría | Ejemplos | Obligaciones |
|-----------|----------|--------------|
| **Permisivas** | MIT, BSD, Apache 2.0 | Incluir attribución, sin restricciones |
| **Weak Copyleft** | LGPL, MPL 2.0 | Cambios al código propio deben compartirse |
| **Strong Copyleft** | GPL, AGPL | Toda obra derivada bajo misma licencia |
| **No-Comercial** | CC BY-NC | Solo uso no comercial |
| **Propietaria** | Licencias custom | Restricciones específicas |

### Frameworks Relevantes

| Framework | Licencia | Impacto |
|-----------|----------|---------|
| Godot Engine | MIT | Permisivo, sin restricciones |
| GDScript built-in | MIT | Permisivo |
| Paquetes Godot (varios) | Variable | Verificar caso por caso |
| Python (build scripts) | PSF | Permisivo |

## 2. Decisiones de Diseño

### Decisión 1: Enfoque de Inventario

**Opción A:** Inventario estático manual (JSON/YAML)
- Pro: Control total, fácil de auditar
- Contra: Requiere actualización manual

**Opción B:** Escaneo automático de dependencias
- Pro: Siempre actualizado
- Contra: Puede fallar con dependencias custom

**Decisión:** Opción B (escaneo automático) + override manual para dependencias que el escáner no detecta. Los resultados se cachean y se validan en CI.

### Decisión 2: Formato de License Notices

**Opción A:** Un solo archivo `THIRD_PARTY_LICENSES.txt`
- Pro: Simple
- Contra: Archivo grande, difícil de mantener

**Opción B:** Archivos individuales por dependencia
- Pro: Modular
- Contra: Miles de archivos

**Decisión:** Opción A (un solo archivo generado automáticamente) + `licenses/` directorio con copies de las licencias originales para referencia completa.

### Decisión 3: Integración con Build Pipeline

**Opción A:** Build falla si hay licencia incompatible
- Pro: Seguridad máxima
- Contra: Puede bloquear desarrollo

**Opción B:** Warning en build, no bloqueo
- Pro: No interrumpe desarrollo
- Contra: Riesgo de pasar por alto

**Decisión:** Build falla SOLO si hay licencia incompatible (GPL + propietario). Warnings para licencias no verificadas.

## 3. Patrones de Diseño

- **LicenseScanner**: Escanea proyecto, detecta dependencias, extrae licencias
- **LicenseValidator**: Valida compatibilidad entre licencias
- **LicenseNoticeGenerator**: Genera archivos de attribución para builds
- **LicenseInventory**: Resource que almacena inventario persistente de licencias
- **LicensePolicy**: Configuración de qué licencias están permitidas/prohibidas

## 4. Riesgos Identificados

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Licencia no detectada por escáner | Alta | Medio | Override manual + verificación en review |
| Licencia incompatible descubierta tarde | Baja | Alto | Validación en build pipeline |
| Cambio de licencia en dependencia (update) | Media | Alto | Re-escaneo en cada build |
| Licencia Ambigua (doble licencia) | Media | Medio | Documentar ambas opciones, elegir una |

## 5. Análisis de Dependencias del Proyecto

### Dependencias Directas Identificadas

| Dependencia | Tipo | Licencia Esperada | Verificar |
|-------------|------|-------------------|-----------|
| Godot 4.x | Engine | MIT | ✅ |
| GDScript stdlib | Lenguaje | MIT | ✅ |
| Godot packages (addons) | Plugins | Variable | ⚠️ |
| Python (build scripts) | Tool | PSF | ✅ |

### Dependencias Indirectas

- Godot carga addons dinámicamente
- Build scripts pueden usar paquetes Python (pip)
- Assets pueden incluir herramientas de conversión con licencias propias
