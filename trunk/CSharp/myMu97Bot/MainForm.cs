using System;
using System.Windows.Forms;
using DudEeer.myMu97Bot.Properties;
using DudEeer.myMu97Bot.Packets;
using System.Collections.Generic;

namespace DudEeer.myMu97Bot
{
    public partial class MainForm : Form
    {
        private static Settings MySettings = new Settings();
        private MUProtocolAnalyzer MyProtoAnalizer = new MUProtocolAnalyzer(MySettings.ServerIp, MySettings.SelfIp);

        public MainForm()
        {
            InitializeComponent();
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
            }
        }

        private void startToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Start();
        }

        private void stopToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Stop();
        }

        private void pauseToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Pause();
        }

        private void continueToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MyProtoAnalizer.Continue();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            MyProtoAnalizer.OnPublicSpeach += (new PublicSpeechEventHandler(MyOnPublicSpeach));
            MyProtoAnalizer.OnCharacterList += (new CharacterListEventHandler(MyOnCharacterList));
            MyProtoAnalizer.OnLivingPosition += (new LivingPositionEventHandler(MyOnPlayerPosition));
            MyProtoAnalizer.OnGameServerAnswer += (new GameServerAnswerEventHandler(MyOnGameServerAnswer));
            MyProtoAnalizer.OnStopMoving += (new StopMovingEventHandler(MyOnStopMoving));
        }
        public void MyOnStopMoving(StopMoving aStopMoving)
        {
            listBox1.Items.Insert(0, string.Format("[STOP MOVING] LivingId : {0}, X : {1}, Y : {2}, Opt : {3}", aStopMoving.LivingId, aStopMoving.X, aStopMoving.Y, aStopMoving.Opt));
        }
        public void MyOnGameServerAnswer(GameServerAnswer aAnswer)
        { 
            if (aAnswer.SubType == GameServerAnswer.SubTypes.Hello)
            {
                listBox1.Items.Insert(0, string.Format("[GS HELLO] PlayerId : {0}, Version {1}", aAnswer.HelloAnswer.PlayerId, aAnswer.HelloAnswer.Version));
            }
        }
        public void MyOnPlayerPosition(LivingPosition aPlayerPosition)
        {
            listBox1.Items.Insert(0, string.Format("[LIVING POSITION] LivingId : {0}, X : {1}, Y : {2}, Rotation : {3}", aPlayerPosition.PlayerId, aPlayerPosition.X, aPlayerPosition.Y, aPlayerPosition.Rotation));
        }

        public void MyOnCharacterList(CharacterList aCharacterList)
        {
            listBox1.Items.Insert(0, "[CHARACTERS LIST]:");
            foreach (CharacterList.CharacterInfo CharInfo in aCharacterList.CharList)
            {
                listBox1.Items.Insert(0, string.Format("[CHARACTERS LIST] {0} : {1}", CharInfo.Name, CharInfo.Level));                                
            }
        }

        public void MyOnPublicSpeach(PublicSpeech aPublicSpeech)
        {
            listBox1.Items.Insert(0, string.Format("[PUBLIC SPEACH] {0} : {1}", aPublicSpeech.Name, aPublicSpeech.Message));
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if ((MyProtoAnalizer.State == MUProtocolAnalyzer.States.Started) || (MyProtoAnalizer.State == MUProtocolAnalyzer.States.Paused)) MyProtoAnalizer.Stop();
        }

    }
}
