Shader "Unlit/MatrixTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	_Angles("Angle", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 oPos : TECVOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};


			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _Angles;
			


			v2f vert (appdata v)
			{
				v2f o;
				o.oPos = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float3 RotateVector(float3 vec, float3 angles)
			{

				

				float xC = cos(angles.x);
				float xS = sin(angles.x);
				float xoC = 1 - xC;

				float yC = cos(angles.y);
				float yS = sin(angles.y);
				float yoC = 1 - yC;

				float zC = cos(angles.z);
				float zS = sin(angles.z);
				float zoC = 1 - zC;

				float3 v = normalize(float3(1, 0, 0));


				//float xTrans[9] = { xC + v.x * v.x * xoC, v.x * v.y * xoC - v.z * xS, v.x * v.z * xoC + v.y * xS,
				//	v.y * v.x * xoC + v.z * xS,	xC + v.y * v.y * xoC, v.y * v.z * xoC - v.x * xS,
				//	v.z + v.x * xoC - v.y * xS,	v.z * v.y * xoC + v.x * xS,	xC + v.z * v.z * xoC };

				float xTrans[9] = { 1,		0,			0,
									0,		xC,			-xS,
									0,		xS,			xC };

				float yTrans[9] = { yC,		0.0f,		yS,
									0.0f,	yC + yoC,	0.0f,
									-yS,	0.0f,		yC};

				float zTrans[9] = { zC,		-zS,		0,
									zS,		zC,			0,
									0,		0,			1 };


				float4x4 xMatrix, yMatrix, zMatrix;

				xMatrix[0] = float4(xTrans[0], xTrans[1], xTrans[2], 0.0f);
				xMatrix[1] = float4(xTrans[3], xTrans[4], xTrans[5], 0.0f);
				xMatrix[2] = float4(xTrans[6], xTrans[7], xTrans[8], 0.0f);
				xMatrix[3] = float4(0, 0, 0, 1.0f);

				yMatrix[0] = float4(yTrans[0], yTrans[1], yTrans[2], 0.0f);
				yMatrix[1] = float4(yTrans[3], yTrans[4], yTrans[5], 0.0f);
				yMatrix[2] = float4(yTrans[6], yTrans[7], yTrans[8], 0.0f);
				yMatrix[3] = float4(0, 0, 0, 1.0f);

				zMatrix[0] = float4(zTrans[0], zTrans[1], zTrans[2], 0.0f);
				zMatrix[1] = float4(zTrans[3], zTrans[4], zTrans[5], 0.0f);
				zMatrix[2] = float4(zTrans[6], zTrans[7], zTrans[8], 0.0f);
				zMatrix[3] = float4(0, 0, 0, 1.0f);


				return normalize( mul(mul(xMatrix,mul(yMatrix,zMatrix)), float4(vec.zyx,1.0)).xyz);


			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				
			float3 normal = normalize(i.oPos);
			float3 angles = _Angles;
			

			float3 newNormal = RotateVector(normal, angles);


			float pi = 3.14159f;
			float phi = 6.28318f;

		//	return float4(newNormal, 1.0f) * 0.5 + 0.5;



			float UVx = (acos(-newNormal.y) / pi);
			float UVy = (atan2(newNormal.x, newNormal.z) / phi + 0.5);

			float2 uv = float2(UVy, UVx);

			fixed4 col = tex2D(_MainTex, uv);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
