using System;

namespace DudEeer.myMu97Bot.Packets
{
    class PutItem : CommonServerToClientPacket
    {
        public byte Position { get; set; }
        public byte Item { get; set; }
        public int Options { get; set; }
 
        public PutItem(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            this.Position = aBuffer[3];
            this.Item = aBuffer[4];
            this.Options = aBuffer[5] * byte.MaxValue * byte.MaxValue + aBuffer[6] * byte.MaxValue + aBuffer[7];
        }
    }
}
