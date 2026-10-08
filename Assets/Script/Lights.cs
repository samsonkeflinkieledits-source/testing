using UnityEngine;

public class Lights : MonoBehaviour
{

    [SerializeField] public float roationSpeed = 10f;
    
    void Update()
    {
        transform.Rotate(Vector3.right * roationSpeed * Time.deltaTime);
    }
}
