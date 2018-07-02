using UnityEngine;
using System.Collections;

[RequireComponent(typeof(LineRenderer))]
public class LaserScriptV2 : MonoBehaviour
{
    public float range = 1000;
    private LineRenderer line;
    public bool playerOnly = true;
    public Transform startPoint;
    public Transform endPoint;
    public int HitDamage = 5;
    public ParticleSystem endEffect;
    Transform endEffectTransform;
    bool canFire = false;

    void Start()
    {
        line = GetComponent<LineRenderer>();
        line.positionCount = 2;
        if(endEffect)
            endEffectTransform = endEffect.transform;
    }
    void Awake()
    {
        InputHandler.OnFireButtonClick+= InputHandler_OnFireButtonClick;
    }

    void InputHandler_OnFireButtonClick (bool flag)
    {
        canFire = flag;
    }
    void Update() // consider void FixedUpdate()
    {
        if (Input.GetKey(KeyCode.F)||canFire)
        {
            RaycastHit hit;
            bool isHit = Physics.Raycast(transform.position, transform.forward, out hit, range); // transform.position + (transform.right * (float)offset) can be used for casting not from center.
            if (isHit)
            {
                Debug.DrawLine(transform.position, hit.point + (transform.forward * range), Color.green);
                line.SetPosition(0, startPoint.position);
                line.SetPosition(1, hit.point);
                line.enabled = true;
                Collider collider = hit.collider;
                if(hit.collider.tag == "Enemy" )
                {
                    Debug.Log ("Hit "+hit.collider.tag);
                    //AudioManager.instance.audioSource.PlayOneShot (AudioManager.instance.explosionClip);
                    // Get the CubeBehavior script to apply damage to target
                    EnemyBehaviorScript cubeCtr = hit.collider.GetComponent<EnemyBehaviorScript>();
                    if ( cubeCtr != null ) {
                        cubeCtr.Hit( HitDamage );
                    }
                }
            }
            else
            {
                line.SetPosition(0, startPoint.position);
                line.SetPosition(1, endPoint.position + (endPoint.forward * range)); // (transform.right * ((float)offset + range)) can be used for casting not from center.
                line.enabled = true;
            }
            if(endEffect){
//                endEffectTransform.position = hit.point;
                if(!endEffect.isPlaying)
                    endEffect.Play();
            }
        }
        else
        {
            if(endEffect){
                if(endEffect.isPlaying)
                    endEffect.Stop();
            }
            line.enabled = false;
        }
    }
    void OnDestroy()
    {
        InputHandler.OnFireButtonClick-= InputHandler_OnFireButtonClick;
    }
}