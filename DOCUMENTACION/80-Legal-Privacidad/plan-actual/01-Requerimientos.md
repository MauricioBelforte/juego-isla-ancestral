**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 80: Legal — Privacidad

## ID del Módulo
- **Código:** M80 (plan maestro: componente nuevo — Legal/Privacidad)
- **Carpeta:** `DOCUMENTACION/80-Legal-Privacidad/`
- **Dependencias:** M78 (Legal — Propiedad Intelectual)
- **Relacionados:** M104 (Analytics, telemetría opcional con opt-out), M81 (Legal — Menores), M79 (Legal — Contratos)
- **Delegable desde:** documentación completa; implementación tras revisión legal del fundador

## 1. Problema

«Isla Ancestral» es un juego single-player 100 % offline desarrollado en Godot 4.x con Voxel Tools, ambientado en un mundo voxel cozy (la isla Aurora). Por diseño el juego no requiere cuentas online, no recoge datos personales por defecto y casi no tiene telemetría. Sin embargo, hoy no existe ningún documento legal/administrativo que comunique esto al jugador.

Sin una política de privacidad publicada, el proyecto queda expuesto a:

1. **Riesgo de compliance regional:** No documentar el tratamiento de datos infringe principios de GDPR (UE), COPPA (EE. UU., menores de 13) y CCPA (California) si en el futuro se activa telemetría (M104).
2. **Falta de transparencia:** El jugador no sabe qué datos se recogen (casi ninguno) ni cómo ejercer sus derechos.
3. **Bloqueo de distribución:** Plataformas como Steam, App Store o Google Play exigen política de privacidad para publicar el juego.
4. **Dependencia de M104:** Si se activa la telemetría opcional, debe existir consentimiento previo y opt-out claro.

## 2. Objetivo

Producir la documentación completa del módulo Legal — Privacidad: política de privacidad (plantilla), declaración de datos recogidos, flujo de consentimiento (telemetría M104), derechos del usuario, protección de menores, política de retención y publicación en web del juego + menú del juego. Todo bajo el principio de **privacidad por diseño** y con la premisa de que **el juego no recoge datos por defecto**.

> ⚠️ **Aviso:** Toda la documentación de este módulo es material preparatorio y **NO constituye asesoramiento legal profesional**. La redacción legal final debe ser revisada por el fundador y, si corresponde, por un abogado antes de su publicación.

## 3. Alcance

### Dentro del alcance
- Plantilla `PRIVACY-POLICY.md` (política de privacidad del juego).
- Plantilla `DATA-DEclaration.md` (declaración de datos recogidos / no recogidos).
- Flujo de consentimiento si la telemetría M104 está activa (consentimiento previo + opt-out permanente).
- Derechos del usuario: acceso, rectificación, borrado, portabilidad y oposición (GDPR art. 15-21; CCPA: know, delete, opt-out).
- Protección de menores: juego no dirigido a menores de 13 (COPPA) y franja 13-16 con consentimiento parental (GDPR).
- Política de retención de datos con plazos y borrado automático.
- Publicación: web oficial del juego + sección «Privacidad» dentro del menú del juego.
- Enlace y coherencia con M104 (telemetría opcional, agregada, anonimizada, con opt-out).

### Fuera del alcance (otros módulos)
- M78 — Propiedad intelectual (derechos de autor, assets, música). Dependencia, no contenido.
- M79 — Contratos (acuerdos con terceros, publishers).
- M81 — Menores (política detallada de menores y verificación parental). Este módulo solo integra lo esencial.
- M82 — Clasificación por edades (IARC).
- Términos de servicio (M125) y marketing legal (M126).

## 4. Restricciones

