using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Game_Objects
{
    public class GOPoint
    {
        public int X = 0;
        public int Y = 0;
    }

    public class GOMeters
    {
        public int Health = 0;
    }

    public class GOPlayerMeters : GOMeters
    {
        public int MaxHealth = 0;
        public int Mana = 0;
        public int MaxMana = 0;
        public int Stamina = 0;
        public int MaxStamina = 0;
    }
}
