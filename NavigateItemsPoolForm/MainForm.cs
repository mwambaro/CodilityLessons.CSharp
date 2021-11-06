using System;
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
    public partial class MainForm : Form
    {
        System.Text.Encoding Encoding => System.Text.Encoding.UTF8;
        string PipeMessageSeparator => "#";
        string ClientPipeName => "ItemsPoolPipe12";
        Task FeedbackFromServerTask = null;
        System.IO.Pipes.NamedPipeClientStream Pipe = null;
        Task PipeWriteTask = null;
        Color VerboseTextBoxForeColor;

        public MainForm()
        {
            InitializeComponent();
            this.ItemsCategoryComboBox.SelectedIndex = 1;
            this.ItemsSourceComboBox.SelectedIndex = 0;
            this.NavigationModeCheckedListBox.CheckOnClick = true;
            this.NavigationModeCheckedListBox.SetItemChecked(0, true);
            FeedbackFromServerTask = HandleFeedbackFromPipeServerStream();
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

        private void OnClickFeedbackPanel(object sender, EventArgs e)
        {
            try
            {
                var layout = sender as Panel;
                layout.SendToBack();
                layout.Visible = false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnClickFeedBackFlowLayoutPanel: " + ex.Message);
            }
        }

        private void OnFeedbackLabelTextChanged(object sender, EventArgs e)
        {
            try
            {
                var label = sender as Label;
                // Center FeedbackLabel
                int X = (this.FeedbackPanel.Size.Width - label.Size.Width) / 2;
                int Y = (this.FeedbackPanel.Size.Height - label.Size.Height) / 2;
                Point location = label.Location;
                location.X = X;
                location.Y = Y;
                label.Location = location;
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnFeedbackLabelTextChanged: " + ex.Message);
            }
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

        private void WriteFeedback(string message)
        {
            try
            {
                string msg = message;

                this.FeedbackLabel.Text = msg;
                this.FeedbackLabel.BringToFront();
                var list = new System.Collections.Generic.List<string>();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("WriteFeedback: " + ex.Message);
            }
        }

        private string InterpreteFeedbackFromPipeServerStream(string data)
        {
            string message = System.String.Empty;

            try
            {
                var strings = data.Split('#');
                string status = System.String.Empty;
                string feedback = System.String.Empty;
                if (strings.Count() > 1)
                {
                    feedback = $"Command '{strings[1]}' on " +
                               $"'{strings[2]}' from " +
                               $"'{strings[3]}' [{strings[4]}]";
                    status = strings[0];
                }
                else
                {
                    feedback = System.String.Empty;
                    status = strings[0];
                }

                if (Regex.IsMatch(status, "OK"))
                {
                    message = $"{feedback} succeeded";
                }
                else if (Regex.IsMatch(status, "ERROR"))
                {
                    message = $"{feedback} failed";
                }
                else
                {
                    message = $"{feedback} met unknown error";
                }
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine
                (
                    "InterpreteFeedbackFromPipeServerStream: " + ex.Message
                );
            }

            return message;

        } // InterpreteFeedbackFromPipeServerStream

        private Task HandleFeedbackFromPipeServerStream()
        {
            Task task = Task.Factory.StartNew(new Action(async () =>
            {
                try
                {
                    bool loop = true;
                    int size = 1024;
                    var buffer = new byte[size];
                    string data = System.String.Empty;

                    if (null == Pipe)
                    {
                        Pipe = new System.IO.Pipes.NamedPipeClientStream(ClientPipeName);
                    }

                    do
                    {
                        if (null != Pipe)
                        {
                            // Check connection
                            if (!Pipe.IsConnected)
                            {
                                try
                                {
                                    Pipe.Connect(1000);
                                }
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine
                                    (
                                        "HandleFeedbackFromPipeServerStream: " + ex.Message
                                    );
                                }
                            }

                            if (Pipe.IsConnected)
                            {
                                // Clean buffer
                                for (int i = 0; i < buffer.Count(); i++)
                                {
                                    buffer[i] = Encoding.GetBytes("0")[0];
                                }
                                // Read data, if any
                                // Data format: status#command#category#source#execution_date
                                int offset = 0;
                                bool loopRead = false;

                                do
                                {
                                    var N = await Pipe.ReadAsync(buffer, offset, buffer.Count());
                                    if ((N > 0) && (N == buffer.Count())) // Possibly more data to read
                                    {
                                        loopRead = true;
                                        offset = N;
                                        data += Encoding.GetString(buffer);
                                    }
                                    else
                                    {
                                        loopRead = false;
                                        offset = 0;
                                        if (N > 0)
                                        {
                                            data += Encoding.GetString(buffer);
                                        }
                                    }
                                }
                                while (loopRead);

                                // Write feedback to user
                                if (
                                    !this.FeedbackPanel.Visible &&
                                    !System.String.IsNullOrEmpty(data)
                                )
                                {
                                    string message = InterpreteFeedbackFromPipeServerStream(data);

                                    if (!System.String.IsNullOrEmpty(message))
                                    {
                                        WriteFeedback(message);
                                    }
                                    data = System.String.Empty;
                                }
                            }
                        }
                    }
                    while (loop);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine
                    (
                        "HandleFeedbackFromPipeServerStream: " + ex.Message
                    );
                }
            }));

            return task;

        } // HandleFeedbackFromPipeServerStream

        private void NavigateItemsPool(object itmCategory, object itmSource, string command)
        {
            try
            {
                string verbose = $"Processing command '{command}' for category '{itmCategory.ToString()}' and source '{itmSource.ToString()}' ... ";
                // Feed back curtain
                bool hideFeedbackLayout = true;
                //WriteFeedback(verbose);
                this.FeedbackPanel.BringToFront();
                this.FeedbackPanel.Visible = true;

                
                WriteVerbose(verbose);
                string itemCategory = itmCategory.ToString();
                string itemSource = itmSource.ToString();

                if (null == Pipe)
                {
                    Pipe = new System.IO.Pipes.NamedPipeClientStream(ClientPipeName);// "FormPipe", System.IO.Pipes.PipeDirection.InOut);
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
                        hideFeedbackLayout = false;
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

                if(hideFeedbackLayout)
                {
                    this.FeedbackPanel.SendToBack();
                    this.FeedbackPanel.Visible = false;
                }
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("NavigateItemsPool: " + ex.Message);
            }
            finally
            {
            }
        } // NavigateItemsPool
    }
}
