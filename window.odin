package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

Window :: struct {
	width:      int,
	height:     int,
	firstMouse: bool,
	lastX:      f32,
	lastY:      f32,
	deltaTime:  f32,
	lastFrame:  f32,
	handle:     glfw.WindowHandle,
}

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
}

processInput :: proc "c" (window: glfw.WindowHandle, app: ^App) {
	camera := &app.camera
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}

	move_camera_targeted(app.window, camera)
}

move_camera_targeted :: proc "c" (window: Window, camera: ^Camera) {
	cameraSpeed := f32(window.deltaTime * 2.5)
	yawRad := glsl.radians(camera.yaw)
	pitchRad := glsl.radians(camera.pitch)
	offset: glsl.vec3
	offset.x = camera.tDistance * math.cos(pitchRad) * math.sin(yawRad)
	offset.y = camera.tDistance * math.sin(pitchRad)
	offset.z = camera.tDistance * math.cos(pitchRad) * math.cos(yawRad)

	camera.position = camera.target + offset
}

move_camera_free :: proc "c" (window: Window, camera: ^Camera) {
	cameraSpeed := f32(window.deltaTime * 2.5)
	if glfw.GetKey(window.handle, glfw.KEY_W) == glfw.PRESS {
		camera.position += cameraSpeed * camera.front
	}
	if glfw.GetKey(window.handle, glfw.KEY_S) == glfw.PRESS {
		camera.position -= cameraSpeed * camera.front
	}
	if glfw.GetKey(window.handle, glfw.KEY_A) == glfw.PRESS {
		camera.position -= glsl.normalize(glsl.cross(camera.front, camera.up)) * cameraSpeed
	}
	if glfw.GetKey(window.handle, glfw.KEY_D) == glfw.PRESS {
		camera.position += glsl.normalize(glsl.cross(camera.front, camera.up)) * cameraSpeed
	}
}

mouse_callback :: proc "c" (handle: glfw.WindowHandle, xposIn: f64, yposIn: f64) {
	app := cast(^App)glfw.GetWindowUserPointer(handle)
	camera := &app.camera
	window := &app.window
	xpos := f32(xposIn)
	ypos := f32(yposIn)

	if window.firstMouse {
		window.lastX = xpos
		window.lastY = ypos
		window.firstMouse = false
	}

	xoffset := xpos - window.lastX
	yoffset := window.lastY - ypos
	window.lastX = xpos
	window.lastY = ypos

	sensitivity: f32 = 0.06
	xoffset *= sensitivity
	yoffset *= sensitivity

	camera.yaw -= xoffset
	camera.pitch -= yoffset

	if camera.pitch > 89 {
		camera.pitch = 89
	}
	if camera.pitch < -89 {
		camera.pitch = -89
	}

	move_camera_targeted(window^, camera)

	front := glsl.vec3 {
		math.cos(glsl.radians(camera.yaw)) * math.cos(glsl.radians(camera.pitch)),
		math.sin(glsl.radians(camera.pitch)),
		math.sin(glsl.radians(camera.yaw)) * glsl.cos(glsl.radians(camera.pitch)),
	}
	//camera.front = glsl.normalize(front)
	camera.front = camera.target
}

scroll_callback := proc "c" (handle: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	app := cast(^App)glfw.GetWindowUserPointer(handle)
	camera := &app.camera
	/*
	camera.fov -= f32(yoffset)
	if camera.fov < 1 {
		camera.fov = 1
	}
	if camera.fov > 45 {
		camera.fov = 45
	}
  */
	camera.tDistance += f32(yoffset)
}

create_window :: proc() -> Window {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	handle := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "model viewer", nil, nil)
	if handle == nil {
		fmt.println("Failed to create window")
		glfw.Terminate()
		os.exit(-1)
	}
	glfw.MakeContextCurrent(handle)


	glfw.SetFramebufferSizeCallback(handle, framebuffer_size_callback)
	glfw.SetCursorPosCallback(handle, mouse_callback)
	glfw.SetScrollCallback(handle, scroll_callback)

	glfw.SetInputMode(handle, glfw.CURSOR, glfw.CURSOR_DISABLED)

	return Window {
		width = SCR_WIDTH,
		height = SCR_HEIGHT,
		firstMouse = true,
		lastX = SCR_WIDTH / 2,
		lastY = SCR_HEIGHT / 2,
		deltaTime = 0,
		lastFrame = 0,
		handle = handle,
	}
}
