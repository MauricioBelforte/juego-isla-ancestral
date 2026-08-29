@tool
extends EditorScript
class_name CodeQualityCheck

## M111 - Código de Calidad: Herramienta de análisis estático
## Analiza scripts GDScript para detectar violaciones de estilo y calidad

@export_group("Configuración de Análisis")

@export var max_method_lines: int = 50
@export var max_class_lines: int = 300
@export var max_file_lines: int = 500
@export var max_cyclomatic_complexity: int = 10
@export var max_nesting_depth: int = 4

@export_group("Directorios a Analizar")
@export var scan_directories: Array[String] = [
	"res://scripts/",
]

@export_group("Salida")
@export var output_to_console: bool = true
@export var output_to_file: bool = true
@export var report_file_path: String = "user://code_quality_report.txt"

## Resultados del análisis
var _results: Dictionary = {}
var _total_violations: int = 0
var _files_scanned: int = 0

func _run() -> void:
	print("=== M111 CodeQualityCheck: Iniciando análisis estático ===")
	_results = {}
	_total_violations = 0
	_files_scanned = 0

	for dir_path in scan_directories:
		_scan_directory(dir_path)

	_generate_report()
	print("=== Análisis completado ===")

func _scan_directory(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("No se pudo abrir directorio: %s" % dir_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var full_path = ""
	while file_name != "":
		if not dir.current_is_dir():
			full_path = dir_path.path_join(file_name)
			if full_path.ends_with(".gd"):
				_scan_file(full_path)
		else:
			if file_name != "." and file_name != "..":
				_scan_directory(full_path)
		file_name = dir.get_next()

func _scan_file(file_path: String) -> void:
	_files_scanned += 1
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("No se pudo leer: %s" % file_path)
		return

	var content = file.get_as_text()
	file.close()

	var lines = content.split("\n")
	var violations: Array[Dictionary] = []

	# Verificar límite de líneas de archivo
	if lines.size() > max_file_lines:
		violations.append({
			"type": "file_too_long",
			"message": "Archivo excede %d líneas (tiene %d)" % [max_file_lines, lines.size()],
			"line": 1,
			"severity": "warning"
		})

	# Analizar estructura: clases, métodos, complejidad
	_analyze_structure(file_path, content, lines, violations)

	# Verificar convenciones de nomenclatura
	_check_naming_conventions(file_path, content, lines, violations)

	# Verificar documentación
	_check_documentation(file_path, content, lines, violations)

	if violations.size() > 0:
		_results[file_path] = violations
		_total_violations += violations.size()

func _analyze_structure(file_path: String, content: String, lines: Array[String], violations: Array[Dictionary]) -> void:
	var in_class = false
	var class_nombre = ""
	var class_start_line = 0
	var class_line_count = 0
	var brace_depth = 0
	var current_method = ""
	var method_start_line = 0
	var method_line_count = 0
	var method_complexity = 1
	var method_nesting = 0
	var max_method_nesting = 0

	for i in range(lines.size()):
		var line = lines[i]
		var line_num = i + 1
		var trimmed = line.strip_edges()

		# Detectar definición de clase
		if trimmed.begins_with("class ") or trimmed.begins_with("class_name "):
			if in_class:
				# Verificar longitud de clase anterior
				if class_line_count > max_class_lines:
					violations.append({
						"type": "class_too_long",
						"message": "Clase '%s' excede %d líneas (tiene %d)" % [class_nombre, max_class_lines, class_line_count],
						"line": class_start_line,
						"severity": "warning"
					})

			in_class = true
			class_start_line = line_num
			class_line_count = 0
			if trimmed.begins_with("class "):
				class_nombre = trimmed.split(" ")[1].split("(")[0].split(":")[0].strip_edges()
			else:
				# class_name - el nombre está en la siguiente línea o es el archivo
				class_nombre = file_path.get_file().get_basename().replace(".gd", "")

		if in_class:
			class_line_count += 1

		# Detectar definición de método (func)
		var func_match = RegEx.new()
		func_match.compile("^\\s*func\\s+(\\w+)\\s*\\(")
		var match = func_match.search(line)
		if match:
			# Verificar método anterior
			if current_method != "":
				_check_method_violations(current_method, method_start_line, method_line_count, method_complexity, max_method_nesting, violations)

			current_method = match.get_string(1)
			method_start_line = line_num
			method_line_count = 0
			method_complexity = 1
			method_nesting = 0
			max_method_nesting = 0

		if current_method != "":
			method_line_count += 1

			# Contar complejidad ciclomática (palabras clave de control de flujo)
			if _is_flow_control(line):
				method_complexity += 1

			# Contar anidamiento
			var open_braces = line.count("{")
			var close_braces = line.count("}")
			method_nesting += open_braces - close_braces
			if method_nesting > max_method_nesting:
				max_method_nesting = method_nesting

			# Detectar fin de método (próximo func, class, o fin de clase)
			var next_is_method_end = false
			if i + 1 < lines.size():
				var next_line = lines[i + 1].strip_edges()
				if next_line.begins_with("func ") or next_line.begins_with("class ") or next_line.begins_with("class_name "):
					next_is_method_end = true

			# También terminar si el brace depth vuelve a 0 en la clase
			brace_depth += open_braces - close_braces
			if brace_depth <= 0 and in_class:
				next_is_method_end = true

			if next_is_method_end:
				_check_method_violations(current_method, method_start_line, method_line_count, method_complexity, max_method_nesting, violations)
				current_method = ""
				brace_depth = 0

	# Verificar última clase
	if in_class and class_line_count > max_class_lines:
		violations.append({
			"type": "class_too_long",
			"message": "Clase '%s' excede %d líneas (tiene %d)" % [class_nombre, max_class_lines, class_line_count],
			"line": class_start_line,
			"severity": "warning"
		})

func _check_method_violations(method_name: String, start_line: int, line_count: int, complexity: int, nesting: int, violations: Array[Dictionary]) -> void:
	if line_count > max_method_lines:
		violations.append({
			"type": "method_too_long",
			"message": "Método '%s' excede %d líneas (tiene %d)" % [method_name, max_method_lines, line_count],
			"line": start_line,
			"severity": "warning"
		})

	if complexity > max_cyclomatic_complexity:
		violations.append({
			"type": "high_complexity",
			"message": "Método '%s' tiene complejidad ciclomática %d (máx %d)" % [method_name, complexity, max_cyclomatic_complexity],
			"line": start_line,
			"severity": "warning"
		})

	if nesting > max_nesting_depth:
		violations.append({
			"type": "deep_nesting",
			"message": "Método '%s' tiene anidamiento nivel %d (máx %d)" % [method_name, nesting, max_nesting_depth],
			"line": start_line,
			"severity": "warning"
		})

func _is_flow_control(line: String) -> bool:
	var trimmed = line.strip_edges()
	var keywords = ["if ", "elif ", "else:", "for ", "while ", "match ", "case ", "try:", "except:", "when "]
	for kw in keywords:
		if trimmed.begins_with(kw) or " " + kw in trimmed:
			return true
	return false

func _check_naming_conventions(file_path: String, content: String, lines: Array[String], violations: Array[Dictionary]) -> void:
	var class_name_regex = RegEx.new()
	class_name_regex.compile("^\\s*class\\s+(\\w+)")
	var class_name_match = ""

	# Obtener nombre de clase esperado (PascalCase desde nombre de archivo)
	var expected_class = file_path.get_file().get_basename().replace(".gd", "")
	var expected_class_pascal = _to_pascal_case(expected_class)

	for i in range(lines.size()):
		var line = lines[i]
		var line_num = i + 1
		var trimmed = line.strip_edges()

		# Verificar class_name
		if trimmed.begins_with("class_name "):
			var name = trimmed.split(" ")[1].split("(")[0].strip_edges()
			if not _is_pascal_case(name):
				violations.append({
					"type": "naming_convention",
					"message": "class_name '%s' debe ser PascalCase" % name,
					"line": line_num,
					"severity": "error"
				})

		# Verificar class definition
		var match = class_name_regex.search(line)
		if match:
			class_name_match = match.get_string(1)
			if not _is_pascal_case(class_name_match):
				violations.append({
					"type": "naming_convention",
					"message": "Clase '%s' debe ser PascalCase" % class_name_match,
					"line": line_num,
					"severity": "error"
				})

		# Verificar señales (snake_case)
		if trimmed.begins_with("signal "):
			var signal_name = trimmed.split(" ")[1].split("(")[0].strip_edges()
			if not _is_snake_case(signal_name):
				violations.append({
					"type": "naming_convention",
					"message": "Señal '%s' debe ser snake_case" % signal_name,
					"line": line_num,
					"severity": "error"
				})

		# Verificar constantes (UPPER_CASE)
		if trimmed.begins_with("const "):
			var const_part = trimmed.substr(6).strip_edges()
			var const_name = const_part.split("=")[0].strip_edges()
			if not _is_upper_case(const_name):
				violations.append({
					"type": "naming_convention",
					"message": "Constante '%s' debe ser UPPER_SNAKE_CASE" % const_name,
					"line": line_num,
					"severity": "error"
				})

		# Verificar enums (PascalCase para el nombre, UPPER_CASE para valores)
		if trimmed.begins_with("enum "):
			var enum_name = trimmed.substr(5).split("{")[0].strip_edges()
			if enum_name != "" and not _is_pascal_case(enum_name):
				violations.append({
					"type": "naming_convention",
					"message": "Enum '%s' debe ser PascalCase" % enum_name,
					"line": line_num,
					"severity": "error"
				})

		# Verificar @export variables (snake_case)
		if trimmed.begins_with("@export"):
			# Buscar la variable en la siguiente línea o misma línea
			var var_line = trimmed
			if not " " in var_line.replace("@export", "").strip_edges():
				if i + 1 < lines.size():
					var_line = lines[i + 1].strip_edges()
			var var_match = RegEx.new()
			var_match.compile("@export.*?\\b(var|let)\\s+(\\w+)")
			var var_result = var_match.search(var_line)
			if var_result:
				var var_name = var_result.get_string(2)
				if not _is_snake_case(var_name) and not _is_upper_case(var_name):
					violations.append({
						"type": "naming_convention",
						"message": "Variable export '%s' debe ser snake_case" % var_name,
						"line": line_num,
						"severity": "warning"
					})

		# Verificar funciones (snake_case)
		if trimmed.begins_with("func "):
			var func_name = trimmed.substr(5).split("(")[0].strip_edges()
			if func_name != "_init" and func_name != "_ready" and func_name != "_process" and func_name != "_physics_process" and func_name != "_input" and not func_name.begins_with("_"):
				if not _is_snake_case(func_name):
					violations.append({
						"type": "naming_convention",
						"message": "Función '%s' debe ser snake_case" % func_name,
						"line": line_num,
						"severity": "error"
					})

func _check_documentation(file_path: String, content: String, lines: Array[String], violations: Array[Dictionary]) -> void:
	var in_class = false
	var class_has_doc = false
	var last_doc_line = -1

	for i in range(lines.size()):
		var line = lines[i]
		var line_num = i + 1
		var trimmed = line.strip_edges()

		# Detectar comentarios de documentación (## o ///)
		if trimmed.begins_with("## ") or trimmed.begins_with("/// "):
			last_doc_line = line_num

		# Detectar clase
		if trimmed.begins_with("class ") or trimmed.begins_with("class_name "):
			if in_class and not class_has_doc:
				violations.append({
					"type": "missing_documentation",
					"message": "Clase pública sin documentación",
					"line": line_num - 1,
					"severity": "info"
				})
			in_class = true
			class_has_doc = (last_doc_line == line_num - 1 or last_doc_line == line_num - 2)

		# Detectar funciones públicas (no privadas _)
		if trimmed.begins_with("func ") and not trimmed.begins_with("func _"):
			var func_name = trimmed.substr(5).split("(")[0].strip_edges()
			# Verificar si tiene docstring justo antes
			var has_doc = false
			if i > 0:
				var prev = lines[i - 1].strip_edges()
				if prev.begins_with("## ") or prev.begins_with("/// "):
					has_doc = true
			if not has_doc and func_name != "_init" and func_name != "_ready":
				violations.append({
					"type": "missing_documentation",
					"message": "Función pública '%s' sin documentación" % func_name,
					"line": line_num,
					"severity": "info"
				})

func _to_pascal_case(snake: String) -> String:
	var parts = snake.split("_")
	var result = ""
	for part in parts:
		if part.length() > 0:
			result += part[0].to_upper() + part.substr(1).to_lower()
	return result

func _is_pascal_case(s: String) -> bool:
	if s.length() == 0:
		return false
	if not (s[0].to_upper() == s[0] and s[0].to_lower() != s[0]):
		return false
	for i in range(1, s.length()):
		if s[i] == "_":
			return false
	return true

func _is_snake_case(s: String) -> bool:
	if s.length() == 0:
		return false
	if s[0] == "_" or s[-1] == "_":
		return false
	for i in range(s.length()):
		var c = s[i]
		if not (c.is_lower() or c.is_digit() or c == "_"):
			return false
	return true

func _is_upper_case(s: String) -> bool:
	if s.length() == 0:
		return false
	for i in range(s.length()):
		var c = s[i]
		if not ((c.to_upper() == c and c.to_lower() != c) or c.is_digit() or c == "_"):
			return false
	return true

func _generate_report() -> void:
	var report = "=== M111 Code Quality Report ===\n"
	report += "Fecha: %s\n" % Time.get_datetime_string_from_system()
	report += "Archivos escaneados: %d\n" % _files_scanned
	report += "Violaciones totales: %d\n\n" % _total_violations

	var by_type: Dictionary = {}
	var by_severity: Dictionary = {"error": 0, "warning": 0, "info": 0}

	for file_path in _results:
		var violations = _results[file_path]
		report += "--- %s ---\n" % file_path
		for v in violations:
			report += "  [%s] L%d: %s\n" % [v.severity.to_upper(), v.line, v.message]
			by_type[v.type] = by_type.get(v.type, 0) + 1
			by_severity[v.severity] = by_severity.get(v.severity, 0) + 1
		report += "\n"
	report += "=== Resumen por tipo ===\n"
	for type_name in by_type:
		var count = by_type[type_name]
		report += "  %s: %d\n" % [type_name, count]

	report += "\n=== Resumen por severidad ===\n"
	for sev in by_severity:
		var count = by_severity[sev]
		report += "  %s: %d\n" % [sev.to_upper(), count]

	if output_to_console:
		print(report)

	if output_to_file:
		var file = FileAccess.open(report_file_path, FileAccess.WRITE)
		if file:
			file.store_string(report)
			file.close()
			print("Reporte guardado en: %s" % report_file_path)
		else:
			push_error("No se pudo guardar reporte en: %s" % report_file_path)