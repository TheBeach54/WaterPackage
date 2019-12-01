Shader "Beach/PE_VolumetricFog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	_Density("_Density",Float) = 0.07
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			//#include "AutoLight.cginc"
			//#include "UnityDeferredLibrary.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D_float _VolumetricShadowTex;
			float _FogDensity;
			float4 _FogColor;
			sampler2D _MainTex;
			float4 _CameraDepthTexture_ST;
			sampler2D  _CameraDepthTexture;

			fixed4 frag (v2f i) : SV_Target
			{
				float3 fogCol = float3(0.6,0.6,0.6);
				half depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).x);
				float fogMask = 1 / pow(exp(depth *_FogDensity), 2);
				

				half4 atten = tex2D(_VolumetricShadowTex, i.uv);
				fixed4 col = tex2D(_MainTex, i.uv);
				
				// just invert the colors
				col.rgb = lerp(col, _FogColor, atten.w)+ atten.rgb;
				//col.rgb = atten.rgb*atten.w;
				//float expo = 0.6f;
				//col.rgb = pow(col.rgb * expo,1/ expo);
				//col.rgb = float3(atten.x, atten.y, 0.0f);
				//col.rgb = atten.xyz;
				return col;
			}
			ENDCG
		}
	}
}
