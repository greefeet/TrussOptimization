wipe
model BasicBuilder -ndm 2 -ndf 2
node 1 0.0 0.0
node 2 1000.0 0.0
node 3 2000.0 0.0
node 4 3000.0 0.0
node 5 4000.0 0.0
node 6 5000.0 0.0
node 7 6000.0 0.0
node 8 7000.0 0.0
node 9 634.4 198.4
node 10 1332.4 198.8
node 11 2575.4 281.5
node 12 3370.2 246.7
node 13 4905.2 173.3
node 14 5117.0 25.1
node 15 6164.2 48.2
node 16 6663.7 150.9
node 17 293.9 653.0
node 18 1428.8 611.3
node 19 3596.9 614.5
node 20 3722.4 508.3
node 21 4759.2 347.0
node 22 5660.1 483.9
node 23 6055.7 524.6
node 24 6357.1 585.9
node 25 6724.7 537.3
node 26 364.9 938.1
node 27 700.9 758.6
node 28 1537.0 966.4
node 29 3277.6 997.4
node 30 4439.6 985.3
node 31 5470.2 894.4
node 32 5729.9 688.5
fix 1 1 1
fix 8 0 1
uniaxialMaterial Elastic 1 20100000
element truss 1 1 2 703 1
element truss 2 1 9 334 1
element truss 3 1 17 91 1
element truss 4 1 26 7.230000e+001 1
element truss 5 2 3 703 1
element truss 6 2 9 250 1
element truss 7 2 10 334 1
element truss 8 3 4 91 1
element truss 9 3 10 155 1
element truss 10 3 11 334 1
element truss 11 3 18 366 1
element truss 12 3 28 537 1
element truss 13 4 5 366 1
element truss 14 4 11 442 1
element truss 15 4 12 703 1
element truss 16 5 6 366 1
element truss 17 5 12 155 1
element truss 18 5 13 91 1
element truss 19 5 20 206 1
element truss 20 5 21 537 1
element truss 21 6 7 366 1
element truss 22 6 13 366 1
element truss 23 6 14 334 1
element truss 24 7 8 703 1
element truss 25 7 14 155 1
element truss 26 7 15 590 1
element truss 27 7 22 442 1
element truss 28 7 23 91 1
element truss 29 8 15 115 1
element truss 30 8 16 5.710000e+001 1
element truss 31 8 25 366 1
element truss 32 9 10 228 1
element truss 33 9 17 334 1
element truss 34 9 27 652 1
element truss 35 10 18 366 1
element truss 36 10 27 537 1
element truss 37 11 12 4.960000e+001 1
element truss 38 11 28 228 1
element truss 39 11 29 8.130000e+001 1
element truss 40 12 19 129 1
element truss 41 12 20 171 1
element truss 42 12 29 101 1
element truss 43 13 14 8.130000e+001 1
element truss 44 13 21 91 1
element truss 45 13 22 250 1
element truss 46 13 31 703 1
element truss 47 14 22 8.130000e+001 1
element truss 48 15 16 366 1
element truss 49 15 23 6.450000e+001 1
element truss 50 15 24 115 1
element truss 51 16 24 250 1
element truss 52 16 25 129 1
element truss 53 17 26 115 1
element truss 54 17 27 8.130000e+001 1
element truss 55 18 27 141 1
element truss 56 18 28 5.710000e+001 1
element truss 57 19 20 115 1
element truss 58 19 29 703 1
element truss 59 19 30 250 1
element truss 60 20 21 334 1
element truss 61 20 30 703 1
element truss 62 21 30 806 1
element truss 63 21 31 155 1
element truss 64 22 23 171 1
element truss 65 22 31 488 1
element truss 66 22 32 7.230000e+001 1
element truss 67 23 24 7.230000e+001 1
element truss 68 23 32 101 1
element truss 69 24 25 171 1
element truss 70 24 31 537 1
element truss 71 24 32 228 1
element truss 72 25 31 537 1
element truss 73 26 27 334 1
element truss 74 26 28 228 1
element truss 75 27 28 8.130000e+001 1
element truss 76 28 29 400 1
element truss 77 29 30 400 1
element truss 78 30 31 129 1
element truss 79 31 32 8.130000e+001 1
pattern Plain 1 "Linear" {
load 2 0 -500000
load 3 0 -500000
load 4 0 -500000
load 5 0 -500000
load 6 0 -500000
load 7 0 -500000
}
system BandSPD
numberer RCM
constraints Plain
integrator LoadControl 1.0
algorithm Linear
analysis Static
recorder Node -file File-OutDisp.out -node 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 -dof 1 2 disp
recorder Element -file File-OutStress.out -ele 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 material stress
analyze 1
quit
