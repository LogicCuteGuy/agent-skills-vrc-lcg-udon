using System;
using System.Linq;
using System.Threading.Tasks;
using UdonSharp;
using UnityEngine;

public interface ILCGTransform
{
    int[] Transform(int[] values);
}

public class RuntimeLCGSupported : UdonSharpBehaviour, ILCGTransform
{
    private int[] _values = new int[] { 1, 2, 3 };

    public int[] Transform(int[] values)
    {
        return values
            .Where(value => value > 0)
            .Select(value => value * 2)
            .ToArray();
    }

    public async void _Run()
    {
        await Task.Yield();

        try
        {
            _values = Transform(_values);
        }
        catch (ArgumentException exception)
        {
            Debug.LogError(exception.Message);
        }
        finally
        {
            Debug.Log("finished");
        }
    }
}
