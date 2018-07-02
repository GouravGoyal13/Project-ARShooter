using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Healthbar : MonoBehaviour {
	public Transform TargetObject;
	Slider healthBar;
	public float healthPanelOffset;
	Color minColor = Color.red;
	Color maxColor = Color.green;
	private int maxHP;
	public bool Lerp;
    Transform cameraTranform;
	public int HealthSliderValue {
		get{ return (int)healthBar.value; }
		set{ healthBar.value = value; }
	}

	public int HealthSliderMaxValue {
		get{ return (int)healthBar.maxValue; }
		set{ healthBar.maxValue = value; }
	}


	public int MaxHP {
		get { return maxHP; }
		set { maxHP = value; }
	}
	// Use this for initialization
	void Awake () {
        cameraTranform = Camera.main.transform;
		healthBar = transform.GetComponent<Slider> ();
	}
	
	// Update is called once per frame
	void Update () {
		if (healthBar != null) {
			Vector3 worldPos = new Vector3 (TargetObject.position.x, TargetObject.position.y + healthPanelOffset, TargetObject.position.z);
			Vector3 screenPos = Camera.main.WorldToScreenPoint (worldPos);
			transform.position = new Vector3 (worldPos.x, worldPos.y, worldPos.z);
            transform.LookAt(cameraTranform);
			if(Lerp)
			healthBar.fillRect.GetComponent<Image> ().color = Color.Lerp (minColor, maxColor, (float)healthBar.value / MaxHP);
		}
	}
}
