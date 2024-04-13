Shader "Unlit/UnlitShader"
{
    Properties // input data
    { // these are basically inspector variables (don't forget to define inside pass)
        //_MainTex ("Texture", 2D) = "white" {}
        _Value("Value", Float) = 1.0
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
        _Scale("UV Scale", Float) = 1
        _Offset("UV Offset", Float) = 0
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
            float4 _ColorA, _ColorB; // created inside properties, this allows us to access it in Pass
            float _ColorStart, _ColorEnd;
            float _Scale;
            float _Offset;

            struct MeshData // meshData is normally named appData. This is per vertex mesh data
            {
                // float3 is the direction (vector3), but a float4 has direction + sign information (whether it's mirrored)
                float4 vertex : POSITION; // vertex position. We are passing data from POSITION (compiler specific) into variable named vertex
                float3 normals : NORMAL;
                //float4 tangent : TANGENT;
                //float4 color : COLOR;
                float2 uv0 : TEXCOORD0;  // UV cordinates. same as vertex but this can be duplicated for 0,1,2,etc. Often UV data is just data
            };

            struct v2f // can be thought of as interpolaters a lot of the time
            {
                //float2 uv : TEXCOORD0; // any data you want it to be
                //UNITY_FOG_COORDS(1) // ignoring fog for now
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0; // TEXCOORD0 is just a way to hold data, if you wanted you could do float2 tangent = TEXCOORD1;
                float2 uv : TEXCOORD1;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            // usually you have more frags (pixels) than you do vertices, so you want to try and do as much as you can in the vert rather than the frag for optimization
            v2f vert (MeshData v) // meshData is normally named appData
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // multiplying by the mvp (model view projection) matrix. Converts local space to clip space
                // UnityObjectToWorldNormal converts from object relative to world relative (ie, lighting should be world space not obj space)
                o.normal = UnityObjectToWorldNormal(v.normals); // often you will just pass data through the vertex shader to the fragment shader
                o.uv = v.uv0;//(v.uv0 + _Offset) * _Scale; // currently just a simple pass through
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex); //ignore for now
                // UNITY_TRANSFER_FOG(o,o.vertex); //ignore for now
                return o;
            }

            // we defined this func
            float InverseLerp(float a, float b, float v) {
                return((v-a)/(b - a));
            }

            // you can have bool and int, but 99% of the time we will use float
            // float4 is like a vector4 (32 bit float), rarely need to use this
            // shaders also have half (16 bit float), most things work with this
            // shaders also have fixed (12 bit float), this is almost never used. Really only useful from the -1 to 1 range
            // float can be a matrix by saying float4x4 (matrix4x4)

            // even though this says float4, if we returned a float2 then it will swizzle out the rest of the values, ie, xy -> xyyy
            float4 frag(v2f i) : SV_Target // this initially was fixed4, not float4
            {
                /*
                *   you can cast from a vector4 to a 2 for example
                *       float4 myVal;
                *       float2 otherVal = myVal.xy;
                *   then with swizzling we can assign all values to one for example
                *       float4 otherVal = myVal.xxxx;
                */

                // sample the texture
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv); // ignoring textures for now
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col); // ignore fog for now
                //return float4(i.normal, 1); // was return col; // float4(1,0,0,1) r,g,b,a so this would be red
                // basically blending between two colors based on the X UV coordinate (lerp)
                //float4 outputColor = lerp(_ColorA, _ColorB, i.uv.x);
                //return outputColor;
                //return float4(i.uv, 0, 1);

                // shaders don't clamp lerp values between 0 to 1, so we have to do that otherwise we get other colors
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x)); // saturate is basically clamping, if less than 0 set to 0, if more than 1, set to 1
                // frac = someVal - floor(someVal) (can be used to check if things need clamping)
                t = frac(t);
                float4 outputColor = lerp(_ColorA, _ColorB, t);
                return outputColor;
            }
            ENDCG
        }
    }
}
