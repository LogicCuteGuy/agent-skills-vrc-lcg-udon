using System.Linq;
using UdonSharp;
using UnityEngine;

public class RuntimeLCGUnsupportedLinq : UdonSharpBehaviour
{
    private int[] _values = new int[] { 3, 1, 2 };

    public void _Run()
    {
        int first = _values.OrderBy(value => value).FirstOrDefault();
        Debug.Log(first);
    }
}
