# M84: Guía de Uso — Música y Audio Legal

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18

## 1. Guía de Uso para el Equipo de Audio

### Estructura del sistema

```
scripts/legal/
├── audio_license.gd          ← Resource: licencia individual
├── audio_credit.gd           ← Resource: crédito individual
├── audio_license_validator.gd ← Validador data-driven
├── audio_legal_manager.gd    ← Autoload: gestor principal
├── audio_credits_generator.gd ← Generador de reportes de créditos
└── test_audio_licenses_m84.gd ← Tests headless
```

### Datos

```
data/legal/
└── audio_licenses.json       ← Catálogo de licencias (fuente de verdad)
```

### Flujo de trabajo

1. **Agregar track:** editar `audio_licenses.json` → agregar entrada en `tracks[]`
2. **Validar:** ejecutar `audio_legal_manager.validate_all_audio()` o test headless
3. **Generar créditos:** `AudioCreditsGenerator.generar_detallado(_creditos)`
4. **Build:** `audio_legal_manager.validar_build()` genera archivos automáticamente

### Campo licencia válido

| Valor | Significado |
|-------|-------------|
| `propia` | Composición original del equipo |
| `MIT` | Licencia MIT (uso libre) |
| `CC0` | Dominio público |
| `CC-BY` | Requiere atribución |
| `CC-BY-SA` | Atribución + ShareAlike |
| `CC-BY-NC` | Atribución + NoComercial (⚠️ no permitida) |

## 2. Cómo Registrar Nuevas Licencias

1. Abrir `data/legal/audio_licenses.json`
2. Agregar objeto en `tracks[]`:

```json
{
  "id": "track-004",
  "titulo": "Nombre del Track",
  "autor": "Nombre del Artista",
  "licencia": "CC-BY",
  "attribution": "Música por Nombre del Artista, used under CC-BY 4.0",
  "tipo": "composicion_original"
}
```

3. Ejecutar validación: `audio_legal_manager.validate_all_audio()`
4. Si es CC-BY, verificar que `attribution` no esté vacío
5. Commitear el JSON

## 3. Cómo Agregar Nuevos Créditos

1. Abrir `scripts/legal/audio_credit.gd` → verificar enum `AudioRole`
2. Si el rol no existe, agregarlo al enum
3. En el código que instancia créditos:

```gdscript
var credito = AudioCredit.new()
credito.persona_nombre = "Nombre"
credito.rol = AudioCredit.AudioRole.COMPOSITOR
credito.track_ids = ["track-004"]
credito.es_pagado_flag = true
audio_legal_manager.agregar_credito(credito)
```

## 4. Proceso de Auditoría de Licencias Pre-Launch

### Checklist pre-release

- [ ] Todos los tracks en `audio_licenses.json` tienen licencia asignada
- [ ] No hay licencias CC-BY-NC (prohibidas por política)
- [ ] Todas las licencias CC-BY tienen `attribution` no vacío
- [ ] `validate_all_audio()` retorna 0 errores
- [ ] `validar_build()` genera `AUDIO_CREDITS.txt` y `AUDIO_LICENSE_REPORT.txt`
- [ ] Créditos incluyen referencia a contrato y estado de pago
- [ ] Archivo de créditos verificado manualmente
- [ ] Contacto de abogado confirmado para clearances

### Contacto de abogado

- **Especialidad:** Entertainment Law / Intellectual Property
- **Uso:** Revisión de contratos de licencia, clearances de audio, DMCA
- **Cuándo consultar:** Antes de usar audio de terceros, al cambiar licencias, pre-launch

## 5. FAQ de Licencias de Audio en Juegos

### ¿Puedo usar música CC-BY-NC?
**No.** La política del proyecto prohíbe licencias NoComercial. Solo se permiten: propia, MIT, CC0, CC-BY, CC-BY-SA.

### ¿Qué hago si un track tiene múltiples licencias?
Registrar la licencia más restrictiva. Si un track tiene CC-BY + MIT, tratarlo como CC-BY (requiere atribución).

