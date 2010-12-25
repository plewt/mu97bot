using System;
using System.Windows.Forms;
using DudEeer.myMu97Bot.Properties;
using DudEeer.myMu97Bot.Packets;
using DudEeer.myMu97Bot.Game_Objects;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot
{
    public partial class MainForm : Form
    {
        private static Settings MySettings = new Settings();
        private MUProtocolAnalyzer MyProtoAnalizer = new MUProtocolAnalyzer(MySettings.ServerIp, MySettings.SelfIp);

        // info about player (us)
        private PlayerEntity BotPlayer = new PlayerEntity();
        
        public MainForm()
        {
            InitializeComponent();
            BotPlayer.ID = MySettings.BotPlayerId;
            BotPlayer.Meters.MaxHealth = MySettings.BotMaxHealth;
            BotPlayer.Meters.MaxMana = MySettings.BotMaxMana;
            BotPlayer.Meters.MaxStamina = MySettings.BotMaxStamina;
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void networkConfigToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if ((new NetworkPreferencesForm()).ShowDialog() == DialogResult.OK)
            {
                MySettings = new Settings();
                MyProtoAnalizer.SelfAddress = MySettings.SelfIp;
                MyProtoAnalizer.ServerAddress = MySettings.ServerIp;
                AddLog(LogType.Common, "Network settings changed.");
            }
        }

        private void startToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Start();
            continueToolStripMenuItem.Enabled = false;
            pauseToolStripMenuItem.Enabled = true;
            stopToolStripMenuItem.Enabled = true;
            startToolStripMenuItem.Enabled = true;
            AddLog(LogType.Common, "Network monitoring started.");
        }

        private void stopToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Stop();
            continueToolStripMenuItem.Enabled = false;
            pauseToolStripMenuItem.Enabled = false;
            stopToolStripMenuItem.Enabled = false;
            startToolStripMenuItem.Enabled = true;
            AddLog(LogType.Common, "Network monitoring stopped.");
        }

        private void pauseToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Pause();
            continueToolStripMenuItem.Enabled = true;
            pauseToolStripMenuItem.Enabled = false;
            stopToolStripMenuItem.Enabled = true;
            startToolStripMenuItem.Enabled = false;
            AddLog(LogType.Common, "Network monitoring paused.");
        }

        private void continueToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Continue();
            continueToolStripMenuItem.Enabled = false;
            pauseToolStripMenuItem.Enabled = true;
            stopToolStripMenuItem.Enabled = true;
            startToolStripMenuItem.Enabled = false;
            AddLog(LogType.Common, "Continuing network monitoring.");
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            MyProtoAnalizer.OnPublicSpeach += (new PublicSpeechEventHandler(MyOnPublicSpeach));
            MyProtoAnalizer.OnCharacterList += (new CharacterListEventHandler(MyOnCharacterList));
            MyProtoAnalizer.OnLivingPosition += (new LivingPositionEventHandler(MyOnPlayerPosition));
            MyProtoAnalizer.OnGameServerAnswer += (new GameServerAnswerEventHandler(MyOnGameServerAnswer));
            MyProtoAnalizer.OnUpdateHealth += (new UpdateHealthEventHandler(MyOnUpdateHealth));
            MyProtoAnalizer.OnUpdateMana += (new UpdateManaEventHandler(MyOnUpdateMana));
            AddLog(LogType.Common, "{0} loaded", Application.ProductName);
        }

        private enum LogType { 
            NetworkProtocol, 
            Common 
        };

        private void AddLog(LogType aLogType, string aFormat, params object[] aArgs)
        {
            switch (aLogType)
            {
                case LogType.NetworkProtocol:
#if LOGNETWORKPROTO
                    if (aFormat != string.Empty)
                    {
                        string LogMessage = string.Format(aFormat, aArgs);
                        LogMessage = string.Format("{0} {1}", DateTime.Now, LogMessage);
                        listBox1.Items.Insert(0, LogMessage);
                    }
#endif
                    break;
                case LogType.Common:
                    if (aFormat != string.Empty)
                    {
                        string LogMessage = string.Format(aFormat, aArgs);
                        LogMessage = string.Format("[{0}]\t{1}", DateTime.Now, LogMessage);
                        listBox1.Items.Insert(0, LogMessage);
                    }
                    break;
                default:
                    break;
            }
            if (BotPlayer.ID != 0)
            { 
                lbIdVal.Text = BotPlayer.ID.ToString();
                lbNameVal.Text = BotPlayer.Name;
                lbHealthVal.Text = string.Format("{0}/{1}", BotPlayer.Meters.Health, BotPlayer.Meters.MaxHealth);
                lbManaVal.Text = string.Format("{0}/{1}", BotPlayer.Meters.Mana, BotPlayer.Meters.MaxMana);
                lbStaminaVal.Text = string.Format("{0}/{1}", BotPlayer.Meters.Stamina, BotPlayer.Meters.MaxStamina);
                lbPositionVal.Text = string.Format("{0} {1}", BotPlayer.Position.X, BotPlayer.Position.Y);
            }
            else
            {
                lbIdVal.Text = "0";
                lbHealthVal.Text = "0/0";
                lbManaVal.Text = "0/0";
                lbStaminaVal.Text = "0/0";
                lbPositionVal.Text = "0 0";
            }
        }

        public void MyOnUpdateHealth(UpdateHealth aUpdateHealth)
        {
            switch (aUpdateHealth.UpdateType)
            {
                case UpdateHealth.UpdateHealthType.Max : 
                    BotPlayer.Meters.MaxHealth = aUpdateHealth.Health;
                    MySettings.BotMaxHealth = BotPlayer.Meters.MaxHealth;
                    AddLog(LogType.NetworkProtocol, "Got maximum hp : {0}", aUpdateHealth.Health);
                    break;
                case UpdateHealth.UpdateHealthType.Current: 
                    BotPlayer.Meters.Health = aUpdateHealth.Health;
                    AddLog(LogType.NetworkProtocol, "Got current hp : {0}", aUpdateHealth.Health);
                    break;
            }
        }

        public void MyOnUpdateMana(UpdateMana aUpdateMana)
        {
            switch (aUpdateMana.UpdateType)
            {
                case UpdateMana.UpdateManaType.Max:
                    BotPlayer.Meters.MaxMana = aUpdateMana.Mana;
                    BotPlayer.Meters.MaxStamina = aUpdateMana.Stamina;
                    MySettings.BotMaxMana = BotPlayer.Meters.MaxMana;
                    MySettings.BotMaxStamina = BotPlayer.Meters.MaxStamina;
                    AddLog(LogType.NetworkProtocol, "Got maximum mana : {0} and stamina : {1}", aUpdateMana.Mana, aUpdateMana.Stamina);
                    break;
                case UpdateMana.UpdateManaType.Current:
                    BotPlayer.Meters.Mana = aUpdateMana.Mana;
                    BotPlayer.Meters.Stamina = aUpdateMana.Stamina;
                    AddLog(LogType.NetworkProtocol, "Got current mana : {0} and stamina : {1}", aUpdateMana.Mana, aUpdateMana.Stamina);
                    break;
            }
        }

        public void MyOnGameServerAnswer(GameServerAnswer aAnswer)
        { 
            if (aAnswer.SubType == GameServerAnswer.SubTypes.Hello)
            {
                AddLog(LogType.NetworkProtocol, "Got GameServer \"hello\" message, player id : {0}, version : {1}", aAnswer.HelloAnswer.PlayerId, aAnswer.HelloAnswer.Version);
                BotPlayer.ID = aAnswer.HelloAnswer.PlayerId;
                MySettings.BotPlayerId = BotPlayer.ID;
                MySettings.Save();
            }
        }

        public void MyOnPlayerPosition(LivingPosition aLivingPosition)
        {
            if (( BotPlayer.ID != 0 ) && ( BotPlayer.ID == aLivingPosition.PlayerId ))
            {
                AddLog(LogType.NetworkProtocol, "Got ourself position X : {1}, Y : {2}, Rotation : {3}", aLivingPosition.PlayerId, aLivingPosition.X, aLivingPosition.Y, aLivingPosition.Rotation);
                BotPlayer.Position.X = aLivingPosition.X;
                BotPlayer.Position.Y = aLivingPosition.Y;
            }
            else
            {
                AddLog(LogType.NetworkProtocol, "Got position of living with id {0} X : {1}, Y : {2}, Rotation : {3}", aLivingPosition.PlayerId, aLivingPosition.X, aLivingPosition.Y, aLivingPosition.Rotation);
            }
        }

        public void MyOnCharacterList(CharacterList aCharacterList)
        {
            AddLog(LogType.NetworkProtocol, "Got characters list ^^^");
            AddLog(LogType.NetworkProtocol, "Name : Level");
            foreach (CharacterList.CharacterInfo CharInfo in aCharacterList.CharList)
            {
                AddLog(LogType.NetworkProtocol, "{0} : {1}", CharInfo.Name, CharInfo.Level);
            }
        }

        public void MyOnPublicSpeach(PublicSpeech aPublicSpeech)
        {
            AddLog(LogType.NetworkProtocol, "Someone said something - {0} : {1}", aPublicSpeech.Name, aPublicSpeech.Message);
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            MySettings.Save();
            if ((MyProtoAnalizer.State == MUProtocolAnalyzer.States.Started) || (MyProtoAnalizer.State == MUProtocolAnalyzer.States.Paused)) MyProtoAnalizer.Stop();
        }

    }
}
