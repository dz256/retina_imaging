function varargout = NewSDKgui(varargin)
% NEWSDKGUI MATLAB code for NewSDKgui.fig
%      NEWSDKGUI, by itself, creates a new NEWSDKGUI or raises the existing
%      singleton*.
%
%      H = NEWSDKGUI returns the handle to a new NEWSDKGUI or the handle to
%      the existing singleton*.
%
%      NEWSDKGUI('CALLBqACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWSDKGUI.M with the given input arguments.
%
%      NEWSDKGUI('Property','Value',...) creates a new NEWSDKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewSDKgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewSDKgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewSDKgui

% Last Modified by GUIDE v2.5 04-Mar-2017 19:54:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewSDKgui_OpeningFcn, ...
                   'gui_OutputFcn',  @NewSDKgui_OutputFcn, ...
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


% --- Executes just before NewSDKgui is made visible.
function NewSDKgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewSDKgui (see VARARGIN)

% set up Imaq and arduino as global variables:
% create ardiuno object and popup default:
ar = arduino('COM6','UNO');
set(handles.BinSize_lm,'Value',2);
set(handles.BinSize_c,'Value',2);
set(handles.Conversion_lm,'Value',1);
set(handles.Conversion_c,'Value',1);
set(handles.ExT_lm,'String',5);
set(handles.ExT_c,'String',180);
%--------------------------------
% set up PCO camera:
if(~exist('triggermode','var'))
    triggermode = 'immediate';
end

if(~exist('binningh','var'))
    binningh = '2';
end

if(~exist('binningv','var'))
    binningv = '2';
end

if(~exist('convf','var'))
    convf = 0;
end

if(~exist('exptime','var'))
    exptime = 5000;
end

if(~exist('pixelclk','var'))
    pixelclk = 0;
end

if(~exist('imcount','var'))
    imcount = 1;
end
% define the video object: 
vid = videoinput('pcocameraadaptor', 0);

%Create adaptor source
src = getselectedsource(vid);

%Set logging to memory
vid.LoggingMode = 'memory';

%Set trigger mode
triggerconfig(vid, triggermode);

%Set frames per trigger
vid.FramesPerTrigger = imcount;

%Set horizontal binnig
src.B1BinningHorizontal = binningh;

%Set vertical binning
src.B2BinningVertical = binningv;

%Set conversion factor if specified
if convf ~= 0
src.CFConversionFactor_e_count = convf;
end

%Set Delay time unit
src.D1DelayTime_unit = 'us';

%Set Exposure time unit
src.E1ExposureTime_unit = 'us';

%Set exposure time
src.E2ExposureTime = exptime;

%Set Pixelclock if specified
if pixelclk ~=0
src.PCPixelclock_Hz = pixelclk;
end

%Set timestamp mode
src.TMTimestampMode = 'BinaryAndAscii';

%--------------------------------
% Choose default command line output for NewSDKgui
handles.output = hObject;

handles.saveImageCount = 0;
handles.liveModeOn = 0;
handles.binNum = 2;
%set(handles.binNumEdit, 'Value', 3); --> depends on binNumEdit?
%set(handles.conversionFactor, 'Value', 2); --> depends on conversionFactor Edit?
handles.vid = vid;
handles.src = src;
handles.ar = ar;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NewSDKgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NewSDKgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject; %just return the entire object - not actually neccassary
varargout{1} = handles.output;


% --- Executes on button press in OnOff_lm.
function OnOff_lm_Callback(hObject, eventdata, handles)
% hObject    handle to OnOff_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(handles.liveModeOn == 0)
        % turn liveMode on
        handles.liveModeOn = 1;
        % change camera setting to match user requirments:
        %Set horizontal binnig
            handles.src.B1BinningHorizontal = num2str(2^(handles.BinSize_lm.Value - 1));
            handles.src.B2BinningVertical = num2str(2^(handles.BinSize_lm.Value - 1));
            handles.src.E2ExposureTime = str2double(handles.ExT_lm.String) * 1000;
            handles.src.CFConversionFactor_e_count = char(handles.Conversion_lm.String(handles.Conversion_lm.Value));
        %start video preview:
        handles.hImage = image(zeros(handles.src.H2HardwareROI_Width,...
                              handles.src.H5HardwareROI_Height,1)...
                              ,'Parent',handles.axes1); 
        preview(handles.vid,handles.hImage);
        guidata(hObject, handles);
    else
        %turn off live mood
        handles.liveModeOn = 0;
        stoppreview(handles.vid);
        guidata(hObject, handles);
    end

% --- Executes on button press in Capture.
function Capture_Callback(hObject, eventdata, handles)
% hObject    handle to Capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% first - change setting to match capture settings:
    %update camera settings:
     handles.src.B1BinningHorizontal = num2str(2^(handles.BinSize_c.Value - 1));
     handles.src.B2BinningVertical = num2str(2^(handles.BinSize_c.Value - 1));
     handles.src.E2ExposureTime = str2double(handles.ExT_c.String) * 1000;
     handles.src.CFConversionFactor_e_count = char(handles.Conversion_c.String(handles.Conversion_c.Value));
       
%capture first image:
writeDigitalPin(handles.ar,12,1)
writeDigitalPin(handles.ar,13,0)
start(handles.vid);
% get data:
image1 = getdata(handles.vid);
%capture second image:
writeDigitalPin(handles.ar,12,0)
writeDigitalPin(handles.ar,13,1)
start(handles.vid);
% get data:
image2 = getdata(handles.vid);
% close LED
writeDigitalPin(handles.ar,13,0)
%draw etc.. 
imagesc(image1(:,:,:,1), 'Parent', handles.axes1);
axis off
colormap(gray(256))
imagesc(image2(:,:,:,1), 'Parent', handles.axes2);
axis off
colormap(gray(256))
%Set min, mean, max values
minVal = num2str(round((double(min(image1(:))) / (2^16))*100));
meanVal = num2str(round((double(mean(image1(:))) / (2^16))*100));
maxVal = num2str(round((double(max(image1(:))) / (2^16))*100));
set(handles.minI1, 'String', ['Min: ' minVal '%']);
set(handles.meanI1, 'String', ['Mean: ' meanVal '%']);
set(handles.maxI1, 'String', ['Max: ' maxVal '%']);
%percentage of pixels at max value
maxValue = max(image1(:));
idx = find(image1(:) == maxValue);
sizeofvec = length(idx);
pixels = num2str(round(double(sizeofvec*100 / numel(image1(:))), 2));
set(handles.numMaxI1, 'String', ['Pixels at Max : ' pixels '%']);
% repeat for 2nd image:
minVal = num2str(round((double(min(image2(:))) / (2^16))*100));
meanVal = num2str(round((double(mean(image2(:))) / (2^16))*100));
maxVal = num2str(round((double(max(image2(:))) / (2^16))*100));
set(handles.minI2, 'String', ['Min: ' minVal '%']);
set(handles.meanI2, 'String', ['Mean: ' meanVal '%']);
set(handles.maxI2, 'String', ['Max: ' maxVal '%']);
%percentage of pixels at max value
maxValue = max(image2(:));
idx = find(image2(:) == maxValue);
sizeofvec = length(idx);
pixels = num2str(round(double(sizeofvec*100 / numel(image2(:))), 2));
set(handles.numMaxI2, 'String', ['Pixels at Max : ' pixels '%']);

%update everything
guidata(hObject,handles)

% --- Executes on button press in SaveImage.
function SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
    %get param settings to add to string:
    bin_num = handles.BinSize_c.String(handles.BinSize_c.Value);
    bin = regexprep(bin_num,'[^\w'']',''); %remove spaces 
    conv = strcat('conv_',handles.Conversion_c.String(handles.Conversion_c.Value));
    conv = strrep(conv,'.','_'); %replase dots 
    expo = strcat('exposure_',handles.ExT_c.String,'ms');
    
    %handles.src.E2ExposureTime = str2double(handles.ExT_c.String) * 1000;

  BasefileName = get(handles.fileBaseName, 'String');
  fileName = strcat(BasefileName,'-bin_',bin,conv,expo);
if isempty(fileName)
    uiwait(warndlg('You must enter a File Base Name.'));
else 
    datefolder = datestr(now,'yyyy-mm-dd');
    %if diectory does not exsits, create one:
    if ~isdir(datefolder)
        mkdir(datefolder)
    end
    
    while exist([datefolder filesep char(fileName) '_' num2str(handles.saveImageCount) '.tif'],'file')
        handles.saveImageCount = handles.saveImageCount + 1;
        guidata(hObject, handles);
    end
    
    imwrite(getimage(handles.axes1),  [datefolder filesep char(fileName) '_' num2str(handles.saveImageCount) '.tif']);
    imwrite(getimage(handles.axes2),  [datefolder filesep char(fileName) '_' num2str(handles.saveImageCount)+1 '.tif']);
   
    guidata(hObject, handles);
    
    %let user know image saved 
    h = msgbox('Image Saved');
    
    handles.saveImageCount = handles.saveImageCount + 2;
    guidata(hObject, handles);
    
end

% --- Executes on button press in IR sensitivity -- .
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checked = get(hObject,'Value');
if checked
    handles.src.IRMode = 'on';
else
    handles.src.IRMode = 'off';
end


% --- Executes on selection change in BinSize_lm.
function BinSize_lm_Callback(hObject, eventdata, handles)
% hObject    handle to BinSize_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BinSize_lm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BinSize_lm
    if(handles.liveModeOn == 1) %if live mode on: update and restart:
        stoppreview(handles.vid); %stop preview
         %update settings:
         handles.src.B1BinningHorizontal = num2str(2^(get(hObject,'Value') - 1));
         handles.src.B2BinningVertical = num2str(2^(get(hObject,'Value') - 1));
         %restart peview:
         preview(handles.vid,handles.hImage);
    end
    


% --- Executes during object creation, after setting all properties.
function BinSize_lm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BinSize_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Conversion_lm.
function Conversion_lm_Callback(hObject, eventdata, handles)
% hObject    handle to Conversion_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Conversion_lm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Conversion_lm
    if(handles.liveModeOn == 1) %if live mode on: update and restart:
            stoppreview(handles.vid); %stop preview
             %update settings:             
             contents = cellstr(get(hObject,'String'));
             handles.src.CFConversionFactor_e_count = char(contents{get(hObject,'Value')});
          %restart peview:
             preview(handles.vid,handles.hImage);
    end

% --- Executes during object creation, after setting all properties.
function Conversion_lm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Conversion_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExT_lm_Callback(hObject, eventdata, handles)
% hObject    handle to ExT_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExT_lm as text
%        str2double(get(hObject,'String')) returns contents of ExT_lm as a double
    if(handles.liveModeOn == 1) %if live mode on: update and restart:
            stoppreview(handles.vid); %stop preview
             %update settings:
               handles.src.E2ExposureTime = str2double(get(hObject,'String')) * 1000;
                   %restart peview:
             preview(handles.vid,handles.hImage);
    end


% --- Executes during object creation, after setting all properties.
function ExT_lm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExT_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BinSize_c.
function BinSize_c_Callback(hObject, eventdata, handles)
% hObject    handle to BinSize_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BinSize_c contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BinSize_c


% --- Executes during object creation, after setting all properties.
function BinSize_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BinSize_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Conversion_c.
function Conversion_c_Callback(hObject, eventdata, handles)
% hObject    handle to Conversion_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Conversion_c contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Conversion_c


% --- Executes during object creation, after setting all properties.
function Conversion_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Conversion_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExT_c_Callback(hObject, eventdata, handles)
% hObject    handle to ExT_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExT_c as text
%        str2double(get(hObject,'String')) returns contents of ExT_c as a double


% --- Executes during object creation, after setting all properties.
function ExT_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExT_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileBaseName_Callback(hObject, eventdata, handles)
% hObject    handle to fileBaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileBaseName as text
%        str2double(get(hObject,'String')) returns contents of fileBaseName as a double


% --- Executes during object creation, after setting all properties.
function fileBaseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileBaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
