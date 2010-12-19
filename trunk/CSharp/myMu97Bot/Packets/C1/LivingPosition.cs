using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Packets
{
    public class LivingPosition : CommonServerToClientPacket
    {
        public int PlayerId { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
        public byte Rotation { get; set; }
        // rotation goes like this:
        //        |
        //   112 96 80
        // - 0      64 -> X
        //   16  32 48
        //        |
        //        V
        //        Y

        public LivingPosition(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            this.PlayerId = aBuffer[3] * (byte.MaxValue + 1) + aBuffer[4];
            this.X = aBuffer[5];
            this.Y = aBuffer[6];
            this.Rotation = aBuffer[7];
        }
    }
}
