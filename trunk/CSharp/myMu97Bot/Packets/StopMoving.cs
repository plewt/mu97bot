using System;

namespace DudEeer.myMu97Bot.Packets
{
    class StopMoving : CommonServerToClientPacket
    {
        public int LivingId { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
        public byte Opt { get; set; }

        public StopMoving(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            this.LivingId = aBuffer[3] * byte.MaxValue + aBuffer[4];
            this.X = aBuffer[5];
            this.Y = aBuffer[6];
            this.Opt = aBuffer[7];
        }
    }
}
