function func = ProbThaiSymI
%BKIV Truss2D 18m span problem by Khomsan Phonsai

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'TrussSymmetry2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'ProbThaiSymI';
PRB.info.Label = 'Weight (kg)';
PRB.info.name = 'Truss2D 18m span problem by Khomsan Phonsai';

%Material Properties (mp) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.mp.elastic = 20100000;    % Convert E from 2.01x10^5 MPa to 20100000 N/cm^2
PRB.mp.density = 0.00785103;  % Convert Density from 7851.03 kg/m^3 to 0.00785103 kg/cm^3
PRB.mp.fy = 24880;            % Convert Fy from 248.8 MPa to 24880 N/cm^2

%Boundary Condition (bc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create nodes - node [xCrd yCrd]
PRB.bc.node=[
    0 0;
    1800 0;
    0.000000 142.520;
    180.0000 174.016;
    360.0000 205.512;
    540.0000 237.008;
    720.0000 268.504;
    900.0000 300.000;
    1080.000 268.504;
    1260.000 237.008;
    1440.000 205.512;
    1620.000 174.016;
    1800.000 142.520;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	2 0 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
PRB.bc.load=[
    3 0 -12500;
    4 0 -25000;
    5 0 -25000;
    6 0 -25000;
    7 0 -25000;
    8 0 -25000;
    9 0 -25000;
    10 0 -25000;
    11 0 -25000;
    12 0 -25000;
    13 0 -12500;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Discrete;

% Continuous Section
PRB.dv.sectionMin=[];
PRB.dv.sectionMax=[];
PRB.dv.criticalArea=[];

% Discrete Section
PRB.dv.crossSection=[
17.85	1.66;
26.84	2.37;
27.16	2.22;
37.66	2.79;
39.01	3.61;
46.78	3.29;
56.24	4.18;
63.14	3.95;
72.38	4.71;
101.5	6;
];
PRB.dv.lengthMin=180;     % minimumMemberLength (cm)
PRB.dv.lengthMax=360;    % maximumMemberLength (cm)
PRB.dv.xMin = 0;
PRB.dv.xMax = 1800;
PRB.dv.yMin = 0;
PRB.dv.yMax = 300;
end