#include "UnityDeferredLibrary.cginc"

uniform sampler2D _GrabTexture;

inline void DynamicDisplace(sampler2D height, float2 uv, float3 wNormal, float dispIntensity, inout float4 wPos)
{
	float d = tex2Dlod(height, float4(uv, 0, 0)).r;
	//d *= dispIntensity;

	wPos.xyz += wNormal * d;
}

inline float3 OverlayBlending(float3 base, float3 overlay)
{

	return lerp(1 - 2 * (1 - base) * (1 - overlay), 2 * base * overlay, step(Luminance(base), 0.5));
}

inline float2 GetCircularDirection(float3 wPos, float2 gPos)
{
	float2 o;
	float2 temp = gPos - wPos.zx;

	temp = normalize(temp);

	o.x = temp.x;
	o.y = temp.y;

	return o;
}

inline void GetGrabDepth_Corrected(float eyeD, float2 uv, float2 refrUV, float2 refrBiasUV, out half3 grabPass, out float depthBuff, out float originalDepth, out float depthLinear, out float originalLinear)
{

	//We sample the GrabPass two times
	//One with the distorted screen uv computed earlier 
	//and one with the normal screen uv
	half3 grab = tex2D(_GrabTexture, refrUV);
	half3 grab2 = tex2D(_GrabTexture, uv);

	//We sample the depth three times 
	// Sample the depth with the screen uv distorted by the refraction
	float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, refrUV);
	// Sample the depth with the screen uv  more distorted by the refraction using a bias
	float depthBias = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, refrBiasUV);
	// Sample the depth with the normal screen uv
	float depth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
	//We check the distance of the more distorted depth buffer
	float depthRefract = LinearEyeDepth(depthBias);
	float depthEye = LinearEyeDepth(depth);
	float depthRefrEye = LinearEyeDepth(depth2);

	//And compare it with the distance of the water fragment
	float eyeTest = step(eyeD - depthRefract, 0);

	//If the distoted depth is closer than the water we don't want it to be in the refraction
	//So we fallback to the undistorted version of the depth buffer and grabpass
	originalDepth = depth2;
	originalLinear = depthRefrEye;
	depthBuff = lerp(depth2, depth, eyeTest);
	grabPass = lerp(grab2, grab, eyeTest);
	depthLinear = lerp(depthRefrEye, depthEye, eyeTest);
}

//Normalize float value between 0 and 1
inline float InverseLerp(float min, float max, float x)
{
	return saturate((x - min) / (max - min));
}

float3 BoxProjection(float3 direction, float3 position, float3 cubemapPosition, float3 boxMin, float3 boxMax)
{
	float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
	float scalar = min(min(factors.x, factors.y), factors.z);
	return direction * scalar + (position - cubemapPosition);
}

//Compute world position using the depth buffer
float3 DepthToWorldPos(float2 uv, float depth, float4x4 projMat, float4x4 viewMat)
{
	float4 H = float4(uv.xy * 2 - 1, depth, 1.0);
	float4 D = mul(projMat, H);
	D = float4(D.xyz / D.w, 1.0);
	float4 wSPos = mul(viewMat, D);
	//return float4(wSPos.rgb, 1.0);

	return (wSPos.xyz + _WorldSpaceCameraPos)/2;
}

float3 DepthToWorldPos_ImageEffect(float2 uv, float depth, float3 ray)
{
	depth = LinearEyeDepth(depth);
	float3 depthWP = ray * depth + _WorldSpaceCameraPos;
	return depthWP;

}

float ComputeWaterTop(float3 viewDir, float3 wPos, float waterLevel = 0)
{
	float3 up = float3(0, wPos.y - waterLevel, 0);
	float VdotU = dot(viewDir, normalize(up));
	float angle = acos(VdotU);

	float d = length(up) / sin(3.1415 / 2 - angle);
	d = -d;
	if (d < 0)
		d = _ProjectionParams.z;


	return d;
	//return abs(d) * mk;
}