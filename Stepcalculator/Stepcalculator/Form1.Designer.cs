namespace Stepcalculator
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.diametrotextb = new System.Windows.Forms.TextBox();
            this.ejetextb = new System.Windows.Forms.TextBox();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.distanciatextb = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.agregarbutton = new System.Windows.Forms.Button();
            this.medialabel = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.gradostxtb = new System.Windows.Forms.TextBox();
            this.label9 = new System.Windows.Forms.Label();
            this.distanciaforsteptb = new System.Windows.Forms.TextBox();
            this.label10 = new System.Windows.Forms.Label();
            this.label11 = new System.Windows.Forms.Label();
            this.calcularbutton = new System.Windows.Forms.Button();
            this.stepsgirolabel = new System.Windows.Forms.Label();
            this.stepsdistlabel = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label12 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(7, 17);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Diametro";
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(7, 40);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(22, 13);
            this.label2.TabIndex = 1;
            this.label2.Text = "Eje";
            // 
            // diametrotextb
            // 
            this.diametrotextb.Location = new System.Drawing.Point(62, 10);
            this.diametrotextb.Name = "diametrotextb";
            this.diametrotextb.Size = new System.Drawing.Size(181, 20);
            this.diametrotextb.TabIndex = 2;
            this.diametrotextb.TextChanged += new System.EventHandler(this.diametroin);
            // 
            // ejetextb
            // 
            this.ejetextb.Location = new System.Drawing.Point(62, 37);
            this.ejetextb.Name = "ejetextb";
            this.ejetextb.Size = new System.Drawing.Size(181, 20);
            this.ejetextb.TabIndex = 3;
            this.ejetextb.TextChanged += new System.EventHandler(this.ejein);
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.Location = new System.Drawing.Point(123, 102);
            this.numericUpDown1.Name = "numericUpDown1";
            this.numericUpDown1.Size = new System.Drawing.Size(120, 20);
            this.numericUpDown1.TabIndex = 4;
            this.numericUpDown1.ValueChanged += new System.EventHandler(this.stepsin);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(10, 104);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(94, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Steps de muestras";
            this.label3.Click += new System.EventHandler(this.label3_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(95, 73);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(50, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "Muestras";
            this.label4.Click += new System.EventHandler(this.label4_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(10, 138);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(51, 13);
            this.label5.TabIndex = 7;
            this.label5.Text = "Distancia";
            // 
            // distanciatextb
            // 
            this.distanciatextb.Location = new System.Drawing.Point(68, 131);
            this.distanciatextb.Name = "distanciatextb";
            this.distanciatextb.Size = new System.Drawing.Size(175, 20);
            this.distanciatextb.TabIndex = 8;
            this.distanciatextb.TextChanged += new System.EventHandler(this.distanciain);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(116, 174);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(94, 13);
            this.label6.TabIndex = 9;
            this.label6.Text = "Distancia MEDIA: ";
            // 
            // agregarbutton
            // 
            this.agregarbutton.Location = new System.Drawing.Point(13, 169);
            this.agregarbutton.Name = "agregarbutton";
            this.agregarbutton.Size = new System.Drawing.Size(75, 23);
            this.agregarbutton.TabIndex = 10;
            this.agregarbutton.Text = "Agregar";
            this.agregarbutton.UseVisualStyleBackColor = true;
            this.agregarbutton.Click += new System.EventHandler(this.button1_Click);
            // 
            // medialabel
            // 
            this.medialabel.AutoSize = true;
            this.medialabel.Location = new System.Drawing.Point(206, 174);
            this.medialabel.Name = "medialabel";
            this.medialabel.Size = new System.Drawing.Size(13, 13);
            this.medialabel.TabIndex = 11;
            this.medialabel.Text = "0";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(12, 226);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(41, 13);
            this.label8.TabIndex = 12;
            this.label8.Text = "Grados";
            // 
            // gradostxtb
            // 
            this.gradostxtb.Location = new System.Drawing.Point(62, 220);
            this.gradostxtb.Name = "gradostxtb";
            this.gradostxtb.Size = new System.Drawing.Size(51, 20);
            this.gradostxtb.TabIndex = 13;
            this.gradostxtb.TextChanged += new System.EventHandler(this.gradosin);
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(133, 226);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(51, 13);
            this.label9.TabIndex = 14;
            this.label9.Text = "Distancia";
            // 
            // distanciaforsteptb
            // 
            this.distanciaforsteptb.Location = new System.Drawing.Point(190, 220);
            this.distanciaforsteptb.Name = "distanciaforsteptb";
            this.distanciaforsteptb.Size = new System.Drawing.Size(53, 20);
            this.distanciaforsteptb.TabIndex = 15;
            this.distanciaforsteptb.TextChanged += new System.EventHandler(this.distin);
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(85, 198);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(77, 13);
            this.label10.TabIndex = 16;
            this.label10.Text = "Para generar...";
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(12, 251);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(76, 13);
            this.label11.TabIndex = 17;
            this.label11.Text = "Se requieren...";
            // 
            // calcularbutton
            // 
            this.calcularbutton.Location = new System.Drawing.Point(98, 246);
            this.calcularbutton.Name = "calcularbutton";
            this.calcularbutton.Size = new System.Drawing.Size(145, 23);
            this.calcularbutton.TabIndex = 18;
            this.calcularbutton.Text = "Calcular";
            this.calcularbutton.UseVisualStyleBackColor = true;
            this.calcularbutton.Click += new System.EventHandler(this.button2_Click);
            // 
            // stepsgirolabel
            // 
            this.stepsgirolabel.AutoSize = true;
            this.stepsgirolabel.Location = new System.Drawing.Point(13, 278);
            this.stepsgirolabel.Name = "stepsgirolabel";
            this.stepsgirolabel.Size = new System.Drawing.Size(16, 13);
            this.stepsgirolabel.TabIndex = 19;
            this.stepsgirolabel.Text = "...";
            // 
            // stepsdistlabel
            // 
            this.stepsdistlabel.AutoSize = true;
            this.stepsdistlabel.Location = new System.Drawing.Point(175, 278);
            this.stepsdistlabel.Name = "stepsdistlabel";
            this.stepsdistlabel.Size = new System.Drawing.Size(16, 13);
            this.stepsdistlabel.TabIndex = 20;
            this.stepsdistlabel.Text = "...";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(43, 278);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(36, 13);
            this.label7.TabIndex = 21;
            this.label7.Text = "Pasos";
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(204, 277);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(36, 13);
            this.label12.TabIndex = 22;
            this.label12.Text = "Pasos";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(255, 299);
            this.Controls.Add(this.label12);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.stepsdistlabel);
            this.Controls.Add(this.stepsgirolabel);
            this.Controls.Add(this.calcularbutton);
            this.Controls.Add(this.label11);
            this.Controls.Add(this.label10);
            this.Controls.Add(this.distanciaforsteptb);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.gradostxtb);
            this.Controls.Add(this.label8);
            this.Controls.Add(this.medialabel);
            this.Controls.Add(this.agregarbutton);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.distanciatextb);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.numericUpDown1);
            this.Controls.Add(this.ejetextb);
            this.Controls.Add(this.diametrotextb);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form1";
            this.Text = "Steps Calculator";
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox diametrotextb;
        private System.Windows.Forms.TextBox ejetextb;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox distanciatextb;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Button agregarbutton;
        private System.Windows.Forms.Label medialabel;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.TextBox gradostxtb;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.TextBox distanciaforsteptb;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Button calcularbutton;
        private System.Windows.Forms.Label stepsgirolabel;
        private System.Windows.Forms.Label stepsdistlabel;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label12;
    }
}

