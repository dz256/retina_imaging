function varargout = pco_pixelfly_gui(varargin)
% PCO_PIXELFLY_GUI MATLAB code for pco_pixelfly_gui.fig
%      PCO_PIXELFLY_GUI, by itself, creates a new PCO_PIXELFLY_GUI or raises the existing
%      singleton*.
%
%      H = PCO_PIXELFLY_GUI returns the handle to a new PCO_PIXELFLY_GUI or the handle to
%      the existing singleton*.
%
%      PCO_PIXELFLY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCO_PIXELFLY_GUI.M with the given input arguments.
%
%      PCO_PIXELFLY_GUI('Property','Value',...) creates a new PCO_PIXELFLY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pco_pixelfly_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pco_pixelfly_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pco_pixelfly_gui

% Last Modified by GUIDE v2.5 01-Aug-2016 11:54:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pco_pixelfly_gui_OpeningFcn, ...
    'gui_OutputFcn',  @pco_pixelfly_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before pco_pixelfly_gui is made visible.
function pco_pixelfly_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pco_edge_gui (see VARARGIN)

% Choose default command line output for pco_edge_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%Flash = line 0 and LEDS = line 1
handles.s = daq.createSession('ni');
addDigitalChannel(handles.s,'Dev1', 'Port0/Line0:1', 'OutputOnly');

handles.saveImageCount = 0;
handles.liveModeOn = 0;
handles.binNum = 2;
handles.binNumFlashVal = 2;
set(handles.binNumEdit, 'Value', 3);
set(handles.binNumFlash, 'Value', 3);
handles.camerahasrun = 0;
handles.xOffset = 80; % Should be a factor of 4, given in pixels with binning =1x1, positive offset shifts frame to left
handles.setroix0 = 88 - handles.xOffset/handles.binNum;
handles.setroiy0 = 1;
handles.setroix1 = 607 - handles.xOffset/handles.binNum;
handles.setroiy1 = 520;
handles.conversion = 1;
handles.conversionFlashVal = 1;
set(handles.conversionFactor, 'Value', 2);
set(handles.conversionFlash, 'Value', 2);
set(handles.flashPowerMenu, 'Value', 8);
guidata(hObject, handles);

% UIWAIT makes pco_edge_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pco_pixelfly_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


function exposureTimeEdit_Callback(hObject, eventdata, handles)

if (handles.liveModeOn == 1)
    del_timebase=uint32(2);
    del_time=uint32(0);
    exp_timebase=uint32(2);
    exp_time=uint32(str2num(get(handles.exposureTimeEdit, 'String')));
    errorCode = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', handles.out_ptr_pf,del_time,exp_time,del_timebase,exp_timebase);
    pco_errdisp('PCO_PCO_SetDelayExposureTime',errorCode);
    
end


% --- Executes during object creation, after setting all properties.
function exposureTimeEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fileBaseNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileBaseNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileBaseNameEdit as text
%        str2double(get(hObject,'String')) returns contents of fileBaseNameEdit as a double


% --- Executes during object creation, after setting all properties.
function fileBaseNameEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in binNumEdit.
function binNumEdit_Callback(hObject, eventdata, handles)

if (handles.liveModeOn == 1)
    uiwait(warndlg('You must restart Live Mode before new Bin Size takes effect.'));
end

if (get(handles.binNumEdit, 'Value') == 2)
    handles.binNum = 1;
    handles.setroix0 = 175 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 1214 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 1040;
    guidata(hObject,handles)
elseif (get(handles.binNumEdit, 'Value') == 4)
    handles.binNum = 4;
    handles.setroix0 = 45 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 304 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 260;
    guidata(hObject,handles)
else
    handles.binNum = 2;
    handles.setroix0 = 88 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 607 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 520;
    guidata(hObject,handles)

end


% --- Executes during object creation, after setting all properties.
function binNumEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IRSensitivityEdit.
function IRSensitivityEdit_Callback(hObject, eventdata, handles)

if (handles.liveModeOn == 1)
    uiwait(warndlg('You must restart Live Mode before the IR Sensitivity update takes effect.'));
end


function exposureTimeEdit2_Callback(hObject, eventdata, handles)

if (handles.liveModeOn == 1)
    del_timebase=uint32(2);
    del_time=uint32(0);
    exp_timebase=uint32(2);
    exp_time=uint32(str2num(get(handles.exposureTimeEdit2, 'String')));
    errorCode = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', handles.out_ptr_pf,del_time,exp_time,del_timebase,exp_timebase);
    pco_errdisp('PCO_PCO_SetDelayExposureTime',errorCode);
    
end


% --- Executes during object creation, after setting all properties.
function exposureTimeEdit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in flashPowerMenu.
function flashPowerMenu_Callback(hObject, eventdata, handles)

