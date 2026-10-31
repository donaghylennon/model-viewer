package main

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"

App :: struct {
	window: Window,
	camera: Camera,
}

main :: proc() {
	if len(os.args) > 2 || len(os.args) < 2 {
		fmt.eprintfln("Usage: %v %v", os.args[0], "<path to OBJ file>")
		os.exit(1)
	}
	model_filepath := os.args[1]
	if !os.exists(model_filepath) {
		fmt.eprintfln("File not found: %v", model_filepath)
		os.exit(1)
	}
	if !strings.ends_with(model_filepath, ".obj") && !strings.ends_with(model_filepath, ".OBJ") {
		fmt.eprintfln("Provided file is not an OBJ file")
		os.exit(1)
	}
	app := App{}

	app.window = create_window()

	app.camera = Camera {
		position  = glsl.vec3{0, 0, 3},
		front     = glsl.vec3{0, 0, -1},
		up        = glsl.vec3{0, 1, 0},
		yaw       = -90,
		pitch     = 0,
		fov       = 45,
		target    = glsl.vec3{0, 0, 0},
		tDistance = 3,
	}

	glfw.SetWindowUserPointer(app.window.handle, cast(rawptr)&app)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, SCR_WIDTH, SCR_HEIGHT)
	gl.Enable(gl.DEPTH_TEST)

	model, ok := load_model(model_filepath)
	if !ok {
		fmt.eprintfln("Error parsing provided OBJ file")
		os.exit(1)
	}
	mesh := create_mesh(model)
	delete_model(model)
	init_mesh(&mesh)
	defer delete_mesh(&mesh)

	app.camera.tDistance = 1.5 * get_aabb_diagonal_length(&mesh)


	for !glfw.WindowShouldClose(app.window.handle) {
		currentFrame := f32(glfw.GetTime())
		app.window.deltaTime = currentFrame - app.window.lastFrame
		app.window.lastFrame = currentFrame

		processInput(app.window.handle, &app)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		draw_mesh(&mesh, &app.camera)

		glfw.SwapBuffers(app.window.handle)
		glfw.PollEvents()
	}

	glfw.Terminate()
}
