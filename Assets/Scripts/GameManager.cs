using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour {
	public static GameManager instance;
	public bool showDebugLog;
	public bool canFire;
	private int score;

	public int Score {
		get {
			return score;
		}
		set {
			score = value;
			string formatedScore = string.Format("Score : {0}",score);
			InputHandler.instance.scoreText.text = formatedScore;
		}
	}

	// Use this for initialization
	void Start () {
		if (instance == null)
			instance = this;
	}
}
