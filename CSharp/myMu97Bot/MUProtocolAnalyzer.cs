using System;
using System.Net.Sockets;
using System.Net;
using SharpPcap;
using PacketDotNet;

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

        #region Events
        public event PublicSpeachEventHandler OnPublicSpeach;
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
                    if (!(device.Opened))
                    {
                        device.Open();
                        curDevice = device;
                        device.Mode = CaptureMode.Packets;
                        device.NonBlockingMode = true;
                        device.Filter = "tcp";
                    }
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
                            switch (cstcpTemp.MesType)
                            {
                                case MessageType.PublicSpeach:
                                    PublicSpeachPacket pspTemp = new PublicSpeachPacket(aBuffer);

                                    if (OnPublicSpeach != null)
                                        AsyncHelper.FireAndForget(OnPublicSpeach, pspTemp.Name, pspTemp.Message);
                                    //                                        OnPublicSpeach(pspTemp.Name, pspTemp.Message);
                                    break;
                            }
                            break;
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
                

                if (MyTcpPacket.PayloadData != null)
                    AnalyzePacket(MyTcpPacket.PayloadData, CurDirection);

            }
            catch (Exception ex)
            {
            }            

        }
    }
}
