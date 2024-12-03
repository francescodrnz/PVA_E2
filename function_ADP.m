function [ADPout]=function_ADP(V_ac,Weo,Neng,BEP)
%  Aircraft Delivery Price
%  Input
%              V_ac  [m/s]   % A/C speed
%              Weo   [Kg]    % Operating Empty Weight
%              Neng  [--]    % Number of engines
%              BEP   [MUSD]  % Cost of one engine (Current Year) or Ceng
%              Q     [--]    % Number of aircraft delivered
               Q=200;
%              CPI   [--]     Consumer Price Index Current Year
               CPI=190;
%  Output
%              ADPout  = 
%                      ADP  [MUSD] % A/C delivery price
%                      MSP  [MUSD] % A/C manufacturers' standard study price 
%              MSPsplit=   
%                      CE    [% of MSP] % Engineering Costs             
%                      CT    [% of MSP] % Tooling Costs                 
%                      CM    [% of MSP] % Manufacturing Costs           
%                      CQ    [% of MSP] % Quality control Costs         
%                      Cdev  [% of MSP] % Development support cost      
%                      CF    [% of MSP] % Flight test cost              
%                      CMM   [% of MSP] % Manufacturing materials cost  
%                      CAV   [% of MSP] % Avionics cost                 
%                      Cengt [% of MSP] % Engines total cost 

%---------------------------------------------------------------------------
%---------------------------------------------------------------------------
    
  CPI86 = 109.6;      % Consumer Price Index 1986 

% ==========================================================================%
% VARIABLE PARAMETERS
  FTA     = 4;        % Number of test aircrafts
  av_p    = 10;       % Avionics cost as % of overall MSP (5%-25%)
% ==========================================================================%

% PARAMETERS

% Cost rates (1986 USD/hour)
  CR_eng      = 59.1;
  CR_tool     = 60.7;
  CR_manpow   = 50.1;
  CR_quality  = 55.4;
 
  CIPP = 0.025;   % Capitalised Interests on Progress Payments
  CO   = 0.06 ;   % Chance Orders

% Unit Conversion

  Weo  = Weo  * 2.2046;  % [lb]
  V_ac = V_ac * 1.9438;  % [knots]
  BEP= BEP*1000000*(CPI/CPI86);    % [USD current]
  
% DAPCA MSP cost model (From Raymer, pp. 491-507)
% Engineering Hours and cost 
  He = 4.86*(Weo)^0.777*(V_ac)^0.894*Q^0.163;
  CE = He*CR_eng*(CPI/CPI86);     % [USD current]
% Tooling Hours and cost 
  Ht = 5.99*(Weo)^0.777*(V_ac)^0.696*Q^0.263; 
  CT = Ht*CR_tool*(CPI/CPI86);    % [USD current]
% Manufacturing Hours and cost 
  Hm = 7.37*(Weo)^0.82*(V_ac)^0.484*Q^0.641;
  CM = Hm*CR_manpow*(CPI/CPI86);  % [USD current]
% Quality control Hours and cost 
  Hq = 0.133*Hm;
  CQ = Hq*CR_quality*(CPI/CPI86); % [USD current]
% Development support cost  [USD current]
  Cdev = (45.42*(Weo)^0.63*(V_ac)^1.3)*(CPI/CPI86); 
% Flight test cost  [USD current]
  CF = (1243.03*(Weo)^0.325*(V_ac)^0.822*(FTA)^1.21)*(CPI/CPI86); 
% Manufacturing materials cost [USD current]
  CMM = (11*Weo^0.921*(V_ac)^0.621*Q^0.799)*(CPI/CPI86); 
% Avionics cost calculated as a percentage (av_p) of MSP [USD current]
  CAV = (av_p/(100-av_p))*(CE + CT + CM + CQ + Cdev + CF + CMM + Neng*BEP*Q);
% MANUFACTURERS' STANDARD STUDY PRICE [USD current]
  MSP = (CE + CT + CM + CQ + Cdev + CF + CMM + CAV + Neng*BEP*Q)/Q; 

% AIRCRAFT DELIVERY PRICE [USD current]
    ADP = (1+CO+CIPP)*MSP; 

    MSPsplit = 100*[CE/Q CT/Q CM/Q CQ/Q Cdev/Q CF/Q CMM/Q CAV/Q Neng*BEP]'/MSP;

    ADPout   = ADP/1000000;
