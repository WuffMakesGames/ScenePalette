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
	if node.get("visible"):
		if node.is_class("CollisionShape2D"): node.hide()
		elif node.is_class("TileMapLayer"):
			var used_rect: Rect2 = node.get_used_rect()
			var tile_size: Vector2 = node.tile_set.tile_size
			rect.position = used_rect.position * tile_size
			rect.end = used_rect.end * tile_size
		elif node.has_method("get_rect"):
			rect = node.get_rect()
			rect.position *= node.scale
			rect.position += node.position
			rect.size *= node.scale
		for child in node.get_children():
			if child is Node2D or Control:
				rect = rect.merge(get_node2d_visible_rect(child, rect))
	return rect
