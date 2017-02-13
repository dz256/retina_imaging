function ima_stack=pco_edge_stack_mex(imacount,triggermode,exposure_time,pixelrate)
% set variables and grab images to a Matlab array using compiled mex function
%
%   [errorCode] = pco_edge_stack(imacount,exposure_time,pixelrate,triggermode)
%
% * Input parameters :
%    imacount                number of images to grab
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
%grab images
%stop camera
%close camera
%

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('imacount','var'))
 imacount = 10;   
end

if(~exist('exposure_time','var'))
 exposure_time = 10;   
end

if(~exist('triggermode','var'))
 triggermode = 0;   
end

if(~exist('pixelrate','var'))
 pixelrate = 1;   
end

[err,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',err); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(err~=0)
 commandwindow;
 return;
end 

if(~libisloaded('GRABFUNC'))
%ignore typedef warning from compiler    
 [~,~]=loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC');
% [~,warnings]=loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC');
% disp(['warnings: ',warnings]);
end

out_ptr=glvar.out_ptr;

subfunc=pco_camera_subfunction();

subfunc.fh_stop_camera(out_ptr);

subfunc.fh_enable_timestamp(out_ptr,2);
subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2)
subfunc.fh_set_pixelrate(out_ptr,pixelrate);
subfunc.fh_set_triggermode(out_ptr,triggermode);

errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

subfunc.fh_get_triggermode(out_ptr);

%subfunc.fh_set_transferparameter(out_ptr);
%is done in calllib('GRABFUNC','pco_edge_transferpar',out_ptr);

subfunc.fh_show_frametime(out_ptr);

if(libisloaded('GRABFUNC'))
 calllib('GRABFUNC','pco_edge_transferpar',out_ptr);
 calllib('GRABFUNC','showhandle',out_ptr);
 num=uint16(imacount);
 [image_stack,num]=calllib('GRABFUNC','pco_imagestack',num,out_ptr,1);
 disp([int2str(num),' images allocated and grabbed']);
 disp('transpose images');
 if(imacount == 1)
  ima_stack=image_stack';
 else 
  [act_xsize,act_ysize,count]=size(image_stack);  
  ima_stack=zeros(act_ysize,act_xsize,count,'uint16');
  for n=1:count   
   ima_stack(:,:,n)=image_stack(:,:,n)';
  end
 end
 
 clear image_stack;
 
 if(imacount == 1)
  m=max(max(ima_stack(10:end-10,10:end-10)));
  disp(['image done maxvalue: ',int2str(m)]);   
  txt=subfunc.fh_print_timestamp_t(ima_stack,1,16);
  disp(['Timestamp data of image: ',txt]);
 else
  reply = input('Show timestamps? Y/N [Y]: ', 's');
  if((isempty(reply))||(reply(1)== 'Y')||(reply(1)== 'y'))
   for n=1:count
    txt=subfunc.fh_print_timestamp_t(ima_stack(:,:,n),1,16);
    disp(['Timestamp data of image ',num2str(n,'%04d'),': ',txt]);
   end   
  end
 end 
 
end

subfunc.fh_stop_camera(out_ptr);

if(libisloaded('GRABFUNC'))
 unloadlibrary('GRABFUNC');
end

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clear glvar;
commandwindow;

end
   



