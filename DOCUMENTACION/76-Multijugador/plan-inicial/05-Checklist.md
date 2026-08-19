**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 76: Multijugador (130 ítems)

## A. Decisión de Producto (RF1)

- [x] Decidir si habrá multijugador (v1: NO, single-player cozy) [M]
- [x] Documentar la decisión con argumentos de género (AC/Stardew/CozyGrove) [M]
- [x] Documentar la decisión con argumentos de coste [M]
- [x] Verificar que el postgame (M75) cubre la vida de la isla sin red [M]
- [x] Registrar la decisión en el manifiesto mp_contract.json [S]

## B. Modo Local (RF2)

- [x] Definir el modo local como primera forma de MP [M]
- [x] Definir 2 jugadores en el mismo dispositivo [S]
- [x] Definir split-screen como presentación local [M]
- [x] Definir host autoritativo para el modo local [M]
- [x] Definir frame budget 60 FPS antes de aprobar la feature (M61) [C]

## C. Modo Online (RF3)

- [x] Diferir el online como extensión futura [S]
- [x] Condicionar el online a hit de métricas (>10k descargas) [M]
- [x] Exigir M77 (Online y Red) antes de cualquier online [S]
- [x] Definir máximo de 4 jugadores online [S]
- [x] Documentar presupuesto estimado de servidores [M]

## D. Cantidad de Jugadores (RF4)

- [x] Definir 1 jugador en v1 (single) [S]
- [x] Definir 2 jugadores para el modo local [S]
- [x] Definir 4 jugadores máximo para online futuro [S]
- [x] Documentar el impacto de rendimiento por jugador extra [M]
- [x] Verificar que la cantidad no rompe el cozy (sin multitudes) [S]

## E. Anfitrión (RF5)

- [x] Definir el anfitrión = jugador que crea la isla [S]
- [x] Definir que el anfitrión posee el mundo [S]
- [x] Definir invitado sin poder de host [S]
- [x] Documentar migración de host (si se cierra sesión) [M]
- [x] Registrar la autoridad en el manifiesto [S]

## F. Servidor (RF6)

- [x] Definir P2P/split para el modo local (sin servidor) [S]
- [x] Definir servidor dedicado SOLO para online futuro [M]
- [x] Documentar $0 de servidores en v1 [S]
- [x] Documentar la estimación mensual de servidor dedicado [M]
- [x] Registrar servidores_v1=false en el manifiesto [S]

## G. Sincronización (RF7)

- [x] Definir host autoritativo (simula mundo, recibe inputs) [M]
- [x] Definir snapshot+reconciliación para online (M77) [M]
- [x] Definir tick rate de referencia (10-20 Hz estado) [M]
- [x] Documentar interpolar animaciones del invitado (M13) [M]
- [x] Verificar determinismo local (split no red) [M]

## H. Autoridad (RF8)

- [x] Definir autoridad del host en el mundo [S]
- [x] Definir autoridad del invitado sobre su avatar [S]
- [x] Definir autoridad del servidor para online (M77) [M]
- [x] Documentar regla: el invitado no desbloquea logros en la isla ajena (M72) [M]
- [x] Registrar authority=host en el manifiesto [S]

## I. Persistencia (RF9)

- [x] Definir save individual sin cambio de formato (M59) [M]
- [x] Definir invitado = perfil local (M92) [M]
- [x] Definir que el invitado NO persiste en la isla del host [S]
- [x] Documentar cero conflictos de escritura de saves [S]
- [x] Verificar migración M60 intacta [S]

## J. Permisos (RF10)

- [x] Definir invitado sin zona destructiva [S]
- [x] Definir edición permitida en zona asignada [M]
- [x] Definir casa del host protegida [S]
- [x] Documentar permisos por diseño (anti-griefing) [S]
- [x] Verificar permisos en el manifiesto [S]

## K. Invitaciones (RF11)

- [x] Definir invitación local = segundo mando [S]
- [x] Definir código de visita con expiración (online futuro) [M]
- [x] Definir lista de amigos futura (M77) [M]
- [x] Documentar flujo de invitación sin cuentas en v1 [S]
- [x] Verificar que la invitación nunca expone datos [S]

## L. Cuentas (RF12)

- [x] Definir sin cuentas en v1 [S]
- [x] Definir perfiles locales (M92) [S]
- [x] Definir cuenta opcional SOLO para online futuro [M]
- [x] Documentar el servicio de cuenta como externo (M77) [M]
- [x] Verificar privacidad del perfil local [S]

## M. Identidad (RF13)

