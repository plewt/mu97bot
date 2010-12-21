using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Packets
{
    // C1 07 26 FE/FF XX XX XX
    public class UpdateHealth : CommonServerToClientPacket
    {
        public enum UpdateHealthType
        {
            Max = 0xFE,
            Current = 0xFF,
            Unknown = -1
        };

        public UpdateHealthType UpdateType { get; set; }
        public int Health { get; set; }

        public UpdateHealth(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            try { this.UpdateType = (UpdateHealthType)aBuffer[3]; }
            catch { this.UpdateType = UpdateHealthType.Unknown; }

            this.Health = aBuffer[4] * (byte.MaxValue + 1) * (byte.MaxValue + 1) + aBuffer[5] * (byte.MaxValue + 1) + aBuffer[6];
        }
    }
}
