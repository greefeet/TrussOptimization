function func=BKIIIsym
%PBKIII Deb and Gulati 2001 (Design of truss-structures for minimum weight using genetic algorithms)

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'TrussSymmetry2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'BKIIIsym';
PRB.info.Label = 'Pound (lb)';
PRB.info.name = 'Truss2D Deb and Gulati 2001 (caseIII)';

%Material Properties (mp) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.mp.elastic = 10000;       % modulus of elastic (ksi) kip per square inch (ksi, kip/in^2)
PRB.mp.density = 0.1;         % density (pci, Pound per cubic inch)
PRB.mp.fy = 20;               % steel tensile strength fy (ksi)

%Boundary Condition (bc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create nodes - node [xCrd yCrd]
PRB.bc.node=[
    0 0;
    120 0;
    240 0;
    360 0;
    480 0;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	5 0 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
PRB.bc.load=[
    2 0 -20;
    3 0 -20;
    4 0 -20;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Continuous;

% Continuous Section
PRB.dv.sectionMin=0;      % minimumCrossSectionArea (in^2)
PRB.dv.sectionMax=2.25;   % maximumCrossSectionArea (in^2)

% Discrete Section
PRB.dv.crossSection=[];

% Design Space
PRB.dv.lengthMin=100;     % minimumMemberLength (in)
PRB.dv.lengthMax=540;     % maximumMemberLength (in)
PRB.dv.xMin = 0;
PRB.dv.xMax = 480;
PRB.dv.yMin = 0;
PRB.dv.yMax = 240;

%Penalty Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.PenaltyConstant = 1000;
end