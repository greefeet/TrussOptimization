function func = BKIV
%BKIV Truss2D 70m span problem by Shrestha and Ghaboussi (caseI)

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'Truss2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'BKIV';
PRB.info.Label = 'Weight (kg)';
PRB.info.name = 'Truss 70m span problem by Shrestha and Ghaboussi (caseI)';

%Material Properties (mp) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.mp.elastic = 20100000;    % Convert E from 2.01x10^5 MPa to 20100000 N/cm^2
PRB.mp.density = 0.00785103;  % Convert Density from 7851.03 kg/m^3 to 0.00785103 kg/cm^3
PRB.mp.fy = 24880;            % Convert Fy from 248.8 MPa to 24880 N/cm^2

%Boundary Condition (bc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create nodes - node [xCrd yCrd]
PRB.bc.node=[
    0 0;
    1000 0;
    2000 0;
    3000 0;
    4000 0;
    5000 0;
    6000 0;
    7000 0;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	8 0 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
PRB.bc.load=[
    2 0 -500000;
    3 0 -500000;
    4 0 -500000;
    5 0 -500000;
    6 0 -500000;
    7 0 -500000;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Discrete;

% Continuous Section
PRB.dv.sectionMin=[];
PRB.dv.sectionMax=[];
PRB.dv.criticalArea=[];

% Discrete Section
PRB.dv.crossSection=[
806 11;     % W14X426  1
755 10.9;   % W14X398  2
703 10.8;   % W14X370  3
652 10.8;   % W14X342  4
590 10.7;   % W14X311  5
537 10.6;   % W14X283  6
488 10.5;   % W14X257  7
442 10.4;   % W14X233  8
400 10.3;   % W14X211  9
366 10.3;   % W14X193  10
334 10.2;   % W14X176  11
301 10.2;   % W14X159  12
275 10.1;   % W14X145  13
250 9.55;   % W14X132  14
228 9.5;    % W14X120  15
206 9.47;   % W14X109  16
188 9.42;   % W14X99   17
171 9.4;    % W14X90   18
155 6.3;    % W14X82   19
141 6.3;    % W14X74   20
129 6.25;   % W14X68   21
115 6.22;   % W14X61   22
101 4.88;   % W14X53   23
91 4.85;    % W14X48   24
81.3 4.8;   % W14X43   25
72.3 3.94;  % W14X38   26
64.5 3.89;  % W14X34   27
57.1 3.78;  % W14X30   28
49.6 2.74;  % W14X26   29
41.9 2.64;  % W14X22   30
];
PRB.dv.lengthMin=500;     % minimumMemberLength (cm)
PRB.dv.lengthMax=3500;    % maximumMemberLength (cm)
PRB.dv.xMin = 0;
PRB.dv.xMax = 7000;
PRB.dv.yMin = 0;
PRB.dv.yMax = 1000;
end