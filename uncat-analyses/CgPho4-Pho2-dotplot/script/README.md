# 2019-11-01
flexidot_1.06.py and the corresponding documentation downloaded from https://github.com/molbio-dresden/flexidot
# 2019-11-28
flexidot doesn't use a scoring matrix for protein sequence, which means it only scores 0 (not matching) or 1 (matching), although it can handle ambiguous sequences. To find an algorithm that takes into account amino acid similarities, I found the old "dotter" program written by Richard Durbin and Erik Sonnhammer in 1995. The original programs failed to run on my MBA. I found a more recent Java version of the original dotter called JDotter, which I downloaded and successfully ran on my laptop. https://4virology.net/virology-ca-tools/jdotter/ (needed to register on the website to install)
