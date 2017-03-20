function pco_imaqregister(reg)
%PCO_IMAQREGISTER Register/Unregister the PCOCameraAdaptor 
%
%   PCO_IMAQREGISTER or PCO_IMAQREGISTER('REGISTER')
%   First copies PCOCameraAdaptor.dll, SC2_Cam.dll, sc2_cl_me4.dll, 
%   sc2_cl_nat.dll and sc2_cl_mtx.dll from the folder of the current 
%   platform (x64 or win32) to the current folder if necessary and 
%   registeres the camera adaptor located in the current folder
%
%   PCO_IMAQREGISTER('UNREGISTER')
%   Unregisteres the PCOCameraAdaptor.dll from the registry location
%
%   See also IMAQREGISTER.

%(c) 2003-2016 PCO AG * Donaupark 11 * D-93309 Kelheim / Germany 

if(~exist('reg','var'))
    reg = 'register';
end


%get registered adaptors
adaptors = imaqregister;
oldpath = pwd;
if (strcmp(reg,'register'))
  
    if verLessThan('matlab','8.2')
     disp('This adaptor is supported in Matlab 2013b and later versions'); 
    return;
    end 
    
    %copy files
    if(strcmp(computer('arch'),'win32'))
     cd ../../bin
    elseif(strcmp(computer('arch'),'win64'))
     cd ../../bin64
    else
        error('This platform is not supported.');
    end
    
    %check if adaptor is already registered and unregister if necessary
    if (isempty(adaptors)== 0)
        for i= 1:length(adaptors)
            if(isempty(strfind(adaptors(i), 'PCOCameraAdaptor.dll')) == 0)
                imaqregister(char(adaptors(i)), 'unregister');
                disp('An adaptor with the same name was already registered. This adaptor is unregistered now.');
                break;
            end
        end
    end
    
    %Register adaptor
    path = [pwd '\PCOCameraAdaptor.dll'];
    imaqregister(path, 'register');
    
elseif (strcmp(reg,'unregister'))
    if isempty(adaptors)
        disp('No adaptors registered. There is nothing to unregister.');
    else
        %check if adaptor is registered at all, if so do unregister
        for i= 1:length(adaptors)
            if(isempty(strfind(adaptors(i), 'PCOCameraAdaptor.dll')) == 0)
                imaqregister(char(adaptors(i)), 'unregister');
                break;
            elseif (i==length(adaptors))
                disp('PCOCameraAdaptor was not found. There is nothing to unregister.');
            end
        end
    end
    
else
    disp('Wrong input string. Use register or unregister as valid inputs.');
end
cd (oldpath);
end