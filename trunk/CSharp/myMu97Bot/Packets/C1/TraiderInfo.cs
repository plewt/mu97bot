using System;

namespace DudEeer.myMu97Bot.Packets
{
    public class TraiderInfo : CommonServerToClientPacket
    {
        public string Name { get; set; }
        public int Level { get; set; }
        public int GuildId { get; set; }

        public TraiderInfo(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            this.Level = aBuffer[13] * byte.MaxValue + aBuffer[14];
            this.GuildId = aBuffer[15] * byte.MaxValue + aBuffer[16];
        }
    }
}
