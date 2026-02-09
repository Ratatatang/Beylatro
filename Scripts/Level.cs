using Godot;
using System;
using System.Linq;

public partial class Level : Node2D
{
    [Export] ColorRect Background;
    [Export] Control RestartMenu;

    [Export] TileMapLayer HexMap;

    Godot.Collections.Dictionary<Vector2, hexTypes> hexes;
    Godot.Collections.Array<Vector2> bombHexes;
    Godot.Collections.Array<Vector2> revealedHexes;

    enum hexTypes
    {
        EMPTY,
        BOMB
    }

    double bombPercent = 20.0;

    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionJustPressed("Restart"))
        {
            if (RestartMenu.Visible == true)
            {
                RestartMenu.Visible = false;
            }
            else
            {
                RestartMenu.Visible = true;
            }
        }

        if (Input.IsActionJustPressed("lmb"))
        {
            revealCells();
        }
    }
    
    public void revealCells()
    {
        var hex = (Vector2)  HexMap.LocalToMap(HexMap.GetLocalMousePosition());

        
    }

    public void placeBombs(Godot.Collections.Array<Vector2> avoidHexes)
    {
        int bombAmount = Mathf.RoundToInt((bombPercent / 100.0) * (double) hexes.Count);

        while (bombHexes.Count < bombAmount)
        {
            var bombHex = hexes.Values[((int) GD.Randi() % (hexes.Keys.Count + 1))];
        }
    }
}
