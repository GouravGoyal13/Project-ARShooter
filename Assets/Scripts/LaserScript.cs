using UnityEngine;
using System.Collections;

public class LaserScript : MonoBehaviour {

	public float mFireRate  = .5f;
	public float mFireRange = 50f;
	public float mHitForce  = 100f;
	public int mLaserDamage = 100;

	// Line render that will represent the Laser
	private LineRenderer mLaserLine;

	// Define if laser line is showing
	private bool mLaserLineEnabled;

	// Time that the Laser lines shows on screen
	private WaitForSeconds mLaserDuration = new WaitForSeconds(0.05f);

	// time of the until the next fire
	private float mNextFire;
	Transform cam;
	// Use this for initialization
	void Start () {
		cam = Camera.main.transform;
		mLaserLine = GetComponent<LineRenderer>();
	}
	// Shot the Laser
	private void Fire(){
		// Hold the Hit information
		RaycastHit hit;
		// Get ARCamera Transform

		// Define the time of the next fire
		mNextFire = Time.time + mFireRate;

		// Set the origin of the RayCast
		Vector3 rayOrigin = cam.position;
		// Checks if the RayCast hit something
		if ( Physics.Raycast( rayOrigin, cam.forward, out hit, mFireRange )){

			mLaserLine.SetPosition(1, hit.point );
			// Set the end of the Laser Line to the object hitted
			Debug.Log("laser hit"+hit.point);
			AudioManager.instance.audioSource.PlayOneShot (AudioManager.instance.explosionClip);
			// Get the CubeBehavior script to apply damage to target
			EnemyBehaviorScript cubeCtr = hit.collider.GetComponent<EnemyBehaviorScript>();
			if ( cubeCtr != null ) {
				if ( hit.rigidbody != null ) {
					// apply force to the target
					hit.rigidbody.AddForce(-hit.normal*mHitForce);
					// apply damage the target
					cubeCtr.Hit( mLaserDamage );
				}
			}
		}
		// Show the Laser using a Coroutine
		StartCoroutine(LaserFx());
	}
	// Update is called once per frame
	void Update () {
		if (GameManager.instance.canFire && Time.time > mNextFire ){
			GameManager.instance.canFire = false;
			Fire();
		}    
	}
	// Show the Laser Effects
	private IEnumerator LaserFx(){
		mLaserLine.enabled = true;

		// Way for a specific time to remove the LineRenderer
		yield return mLaserDuration;
		mLaserLine.enabled = false;
	}
}