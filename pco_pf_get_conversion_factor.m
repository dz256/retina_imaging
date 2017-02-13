function [ errorCode, out_ptr ] = pco_pf_get_conversion_factor(out_ptr, conversion)

%SC2_SDK_FUNC int WINAPI PCO_GetIRSensitivity(HANDLE ph, WORD* wIR)
% 


conversion = uint32(conversion*100);


[errorCode,out_ptr, hello]  = calllib('PCO_CAM_SDK','PCO_GetConversionFactor',out_ptr,conversion);
pco_errdisp('PCO_GetConversionFactor',errorCode);

disp(hello)
end