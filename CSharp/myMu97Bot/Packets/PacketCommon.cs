using System;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot.Packets
{
    public enum MessageTypeC1
    {
        // C1
        PublicSpeach = 0,
        ServerText = 0x0d,
        DamageReceived = 0x11,
        Death = 0x17,
        PutItem = 0x32,
        TraiderInfo = 0x37,
        OpenCreateGuildWindow = 0x55, // no params
        OpenVaultWindow = 0x82, // no params
        StopMoving = 0xd4,
        PlayerPosition = 0xf1,
        CharacterList = 0xf3, // on char select menu
        Unknown = -1
    }
    public enum MessageTypeC1
    {
        // C2
        MeetPlayer = 0x12,
        Unknown = -1
    }

    public delegate void PublicSpeachEventHandler(string aName, string aText);
    public delegate void ServerTextEventHandler(ConsoleColor aTextColor, string aText);
    public delegate void DamageReceivedEventHandler(int aLeavingId, int aDamage, bool aCritical);
    public delegate void DeathEventEventHandler(int aLeavingId, int aKillerId);
    public delegate void PutItemEventHandler(byte aPosition, byte aItem, int aOptions);
    public delegate void TraderInfoEventHandler(string aName, int aLevel, int aGuildId);
    public delegate void OpenCreateGuildWindowEventHandler();
    public delegate void OpenVaultWindowEventHandler();
    public delegate void StopMovingEventHandler(int LivingId, byte X, byte Y, byte Opt);
    public delegate void PlayerPositionEventHandler(int MapNumber, int PlayerId);
    public delegate void CharacterListEventHandler(List<CharacterList.CharacterInfo> aCharList);

    public enum PacketClass
    {
        C1 = 0xC1,
        C2 = 0xC2,
        C3 = 0xC3,
        Unknown = -1
    }

    public class CommonServerToClientPacket
    {
        public PacketClass ClassType { get; set; }
        public byte Length { get; set; }
        public MessageTypeC1 MesType { get; set; }

        public CommonServerToClientPacket(byte[] aBuffer)
        {
            if (aBuffer.Length < 4) throw new Exception("Too short packet.");

            try { this.ClassType = (PacketClass)aBuffer[0]; }
            catch { this.ClassType = PacketClass.Unknown; }

            try { this.MesType = (MessageTypeC1)aBuffer[2]; }
            catch { this.MesType = MessageTypeC1.Unknown; }

            this.Length = aBuffer[1];
        }
    }
}
