namespace DudEeer.myMu97Bot
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.startToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.startToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.pauseToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.continueToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.stopToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.propertiesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.networkConfigToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.label1 = new System.Windows.Forms.Label();
            this.lbHealth = new System.Windows.Forms.Label();
            this.lbHealthVal = new System.Windows.Forms.Label();
            this.lbMana = new System.Windows.Forms.Label();
            this.lbManaVal = new System.Windows.Forms.Label();
            this.lbPosition = new System.Windows.Forms.Label();
            this.lbPositionVal = new System.Windows.Forms.Label();
            this.lbIdVal = new System.Windows.Forms.Label();
            this.lbId = new System.Windows.Forms.Label();
            this.lbStamina = new System.Windows.Forms.Label();
            this.lbStaminaVal = new System.Windows.Forms.Label();
            this.lbNameVal = new System.Windows.Forms.Label();
            this.lbName = new System.Windows.Forms.Label();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.startToolStripMenuItem,
            this.propertiesToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(534, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // startToolStripMenuItem
            // 
            this.startToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.startToolStripMenuItem1,
            this.pauseToolStripMenuItem,
            this.continueToolStripMenuItem,
            this.stopToolStripMenuItem,
            this.toolStripSeparator1,
            this.exitToolStripMenuItem});
            this.startToolStripMenuItem.Name = "startToolStripMenuItem";
            this.startToolStripMenuItem.Size = new System.Drawing.Size(46, 20);
            this.startToolStripMenuItem.Text = "Main";
            // 
            // startToolStripMenuItem1
            // 
            this.startToolStripMenuItem1.Name = "startToolStripMenuItem1";
            this.startToolStripMenuItem1.Size = new System.Drawing.Size(123, 22);
            this.startToolStripMenuItem1.Text = "Start";
            this.startToolStripMenuItem1.Click += new System.EventHandler(this.startToolStripMenuItem1_Click);
            // 
            // pauseToolStripMenuItem
            // 
            this.pauseToolStripMenuItem.Enabled = false;
            this.pauseToolStripMenuItem.Name = "pauseToolStripMenuItem";
            this.pauseToolStripMenuItem.Size = new System.Drawing.Size(123, 22);
            this.pauseToolStripMenuItem.Text = "Pause";
            this.pauseToolStripMenuItem.Click += new System.EventHandler(this.pauseToolStripMenuItem_Click);
            // 
            // continueToolStripMenuItem
            // 
            this.continueToolStripMenuItem.Enabled = false;
            this.continueToolStripMenuItem.Name = "continueToolStripMenuItem";
            this.continueToolStripMenuItem.Size = new System.Drawing.Size(123, 22);
            this.continueToolStripMenuItem.Text = "Continue";
            this.continueToolStripMenuItem.Click += new System.EventHandler(this.continueToolStripMenuItem_Click);
            // 
            // stopToolStripMenuItem
            // 
            this.stopToolStripMenuItem.Enabled = false;
            this.stopToolStripMenuItem.Name = "stopToolStripMenuItem";
            this.stopToolStripMenuItem.Size = new System.Drawing.Size(123, 22);
            this.stopToolStripMenuItem.Text = "Stop";
            this.stopToolStripMenuItem.Click += new System.EventHandler(this.stopToolStripMenuItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(120, 6);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(123, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // propertiesToolStripMenuItem
            // 
            this.propertiesToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.networkConfigToolStripMenuItem});
            this.propertiesToolStripMenuItem.Name = "propertiesToolStripMenuItem";
            this.propertiesToolStripMenuItem.Size = new System.Drawing.Size(72, 20);
            this.propertiesToolStripMenuItem.Text = "Properties";
            // 
            // networkConfigToolStripMenuItem
            // 
            this.networkConfigToolStripMenuItem.Name = "networkConfigToolStripMenuItem";
            this.networkConfigToolStripMenuItem.Size = new System.Drawing.Size(158, 22);
            this.networkConfigToolStripMenuItem.Text = "Network Config";
            this.networkConfigToolStripMenuItem.Click += new System.EventHandler(this.networkConfigToolStripMenuItem_Click);
            // 
            // listBox1
            // 
            this.listBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.listBox1.FormattingEnabled = true;
            this.listBox1.Location = new System.Drawing.Point(0, 24);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(387, 352);
            this.listBox1.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(393, 24);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(57, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Player Info";
            // 
            // lbHealth
            // 
            this.lbHealth.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbHealth.AutoSize = true;
            this.lbHealth.Location = new System.Drawing.Point(397, 76);
            this.lbHealth.Name = "lbHealth";
            this.lbHealth.Size = new System.Drawing.Size(38, 13);
            this.lbHealth.TabIndex = 3;
            this.lbHealth.Text = "Health";
            // 
            // lbHealthVal
            // 
            this.lbHealthVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbHealthVal.AutoSize = true;
            this.lbHealthVal.Location = new System.Drawing.Point(465, 76);
            this.lbHealthVal.Name = "lbHealthVal";
            this.lbHealthVal.Size = new System.Drawing.Size(24, 13);
            this.lbHealthVal.TabIndex = 4;
            this.lbHealthVal.Text = "0/0";
            // 
            // lbMana
            // 
            this.lbMana.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbMana.AutoSize = true;
            this.lbMana.Location = new System.Drawing.Point(397, 89);
            this.lbMana.Name = "lbMana";
            this.lbMana.Size = new System.Drawing.Size(34, 13);
            this.lbMana.TabIndex = 5;
            this.lbMana.Text = "Mana";
            // 
            // lbManaVal
            // 
            this.lbManaVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbManaVal.AutoSize = true;
            this.lbManaVal.Location = new System.Drawing.Point(465, 89);
            this.lbManaVal.Name = "lbManaVal";
            this.lbManaVal.Size = new System.Drawing.Size(24, 13);
            this.lbManaVal.TabIndex = 6;
            this.lbManaVal.Text = "0/0";
            // 
            // lbPosition
            // 
            this.lbPosition.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbPosition.AutoSize = true;
            this.lbPosition.Location = new System.Drawing.Point(398, 115);
            this.lbPosition.Name = "lbPosition";
            this.lbPosition.Size = new System.Drawing.Size(44, 13);
            this.lbPosition.TabIndex = 7;
            this.lbPosition.Text = "Position";
            // 
            // lbPositionVal
            // 
            this.lbPositionVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbPositionVal.AutoSize = true;
            this.lbPositionVal.Location = new System.Drawing.Point(466, 115);
            this.lbPositionVal.Name = "lbPositionVal";
            this.lbPositionVal.Size = new System.Drawing.Size(22, 13);
            this.lbPositionVal.TabIndex = 8;
            this.lbPositionVal.Text = "0 0";
            // 
            // lbIdVal
            // 
            this.lbIdVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbIdVal.AutoSize = true;
            this.lbIdVal.Location = new System.Drawing.Point(465, 46);
            this.lbIdVal.Name = "lbIdVal";
            this.lbIdVal.Size = new System.Drawing.Size(13, 13);
            this.lbIdVal.TabIndex = 9;
            this.lbIdVal.Text = "0";
            // 
            // lbId
            // 
            this.lbId.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbId.AutoSize = true;
            this.lbId.Location = new System.Drawing.Point(397, 46);
            this.lbId.Name = "lbId";
            this.lbId.Size = new System.Drawing.Size(16, 13);
            this.lbId.TabIndex = 10;
            this.lbId.Text = "Id";
            // 
            // lbStamina
            // 
            this.lbStamina.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbStamina.AutoSize = true;
            this.lbStamina.Location = new System.Drawing.Point(397, 102);
            this.lbStamina.Name = "lbStamina";
            this.lbStamina.Size = new System.Drawing.Size(45, 13);
            this.lbStamina.TabIndex = 11;
            this.lbStamina.Text = "Stamina";
            // 
            // lbStaminaVal
            // 
            this.lbStaminaVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbStaminaVal.AutoSize = true;
            this.lbStaminaVal.Location = new System.Drawing.Point(465, 102);
            this.lbStaminaVal.Name = "lbStaminaVal";
            this.lbStaminaVal.Size = new System.Drawing.Size(24, 13);
            this.lbStaminaVal.TabIndex = 12;
            this.lbStaminaVal.Text = "0/0";
            // 
            // lbNameVal
            // 
            this.lbNameVal.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbNameVal.AutoSize = true;
            this.lbNameVal.Location = new System.Drawing.Point(465, 59);
            this.lbNameVal.Name = "lbNameVal";
            this.lbNameVal.Size = new System.Drawing.Size(50, 13);
            this.lbNameVal.TabIndex = 14;
            this.lbNameVal.Text = "No name";
            // 
            // lbName
            // 
            this.lbName.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbName.AutoSize = true;
            this.lbName.Location = new System.Drawing.Point(397, 59);
            this.lbName.Name = "lbName";
            this.lbName.Size = new System.Drawing.Size(35, 13);
            this.lbName.TabIndex = 13;
            this.lbName.Text = "Name";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(534, 376);
            this.Controls.Add(this.lbNameVal);
            this.Controls.Add(this.lbName);
            this.Controls.Add(this.lbStaminaVal);
            this.Controls.Add(this.lbStamina);
            this.Controls.Add(this.lbId);
            this.Controls.Add(this.lbIdVal);
            this.Controls.Add(this.lbPositionVal);
            this.Controls.Add(this.lbPosition);
            this.Controls.Add(this.lbManaVal);
            this.Controls.Add(this.lbMana);
            this.Controls.Add(this.lbHealthVal);
            this.Controls.Add(this.lbHealth);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.listBox1);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "MainForm";
            this.Text = "MainForm";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MainForm_FormClosing);
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem startToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem startToolStripMenuItem1;
        private System.Windows.Forms.ToolStripMenuItem pauseToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem continueToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem stopToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem propertiesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem networkConfigToolStripMenuItem;
        private System.Windows.Forms.ListBox listBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lbHealth;
        private System.Windows.Forms.Label lbHealthVal;
        private System.Windows.Forms.Label lbMana;
        private System.Windows.Forms.Label lbManaVal;
        private System.Windows.Forms.Label lbPosition;
        private System.Windows.Forms.Label lbPositionVal;
        private System.Windows.Forms.Label lbIdVal;
        private System.Windows.Forms.Label lbId;
        private System.Windows.Forms.Label lbStamina;
        private System.Windows.Forms.Label lbStaminaVal;
        private System.Windows.Forms.Label lbNameVal;
        private System.Windows.Forms.Label lbName;
    }
}