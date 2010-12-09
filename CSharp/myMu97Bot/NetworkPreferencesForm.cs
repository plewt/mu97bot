using System;
using System.Windows.Forms;
using System.Net;
using SharpPcap;
using DudEeer.myMu97Bot.Properties;

namespace DudEeer.myMu97Bot
{
    public partial class NetworkPreferencesForm : Form
    {
        private Settings mySettings = new Settings(); 
        public NetworkPreferencesForm()
        {
            InitializeComponent();
        }

        private void PreferencesForm_Load(object sender, EventArgs e)
        {
            string strIP = null;
            LivePcapDeviceList devices = LivePcapDeviceList.Instance;
            if (devices.Count > 0)
            {
                foreach (LivePcapDevice ip in devices)
                {
                    strIP = ip.Name;
                    cbSelfIp.Items.Add(strIP);
                }
                if (cbSelfIp.Items.Count == 0)
                {
                    throw new Exception("Error : No network interfaces found!");
                }

                if (cbSelfIp.Items.Contains(mySettings.SelfIp))
                {
                    cbSelfIp.SelectedIndex = cbSelfIp.Items.IndexOf(mySettings.SelfIp);
                }
                else
                {
                    cbSelfIp.SelectedIndex = 0;
                }

                tbServerIp.Text = mySettings.ServerIp;
            }
        }

        private void bCancel_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            Close();
        }

        private void bOk_Click(object sender, EventArgs e)
        {
            mySettings.ServerIp = tbServerIp.Text;
            mySettings.SelfIp = cbSelfIp.Text;
            mySettings.Save();
            DialogResult = DialogResult.OK;
            Close();
        }
    }
}
