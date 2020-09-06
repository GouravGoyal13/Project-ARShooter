using UnityEngine;
using System.Collections;

public class Mover : MonoBehaviour 
{
	public enum Orbit{ORB1 = 10,ORB2 = 20,ORB3 = 30};
	public Transform target;
	public int moveSpeed;
	public int rotationSpeed;
	public int maxDistance;
	public Orbit orbit = Orbit.ORB1;
	private Transform myTransform;
	
	void Awake() {
		myTransform = transform;
	}
	
	// Use this for initialization
	void Start () {
		GameObject go = GameObject.FindGameObjectWithTag("MainCamera");
		target = go.transform;
		maxDistance = (int)orbit;
	}
	
	// Update is called once per frame
	void Update () {
		
		Debug.DrawLine(target.position, myTransform.position, Color.yellow);
		
		//Look at target
		myTransform.rotation = Quaternion.Slerp(myTransform.rotation, Quaternion.LookRotation(target.position - myTransform.position), rotationSpeed * Time.deltaTime);
		
		if(Vector3.Distance(target.position, myTransform.position) > maxDistance) {
			//Move towards target
			myTransform.position += myTransform.forward * moveSpeed * Time.deltaTime;
		}
	}


}
