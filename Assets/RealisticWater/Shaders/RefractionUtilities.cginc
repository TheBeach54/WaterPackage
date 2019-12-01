#ifndef REFRACTION_UTILITIES
#define REFRACTION_UTILITIES

float3 RayCastPlane(float3 planeNormal, float3 planePosition, float3 start, float3 end)
{
	float3 ray = end - start;
	float3 rayDir = normalize(ray);
	float RdotP = dot(rayDir, planeNormal);

	float3 hitPos = start + rayDir * (dot(planePosition - start, planeNormal) / RdotP);
	return hitPos;
}



float3 RayCastCylinder(float3 start, float3 dir, float3 cylPosition, float3 cylAxis, float cylRadius)
{
	float3 toCyl = start - cylPosition;

	float axisDotDir = dot(cylAxis, dir);
	float distAlongAxis = dot(cylAxis, toCyl);

	float a = 1.0f - axisDotDir*axisDotDir;
	float b = dot(toCyl, dir) - distAlongAxis*axisDotDir;
	float c = dot(toCyl, toCyl) - distAlongAxis*distAlongAxis - cylRadius*cylRadius;
	float h = b*b - a*c;
	if (h < 0.0f) return float3(-1.0f, -1.0f, 0.0f);
	h = sqrt(h);
	float dist = (-b - h) / a;
	return start + dir*dist;
	//return float2(-b - h, -b + h) / a;
}

float2 RayCastSphere(float3 start, float3 dir, float3 position, float radius)
{
	float3 toSphere = start - position;
	float b = dot(toSphere, dir);
	float c = dot(toSphere, toSphere) - radius*radius;
	float h = b*b - c;
	if (h < 0.0f)
		return float2(-1.0, -1.0);
	h = sqrt(h);
	return float2(-b - h, -b + h);
}

float3 GetRefractedPointOnSphere(float3 start, float3 end, float3 position, float radius, float indice = 1.3f)
{
	float3 o;
	float3 ray = end - start;
	float rayLength = length(ray);
	float3 rayDir = ray / rayLength;

	float2 hitInfo = RayCastSphere(start, rayDir, position, radius);

	if (hitInfo.x < 0.0f && hitInfo.y < 0.0f)
		return end;

	float minDist = min(hitInfo.x, hitInfo.y);
	float maxDist = max(hitInfo.x, hitInfo.y);

	if (rayLength > maxDist || rayLength < minDist)
		return end;

	float hitDist = min(hitInfo.x, hitInfo.y);
	float3 hitPos = start + rayDir * hitDist;
	float3 hitToOrigin = hitPos - position;
	float hitSphDist = length(hitToOrigin);

	//if (hitSphDist > radius)
	//	return end;

	float3 hitNormal = hitToOrigin / hitSphDist * sign(hitInfo.y - hitInfo.x);// length(hitPos - position);

	float3 refractedDir = refract(rayDir, hitNormal, 1/indice);

	float2 percHitInfo = RayCastSphere(end, -refractedDir, position, radius);

	if (percHitInfo.x < 0.0f && percHitInfo.y < 0.0f)
		return end;

	float percHitDist = min(percHitInfo.x, percHitInfo.y);



	float3 perceivedHitPos = end - refractedDir * percHitDist;
	float3 newRay = perceivedHitPos - start;
	float3 newDir = normalize(newRay);
	float3 newLength = dot(ray, newDir);// length(newRay);
	o = start + newDir * rayLength;
	float sphereCheck = length(o - position);
	//if (sphereCheck > radius)
	//	return (end+ o)*0.5f;
	//o = perceivedHitPos;


	return o;
}
/*
// inifintie cylinder defined by a base point cb, a normalized axis ca and a radious cr
vec2 cylIntersect(in vec3 ro, in vec3 rd, in vec3 cb, in vec3 ca, float cr)
{
vec3  oc = ro - cb;
float card = dot(ca, rd);
float caoc = dot(ca, oc);

float a = 1.0 - card*card;
float b = dot(oc, rd) - caoc*card;
float c = dot(oc, oc) - caoc*caoc - cr*cr;
float h = b*b - a*c;
if (h < 0.0) return vec2(-1.0);
h = sqrt(h);
return vec2(-b - h, -b + h) / a;
}*/
/*
float3 RayCastCylinder(float3 cylNormal, float3 cylRadius, float3 cylPosition, float3 start, float3 end)
{
float3 ray = end - start;
float3 rayDir = normalize(ray);
float3 rayLength = length(ray);
float3 worldUp = float3(0, 1, 0);
float3 cylTangent = cross(worldUp, cylNormal);
float3 toOrigin = cylPosition - start;

float3 projection = (dot(toOrigin, cylTangent) * cylTangent + dot(toOrigin, worldUp) * worldUp);
float projLength = length(projection) + cylRadius;
float3 hitNormal = normalize(projection);
float sinO = dot(rayDir, hitNormal);
float3 hitPos = start + (projLength / sinO) * rayDir;


return hitPos;
}*/

float3 ProjectPointOnPlane(float3 planeNormal, float3 planePosition, float3 pos)
{
	return pos + dot(planePosition - pos, planeNormal) * planeNormal;
}
float IntersectPlane(float3 planeNormal, float3 planePosition, float3 pos, float3 dir)
{
	return dot((pos - planePosition), planeNormal) / dot(dir, planeNormal);
}

float3 GetRefractedPointOnCylinder(float3 axis, float3 position, float radius, float3 start, float3 end, float indice)
{
	float3 ray = end - start;
	float3 rayDir = normalize(ray);
	float rayLength = length(ray);
	float3 worldUp = float3(0, 1, 0);
	float3 cylX, cylY;

	if (rayDir.y == worldUp.y)
	{
		worldUp = float3(0.1, 0.9, 0);
		cylX = normalize(cross(axis, worldUp));
		cylY = normalize(cross(axis, cylX));
		cylX = normalize(cross(cylX, cylY));
	}
	else
	{
		cylX = normalize(cross(axis, worldUp));
		cylY = normalize(cross(axis, cylX));
	}

	float3 rayHit = RayCastCylinder(start, rayDir, axis, position, radius);
	float3 toHit = normalize(rayHit - position);


	float3 normal = normalize(dot(toHit, cylX)*cylX + dot(toHit, cylY)*cylY);

	float3 refractedRay = refract(rayDir, -normal, indice);
	float3 perceivedPoint = RayCastCylinder(end, -refractedRay, axis, position, radius);

	float3 newRay = perceivedPoint - start;
	float3 newDir = normalize(newRay);

	return start + newDir * rayLength;

}


float3 GetRefractedPoint(float3 planeNormal, float3 position, float3 start, float3 end, float indice)
{
	//float planeDist = dot(position - start, planeNormal);
	float3 ray = end - start;
	float3 rayDir = normalize(ray);
	float needRefract = step(dot(rayDir, planeNormal), 0.0f); // direction check
	needRefract *= step(dot(end - position, planeNormal), 0.0f); // object position check
	needRefract *= step(dot(start - position, -planeNormal), 0.0f); // camera position check
	if (needRefract < 0.5f)
		return end;



	float rayLength = length(ray);
	float3 refractedRay = refract(rayDir, planeNormal, indice);

	float3 perceivedPoint = RayCastPlane(-planeNormal, position, end, end - refractedRay);

	float3 newRay = perceivedPoint - start;
	float3 newDir = normalize(newRay);

	return start + newDir * rayLength;


}
#endif