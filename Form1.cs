using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;

namespace NetworkScanUsingPowershell
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        List<string> paths = new List<string>();
        int i1 = 0;
        int i2 = 0;
        void writeFile()
        {
            if (paths.Count() == 0)
            {
                if (MessageBox.Show("Chưa có chức năng nào được chọn!") == DialogResult.OK)
                {
                    return;
                };

            }
            sfdSave.Filter = "PowerShell file (*.ps1)|*.ps1";
            if (sfdSave.ShowDialog() == DialogResult.OK)
            {
                StreamWriter writer = new StreamWriter(sfdSave.OpenFile());
                paths.ForEach(path =>
                {
                    StreamReader reader = new StreamReader(path);
                    string ln;
                    while ((ln = reader.ReadLine()) != null)
                    {
                        writer.WriteLine(ln);
                    }
                    reader.Dispose();
                    reader.Close();
                });  
                writer.Dispose();
                writer.Close();              
            }
            else
            {
                btnNetworkScan.BackColor = Color.LightSteelBlue;
            }
        }
        private void btnNetworkScan_Click(object sender, EventArgs e)
        {
            i1++;

            string currentDirectory = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);
            string fullPath = currentDirectory + @"\NetworkScanUsingPowershell.ps1";

            if (i1 == 1)
            {
                btnNetworkScan.BackColor = Color.Violet;

                paths.Add(fullPath);
            }
            if (i1 == 2)
            {
                i1 = 0;
            }
            if (i1 == 0)
            {
                btnNetworkScan.BackColor = Color.LightSteelBlue;
                paths.Remove(fullPath);
            }
            
        }

        private void btnFilesScan_Click(object sender, EventArgs e)
        {
            i2++;
            string currentDirectory = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);
            string fullPath = currentDirectory + @"\FilesScanUsingPowershell.ps1";
            if (i2 == 1)
            {

                paths.Add(fullPath);
            }
            if (i2 == 2)
            {
                i2 = 0;
            }
            if (i2 == 0)
            {
                paths.Remove(fullPath);
            }

        }
        private void btnCreate_Click(object sender, EventArgs e)
        {
            writeFile();
            paths.Clear();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {

            btnNetworkScan.BackColor = Color.LightSteelBlue;
            paths.Clear();
        }
    }
}
