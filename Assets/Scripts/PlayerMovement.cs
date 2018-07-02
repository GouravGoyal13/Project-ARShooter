using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerMovement : MonoBehaviour {
	public float speed = 1.0f;
	Vector3 centerPosition=new Vector3(0,0,0);
//	Vector3 centerPosition;
	bool LerpedUp=false;
	float LerpTime=1.0f;
	bool canDodgeLeft;
	bool canDodgeRight;
	void Awake()
	{
	}

	void Start()
	{
//		centerPosition = transform.position;
	}

	void Update()   
	{ 
		//If HoldOn Right Mousebutton,Move from Point A to B  
		if(canDodgeLeft) 
		{
			if(!LerpedUp)
			{
				//Reset LerpTime
				LerpTime=0.0f;
				//State Lerping Up(A to B)
				LerpedUp=true;
			}         
			else if(LerpTime<1.0f)
			{         
				transform.position = Vector3.Lerp(transform.position , transform.position+Vector3.left,LerpTime); 
				LerpTime+=Time.deltaTime*speed;
			}

		}  
		else if(canDodgeRight) 
		{
			if(!LerpedUp)
			{
				//Reset LerpTime
				LerpTime=0.0f;
				//State Lerping Up(A to B)
				LerpedUp=true;
			}         
			else if(LerpTime<1.0f)
			{         
				transform.position = Vector3.Lerp(transform.position , transform.position+Vector3.right,LerpTime);          
				LerpTime+=Time.deltaTime*speed;
			}

		}  
		else//If released Right Mousebutton,Move from Point B to A
		{
			if(LerpedUp)
			{
				//Reset LerpTime
				LerpTime=0.0f;
				//State Lerping Down(B to A)
				LerpedUp=false;
			}         
			else if(LerpTime<1.0f)
			{
				transform.position = Vector3.Lerp(transform.position, centerPosition , LerpTime);
				LerpTime+=Time.deltaTime*speed;
			}
		} 
	} 
	void LateUpdate()
	{
		Vector3 pos = transform.position;
		pos.x = Mathf.Clamp(pos.x, -6, 6);
		transform.localPosition = pos;
	}

	void OnDestroy()
	{
	}
}
