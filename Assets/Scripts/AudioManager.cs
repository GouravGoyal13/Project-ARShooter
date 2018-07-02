using UnityEngine;
using System.Collections;

public class AudioManager : MonoBehaviour
{
	public static AudioManager instance;
	public AudioClip fireClip;
	public AudioClip explosionClip;
	public AudioSource audioSource;
	void Start(){
		if (instance == null)
			instance = this;
	}
}