function [ errorCode, out_ptr ] = pco_pf_set_ir_sensitivity(out_ptr, IRSensitivity)

%SC2_SDK_FUNC int WINAPI PCO_GetIRSensitivity(HANDLE ph, WORD* wIR)
% 
% %set delay and exposure time
% if((exist('del_timebase','var'))&&(exist('del_time','var'))&&(exist('exp_timebase','var'))&&(exist('exp_time','var')))
%     errorCode = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', out_ptr,del_time,exp_time,del_timebase,exp_timebase);
%     pco_errdisp('PCO_PCO_SetDelayExposureTime',errorCode);
% end

IRSensitivity = uint32(IRSensitivity);

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_SetIRSensitivity',out_ptr,IRSensitivity);
pco_errdisp('PCO_SetIRSensitivity',errorCode);

end