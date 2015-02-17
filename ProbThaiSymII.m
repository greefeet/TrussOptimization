function func = ProbThaiSymII
%ProbThaiSymII Truss2D 18m span, 5 Degree by Khomsan Phonsai

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;

%Objective Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = 'TrussSymmetry2D';

%Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.info.prob = 'ProbThaiSymII';
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
    0.000000 78.7398;
    225.0000 98.4247;
    450.0000 118.1097;
    675.0000 137.7946;
    900.0000 157.4796;
    1125.000 137.7946;
    1350.000 118.1097;
    1575.000 98.4247;
    1800.000 78.7398;
    ];
%Set the boundary conditions - fix [nodeID xResrnt? yRestrnt]
PRB.bc.fix=[
    1 1 1 ;
	2 0 1;
    ];
%Create the nodal load - load [nodeID xForce yForce]
% กำหนดโครงหลังคาช่วงยาวต่างกัน 6 เมตร ช่วงยาวละ 2.25 เมตร

% กำหนด DL โครงสร้างเหล็ก = 180 kg/m = น้ำหนักลงที่แต่ละจุด 405 kg/PointLoad
% กำหนด DL หลังคา 18kg/m^2 = 108 kg/m = น้ำหนักลงที่แต่ละจุด 243 kg/PointLoad
% กำหนด LL หลังคา 30kg/m^2 = 180 kg/m = น้ำหนักลงที่แต่ละจุด 405  kg/PointLoad
% กำหนด LL ลม 50kg/m = น้ำหนักลงที่แต่ละจุด 112.5 kg/PointLoad

% กำหนด Total Load per PointLoad = 1165.5 kg/PointLoad or 11,429 N/PointLoad
% เผื่อ Safety Factor เข้าไปอีกสัก 1.3 จาก 11,429 N 
% จะได้ 14,858 กำหนดเป็น 15,000 N
% 15,000x2 = 30,000 N

PRB.bc.load=[
    3 0 -15000;
    4 0 -30000;
    5 0 -30000;
    6 0 -30000;
    7 0 -30000;
    8 0 -30000;
    9 0 -30000;
    10 0 -30000;
    11 0 -15000;
    ];

%Design Variable (dv) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PRB.dv.TypeSection=TypeSection.Discrete;

% Continuous Section
PRB.dv.sectionMin=[];
PRB.dv.sectionMax=[];
PRB.dv.criticalArea=[];

% Discrete Section (W Secton HxB-T1-T2)
PRB.dv.crossSection=[
17.85	1.66;       %150x75
26.84	2.37;       %148x100-6-9
27.16	2.22;       %200x100-5.5-8
37.66	2.79;       %250x125-6-9
39.01	3.61;       %194x150-6-9
46.78	3.29;       %300x150-6.5-9
56.24	4.18;       %244x175-7-11
63.14	3.95;       %350x175-7-11
72.38	4.71;       %294x200-8-12
101.5	6;          %340x250-9-14
];
PRB.dv.lengthMin=180;     % minimumMemberLength (cm)
PRB.dv.lengthMax=400;     % maximumMemberLength (cm)
PRB.dv.xMin = 0;
PRB.dv.xMax = 1800;
PRB.dv.yMin = 0;
PRB.dv.yMax = 157.4796;
end