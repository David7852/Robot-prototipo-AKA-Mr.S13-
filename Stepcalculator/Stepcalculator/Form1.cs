using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Stepcalculator
{
    public partial class Form1 : Form
    {
        public double diametrorueda, perimetro, eje, media, time;
        public const double DELAY = 0.022;
        public List<double> distancias;

        public int GRADOS, STEP, g,d, steps;

        public Form1()
        {
            GRADOS = 0;
            STEP = 0;
            g = 0;
            d = 0;
            steps = 0;
            diametrorueda = 0;
            perimetro = 0;
            eje = 0;
            media = 0;
            distancias=new List<double>();
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
        private void label4_Click(object sender, EventArgs e)
        {

        }
        private void label3_Click(object sender, EventArgs e)
        {

        }
        private void diametroin(object sender, EventArgs e)
        {
            if (!Double.TryParse(diametrotextb.Text,out diametrorueda))
                return;
            diametrorueda = Double.Parse(diametrotextb.Text);
        }

        private void ejein(object sender, EventArgs e)
        {
            if (!Double.TryParse(ejetextb.Text, out eje))
                return;
            eje = Double.Parse(ejetextb.Text);
        }

        private void stepsin(object sender, EventArgs e)
        {
            distancias.Clear();
            steps = (int) numericUpDown1.Value;
        }

        private void distanciain(object sender, EventArgs e)
        {
            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            double dd;
            if (!Double.TryParse(distanciatextb.Text, out dd))
                return;
            distancias.Add(Double.Parse(distanciatextb.Text));
            calmedia();
            medialabel.Text = media.ToString();
        }

        private void gradosin(object sender, EventArgs e)
        {
            if (!int.TryParse(gradostxtb.Text, out g))
                return;
            g = Int32.Parse(gradostxtb.Text);
        }

        private void distin(object sender, EventArgs e)
        {
            if (!int.TryParse(distanciaforsteptb.Text, out d))
                return;
            d = Int32.Parse(distanciaforsteptb.Text);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (diametrorueda == 0||eje==0||steps==0||distancias.Count==0||g==0||d==0)
                return;
            
            perimetro=2*Math.PI*(diametrorueda/2);
            time = steps*DELAY;
            double auxtime = (perimetro*time)/media;
            double cmperg = perimetro/360;
            double auxdez = (perimetro*DELAY)/auxtime;
            double gradosperstep = auxdez/cmperg;
            double delaysto360 = auxtime/DELAY;
            double G = 2*Math.PI*eje;
            double gg = (g*G)/360;
            double razon = G/gg;
            GRADOS = (int) Math.Round((gg*delaysto360)/perimetro);
            STEP = (int) Math.Round((d*delaysto360)/perimetro);
            stepsgirolabel.Text =  GRADOS.ToString();
            stepsdistlabel.Text = STEP.ToString();
        }

        public void calmedia()
        {
            double di=0;
            foreach(double d in distancias)
            {
                di += d;
            }
            media = di/distancias.Count;
        }
    }
}
