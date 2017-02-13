function [ errorCode,out_ptr ] = pco_edge_close( out_ptr, sBufNr )
%PCO_EDGE_CLOSE Summary of this function goes here
%   Detailed explanation goes here
%% close camera
act_recstate = uint16(10);
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);

if(act_recstate==1)
    [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,0);
    pco_errdisp('PCO_SetRecordingState',errorCode);
end

errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
pco_errdisp('PCO_FreeBuffer',errorCode);

errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera',out_ptr);
pco_errdisp('PCO_CloseCamera',errorCode);

% unloadlibrary('PCO_CAM_SDK');

if(errorCode)
    pco_errdisp('pco_edge_close',errorCode);
else
    disp('pco_edge_close done');
    
end

