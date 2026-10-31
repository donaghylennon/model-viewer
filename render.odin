package main

import "core:math/linalg/glsl"
import "core:os"
import "core:slice"
import gl "vendor:OpenGL"

Camera :: struct {
	position:  glsl.vec3,
	front:     glsl.vec3,
	up:        glsl.vec3,
	// Free floating camera
	yaw:       f32,
	pitch:     f32,
	fov:       f32,
	// Targeted camera
	target:    glsl.vec3,
	tDistance: f32,
}

Shader :: struct {
	vertex_src:   string,
	fragment_src: string,
	program:      u32,
}

Mesh :: struct {
	vertices: []f32,
	faces:    []u32,
	vao:      u32,
	vbo:      u32,
	ebo:      u32,
	shader:   Shader,
}

create_mesh :: proc(model: Model) -> Mesh {
	return Mesh {
		slice.clone(model.vertices),
		slice.clone(model.faces),
		0,
		0,
		0,
		create_shader("./res/vertex.vs", "./res/fragment.fs"),
	}
}

init_mesh :: proc(mesh: ^Mesh) {
	gl.GenVertexArrays(1, &mesh.vao)
	gl.GenBuffers(1, &mesh.vbo)
	gl.GenBuffers(1, &mesh.ebo)

	gl.BindVertexArray(mesh.vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(f32),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(mesh.faces) * size_of(u32),
		raw_data(mesh.faces),
		gl.STATIC_DRAW,
	)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}

delete_mesh :: proc(mesh: ^Mesh) {
	gl.DeleteVertexArrays(1, &mesh.vao)
	gl.DeleteBuffers(1, &mesh.vbo)
	gl.DeleteBuffers(1, &mesh.ebo)
	delete_shader(mesh.shader)

	delete(mesh.vertices)
	delete(mesh.faces)
}

get_centre :: proc(mesh: ^Mesh) -> glsl.vec3 {
	max_edge := glsl.vec3{mesh.vertices[0], mesh.vertices[1], mesh.vertices[2]}
	min_edge := max_edge

	for i := 0; i + 2 < len(mesh.vertices); i += 3 {
		vertex := [3]f32{mesh.vertices[i], mesh.vertices[i + 1], mesh.vertices[i + 2]}
		if vertex.x > max_edge.x do max_edge.x = vertex.x
		if vertex.y > max_edge.y do max_edge.y = vertex.y
		if vertex.z > max_edge.z do max_edge.z = vertex.z

		if vertex.x < min_edge.x do min_edge.x = vertex.x
		if vertex.y < min_edge.y do min_edge.y = vertex.y
		if vertex.z < min_edge.z do min_edge.z = vertex.z
	}

	return (min_edge + max_edge) / 2
}

get_aabb_diagonal_length :: proc(mesh: ^Mesh) -> f32 {
	max_edge := glsl.vec3{mesh.vertices[0], mesh.vertices[1], mesh.vertices[2]}
	min_edge := max_edge

	for i := 0; i + 2 < len(mesh.vertices); i += 3 {
		vertex := [3]f32{mesh.vertices[i], mesh.vertices[i + 1], mesh.vertices[i + 2]}
		if vertex.x > max_edge.x do max_edge.x = vertex.x
		if vertex.y > max_edge.y do max_edge.y = vertex.y
		if vertex.z > max_edge.z do max_edge.z = vertex.z

		if vertex.x < min_edge.x do min_edge.x = vertex.x
		if vertex.y < min_edge.y do min_edge.y = vertex.y
		if vertex.z < min_edge.z do min_edge.z = vertex.z
	}

	return glsl.length(max_edge - min_edge)
}

draw_mesh :: proc(mesh: ^Mesh, camera: ^Camera) {
	shader := &mesh.shader
	gl.UseProgram(shader.program)
	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.position, camera.target, camera.up)

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(45),
		f32(f32(SCR_WIDTH) / f32(SCR_HEIGHT)),
		0.1,
		100,
	)

	shader_set_mat4(shader.program, "projection", projection)
	shader_set_mat4(shader.program, "view", view)

	gl.BindVertexArray(mesh.vao)
	model: glsl.mat4 = 1
	angle := f32(90.0)
	model *= glsl.mat4Rotate({-1.0, 0.0, 0.0}, glsl.radians(angle))
	model *= glsl.mat4Translate(-get_centre(mesh))
	shader_set_mat4(shader.program, "model", model)

	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.faces)), gl.UNSIGNED_INT, nil)
}

create_shader :: proc(vertex_src, fragment_src: string) -> Shader {
	program, loaded_ok := gl.load_shaders_file(vertex_src, fragment_src)
	if !loaded_ok {
		os.exit(-1)
	}
	return Shader{vertex_src, fragment_src, program}
}

delete_shader :: proc(shader: Shader) {
	gl.DeleteProgram(shader.program)
}


shader_set_mat4 :: proc(id: u32, name: cstring, mat: glsl.mat4) {
	lc := mat
	gl.UniformMatrix4fv(gl.GetUniformLocation(id, name), 1, gl.FALSE, raw_data(&lc))
}

shader_set_f32 :: proc(id: u32, name: cstring, float: f32) {
	gl.Uniform1f(gl.GetUniformLocation(id, name), float)
}
