Shader "Unlit/UnlitShader"
{
    Properties // input data
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Value("Value", Float) = 1.0
    }
        SubShader
    {
        // more render pipeline related
        Tags { "RenderType" = "Opaque" }
        LOD 100 // basically never used

        Pass // graphics related stuff for this specic pass
        {
            // anything inside CGPROGRAM to ENDCG is part of the shader code
            CGPROGRAM
            #pragma vertex vert // tells compiler what function is the vertex shader
            #pragma fragment frag // tells compiler what function is the fragment shader

            // make fog work
            //#pragma multi_compile_fog // I'm ignoring fog in this file

            #include "UnityCG.cginc"

            float _Value; // created on line 6, value is gotten from inspector

            struct MeshData // meshData is normally named appData. This is per vertex mesh data
            {
                // float3 is the direction (vector3), but a float4 has direction + sign information (whether it's mirrored)
                float4 vertex : POSITION; // vertex position. We are passing data from POSITION (compiler specific) into variable named vertex
                //float3 normals : NORMAL;
                //float4 tangent : TANGENT;
                //float4 color : COLOR;
                float2 uv : TEXCOORD0;  // UV cordinates. same as vertex but this can be duplicated for 0,1,2,etc. Often UV data is just data
            };

            struct v2f // can be thought of as interpolaters a lot of the time
            {
                float2 uv : TEXCOORD0; // any data you want it to be
                //UNITY_FOG_COORDS(1) // ignoring fog for now
                float4 vertex : SV_POSITION; // clip space position
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            v2f vert (MeshData v) // meshData is normally named appData
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // multiplying by the mvp (model view projection) matrix. Converts local space to clip space
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex); //ignore for now
                // UNITY_TRANSFER_FOG(o,o.vertex); //ignore for now
                return o;
            }

            // you can have bool and int, but 99% of the time we will use float
            // float4 is like a vector4 (32 bit float), rarely need to use this
            // shaders also have half (16 bit float), most things work with this
            // shaders also have fixed (12 bit float), this is almost never used. Really only useful from the -1 to 1 range
            // float can be a matrix by saying float4x4 (matrix4x4)

            float4 frag (v2f i) : SV_Target // this initially was fixed4, not float4
            {
                // sample the texture
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv); // ignoring textures for now
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col); // ignore fog for now
                return float4(1,0,0,1); // was return col; // float4(1,0,0,1) r,g,b,a
            }
            ENDCG
        }
    }
}
