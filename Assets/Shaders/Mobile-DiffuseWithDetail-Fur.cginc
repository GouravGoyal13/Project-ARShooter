#ifndef MOBILE_DIFFUSE_WITH_DETAIL_FUR_INCLUDED
#define MOBILE_DIFFUSE_WITH_DETAIL_FUR_INCLUDED

#include "Mobile-DiffuseWithDetail.cginc"

//#define EXTRUDE_MAX_LEVEL 15.0

#ifndef EXTRUDE_LEVEL
#	define EXTRUDE_LEVEL 0
#endif

#define LEVEL01 (EXTRUDE_LEVEL / EXTRUDE_MAX_LEVEL)
#define ONE_MINUS_LEVEL01 (1.0 - LEVEL01)

// This is pow(LEVEL01, 3) but can be worked out at compile time
#define LEVEL01_POW (LEVEL01 * LEVEL01 * LEVEL01)
#define ONE_MINUS_LEVEL01_POW (ONE_MINUS_LEVEL01 * ONE_MINUS_LEVEL01 * ONE_MINUS_LEVEL01)

#define FUR_LENGTH_IN_VERTEX_COLORS
#define FUR_LENGTH_VERTEX_COLOR_CHANNEL r

float4 _DiffuseTex_TexelSize;

sampler2D _FurTex;
fixed _FurScale;
fixed _FurOffset;
float _FurLength;
float _FurTrim;
float3 _FurGravity;
fixed _FurStrength;

struct VertOutFur
{
	VertOut base;
#if EXTRUDE_LEVEL
	fixed4 col : COLOR;
#endif
};

VertOutFur v_fur(VertIn INPUT)
{
	VertOutFur OUTPUT;

	float furLength = _FurLength;
#	ifdef FUR_LENGTH_IN_VERTEX_COLORS
	furLength *= INPUT.color.FUR_LENGTH_VERTEX_COLOR_CHANNEL;
#	endif
	INPUT.position.xyz -= INPUT.normal * furLength * _FurTrim;

#if EXTRUDE_LEVEL
	furLength *= LEVEL01;
	INPUT.position.xyz += INPUT.normal * furLength;
	float3 gravity = _Object2World[0].xyz * _FurGravity.x + _Object2World[1].xyz * _FurGravity.y + _Object2World[2].xyz * _FurGravity.z;
	INPUT.position.xyz += gravity * furLength * LEVEL01_POW;
	fixed alpha = 1.0 - LEVEL01_POW;
	OUTPUT.col = fixed4(1.0, 1.0, 1.0, alpha);
#	ifdef FUR_SHADOW
	fixed shadow = 1.0 - _FurStrength * (_FurLength > 0.0) * ONE_MINUS_LEVEL01_POW;
	OUTPUT.col.rgb *= shadow;
#	endif
#endif

	OUTPUT.base = v(INPUT);

	return OUTPUT;
}

PixelOut p_fur(VertOutFur input)
{
	PixelOut OUT = p(input.base);

#if EXTRUDE_LEVEL
	OUT.color.a = tex2D(_FurTex, input.base.uv).a * _FurScale + _FurOffset;
	OUT.color *= input.col;
	//clip(OUT.color.a);
#endif

	return OUT;
}

#endif
