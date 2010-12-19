using System;

namespace DudEeer.myMu97Bot.Packets
{
    public class Death : CommonServerToClientPacket
    {
        public int LivingId { get; set; }
        public int KillerId { get; set; }

        public Death(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 7) throw new Exception("Too short packet.");

            this.LivingId = aBuffer[3] * byte.MaxValue + aBuffer[4];
            this.KillerId = aBuffer[5] * byte.MaxValue + aBuffer[6];
        }
    }
}
