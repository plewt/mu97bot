using System;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot.Packets
{
/*
 -		aBuffer	{byte[135]}	byte[]
		[0]	193	byte
		[1]	135	byte
		[2]	243	byte
-------------------------------------
COUNT		[3]	0	byte
		[4]	5	byte
-------------------------------------
ID		[5]	0	byte
-------------------------------------
NAME		[6]	78	byte
		[7]	97	byte
		[8]	103	byte
		[9]	108	byte
		[10]	111	byte
		[11]	69	byte
		[12]	108	byte
		[13]	102	byte
		[14]	0	byte
		[15]	0	byte
-------------------------------------
WTF?		[16]	123	byte
-------------------------------------
LVL		[17]	0	byte
		[18]	1	byte
-------------------------------------
WTF?		[19]	0	byte
		[20]	80	byte
		[21]	71	byte
		[22]	196	byte
		[23]	204	byte
		[24]	204	byte
		[25]	207	byte
		[26]	31	byte
		[27]	255	byte
		[28]	241	byte
		[29]	1	byte
		[30]	0	byte
-------------------------------------
*/
    public class CharacterList : CommonServerToClientPacket
    {
        private const int CharacterInfoLength = 26;

        public class CharacterInfo
        {
            public string Name { get; set; }
            public int Level { get; set; }
            // futher bytes not processed
        }

        public List<CharacterInfo> CharList = new List<CharacterInfo>();

        public CharacterList(byte[] aBuffer)
            : base(aBuffer)
        {
            if (aBuffer.Length < 4) throw new Exception("Too short packet.");

            for(int i = 0; i < aBuffer[4]; i++)
            {
                CharacterInfo TempChar = new CharacterInfo();

                char[] chName = new char[10];
                Array.Copy(aBuffer, 5 + CharacterInfoLength * i + 1, chName, 0, 10);
                TempChar.Name = (new string(chName)).Trim('\0');
                TempChar.Level = aBuffer[5 + CharacterInfoLength * i + 12] + aBuffer[5 + CharacterInfoLength * i + 13] * 256;

                this.CharList.Add(TempChar);
            }
        }
    }
}
