using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DudEeer.myMu97Bot.Packets
{
// C2 NOT YET IMPLEMENTED
    /*    class MeetPlayer : CommonServerToClientPacket
        {
            private const int CharacterInfoLength = 26;

            public class CharacterInfo
            {
                public string Name { get; set; }
                public int Level { get; set; }
                // futher bytes not processed
            }

            public List<CharacterInfo> CharList = new List<CharacterInfo>();

            public MeetPlayer(byte[] aBuffer)
                : base(aBuffer)
            {
                if (aBuffer.Length < 4) throw new Exception("Too short packet.");

                for(int i = 0; i < aBuffer[3]; i++)
                {
                    CharacterInfo TempChar = new CharacterInfo();

                    char[] chName = new char[10];
                    Array.Copy(aBuffer, 4 + CharacterInfoLength * i + 1, chName, 0, 10);
                    TempChar.Name = (new string(chName)).Trim('\0');
                    TempChar.Level = aBuffer[4 + CharacterInfoLength * i + 12];

                    this.CharList.Add(TempChar);
                }
            }
        }*/
}
