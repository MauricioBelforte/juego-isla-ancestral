**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

**Módulo:** 127-Copyright-Del-Juego (127)

# Checklist personal tareas — 127-Copyright-Del-Juego

> Extraídas del `05-Checklist.md` del módulo (101 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.
>
> **iter. 2 (2026-09-15, Log 923):** re-marcado honesto tras la reversión de la auditoría del 2026-09-14
> (agnes-2.5-flash cerró el módulo citando secciones de `03-Diseno.md` que **no existen**: 2.3/3.1/3.2/4.2/4.3).
> Criterio: **[x]** cita un artefacto real o una sección existente; **[?]** nombra el dueño externo o la
> acción humana requerida; **[ ]** es trabajo pendiente real del módulo. Se **preservan** las 4 marcas
> previas de MiMo V2.5 (minimax-m3-free). Resultado: **39 `[x]` · 25 `[?]` · 37 `[ ]`**.
>
> **Entregable nuevo:** `legal/copyright_register.md` (antes referencia colgante), generado de forma
> determinista por `tools/legal/generate_copyright_register.py` (test 18/18, modo `--check` para CI).
> Suite del módulo `test_copyright_m127.gd`: **13 checks / 0 fallos ×3**, guardián anti-falso-verde
> probado por inyección.
>
> **Abiertos `[?]`:** usuario/asesoría legal (registro formal, DMCA, disputas, jurisdicciones) ·
> M118/M06/M41/M45/M22/M147/M131/M103/M107 (integración) · M46/M89/M130 (assets y UI).

## Tareas

- [x] T-001 Cargar datos desde JSON (secciones/politicas/elementos) [S]
- [x] T-002 Detectar errores estructurales (id, nombre, etc) [S]
- [x] T-003 Test headless de validacion [M]
- [x] T-004 Datos data-driven en data/legal/ [S]
- [?] T-005 Registrar narrativa
- [?] T-006 Registrar logos
- [x] T-007 Mantener evidencia de autoría
- [x] T-008 Definir copyright automatico en creacion (Berne Convention)
- [x] T-009 Definir código (automatico en creacion)
- [x] T-010 Definir arte (automatico en creacion)
- [x] T-011 Definir música (automatico en creacion)
- [x] T-012 Definir narrativa (automatico en creacion)
- [x] T-013 Definir logos (automatico en creacion)
- [x] T-014 Definir registro formal (USCO, etc.)
- [x] T-015 Definir registro de código (USCO: Source Code)
- [x] T-016 Definir registro de arte (USCO: Visual Arts)
- [x] T-017 Definir registro de música (USCO: Sound Recording)
- [x] T-018 Definir registro de narrativa (USCO: Literary Work)
- [x] T-019 Definir registro de logos (USCO: Visual Arts)
- [x] T-020 Diseñar costos (USD 35-85 por registro)
- [ ] T-021 Diseñar beneficios (proteccion legal, presuncion de validez)
- [x] T-022 Definir git logs (commits, autores, fechas)
- [x] T-023 Definir timestamps (archivos, commits)
- [ ] T-024 Definir borradores (sketches, iteraciones)
- [x] T-025 Definir metadata (EXIF, IPTC, tags)
- [x] T-026 Definir registro de código (copyright automatico)
- [x] T-027 Definir evidencia de autoría (git logs, timestamps)
- [x] T-028 Diseñar git logs como prueba de evolucion
- [ ] T-029 Diseñar git blame para rastrear autoría
- [x] T-030 Definir registro de arte (copyright automatico)
- [x] T-031 Definir evidencia de autoría (timestamps, borradores)
- [x] T-032 Diseñar timestamps de archivos como evidencia
- [ ] T-033 Diseñar borradores de arte (sketches, iteraciones)
- [x] T-034 Definir registro de música (copyright automatico)
- [x] T-035 Definir evidencia de autoría (timestamps, archivos de proyecto)
- [x] T-036 Diseñar timestamps de archivos como evidencia
- [ ] T-037 Diseñar archivos de proyecto (DAW, MIDI)
- [x] T-038 Definir registro de narrativa (copyright automatico)
- [x] T-039 Definir evidencia de autoría (timestamps, borradores)
- [x] T-040 Diseñar timestamps de archivos como evidencia
- [ ] T-041 Diseñar borradores de narrativa (Google Docs, Word)
- [x] T-042 Definir registro de logos (copyright automatico)
- [x] T-043 Definir evidencia de autoría (timestamps, borradores)
- [x] T-044 Diseñar timestamps de archivos como evidencia
- [ ] T-045 Diseñar borradores de logos (sketches, iteraciones)
- [x] T-046 Diseñar legal/copyright_register.md
- [x] T-047 Diseñar prueba de que git logs muestran autoría correcta
- [ ] T-048 Diseñar prueba de que timestamps sean consistentes
- [ ] T-049 Diseñar prueba de que borradores estén accesibles
- [ ] T-050 Diseñar prueba de que metadata esté presente
- [x] T-051 Desarrollar script para generar automáticamente el archivo de avisos de copyright y atribución en cada build [S]
- [ ] T-052 Implementar protocolo automatizado de inserción de encabezados de copyright en scripts de código fuente (.gd / .cs) [S]
- [ ] T-053 Crear sistema de sellado de tiempo criptográfico (hashes SHA-256) sobre versiones maestras de código, arte y audio [M]
- [ ] T-054 Documentar procedimiento operativo paso a paso para el registro formal de código ante la US Copyright Office (USCO) [M]
- [ ] T-055 Documentar procedimiento operativo para el registro formal de arte 2D/3D y logos ante la USCO (Visual Arts) [M]
- [ ] T-056 Documentar procedimiento operativo para el registro formal de la banda sonora ante la USCO (Sound Recording) [M]
- [ ] T-057 Documentar procedimiento operativo para el registro formal de la narrativa y biblia de lore ante la USCO (Literary Work) [M]
- [ ] T-058 Diseñar sistema de resguardo inmutable de logs de Git y commits para trazabilidad de autoría en litigios [M]
- [ ] T-059 Implementar validador de metadata de copyright embebida en assets exportados (texturas, modelos, música) [S]
- [?] T-060 Integrar con M118 (CI/CD) para verificar automáticamente la presencia de cabeceras de copyright en cada PR [M]
- [?] T-061 Integrar con M06 (Control de Versiones) para auditorías periódicas de historial de autoría mediante git blame [S]
- [?] T-062 Integrar con M41 (Música) para archivar sesiones multipista (DAW), stems y partituras como prueba de autoría
- [?] T-063 Integrar con M45 (Arte 3D) para archivar archivos maestros .blend con timestamps de creación inmutables [M]
- [?] T-064 Integrar con M22 (Historia Principal) y M147 (World Building) para archivar borradores y cronología de lore [M]
- [?] T-065 Integrar con M131 (Créditos) para asegurar correspondencia 100% fiel entre autores reales y créditos in-game [S]
- [?] T-066 Integrar con M103 (Logging) para auditar cambios en declaraciones de derechos de autor y licencias [S]
- [?] T-067 Integrar con M107 (Backups) para resguardo redundante (estrategia 3-2-1) de evidencias de autoría original [M]
- [?] T-068 Diseñar protocolo formal de respuesta y contra-notificación ante reclamos falsos o maliciosos de DMCA [M]
- [?] T-069 Establecer mecanismo de resolución de disputas de coautoría con colaboradores externos o exempleados [M]
- [?] T-070 Definir protocolo de evaluación legal ante inclusión de librerías open source con licencias copyleft o ambiguas [M]
- [?] T-071 Establecer plan de acción ante detección de clones, ripeos de assets o plagios en tiendas no autorizadas [M]
- [?] T-072 Diseñar procedimiento ante disputas de autoría de samples o librerías de sonido
- [?] T-073 Definir gestión de propiedad intelectual sobre prototipos o conceptos desarrollados en game jams previas
- [?] T-074 Establecer protocolo de depuración urgente si se detectan assets provisionales de terceros en builds release [M]
- [?] T-075 Diseñar estrategia de protección de copyright en jurisdicciones internacionales no firmantes del Convenio de Berna [M]
- [ ] T-076 Automatizar el empaquetado de código y muestras visuales según formatos y límites USCO
- [ ] T-077 Desarrollar herramienta de escaneo de repositorio para detectar código huérfano sin atribución de autor [M]
- [?] T-078 Optimizar costos de registro formal agrupando múltiples obras relacionadas bajo registros colectivos [S]
- [ ] T-079 Diseñar pipeline de metadata que no incremente innecesariamente el tamaño de los paquetes de distribución [S]
- [ ] T-080 Centralizar base de datos de números de registro, certificados y fechas de concesión de derechos de autor [S]
- [ ] T-081 Simplificar la recolección de pruebas periciales de autoría mediante scripts de volcado de commits y diffs [M]
- [ ] T-082 Implementar auditoría automatizada de dependencias para certificar la ausencia de código no autorizado [M]
- [?] T-083 Mantener matriz de titularidad de derechos actualizada ante eventuales cesiones, acuerdos o publishing
- [ ] T-084 Redactar guía interna sobre buenas prácticas de preservación de evidencia de autoría para desarrolladores [M]
- [ ] T-085 Elaborar directrices para la correcta redacción de avisos legales de copyright en UI, manuales y packaging [S]
- [ ] T-086 Mantener catálogo maestro de certificados de registro de copyright oficiales obtenidos por el proyecto [S]
- [ ] T-087 Documentar política oficial de counter-notice DMCA para plataformas de distribución digital [M]
- [ ] T-088 Redactar documento explicativo sobre derechos morales y derechos patrimoniales aplicables al videojuego [M]
- [?] T-089 Diseñar contratos estándar de cesión de derechos de autor (Work for Hire) para freelancers y contratistas
- [ ] T-090 Documentar fechas clave de primera fijación y publicación de cada componente creativo de Isla Ancestral [S]
- [ ] T-091 Elaborar FAQ interno sobre uso de referencias visuales, homenajes y límites del Fair Use [S]
- [?] T-092 Diseñar presentación estética y tipográfica del aviso de copyright en pantalla de título, splash y menú de créditos [S]
- [ ] T-093 Implementar identificadores discretos o marcas de agua forenses en builds preliminares entregadas a prensa [M]
- [?] T-094 Estandarizar el diseño visual de los certificados y carpetas del archivo histórico de propiedad intelectual
- [?] T-095 Crear pantalla accesible y navegable de licencias de software y librerías de terceros en el menú de opciones [S]
- [ ] T-096 Redactar acuerdos de cesión de derechos con tono amigable y explicaciones claras para artistas colaboradores [S]
- [ ] T-097 Publicar guía comunitaria sobre uso permitido de marcas y arte del juego para fanart y contenido no comercial [S]
- [?] T-098 Diseñar sello distintivo de copyright oficial para manuales de juego, artbooks y piezas de coleccionista [S]
- [ ] T-099 Realizar revisión semestral de la consistencia de marcas y avisos de copyright en todas las plataformas soportadas [S]
- [ ] T-100 Documentar registro de la primera fijación y uso ininterrumpido del nombre 'Isla Ancestral' como evidencia de derechos marcarios ante eventuales oposiciones [M]
- [ ] T-101 Diseñar auditoría de dependencias del repositorio para certificar que el build final no incorpora assets placeholder de terceros sin licencia [M]
