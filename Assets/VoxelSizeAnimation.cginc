#ifndef VoxelSizeAnimation_INCLUDED
#define VoxelSizeAnimation_INCLUDED

#define PI 3.141592

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;
float3 _EmissionColor;
float _Size;
float _Distance;
float _Density;
float _Speed;
float4 _EffectVector;

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct g2f
{
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float2 edge : TEXCOORD2;
	float4 vertex : SV_POSITION;
};

struct vData
{
	float3 pos;
	float2 uv;
	float3 normal;
	float2 edge;
};

vData SetVData(float3 center, float3 posVec, float dist, float2 uv)
{
	vData v;
	v.pos = center + posVec * dist * _Size;
	v.uv = TRANSFORM_TEX(uv, _MainTex);

	return v;
}

g2f SetVertex(vData data)
{
	g2f o;
	o.vertex.xyz = data.pos;
	o.vertex = UnityWorldToClipPos(o.vertex);
	o.uv = data.uv;
	o.normal = data.normal;
	o.edge = data.edge;
	return o;
}

appdata vert(appdata v)
{
	v.vertex = mul(unity_ObjectToWorld, v.vertex);
	return v;
}

[maxvertexcount(24)]
void geom(triangle appdata input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> triStream)
{
	#define ADDV(v, n, e) v.normal = n; v.edge = e; triStream.Append(SetVertex(v))

	float3 center = (input[0].vertex + input[1].vertex + input[2].vertex).xyz / 3;

	float param = dot(_EffectVector.xyz, center) - _EffectVector.w;
	param = saturate(1 - param);

	if (param == 0) return;

	uint seed = pid * 877;
	if (Random(seed) > _Density) return;

	float dist0 = distance(input[0].vertex.xyz, center);
	float dist1 = distance(input[1].vertex.xyz, center);
	float dist2 = distance(input[2].vertex.xyz, center);
	float dist = (dist0 + dist1 + dist2) / 3;

	float3 vec1 = (input[1].vertex - input[0].vertex).xyz;
	float3 vec2 = (input[2].vertex - input[0].vertex).xyz;
	float3 nor = normalize(cross(vec1, vec2));

	float2 uv = (input[0].uv + input[1].uv + input[2].uv) / 3;
	
	float time = _Time.y * _Speed;
	float randX = abs(sin(2 * Random2(input[0].uv) * PI + time));
	float randY = abs(sin(2 * Random2(input[1].uv) * PI + time));
	float randZ = abs(sin(2 * Random2(input[2].uv) * PI + time));

	float3 leftFront = float3(-randX, randY, -randZ);
	float3 leftBack = float3(-randX, randY, randZ);
	float3 rightFront = float3(randX, randY, -randZ);
	float3 rightBack = float3(randX, randY, randZ);

	vData v[4][2];

	center += nor * _Distance;
	_Size *= saturate(smoothstep(0, 0.5, param) * 2);

	v[0][0] = SetVData(center, leftFront, dist, uv);
	v[1][0] = SetVData(center, leftBack, dist, uv);
	v[2][0] = SetVData(center, rightFront, dist, uv);
	v[3][0] = SetVData(center, rightBack, dist, uv);
	v[0][1] = SetVData(center, leftFront * float3(1.0, -1.0, 1.0), dist, uv);
	v[1][1] = SetVData(center, leftBack * float3(1.0, -1.0, 1.0), dist, uv);
	v[2][1] = SetVData(center, rightFront * float3(1.0, -1.0, 1.0), dist, uv);
	v[3][1] = SetVData(center, rightBack * float3(1.0, -1.0, 1.0), dist, uv);

	// 上
	ADDV(v[2][0], float3(0, 1, 0), float2(0, 0));
	ADDV(v[0][0], float3(0, 1, 0), float2(1, 0));
	ADDV(v[3][0], float3(0, 1, 0), float2(0, 1));
	ADDV(v[1][0], float3(0, 1, 0), float2(1, 1));
	triStream.RestartStrip();
	// 右
	ADDV(v[2][1], float3(1, 0, 0), float2(0, 0));
	ADDV(v[2][0], float3(1, 0, 0), float2(1, 0));
	ADDV(v[3][1], float3(1, 0, 0), float2(0, 1));
	ADDV(v[3][0], float3(1, 0, 0), float2(1, 1));
	triStream.RestartStrip();
	// 左
	ADDV(v[0][0], float3(-1, 0, 0), float2(0, 0));
	ADDV(v[0][1], float3(-1, 0, 0), float2(1, 0));
	ADDV(v[1][0], float3(-1, 0, 0), float2(0, 1));
	ADDV(v[1][1], float3(-1, 0, 0), float2(1, 1));
	triStream.RestartStrip();
	// 奥
	ADDV(v[1][1], float3(0, 0, 1), float2(0, 0));
	ADDV(v[3][1], float3(0, 0, 1), float2(1, 0));
	ADDV(v[1][0], float3(0, 0, 1), float2(0, 1));
	ADDV(v[3][0], float3(0, 0, 1), float2(1, 1));
	triStream.RestartStrip();
	// 手前
	ADDV(v[2][1], float3(0, 0, -1), float2(0, 0));
	ADDV(v[0][1], float3(0, 0, -1), float2(1, 0));
	ADDV(v[2][0], float3(0, 0, -1), float2(0, 1));
	ADDV(v[0][0], float3(0, 0, -1), float2(1, 1));
	triStream.RestartStrip();
	// 下
	ADDV(v[0][1], float3(0, -1, 0), float2(0, 0));
	ADDV(v[2][1], float3(0, -1, 0), float2(1, 0));
	ADDV(v[1][1], float3(0, -1, 0), float2(0, 1));
	ADDV(v[3][1], float3(0, -1, 0), float2(1, 1));
	triStream.RestartStrip();	
}

fixed4 frag(g2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv) * _Color;
	float2 bcc = i.edge;
	float2 fw = fwidth(bcc);
	float2 edge2 = min(smoothstep(fw / 2, fw, bcc),
		smoothstep(fw / 2, fw, 1 - bcc));
	float edge = 1 - min(edge2.x, edge2.y);

	col.xyz += _EmissionColor * edge;
	return col;
}
#endif