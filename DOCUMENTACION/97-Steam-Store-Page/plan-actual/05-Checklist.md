**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 97: Steam / Store Page

## A. Problema, objetivos y alcance

- [ ] Definir el problema: el juego es invisible hasta que tiene store page en Steam [S]
- [ ] Registrar que la store page es el embudo principal de conversión del nicho indie cozy [M]
- [ ] Definir el objetivo: página completa y profesional antes de la campaña de marketing [M]
- [ ] Definir el objetivo secundario: maximizar wishlists en pre-lanzamiento [M]
- [ ] Definir alcance: textos, tags, capturas, trailer planificado, requisitos, precio, assets, keywords [M]
- [ ] Definir fuera de alcance: integración técnica Steamworks en el juego (M96) [S]
- [ ] Definir fuera de alcance: proceso de review y publicación de Steam (M143) [S]
- [ ] Definir fuera de alcance: producción física del trailer final (delegada a medios) [S]
- [ ] Registrar dependencia de M96 (Plataformas) sin bloquearse por su falta de documentación [S]
- [ ] Registrar integración con M86 (IA Generativa) para borradores únicamente [S]
- [ ] Registrar integración con M136 (Hoja de Ruta) para fechas de visibilidad [S]
- [ ] Registrar integración con M143 (Lanzamiento) para la ventana de salida [S]
- [ ] Confirmar stack correcto: Godot 4.x + Voxel Tools + GDScript, sin Unity/C# [S]
- [ ] Establecer restricción: contenido 100 % fiel al build real del juego [S]
- [ ] Establecer restricción: costo mínimo, priorizando assets internos [S]

## B. RF: Descripción y textos de la página

- [ ] RF1.1: redactar short description de máximo 300 caracteres [M]
- [ ] RF1.1: escribir short description en español con fantasía cozy (isla, calma, ritmo propio) [M]
- [ ] RF1.1: escribir short description en inglés con el mismo gancho emocional [M]
- [ ] RF1.2: estructurar el About con 7 secciones (gancho, ritmo, cultivo, hogar, isla viva, misterios, CTA) [M]
- [ ] RF1.2: incluir agricultura (M33) en la sección de cultivo [S]
- [ ] RF1.2: incluir pesca (M34) y minería (M35) en la sección de cultivo [S]
- [ ] RF1.2: incluir crafting (M16), construcción (M17) y casa (M18) en la sección de hogar [S]
- [ ] RF1.2: incluir vecinos (M19), amistad (M20) y diálogos (M21) en la sección de isla viva [S]
- [ ] RF1.2: incluir historia (M22/M23) y templos/ruinas (M24/M25) en la sección de misterios [S]
- [ ] RF1.2: cerrar el About con llamada a la acción de wishlist [M]
- [ ] RF1.3: limitar cada sección a 1 párrafo + 2-4 bullets [M]
- [ ] RF1.4: pasar los textos por revisión humana del fundador (política M86) [M]
- [ ] RF1.4: verificar que el tono es cálido y sin presión (regla cozy) [S]
- [ ] Redactar FAQ breve: multijugador no, duración, controles, final [M]
- [ ] Verificar el límite de caracteres vigente de la short description en Steamworks [S]

## C. RF: Tags y categorías

- [ ] Seleccionar los 20 tags permitidos del catálogo oficial de Steam [M]
- [ ] Incluir el tag Cozy en la selección [S]
- [ ] Incluir Farming Sim en la selección [S]
- [ ] Incluir Life Sim en la selección [S]
- [ ] Incluir Building en la selección [S]
- [ ] Incluir Crafting en la selección [S]
- [ ] Incluir Voxel en la selección [S]
- [ ] Incluir Open World o Sandbox según disponibilidad [S]
- [ ] Incluir Exploration y Relaxing en la selección [S]
- [ ] Incluir Singleplayer como tag y como categoría principal [S]
- [ ] Incluir Agriculture, Fishing y Mining si el catálogo los ofrece [S]
- [ ] Marcar la categoría Controller si el juego soporta mando (M57) [S]
- [ ] Verificar que ningún tag inventado o inexistente entra en la lista [S]
- [ ] Verificar que los tags no dupliquen las keywords (evitar relleno) [M]
- [ ] Planificar el primer pase de corrección de tags 2 semanas post-publicación [S]

## D. RF: Capturas de pantalla

