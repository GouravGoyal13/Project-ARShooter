using UnityEngine;
using System.Collections;

// We'll need to use Vuforia package to
// make sure that everything is working
using Vuforia;
using UnityEngine.UI;

public class SpawnScript : MonoBehaviour {  

	public Canvas canvas;
	public GameObject healthBarPrefab;
	// Cube element to spawn
	public GameObject[] mEnemy;

	//Enemy Spawn distance from player
	public int mEnemyDistance;

	// Qtd of Cubes to be Spawned
	public int mTotalEnemiesInAWave      = 10;

	// Time to spawn the Cubes
	public float mTimeToSpawn   = 1f;

	// hold all cubes on stage
	private GameObject[] mCubes;

	// define if position was set
	private bool mPositionSet;
	// Define the position if the object
	// according to ARCamera position
	private bool SetPosition()
	{
		// get the camera position
		Transform cam = Camera.main.transform;

		// set the position 10 units forward from the camera position
		transform.position = cam.forward * 10;
		return true;
	}
	// Loop Spawning cube elements
	private IEnumerator SpawnLoop() 
	{
		// Defining the Spawning Position
		StartCoroutine( ChangePosition() );

		yield return new WaitForSeconds(0.2f);

		// Spawning the elements
		int i = 0;
		while ( i <= (mTotalEnemiesInAWave-1) ) {

			mCubes[i] = SpawnElement();
			i++;
			yield return new WaitForSeconds(Random.Range(mTimeToSpawn, mTimeToSpawn*3));
		}
	}

	// Spawn a cube
	private GameObject SpawnElement() 
	{
		// spawn the element on a random position, inside a imaginary sphere
		Vector3 spawnPosition = (Random.insideUnitSphere*mEnemyDistance) + transform.position;
		spawnPosition = new Vector3 (spawnPosition.x, spawnPosition.y, Mathf.Abs (spawnPosition.z));
		GameObject cube = Instantiate(mEnemy[Random.Range(0,mEnemy.Length)], spawnPosition, transform.rotation ) as GameObject;
		cube.GetComponent<EnemyBehaviorScript> ().healthBar = SpawnHealthBar (cube);
		// define a random scale for the cube
		float scale = Random.Range(0.5f, 2f);
		// change the cube scale
		cube.transform.localScale = new Vector3( scale, scale, scale );
		return cube;
	}

	Healthbar SpawnHealthBar(GameObject enemy)
	{
		GameObject healthPanel = Instantiate(healthBarPrefab) as GameObject;
		healthPanel.transform.SetParent(canvas.transform, false);
		Healthbar healthBar = healthPanel.GetComponent<Healthbar> ();
		healthBar.TargetObject = enemy.transform;
		healthBar.MaxHP = 100;
		healthBar.HealthSliderMaxValue = 100;
		return healthBar;
	}

	void Start () {
		// Initializing spawning loop
		StartCoroutine( SpawnLoop() );

		// Initialize Cubes array according to
		// the desired quantity
		mCubes = new GameObject[ mTotalEnemiesInAWave ];
	}

	// We'll use a Coroutine to give a little
	// delay before setting the position
	private IEnumerator ChangePosition() {

		yield return new WaitForSeconds(0.2f);
		// Define the Spawn position only once
		if ( !mPositionSet ){
			// change the position only if Vuforia is active
			if ( VuforiaBehaviour.Instance.enabled )
				SetPosition();
		}
	}
}