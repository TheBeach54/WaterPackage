Shader "Unlit/WaterStencilMask"
{
	Properties
	{
		_DiscardDot("Y tolerance before discard",Range(-1,1)) = -0.5
		[IntRange]_Debug("_Debug", Range(0,14)) = 0
	}
		SubShader
	{
		Tags { "Queue" = "Transparent-2" "RenderType" = "Transparent" }
		LOD 100
		Stencil{
		Ref 3
		Comp Always
		ZFail Keep
		Pass Replace
		}

		
		ColorMask [_Debug]
		ZWrite On
		ZTest Always

	Pass
	{
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		// make fog work
		#pragma multi_compile_fog

		#include "UnityCG.cginc"
		half _Debug, _DiscardDot;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float3 normal : NORMAL;

				float4 vertex : SV_POSITION;
			};


			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				//if (_Debug)
				//discard;
				if (dot(normalize(i.normal),float3(0,-1,0)) >_DiscardDot)

				discard;
			return float4(i.normal, 1);
				//return col;
			}
			ENDCG
		}
	}
}
