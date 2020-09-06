Shader "GLU/Simple Skybox" 
{
	Properties
	{
		_MainTex ("Texture 1", 2D) = "white" {}
	}
	
	Category
	{
		Tags { "Queue"="Background" "RenderType"="Background" }
		Cull Off 
		ZWrite Off
		Lighting Off
		Fog { Mode Off }
		Blend One Zero
		
		SubShader
		{
			Pass
			{
				SetTexture [_MainTex]
				{
					combine texture
				}			
			}
		}
	}
	
	Fallback "Diffuse"
}
