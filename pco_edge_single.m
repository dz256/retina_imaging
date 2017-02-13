function pco_edge_single(triggermode,exposure_time,pixelrate)
% set variables grab and display a single images
%
%   [errorCode] = pco_edge_single(exposure_time,pixelrate,triggermode)
%
% * Input parameters :
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%    pixelrate               camera pixelrate selection (default=1)
%                            1 low pixelrate 95Mhz
%                            2 high pixelrate 286Mhz
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions
%
%grab images from a recording pco.edge camera
%using functions PCO_AddBufferEx and PCO_WaitforBuffer
%display the grabbed images
%
%function workflow
%open camera
%set variables
%start camera
%grab image
%show image
%stop camera
%close camera
%


glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('exposure_time','var'))
    exposure_time = 10;
end

if(~exist('triggermode','var'))
    triggermode = 0;
end

if(~exist('pixelrate','var'))
    pixelrate = 1;
end

%reduce_display_size=1: display only top-left corner 800x600Pixel
reduce_display_size=0;

[err,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',err);
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(err~=0)
    commandwindow;
    return;
end

out_ptr=glvar.out_ptr;

subfunc=pco_camera_subfunction();

subfunc.fh_stop_camera(out_ptr);

%do settings starting from a known state
subfunc.fh_reset_settings_to_default(out_ptr);

subfunc.fh_enable_timestamp(out_ptr,2);
subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2)
subfunc.fh_set_pixelrate(out_ptr,pixelrate);
subfunc.fh_set_triggermode(out_ptr,triggermode);

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);

%adjust transfer parameter if necessary
subfunc.fh_set_transferparameter(out_ptr);

subfunc.fh_get_triggermode(out_ptr);

subfunc.fh_show_frametime(out_ptr);

disp('get single image');
[err,ima,glvar]=pco_camera_stack(1,glvar);
if(err==0)
    if(reduce_display_size~=0)
        [ys,xs]=size(ima);
        xmax=800;
        ymax=600;
        if((xs>xmax)&&(ys>ymax))
            ima=ima(1:ymax,1:xmax);
        elseif(xs>xmax)
            ima=ima(:,1:xmax);
        elseif(ys>ymax)
            ima=ima(1:ymax,:);
        end
    end
    m=max(max(ima(10:end-10,10:end-10)));
    % imshow(ima',[0,m+100]);
    draw_image(ima,[0 m+100]);
    imwrite(ima,'image_test.tif','tif');
    disp(['found max ',int2str(m)]);
    disp('Press "Enter" to proceed')
    pause();
    close()
    clear ima;
end

subfunc.fh_stop_camera(out_ptr);

if(glvar.camera_open==1)
    glvar.do_close=1;
    glvar.do_libunload=1;
    pco_camera_open_close(glvar);
end

clear glvar;
commandwindow;

end

