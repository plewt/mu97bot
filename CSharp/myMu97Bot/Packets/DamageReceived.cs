﻿using System;

namespace DudEeer.myMu97Bot.Packets
{
    class DamageReceived : CommonServerToClientPacket
    {
        public int LeavingId { get; set; }
        public int Damage { get; set; }
        public bool Critical { get; set; }
 
        public DamageReceived(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 8) throw new Exception("Too short packet.");

            this.Critical = (aBuffer[7] == 1);
            this.LeavingId = aBuffer[3] * byte.MaxValue + aBuffer[4];
            this.Damage = aBuffer[5] * byte.MaxValue + aBuffer[6];
        }
    }
}
