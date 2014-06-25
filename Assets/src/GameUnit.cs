using System;
using UnityEngine;

namespace Muto.Logic
{
    public interface GameUnit
    {
        Position2D Position { get; }

        /// <summary>
        /// Occurs when moved. The second arg should be the original position.
        /// </summary>
        event Action<GameUnit, Position2D> Moved;
        event Action<GameUnit> Destroyed;
    }
}