- [x] Definir avatar de perfil (M92) [S]
- [x] Definir nombre de isla único en visitas [M]
- [x] Definir nombre de jugador editable [S]
- [x] Documentar identidad sin cuentas (local) [S]
- [x] Verificar identidad en el manifiesto [S]

## N. Chat (RF14)

- [x] Definir sin chat en v1 [S]
- [x] Definir frases rápidas (T-chat moderado) [M]
- [x] Definir sin texto libre en el cozy [S]
- [x] Definir sistema de reporte si hay texto libre futuro [M]
- [x] Registrar chat=frases rapidas en el manifiesto [S]

## O. Emotes (RF15)

- [x] Definir rueda de emotes [S]
- [x] Definir emotes como notificaciones express (M44) [M]
- [x] Definir set base de emotes (hola, gracias, risa, enojo) [S]
- [x] Documentar animaciones de emotes (M13) [M]
- [x] Verificar que los emotes no requieren red en local [S]

## P. Intercambio (RF16)

- [x] Definir sin intercambio en v1 [S]
- [x] Definir trueque futuro solo decorativo (M38) [M]
- [x] Prohibir transferencia de ítems de historia (M22/M23) [S]
- [x] Prohibir transferencia de colecciones de avance (M73) [S]
- [x] Verificar economía protegida en el manifiesto [S]

## Q. Construcción Cooperativa (RF17)

- [x] Definir construcción cooperativa futura solo en zona permitida [M]
- [x] Definir catálogo de muebles compartido de solo lectura [M]
- [x] Definir undo/redo del invitado para evitar errores [M]
- [x] Documentar sin tocar el sistema de construcción single (M15) [S]
- [x] Verificar permisos de construcción en el manifiesto [S]

## R. Puzzles Cooperativos (RF18)

- [x] Definir puzzles cooperativos SOLO opcionales (M24) [S]
- [x] Prohibir puzzles que bloqueen historia (M22) [S]
- [x] Definir solución compartida sin estado duplicado [M]
- [x] Documentar puzzles con 1 solución (sin puzles rotos) [S]
- [x] Verificar que el invitado no recibe logros de progreso (M72) [S]

## S. Progreso Compartido (RF19)

- [x] Definir progreso NUNCA compartido [S]
- [x] Documentar cada jugador con su isla [S]
- [x] Verificar que el invitado no avanza la historia ajena (M22) [S]
- [x] Documentar que los eventos (M74) se viven juntos pero cuentan individual [M]
- [x] Registrar progreso individual en el manifiesto [S]

## T. Progreso Individual (RF20)

- [x] Definir invitado con su avatar y progreso global [M]
- [x] Definir perfil local del invitado (M92) [M]
- [x] Documentar colecciones (M73) individuales [S]
- [x] Documentar economía (M38) individual [S]
- [x] Verificar sin contaminación de saves [S]

## U. Seguridad (RF21)

- [x] Definir offline-first (M59) [S]
- [x] Definir código de visita con expiración [M]
- [x] Definir sin exposición de datos locales [M]
- [x] Documentar cifrado de transporte futuro (M77) [M]
- [x] Verificar que v1 no abre puertos de red [S]

## V. Anti-Griefing (RF22)

- [x] Definir anti-griefing por diseño (permisos) [S]
- [x] Definir invitado sin herramientas destructivas [S]
- [x] Definir respaldo del mundo del host (M59) ante incidentes [M]
- [x] Documentar rollback de cambios del invitado [M]
- [x] Registrar permisos en el manifiesto [S]

## W. Moderación (RF23)

- [x] Definir moderación por frases rápidas (sin texto libre) [S]
- [x] Definir reporte de jugadores si hay texto futuro [M]
- [x] Definir baneo de visitas para el host [M]
- [x] Documentar política de privacidad de cuentas futuras (M77) [M]
- [x] Verificar cero moderación en v1 (no hay red) [S]

## X. Costes de Servidores (RF24)

- [x] Documentar $0 de servidores en v1 [S]
- [x] Estimar servidor 8 vCPU/16 GB para ~200 CCU [M]
- [x] Estimar $120-180/mes por servidor dedicado [M]
- [x] Condicionar el online al hit de métricas (>10k descargas) [M]
- [x] Registrar coste_estimado_mensual=0 en el manifiesto [S]

## Y. Cierre del Contrato (RF25)

- [x] Definir los 25 puntos del plan maestro como contrato [M]
- [x] Documentar el flujo de apertura de FASE LOCAL [M]
- [x] Documentar el flujo de apertura de FASE ONLINE (M77) [M]
- [x] Entregar validate_mp_contract.gd (grep + manifiesto) [M]
- [x] Entregar mp_contract.json [S]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]