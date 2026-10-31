#version 330 core
layout (location = 0) in vec3 aPos;
//layout (location = 1) in vec2 aTexCoord;

//out vec2 TexCoord;
out vec3 worldPosition;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform float u_time;

void main()
{
  vec4 position = model * vec4(aPos, 1.0);
  /*
  if (position.x > 0) {
    position.x += 4.0f * (1 + cos(u_time));
  } else if (position.x < 0) {
    position.x -= 4.0f * (1 + cos(u_time));
  }
  */
  //position.x += ((0.5 * cos(position.y)) + (0.5 * cos(u_time)));
  //position.x += cos(position.x / abs(position.x)) * ((cos(position.y)) * (cos(2 * u_time)));
  //position.y += cos(position.x / abs(position.y)) * ((sin(position.x)) * (sin(2 * u_time)));
  /*
  float d = length(vec2(position));
  if (cos(d) > cos(u_time) - 0.3 && cos(d) < cos(u_time) + 0.3) {
      position.x += 0.5 * (1 - abs(cos(d) - cos(u_time)));
  }
  */


  worldPosition = position.xyz;
  gl_Position = projection * view * position;

	//TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}
