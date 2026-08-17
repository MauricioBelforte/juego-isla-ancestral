**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 80: Legal — Privacidad

> ⚠️ **Aviso:** Este documento es análisis técnico/administrativo del dominio de privacidad. **No constituye asesoramiento legal profesional.** Las decisiones aquí planteadas deben validarse con el fundador y, en caso de duda, con un profesional del derecho.

## 1. Análisis del dominio

### 1.1 Contexto del juego
«Isla Ancestral» (Godot 4.x + Voxel Tools, GDScript) es un juego single-player 100 % offline, mundo voxel cozy (isla Aurora), sin cuentas online, sin persistencia en servidores y casi sin telemetría. La única recolección posible de datos es la telemetría opcional del módulo M104 (analytics agregados y anonimizados, con opt-out). Esto define un perfil de riesgo de privacidad **muy bajo**, pero exige documentación porque el proyecto se distribuirá por plataformas que lo requieren (Steam, Epic, etc.).

### 1.2 Marco normativo de referencia

| Norma | Ámbito | Qué exige | Relevancia para M80 |
|---|---|---|---|
| GDPR (Reglamento UE 2016/679) | Unión Europea | Licitud y transparencia del tratamiento, datos mínimos, consentimiento, derechos ARCO+2 (acceso, rectificación, supresión, portabilidad, oposición), retención limitada, notificación de brechas, menores 13-16 con consentimiento parental según país | Alta: publicación en Europa; define el esqueleto de derechos y consentimiento |
| COPPA (Children's Online Privacy Protection Act) | EE. UU. | Consentimiento parental verificable para recoger datos de menores de 13 años; política de privacidad clara | Media: el juego no está dirigido a menores de 13; se declara explícitamente |
| CCPA/CPRA | California, EE. UU. | Derechos: conocer (know), borrar (delete), opt-out de venta/compartición, no discriminación | Media: sección específica; el juego no vende datos, se declara |

### 1.3 Principios rectores aplicados

1. **Minimización de datos:** recoger lo mínimo necesario; en el estado por defecto del juego: **nada**.
2. **Privacidad por diseño y por defecto:** la configuración por defecto es no recoger datos; la telemetría M104 inicia apagada.
3. **Anonimización y agregación:** si se activa M104, solo datos agregados (bioma visitado, duración de sesión), nunca identificables (M104 ya define IDs de sesión hash rotativos e IP truncada).
4. **Transparencia radical:** la política dice exactamente qué se recoge y qué no, sin ambigüedades.
5. **Control del usuario:** opt-out visible, reversible y efectivo en el mismo frame en que se desactiva (M104 lo garantiza).
6. **Retención limitada:** plazos cortos y borrado automático del buffer local de telemetría.

### 1.4 Derechos del usuario (mapa)

| Derecho | GDPR | CCPA | Cómo se satisface en un juego offline sin datos |
|---|---|---|---|
| Acceso | Art. 15 | Right to know | Email de contacto; respuesta dentro de plazos legales |
| Rectificación | Art. 16 | — | Corrección de datos locales si los hubiera |
| Borrado | Art. 17 | Right to delete | Borrado manual/local de datos de juego y telemetría |
| Portabilidad | Art. 20 | — | Exportación de partida (formato JSON local) |
| Oposición/opt-out | Art. 21 | Opt-out de venta | Toggle M104; sin venta de datos (declarado) |
| No discriminación | — | CCPA | El opt-out no degrada la experiencia de juego |

### 1.5 Política de retención

- **Partidas locales:** se conservan mientras el jugador las mantenga; borrado manual disponible (datos en el dispositivo del usuario).
- **Telemetría M104 (si activa):** buffer local con plazo máximo definido (ej: 30 días) y borrado automático al desactivar el opt-out.
- **Respaldos (M107):** los backups son locales y del jugador; no involucran datos personales del titular.
- **Cualquier dato futuro (crash reporting, M122):** ignorar por el momento; M104 es la única fuente.

### 1.6 Menores de edad

- El juego no está dirigido a menores de 13 años (declaración COPPA) y no recoge datos personales; por lo tanto, COPPA no se activa en el estado por defecto.
- Bajo GDPR, la política informa el rango 13-16 con consentimiento parental según legislación local (España: 14 años).
- La política incluye la instrucción de que un menor no debe proporcionar datos personales; si M104 se activa, el consentimiento debe ser verificable.

### 1.7 Alternativas consideradas

| Alternativa | Evaluación | Veredicto |
|---|---|---|
| No publicar política de privacidad | Bloquea distribución (Steam exige política), arriesga sanciones y reputación | ❌ Descartada |
| Crear cuentas online obligatorias para "mejorar" el producto | Contradice el modelo cozy, single-player y offline; aumenta superficie de datos personales | ❌ Descartada |
| Telemetría obligatoria sin opt-out | Violaría GDPR/CCPA y la confianza de la comunidad | ❌ Descartada |
| Pedir consentimiento aunque no haya datos | Fricción innecesaria; consentimiento sin objeto real | ❌ Descartada |
| Contratar asesoría legal externa desde el día 1 | Costosa e innecesaria en esta fase; se delega revisión final | ⏸️ Pospuesta (revisión final) |
| Publicar política mínima alineada al juego real | Cumple transparencia, plataformas y expectativa del jugador con esfuerzo ajustado | ✅ Adoptada |

### 1.8 Decisiones clave

1. **Decisión 80-D1 — Política mínima por diseño:** el documento base declara que el juego no recoge datos personales (offline, sin cuentas). Es la decisión central: refleja el estado real y evita sobre-promesas.
2. **Decisión 80-D2 — Telemetría opcional con opt-out:** se documenta el escenario M104: consentimiento al primer arranque (solo si la telemetría está habilitada por configuración), opt-out permanente y borrado inmediato del buffer al desactivar.
3. **Decisión 80-D3 — Consentimiento condicionado a datos reales:** no se muestra diálogo de consentimiento si no hay telemetría activa; se evita fricción innecesaria.
4. **Decisión 80-D4 — Texto legal desacoplado del código:** la política vive en `PRIVACY-POLICY.md` (y copia embebida como recurso Godot); el menú «Privacidad» solo la renderiza. Facilita actualizaciones sin recompilar lógica.
5. **Decisión 80-D5 — Publicación dual:** web oficial del juego (URL estable, versión canónica) + sección «Privacidad» en el menú del juego (versión de referencia).
6. **Decisión 80-D6 — Versionado semántico del documento:** cada revisión de la política lleva fecha, versión y changelog; cambios significativos se notifican en el menú del juego (aviso único al actualizar la versión local).
7. **Decisión 80-D7 — Canal de contacto único:** un email de privacidad del estudio canaliza derechos ARCO+2, dudas de menores y peticiones de borrado.

### 1.9 Riesgos y mitigaciones

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| La política promete más de lo que el juego cumple | Baja | Revisión de cada afirmación contra el comportamiento real (RF, testings) |
| Futura feature online rompe el modelo offline | Baja | Cláusula de cambios: cualquier futuro tratamiento de datos se incorpora a la política antes de activarse (Decisión 80-D6) |
| Publicación en tiendas rechazada por política incompleta | Media | Plantillas alineadas a los requisitos típicos de Steam/Epic (contacto, retención, menores, derechos) |
| Interpretación errónea como asesoramiento legal | Media | Aviso explícito en todos los documentos del módulo |
| Traducciones inexactas (futuro) | Media | Base única en español; traducciones con revisión antes de publicarse |