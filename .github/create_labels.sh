#!/bin/bash
# Script para crear labels de GitHub Issues para M102 Bug Tracking
# Ejecutar con: gh auth login && bash .github/create_labels.sh
# Requiere: GitHub CLI (gh) autenticado con permisos de repo

set -e

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Creando labels en repo: $REPO"

# Función helper
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    echo "  Creando: $name ($color)"
    gh label create "$name" --color "$color" --description "$description" --repo "$REPO" || echo "    (ya existe o error)"
}

echo "=== SEVERIDADES ==="
create_label "severity:critical" "d73a4a" "Bloquea release - Crash, data loss, feature principal rota"
create_label "severity:major" "ff7b72" "Bloquea milestone - Feature secundaria rota, workaround difícil"
create_label "severity:minor" "ffc74f" "No bloquea - Workaround fácil, comportamiento incorrecto menor"
create_label "severity:trivial" "6a737d" "Cosmético - Typo, alineación visual, sugerencia"

echo "=== PRIORIDADES ==="
create_label "priority:immediate" "d73a4a" "Hotfix en producción o bloquea a todo el equipo"
create_label "priority:high" "ff7b72" "Sprint actual, comprometido en milestone"
create_label "priority:medium" "ffc74f" "Backlog cercano, planificado para próximo sprint"
create_label "priority:low" "6a737d" "Eventual, nice-to-fix, technical debt"

echo "=== CATEGORÍAS ==="
create_label "category:gameplay" "1f6feb" "Movimiento, interacción, NPC, combate, progresión"
create_label "category:ui" "a371f7" "Menús, HUD, inventario, diálogos, controles, accesibilidad"
create_label "category:audio" "2ea043" "Música, SFX, volumen, mezcla, espacialización"
create_label "category:render" "1f6feb" "Gráficos, shaders, iluminación, voxel, colisiones, framerate"
create_label "category:networking" "8b5cf6" "Multiplayer, sincronización, latencia (M76/M77)"
create_label "category:assets" "f97583" "Modelos 3D, texturas, animaciones, faltantes o incorrectos"
create_label "category:build" "8b6e4e" "Errores compilación, instalador, plataformas específicas"
create_label "category:localization" "fb8500" "Traducciones, textos cortados, encoding"
create_label "category:performance" "fb8500" "FPS bajo, memoria, cargas lentas"
create_label "category:crash" "b60205" "Cuelgues, excepciones no manejadas"

echo "=== ESTADOS ==="
create_label "status:new" "0e8a16" "Issue creado, pendiente de triage"
create_label "status:in-progress" "fb8500" "Asignado a desarrollador, trabajo en curso"
create_label "status:verified" "0e8a16" "Fix implementado, awaiting QA verification"
create_label "status:closed" "6a737d" "Verificado y confirmado, versión de fix documentada"
create_label "status:wontfix" "6a737d" "No se corregirá (por diseño, costo, deprecated)"
create_label "status:duplicate" "6a737d" "Marcado como duplicado de otro issue"

echo "=== OTROS ==="
create_label "bug" "d73a4a" "Tipo: reporte de bug"
create_label "needs-info" "ffc74f" "Issue incompleto, requiere más información del reporter"

echo ""
echo "✅ Labels creados. Verificar en: https://github.com/$REPO/labels"