
namespace NavigateItemsPoolForm
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
            this.FeedbackPanel = new System.Windows.Forms.Panel();
            this.FeedbackPanelOkButton = new System.Windows.Forms.Button();
            this.FeedbackRichTextBox = new System.Windows.Forms.RichTextBox();
            this.VerboseTextBox = new System.Windows.Forms.RichTextBox();
            this.ButtonDownload = new System.Windows.Forms.Button();
            this.ButtonUpload = new System.Windows.Forms.Button();
            this.ButtonAutomatic = new System.Windows.Forms.Button();
            this.ButtonNext = new System.Windows.Forms.Button();
            this.ButtonPrevious = new System.Windows.Forms.Button();
            this.ItemsSourceComboBox = new System.Windows.Forms.ComboBox();
            this.NavigationModeCheckedListBox = new System.Windows.Forms.CheckedListBox();
            this.ItemsCategoryComboBox = new System.Windows.Forms.ComboBox();
            this.FeedbackPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // FeedbackPanel
            // 
            this.FeedbackPanel.BackColor = System.Drawing.Color.White;
            this.FeedbackPanel.Controls.Add(this.FeedbackPanelOkButton);
            this.FeedbackPanel.Controls.Add(this.FeedbackRichTextBox);
            this.FeedbackPanel.Location = new System.Drawing.Point(12, 12);
            this.FeedbackPanel.Name = "FeedbackPanel";
            this.FeedbackPanel.Size = new System.Drawing.Size(632, 278);
            this.FeedbackPanel.TabIndex = 10;
            this.FeedbackPanel.Visible = false;
            this.FeedbackPanel.Click += new System.EventHandler(this.OnClickFeedbackPanel);
            // 
            // FeedbackPanelOkButton
            // 
            this.FeedbackPanelOkButton.Location = new System.Drawing.Point(542, 225);
            this.FeedbackPanelOkButton.Name = "FeedbackPanelOkButton";
            this.FeedbackPanelOkButton.Size = new System.Drawing.Size(75, 33);
            this.FeedbackPanelOkButton.TabIndex = 2;
            this.FeedbackPanelOkButton.Text = "OK";
            this.FeedbackPanelOkButton.UseVisualStyleBackColor = true;
            this.FeedbackPanelOkButton.Click += new System.EventHandler(this.OnFeedbackPanelOkButtonClicked);
            // 
            // FeedbackRichTextBox
            // 
            this.FeedbackRichTextBox.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.FeedbackRichTextBox.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FeedbackRichTextBox.ForeColor = System.Drawing.Color.White;
            this.FeedbackRichTextBox.Location = new System.Drawing.Point(221, 92);
            this.FeedbackRichTextBox.Name = "FeedbackRichTextBox";
            this.FeedbackRichTextBox.ReadOnly = true;
            this.FeedbackRichTextBox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.None;
            this.FeedbackRichTextBox.Size = new System.Drawing.Size(164, 67);
            this.FeedbackRichTextBox.TabIndex = 1;
            this.FeedbackRichTextBox.Text = "Feedback lines go here\nLine 2\nLine 3\nLine 4";
            this.FeedbackRichTextBox.TextChanged += new System.EventHandler(this.OnFeedbackRichTextBoxTextChanged);
            // 
            // VerboseTextBox
            // 
            this.VerboseTextBox.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.VerboseTextBox.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.VerboseTextBox.ForeColor = System.Drawing.Color.White;
            this.VerboseTextBox.Location = new System.Drawing.Point(37, 177);
            this.VerboseTextBox.Name = "VerboseTextBox";
            this.VerboseTextBox.ReadOnly = true;
            this.VerboseTextBox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical;
            this.VerboseTextBox.Size = new System.Drawing.Size(581, 143);
            this.VerboseTextBox.TabIndex = 4;
            this.VerboseTextBox.Text = "";
            this.VerboseTextBox.TextChanged += new System.EventHandler(this.OnVerboseTextBoxTextChanged);
            // 
            // ButtonDownload
            // 
            this.ButtonDownload.Location = new System.Drawing.Point(494, 115);
            this.ButtonDownload.Name = "ButtonDownload";
            this.ButtonDownload.Size = new System.Drawing.Size(75, 41);
            this.ButtonDownload.TabIndex = 9;
            this.ButtonDownload.Text = "Download";
            this.ButtonDownload.UseVisualStyleBackColor = true;
            this.ButtonDownload.Click += new System.EventHandler(this.OnCommandButtonClicked);
            // 
            // ButtonUpload
            // 
            this.ButtonUpload.Location = new System.Drawing.Point(403, 115);
            this.ButtonUpload.Name = "ButtonUpload";
            this.ButtonUpload.Size = new System.Drawing.Size(75, 41);
            this.ButtonUpload.TabIndex = 8;
            this.ButtonUpload.Text = "Upload";
            this.ButtonUpload.UseVisualStyleBackColor = true;
            this.ButtonUpload.Click += new System.EventHandler(this.OnCommandButtonClicked);
            // 
            // ButtonAutomatic
            // 
            this.ButtonAutomatic.Location = new System.Drawing.Point(298, 115);
            this.ButtonAutomatic.Name = "ButtonAutomatic";
            this.ButtonAutomatic.Size = new System.Drawing.Size(87, 41);
            this.ButtonAutomatic.TabIndex = 3;
            this.ButtonAutomatic.Text = "Automatic";
            this.ButtonAutomatic.UseVisualStyleBackColor = true;
            this.ButtonAutomatic.Click += new System.EventHandler(this.OnCommandButtonClicked);
            // 
            // ButtonNext
            // 
            this.ButtonNext.Location = new System.Drawing.Point(184, 115);
            this.ButtonNext.Name = "ButtonNext";
            this.ButtonNext.Size = new System.Drawing.Size(97, 41);
            this.ButtonNext.TabIndex = 1;
            this.ButtonNext.Text = "Next";
            this.ButtonNext.UseVisualStyleBackColor = true;
            this.ButtonNext.Click += new System.EventHandler(this.OnCommandButtonClicked);
            // 
            // ButtonPrevious
            // 
            this.ButtonPrevious.Location = new System.Drawing.Point(76, 115);
            this.ButtonPrevious.Name = "ButtonPrevious";
            this.ButtonPrevious.Size = new System.Drawing.Size(91, 41);
            this.ButtonPrevious.TabIndex = 0;
            this.ButtonPrevious.Text = "Previous";
            this.ButtonPrevious.UseVisualStyleBackColor = true;
            this.ButtonPrevious.Click += new System.EventHandler(this.OnCommandButtonClicked);
            // 
            // ItemsSourceComboBox
            // 
            this.ItemsSourceComboBox.FormattingEnabled = true;
            this.ItemsSourceComboBox.Items.AddRange(new object[] {
            "Local",
            "Youtube",
            "Vimeo",
            "One Drive",
            "Google Drive",
            "Dropbox",
            "Netflix",
            "Stream Server"});
            this.ItemsSourceComboBox.Location = new System.Drawing.Point(307, 35);
            this.ItemsSourceComboBox.Name = "ItemsSourceComboBox";
            this.ItemsSourceComboBox.Size = new System.Drawing.Size(311, 21);
            this.ItemsSourceComboBox.TabIndex = 7;
            // 
            // NavigationModeCheckedListBox
            // 
            this.NavigationModeCheckedListBox.FormattingEnabled = true;
            this.NavigationModeCheckedListBox.Items.AddRange(new object[] {
            "Loop",
            "Random",
            "Select"});
            this.NavigationModeCheckedListBox.Location = new System.Drawing.Point(184, 35);
            this.NavigationModeCheckedListBox.Name = "NavigationModeCheckedListBox";
            this.NavigationModeCheckedListBox.Size = new System.Drawing.Size(92, 49);
            this.NavigationModeCheckedListBox.TabIndex = 5;
            // 
            // ItemsCategoryComboBox
            // 
            this.ItemsCategoryComboBox.FormattingEnabled = true;
            this.ItemsCategoryComboBox.Items.AddRange(new object[] {
            "TV-Series",
            "Movies",
            "Music Videos",
            "Music Audios",
            "Source Code",
            "Readings"});
            this.ItemsCategoryComboBox.Location = new System.Drawing.Point(37, 35);
            this.ItemsCategoryComboBox.Name = "ItemsCategoryComboBox";
            this.ItemsCategoryComboBox.Size = new System.Drawing.Size(121, 21);
            this.ItemsCategoryComboBox.TabIndex = 2;
            this.ItemsCategoryComboBox.SelectedValueChanged += new System.EventHandler(this.OnSelectedValueChanged);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.ClientSize = new System.Drawing.Size(656, 326);
            this.Controls.Add(this.FeedbackPanel);
            this.Controls.Add(this.ButtonDownload);
            this.Controls.Add(this.ButtonUpload);
            this.Controls.Add(this.ItemsSourceComboBox);
            this.Controls.Add(this.NavigationModeCheckedListBox);
            this.Controls.Add(this.VerboseTextBox);
            this.Controls.Add(this.ButtonAutomatic);
            this.Controls.Add(this.ItemsCategoryComboBox);
            this.Controls.Add(this.ButtonNext);
            this.Controls.Add(this.ButtonPrevious);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "MainForm";
            this.Text = "Navigate Items Pool - Form";
            this.FeedbackPanel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Panel FeedbackPanel;
        private System.Windows.Forms.RichTextBox VerboseTextBox;
        private System.Windows.Forms.Button ButtonDownload;
        private System.Windows.Forms.Button ButtonUpload;
        private System.Windows.Forms.Button ButtonAutomatic;
        private System.Windows.Forms.Button ButtonNext;
        private System.Windows.Forms.Button ButtonPrevious;
        private System.Windows.Forms.ComboBox ItemsSourceComboBox;
        private System.Windows.Forms.CheckedListBox NavigationModeCheckedListBox;
        private System.Windows.Forms.ComboBox ItemsCategoryComboBox;
        private System.Windows.Forms.RichTextBox FeedbackRichTextBox;
        private System.Windows.Forms.Button FeedbackPanelOkButton;
    }
}

