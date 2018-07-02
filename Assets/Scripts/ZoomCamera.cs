using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ZoomCamera : MonoBehaviour {
    public Slider ZoomSlider;
    public GameObject ZoomUI;
    public Camera ARCamera;
    public Camera ScopeCamera;
    bool canZoom;
    int initialFOV;
    void Start()
    {
        InputHandler.OnZoomButtonClick+= InputHandler_OnZoomButtonClick;
    }

    void InputHandler_OnZoomButtonClick (bool flag)
    {
        canZoom = !canZoom;
        ScopeCamera.fieldOfView = ARCamera.fieldOfView;
        initialFOV =(int) ScopeCamera.fieldOfView;
        ScopeCamera.gameObject.SetActive(canZoom);
        ZoomUI.SetActive(canZoom);
        ScopeCamera.depth = canZoom?1f:0f;
        ARCamera.LayerCullingToggle(5,canZoom);
        ARCamera.LayerCullingToggle(9,canZoom);
        ScopeCamera.LayerCullingToggle(8, canZoom);
        ZoomSlider.onValueChanged.AddListener(delegate {ChangeFOV(); });
    }
   
    void ChangeFOV(){
        ScopeCamera.fieldOfView = (initialFOV+ZoomSlider.value)*2;
    }
}
