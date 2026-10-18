# Sonda temporal (evidencia T59): semantica de liberar_envejecidos() con
# recurso real + unreference() sin reference() previo (stream_manager.gd L350).
extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _mk() -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 0, 0, 1))
	return ImageTexture.create_from_image(img)


func _run() -> void:
	var sm := root.get_node_or_null("StreamManager")
	var mm := root.get_node_or_null("MemoryMonitor")
	print("P0 sm=", sm != null, " mm=", mm != null)
	var t0 := _mk()
	var w0: WeakRef = weakref(t0)
	t0 = null
	print("P0 weak null al soltar unica ref: ", w0.get_ref() == null)

	print("P1 inicio: LRU con recurso, RETENIENDO ref durante liberar")
	var t1 := _mk()
	var w1: WeakRef = weakref(t1)
	sm.registrar_chunk("probe_p1", 50.0, t1)
	sm.marcar_envejecidos(10.0)
	sm.marcar_envejecidos(10.0)
	var lib1: int = sm.liberar_envejecidos()
	print("P1 liberados=", lib1, " weak_viva=", w1.get_ref() != null,
		" valid=", is_instance_valid(t1))
	t1 = null
	print("P1 solte ref tras liberar; weak_viva=", w1.get_ref() != null)
	print("P1 FIN")

	print("P2 inicio: LRU con recurso, soltando ref ANTES de liberar")
	var t2 := _mk()
	var w2: WeakRef = weakref(t2)
	sm.registrar_chunk("probe_p2", 50.0, t2)
	t2 = null
	print("P2 solte ref antes; weak_viva=", w2.get_ref() != null)
	sm.marcar_envejecidos(10.0)
	sm.marcar_envejecidos(10.0)
	var lib2: int = sm.liberar_envejecidos()
	print("P2 liberados=", lib2, " weak_viva=", w2.get_ref() != null)
	print("P2 FIN")

	print("P3 inicio: cola M62 pura (sin LRU)")
	var t3 := _mk()
	var w3: WeakRef = weakref(t3)
	mm.registrar_candidato_descarga(t3, 1, 0.0)
	t3 = null
	print("P3 weak_viva tras cola: ", w3.get_ref() != null)
	var lib3: int = mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	print("P3 liberados=", lib3, " weak_viva tras descarga: ", w3.get_ref() != null)
	print("P3 FIN")

	print("PROBE FIN OK")
	quit(0)
