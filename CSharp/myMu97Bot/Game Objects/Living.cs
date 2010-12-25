using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Game_Objects
{
    public class LivingEntity
    {
        public int ID = 0;
        public GOPoint Position = new GOPoint();
        public GOMeters Meters = new GOMeters();
    }

    public class MonsterEntity : LivingEntity
    { 
    }

    public class PlayerEntity : LivingEntity
    {
        public GOPlayerMeters Meters = new GOPlayerMeters();
        public string Name = "";
        public int Level = 0;
    }
}
