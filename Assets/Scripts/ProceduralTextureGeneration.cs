using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour {

	public Material material = null;

	#region Material properties
	[SerializeField, SetProperty("textureWidth")]
	private int m_textureWidth = 512;

	public int textureWidth {
		get {
			return m_textureWidth;
		}
		set {
			m_textureWidth = value;
			_UpdateMaterial();
		}
	}
	
	[SerializeField, SetProperty("backgroundColor")]
	private Color m_backgroundColor = Color.white;

	public Color backgroundColor {
		get {
			return m_backgroundColor;
		}
		set {
			m_backgroundColor = value;
			_UpdateMaterial();
		}
	}

	#endregion

	private Texture2D m_generatedTexture = null;


	// Use this for initialization
	void Start () {
		
	}

	private void _UpdateMaterial() {
		if (material != null) {
			m_generatedTexture = _GenerateProceduralTexture();
			material.SetTexture("_MainTex", m_generatedTexture);
		}
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
