%script: copy correct dll-files and compile grabfunc

 pco_camera_create_deffile();

 if(strcmp(computer('arch'),'win32'))
  if(~exist('./sc2_cam.dll','file'))
   copyfile('./win32/sc2_cam.dll','./');
  end 
  if(~exist('./sc2_cam.lib','file'))
   copyfile('./win32/sc2_cam.lib','./');
  end 
  if(~exist('./sc2_cl_me4.dll','file'))
   copyfile('./win32/sc2_cl_me4.dll','./');
  end 
 elseif(strcmp(computer('arch'),'win64'))
  if(~exist('./sc2_cam.dll','file'))
   copyfile('./x64/sc2_cam.dll','./');
  end 
  if(~exist('./sc2_cam.lib','file'))
   copyfile('./x64/sc2_cam.lib','./');
  end 
  if(~exist('./sc2_cl_me4.dll','file'))
   copyfile('./x64/sc2_cl_me4.dll','./');
  end 
 else
  error('This platform is not supported');   
 end 

 mex grabfunc.c -lSC2_Cam -L.\

 