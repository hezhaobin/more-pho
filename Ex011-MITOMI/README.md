---
title: MITOMI preliminary data and analysis
author: Bin He
date: 9 nov 2017
---


## Brief

   Ivan Istomin in Sebastian's lab has run two MITOMI chips to measure the binding specificity and affinity of ScPho4 and CgPho4. This note is to document the details of the experiment and prepare for an analysis.

## Material

Table 1.  Plasmids sent to Ivan and Sebastian on 7 avr 2017

| Plasmid # | Content | Note |
| EB2135 | pRS315-ScPho4_UTR-Chimeric_Pho4_CDS-YFP | CgPho4 TAD, DBD + ScPho4 middle |
| EB2146 | pRS315-ScPho4_UTR-ScPho4_CDS-YFP |\ |
| EB2147 | pRS315-ScPho4_UTR-CgPho4_CDS-YFP |\ |
| HB002 | pFA6a-CgPho4_UTR-CgPho4_CDS-3xGS |\ |
| HB006 | pFA6a-CgPho4_UTR-ScPho4_CDS-3xGS |\ |

## Methods

### Below is what was proposed by Sebastian (recorded in an email on 10 avr 2017)

1.  from EB2147, EB2146 and EB2135 run a 2-step PCR amplifying only the ScPho4, CgPho4, and Pho4 chimera to generate linear expression templates for all three proteins. Don't forget to add a His-tag to these proteins

2.  test each of these proteins against the dsDNA target library we discussed last time. We will first test these with the standard geometry (i.e. protein on surface / DNA in solution). But we also probably want to test them with DNA on the surface and protein in solution

Optional:

    -   it may also be useful to actually generate linear expression templates from the above plasmids and also include the yEGFP part (here you may not need to add a His tag since we can always surface immobilize then using the GFP directly).

### Modification based on Ivan's email (3 aout 2017)

1.  ScPho4 and CgPho4 CDS were cloned with a C-terminal 3x HIS tag into an in vitro transcription and translation system based on wheat germ lysate (Promega). The protein is cotranslationally labeled with tRNA-lysince-BODIPY.

2.  The labeled TF proteins were bound to the surface of MITOMI using Qiagen biotinylated anti-His antibodies.

3.  As for oligos, he used the one-off variants of NNNGTG E-box (10 variants) and all permutations of NNCACGTG flanking of targets (16 variants)

4.  The oligos were Cy5 labeled, spotted onto MITOMI from 2 µM - 4.86 nM in 6 dilutions of step size 0.3 (how?)

5.  Images were taken using a custom-configured Nikon microscope and analyzed in GenePix.

6.  Image files:

    1.  FITC at 400ms exposure protein attached to the surface (GenePix wavelength 1)

    2.  Cy5 100ms exposure DNA target in solution before wash (wavelength 2)

    3.  Cy5 100ms exposure DNA target attached to Pho4p after wash (wavelength 3)

7.  Linear model fitting

    1. fit 1-site binding model with Hill function

    2. calculate Kd as [DNA * Pho4] = Vmax * [DNA in solution] / ([DNA in solution] + Kd)

    3. convert the Kd estimates above from relative fluorescent units to molar concentrations using the calibration curve.
