using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InputHandler : MonoBehaviour
{
    public static InputHandler instance;

    public delegate void ButtonClick(bool flag);

    public static event ButtonClick OnFireButtonClick;
    public static event ButtonClick OnZoomButtonClick;

    public GameObject PausePanel;
    public Text scoreText;

    // Use this for initialization
    void Start()
    {
        if (instance == null)
            instance = this;
    }

    public void OnResumeClick()
    {
        if (PausePanel != null)
            Time.timeScale = 1;
        PausePanel.SetActive(false);
    }

    public void OnQuitClick()
    {
        Application.Quit();
    }

    void ToggleDebug()
    {
        if (!GameManager.instance.showDebugLog)
            GameManager.instance.showDebugLog = true;
        else
            GameManager.instance.showDebugLog = false;
    }

    public void OnButtonPressed(string buttonName)
    {
        switch (buttonName)
        {
            case "Fire":
                if (OnFireButtonClick != null)
                    OnFireButtonClick(true);
                Debug.Log("Fire Pressed");
                break;
		
        }
    }

    public void OnButtonReleased(string buttonName)
    {
        switch (buttonName)
        {
            case "Fire":
                if (OnFireButtonClick != null)
                    OnFireButtonClick(false);
                Debug.Log("Fire Released");
                break;
        }
    }

    public void OnPauseClick()
    {
        if (PausePanel != null)
            PausePanel.SetActive(true);
        Time.timeScale = 0;
    }

    public void OnZoomClick(){
        if (OnZoomButtonClick != null)
            OnZoomButtonClick(true);
        Debug.Log("zoom click");
    }

}