if (get(handles.flashPowerMenu, 'Value') == 2)
    handles.flashPower = 1;
    set(handles.exposureTimeEdit2, 'String', '2300');
    guidata(hObject,handles)
else if (get(handles.flashPowerMenu, 'Value') == 3)
        handles.flashPower = 2;
        set(handles.exposureTimeEdit2, 'String', '1280');
        guidata(hObject,handles)
    else if (get(handles.flashPowerMenu, 'Value') == 4)
            handles.flashPower = 4;
            set(handles.exposureTimeEdit2, 'String', '600');
            guidata(hObject,handles)
        else if (get(handles.flashPowerMenu, 'Value') == 5)
                handles.flashPower = 8;
                set(handles.exposureTimeEdit2, 'String', '400');
                guidata(hObject,handles)
            else if (get(handles.flashPowerMenu, 'Value') == 6)
                    handles.flashPower = 16;
                    set(handles.exposureTimeEdit2, 'String', '300');
                    guidata(hObject,handles)
                else if (get(handles.flashPowerMenu, 'Value') == 7)
                        handles.flashPower = 32;
                        set(handles.exposureTimeEdit2, 'String', '220');
                        guidata(hObject,handles)
                    else if (get(handles.flashPowerMenu, 'Value') == 8)
                            handles.flashPower = 64;
                            set(handles.exposureTimeEdit2, 'String', '180');
                            guidata(hObject,handles)
                        else
                            handles.flashPower = 64;
                            set(handles.exposureTimeEdit2, 'String', '180');
                            guidata(hObject,handles)
                        end
                    end
                end
            end
        end
    end
end


% --- Executes during object creation, after setting all properties.
function flashPowerMenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)

if handles.camerahasrun == 0;
    uiwait(warndlg('You must run Live Mode before setting the ROI.'));
    set(handles.setROI, 'Value', 0);
    guidata(hObject, handles);
    
else
    if get(handles.liveMode, 'Value') == 1
        pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);
        set(handles.liveMode, 'Value', 0);
        handles.liveModeOn = 0;
        guidata(hObject,handles)
    end
    
    if get(handles.setROI, 'Value') == 1
        handles.rectangle = imrect(gca, [10 10 100 100]);
        setFixedAspectRatioMode(handles.rectangle,1)
        guidata(hObject, handles);
    else
        ROIPosition = round(getPosition(handles.rectangle));
        oldx0 = handles.setroix0;
        oldy0 = handles.setroiy0;
        handles.setroix0 = oldx0 - 1 + ROIPosition(1);
        handles.setroiy0 = oldy0 - 1 + ROIPosition(2);
        handles.setroix1 = oldx0 - 1 + ROIPosition(1) + ROIPosition(3) - 1;
        handles.setroiy1 = oldy0 - 1 + ROIPosition(2) + ROIPosition(4) - 1;
        guidata(hObject, handles);
        delete(handles.rectangle);
        set(handles.liveMode, 'Value', 1)
        liveMode_Callback(handles.liveMode, eventdata, handles)
    end
end


% --- Executes on button press in resetROI.
function resetROI_Callback(hObject, eventdata, handles)

if get(handles.liveMode, 'Value') == 1
    pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);
    set(handles.liveMode, 'Value', 0);
    handles.liveModeOn = 0;
    guidata(hObject,handles)
end

if (get(handles.binNumEdit, 'Value') == 2)
    handles.setroix0 = 175 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 1214 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 1040;
    guidata(hObject,handles)
    set(handles.liveMode, 'Value', 1)
    liveMode_Callback(handles.liveMode, eventdata, handles)
elseif (get(handles.binNumEdit, 'Value') == 3)
    handles.binNum = 4;
    handles.setroix0 = 45 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 304 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 260;
    guidata(hObject,handles)
elseif (get(handles.binNumEdit, 'Value') == 1)
    handles.setroix0 = 88 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 607 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 520;
    guidata(hObject,handles)
    set(handles.liveMode, 'Value', 1)
    liveMode_Callback(handles.liveMode, eventdata, handles)
end


% --- Executes on selection change in conversionFactor.
function conversionFactor_Callback(hObject, eventdata, handles)

if (handles.liveModeOn == 1)
    uiwait(warndlg('You must restart Live Mode before new Conversion Factor takes effect.'));
end

if (get(handles.conversionFactor, 'Value') == 3)
    handles.conversion = 1.5;
    guidata(hObject,handles)
