function [ errorCode, out_ptr ] = pco_pf_set_conversion_factor(out_ptr, conversion)

%SC2_SDK_FUNC int WINAPI PCO_GetIRSensitivity(HANDLE ph, WORD* wIR)
% 


conversion = uint32(conversion*100);

disp(conversion)
[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_SetConversionFactor',out_ptr,conversion);
pco_errdisp('PCO_SetConversionFactor',errorCode);

end