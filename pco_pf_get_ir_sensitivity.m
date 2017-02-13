function ir_sensitivity_value = pco_pf_get_ir_sensitivity(out_ptr, sBufNr, im_ptr, ev_ptr, IRSensitivity)

%SC2_SDK_FUNC int WINAPI PCO_GetIRSensitivity(HANDLE ph, WORD* wIR)

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetIRSensitivity',out_ptr,1,0,0,sBufNr,IRSensitivity, IRSensitivity,14);
pco_errdisp('PCO_GetIRSensitivity',errorCode);

[errorCode,out_ptr,ir_sensitivity_value]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
pco_errdisp('PCO_GetBuffer',errorCode);

end