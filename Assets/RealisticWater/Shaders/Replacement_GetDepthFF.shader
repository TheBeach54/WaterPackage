Shader "Beach/Replacement_GetDepthFrontFace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
			_VelocityMultiplier("_VelocityMultiplier", Float) = 1
		[Toggle]_DontShow("Dont Show In Game", Float) = 0
			_ObjVelocity("Obj Velocity", Float) = 40
	}
	SubShader
	{
		Tags{ "RenderType" = "Dynamic" }
		LOD 100
		Pass
	{
		ColorMask G
		Cull Front
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float eyeD : TEXCOORD0;
	};


	v2f vert(appdata v)
	{
		v2f o;
		float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
		o.eyeD = worldPos.y;
		o.vertex = mul(UNITY_MATRIX_VP, worldPos);
		return o;
	}

	float4 frag(v2f i) : SV_Target
	{


		// sample the texture
		float lD = i.eyeD;
	return float4(0.0f, lD ,0.0f, 1.0f);
	}
		ENDCG
	}
		Pass
		{
			ColorMask RB
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float eyeD : TEXCOORD0;
			};
			float _ObjVelocity;
			float _VelocityMultiplier;

			v2f vert (appdata v)
			{
				v2f o;
				float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.eyeD = worldPos.y;
				o.vertex = mul(UNITY_MATRIX_VP, worldPos);
				return o;
			}
			
			float4 frag(v2f i) : SV_Target
			{

				
				// sample the texture
				float lD = i.eyeD;


			return float4(lD.x, 0.0f , _ObjVelocity * _VelocityMultiplier, 1.0f);
			}
			ENDCG
		}
	
	}
}