1. **Juego 100 % offline:** la política debe reflejar que no hay cuentas, servidores ni datos personales por defecto.
2. **Datos mínimos:** si se recoge telemetría (M104), solo datos agregados y anonimizados, nunca identificables.
3. **Opt-out obligatorio:** cualquier recolección futura debe tener opt-out claro y reversible, alineado con M104.
4. **Lenguaje claro:** la política debe estar redactada en español comprensible, sin jerga legal innecesaria.
5. **Sin asesoramiento legal:** los documentos son plantillas; requieren revisión profesional antes de publicarse.
6. **Godot 4.x / GDScript:** cualquier herramienta dentro del juego (menú «Privacidad») se implementa en GDScript, sin dependencias externas de red.
7. **Modularidad (AGENTS.md §9):** la lógica de UI (menú) no debe acoplarse al contenido legal; el texto vive en archivos `.md`/`.tres` separados.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Política de privacidad publicada | Documento completo, en español, accesible desde la web del juego y desde el menú del juego |
| RF2 | Declaración de datos | `DATA-DEclaration.md`: inventario explícito de qué datos se recogen (ninguno por defecto) y cuáles se recogerían si se activa M104 |
| RF3 | Consentimiento previo | Si la telemetría M104 está activa, solicitar consentimiento informado al primer inicio, antes de recoger cualquier dato |
| RF4 | Opt-out permanente | Mecanismo visible para desactivar la telemetría en cualquier momento (toggle M104 + instrucciones en la política) |
| RF5 | Derechos del usuario | Canales para ejercer acceso, rectificación, borrado, portabilidad y oposición; email de contacto de privacidad |
| RF6 | Protección de menores | Juego no dirigido a menores de 13 años (COPPA); para 13-16 (UE) se requiere consentimiento parental conforme a GDPR |
| RF7 | Política de retención | Plazos máximos de conservación de datos locales (si los hubiera) y ciclo de borrado automático |
| RF8 | Publicación web | La política se publica en la web oficial del juego con URL estable |
| RF9 | Publicación en el juego | Sección «Privacidad» accesible desde el menú principal o configuración, con el texto de la política |
| RF10 | Cumplimiento regional | Secciones específicas: GDPR (UE), COPPA (EE. UU.) y CCPA (California) |
| RF11 | Versionado y cambios | Registro de versiones de la política con fecha de última actualización y aviso de cambios significativos |
| RF12 | Contacto | Identificar responsable del tratamiento y email de contacto de privacidad |

## 6. Requisitos No Funcionales

- **Privacidad por diseño:** el comportamiento por defecto del juego es no recoger datos.
- **Transparencia:** la política describe con exactitud qué se recoge y qué no; sin promesas que el juego no cumpla.
- **Accesibilidad:** estructura por secciones, tablas y lenguaje claro; pensada para lectura fácil.
- **Mantenibilidad:** plantillas separadas de la lógica del juego (archivos texto/ConfigResource), fáciles de actualizar sin tocar código.
- **Rendimiento:** la sección «Privacidad» en el menú no debe afectar los tiempos de carga ni el frame budget (texto estático, sin red).
- **Sin dependencias de red:** el juego offline no requiere conexión para mostrar la política.
- **Comprobable:** cada afirmación de la política se corresponde con el comportamiento real del juego (M104, configuraciones).
- **Aviso legal:** los documentos incluyen la aclaración de que no constituyen asesoramiento legal profesional.

## 7. Criterios de Aceptación

1. Existen las plantillas `PRIVACY-POLICY.md` y `DATA-DEclaration.md` con todas las secciones del diseño (03-Diseno.md).
2. La política refleja el modelo real: single-player offline, sin cuentas, casi sin telemetría.
3. El flujo de consentimiento + opt-out de M104 queda documentado y es implementable en GDScript.
4. Se cubren GDPR, COPPA y CCPA con secciones propias.
5. Los derechos de acceso, borrado y portabilidad tienen canal de contacto definido.
6. Los documentos incluyen el aviso de que no constituyen asesoramiento legal profesional.
7. La checklist (05-Checklist.md) supera los 115 ítems y queda delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M078** — Legal — Propiedad Intelectual | Base para legal — propiedad intelectual |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M081** — Legal — Menores | Usado por legal — menores |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M078** — Legal — Propiedad Intelectual | Depende de este módulo |
| **M081** — Legal — Menores | Este módulo lo necesita |

