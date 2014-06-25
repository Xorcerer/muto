using System;
using System.Collections.Generic;

namespace Muto.Logic
{
    public struct Position2D : IEquatable<Position2D>
    {
        public readonly int X;
        public readonly int Y;

        public Position2D(int x, int y)
        {
            X = x;
            Y = y;
        }

        public Position2D Move(int xOffset, int yOffset)
        {
            return new Position2D(X + xOffset, Y + yOffset);
        }

        public override int GetHashCode()
        {
            return (X >> 16) | (X << 16) ^ Y;
        }

        public bool Equals(Position2D other) 
        {
            return X == other.X && Y == other.Y;
        }
        
        public override bool Equals(Object obj)
        {
            if (obj == null) 
                return false;

            if (obj is Position2D)
                return Equals((Position2D)obj);

            return false;
        }   

        public static bool operator == (Position2D lhs, Position2D rhs)
        {
            return lhs.X == rhs.X && lhs.Y == rhs.Y;
        }

        public static bool operator != (Position2D lhs, Position2D rhs)
        {
            return !(lhs == rhs);
        }

    }
}

