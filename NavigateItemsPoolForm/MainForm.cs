using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NavigateItemsPoolForm
{
    public partial class MainForm : Form
    {
        #region Delegates or/and Events

        delegate void AsyncOperationReturn(object sender, string operation);

        #endregion

        #region Properties and Fields

        System.Text.Encoding Encoding => System.Text.Encoding.UTF8;
        string PipeMessageSeparator => "#";
        string ServerPipeName => "."; // Remote computer, '.' for local
        string ClientPipeName => "ItemsPoolPipeServer";
        int FeedbackDelayInMilliseconds => 10000;

        CancellationToken PipeReadCancellationToken = new CancellationToken(false);
        CancellationToken FeedbackCancellationToken = new CancellationToken(false);
        Task FeedbackFromServerTask = null;
        System.Drawing.Size ReferenceTextCharacterSize = default;
        System.IO.Pipes.NamedPipeClientStream Pipe = null;
        Color VerboseTextBoxForeColor;
        event AsyncOperationReturn PipeWriteAsyncReturn;

        #endregion

        public MainForm()
        {
            InitializeComponent();
            this.ItemsCategoryComboBox.SelectedIndex = 1;
            this.ItemsSourceComboBox.SelectedIndex = 0;
            this.NavigationModeCheckedListBox.CheckOnClick = true;
            this.NavigationModeCheckedListBox.SetItemChecked(0, true);
            ReferenceTextCharacterSize = AssessTextCharacterSize();
            PipeWriteAsyncReturn += new AsyncOperationReturn(this.OnReturningFromAsyncPipeOperation);

        } // MainForm

        #region Event Handlers

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

        } // OnVerboseTextBoxTextChanged

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

        } // OnCommandButtonClicked

        private void OnFeedbackPanelOkButtonClicked(object sender, EventArgs e)
        {
            try
            {
                HideFeedbackPanel();
                FeedbackCancellationToken = new CancellationToken(true);
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine
                (
                    "OnFeedbackPanelOkButtonClicked: " + ex.Message
                );
            }

        } // OnFeedbackPanelOkButtonClicked

        private void OnSelectedValueChanged(object sender, EventArgs e)
        {
            System.Windows.Forms.ComboBox box = sender as System.Windows.Forms.ComboBox;

        } // OnSelectedValueChanged

        private void OnClickFeedbackPanel(object sender, EventArgs e)
        {
            try
            {
                HideFeedbackPanel();
                FeedbackCancellationToken = new CancellationToken(true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnClickFeedbackPanel: " + ex.Message);
            }

        } // OnClickFeedbackPanel

        private void OnFeedbackRichTextBoxTextChanged(object sender, EventArgs e)
        {
            try
            {
                var box = sender as RichTextBox;
                // Adapt size
                var textSize = RichTextAreaSize(box.Text);
                int height = textSize["Height"] * ReferenceTextCharacterSize.Height;
                int width = textSize["Width"] * ReferenceTextCharacterSize.Width;
                // Adapt to feedback panel
                width = this.FeedbackPanel.Size.Width <= width ?
                        this.FeedbackPanel.Size.Width :
                        width;
                height = this.FeedbackPanel.Size.Height <= height ?
                         this.FeedbackPanel.Size.Height :
                         height;
                box.Size = new System.Drawing.Size(width, height);
                // Center Feedback text box
                int X = this.FeedbackPanel.Size.Width > box.Size.Width ?
                        (this.FeedbackPanel.Size.Width - box.Size.Width) / 2 :
                        0;
                int Y = this.FeedbackPanel.Size.Height > box.Size.Height ?
                        (this.FeedbackPanel.Size.Height - box.Size.Height) / 2 :
                        0;
                Point location = box.Location;
                location.X = X;
                location.Y = Y;
                box.Location = location;
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine
                (
                    "OnFeedbackRichTextBoxTextChanged: " + ex.Message
                );
            }

        } // OnFeedbackRichTextBoxTextChanged

        /// <summary>
        ///     Responds to a returning from a WriteAsync pipe operation by giving
        ///     feedback to User and waiting server's feedback.
        /// </summary>
        /// <param name="sender"> The async pipe task </param>
        /// <param name="operation"> Specifies the command string </param>
        private void OnReturningFromAsyncPipeOperation(object sender, string operation)
        {
            try
            {
                Task task = sender as Task;

                WriteVerbose($"Feedback UI to {{{operation}}} ... ", true);

                // Some milliseconds to complete and we are good
                Task.Delay(1000);
                // Give feedback for async task operation
                GiveFeedbackToUiInput(task, operation);

                WriteVerbose("OK");

                // Wait for server's feedback
                int size = 1024;
                var buffer = new byte[size];
                string data = System.String.Empty;

                if (null == Pipe)
                {
                    return;
                }

                WriteVerbose("Waiting for response from server ... ", true);
                
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
                            "OnReturningFromAsyncPipeOperation#Connect: " + ex.Message
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
                    try
                    {
                        // Some milliseconds for the server to respond and we are good
                        Task.Delay(5000);
                        var T = Pipe.ReadAsync
                        (
                            buffer, 0, 1, PipeReadCancellationToken
                        );
                        if (T.IsCompleted)
                        {
                            int N = T.Result;
                            if (N > 0)
                            {
                                data += Encoding.GetString(buffer);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine
                        (
                            "OnReturningFromAsyncPipeOperation#ReadAsync: " +
                            ex.Message
                        );
                    }

                    // Write feedback to user
                    if (!System.String.IsNullOrEmpty(data))
                    {
                        WriteVerbose("OK");

                        string message =
                        InterpreteFeedbackFromPipeServerStream(data);

                        // Fire feedback event
                        GiveFeedbackToUiInput(task, message, false);

                        data = System.String.Empty;
                    }
                    else
                    {
                        WriteVerbose("No Response");
                    }
                }
                else
                {
                    WriteVerbose("Disconnected");
                }
                
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine
                (
                    "OnReturningFromAsyncPipeOperation: " + ex.Message
                );
            }

        } // OnReturningFromAsyncPipeOperation

        #endregion

        #region Helper Methods

        private void HideFeedbackPanel()
        { 
            try
            {
                this.FeedbackPanel.SendToBack();
                this.FeedbackPanel.Visible = false;
                this.FeedbackRichTextBox.Visible = false;
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("HideFeedbackPanel: " + ex.Message);
            }

        } // HideFeedbackPanel

        private void ShowFeedbackPanel()
        {
            try
            {
                this.FeedbackPanel.BringToFront();
                this.FeedbackPanel.Visible = true;
                this.FeedbackRichTextBox.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ShowFeedbackPanel: " + ex.Message);
            }

        } // ShowFeedbackPanel

        /// <summary>
        ///     Calculates the number of lines and the length of the longest line of a rich text.
        /// </summary>
        /// <param name="richText">Multi-line rich text string </param>
        /// <returns> A {Height: number of lines, Width: length of longest line} dictionary</returns>
        private Dictionary<string, int> RichTextAreaSize(string richText)
        {
            Dictionary<string, int> textSize = null;

            try
            {
                var ary = new string[] { "\n", "\r", "\r\n" };
                var lines = richText.Split(ary, StringSplitOptions.RemoveEmptyEntries);
                // Longest line length
                int length = 0;
                foreach (string line in lines)
                {
                    int l = line.Length;
                    if (l > length)
                    {
                        length = l;
                    }
                }
                textSize = new Dictionary<string, int>();
                textSize["Height"] = lines.Count();
                textSize["Width"] = length;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("RichTextAreaSize: " + ex.Message);
            }

            return textSize;

        } // RichTextAreaSize

        /// <summary>
        ///     Assesses the view port size of a text character according to original font
        /// </summary>
        /// <param name="reference"> Reference RichTextBox object mocked in UI visual design </param>
        /// <returns>Size object of a rich text character </returns>
        /// <details>
        ///     Must run when we know the text fits well in reference text box.
        ///     For example, in constructor, after components initialization,
        ///     assuming satisfying visual UI design.
        /// </details>
        private System.Drawing.Size AssessTextCharacterSize(RichTextBox reference=null)
        {
            Size Size = default;

            try
            { 
                if(null == reference)
                {
                    reference = this.FeedbackRichTextBox;
                }

                var textSize = RichTextAreaSize(reference.Text);
                // Reference rich text character font size
                int height = (int)Math.Ceiling
                (
                    (double)reference.Size.Height / (double)textSize["Height"]
                );
                int width = (int)Math.Ceiling
                (
                    (double)reference.Size.Width / (double)textSize["Width"]
                );

                Size = new Size(width, height);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AssessTextCharacterSize: " + ex.Message);
            }

            return Size;

        } // AssessTextCharacterSize

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

        } // WriteVerbose

        private void WriteFeedback(string message)
        {
            try
            {
                string msg = message;

                // Show feedback
                this.FeedbackRichTextBox.Text = msg;
                ShowFeedbackPanel();
                // Flip feedback cancellation token
                FeedbackCancellationToken = new CancellationToken(true);
                Task.Delay(500);
                FeedbackCancellationToken = new CancellationToken(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("WriteFeedback: " + ex.Message);
            }

        } // WriteFeedback

        private string InterpreteFeedbackFromPipeServerStream(string data)
        {
            string message = System.String.Empty;

            try
            {
                var strings = data.Split('#');
                string feedback = System.String.Empty;
                if (strings.Count() == 5)
                {
                    feedback = $"Status:  {strings[0]}\r\n" + 
                               $"Command: '{strings[1]}' on " +
                               $"'{strings[2]}' from " +
                               $"'{strings[3]}' \r\n" + 
                               $"Date:    {strings[4]}";
                }
                else
                {
                    feedback = $"Status: {strings[0]}\r\n";
                }

                message = feedback;
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

        private void GiveFeedbackToUiInput(Task task, string operation, bool noStatus=true)
        {
            try
            { 
                string msg = operation;
                string status = System.String.Empty;
                if (noStatus)
                {
                    try
                    {
                        if (task.IsCanceled)
                        {
                            status = "Status: Canceled";
                        }
                        else if (task.IsFaulted)
                        {
                            status = "Status: Faulted";
                        }
                        else if (task.IsCompleted)
                        {
                            status = "Status: Completed";
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine
                        (
                            "GiveFeedbackToUiInput: " + ex.Message
                        );
                    }

                    if (!string.IsNullOrEmpty(status) && !string.IsNullOrEmpty(operation))
                    {
                        string richText = $"{status}\r\n{operation}";

                        WriteFeedback(richText);
                    }
                }
                else
                {
                    WriteFeedback(operation);
                }

            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine
                (
                    "GiveFeedbackToUiInput: " + ex.Message
                );
            }

        } // GiveFeedbackToUiInput

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
                    Pipe = new System.IO.Pipes.NamedPipeClientStream
                    (
                        ServerPipeName, ClientPipeName, 
                        System.IO.Pipes.PipeDirection.InOut,
                        System.IO.Pipes.PipeOptions.Asynchronous
                    );
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
                    WriteVerbose(verbose, false, "Green");

                    string message = command + PipeMessageSeparator + 
                                     itemCategory + PipeMessageSeparator + 
                                     itemSource;

                    var buffer = Encoding.GetBytes(message);
                    var task = Pipe.WriteAsync(buffer, 0, 1);

                    string operation = $"'{command}' on '{itemCategory}' from '{itemSource}'";
                    PipeWriteAsyncReturn(task, operation);
                }
                else
                {
                    verbose = "ERROR";
                    WriteVerbose(verbose, false, "Red");
                    string message = $"Status: Pipe not connected\r\n" +
                                     $"Command '{command}' on '{itemCategory}' from '{itemSource}'";
                    WriteFeedback(message);
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

        } // NavigateItemsPool

        #endregion
    
    }
}
