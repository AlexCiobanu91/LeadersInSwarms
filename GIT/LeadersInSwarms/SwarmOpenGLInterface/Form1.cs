using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace SwarmOpenGLInterface
{
    public partial class Form1 : Form
    {

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            cbLeaderType.SelectedIndex = 2;
            cbSimulationType.SelectedIndex = 1;
            tbNumberOfObstacles.Value = 0;
            tbNumberOfAgents.Value = 1000;
            tbNumberOfLeaders.Value = 1;

            txtNumberOfAgents.Text = "" + 1000;
            txtNumberOfObstacles.Text = "" + 0;
            txtNumberOfLeaders.Text = "" + 1;

            gbLeaderShapes.Visible = chkShapeForming.Checked;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            tabCtrl.SelectedIndexChanged += tabCtrl_SelectedIndexChanged;
            
        }

        private void btnLaunch_Click(object sender, EventArgs e)
        {
            Directory.CreateDirectory("Data");

            int na = int.Parse(txtNumberOfAgents.Text);
            int l = int.Parse(txtNumberOfLeaders.Text);
            int o = int.Parse(txtNumberOfObstacles.Text);
            int lt = 0;
            int at = 0;
            int st = 0;
            int shape1 = 0;
            int shape2 = 0;
            int shape3 = 0;
            int shape4 = 0;
            int shape5 = 0;
            int shape6 = 0;
            int shape7 = 0;
            int shape8 = 0;
            
             switch (cbSimulationType.SelectedIndex)
             {
                 case 0:
                     st = 0;
                     break;
                 case 1:
                     st = 1;
                     break;
             }
             
            
            switch (cbAvoidanceType.SelectedIndex)
            {
                case 0:
                    at = 0;
                    break;
                case 1:
                    at = 1;
                    break;
            }
            
            
            switch (cbLeaderType.SelectedIndex)
            {
                case 0:
                    lt = 1;
                    break;
                case 1:
                    lt = 2;
                    break;
                case 2:
                    lt = 7;
                    break;
                case 3:
                    at = 2;
                    lt = 8;
                    break;
                case 4:
                    at = 2;
                    lt = 9;
                    break;
            }
            if (rbCircle1.Checked) shape1 = 0;
            if (rbSquare1.Checked) shape1 = 1;
            if (rbTriangle1.Checked) shape1 = 2;

            if (rbCircle2.Checked) shape2 = 0;
            if (rbSquare2.Checked) shape2 = 1;
            if (rbTriangle2.Checked) shape2 = 2;

            if (rbCircle3.Checked) shape3 = 0;
            if (rbSquare3.Checked) shape3 = 1;
            if (rbTriangle3.Checked) shape3 = 2;

            if (rbCircle4.Checked) shape4 = 0;
            if (rbSquare4.Checked) shape4 = 1;
            if (rbTriangle4.Checked) shape4 = 2;

            if (rbCircle5.Checked) shape5 = 0;
            if (rbSquare5.Checked) shape5 = 1;
            if (rbTriangle5.Checked) shape5 = 2;

            if (rbCircle6.Checked) shape6 = 0;
            if (rbSquare6.Checked) shape6 = 1;
            if (rbTriangle6.Checked) shape6 = 2;

            if (rbCircle7.Checked) shape7 = 0;
            if (rbSquare7.Checked) shape7 = 1;
            if (rbTriangle7.Checked) shape7 = 2;

            if (rbCircle8.Checked) shape8 = 0;
            if (rbSquare8.Checked) shape8 = 1;
            if (rbTriangle8.Checked) shape8 = 2;

            int od = chkDynamicObstable.Checked ? 1 : 0;
            int fs = chkFullScreen.Checked ? 1 : 0;
            int sf = chkShapeForming.Checked ? 1 : 0;
            string filename = ".\\Data\\test";

            string fis = filename;
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.WorkingDirectory = Directory.GetCurrentDirectory();
            startInfo.FileName = @"SwarmOpenGLCUDA.exe";

            startInfo.Arguments = na + " " + l + " " + o + " " + lt + " " + at + " " + od + " " + fs + " " + st + " " + sf + " " + shape1 + " " + shape2 + " " + shape3 + " " + shape4 + " " + shape5 + " " + shape6 + " " + shape7 + " " + shape8 + " " + fis;

            var process = new Process
            {
                StartInfo = startInfo
            };

            process.Start();
            process.WaitForExit();
            
            /*
            foreach (int od in new List<int>() { 0, 1 })
            {
                foreach (int o in new List<int>() { 1, 2, 4, 8})
                {
                    string filename = ".\\Data\\1000_o" + o + "_at" + 2 + "_od" + od;
                    Directory.CreateDirectory(filename);

                    for (int i = 0; i < 6; i++)
                    {
                        ProcessStartInfo startInfo = new ProcessStartInfo();
                        startInfo.WorkingDirectory = Directory.GetCurrentDirectory();
                        startInfo.FileName = @"SwarmOpenGLCUDA.exe";

                        string fis = filename + "\\" + i + "_";
                        // startInfo.Arguments = 1 + " " + o + " " + 1 + " " + 2 + " " + 0 + " " + fis;
                        startInfo.Arguments = 1 + " " + o + " " + 9 + " " + 2 + " " + od + " " + 0 + " " + 0 + " " + fis;

                        var process = new Process
                        {
                            StartInfo = startInfo
                        };

                        process.Start();
                        process.WaitForExit();
                    }
                }
            }
            
            int fs = 0;
            foreach (int st in new List<int>() {1})
            {
                foreach (int od in new List<int>() {1})
                {
                    foreach (int o in new List<int>() {8 })
                    {
                        foreach (int lt in new List<int>() {2, 7})
                        {

                            foreach (int l in new List<int>() {1, 2})
                            {
                                string filename = ".\\Data\\1000_l" + l +
                                                      "_o" + o +
                                                      "_lt" + lt +
                                                      "_at" + 0 +
                                                      "_od" + od +
                                                      "_st" + st;

                                Directory.CreateDirectory(filename);

                                for (int i = 6; i < 16; i++)
                                {
                                    string fis = filename + "\\" + i + "_";
                                    ProcessStartInfo startInfo = new ProcessStartInfo();
                                    startInfo.WorkingDirectory = Directory.GetCurrentDirectory();
                                    startInfo.FileName = @"SwarmOpenGLCUDA.exe";

                                    startInfo.Arguments = l + " " + o + " " + lt + " " + 0 + " " + od + " " + fs + " " + st + " " + fis;

                                    var process = new Process
                                    {
                                        StartInfo = startInfo
                                    };

                                    process.Start();
                                    process.WaitForExit();
                                }
                            }
                        }

                    }
                }
            }
            */
            
        }

        private void btnLaunchBatch_Click(object sender, EventArgs e)
        {
            for (int o = 1; o <= 8; o *= 2)
            {
                string filename = ".\\Data\\1000_o" + o + "_at" + 2;
                Directory.CreateDirectory(filename);

                for (int i = 0; i < 10; i++)
                {
                    ProcessStartInfo startInfo = new ProcessStartInfo();
                    startInfo.WorkingDirectory = Directory.GetCurrentDirectory();
                    startInfo.FileName = @"SwarmOpenGLCUDA.exe";

                    string fis = filename + "\\" + i + "_";
                    startInfo.Arguments = 1 + " " + o + " " + 1 + " " + 2 + " " + 0 + " " + fis;

                    var process = new Process
                    {
                        StartInfo = startInfo
                    };

                    process.Start();
                    process.WaitForExit();
                }
            }

            foreach (int l in new List<int>() { 1, 2, 4, 8 })
            {
                foreach (int o in new List<int>() { 1, 2, 4, 8, 16 })
                {
                    foreach (int lt in new List<int>() { 1, 2 })
                    {
                        foreach (int at in new List<int>() { 0, 1 })
                        {
                            foreach (int od in new List<int>() { 0, 1 })
                            {
                                string filename = ".\\Data\\1000_l" + l +
                                                      "_o" + o +
                                                      "_lt" + lt +
                                                      "_at" + at +
                                                      "_od" + 0;

                                Directory.CreateDirectory(filename);

                                for (int i = 100; i < 101; i++)
                                {
                                    string fis = filename + "\\" + i + "_";
                                    ProcessStartInfo startInfo = new ProcessStartInfo();
                                    startInfo.WorkingDirectory = Directory.GetCurrentDirectory();
                                    startInfo.FileName = @"SwarmOpenGLCUDA.exe";


                                    startInfo.Arguments = l + " " + o + " " + lt + " " + at + " " + 0 + " " + fis;

                                    var process = new Process
                                    {
                                        StartInfo = startInfo
                                    };

                                    process.Start();
                                    process.WaitForExit();
                                }
                            }
                        }
                    }
                }
            }
        }

        private void tbNumberOfObstacles_Scroll(object sender, EventArgs e)
        {
            txtNumberOfObstacles.Text = tbNumberOfObstacles.Value.ToString();
        }

        private void tbNumberOfAgents_Scroll(object sender, EventArgs e)
        {
            txtNumberOfAgents.Text = tbNumberOfAgents.Value.ToString();
        }

        private void ShowLeaderShapes()
        {
            if (chkShapeForming.Checked)
            {
                switch (tbNumberOfLeaders.Value)
                {
                    case 8:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = true;
                        gbLeader5.Visible = true;
                        gbLeader6.Visible = true;
                        gbLeader7.Visible = true;
                        gbLeader8.Visible = true;
                        break;
                    case 7:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = true;
                        gbLeader5.Visible = true;
                        gbLeader6.Visible = true;
                        gbLeader7.Visible = true;
                        gbLeader8.Visible = false;
                        break;
                    case 6:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = true;
                        gbLeader5.Visible = true;
                        gbLeader6.Visible = true;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 5:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = true;
                        gbLeader5.Visible = true;
                        gbLeader6.Visible = false;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 4:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = true;
                        gbLeader5.Visible = false;
                        gbLeader6.Visible = false;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 3:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = true;
                        gbLeader4.Visible = false;
                        gbLeader5.Visible = false;
                        gbLeader6.Visible = false;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 2:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = true;
                        gbLeader3.Visible = false;
                        gbLeader4.Visible = false;
                        gbLeader5.Visible = false;
                        gbLeader6.Visible = false;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 1:
                        gbLeaderShapes.Visible = true;
                        gbLeader1.Visible = true;
                        gbLeader2.Visible = false;
                        gbLeader3.Visible = false;
                        gbLeader4.Visible = false;
                        gbLeader5.Visible = false;
                        gbLeader6.Visible = false;
                        gbLeader7.Visible = false;
                        gbLeader8.Visible = false;
                        break;
                    case 0:
                        gbLeaderShapes.Visible = false;
                        chkShapeForming.Checked = false;
                        break;
                }
            }

            if (!chkShapeForming.Checked)
            {
                tabCtrl.Width = 300;
            }
            else
            {
                tabCtrl.Width = 600;
            }
        }
        private void tbNumberOfLeaders_Scroll(object sender, EventArgs e)
        {
            txtNumberOfLeaders.Text = tbNumberOfLeaders.Value.ToString();
            ShowLeaderShapes();           
        }

        private void txtNumberOfAgents_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtNumberOfAgents.Text))
            {
                int numberOfAgents = Int32.Parse(txtNumberOfAgents.Text);
                if (numberOfAgents > 4000)
                {
                    tbNumberOfAgents.Value = 4000;
                    txtNumberOfAgents.Text = "" + 4000;
                }

                if (numberOfAgents < 0)
                {
                    tbNumberOfAgents.Value = 0;
                    txtNumberOfAgents.Text = "" + 0;
                }
                tbNumberOfAgents.Value = numberOfAgents;
            }

        }
        private void txtNumberOfObstacles_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtNumberOfObstacles.Text))
            {
                int numberOfObstacles = Int32.Parse(txtNumberOfObstacles.Text);
                if (numberOfObstacles > 10)
                {
                    tbNumberOfObstacles.Value = 10;
                    txtNumberOfObstacles.Text = "" + 10;
                }

                if (numberOfObstacles < 0)
                {
                    tbNumberOfObstacles.Value = 0;
                    txtNumberOfObstacles.Text = "" + 0;
                }
                tbNumberOfObstacles.Value = numberOfObstacles;
            }
        }
        private void txtNumberOfLeaders_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtNumberOfLeaders.Text))
            {
                int numberOfLeaders = Int32.Parse(txtNumberOfLeaders.Text);
                if (numberOfLeaders > 8)
                {
                    tbNumberOfLeaders.Value = 8;
                    txtNumberOfLeaders.Text = "" + 8;
                }
                else if (numberOfLeaders < 0)
                {
                    tbNumberOfLeaders.Value = 0;
                    txtNumberOfLeaders.Text = "" + 0;
                }
                else
                {
                    tbNumberOfLeaders.Value = numberOfLeaders;
                }
            }
            ShowLeaderShapes();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            ProcessStartInfo sInfo = new ProcessStartInfo("https://github.com/flamecata");
            Process.Start(sInfo);
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            ProcessStartInfo sInfo = new ProcessStartInfo("https://www.linkedin.com/in/alexandru-catalin-ciobanu-680030104/");
            Process.Start(sInfo);
        }

        private void linkLabel3_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            ProcessStartInfo sInfo = new ProcessStartInfo("https://www.facebook.com/flamecata");
            Process.Start(sInfo);     
        }

        private void linkLabel4_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(string.Format(@"mailto:alexandrucatalin.ciobanu@gmail.com?subject=Leaders%20in%20swarms"));
        }

        private void chkShapeForming_CheckedChanged(object sender, EventArgs e)
        {
            gbLeaderShapes.Visible = chkShapeForming.Checked;
            ShowLeaderShapes();
          
        }

        private void tabCtrl_SelectedIndexChanged(Object sender, EventArgs e)
        {
            switch (tabCtrl.SelectedIndex)
            {
                case 0:
                    chkShapeForming.Checked = true;
                    break;
                case 1:
                    chkShapeForming.Checked = false;
                    break;
            }
        }
    }
}