### ¿Cómo genero los créditos para el build?
`audio_legal_manager.validar_build()` lo hace automáticamente. También puedes usar `AudioCreditsGenerator` manualmente.

### ¿Necesito abogado para todo?
No. Solo para: contratos de licencia con terceros, clearances de audio existente, y revisión pre-launch.

### ¿Qué pasa si detecto una licencia inválida?
`validate_all_audio()` retorna los errores. Corregir en `audio_licenses.json` antes de commitear.

## 6. Tabla de Comparación de Tipos de Licencia

| Licencia | Uso comercial | Atribución | Modificar | Compartir igual | Notas |
|----------|--------------|------------|-----------|-----------------|-------|
| Propia | ✅ | ❌ | ✅ | ❌ | Total control |
| MIT | ✅ | ❌ | ✅ | ❌ | Mínima restricción |
| CC0 | ✅ | ❌ | ✅ | ❌ | Dominio público |
| CC-BY | ✅ | ✅ | ✅ | ❌ | Solo atribución |
| CC-BY-SA | ✅ | ✅ | ✅ | ✅ | Misma licencia |
| CC-BY-NC | ❌ | ✅ | ✅ | ❌ | ⛔ Prohibida |

## 7. Template de Email para Solicitar Clearances

```
Asunto: Solicitud de clearance de audio — [Nombre del Track]

Estimado/a [Nombre]:

Soy [Tu nombre], [cargo] de [estudio/proyecto]. Estamos desarrollando
un videojuego llamado "Isla Ancestral" y nos gustaría utilizar
su obra "[Nombre del Track]" en nuestro proyecto.

Detalles de uso:
- Obra: [Nombre del Track]
- Uso previsto: [menú/escena/gameplay]
- Licencia deseada: [CC-BY / MIT / Comercial]
- Duración del uso: [permanente / temporal]
- Plataformas: [PC / Web / Consolas]

Agradeceríamos nos indique:
1. Si el uso es aceptable bajo la licencia indicada
2. Si requiere atribución específica
3. Si hay restricciones adicionales
4. Si necesita compensación económica

Quedo a su disposición para cualquier consulta.

Saludos cordiales,
[Nombre]
[Contacto]
```

## 8. Registro de Cambios del Módulo

| Fecha | Cambio | Agente |
|-------|--------|--------|
| 2026-09-02 | Creación inicial: audio_license.gd, audio_credit.gd, validator, manager | deepseek-v4-flash |
| 2026-09-13 | Iteración 2: edge cases, policies documentadas | agnes-2.5-flash |
| 2026-09-15 | Iteración 3: credits generator, build integration | mimo-v2.5 |
| 2026-09-17 | Iteración 4: validar_build(), dry-run, skip_validation | mimo-v2.5 |
| 2026-09-18 | Iteración 5: guía de uso, FAQ, templates, tests edge case | mimo-v2.5 |

## 9. Proceso de Actualización de Créditos

1. **Detectar cambio:** nuevo track, cambio de artista, cambio de licencia
2. **Actualizar JSON:** modificar `audio_licenses.json`
3. **Validar:** ejecutar `validate_all_audio()`
4. **Regenerar créditos:** ejecutar `validar_build()` o manual con `AudioCreditsGenerator`
5. **Verificar:** revisar `AUDIO_CREDITS.txt` generado
6. **Commitear:** JSON + créditos generados
7. **Documentar:** agregar entrada en registro de cambios

## 10. Casos de Uso Edge — Audio de Dominio Público

### Audio CC0 (dominio público)
- No requiere atribución
- Puede usarse comercialmente
- Puede modificarse libremente
- **Recomendación:** incluir atribución voluntaria como cortesía

### Audio de dominio público (pre-CC0)
- Verificar que esté efectivamente en dominio público
- En EE.UU.: obra publicada antes de 1929
- En otros países: varía (generalmente 70 años después de muerte del autor)
- **Recomendación:** documentar origen y fecha de publicación

### Audio con licencia mixta
- Si un track tiene múltiples licencias disponibles, usar la más permisiva
- Documentar qué licencia se eligió y por qué
- Si hay duda, consultar con abogado
