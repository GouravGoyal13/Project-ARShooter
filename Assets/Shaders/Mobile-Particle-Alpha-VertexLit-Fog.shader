// Simplified VertexLit Blended Particle shader. Differences from regular VertexLit Blended Particle one:
// - no AlphaTest
// - no ColorMask

Shader "GLU/Particles/VertexLit Blended Fog"
{
	Properties 
	{
		_EmisColor ("Emissive Color", Color) = (0.2, 0.2, 0.2, 0)
		_MainTex ("Particle Texture", 2D) = "white" {}
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off ZWrite Off Fog { Mode Global }
	
		Lighting On
		Material { Emission [_EmisColor] }
		ColorMaterial AmbientAndDiffuse

		SubShader 
		{
			Pass 
			{
				SetTexture [_MainTex] 
				{
					combine texture * primary
				}
			}
		}
	}
}