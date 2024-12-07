function [out] = IntStandAir_SI(H,par)
% International Standar Atmosphere 
%--------------------------------------------------------------------------- 
% Inputs: H     Height [m]
%         par   required output [string] 
%               accepted values  't' 'p' 'rho' 'mu' 'ni' 'a'
% Outputs: T    Temperature                 [K      ]
%          p    Pressure                    [Pa     ]
%          rho  Density                     [Kg/m3  ]
%          mu   Viscosity                   [Kg/m/s ]
%          ni   Kinematic Viscosity         [m2/s   ]
%          a    Speed of Sound              [m/s    ]
% Used function and routines: none         
%
% SEA LEVEL VALUES
%
% Pressure                101325    [Pa     ];  2116.7     [lbf/ft2  ]
% Density                 1,225     [Kg/m3  ];  0.002378   [slug/ft3 ]
% Temperature             288.2     [K      ];  518        [R        ]
% Speed of Sound          340.3     [m/s    ];  1116.4     [ft/s     ]
% Viscosity               1.789e-5  [Kg/m/s ];  3.737e-7   [slug/ft/s]
% Kinematic Viscosity     1.460e-5  [m2/s   ];  1.5723e-4  [ft2/s    ]
% Thermal Conductivity    0.0253    [J/m/s/K];  3.165e-3   [lb/s/oR  ]
% 
% Specific Heat Cp        1005      [J/Kg/K];   6005       [ft lbf/slug/R]
% Specific Heat Cv        717.98    [J/Kg/K];   4289       [ft lbf/slug/R]
%---------------------------------------------------------------------------          
%---------------------------------------------------------------------------
%

% Constant definition
  R=287.05;      % Perfect gas constant [J/Kg/K] (1715.7 ft lbf/slug/R)
  g=9.80665;     % Gravitational Acceleration [m/s2] (32.174 ft/s2)
  beta=1.458e-6; % parameter of the Sutherland law [mu=beta*T^(3/2)/(T+S)]
  S=110.4;       % parameter of the Sutherland law [mu=beta*T^(3/2)/(T+S)]
  gamma=1.4;     % Ratio of Specific Heats

% Sea level conditions
  T0=288.15;     % Temperature [K] 
  p0=101325;     % Pressure    [Pa]
  rho0=1.225;    % Density     [Kg/m3]
             
% Stratosphere conditions (h = 11000 m )
  Hs=11000;
  Ts=216.65;
  ps=p0*(1-0.0065*Hs/T0)^(g/R/0.0065);
  rhos=rho0*(1-0.0065*Hs/T0)^(g/R/0.0065-1);

% 20000 m conditions
  H20=20000;
  T20=Ts;
  p20=ps*exp(-g/R/Ts*(H20-Hs));
  rho20=rhos*exp(-g/R/Ts*(H20-Hs));



if H<11000
   T=T0-0.0065*H;
   p=p0*(1-0.0065*H/T0)^(g/R/0.0065);
   rho=rho0*(1-0.0065*H/T0)^(g/R/0.0065-1);
   mu=beta*T^(3/2)/(T+S);
   a=sqrt(gamma*R*T);
   ni=mu/rho;
else	if H<20000
      T=Ts;
      p=ps*exp(-g/R/Ts*(H-Hs));
      rho=rhos*exp(-g/R/Ts*(H-Hs));
      mu=beta*T^(3/2)/(T+S);
      a=sqrt(gamma*R*T);
      ni=mu/rho;
   else
      T=T20+0.001*(H-H20);
      p=p20*(1+0.001*(H-H20)/T20)^(-g/R/0.001);
      rho=rho20*(1+0.001*(H-H20)/T20)^(-g/R/0.001-1);
      mu=beta*T^(3/2)/(T+S);
      a=sqrt(gamma*R*T);
      ni=mu/rho;
   end   
end

switch lower(par)
case 't'                   
     out=T;             
case 'p'
     out=p;
case 'rho'
     out=rho;
case 'mu'
     out=mu;
case 'ni'
     out=ni;
case 'a'  
     out=a;
otherwise
     out=[T,p,rho,mu,ni,a];
end