- [ ] Planificar entre 6 y 8 capturas finales (máximo 10 permitido por Steam) [M]
- [ ] Definir la resolución mínima 1280x720 y objetivo 1920x1080 en 16:9 [S]
- [ ] Shot 1: playa de Aurora al amanecer con el personaje visible [M]
- [ ] Shot 2: huerto con cultivos listos en horas de tarde [M]
- [ ] Shot 3: pesca en el río con luz de mañana [M]
- [ ] Shot 4: entrada de la mina con iluminación interior cálida [M]
- [ ] Shot 5: taller de crafting y casa construida al atardecer [M]
- [ ] Shot 6: plaza del pueblo con 2-3 vecinos a mediodía [M]
- [ ] Shot 7: templo en ruinas con puzzle y antorchas de noche [M]
- [ ] Shot 8: vista aérea de la isla en golden hour [M]
- [ ] Prohibir en capturas: UI de debug, consola, textos de desarrollo [S]
- [ ] Prohibir en capturas: logs de herramientas o logos de editor [S]
- [ ] Prohibir en capturas: textos en otro idioma sin subtítulos [S]
- [ ] Asegurar que cada captura muestra gameplay real de builds verificados [S]
- [ ] Exportar las capturas sin compresión visible (PNG o JPG de alta calidad) [S]

## E. RF: Trailer y vídeo

- [ ] Planificar un trailer principal de 60 a 90 segundos [M]
- [ ] Respetar el límite de Steam de 15 s a 2 min por tramo de vídeo [S]
- [ ] Definir formato MP4 H.264 a 1920x1080 [S]
- [ ] Estructurar el guion en 3 actos: hook (0-8 s), sistemas (8-55 s), cierre (55-90 s) [M]
- [ ] Hook: desembarco o primera mañana en la isla como apertura [M]
- [ ] Acto central: montaje de 6 tomas (cultivo, pesca, minería, crafting, pueblo, templo) [C]
- [ ] Cierre: logo del juego + mensaje de wishlist [M]
- [ ] Diseñar la primera escena para comunicar sin sonido (autoplay silenciado) [M]
- [ ] Verificar que la música del trailer tiene licencia correcta (M41/M44) [M]
- [ ] Planificar subtítulos o texto en pantalla accesibles (M58) [S]
- [ ] Dejar predefinido el trailer secundario opcional (deep dive de sistemas) [S]
- [ ] Registrar el peso objetivo del archivo final (< 1 GB para reproducción fluida) [S]

## F. RF: Requisitos de sistema

- [ ] Definir SO mínimo: Windows 10 64-bit [S]
- [ ] Definir SO recomendado: Windows 11 64-bit [S]
- [ ] Definir CPU mínima: Intel i5 / AMD Ryzen 5 de 4-6 núcleos [S]
- [ ] Definir CPU recomendada: Intel i5 / AMD Ryzen 5 de 6+ núcleos recientes [S]
- [ ] Definir RAM mínima: 8 GB [S]
- [ ] Definir RAM recomendada: 16 GB [S]
- [ ] Definir GPU mínima: iGPU moderna o dedicada básica con DX11 [S]
- [ ] Definir GPU recomendada: GTX 1060 / RX 580 o superior [S]
- [ ] Definir espacio en disco base: 4 GB, ajustable al build final [S]
- [ ] Validar los valores con profiling real (M62/M90) sobre la máquina mínima [C]
- [ ] Documentar red no requerida (singleplayer por diseño) [S]
- [ ] Registrar decisión de plataformas Linux/macOS según M96 (omitir si no son objetivo) [S]

## G. RF: Precio y price point

- [ ] Investigar el price tier del género cozy indie (2024-2026) [M]
- [ ] Registrar el rango típico: $9.99 a $29.99 según alcance [S]
- [ ] Proponer $19.99 USD como precio sugerido (tier medio-alto cozy) [M]
- [ ] Proponer descuento de lanzamiento opcional del 10-15 % [S]
- [ ] Documentar que el precio final es decisión exclusiva del fundador [S]
- [ ] Dejar predefinido el uso de precios regionales automáticos de Steam [S]
- [ ] Verificar coherencia del precio con el contenido prometido (M38) [S]
- [ ] Asegurar que el precio se fija antes de las primeras campañas públicas [S]
- [ ] Descartar Early Access como modelo de lanzamiento (riesgo de reviews negativas en cozy) [M]

## H. RF: Keywords y metadatos

