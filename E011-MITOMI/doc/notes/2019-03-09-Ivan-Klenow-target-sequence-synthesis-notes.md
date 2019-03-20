---
title:  Target synthesis by Klenow
author: Ivan Istomin
date:   9 mar 2019
---

Hello Bin,

First please accept my apologies for belated answer. You can find the Klenow protocol [attached](../protocols/2016-12-09-Ivan-Istomin-Klenow-target-sequence-synthesis.pdf) along with the file with targets that we’ve used for CgPho4p as they’re named in my inventory. Please note that in the protocol the ramp rates are for the Eppendorf machine and I believe that 100% corresponds to 6ºC/sec, hence 10% will be 0.6ºC/sec. As you can see, this protocol involves pre-annealing step that’s done in the buffer alone and only after that is followed by the addition of the energy mix and of enzyme. Please advice if you’d like to receive the references for the Klenow(exo-) that we used, I believe it was Thermo Fischer one. In the end as you can see you’re getting the concentration of 0.4uL * 500uM / 30uL total volume = 6.(6)uM double stranded target if all the fluorescent complementary oligos have bound and extended successfully. As Sebastian is pointing out you can lower the concentrations of reactants and still get good purification results. With the targets of this length (30bp) you can then run a gel and resolve single-stranded and double-stranded molecules. 

One thing that I have to warn you about though is the usage of biotin-conjugated complement — if I understood it correctly, you’d like to use SPR to study the binding of your protein to the targets, in which case you might have to purify the results of the Klenow reaction to get rid of any binding of single-stranded biotinylated complement to the SPR surface. 

Now for the target design, the sequences that correspond to the measured in the file MITOMI_Cg_affinities.xlsx (attached) are rank-ordered in the file TargetSequences.xlsx (attached), they are different from the design that you’re suggesting. I can explain why these ones were chosen. The sequence of the complement (in this case biotinylated, but you can chose a non-biotinylated version of course) is under the name Comp Cy5 biotin / 1B9_compBiotCy5 in the same file.

Please let me know if that answers some of the questions that you had, I’ll be happy to provide more in-detailed info.

Best,
Ivan
