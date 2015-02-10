function func=BKII
%BKII Cantilever 33 m

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'Truss2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'BKII';
PRB.info.Label = 'Pound (lb)';
PRB.info.name = 'Truss2D Cantilever 33 m (Benchmark II)';

%Material Properties (mp) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.mp.elastic = 10000;       % modulus of elastic (ksi) kip per square inch (ksi, kip/in^2)
PRB.mp.density = 0.1;         % density (pci, Pound per cubic inch)
PRB.mp.fy = 20;               % steel tensile strength fy (ksi)

%Boundary Condition (bc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create nodes - node [xCrd yCrd]
PRB.bc.node=[
    0 0;
    250 250;
    500 250;
    750 250;
    1000 250;
    1250 250;
    0 250;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	7 1 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
PRB.bc.load=[
    2 0 -20;
    3 0 -20;
    4 0 -20;
    5 0 -20;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Continuous;

% Continuous Section
PRB.dv.sectionMin=0;      % minimumCrossSectionArea (in^2)
PRB.dv.sectionMax=21.75;   % maximumCrossSectionArea (in^2)

% Discrete Section
PRB.dv.crossSection=[];

% Design Space
PRB.dv.lengthMin=350;     % minimumMemberLength (in)
PRB.dv.lengthMax=1000;    % maximumMemberLength (in)
PRB.dv.xMin = 0;
PRB.dv.xMax = 1250;
PRB.dv.yMin = 0;
PRB.dv.yMax = 250;

%Penalty Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.PenaltyConstant = 10000;
end