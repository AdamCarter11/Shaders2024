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
        // subshader tags
        Tags { 
                "RenderType" = "Transparent" // set this to "Opaque" if we don't want it transparent, or "Transparent" if we do want it transparent. Used for post processing
                "Queue" = "Transparent" // don't need this if opaque but this is needed if transparent so that it doesn't always show up behind everything else. This changes render order
    
            } 
        LOD 100 // basically never used but controls height level?

        Pass // graphics related stuff for this specic pass
        {
            // pass tags

            // Blending modes (defined before CGPROGRAM
            // adding this here applies the blend to this whole shader
            // blendings formula looks like this: (src * A +/- dst * B) src = source, dst = destination, A/B +/- are values we can change
            // so an additive blend would use (src * 1 + dst * 1)
            // Multiply blend: (src * dst + dst * 0), so A is holding dst, to simplify: src * dst
            // when using transparent objects, we have to make it not write to the depth buffer so we can actually see behind it
            // depth buffer is basically a way to not render objects that are behind other objects

            //Cull Back // default value, it will cull the backside of the object, fine for opaque objects
            //Cull Front // Culls the front of the object
            Cull Off  // turns culling off, good for transparent objs
            ZWrite off // makes it NOT write to the depth buffer, ie, it's see through, but makes it always look like it's behind everything else
            //ZTest LEqual // default value, if depth of this obj is <= the depth already written into the depth buffer, show it, otherwise, don't, ie, if obj is in other obj, don't show
            //ZTest Always // means obj is always showing, even if inside or behind other objs
            //ZTest GEqual // only draw if behind something
            Blend One One // additive blend
            //Blend DstColor Zero // multiply blend
            
            // anything inside CGPROGRAM to ENDCG is part of the shader code
            CGPROGRAM
            #pragma vertex vert // tells compiler what function is the vertex shader
            #pragma fragment frag // tells compiler what function is the fragment shader

            // make fog work
            //#pragma multi_compile_fog // I'm ignoring fog in this file

            #include "UnityCG.cginc"
            
            // preprocessor define
            #define TAU 6.28318530718 // this basically just means wherever we see TAU, replace it with the number

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
                //float4 tangent : TANGENT; // tangent direction (xyz) tangent sign (w) 
                //float4 color : COLOR; // vertex colors
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

            // usually you have more frags (pixels) than you do vertices, so you want to try and do as much as you can in the vertex shader rather than the frag shader for optimization
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
                //float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x)); // saturate is basically clamping, if less than 0 set to 0, if more than 1, set to 1
                // frac = someVal - floor(someVal) (can be used to check if things need clamping)
                //t = frac(t);
                //float4 outputColor = lerp(_ColorA, _ColorB, t);
                //return outputColor;

                // Unity has a built in time var called _Time.xyzw (xyzw are different scales of time, y is seconds)
                //_Time.y

                float xOffset = cos(i.uv.x * TAU * 8) * .01; // this makes the lines wavy vertically
                // by adding time to the offset, we are moving the lines based on time, creating a spinning effect
                float t = cos((i.uv.y + xOffset - _Time.y * .1f) * TAU * 5) * .5 + .5; // this creates lines from -1 to 1 repeating (5, .5, .5 are just offseting values)
                // we can then make this have a fade out effect
                t *= 1 - i.uv.y;
                float topBottomRemover = (abs(i.normal.y) < .999); // basically remove all the flat faces facing up/down
                float waves = t * topBottomRemover;
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                return waves * gradient;
            }
            ENDCG
        }
    }
}


