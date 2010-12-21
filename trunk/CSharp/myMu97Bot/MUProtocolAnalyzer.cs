using System;
using System.Net.Sockets;
using System.Net;
using SharpPcap;
using PacketDotNet;
using DudEeer.myMu97Bot.Packets;
using System.IO;

namespace DudEeer.myMu97Bot
{
    public class MUProtocolAnalyzer
    {
        private uint LastAck = 0;
        private uint LastSeq = 0;
        private enum PacketDirection
        {
            ClientToServer,
            ServerToClient
        }

        public enum States
        {
            Started,        // Working
            Stopped,        // Not working
            Paused          // Paused
        }

        private IPAddress ipServerAddress;
        private string sSelfAddress;
        private States stState = States.Stopped;
        private LivePcapDevice curDevice;
#if LOGPACKETS
        private TextWriter MyWriter = new StreamWriter("outgoing.txt", true);
#endif

        #region Events
        public event PublicSpeechEventHandler OnPublicSpeach;
        public event ServerTextEventHandler OnServerText;
        public event DamageReceivedEventHandler OnDamageReceived;
        public event DeathEventEventHandler OnDeath;
        public event PutItemEventHandler OnPutItem;
        public event TraiderInfoEventHandler OnTraiderInfo;
        public event OpenCreateGuildWindowEventHandler OnOpenCreateGuildWindow;
        public event OpenVaultWindowEventHandler OnOpenVaultWindow;
        public event StopMovingEventHandler OnStopMoving;
        public event LivingPositionEventHandler OnLivingPosition;
        public event CharacterListEventHandler OnCharacterList;
        public event GameServerAnswerEventHandler OnGameServerAnswer;
        public event UpdateHealthEventHandler OnUpdateHealth;
        public event UpdateManaEventHandler OnUpdateMana;
        #endregion

        public States State { get {return stState; } }

        public string SelfAddress
	    {
		    get { return sSelfAddress;}
		    set { sSelfAddress = value;}
	    }

	    public string ServerAddress
	    {
		    get { return ipServerAddress.ToString();}
		    set { ipServerAddress = IPAddress.Parse(value);}
	    }

        public MUProtocolAnalyzer(string aServerAddress = "", string aSelfAddress = "")
        {
            sSelfAddress = aSelfAddress;
            ipServerAddress = IPAddress.Parse(aServerAddress);
        }

