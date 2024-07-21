extends Node

@export var theTexture : Texture2D
var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
var rd : RenderingDevice
var shader : RID
var buffer : RID
var secondBuffer : RID

var pipeline : RID

var uniform_set : RID

var bindings : Array[RDUniform]

@onready var ColorPicker1 : ColorPickerButton = $ColorPickerButton
@onready var ColorPicker2 : ColorPickerButton = $ColorPickerButton2

@onready var textureInputPreview : TextureRect = $TexturePanel2/TextureRect3
@onready var textureOutputPreview : TextureRect = $TexturePanel/TextureRect3

@onready var spinBoxInput : SpinBox = $SpinBox

func _ready()->void:
	textureInputPreview.texture = theTexture
	
	_setupCompute()
	
	_updateCompute()

func _setupCompute()->void:
	rd = RenderingServer.create_local_rendering_device()
	
	var shaderFile : RDShaderFile = load("res://Scenes/OutOfProgramDebug/computeShaderTest.glsl")
	var shaderSpirv : RDShaderSPIRV = shaderFile.get_spirv()
	shader= rd.shader_create_from_spirv(shaderSpirv)
	
	var input_multiply_array : PackedFloat32Array = [spinBoxInput.value]
	
	var input_mult_bytes := input_multiply_array.to_byte_array()
	var input_bytes := input.to_byte_array()
	
	buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	secondBuffer = rd.storage_buffer_create(input_mult_bytes.size(),input_mult_bytes)
	
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	
	var secondUnif := RDUniform.new()
	secondUnif.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	secondUnif.binding = 1
	secondUnif.add_id(secondBuffer)
	
	bindings = [uniform,secondUnif]
	
	uniform_set = rd.uniform_set_create(bindings, shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	
	# Create a compute pipeline
	pipeline = rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	
	rd.submit()
	
	rd.sync()

func _updateCompute()->void:
	# Read back the data from the buffer
	var input_multiply_array : PackedFloat32Array = [spinBoxInput.value]
	
	var input_mult_bytes := input_multiply_array.to_byte_array()
	var input_bytes := input.to_byte_array()
	
	buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	secondBuffer = rd.storage_buffer_create(input_mult_bytes.size(),input_mult_bytes)
	
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	
	var secondUnif := RDUniform.new()
	secondUnif.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	secondUnif.binding = 1
	secondUnif.add_id(secondBuffer)
	
	bindings[0] = uniform
	bindings[1] = secondUnif
	
	uniform_set = rd.uniform_set_create(bindings, shader, 0)
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	
	rd.submit()
	
	rd.sync()
	
	var output_bytes := rd.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)

func _process(_delta : float)->void:
	pass
