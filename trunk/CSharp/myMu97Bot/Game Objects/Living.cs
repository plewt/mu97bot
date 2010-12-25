using System.Drawing;

namespace DudEeer.myMu97Bot.Game_Objects
{
    public class LivingEntity
    {
        public int ID = 0;
        public Point Position = new Point();
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
