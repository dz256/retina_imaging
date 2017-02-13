function image_stack = pco_pf_getsnapshot(out_ptr, sBufNr, im_ptr, ev_ptr)
%PCO_EDGE_GETSNAPSHOT Summary of this function goes here
%   Detailed explanation goes here

wCameraBusyState = libpointer('uint16Ptr',uint16(1));
while wCameraBusyState.Value
    [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_GetCameraBusyStatus', out_ptr, wCameraBusyState);
    pco_errdisp('PCO_GetCameraBusyStatus', errorCode);
end

wTriggered = libpointer('uint16Ptr',uint16(0));
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ForceTrigger', out_ptr,wTriggered);
pco_errdisp('PCO_ForceTrigger', errorCode);

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,1,0,0,sBufNr,1392,1040,14);
pco_errdisp('PCO_GetImageEx',errorCode);

[errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
pco_errdisp('PCO_GetBuffer',errorCode);
image_stack = flipud(image_stack');

end

