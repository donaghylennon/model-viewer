#version 330 core
out vec4 FragColor;

in vec3 worldPosition;

uniform float u_time;

#define PI radians(180.0)

void main()
{
  vec3 normal = normalize(cross(dFdx(worldPosition), dFdy(worldPosition)));

  // Keep lighting consistent for both sides of a triangle.
  if (!gl_FrontFacing) {
      normal = -normal;
  }

  vec3 lightDirection = normalize(vec3(0.4, 0.7, 0.6));
  float diffuse = max(dot(normal, lightDirection), 0.0);

  vec3 baseColor = vec3(0.75, 0.45, 0.20);
  //vec3 dist = abs(worldPosition);
  //vec3 baseColor = vec3(0.75 * cos(dist.x), 0.45 * cos(dist.y), 0.20 * cos(dist.z));
  //float distance = length(vec2(worldPosition));
  //vec3 baseColor = vec3((cos(distance)+1)/2, (cos(distance + PI/2)+1)/2, (cos(distance + PI))+1)/2;
  vec3 color = baseColor * (0.15 + 0.85 * diffuse);

  FragColor = vec4(color, 1.0);
	//FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
