using UnityEngine;
using System;
using System.Collections.Generic;

namespace Muto.Logic
{
    public class UnitOverlapException: Exception
    {

    }

    public class Map
    {
        private Dictionary<Position2D, GameUnit> _objs = new Dictionary<Position2D, GameUnit>();

        public GameUnit this[int x, int y]
        {
            get
            {
                return _objs[new Position2D(x, y)];
            }
        }

        public GameUnit this[Position2D position]
        {
            get
            {
                return _objs[position];
            }
        }

        public void Add(GameUnit unit)
        {
            GameUnit another;
            if (_objs.TryGetValue(unit.Position, out another))
            {
                if (another == unit)
                    return;

                throw new UnitOverlapException();
            }

            _objs[unit.Position] = unit;

            unit.Destroyed += OnUnitDestroyed;
            unit.Moved += OnUnitMoved;
        }

        public void OnUnitMoved(GameUnit unit, Position2D originalPosition)
        {
            _objs.Remove(originalPosition);
            _objs[unit.Position] = unit;
        }

        public void OnUnitDestroyed(GameUnit unit)
        {
            _objs.Remove(unit.Position);

            unit.Moved -= OnUnitMoved;
            unit.Destroyed -= OnUnitDestroyed;
        }
    }
}
