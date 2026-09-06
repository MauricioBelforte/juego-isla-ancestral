**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-04

# Guía de Configuración de OpenCode

> Guía para reinstalar y configurar OpenCode con este proyecto. Si OpenCode deja de funcionar, seguir estos pasos.

---

## 1. Instalación

1. Descargar OpenCode desde https://opencode.ai
2. Instalar y abrir
3. Seleccionar proveedor de modelo (OpenRouter, OpenAI, Anthropic, etc.)

---

## 2. Configuración de Providers (API Keys)

En OpenCode, ir a **Settings → Providers** y agregar cada proveedor:

| Provider | URL API | Notas |
|----------|---------|-------|
| OpenRouter | `https://openrouter.ai/api/v1` | Modelos múltiples (MiMo, DeepSeek, GLM, etc.) |
| OpenAI | `https://api.openai.com/v1` | GPT-4, o1, etc. |
| Anthropic | `https://api.anthropic.com` | Claude |
| Google | `https://generativelanguage.googleapis.com` | Gemini |

**Por cada provider:**
1. Pegar la API Key
2. Seleccionar el modelo por defecto
3. Guardar
4. **Probar con un mensaje corto** antes de agregar el siguiente provider

---

## 3. Configuración MCP (Model Context Protocol)

### 3.1 Archivo `opencode.json`

Crear/editar `opencode.json` en la **raíz del proyecto** (junto a `AGENTS.md`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "godot": {
      "type": "local",
      "command": ["node", "tools/mcp/godot-mcp/build/index.js"],
      "environment": {
        "GODOT_PATH": "D:\\ISLA ANCESTRAL\\Godot_v4.7.2-stable_win64.exe\\Godot_v4.7.2-stable_win64.exe"
      },
      "enabled": true,
      "timeout": 30000
    }
  }
}
```

### 3.2 Requisitos del MCP

- **Node.js** instalado (v22+ recomendado)
- Archivo `tools/mcp/godot-mcp/build/index.js` presente en el proyecto
- Godot 4.7.2 instalado en la ruta indicada en `GODOT_PATH`

### 3.3 Verificar MCP

Después de crear/editar `opencode.json`:
1. **Reiniciar OpenCode** completo
2. Abrir este proyecto
3. Escribir un mensaje de prueba (ej: "hola")
4. El MCP debería conectarse automáticamente

---

## 4. Estructura del Proyecto

```
juego-isla-ancestral/
├── AGENTS.md                    ← Reglas globales para agentes
├── opencode.json                ← Configuración MCP de OpenCode
├── CHECKLIST-GLOBAL.md          ← Estado global de módulos
├── DOCUMENTACION/               ← Toda la documentación
│   ├── 06-GUIA-DE-CONEXION-VISION.md  ← Guía MCP detallada
│   ├── 07-GUIA-GODOT.md        ← Errores y soluciones Godot
│   ├── TAREAS-POR-MODELO/       ← Backlogs personales
│   │   └── mimo-v2.5/          ← MiMo (este agente)
│   │       └── BACKLOG-MASTER.md
│   └── ...
├── game/
│   └── isla-ancestral/          ← Proyecto Godot
│       ├── project.godot
│       └── scripts/
├── Logs/                        ← Logs de agentes
│   └── ULTIMO_NUMERO.txt        ← Último número de log
└── tools/
    └── mcp/
        ├── godot-mcp/           ← Servidor MCP Godot
        └── screen-mcp/          ← Servidor MCP pantalla
```

---

## 5. Solución de Problemas Comunes

### MCP no conecta
- Verificar que `opencode.json` esté en la raíz del proyecto
- Verificar que Node.js esté instalado: `node --version`
- Verificar que `tools/mcp/godot-mcp/build/index.js` exista
- Reiniciar OpenCode

### Provider no responde
- Verificar que la API Key sea válida
- Probar el provider en otra herramienta (ej: Kilo Code) para confirmar que funciona
- Verificar que no se haya agotado el crédito/rate limit
- Intentar con otro modelo del mismo provider

### Chat no responde (hace ruido pero no contesta)
- Cerrar el chat y abrir uno nuevo
- Verificar que el modelo seleccionado esté disponible
- Si es rate limit, esperar unos minutos

### Logs duplicados
- Ejecutar verificación de duplicados (tarea recurrente de MiMo)
- Renombrar archivos duplicados
- Actualizar `ULTIMO_NUMERO.txt`
- Corregir referencias en documentación

---

## 6. Referencias

- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` — Guía completa de MCP (V1-V5)
- `DOCUMENTACION/07-GUIA-GODOT.md` — Errores comunes de Godot
- `AGENTS.md` — Reglas globales del proyecto
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.5/BACKLOG-MASTER.md` — Backlog de MiMo

---

**Firma:** MiMo V2.5 · OpenCode · 2026-09-04
