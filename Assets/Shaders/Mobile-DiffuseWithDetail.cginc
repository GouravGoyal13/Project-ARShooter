#ifndef MOBILE_DIFFUSE_WITH_DETAIL_INCLUDED
#define MOBILE_DIFFUSE_WITH_DETAIL_INCLUDED

#include "UnityCG.cginc"

fixed3 _LightColor0;

sampler2D _DiffuseTex;
float4 _DiffuseTex_ST;

sampler2D _NormalTex;

half _MinSpecularGlossiness;
half _MaxSpecularGlossiness;
fixed _MinDiffuseCoefficient;
fixed _MaxDiffuseCoefficient;

struct VertIn
{
	float4 position : POSITION;
	float4 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 texcoord : TEXCOORD0;
	fixed4 color : COLOR;
};

struct VertOut
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
	fixed3 tSpace0 : TEXCOORD1;
	fixed3 tSpace1 : TEXCOORD2;
	fixed3 tSpace2 : TEXCOORD3;
	fixed3 halfAngleDir : TEXCOORD4;
};

VertOut v(VertIn INPUT)
{
	VertOut OUTPUT;

	OUTPUT.position = mul(UNITY_MATRIX_MVP, INPUT.position);
	OUTPUT.uv = TRANSFORM_TEX(INPUT.texcoord, _DiffuseTex);

	float3 worldPosition = mul(_Object2World, INPUT.position).xyz;
	float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPosition));
	float3 worldNormal = UnityObjectToWorldNormal(INPUT.normal);
	float3 worldTangent = UnityObjectToWorldDir(INPUT.tangent.xyz);
	float3 worldBitangent = cross(worldNormal, worldTangent) * INPUT.tangent.w;

	OUTPUT.tSpace0 = fixed3(worldTangent.x, worldBitangent.x, worldNormal.x);
	OUTPUT.tSpace1 = fixed3(worldTangent.y, worldBitangent.y, worldNormal.y);
	OUTPUT.tSpace2 = fixed3(worldTangent.z, worldBitangent.z, worldNormal.z);

	float3 halfAngleDir = normalize(worldViewDir + _WorldSpaceLightPos0.xyz);
	OUTPUT.halfAngleDir = halfAngleDir;

	return OUTPUT;
}

struct PixelOut
{
	fixed4 color : COLOR;
};

PixelOut p (VertOut input)
{
	PixelOut OUT;

#ifdef DISABLE_AMBIENT
	fixed3 ambientColor = 0;;
#else
	fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
#endif

	float4 normalTexture = tex2D(_NormalTex, input.uv);
	fixed3 normal = UnpackNormal(normalTexture);
	fixed3 worldNormal = normalize(fixed3(dot(input.tSpace0.xyz, normal), dot(input.tSpace1.xyz, normal), dot(input.tSpace2.xyz, normal)));
	fixed NdotL = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
	fixed diffuseCoefficient = clamp(NdotL, _MinDiffuseCoefficient, _MaxDiffuseCoefficient);
	fixed4 diffuseTexture = tex2D(_DiffuseTex, input.uv);
	fixed3 diffuseColor = (_LightColor0.rgb * diffuseTexture) * diffuseCoefficient;

	fixed NdotH = max(0, dot(worldNormal, normalize(input.halfAngleDir)));
	fixed specularIntensity = diffuseTexture.a * NdotL;
	// On mobile platforms this is really the same as:
	// half specularGlossiness = _MaxSpecularGlossiness;
	// as normalTexture.a will always be 1.0, but it does not save any cycles to remove it...
	half specularGlossiness = lerp(_MinSpecularGlossiness, _MaxSpecularGlossiness, normalTexture.a);
	half specularCoefficient = pow(NdotH, specularGlossiness) * specularIntensity;
	half3 specularColor = _LightColor0.rgb * specularCoefficient;

	half3 finalColor = ambientColor + diffuseColor + specularColor;

	OUT.color = fixed4(finalColor, 1.0);

	return OUT;
}

#endif
