
// This parameter must be a property of the shader.
float _ReceiveShadows;


int _ShadowsEnabled;
sampler2D _ShadowMap;
float4x4 _ShadowMatrix;
float4x4 _ShadowViewMatrix;
float _ShadowCameraFarClipPlane;
float4x4 _ShadowBiasMatrix;

half3 ApplyShadows( half3 color, float4 shadowCoord )
{
    if( _ShadowsEnabled >= 1 && _ReceiveShadows > 0)
    {                   
        float shadowDepth = 1.0f;

        float sx = shadowCoord.x * 0.5 + 0.5;
        float sy = shadowCoord.y * 0.5 + 0.5;
        float sz = shadowCoord.z * 0.5 + 0.5;
        
        float4 finalShadowCoord = float4( sx, sy, sz, shadowCoord.w );
        if( finalShadowCoord.x >= 0.00 && finalShadowCoord.x <= 1.0 )
        {
            if( finalShadowCoord.y >= 0.00 && finalShadowCoord.y <= 1.0 )
            {
                shadowDepth = tex2Dproj( _ShadowMap, finalShadowCoord ).z;
                shadowDepth = clamp( shadowDepth, 0.4, 1.0 );
            }
        }

       color *= shadowDepth;
   }

   return color;
}

float4 CalculateShadowCoordinate(float4 vertex)
{
    return mul( _ShadowMatrix, mul( _Object2World, vertex ) );
}