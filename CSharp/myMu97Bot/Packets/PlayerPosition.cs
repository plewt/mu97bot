using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Packets
{
    class PlayerPosition : CommonServerToClientPacket
    {
        public int MapNumber { get; set; }
        public int PlayerId { get; set; }
        // futher bytes unknown

        public PlayerPosition(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 11) throw new Exception("Too short packet.");

            this.MapNumber = aBuffer[3] * byte.MaxValue + aBuffer[4];
            this.PlayerId = aBuffer[5];
        }
    }
}
