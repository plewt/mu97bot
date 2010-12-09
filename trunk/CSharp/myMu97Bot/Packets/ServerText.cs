using System;

namespace DudEeer.myMu97Bot.Packets
{
    public class ServerText : CommonServerToClientPacket
    {
        public string Text { get; set; }
        public ConsoleColor TextColor { get; set; }

        ServerText(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 5) throw new Exception("Too short packet.");

            if (aBuffer[3] == 1) this.TextColor = ConsoleColor.Blue;
            else this.TextColor = ConsoleColor.Black;

            char[] chText = new char[this.Length - 5];
            Array.Copy(aBuffer, 4, chText, 0, this.Length - 5);
            this.Text = (new string(chText)).Trim('\0');
        }
    }
}
