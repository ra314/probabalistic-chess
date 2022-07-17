extends TextureButton
class_name Tile

var grid_pos: Vector2
const size := Vector2(64,64)
var color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(grid_pos) -> void:
	self.grid_pos = grid_pos
	rect_position = size*grid_pos

# Dynamically create a texture
func create_tex(color: Color, size: Vector2) -> ImageTexture:
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	dynImage.create(size.x,size.y,false,Image.FORMAT_RGB8)
	dynImage.fill(color)
	imageTexture.create_from_image(dynImage)
	return imageTexture

func set_color(color: Color) -> void:
	texture_normal = create_tex(color, size)

func select():
	$Selected.visible = true
func deselect():
	$Selected.visible = false
func highlight_movement():
	$"Possible Move".visible = true
func dehighlight_movement():
	$"Possible Move".visible = false
