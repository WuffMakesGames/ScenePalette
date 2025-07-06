class_name ScenePalettePreviewGenerator extends Node

static func generate_preview(node: Node, scene: PackedScene, preview_size: Vector2) -> Texture2D:
	var instance: Node = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	var viewport = SubViewport.new()
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.transparent_bg = true
	viewport.size = preview_size
	viewport.add_child(instance)
	node.add_child(viewport)
	
	if instance is Node2D or Control:
		var visible_rect = get_node2d_visible_rect(instance)
		var visible_center = visible_rect.position + visible_rect.size / 2
		instance.scale = (preview_size/visible_rect.size)
		instance.scale = instance.scale.min(Vector2(instance.scale.y, instance.scale.x))
		instance.position = preview_size / 2 - visible_center * instance.scale
		instance.queue_redraw()
		
	viewport.debug_draw = true
	return viewport.get_texture()

static func get_node2d_visible_rect(node: Node, rect: Rect2 = Rect2()) -> Rect2:
	if node.is_class("CollisionShape2D"): node.hide()
	if node.get("visible") and node.visible and node.has_method("get_rect"):
		rect = node.get_rect()
		rect.position *= node.scale
		rect.size *= node.scale
		rect.position += node.position
	for child in node.get_children():
		if child is Node2D or Control:
			rect = rect.merge(get_node2d_visible_rect(child, rect))
	return rect
