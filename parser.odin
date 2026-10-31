package main

Expr :: union {
	Vertex,
	TexCoord,
	SurfNormal,
}

Vertex :: distinct [3]f32

TexCoord :: distinct [3]f32

SurfNormal :: distinct [3]f32

Parser :: struct {}
