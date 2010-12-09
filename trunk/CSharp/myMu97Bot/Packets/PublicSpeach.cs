using System;

namespace DudEeer.myMu97Bot.Packets
{
    public class PublicSpeach : CommonServerToClientPacket
    {
        public string Name { get; set; }
        public string Message { get; set; }

        public PublicSpeach(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 13) throw new Exception("Too short packet.");

            char[] chName = new char[10];
            Array.Copy(aBuffer, 3, chName, 0, 10);
            this.Name = (new string(chName)).Trim('\0');

            if (this.Length > 13)
            {
                char[] chMessage = new char[this.Length - 13];
                Array.Copy(aBuffer, 13, chMessage, 0, this.Length - 13);
                this.Message = (new string(chMessage)).Trim('\0');
            }
        }
    }
}
