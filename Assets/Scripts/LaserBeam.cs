
//This is free to use and no attribution is required
//No warranty is implied or given
using UnityEngine;
using System.Collections;
using UnityEngine.UI;

[RequireComponent (typeof(LineRenderer))]

public class LaserBeam : MonoBehaviour {

	public float laserWidth = 1.0f;
	public float noise = 1.0f;
	public float maxLaserLength = 50.0f;
	public float maxRayLength = 100.0f;
	public Color color = Color.red;
	bool canFire;
	LineRenderer lineRenderer;
	int length;
	Vector3[] position;
	//Cache any transforms here
	Transform myTransform;
	Transform endEffectTransform;
	//The particle system, in this case sparks which will be created by the Laser
	public ParticleSystem endEffect;
	Vector3 offset;
	public float HitForce = 2;
	public int HitDamage = 5;
	public bool useLineRenderer;
	Transform camTransform;
	void Awake()
	{
		InputHandler.OnFireButtonClick+= InputHandler_OnFireButtonClick;
	}

	void InputHandler_OnFireButtonClick (bool flag)
	{
		canFire = flag;
	}


	// Use this for initialization
	void Start () {
		camTransform = Camera.main.transform;
		if (useLineRenderer) {
			lineRenderer = GetComponent<LineRenderer> ();
			lineRenderer.startWidth = laserWidth;
			lineRenderer.endWidth = laserWidth;
			myTransform = transform;
			offset = new Vector3 (0, 0, 0);
		}
//		endEffect = GetComponentInChildren<ParticleSystem>();
		if(endEffect)
			endEffectTransform = endEffect.transform;
	}

	// Update is called once per frame
	void Update () 
	{
		if (canFire) {
			UpdateLength();
			if (useLineRenderer) {
				lineRenderer.enabled = true;
				RenderLaser ();
			}
		} else {
			if (useLineRenderer) {
				lineRenderer.enabled = false;
			}
		}
	}

	void RenderLaser(){

		//Shoot our laserbeam forwards!
		lineRenderer.startColor = color;
		lineRenderer.endColor = color;
		//Move through the Array
		for(int i = 0; i<length; i++){
			//Set the position here to the current location and project it in the forward direction of the object it is attached to
			offset.x =myTransform.position.x+i*myTransform.forward.x+Random.Range(-noise,noise);
			offset.z =i*myTransform.forward.z+Random.Range(-noise,noise)+myTransform.position.z;
			position[i] = offset;
			position[0] = myTransform.position;

			lineRenderer.SetPosition(i, position[i]);

		}

	}

	void UpdateLength(){
		//Raycast from the location of the cube forwards
		RaycastHit[] hit;
		hit = Physics.RaycastAll(camTransform.position, camTransform.forward, maxRayLength);
		int i = 0;
		while(i < hit.Length){
			Debug.DrawLine (camTransform.position, hit [i].point,Color.green);
			//Check to make sure we aren't hitting triggers but colliders
			if(hit[i].collider.tag == "Enemy" )
			{
				Debug.Log ("Hit "+hit[i].collider.tag);
				length = (int)Mathf.Round(hit[i].distance)+2;
				position = new Vector3[length];
				AudioManager.instance.audioSource.PlayOneShot (AudioManager.instance.explosionClip);
				// Get the CubeBehavior script to apply damage to target
				EnemyBehaviorScript cubeCtr = hit[i].collider.GetComponent<EnemyBehaviorScript>();
				if ( cubeCtr != null ) {
					cubeCtr.Hit( HitDamage );
				}
				//Move our End Effect particle system to the hit point and start playing it
				if(endEffect){
					endEffectTransform.position = hit[i].point;
					if(!endEffect.isPlaying)
						endEffect.Play();
				}

				if(useLineRenderer)
					lineRenderer.positionCount = length;
				return;
			}
			i++;
		}
		//If we're not hitting anything, don't play the particle effects
		if(endEffect){
			if(endEffect.isPlaying)
				endEffect.Stop();
		}
		length = (int)maxLaserLength;
		position = new Vector3[length];
		if(useLineRenderer)
			lineRenderer.positionCount = length;
	}
}