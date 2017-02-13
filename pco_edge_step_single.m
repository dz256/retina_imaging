function [errorCode] = pco_edge_step_single(start_time,stop_time,step_time)
% grab and display images with increasing exposure times
%
%   [errorCode] = edge_single(exposure_time,loop)
%
% * Input parameters :
%    start_time              start exposure time of camera in ms default=5ms
%    stop_time               stop exposure time 
%    step_time               exposure time steps
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab images with different exposure times
%display the grabbed images
%
%function workflow
%open camera
%set exposure time
%start camera
%grab image
%show image
%increase exposure time by factor 2 
%grab image
%show image
%stop camera
%close camera
%

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('start_time','var'))
 start_time = 5;   
end

if(~exist('stop_time','var'))
 stop_time = 20;   
end

if(~exist('step_time','var'))
 step_time = 5;   
end

if(step_time<1)
 step_time=1;
end 

%reduce_display_size=1: display only top-left corner 800x600Pixel
reduce_display_size=1;

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

%enable ASCII and binary timestamp
subfunc.fh_enable_timestamp(out_ptr,2);

%set Pixelrate 95Mhz
subfunc.fh_set_pixelrate(out_ptr,1);

subfunc.fh_set_exposure_times(out_ptr,start_time,2,0,2)

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

subfunc.fh_show_frametime(out_ptr);

subfunc.fh_start_camera(out_ptr);

disp(['get single image with exposure_time ',int2str(start_time)]);
[errorCode,ima]=pco_camera_stack(1,glvar);
if(errorCode==0)
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
 imah=draw_image(ima,[0 100]);
 axish=gca;
 set(axish,'CLim',[0 m+100]);
 disp(['found max ',int2str(m)]);
 disp('Press "Enter" to proceed')
 pause();
 clear ima;
end 

act_time=start_time;

while act_time < stop_time
 act_time=act_time+step_time;   
 
 subfunc.fh_set_exposure_times(out_ptr,act_time,2,0,2)

 disp(['get next image with exposure_time ',int2str(act_time)]);
 [errorCode,ima]=pco_camera_stack(1,glvar);
 if(errorCode==0)
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
  m1=max(max(ima(10:end-10,10:end-10)));
  set(imah,'CData',ima,'CDataMapping','scaled'); 
  disp(['found max ',int2str(m1)]);
  disp('Press "Enter" to proceed')
  pause();
  clear ima;
 end 
end

close();

subfunc.fh_stop_camera(glvar.out_ptr);

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clear glvar;
commandwindow;

end