- [ ] Redactar la keyword list de Steamworks con el juego descrito en 8-12 palabras clave [M]
- [ ] Incluir keywords principales: cozy, calm, relax, island, voxel, farm, build, fish, mine [M]
- [ ] Incluir el nombre de la isla (Aurora) como keyword [S]
- [ ] Evitar duplicar los términos ya cubiertos por los 20 tags [M]
- [ ] Prohibir marcas de terceros y palabras engañosas en keywords [S]
- [ ] Registrar los idiomas marcados en Steamworks (ES/EN mínimo) [S]
- [ ] Verificar el número de campos de keywords vigente en Steamworks [S]
- [ ] Coordinar los metadatos con la investigación de otros juegos del repo [S]

## I. RF: Assets gráficos de la tienda

- [ ] Especificar header capsule 460x215 [S]
- [ ] Especificar small capsule 231x87 [S]
- [ ] Especificar main/large capsule 616x353 [S]
- [ ] Especificar vertical capsule 600x900 [S]
- [ ] Especificar library header 616x353 [S]
- [ ] Especificar library hero 3840x1240 con zona segura 1430x1240 [S]
- [ ] Especificar logo grande ~570x110 transparente [S]
- [ ] Especificar fondo de página ~1438x810 [S]
- [ ] Especificar icónos de aplicación 32 a 256 px [S]
- [ ] Definir el estilo visual: paleta cálida cozy y tipografía del juego (M88) [M]
- [ ] Garantizar legibilidad del logo a tamaño pequeño [S]
- [ ] Verificar todas las dimensiones contra la documentación vigente de Steamworks antes de exportar [S]
- [ ] Registrar la advertencia de que Steam puede actualizar estos requisitos [S]

## J. RN: Requisitos no funcionales

- [ ] RN1: planificar el primer pase de contenido en 2-4 semanas de trabajo delegado [M]
- [ ] RN1: confirmar que el módulo no afecta el frame budget (no es runtime) [S]
- [ ] RN2: mantener coherencia SEO entre título, short description, tags y keywords [M]
- [ ] RN3: garantizar honestidad total del material audiovisual (builds reales) [S]
- [ ] RN4: exigir calidad editorial nativa en español e inglés [M]
- [ ] RN5: versionar todos los textos en Markdown dentro del módulo [S]
- [ ] RN6: revalidar dimensiones, límites y formatos contra Steamworks al publicar [S]
- [ ] RN7: incluir subtítulos y evitar parpadeos en capturas/trailer (M58) [S]
- [ ] RN8: pasar la revisión legal de assets y nombres (M78) [S]
- [ ] RN9: no prometer multijugador ni futuros contenidos obligatorios en la página [S]

## K. Análisis del dominio

- [ ] Analizar el embudo de conversión de la store page (descubrimiento, escaneo, lectura, wishlist) [M]
- [ ] Analizar el peso de los tags en el descubrimiento de Steam (páginas de etiqueta) [M]
- [ ] Analizar la diferencia entre keywords (búsqueda interna) y SEO externo [M]
- [ ] Analizar el rol de la primera captura como miniatura principal [S]
- [ ] Analizar el autoplay de vídeo silenciado en la tienda [S]
- [ ] Analizar el valor estimado de cada wishlist para ventas del día 1 [M]
- [ ] Analizar los price tiers del género cozy con referencias de mercado [M]
- [ ] Evaluar la alternativa de publicación inmediata sin pulir (descartada) [S]
- [ ] Evaluar la alternativa de página oculta primero (adoptada) [M]
- [ ] Evaluar la alternativa de Early Access (descartada por el género) [S]
- [ ] Evaluar el uso de IA (M86) solo para borradores (adoptado) [S]
- [ ] Evaluar tercerizar la producción de medios (solo si decide el fundador) [S]
- [ ] Documentar los riesgos del módulo con mitigaciones (cambios de formato, capturas viejas, precio) [M]

## L. Diseño de la página

- [ ] Definir la arquitectura del módulo como paquete de contenido, no código de runtime [S]
- [ ] Diseñar la estructura de carpetas internas del plan-actual (plantillas de contenido) [S]
- [ ] Diseñar las 7 secciones del About con esquema título + párrafo + bullets [M]
- [ ] Diseñar la shot list de 8 capturas con escena, cámara y luz [M]
- [ ] Diseñar el guion del trailer en 3 actos con tomas y duración [M]
- [ ] Diseñar la tabla de requisitos mínimos/recomendados con fuente de verdad [S]
- [ ] Definir el roadmap de la página F0-F3 (oculta, coming soon, pre-lanzamiento, lanzamiento) [M]
- [ ] Definir los gates de entrada de cada fase del roadmap [M]
- [ ] Diseñar el CTA de wishlist en cada sección del About [S]
- [ ] Definir el mantenimiento continuo en cada milestone de M136 [M]
- [ ] Diseñar la plantilla de keywords sin duplicación de tags [S]
- [ ] Diseñar la plantilla de assets-store con rutas y estado de export [S]

