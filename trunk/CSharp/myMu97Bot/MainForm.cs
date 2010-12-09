using System;
using System.Windows.Forms;
using DudEeer.myMu97Bot.Properties;

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
            MyProtoAnalizer.OnPublicSpeach += (new PublicSpeachEventHandler(MyOnPublicSpeach));
        }

        public void MyOnPublicSpeach(string aName, string aText)
        {
            listBox1.Items.Add(string.Format("{0} : {1}", aName, aText));
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if ((MyProtoAnalizer.State == MUProtocolAnalyzer.States.Started) || (MyProtoAnalizer.State == MUProtocolAnalyzer.States.Paused)) MyProtoAnalizer.Stop();
        }
    }
}
