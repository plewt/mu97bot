namespace DudEeer.myMu97Bot
{
    partial class NetworkPreferencesForm
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
            this.lbSelfIp = new System.Windows.Forms.Label();
            this.cbSelfIp = new System.Windows.Forms.ComboBox();
            this.lbServerIp = new System.Windows.Forms.Label();
            this.tbServerIp = new System.Windows.Forms.TextBox();
            this.bOk = new System.Windows.Forms.Button();
            this.bCancel = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // lbSelfIp
            // 
            this.lbSelfIp.AutoSize = true;
            this.lbSelfIp.Location = new System.Drawing.Point(12, 9);
            this.lbSelfIp.Name = "lbSelfIp";
            this.lbSelfIp.Size = new System.Drawing.Size(71, 13);
            this.lbSelfIp.TabIndex = 0;
            this.lbSelfIp.Text = "Self aaddress";
            // 
            // cbSelfIp
            // 
            this.cbSelfIp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.cbSelfIp.FormattingEnabled = true;
            this.cbSelfIp.Location = new System.Drawing.Point(112, 6);
            this.cbSelfIp.Name = "cbSelfIp";
            this.cbSelfIp.Size = new System.Drawing.Size(206, 21);
            this.cbSelfIp.TabIndex = 1;
            // 
            // lbServerIp
            // 
            this.lbServerIp.AutoSize = true;
            this.lbServerIp.Location = new System.Drawing.Point(12, 34);
            this.lbServerIp.Name = "lbServerIp";
            this.lbServerIp.Size = new System.Drawing.Size(78, 13);
            this.lbServerIp.TabIndex = 2;
            this.lbServerIp.Text = "Server address";
            // 
            // tbServerIp
            // 
            this.tbServerIp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.tbServerIp.Location = new System.Drawing.Point(112, 31);
            this.tbServerIp.Name = "tbServerIp";
            this.tbServerIp.Size = new System.Drawing.Size(206, 20);
            this.tbServerIp.TabIndex = 3;
            // 
            // bOk
            // 
            this.bOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.bOk.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.bOk.Location = new System.Drawing.Point(159, 59);
            this.bOk.Name = "bOk";
            this.bOk.Size = new System.Drawing.Size(75, 23);
            this.bOk.TabIndex = 4;
            this.bOk.Text = "Ok";
            this.bOk.UseVisualStyleBackColor = true;
            this.bOk.Click += new System.EventHandler(this.bOk_Click);
            // 
            // bCancel
            // 
            this.bCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.bCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.bCancel.Location = new System.Drawing.Point(240, 59);
            this.bCancel.Name = "bCancel";
            this.bCancel.Size = new System.Drawing.Size(75, 23);
            this.bCancel.TabIndex = 5;
            this.bCancel.Text = "Cancel";
            this.bCancel.UseVisualStyleBackColor = true;
            this.bCancel.Click += new System.EventHandler(this.bCancel_Click);
            // 
            // PreferencesForm
            // 
            this.AcceptButton = this.bOk;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.bCancel;
            this.ClientSize = new System.Drawing.Size(331, 94);
            this.ControlBox = false;
            this.Controls.Add(this.bCancel);
            this.Controls.Add(this.bOk);
            this.Controls.Add(this.tbServerIp);
            this.Controls.Add(this.lbServerIp);
            this.Controls.Add(this.cbSelfIp);
            this.Controls.Add(this.lbSelfIp);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.Name = "PreferencesForm";
            this.Text = "Network preferences";
            this.Load += new System.EventHandler(this.PreferencesForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lbSelfIp;
        private System.Windows.Forms.ComboBox cbSelfIp;
        private System.Windows.Forms.Label lbServerIp;
        private System.Windows.Forms.TextBox tbServerIp;
        private System.Windows.Forms.Button bOk;
        private System.Windows.Forms.Button bCancel;
    }
}

