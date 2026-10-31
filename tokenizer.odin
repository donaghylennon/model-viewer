package main

TokenKind :: enum {
	Vertex,
	VertexNormal,
	VertexTexture,
	Face,
	Float,
	Int,
}

Token :: struct {
	kind: TokenKind,
	text: string,
}

Tokenizer :: struct {
	source: string,
	pos:    int,
}


tokenize :: proc(input: string) -> []Token {
	create_tokenizer(input)
	return {}
}

create_tokenizer :: proc(source: string) -> Tokenizer {
	return Tokenizer{source, 0}
}
