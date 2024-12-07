function output_ias2tas = IAS2TAS(VIAS,h)
 % =====================================================================
 %        
 %                         IAS2TAS
 %
 % Function to evaluate the EAS and TAS starting from IAS
 % VIAS = [m/s]
 % h = [m]
 % =====================================================================
 
 gamma_air = 1.4;                         %ideal diatomic gas value
 rho_0 = IntStandAir_SI(0,['rho']);   %[kg/m^3] air density @ sea level
 a = IntStandAir_SI(h,['a']);         %[m/s] Speed of sound
 p = IntStandAir_SI(h,['p']);         %[Pa] Pressure
 rho = IntStandAir_SI(h,['rho']);     %[kg/m^3] Air density
 pt = p+0.5*rho_0*VIAS^2;             %[Pa] Total pressure read by the IAS anemometer
 
 VEAS = sqrt(2*a^2/(gamma_air-1)*(rho/rho_0)*((pt/p)^((gamma_air-1)/gamma_air)-1)); %[m/s] EAS
 VTAS = VEAS*sqrt(rho_0/rho);                                           %[m/s] TAS
 
output_ias2tas=[VEAS,VTAS];
end

