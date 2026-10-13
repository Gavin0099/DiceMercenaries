extends SceneTree

# DM-00 only: verify the actual shipped entry scene; no gameplay logic.
func _initialize() -> void:
    var path: String = ProjectSettings.get_setting("application/run/main_scene", "")
    if path != "res://scenes/ui/bootstrap.tscn":
        _fail("Unexpected main scene: " + path)
        return
    var packed: PackedScene = load(path) as PackedScene
    if packed == null:
        _fail("Main scene cannot load")
        return
    var instance: Node = packed.instantiate()
    if not instance is Control:
        instance.free()
        _fail("Root must be Control")
        return
    if instance.get_meta("slice", "") != "DM-00":
        instance.free()
        _fail("Scene must identify its slice")
        return
    var status: Label = instance.get_node_or_null("Status") as Label
    if status == null or not status.text.contains("DM-00"):
        instance.free()
        _fail("Missing visible skeleton status")
        return
    root.add_child(instance)
    await process_frame
    instance.queue_free()
    print("DM00_BOOTSTRAP_PASS")
    quit(0)

func _fail(message: String) -> void:
    printerr("DM00_BOOTSTRAP_FAIL: " + message)
    quit(1)