        public bool Start()
        {
            try
            {
                LivePcapDeviceList devices = LivePcapDeviceList.Instance;
                foreach (LivePcapDevice device in devices)
                {
                    if (device.Name != sSelfAddress) continue;

                    device.OnPacketArrival += new PacketArrivalEventHandler(MyPcapCapture);
                    if (!(device.Opened)) device.Open();
                    curDevice = device;
                    device.Mode = CaptureMode.Packets;
                    device.NonBlockingMode = true;
                    device.Filter = "tcp";

                    device.StartCapture();
                    stState = States.Started;
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        public void Stop()
        {
            curDevice.StopCapture();
            stState = States.Stopped;
        }

        public void Pause()
        {
            stState = States.Paused;
        }

        public void Continue()
        {
            stState = States.Started;
        }

        private void AnalyzePacket(byte[] aBuffer, PacketDirection aType)
        {
            switch (aType)
            {
                case PacketDirection.ClientToServer: break; // maybe later
                case PacketDirection.ServerToClient:
                    // TODO : Here should be different types of mu protocol packets with parsing and event-based processing
                    CommonServerToClientPacket cstcpTemp = new CommonServerToClientPacket(aBuffer);
                    switch (cstcpTemp.ClassType)
                    {
                        case PacketClass.C1:
                            switch (cstcpTemp.MesTypeC1)
                            {
                                case MessageTypeC1.PublicSpeech:
                                    if (OnPublicSpeach != null)
                                    {
                                        PublicSpeech pspTemp = new PublicSpeech(aBuffer);
                                        AsyncHelper.FireAndForget(OnPublicSpeach, pspTemp);
                                    }
                                    break;
                                case MessageTypeC1.CharacterList:
                                    if (OnCharacterList != null)
                                    {
                                        CharacterList clTemp = new CharacterList(aBuffer);
                                        AsyncHelper.FireAndForget(OnCharacterList, clTemp);
                                    }
                                    break;
                                case MessageTypeC1.DamageReceived:
                                    if (OnDamageReceived != null)
                                    {
                                        DamageReceived drTemp = new DamageReceived(aBuffer);
                                        AsyncHelper.FireAndForget(OnDamageReceived, drTemp);
                                    }
                                    break;
                                case MessageTypeC1.Death:
                                    if (OnDeath != null)
                                    {
                                        Death dTemp = new Death(aBuffer);
                                        AsyncHelper.FireAndForget(OnDeath, dTemp);
                                    }
                                    break;
                                case MessageTypeC1.OpenCreateGuildWindow:
                                    if (OnOpenCreateGuildWindow != null)
                                        AsyncHelper.FireAndForget(OnOpenCreateGuildWindow);
                                    break;
                                case MessageTypeC1.OpenVaultWindow:
                                    if (OnOpenVaultWindow != null)
                                        AsyncHelper.FireAndForget(OnOpenVaultWindow);
                                    break;
                                case MessageTypeC1.PlayerPosition:
                                    if (OnLivingPosition != null)
                                    {
                                        LivingPosition ppTemp = new LivingPosition(aBuffer);
                                        AsyncHelper.FireAndForget(OnLivingPosition, ppTemp);
                                    }
                                    break;
                                case MessageTypeC1.PutItem:
                                    if (OnPutItem != null)
                                    {
                                        PutItem piTemp = new PutItem(aBuffer);
                                        AsyncHelper.FireAndForget(OnPutItem, piTemp);
                                    }
                                    break;
                                case MessageTypeC1.ServerText:
                                    if (OnServerText != null)
                                    {
                                        ServerText stTemp = new ServerText(aBuffer);
                                        AsyncHelper.FireAndForget(OnServerText, stTemp);
                                    }
                                    break;
                                case MessageTypeC1.TraiderInfo:
                                    if (OnTraiderInfo != null)
                                    {
                                        TraiderInfo tiTemp = new TraiderInfo(aBuffer);
                                        AsyncHelper.FireAndForget(OnTraiderInfo, tiTemp);
                                    }
                                    break;
                                case MessageTypeC1.StopMoving:
                                    if (OnStopMoving != null)
                                    {
                                        StopMoving smTemp = new StopMoving(aBuffer);
                                        AsyncHelper.FireAndForget(OnStopMoving, smTemp);
                                    }
                                    break;                                    
                                case MessageTypeC1.GameServerAnswer:
                                    if (OnGameServerAnswer != null)
                                    {
                                        GameServerAnswer gsaTemp = new GameServerAnswer(aBuffer);
                                        AsyncHelper.FireAndForget(OnGameServerAnswer, gsaTemp);
                                    }
                                    break;
                                case MessageTypeC1.UpdateHealth:
                                    if (OnUpdateHealth != null)
                                    {
                                        UpdateHealth uhTemp = new UpdateHealth(aBuffer);
                                        AsyncHelper.FireAndForget(OnUpdateHealth, uhTemp);
                                    }
                                    break;
                                case MessageTypeC1.UpdateMana:
                                    if (OnUpdateMana != null)
                                    {
                                        UpdateMana umTemp = new UpdateMana(aBuffer);
                                        AsyncHelper.FireAndForget(OnUpdateMana, umTemp);
                                    }
                                    break;
                            }
                            break;
                    }
                    if ((cstcpTemp.ClassType != PacketClass.Unknown) && (cstcpTemp.Length < aBuffer.Length))
                    {
                        byte[] subArray = new byte[aBuffer.Length - cstcpTemp.Length];
                        Array.Copy(aBuffer, cstcpTemp.Length, subArray, 0, aBuffer.Length - cstcpTemp.Length);
                        AnalyzePacket(subArray, aType);
                    }
                    break;
            }
        }

        public void MyPcapCapture(object aSender, CaptureEventArgs aArgs)
        {
            try
            {
                LivePcapDevice dev = (LivePcapDevice)aSender;
                string DevAddress = "";
                foreach (PcapAddress address in dev.Addresses)
                {
                    if (address.Addr == null) continue;
                    if (address.Addr.sa_family != 2) continue;
                    DevAddress = address.Addr.ToString();
                    break;
                }
                if (DevAddress == "") return;
                Packet MyPacket = Packet.ParsePacket(aArgs.Packet);
                TcpPacket MyTcpPacket = TcpPacket.GetEncapsulated(MyPacket);
                IpPacket MyIpPacket = IpPacket.GetEncapsulated(MyPacket);
                if (MyTcpPacket.PayloadData.Length == 0) return;

                PacketDirection CurDirection;
                string PacketFrom = MyIpPacket.SourceAddress.ToString();
                string PacketTo = MyIpPacket.DestinationAddress.ToString();
                if ((PacketFrom == DevAddress) && (PacketTo == ipServerAddress.ToString()))
                    CurDirection = PacketDirection.ClientToServer;
                else if ((PacketFrom == ipServerAddress.ToString()) && (PacketTo == DevAddress))
                    CurDirection = PacketDirection.ServerToClient;
                else return;

                if ((LastAck == MyTcpPacket.AcknowledgmentNumber) && (LastSeq == MyTcpPacket.SequenceNumber)) return;
                else
                {
                    LastAck = MyTcpPacket.AcknowledgmentNumber;
                    LastSeq = MyTcpPacket.SequenceNumber;
                }


#if LOGPACKETS
                if (CurDirection == PacketDirection.ServerToClient)
                {
                    string MyOutString = "";
                    foreach (byte MyByte in MyTcpPacket.PayloadData)
                    {
                        MyOutString = String.Format("{0} {1:X2}", MyOutString, MyByte);
                    }
                    MyWriter.WriteLine("S->C " + MyOutString);
                    MyWriter.Flush();
                }
                else
                {
                    string MyOutString = "";
                    foreach (byte MyByte in MyTcpPacket.PayloadData)
                    {
                        MyOutString = String.Format("{0} {1:X2}", MyOutString, MyByte);
                    }
                    MyWriter.WriteLine("C->S " + MyOutString);
                    MyWriter.Flush();
                }
#endif


                if (MyTcpPacket.PayloadData != null)
                    AnalyzePacket(MyTcpPacket.PayloadData, CurDirection);

            }
            catch (Exception ex)
            {
            }            

        }
    }
}
