function [ errorCode, out_ptr, sBufNr, im_ptr, ev_ptr ] = pco_pf_open(exposure_time,currentTriggerMode, binNum, roix0, roix1, roiy0, roiy1, IRSensitivity, conversion)
%PCO_EDGE_PRESNAPSHOT Summary of this function goes here
%   Detailed explanation goes here
glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
set_default = 0;
[errorCode,glvar] = pco_edge_setup(set_default,glvar,exposure_time,currentTriggerMode, binNum, roix0, roix1, roiy0, roiy1, IRSensitivity, conversion);
pco_errdisp('pco_edge_setup', errorCode);

% get camera name
text=blanks(100);
[errorCode,~,text] = calllib('PCO_CAM_SDK','PCO_GetInfoString',glvar.out_ptr,1,text,100);
pco_errdisp('PCO_GetInfoString',errorCode);

if ~isempty(strfind(text,'pixelfly'))
    out_ptr=glvar.out_ptr;
    % ready camera for software triggered snapshot
    image_stack = zeros(1392 / binNum, 1040 / binNum);
    imasize = 2 * (1392 / binNum) * (1040 / binNum);
    
    act_recstate = uint16(10);
    [errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
    pco_errdisp('PCO_GetRecordingState',errorCode);
    
    sBufNr=int16(-1);
    im_ptr = libpointer('uint16Ptr',image_stack);
    ev_ptr = libpointer('voidPtr');
    
    [errorCode,out_ptr,sBufNr,image_stack,ev_ptr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
    if(errorCode)
        pco_errdisp('PCO_AllocateBuffer',errorCode);
        return;
    end
    
    if(act_recstate==0)
        [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,1);
        pco_errdisp('PCO_SetRecordingState',errorCode);
    end
    
    if(errorCode)
        pco_errdisp('pco_pf_open',errorCode);
    else
        disp('Pixelfly open');
    end
    
elseif ~isempty(strfind(text,'edge'))
    if(errorCode)
        pco_errdisp('pco_pf_open',errorCode);
    else
        disp('edge open');
    end
end