﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NavigateItemsPoolForm
{
    public partial class Form1 : Form
    {
        System.Text.Encoding Encoding => System.Text.Encoding.UTF8;
        string PipeMessageSeparator => "#";
        System.IO.Pipes.NamedPipeClientStream Pipe = null;
        Task PipeWriteTask = null;
        Color VerboseTextBoxForeColor;

        public Form1()
        {
            InitializeComponent();
            this.ItemsCategoryComboBox.SelectedIndex = 1;
            this.ItemsSourceComboBox.SelectedIndex = 0;
            this.NavigationModeCheckedListBox.SelectedIndex = 0;
        }

        private void OnVerboseTextBoxTextChanged(object sender, EventArgs e)
        {
            try
            {
                this.VerboseTextBox.ForeColor = VerboseTextBoxForeColor;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnVerboseTextBoxTextChanged: " + ex.Message);
            }
        }

        private void OnCommandButtonClicked(object sender, EventArgs e)
        {
            try
            {
                Button button = sender as Button;
                object category = this.ItemsCategoryComboBox.SelectedItem;
                object source = this.ItemsSourceComboBox.SelectedItem;
                NavigateItemsPool(category, source, button.Text);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnCommandButtonClicked: " + ex.Message);
            }
        }

        private void OnSelectedValueChanged(object sender, EventArgs e)
        {
            System.Windows.Forms.ComboBox box = sender as System.Windows.Forms.ComboBox;
        }

        private void WriteVerbose(string message, bool noNewLine=false, string ccolor="White")
        {
            try
            {
                string msg = message;
                if(!noNewLine)
                {
                    msg += "\r\n";
                }
                VerboseTextBoxForeColor = this.VerboseTextBox.ForeColor;
                this.VerboseTextBox.ForeColor = Color.FromName(ccolor);
                this.VerboseTextBox.Text += msg;
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("WriteVerbose: " + ex.Message);
            }
        }

        private void NavigateItemsPool(object itmCategory, object itmSource, string command)
        {
            try
            {
                string verbose = $"Processing command '{command}' for category '{itmCategory.ToString()}' and source '{itmSource.ToString()}' ... ";
                WriteVerbose(verbose);
                string itemCategory = itmCategory.ToString();
                string itemSource = itmSource.ToString();

                if (null == Pipe)
                {
                    Pipe = new System.IO.Pipes.NamedPipeClientStream("VideoItemsPoolPipe");// "FormPipe", System.IO.Pipes.PipeDirection.InOut);
                }

                if (!Pipe.IsConnected)
                {
                    verbose = "Pipe is not connected. Connecting ... ";
                    WriteVerbose(verbose, true);
                    try
                    {
                        Pipe.Connect(1000);
                    }
                    catch(Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine
                        (
                            "NavigateItemsPool: " + ex.Message
                        );
                    }
                }

                if (Pipe.IsConnected)
                {
                    verbose = "OK";
                    WriteVerbose(verbose, false, "Red");
                    // In case it ever makes sense to queue commands
                    // which may never occur, solved by a spinner and a feedback message.
                    bool queueCommand = false; 
                    if (null != PipeWriteTask)
                    {
                        if(!PipeWriteTask.IsCompleted)
                        {
                            queueCommand = true;
                        }
                    }

                    verbose = "Should we add command to command queue? ... ";
                    WriteVerbose(verbose, true);

                    string message = command + PipeMessageSeparator + 
                                     itemCategory + PipeMessageSeparator + 
                                     itemSource;
                    if (!queueCommand)
                    {
                        verbose = "NO";
                        WriteVerbose(verbose, false, "Green");

                        var buffer = Encoding.GetBytes(message);
                        int size = buffer.Count();
                        PipeWriteTask = Pipe.WriteAsync(buffer, 0, size);
                    }
                    else
                    {
                        verbose = "YES";
                        WriteVerbose(verbose, false, "Red");
                    }
                }
                else
                {
                    verbose = "ERROR";
                    WriteVerbose(verbose, false, "Red");
                }

                verbose = "Done Processing";
                WriteVerbose(verbose, false, "Green");
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("NavigateItemsPool: " + ex.Message);
            }
            finally
            {
            }
        }
    }
}
