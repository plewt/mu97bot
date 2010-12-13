using System;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot.Packets
{
/*# Authentication
Authentication C3 XX XX F1 01
InvalidPass C1 05 F1 01 00
AuthenticOK C1 05 F1 01 01
AccInvalid C1 05 F1 01 02
AccAlreadyCon C1 05 F1 01 03
ServerFull C1 05 F1 01 04
AccBlocked C1 05 F1 01 05
NewVersionReq C1 05 F1 01 06
Conerror C1 05 F1 01 07
ConClosed3Fails C1 05 F1 01 08
NoChargeInfo C1 05 F1 01 09
SubscTermOver C1 05 F1 01 0A
SubscTimeOver C1 05 F1 01 0B
SubscTermIpOver C1 05 F1 01 0C
SubscTimeIpOver C1 05 F1 01 0D
OnlyPlayers15 C1 05 F1 01 11

# Logout
Logout - Exit game C3 XX XX F1 02 00
Logout - Switch Char C3 XX XX F1 02 01
Logout - Switch Server C3 XX XX F1 02 02

# Connection
CloseGame C1 05 F1 02 00
ServerSaysHello C1 04 00 01
ServerList-Request C1 04 F4 06
ServerList-Reply C2 XX XX F4 06 00 XX 00 XX
Server Select C1 06 F4 03 XX XX
Selection-Reply C1 XX F4 03 XX
GameServerHello C1 0C F1 00 01 XX
Client - Ping C3 12 XX 0E 00
Ping Reply C1 04 0F XX

# Char
Char - List Request C1 04 F3 00
Char - List Reply C1 XX F3 00
Char - Create C1 XX F3 01
Char - Selected C1 XX F3 03
Char - Stats C3 XX XX F3 03
Skills List C1 XX F3 11
Char - Respawn C3 XX XX F3 04
Char - Config Setup C1 XX F3 30
Char - Rotate C1 05 18 XX XX

# Update
Potion used C3 XX XX 26
Update Life Max C1 07 26 FE XX XX XX
Update Mana/Sta Max C1 08 27 FE 00 XX XX XX
Update Mana/Stamina C1 08 27 FF

# Friends
Friends - List C2 XX XX C0 00

# Main.exe Checksum
Main.exe - Checksum Key C1 06 03 XX XX XX
Main.exe - Checksum C3 XX XX 03 00

# NPGGChecksum
NPGGChecksum C3 XX XX 73 00

# Message
Public Message C1 XX 00
Whisper C1 XX 02

# Money
Money - Update C1 XX 81 01

# Inventory
Inventory - Item moved C3 XX XX 24

# moviment
Update Position CTS C1 06 D3
Update Position STC C1 07 DF
Object Moved C1 08 D3
Attack C1 07 D7 XX XX XX XX

# Trade
TradeSuccessful C1 04 3D 01
TradeCanceled C1 04 3D 00
ClientCloseTrade C1 03 3D

# NPC
OpenNPCWindow C3 XX XX 30

# Vault packets
Vault - Unlocked C1 04 83 00
Vault - Locked C1 04 83 01
Vault - Closed C1 03 82
Vault - Item List C2 XX XX 31 00

# Meeting events
Meet - Monster C2 XX XX 13 XX
Meet - Item C2 XX XX 20 XX
Meet - Player C2 XX XX 12 XX
Meet - Store C2 XX XX 3F 00
Meet - Transf Monster C2 XX XX 45

# Forget objects
Forget Item C2 XX XX 21

# Actions
Pick up item C3 XX XX 22

# Hunting
Exp obtained C3 XX XX 16
Object - Death C1 08 17 XX XX XX XX XX

# Skills
DK Twist Slash C3 XX XX 1E 29
DK Death Stab C3 XX XX 19 2B
DK Falling Slash C3 XX XX 19 13
DW Energy Ball C3 XX XX 19 11
DW Poison C3 XX XX 19 01
DW Meteorite C3 XX XX 19 02
DW Lightning C3 XX XX 19 03
DW Fire Ball C3 XX XX 19 04
DW Power Wave C3 XX XX 19 0B
DW Ice C3 XX XX 19 07

# Guild
Guild - Bind player C2 XX XX 65

# Unknown packets
Unknown C1 04 F3 7A*/
    public enum MessageTypeC1
    {
        // C1
        PublicSpeech = 0,
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
    public enum MessageTypeC2
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
    public delegate void TraiderInfoEventHandler(string aName, int aLevel, int aGuildId);
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
