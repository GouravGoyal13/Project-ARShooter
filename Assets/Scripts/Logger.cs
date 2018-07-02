using UnityEngine;
using System.Collections;

public class Logger : MonoBehaviour
{
	string myLog;
	Queue myLogQueue = new Queue();
	void Start(){
	}

	void OnEnable () {
		Application.logMessageReceived += HandleLog;
	}

	void OnDisable () {
		Application.logMessageReceived -= HandleLog;
	}

	void HandleLog(string logString, string stackTrace, LogType type){
		myLog = logString;
		string newString = "\n [" + type + "] : " + myLog;
		myLogQueue.Enqueue(newString);
		if (type == LogType.Exception)
		{
			newString = "\n" + stackTrace;
			myLogQueue.Enqueue(newString);
		}
		myLog = string.Empty;
		foreach(string mylog in myLogQueue){
			myLog += mylog;
		}
	}

	void OnGUI () {
		if (GameManager.instance.showDebugLog) {

			if (GUILayout.Button ("Clear",GUILayout.Width(Screen.width/4),GUILayout.Height(50))) {
				myLog = string.Empty;
			}
			GUILayout.Label (myLog);
		}
		
	}
}