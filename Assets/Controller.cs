using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Controller : MonoBehaviour
{
    [SerializeField] float _offset;
    [SerializeField] private Renderer[] _linkedRenderers;

    private MaterialPropertyBlock _sheet;

    Vector4 EffectVector
    {
        get
        {
            var fwd = transform.forward;
            var dist = Vector3.Dot(fwd, transform.position);
            return new Vector4(fwd.x, fwd.y, fwd.z, dist + _offset);
        }
    }

    private void Update()
    {
        if (_linkedRenderers == null || _linkedRenderers.Length == 0) return;
        if (_sheet == null) _sheet = new MaterialPropertyBlock();

        var ev = EffectVector;

        foreach (var renderer in _linkedRenderers)
        {
            renderer.GetPropertyBlock(_sheet);
            _sheet.SetVector("_EffectVector", ev);
            renderer.SetPropertyBlock(_sheet);
        }
    }

    #if UNITY_EDITOR

    Mesh _gridMesh;

    void OnDestroy()
    {
        if (_gridMesh != null)
        {
            if (Application.isPlaying)
                Destroy(_gridMesh);
            else
                DestroyImmediate(_gridMesh);
        }
    }

    void OnDrawGizmos()
    {
        if (_gridMesh == null) InitGridMesh();

        Gizmos.matrix = transform.localToWorldMatrix;

        var p = Vector3.forward * (_offset + 1);

        Gizmos.color = new Color(1, 1, 0, 0.5f);
        Gizmos.DrawWireMesh(_gridMesh, p);
    }

    void InitGridMesh()
    {
        const float ext = 0.5f;
        const int columns = 10;

        var vertices = new List<Vector3>();
        var indices = new List<int>();

        for (var i = 0; i < columns + 1; i++)
        {
            var x = ext * (2.0f * i / columns - 1);

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, -ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(x, +ext, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(-ext, x, 0));

            indices.Add(vertices.Count);
            vertices.Add(new Vector3(+ext, x, 0));
        }

        _gridMesh = new Mesh();
        _gridMesh.hideFlags = HideFlags.DontSave;
        _gridMesh.SetVertices(vertices);
        _gridMesh.SetNormals(vertices);
        _gridMesh.SetIndices(indices.ToArray(), MeshTopology.Lines, 0);
        _gridMesh.UploadMeshData(true);
    }

    #endif
}
