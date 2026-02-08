using Godot;
using System;

public partial class Level : Node2D
{
    [Export] ColorRect Background;
    [Export] Control RestartMenu;

    [Export] TileMapLayer HexMap;

    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionJustPressed("Restart"))
        {ms-appid:W~com.squirrel.GitHubDesktop.GitHubDesktop
            if (RestartMenu.Visible == true)
            {
                RestartMenu.Visible = false;
            }
            else
            {
                RestartMenu.Visible = true;
            }
        }

        if(Input)
    }
}
