package main

import "core:os"
import "core:strconv"
import "core:strings"

Model :: struct {
	vertices: []f32,
	faces:    []u32,
}

load_model :: proc(filename: string) -> (model: Model, ok: bool) {
	data, err := os.read_entire_file_from_path(filename, context.allocator)
	defer delete(data)
	if err != nil {
		return Model{}, false
	}
	text := string(data)
	vertices := make([dynamic]f32)
	faces := make([dynamic]u32)

	for line in strings.split_lines_iterator(&text) {
		line := strings.trim_left_space(line)
		if (len(line) <= 0) do continue

		if (strings.starts_with(line, "v ")) {
			line := strings.trim_space(line[1:])
			vert_strings := strings.split(line, " ")
			for vs in vert_strings {
				vertex := strconv.parse_f32(vs) or_return
				append(&vertices, vertex)
			}
		} else if (strings.starts_with(line, "f ")) {
			line := strings.trim_space(line[1:])
			vertex_indices := make([dynamic]u32)
			defer delete(vertex_indices)
			for face_chars in strings.fields_iterator(&line) {
				indices := strings.split(face_chars, "/")
				vi := strconv.parse_uint(indices[0]) or_return
				append(&vertex_indices, u32(vi) - 1)
			}
			for i := 2; i < len(vertex_indices); i += 1 {
				append(&faces, vertex_indices[0], vertex_indices[i - 1], vertex_indices[i])
			}
		}
	}

	return Model{vertices[:], faces[:]}, true
}

delete_model :: proc(model: Model) {
	delete(model.vertices)
	delete(model.faces)
}
