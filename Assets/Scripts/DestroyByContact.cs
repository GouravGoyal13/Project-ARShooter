using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyByContact : MonoBehaviour {
	public string[] contacts;
	// Use this for initialization
	void Start () {
		
	}
	
	void OnTriggerEnter (Collider other)
	{
		foreach (string contact in contacts) {
			if (other.tag == contact) {
				Destroy (gameObject);//destroy object the script attached to
			}
		}

	}

}
