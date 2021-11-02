
namespace NavigateItemsPoolForm
{
    partial class Form1
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
            this.ButtonPreviousItem = new System.Windows.Forms.Button();
            this.ButtonNextItem = new System.Windows.Forms.Button();
            this.comboBox1 = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // ButtonPreviousItem
            // 
            this.ButtonPreviousItem.Location = new System.Drawing.Point(157, 220);
            this.ButtonPreviousItem.Name = "ButtonPreviousItem";
            this.ButtonPreviousItem.Size = new System.Drawing.Size(133, 56);
            this.ButtonPreviousItem.TabIndex = 0;
            this.ButtonPreviousItem.Text = "Previous Item";
            this.ButtonPreviousItem.UseVisualStyleBackColor = true;
            this.ButtonPreviousItem.Click += new System.EventHandler(this.OnClickButtonPreviousItem);
            // 
            // ButtonNextItem
            // 
            this.ButtonNextItem.Location = new System.Drawing.Point(340, 220);
            this.ButtonNextItem.Name = "ButtonNextItem";
            this.ButtonNextItem.Size = new System.Drawing.Size(133, 56);
            this.ButtonNextItem.TabIndex = 1;
            this.ButtonNextItem.Text = "Next Item";
            this.ButtonNextItem.UseVisualStyleBackColor = true;
            this.ButtonNextItem.Click += new System.EventHandler(this.OnClickButtonNexItem);
            // 
            // comboBox1
            // 
            this.comboBox1.FormattingEnabled = true;
            this.comboBox1.Items.AddRange(new object[] {
            "TV-Series",
            "Movies",
            "Music Videos",
            "Music Audios",
            "Source Code",
            "Readings"});
            this.comboBox1.Location = new System.Drawing.Point(37, 35);
            this.comboBox1.Name = "comboBox1";
            this.comboBox1.Size = new System.Drawing.Size(121, 21);
            this.comboBox1.TabIndex = 2;
            this.comboBox1.SelectedValueChanged += new System.EventHandler(this.OnSelectedValueChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(656, 326);
            this.Controls.Add(this.comboBox1);
            this.Controls.Add(this.ButtonNextItem);
            this.Controls.Add(this.ButtonPreviousItem);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.Text = "Navigate Items Pool - Form";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button ButtonPreviousItem;
        private System.Windows.Forms.Button ButtonNextItem;
        private System.Windows.Forms.ComboBox comboBox1;
    }
}

