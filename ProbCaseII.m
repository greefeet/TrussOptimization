function func=ProbCaseII
%ProbCaseII Deb and Gulati 2001 (Design of truss-structures for minimum weight using genetic algorithms)

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'Truss2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'ProbCaseII';
PRB.info.Label = 'Pound (lb)';
PRB.info.name = 'Truss2D Deb and Gulati 2001 (caseII)';

%Material Properties (mp) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.mp.elastic = 10000;       % modulus of elastic (ksi) kip per square inch (ksi, kip/in^2)
PRB.mp.density = 0.1;         % density (pci, Pound per cubic inch)
PRB.mp.fy = 25;               % steel tensile strength fy (ksi)

%Boundary Condition (bc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create nodes - node [xCrd yCrd]
PRB.bc.node=[
    0 0;
    360 0;
    720 0;
    0 360;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	4 1 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
PRB.bc.load=[
    2 0 -100;
    3 0 -100;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Continuous;

% Continuous Section
PRB.dv.sectionMin=0;      % minimumCrossSectionArea (in^2)
PRB.dv.sectionMax=35.0;   % maximumCrossSectionArea (in^2)

% Discrete Section
PRB.dv.crossSection=[];

% Design Space
PRB.dv.lengthMin=180;     % minimumMemberLength (in)
PRB.dv.lengthMax=1000;    % maximumMemberLength (in)
PRB.dv.xMin = 0;
PRB.dv.xMax = 720;
PRB.dv.yMin = 0;
PRB.dv.yMax = 360;

%Penalty Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.PenaltyConstant = 10000;
end