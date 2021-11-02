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
    public partial class Form1 : Form
    {
        System.Text.Encoding Encoding => System.Text.Encoding.UTF8;
        System.IO.Pipes.NamedPipeClientStream Pipe = null;

        public Form1()
        {
            InitializeComponent();
        }

        private void OnClickButtonPreviousItem(object sender, EventArgs e)
        {
            try
            {
                NavigateItemsPool(this.comboBox1.SelectedItem, "Previous");
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnClickButtonPreviousItem: " + ex.Message);
            }
        }

        private void OnClickButtonNexItem(object sender, EventArgs e)
        {
            try
            {
                NavigateItemsPool(this.comboBox1.SelectedItem, "Next");
                
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OnClickButtonNexItem: " + ex.Message);
            }
        }

        private void OnSelectedValueChanged(object sender, EventArgs e)
        {
            System.Windows.Forms.ComboBox box = sender as System.Windows.Forms.ComboBox;
        }

        private void NavigateItemsPool(object itemType, string command)
        {
            try
            {
                switch (itemType.ToString())
                {
                    case "TV-Series":
                        break;
                    case "Movies":
                        if (null == Pipe)
                        {
                            Pipe = new System.IO.Pipes.NamedPipeClientStream("VideosPool");// "FormPipe", System.IO.Pipes.PipeDirection.InOut);

                        }

                        if (!Pipe.IsConnected)
                        {
                            Pipe.Connect(1000);
                        }

                        if (Pipe.IsConnected)
                        {
                            Pipe.FlushAsync();
                            var buffer = Encoding.GetBytes(command);
                            Pipe.WriteAsync(buffer, 0, buffer.Count());
                        }
                        break;
                    case "Music Videos":
                        break;
                    case "Music Audios":
                        break;
                    case "Readings":
                        break;
                    case "Source Code":
                        break;
                }
            }
            catch(Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("NavigateItemsPool: " + ex.Message);
            }
            finally
            {
                if(null != Pipe)
                {
                    Pipe.FlushAsync();
                    Pipe.Close();
                    Pipe.Dispose();
                }
            }
        }
    }
}
