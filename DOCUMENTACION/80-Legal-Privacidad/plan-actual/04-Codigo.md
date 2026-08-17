**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 80: Legal — Privacidad

> ⚠️ **Aviso:** Los fragmentos de política incluidos en este documento son **esqueletos de contenido** para la implementación. **No constituyen asesoramiento legal profesional** ni texto legal definitivo. La redacción final debe ser revisada por el fundador y, si corresponde, por un abogado antes de su publicación.

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `DOCUMENTACION/80-Legal-Privacidad/plan-actual/PRIVACY-POLICY.md` | Plantilla canónica de la política de privacidad del juego | Pendiente de redacción inicial |
| `DOCUMENTACION/80-Legal-Privacidad/plan-actual/DATA-DEclaration.md` | Declaración de datos recogidos / no recogidos | Pendiente de redacción inicial |
| `res://legal/privacy_policy.md` | Copia embebida de la política (recurso texto en Godot 4.x) | Pendiente de implementación |
| `res://legal/data_declaration.md` | Copia embebida de la declaración de datos | Pendiente de implementación |
| `res://legal/privacy_config.tres` | ConfigResource: `version`, `fecha_actualizacion`, `email_contacto`, `url_web` | Pendiente de implementación |
| `res://legal/privacy_menu.gd` | Escena/menú «Privacidad»: renderiza el texto embebido, muestra estado de telemetría M104 | Pendiente de implementación |
| `res://legal/privacy_consent.gd` | Gestor del diálogo de consentimiento (solo si M104 está activa) | Pendiente de implementación |

## 2. Esqueleto de PRIVACY-POLICY.md (contenido por secciones)

```markdown
# Política de Privacidad — Isla Ancestral

Versión 1.0 · Última actualización: [FECHA] · Responsable: [Nombre del estudio/desarrollador]

## 1. Introducción
«Isla Ancestral» es un juego single-player 100 % offline desarrollado en Godot 4.x
(mundo voxel cozy, isla Aurora). No requiere cuentas online, no se conecta a
servidores y, por defecto, **no recoge datos personales**.

## 2. Resumen ejecutivo
- No recogemos datos personales por defecto.
- Solo existe telemetría opcional, agregada y anonimizada, que TÚ activas
  desde la configuración y puedes desactivar en cualquier momento.
- Tus partidas viven en tu dispositivo. Tú decides cuándo borrarlas.

## 3. Datos que recogemos
| Dato | ¿Cuándo se recoge? | Tratamiento |
|---|---|---|
| Partida local (inventario, progreso, posición) | Siempre, solo en tu dispositivo | Local, sin transmisión |
| Telemetría agregada (bioma, duración de sesión, contadores) | Solo si activas Analytics | Agregada y anonimizada, máx. 30 días |

## 4. Datos que NO recogemos
No recogemos: cuentas, email, nombre, dirección, IP, ubicación GPS, datos de
dispositivo identificables, ni ninguna información de menores de 13 años.

## 5. Consentimiento
Si la telemetría está activa, al primer arranque se muestra un aviso informativo
y se solicita tu consentimiento antes de recoger cualquier dato.

## 6. Opt-out
Menú ► Configuración ► Analytics: puedes desactivar la telemetría cuando quieras.
Al desactivarla, se borra inmediatamente el buffer local de datos.

## 7. Derechos del usuario
De acuerdo con GDPR y CCPA puedes ejercer: acceso, rectificación, borrado,
portabilidad y oposición escribiendo a [EMAIL]. Respondemos en un máximo de 30 días.

## 8. Menores de edad
El juego no está dirigido a menores de 13 años (COPPA). En la Unión Europea,
los menores de 13 a 16 años requieren consentimiento parental (GDPR).
Si eres padre/madre/tutor, escríbenos a [EMAIL].

## 9. Retención de datos
- Partidas: mientras tú las conserves en tu dispositivo.
- Telemetría: máximo 30 días; se borra automáticamente.

## 10. Seguridad
Los datos se almacenan únicamente en tu dispositivo. En el estado por defecto
el juego no realiza ninguna transmisión de red.

## 11. Cambios en esta política
Cualquier cambio se publicará aquí con nueva versión y fecha. Si la versión
embebida en el juego cambia, se mostrará un aviso en el menú.

## 12. Cumplimiento regional
GDRP (UE) · COPPA (EE. UU.) · CCPA (California). Esta política aplica la
normativa más estricta como base común.

## 13. Contacto
Responsable: [Nombre del estudio] · Email de privacidad: [EMAIL] · Web: [URL]

## 14. Aviso legal
Este documento es informativo y no constituye asesoramiento legal profesional.
```

## 3. Esqueleto de DATA-DEclaration.md

```markdown
# Declaración de Datos — Isla Ancestral (Módulo 80)

| Dato | Por defecto | Con telemetría (M104) | Fin | Legal | Retención | Opt-out |
|---|---|---|---|---|---|---|
| Partida local | Sí (local) | Sí (local) | Progresión | Interés legítimo técnico | Hasta borrado | — |
| Configuración | Sí (local) | Sí (local) | Experiencia | Interés legítimo técnico | Hasta borrado | — |
| Bioma visitado (agregado) | No | Sí | Diseño | Consentimiento | 30 días | Toggle M104 |
| Duración de sesión (agregada) | No | Sí | Balance | Consentimiento | 30 días | Toggle M104 |
| Uso de features (contadores) | No | Sí | Priorización | Consentimiento | 30 días | Toggle M104 |
| Datos personales | No | No | — | — | — | — |
```