## M. Integración con módulos del proyecto

- [ ] Referenciar M96 (Plataformas) para SO objetivos y Steam Deck [S]
- [ ] Referenciar M86 (IA Generativa) con política de revisión humana obligatoria [S]
- [ ] Referenciar M136 (Hoja de Ruta) para el hito de visibilidad (Coming Soon) [S]
- [ ] Referenciar M143 (Lanzamiento) para la ventana, build gold y fecha [S]
- [ ] Referenciar M29-M31 (tiempo, reloj, día/noche) en la promesa de ritmo propio [S]
- [ ] Referenciar M33-M35 (agricultura, pesca, minería) en la descripción [S]
- [ ] Referenciar M16-M18 (crafting, construcción, casas) en la descripción [S]
- [ ] Referenciar M19-M21 (NPC, amistad, diálogos) en la carpeta de isla viva [S]
- [ ] Referenciar M24-M27 (templos, ruinas, islas) en la sección de misterios [S]
- [ ] Referenciar M57 y M58 (controles, accesibilidad) en requisitos y categorías [S]
- [ ] Referenciar M62/M90 (rendimiento, gráficos) para validar requisitos de sistema [S]
- [ ] Referenciar M78 y M88 (legal, tipografías) para assets y textos [S]
- [ ] Documentar la autogestión del propio módulo 97 (plan-inicial/plan-actual espejados) [S]

## N. Edge cases

- [ ] Manejar el rechazo de contenido de Steam (captura o vídeo no aceptado): plan de corrección [M]
- [ ] Manejar categorías equivocadas: primer pase de tags a las 2 semanas [M]
- [ ] Manejar cambios de dimensiones de assets tras actualización de Steamworks [S]
- [ ] Manejar cambios de límites de caracteres o de cantidad de tags [S]
- [ ] Manejar la falta de nombre comercial definitivo: página retenida en F0 [M]
- [ ] Manejar la falta de decisión de precio: sin campañas públicas hasta decidir [S]
- [ ] Manejar capturas desactualizadas por cambios del juego: regrabar en cada milestone [S]
- [ ] Manejar el idioma de los subtítulos del trailer en versiones EN/ES [S]
- [ ] Manejar slots de vídeo ocupados por el primer trailer (2 máx. planificados) [S]
- [ ] Manejar reviews negativas por requisitos engañosos: validación con profiling previo [S]
- [ ] Manejar festivales de Steam que requieren el juego en Coming Soon con fecha [M]
- [ ] Manejar contenido de IA M86 en borradores: nunca publicar sin revisión [S]
- [ ] Manejar la ausencia de cuenta Steamworks: escalar a M143 antes de F0 [S]

## O. Documentación

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance, restricciones, RF y RN [M]
- [ ] Crear 02-Analisis.md con análisis del dominio, alternativas y decisiones [M]
- [ ] Crear 03-Diseno.md con estructura, shot list, requisitos, artwork y roadmap [M]
- [ ] Crear 04-Codigo.md con archivos previstos, plantillas y notas del agente [M]
- [ ] Crear 05-Checklist.md con mínimo 120 ítems verificables [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Esperar el espejo byte a byte de plan-actual [S]
- [ ] Registrar la advertencia de verificación contra Steamworks en los 5 archivos [S]

## P. Testings

- [ ] Probar la short description en ambos idiomas bajo el límite de caracteres [S]
- [ ] Verificar que los 20 tags existen en el catálogo real de Steam (búsqueda manual) [S]
- [ ] Verificar que ninguna captura contiene UI de desarrollo (revisión visual) [S]
- [ ] Validar el render 16:9 de cada captura antes de la subida [S]
- [ ] Probar el trailer en autoplay silenciado en la página de Steam (preview) [M]
- [ ] Verificar el peso y formato MP4 H.264 del trailer final [S]
- [ ] Cotejar los requisitos de sistema contra el profiling real (M62/M90) [C]
- [ ] Simular el flujo completo F0-F2 en un entorno de prueba de Steamworks [M]
- [ ] Revisar la página con acceso limitado (prensa) antes del coming soon público [S]
- [ ] Ejecutar el pase de tags post-lanzamiento y documentar resultados [M]
- [ ] Verificar que las dimensiones de assets coinciden con las docs vigentes [S]
- [ ] Confirmar que los textos finales tienen aprobación humana del fundador [S]