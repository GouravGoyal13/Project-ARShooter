using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class test : MonoBehaviour {
	Image sprite;
	// Use this for initialization
	void Start () {
		sprite = transform.GetComponent<Image> ();
	}
	
	// Update is called once per frame
	public void Pressed (object obj) {
		sprite.color = Color.red;
	}
	public void Released () {
		sprite.color = Color.green;

	}

}
