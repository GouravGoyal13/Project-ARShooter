// Based on Unity's built in Unlit/Texture shader
Shader "GLU/DoubleSided/Unlit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		
		Pass 
		{
			Lighting Off
			Cull off
			SetTexture [_MainTex] { combine texture } 
		}
	}
}