## 4. API pública prevista (GDScript, Godot 4.x)

```gdscript
# res://legal/privacy_config.gd (extiende Resource)
class_name PrivacyConfig
extends Resource

@export var version: String = "1.0"
@export var fecha_actualizacion: String = ""
@export var email_contacto: String = ""
@export var url_web: String = ""
```

```gdscript
# res://legal/privacy_menu.gd (Node, adosado a la escena del menú «Privacidad»)
class_name PrivacyMenu
extends Control

@onready var politica_label: RichTextLabel = %PoliticaLabel

func _ready() -> void:
    cargar_politica()

func cargar_politica() -> void:
    """Carga PRIVACY-POLICY.md embebido y lo muestra en la interfaz."""
    var ruta: String = "res://legal/privacy_policy.md"
    if FileAccess.file_exists(ruta):
        politica_label.text = FileAccess.get_file_as_string(ruta)

func mostrar_estado_telemetria() -> String:
    """Consulta a M104 si está disponible; si no, 'desactivada' por defecto."""
    # Integración futura: AnalyticsDirector.esta_opt_out()
    return "desactivada"
```

```gdscript
# res://legal/privacy_consent.gd (autoload opcional, solo si M104 estará activa)
class_name PrivacyConsent
extends Node

signal consentimiento_resuelto(aceptado: bool)

func necesita_consentimiento() -> bool:
    """Solo pide consentimiento si la telemetría M104 está activa."""
    # Integración futura: consultar AnalyticsDirector / config M104
    return false

func resolver(aceptado: bool) -> void:
    emit_signal("consentimiento_resuelto", aceptado)
```

## 5. Integración con M104 (telemetría opt-out)

- **Fuente de verdad del estado:** la configuración de M104 (Analytics). `privacy_menu.gd` solo la consulta, nunca la modifica (separación de responsabilidades, AGENTS.md §9).
- **Consentimiento:** `privacy_consent.gd` se ejecuta únicamente si `AnalyticsDirector` existe y reporta telemetría activa; si el jugador rechaza, se invoca `establecer_opt_out(true)` de M104.
- **Borrado:** al desactivar el opt-out se borra el buffer local de M104 (responsabilidad de M104; la política solo lo documenta).
- **Vista de estado:** la sección «Privacidad» del menú muestra «Telemetría: activa/desactivada» y el enlace a la política.

## 6. Integración con M78 (Legal — Propiedad Intelectual)

- La política de privacidad **no** trata derechos de autor; referencia a M78 solo en la sección de contacto/aviso (titularidad de los contenidos del juego).
- La firma de la política identifica al responsable del tratamiento, que es el mismo titular de la propiedad intelectual (coherencia entre M78 y M80).
- Si M78 define razón social/marca comercial, usar ese nombre en la sección 13 (Contacto) de la política.

## 7. Pendientes de implementación

- Redactar `PRIVACY-POLICY.md` completo (esqueleto anterior) y validar con el fundador.
- Redactar `DATA-DEclaration.md` completo.
- Crear `privacy_config.tres` con versión, fecha, email y URL.
- Implementar `privacy_menu.gd` y la entrada «Privacidad» en el menú principal.
- Implementar `privacy_consent.gd` conectado a M104 cuando exista.
- Revisar la política contra los requisitos de publicación de Steam/Epic antes del build.

## 8. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 80 (plan-inicial + plan-actual idénticos): requerimientos, análisis de dominio (GDPR/COPPA/CCPA), diseño de la política y declaración de datos, esqueletos de contenido y APIs previstas en GDScript para Godot 4.x.
- Definió 12 requisitos funcionales (política, declaración, consentimiento, opt-out, derechos, menores, retención, publicación web/en juego, cumplimiento regional, versionado, contacto) y 8 no funcionales.
- Documenté las 7 decisiones clave, incluida la política mínima (juego 100 % offline) y la telemetría opcional M104 con opt-out.
- Alineé la integración con M78 (titularidad) y M104 (estado del opt-out como única fuente de verdad).
- La checklist de implementación supera los 115 ítems, todos verificables.

### Lo que NO pude hacer (honestidad obligatoria)
- **No redacté el texto legal definitivo**: los documentos son esqueletos/plantillas. La redacción legal final requiere revisión del fundador y, preferentemente, de un abogado antes de publicarse (especialmente secciones de menores, retención y cumplimiento regional).
- No implementé código: este módulo es 100 % documentación; la implementación (menú «Privacidad», diálogo de consentimiento) queda delegada y depende de que M104 exista.
- No verifiqué los requisitos exactos y actuales de publicación de Steam/Epic para políticas de privacidad (pueden cambiar; verificar antes del build).

### Recomendaciones para el próximo agente
- Al implementar: crear `res://legal/` (GDScript, Godot 4.x) con `privacy_config.gd`, `privacy_menu.gd` y `privacy_consent.gd` siguiendo las APIs previstas en la sección 4.
- Redactar la versión 1.0 de `PRIVACY-POLICY.md` y `DATA-DEclaration.md` en `plan-actual/` y embederlas en `res://legal/`.
- Conectar el diálogo de consentimiento a M104 solo si `AnalyticsDirector` existe; el estado por defecto es NO pedir consentimiento.
- Antes del build de distribución, validar con la checklist que la política cumple los requisitos de tiendas y revisar con el fundador la sección de contacto (email real del estudio).
- Actualizar `plan-actual/` de este módulo si cambia el modelo de datos (ej: crash reporting M122).