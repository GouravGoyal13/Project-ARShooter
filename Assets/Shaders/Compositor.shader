//
Shader "Helios/Compositor"
{
	Properties
	{
		_MainTex ("Background", 2D) = "white" {}
	}

	SubShader
	{

		Pass
		{
			Cull Off
			ZWrite Off
			ZTest Always
			Blend Off
			AlphaTest Off

			Fog { Mode off }

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#pragma target 3.0

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			#if defined(SINEWAVE_DISTORTION_ENABLED)
			#	define RESPECT_DISTORTED_UVS
			#endif

			// !!WARNING!! - the multi_compiles will need to be uncommented for the effect you want.

			//#pragma multi_compile _ ANTIALIASING_ENABLED
			#include "Assets/Packages/Helios/Resources/Antialiasing.cginc"

			#pragma multi_compile _ COLOR_CORRECTION_ENABLED
			//#define COLOR_CORRECTION_LOOKUP rgb_color_correction_color
			#include "Assets/Packages/Helios/Resources/ColorCorrection.cginc"

			#pragma multi_compile _ BLOOM_ENABLED
			#include "Assets/Packages/Helios/Resources/Bloom.cginc"

			#pragma multi_compile _ DEPTH_OF_FIELD_ENABLED DEPTH_OF_FIELD_DEBUG_ENABLED
			#include "Assets/Packages/Helios/Resources/DepthOfField.cginc"

			#pragma multi_compile _ CHROMATIC_ABERRATION_ENABLED
			#define CHROMATIC_ABERRATION_CHANNEL g
			#ifdef RESPECT_DISTORTED_UVS
			#	define CHROMATIC_ABERRATION_DEPENDENT_UV
			#endif
			#define CHROMATIC_ABERRATION_MODE 2
			#include "Assets/Packages/Helios/Resources/ChromaticAberration.cginc"

			#pragma multi_compile _ SINEWAVE_DISTORTION_ENABLED
			#include "Assets/Packages/Helios/Resources/SinewaveDistortion.cginc"

			//#pragma multi_compile _ VIGNETTING_ENABLED
			#include "Assets/Packages/Helios/Resources/Vignetting.cginc"

			//#pragma multi_compile _ MOTION_BLUR_ENABLED
			//#define MOTION_BLUR_SAMPLES 10
			#ifdef RESPECT_DISTORTED_UVS
			#	define MOTION_BLUR_DEPENDENT_UV
			#endif
			#include "Assets/Packages/Helios/Resources/MotionBlur.cginc"

			//#pragma multi_compile _ BLUR_ENABLED
			#ifdef RESPECT_DISTORTED_UVS
			#	define BLUR_DEPENDENT_UV
			#endif
			#include "Assets/Packages/Helios/Resources/Blur.cginc"

			//#pragma multi_compile _ RADIAL_BLUR_ENABLED
			#ifdef RESPECT_DISTORTED_UVS
			#	define RADIAL_BLUR_DEPENDENT_UV
			#endif
			#include "Assets/Packages/Helios/Resources/RadialBlur.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				V2F_COLOR_CORRECTION
				V2F_BLOOM(1)
				V2F_DEPTH_OF_FIELD(2)
				V2F_CHROMATIC_ABERRATION(3)
				V2F_VIGNETTING(4)

				V2F_MOTION_BLUR(5)			///< !!!WARNING!!! - same index as distortion - means one or the other...
				V2F_SINEWAVE_DISTORTION(5)	///< !!!WARNING!!! - same index as motion blur - means one or the other...

				V2F_BLUR(6)				///< !!!WARNING!!! - same index as radial blur & antialiasing - means only one...
				V2F_RADIAL_BLUR(6, 7)	///< !!!WARNING!!! - same index as blur & antialiasing - means only one...
				V2F_ANTIALIASING(6, 7)	///< !!!WARNING!!! - same index as blur & radial blur - means only one...
			};

			v2f vert(appdata_base v)
			{
				float4 pos = mul(UNITY_MATRIX_MVP, v.vertex);
				v2f o;
				o.pos = pos;
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					o.uv.y = 1.0 - o.uv.y;
				#endif

				TRANSFER_SINEWAVE_DISTORTION(o, v);
				TRANSFER_ANTIALIASING(o, v);
				TRANSFER_COLOR_CORRECTION(o, v);
				TRANSFER_BLOOM(o, v);
				TRANSFER_DEPTH_OF_FIELD(o, v);
				TRANSFER_CHROMATIC_ABERRATION(o, v);
				TRANSFER_VIGNETTING(o, v);
				TRANSFER_MOTION_BLUR(o, v);
				TRANSFER_BLUR(o, v);
				TRANSFER_RADIAL_BLUR(o, v);

				return o;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, IN.uv);

				SINEWAVE_DISTORTION_COLOR(col, IN);
				RADIAL_BLUR_COLOR(col, IN);
				BLUR_COLOR(col, IN);
				MOTION_BLUR_COLOR(col, IN);
				ANTIALIASING_COLOR(col, IN);
				CHROMATIC_ABERRATION_COLOR(col, IN);
				DEPTH_OF_FIELD_COLOR(col, IN);
				COLOR_CORRECTION_COLOR(col, IN);
				BLOOM_COLOR(col, IN);
				VIGNETTING_COLOR(col, IN);

				return col;
			}
			ENDCG
		}
	}

	Fallback Off
}
