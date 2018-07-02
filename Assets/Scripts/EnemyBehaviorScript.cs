using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class EnemyBehaviorScript : MonoBehaviour {
	//Enemy Orbits
	public enum Orbit{ORB1 = 30,ORB2 = 50,ORB3 = 70};
	public Orbit orbit = Orbit.ORB1;

	//Enemy Particle Effect
	public GameObject Explosion;

	// Cube's Max/Min scale
	public float mScaleMax  = 2f;
	public float mScaleMin  = 0.5f;

	//Max distance from Orbit
	public int mOrbitMaxDistance;

	// Orbit max Speed
	public float mOrbitMaxSpeed = 30f;

	// Orbit speed
	private float mOrbitSpeed;

	// Anchor point for the Cube to rotate around
	private Transform mOrbitAnchor;

	// Orbit direction
	private Vector3 mOrbitDirection;

	// Max Cube Scale
	private Vector3 mCubeMaxScale;

	// Growing Speed
	public float mGrowingSpeed  = 10f;
	private bool mIsCubeScaled  = false;
	public int maxHealth  =100;
	public Healthbar healthBar;

	void Start () {
		CubeSettings();
		mOrbitMaxDistance = (int)orbit;
	}

	// Set initial cube settings
	private void CubeSettings(){
		// defining the anchor point as the main camera
		mOrbitAnchor = Camera.main.transform;

		// defining the orbit direction
		float x = Random.Range(0f,0f);
		float y = Random.Range(0f,0f);
		float z = Random.Range(-1f,1f);
		mOrbitDirection = new Vector3( x, y , z );

		// defining speed
		mOrbitSpeed = Random.Range( 5f, mOrbitMaxSpeed );

		// defining scale
		float scale = Random.Range(mScaleMin, mScaleMax);
		mCubeMaxScale = new Vector3( scale, scale, scale );

		// set cube scale to 0, to grow it lates
		transform.localScale = Vector3.zero;
	}
	// Update is called once per frame
	void Update () {
		// makes the cube orbit and rotate
		MoveEnemy();
		// scale cube if needed
		if ( !mIsCubeScaled )
			ScaleObj();
	}

	void MoveEnemy()
	{
		Debug.DrawLine(mOrbitAnchor.position, transform.position, Color.yellow);

		//Look at target
		transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(mOrbitAnchor.position - transform.position), mOrbitSpeed * Time.deltaTime);
		if (Vector3.Distance (mOrbitAnchor.position, transform.position) > mOrbitMaxDistance) {
			//Move towards target
			transform.position += transform.forward * mOrbitMaxSpeed * Time.deltaTime;
		} else {
			RotateCube ();
		}
	}

	// Scale object from 0 to 1
	private void ScaleObj(){

		// growing obj
		if ( transform.localScale != mCubeMaxScale )
			transform.localScale = Vector3.Lerp( transform.localScale, mCubeMaxScale, Time.deltaTime * mGrowingSpeed );
		else
			mIsCubeScaled = true;
	}

	// Makes the cube rotate around a anchor point
	// and rotate around its own axis
	private void RotateCube(){
		// rotate cube around camera
		transform.RotateAround(
			mOrbitAnchor.position, mOrbitDirection, mOrbitSpeed * Time.deltaTime);

		// rotating around its axis
		transform.Rotate( mOrbitDirection * 30 * Time.deltaTime);
//		transform.rotation = new Quaternion(Mathf.Abs(transform.rotation.w),Mathf.Abs(transform.rotation.x),Mathf.Abs(transform.rotation.y),Mathf.Abs(transform.rotation.z));
	}
	// Cube Health
	public int mEnemyHealth  = 100;

	// Define if the Cube is Alive
	private bool mIsAlive       = true;

	// Cube got Hit
	// return 'false' when cube was destroyed
	public bool Hit( int hitDamage ){
		Debug.Log (string.Format( "Hit Damage {0}-- Enemy Health {1}---- EnemyName {2}",hitDamage,mEnemyHealth,gameObject.name));
		mEnemyHealth -= hitDamage;
		healthBar.HealthSliderValue = mEnemyHealth;
		if ( mEnemyHealth <= 0 && mIsAlive ) {
			StartCoroutine( DestroyCube());
			return true;
		}
		return false;
	}

	// Destroy Cube
	private IEnumerator DestroyCube(){
		mIsAlive = false;
		Destroy (healthBar.gameObject);
		//AudioManager.instance.audioSource.PlayOneShot (AudioManager.instance.explosionClip);
		// Make the cube desappear
		GetComponent<Renderer>().enabled = false;
//		Explosion.SetActive (true);
		// we'll wait some time before destroying the element
		// this is usefull when using some kind of effect
		// like a explosion sound effect.
		// in that case we could use the sound lenght as waiting time
		if(GameManager.instance!=null)
		{
			GameManager.instance.Score +=10; 
		}
		Debug.Log ("Destroying "+gameObject.name);
		Destroy(gameObject);
		yield return null;
	}
}