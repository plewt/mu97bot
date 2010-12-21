using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Packets
{
    // C1 08 27 FE/FF XX XX XX XX 
    public class UpdateMana : CommonServerToClientPacket
    {
        public enum UpdateManaType
        {
            Max = 0xFE,
            Current = 0xFF,
            Unknown = -1
        };

        public UpdateManaType UpdateType { get; set; }
        public int Mana { get; set; }
        public int Stamina { get; set; }

        public UpdateMana(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            try { this.UpdateType = (UpdateManaType)aBuffer[3]; }
            catch { this.UpdateType = UpdateManaType.Unknown; }

            this.Mana = aBuffer[4] * (byte.MaxValue + 1) + aBuffer[5];
            this.Stamina = aBuffer[6] * (byte.MaxValue + 1) + aBuffer[7];
        }
    }
}