else
    handles.conversion = 1;
    guidata(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function conversionFactor_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in liveMode.
function liveMode_Callback(hObject, eventdata, handles)

if (get(hObject, 'Value') == 1)
    % open camera - set to trigger mode 0
    
    if (get(handles.setROI, 'Value') == 1)
        set(hObject, 'Value', 0)
        uiwait(warndlg('You must complete ROI selection before restarting Live Mode.'));
    else
        [ errorCode_pf, handles.out_ptr_pf, handles.sBufNr_pf, im_ptr_pf, ev_ptr_pf ] = pco_pf_open(str2num(get(handles.exposureTimeEdit, 'String')) * 1000 ,0, handles.binNum, handles.setroix0, handles.setroix1, handles.setroiy0, handles.setroiy1, get(handles.IRSensitivityEdit, 'Value'), handles.conversion);
        
        handles.camerahasrun = 1;
        handles.liveModeOn = 1;
        
        %illumination string
        set(handles.illuminationType, 'String', 'Illumination Type : LED');
        guidata(hObject,handles)
        
        %set hardware trigger for LEDs
        outputSingleScan(handles.s,[0 1])
        
        %set figure window on top of command window
        guidata(hObject,handles)
        figure(gcf)
        
        image_stack = zeros(((handles.setroix1-handles.setroix0)+1),((handles.setroiy1-handles.setroiy0)+1))';
        
        % while loop
        while get(hObject,'Value')
            image_stack = pco_pf_getsnapshot(handles.out_ptr_pf, handles.sBufNr_pf, im_ptr_pf, ev_ptr_pf, handles.binNum, handles.setroix0, handles.setroix1, handles.setroiy0, handles.setroiy1);
            pco_errdisp('pco_edge_getsnapshot', errorCode_pf);
            imagesc(image_stack(:,:));
            axis off
            colormap(gray(256))
            %Set min, mean, max values
            minVal = num2str(round((double(min(image_stack(:))) / (2^16))*100));
            meanVal = num2str(round((double(mean(image_stack(:))) / (2^16))*100));
            maxVal = num2str(round((double(max(image_stack(:))) / (2^16))*100));
            set(handles.minValEdit, 'String', ['Min : ' minVal '%']);
            set(handles.meanValEdit, 'String', ['Mean : ' meanVal '%']);
            set(handles.maxValEdit, 'String', ['Max : ' maxVal '%']);
            %percentage of pixels at max value
            maxValue = max(image_stack(:));
            idx = find(image_stack(:) == maxValue);
            sizeofvec = length(idx);
            pixels = num2str(round(double(sizeofvec*100 / numel(image_stack)), 2));
            set(handles.pixelsAtMax, 'String', ['Pixels at Max : ' pixels '%']);
            guidata(hObject,handles)
            %prevent drawnow from crashing
            set(gcf, 'Renderer', 'painters')
            drawnow
        end
    end
else
    % Close camera out
    pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);
    handles.liveModeOn = 0;
    outputSingleScan(handles.s,[0 0])
    guidata(hObject,handles)
end


% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)

if get(handles.liveMode, 'Value') == 1
    pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);
    set(handles.liveMode, 'Value', 0);
    handles.liveModeOn = 0;
    guidata(hObject,handles)
end
               
%open camera
[ errorCode_pf, handles.out_ptr_pf, handles.sBufNr_pf, im_ptr_pf, ev_ptr_pf ] = ...
    pco_pf_open(str2num(get(handles.exposureTimeEdit2, 'String')) * 1000,0, ...
    handles.binNumFlashVal, handles.setroix0, handles.setroix1, ...
    handles.setroiy0, handles.setroiy1, get(handles.IRSensitivityEdit, 'Value'),...
    handles.conversionFlashVal);

%illumination string
set(handles.illuminationType, 'String', 'Illumination Type : Flash');
guidata(hObject,handles)

% set hardware trigger for flash
outputSingleScan(handles.s,[1 0])

%set figure window on top of command window
guidata(hObject,handles)
figure(gcf)

axes(handles.cameraAxes);
image_stack = zeros(((handles.setroix1-handles.setroix0)+1),((handles.setroiy1-handles.setroiy0)+1))';
%take  2 snapshots


image_stack = pco_pf_getsnapshot(handles.out_ptr_pf, handles.sBufNr_pf, im_ptr_pf, ev_ptr_pf, handles.binNumFlashVal, handles.setroix0, handles.setroix1, handles.setroiy0, handles.setroiy1);
pco_errdisp('pco_edge_getsnapshot', errorCode_pf);
imagesc(image_stack(:,:));
axis off
colormap(gray(256))
%Set min, mean, max values
minVal = num2str(round((double(min(image_stack(:))) / (2^16))*100));
meanVal = num2str(round((double(mean(image_stack(:))) / (2^16))*100));
maxVal = num2str(round((double(max(image_stack(:))) / (2^16))*100));
set(handles.minValEdit, 'String', ['Min : ' minVal '%']);
set(handles.meanValEdit, 'String', ['Mean : ' meanVal '%']);
set(handles.maxValEdit, 'String', ['Max : ' maxVal '%']);

