Shader "Unlit/VertexOffset"
{
    Properties // input data
    {
        _Value("Value", Float) = 1.0
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
        _WaveAmplitude("Wave Amplitude", Range(0,.2)) = .1
        _Scale("UV Scale", Float) = 1
        _Offset("UV Offset", Float) = 0
    }
        SubShader
    {
        Tags {
                "RenderType" = "Opaque"

            }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"


            #define TAU 6.28318530718 

            float _Value;
            float4 _ColorA, _ColorB;
            float _ColorStart, _ColorEnd;
            float _Scale;
            float _Offset;
            float _WaveAmplitude;

            struct MeshData
            {

                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f
            {

                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            // functions need to be declared before they can be used
            float GetWave(float2 uv) {
                // multiplying by 2 and subtracting one remaps the values from 0->1 to -1->1
                float2 uvsCentered = uv * 2 - 1;

                float radialDist = length(uvsCentered);

                float wave = cos((radialDist - _Time.y * .1) * TAU * 5) * .5 + .5;
                wave *= 1 - radialDist; // invert radial distance
                return wave;
            }

            v2f vert(MeshData v)
            {
                v2f o;

                // here we are actually affecting the vertices (points on the mode) and changing their position
                // think of how text mesh pro works
                //float wave = cos((v.uv0.y - _Time.y * .1) * TAU * 5);
                //float wave2 = cos((v.uv0.x - _Time.y * .1) * TAU * 5);
                //v.vertex.y = wave * wave2 * _WaveAmplitude;

                v.vertex.y = GetWave(v.uv0) ; // * _WaveAmplitude

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                return o;
            }

            // we defined this func
            float InverseLerp(float a, float b, float v) {
                return((v - a) / (b - a));
            }

            

            float4 frag(v2f i) : SV_Target
            {
                return GetWave(i.uv);
            }

            ENDCG
        }
    }
}


