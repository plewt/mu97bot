using System;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot.Packets
{
    public enum MessageTypeC1
    {
        // C1
        PublicSpeech = 0,
        ServerText = 0x0d,
        PlayerPosition = 0x10,
        DamageReceived = 0x11,
        Death = 0x17,
        UpdateHealth = 0x26,
        UpdateMana = 0x27,
        PutItem = 0x32,
        TraiderInfo = 0x37,
        OpenCreateGuildWindow = 0x55, // no params
        OpenVaultWindow = 0x82, // no params
        StopMoving = 0xd4,
        GameServerAnswer = 0xf1,
        CharacterList = 0xf3, // on char select menu
        Unknown = -1
    }
    public enum MessageTypeC2
    {
        // C2
        MeetPlayer = 0x12,
        Unknown = -1
    }
    public enum MessageTypeC3
    {
        // C3
        Unknown = -1
    }
    public enum MessageTypeC4
    {
        // C4
        Unknown = -1
    }
    public delegate void PublicSpeechEventHandler(PublicSpeech aPublicSpeech);
    public delegate void ServerTextEventHandler(ServerText aServerText);
    public delegate void DamageReceivedEventHandler(DamageReceived aDamageReceived);
    public delegate void DeathEventEventHandler(Death aDeath);
    public delegate void PutItemEventHandler(PutItem aPutItem);
    public delegate void TraiderInfoEventHandler(TraiderInfo aTraiderInfo);
    public delegate void OpenCreateGuildWindowEventHandler();
    public delegate void OpenVaultWindowEventHandler();
    public delegate void StopMovingEventHandler(StopMoving aStopMoving);
    public delegate void LivingPositionEventHandler(LivingPosition aPlayerPosition);
    public delegate void CharacterListEventHandler(CharacterList aCharList);
    public delegate void GameServerAnswerEventHandler(GameServerAnswer aGSAnswer);
    public delegate void UpdateHealthEventHandler(UpdateHealth aUpdateHealth);
    public delegate void UpdateManaEventHandler(UpdateMana aUpdateMana);

    public enum PacketClass
    {
        C1 = 0xC1,
        C2 = 0xC2,
        C3 = 0xC3,
        C4 = 0xC4,
        Unknown = -1
    }

    public class CommonServerToClientPacket
    {
        public PacketClass ClassType { get; set; }
        public int Length { get; set; }
        public MessageTypeC1 MesTypeC1 { get; set; }
        public MessageTypeC2 MesTypeC2 { get; set; }
        public MessageTypeC3 MesTypeC3 { get; set; }
        public MessageTypeC4 MesTypeC4 { get; set; }

        public CommonServerToClientPacket(byte[] aBuffer)
        {
            if (aBuffer.Length < 4) throw new Exception("Too short packet.");

            try { this.ClassType = (PacketClass)aBuffer[0]; }
            catch { this.ClassType = PacketClass.Unknown; }

            if (this.ClassType == PacketClass.C1)
            {
                try { this.MesTypeC1 = (MessageTypeC1)aBuffer[2]; }
                catch { this.MesTypeC1 = MessageTypeC1.Unknown; }
            }
            else if (this.ClassType == PacketClass.C2)
            {
                try { this.MesTypeC2 = (MessageTypeC2)aBuffer[3]; }
                catch { this.MesTypeC2 = MessageTypeC2.Unknown; }
            }
            else if (this.ClassType == PacketClass.C3)
            {
                try { this.MesTypeC3 = (MessageTypeC3)aBuffer[2]; }
                catch { this.MesTypeC3 = MessageTypeC3.Unknown; }
            }
            else if (this.ClassType == PacketClass.C4)
            {
                try { this.MesTypeC4 = (MessageTypeC4)aBuffer[3]; }
                catch { this.MesTypeC4 = MessageTypeC4.Unknown; }
            }

            if ((this.ClassType == PacketClass.C1) || (this.ClassType == PacketClass.C3))
                this.Length = aBuffer[1];
            else this.Length = aBuffer[1] * (byte.MaxValue + 1) + aBuffer[2];
        }
    }
}
