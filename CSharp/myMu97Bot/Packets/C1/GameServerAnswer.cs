using System;

namespace DudEeer.myMu97Bot.Packets
{
    public class GameServerAnswer : CommonServerToClientPacket
    {
        public enum SubTypes {
            Hello = 0,
            LoginFailed = 1,
            GameClose = 2,
            Unknown = -1
        }
        
        public class SubHello {
            public int PlayerId { get; set; }
            public string Version { get; set; }
            
            public SubHello(int aPlayerId, string aVersion)
            {
                this.PlayerId = aPlayerId;
                this.Version = aVersion;
            }
        }

        public SubTypes SubType { get; set; }
        public SubHello HelloAnswer { get; set; }

        public GameServerAnswer(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 4) throw new Exception("Too short packet.");
            if (aBuffer[3] > 2) throw new Exception("Unknown subtype.");
            this.SubType = (SubTypes)aBuffer[3];
            if (this.SubType == SubTypes.Hello)
            {
                if (aBuffer.Length < 12) throw new Exception("Too short packet.");
                char[] chVersion = new char[5];
                Array.Copy(aBuffer, 7, chVersion, 0, 5);
                HelloAnswer = new SubHello(aBuffer[5] * (byte.MaxValue + 1) + aBuffer[6], (new string(chVersion)).Trim('\0'));
            }
        }
    }
}
