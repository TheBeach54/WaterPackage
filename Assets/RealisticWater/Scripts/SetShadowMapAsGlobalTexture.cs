using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class SetShadowMapAsGlobalTexture : MonoBehaviour
{
    public string textureSemanticName = "_SunCascadedShadowMap";
#if UNITY_EDITOR
    public bool reset;
#endif

    private RenderTexture shadowMapRenderTexture;
    private CommandBuffer commandBuffer;
    private Light lightComponent;

    void OnEnable()
    {
        lightComponent = GetComponent<Light>();
        SetupCommandBuffer();
        Shader.SetGlobalTexture("_SunCascadedShadowMap", shadowMapRenderTexture);
    }

    void OnDisable()
    {
        lightComponent.RemoveCommandBuffer(LightEvent.AfterShadowMap, commandBuffer);
        ReleaseCommandBuffer();
    }


    void Update()
    {

#if UNITY_EDITOR
        if (reset)
        {
            OnDisable();
            OnEnable();
            reset = false;
        }
#endif
    }



    void SetupCommandBuffer()
    {
        commandBuffer = new CommandBuffer();

        RenderTargetIdentifier shadowMapRenderTextureIdentifier = BuiltinRenderTextureType.CurrentActive;
        commandBuffer.SetGlobalTexture(textureSemanticName, shadowMapRenderTextureIdentifier);
       

        lightComponent.AddCommandBuffer(LightEvent.AfterShadowMap, commandBuffer);
    }

    void ReleaseCommandBuffer()
    {
        commandBuffer.Clear();
    }
}