%percentage of pixels at max value
maxValue = max(image_stack(:));
idx = find(image_stack(:) == maxValue);
sizeofvec = length(idx);
pixels = num2str(round(double(sizeofvec*100 / numel(image_stack)), 2));
set(handles.pixelsAtMax, 'String', ['Pixels at Max : ' pixels '%']);
guidata(hObject,handles)
set(gcf, 'Renderer', 'painters')            
drawnow

axes(handles.cameraAxes2);
image_stack2 = zeros(((handles.setroix1-handles.setroix0)+1),((handles.setroiy1-handles.setroiy0)+1))';

%take snapshot
image_stack2 = pco_pf_getsnapshot(handles.out_ptr_pf, handles.sBufNr_pf, im_ptr_pf, ev_ptr_pf, handles.binNumFlashVal, handles.setroix0, handles.setroix1, handles.setroiy0, handles.setroiy1);
pco_errdisp('pco_edge_getsnapshot', errorCode_pf);
imagesc(image_stack2(:,:));
axis off
colormap(gray(256))
%Set min, mean, max values
minVal = num2str(round((double(min(image_stack2(:))) / (2^16))*100));
meanVal = num2str(round((double(mean(image_stack2(:))) / (2^16))*100));
maxVal = num2str(round((double(max(image_stack2(:))) / (2^16))*100));
set(handles.minValEdit, 'String', ['Min : ' minVal '%']);
set(handles.meanValEdit, 'String', ['Mean : ' meanVal '%']);
set(handles.maxValEdit, 'String', ['Max : ' maxVal '%']);

%percentage of pixels at max value
maxValue = max(image_stack2(:));
idx = find(image_stack2(:) == maxValue);
sizeofvec = length(idx);
pixels = num2str(round(double(sizeofvec*100 / numel(image_stack2)), 2));
set(handles.pixelsAtMax, 'String', ['Pixels at Max : ' pixels '%']);
guidata(hObject,handles)
            
drawnow

outputSingleScan(handles.s,[0 0])

%close camera
pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);


% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)

fileName = get(handles.fileBaseNameEdit, 'String');
if isempty(fileName)
    uiwait(warndlg('You must enter a File Base Name.'));
else
    datefolder = datestr(now,'yyyy-mm-dd');
    
    if ~isdir(datefolder)
        mkdir(datefolder)
    end
    
    while exist([datefolder filesep fileName '_' num2str(handles.saveImageCount) '.tif'],'file')
        handles.saveImageCount = handles.saveImageCount + 1;
        guidata(hObject, handles);
    end
    
    imwrite(getimage(handles.cameraAxes),  [datefolder filesep fileName '_' num2str(handles.saveImageCount) '.tif']);
    imwrite(getimage(handles.cameraAxes2),  [datefolder filesep fileName '_' num2str(handles.saveImageCount)+1 '.tif']);
   
    guidata(hObject, handles);
    
    if get(handles.saveGUI, 'Value') == 1
        saveas(gcf, [datefolder filesep fileName '_' num2str(handles.saveImageCount) 'GUI.tif']);
        guidata(hObject, handles);
        h = msgbox('Image and GUI Saved');
    else
    h = msgbox('Image Saved');
    end
    
    handles.saveImageCount = handles.saveImageCount + 2;
    guidata(hObject, handles);
    
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if get(handles.liveMode, 'Value') == 1
    pco_edge_close(handles.out_ptr_pf, handles.sBufNr_pf);
    
end

delete(hObject);


% --- Executes on button press in saveGUI.
function saveGUI_Callback(hObject, eventdata, handles)
% hObject    handle to saveGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveGUI


% --- Executes on selection change in conversionFlash.
function conversionFlash_Callback(hObject, eventdata, handles)

if (get(handles.conversionFlash, 'Value') == 3)
    handles.conversionFlashVal = 1.5;
    guidata(hObject,handles)
else
    handles.conversionFlashVal = 1;
    guidata(hObject,handles)
end


% --- Executes during object creation, after setting all properties.
function conversionFlash_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in binNumFlash.
function binNumFlash_Callback(hObject, eventdata, handles)

if (get(handles.binNumFlash, 'Value') == 2)
    handles.binNumFlashVal = 1;
    handles.setroix0 = 175 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 1214 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 1040;
    guidata(hObject,handles)
elseif (get(handles.binNumFlash, 'Value') == 4)
    handles.binNumFlashVal = 4;
    handles.setroix0 = 45 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 304 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 260;
    guidata(hObject,handles)
else
    handles.binNumFlashVal = 2;
    handles.setroix0 = 88 - handles.xOffset/handles.binNum;
    handles.setroiy0 = 1;
    handles.setroix1 = 607 - handles.xOffset/handles.binNum;
    handles.setroiy1 = 520;
    guidata(hObject,handles)
end




% --- Executes during object creation, after setting all properties.
function binNumFlash_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
