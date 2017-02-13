function varargout = pco_edge_gui(varargin)
% PCO_EDGE_GUI MATLAB code for pco_edge_gui.fig
%      PCO_EDGE_GUI, by itself, creates a new PCO_EDGE_GUI or raises the existing
%      singleton*.
%
%      H = PCO_EDGE_GUI returns the handle to a new PCO_EDGE_GUI or the handle to
%      the existing singleton*.
%
%      PCO_EDGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCO_EDGE_GUI.M with the given input arguments.
%
%      PCO_EDGE_GUI('Property','Value',...) creates a new PCO_EDGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pco_edge_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pco_edge_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pco_edge_gui

% Last Modified by GUIDE v2.5 06-Nov-2015 16:37:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pco_edge_gui_OpeningFcn, ...
    'gui_OutputFcn',  @pco_edge_gui_OutputFcn, ...
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

% --- Executes just before pco_edge_gui is made visible.
function pco_edge_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pco_edge_gui (see VARARGIN)
handles.imgcount = 0;
addpath(genpath('C:\Users\PERL\Copy\01 Matlab Projects\mexopencv-perl'));

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
set_default = 0;

handles.exposure_time = str2double(get(handles.edit1,'String'));
% handles.exposure_time = 10; %ms

[errorCode,glvar] = pco_edge_setup_live(set_default, glvar, handles.exposure_time);
pco_errdisp('pco_edge_setup', errorCode);
handles.out_ptr = glvar.out_ptr;
handles.subfunc=pco_camera_subfunction();

% stop camera if it is running
handles.subfunc.fh_stop_camera(handles.out_ptr);

%get Camera Description
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', handles.out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);
handles.width=uint16(cam_desc.wMaxHorzResStdDESC);
handles.height=uint16(cam_desc.wMaxVertResStdDESC);
handles.image_stack = zeros(handles.width,handles.height,2,'uint16');

% get camera name
text=blanks(100);
[errorCode,~,text] = calllib('PCO_CAM_SDK','PCO_GetInfoString',glvar.out_ptr,1,text,100);
pco_errdisp('PCO_GetInfoString',errorCode);
if ~isempty(strfind(text,'edge'))
    handles.name = 'edge';
    display('camera: PCO edge');
elseif ~isempty(strfind(text,'pixelfly'))
    handles.name = 'pixelfly';
    display('camera: PCO pixelfly');
else
    handles.name = 'unknown';
    display('camera: unknown');
end

cv.namedWindow(handles.name, 0); %0 WINDOW_NORMAL; 1 WINDOW_AUTOSIZE

%Allocate 2 SDK buffer and set address of buffers in stack
handles.sBufNr_1 = int16(-1);
handles.im_ptr_1 = libpointer('uint16Ptr',handles.image_stack(:,:,1));
handles.ev_ptr_1 = libpointer('voidPtr');

handles.sBufNr_2 = int16(-1);
handles.im_ptr_2 = libpointer('uint16Ptr',handles.image_stack(:,:,2));
handles.ev_ptr_2 = libpointer('voidPtr');

set(handles.text2, 'String', [handles.name, ' ', sprintf('%04.1f',0)]);

handles.mode_reset = 0;

% Choose default command line output for pco_edge_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pco_edge_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = pco_edge_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles, 'name')
    varargout{1}.name = handles.name;
    varargout{1}.out_ptr = handles.out_ptr;
else
    varargout{1} = [];
end
if isfield(handles, 'sBufNr')
    varargout{1}.sBufNr = handles.sBufNr;
    varargout{1}.im_ptr = handles.im_ptr;
    varargout{1}.ev_ptr = handles.ev_ptr;
end


% --- Executes on button press in togglebutton1 live preview.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause (0.5);
% Hint: get(hObject,'Value') returns toggle state of togglebutton1


act_xsize = handles.width;
act_ysize = handles.height;
imasize = 2 * act_xsize * act_ysize;
bitpix = 16;
imgcount = 0;

while get(hObject,'Value')
    % toggle button is pressed, live preview on
    tstart = tic;
    
    % first frame, initialize camera
    if imgcount == 0
                
        pause(0.2);
        handles.image_current = zeros(act_ysize,act_xsize,'uint16');
        set(handles.popupmenu1, 'Value', 1)
        
        % stop recording if it is on
        act_recstate = uint16(10);
        [errorCode,handles.out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', handles.out_ptr,act_recstate);
        pco_errdisp('PCO_GetRecordingState',errorCode);
        if(act_recstate ~= 0)
            % this will remove all pending buffers in the queue
            [errorCode, handles.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', handles.out_ptr);
            pco_errdisp('PCO_CancelImages',errorCode);
            
            [errorCode,handles.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', handles.out_ptr, 0);
            pco_errdisp('PCO_SetRecordingState',errorCode);
            pause(0.5);
        end
        
        % set trigger mode to auto
        handles.subfunc.fh_stop_camera(handles.out_ptr);
        triggermode=uint16(0);
        handles.subfunc.fh_set_triggermode(handles.out_ptr,triggermode);
        
        % set up exposure time
        handles.subfunc.fh_stop_camera(handles.out_ptr);
        handles.exposure_time = uint32(str2double(get(handles.edit1,'String')));
        handles.subfunc.fh_set_exposure_times(handles.out_ptr,handles.exposure_time, 2, 0, 0);
        errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', handles.out_ptr);
        if(errorCode)
            pco_errdisp('PCO_ArmCamera',errorCode);
            return;
        end
        
        [errorCode,handles.out_ptr,handles.sBufNr_1,handles.image_stack(:,:,1),handles.ev_ptr_1]  ...
            = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr,handles.sBufNr_1,imasize,handles.im_ptr_1,handles.ev_ptr_1);
        if(errorCode)
            pco_errdisp('PCO_AllocateBuffer 1 in imgcount 1',errorCode);
            return;
        end
        [errorCode,handles.out_ptr,handles.sBufNr_2,handles.image_stack(:,:,2),handles.ev_ptr_2]  ...
            = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr,handles.sBufNr_2,imasize,handles.im_ptr_2,handles.ev_ptr_2);
        if(errorCode)
            pco_errdisp('PCO_AllocateBuffer 2 in imgcount 1',errorCode);
            err  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',handles.out_ptr,handles.sBufNr_1);
            pco_errdisp('PCO_FreeBuffer',err);
            return;
        end
        
        ml_buflist_1.sBufNr = handles.sBufNr_1;
        handles.buflist_1 = libstruct('PCO_Buflist',ml_buflist_1);
        ml_buflist_2.sBufNr = handles.sBufNr_2;
        handles.buflist_2 = libstruct('PCO_Buflist',ml_buflist_2);
        
        % start recording if it is off
        handles.subfunc.fh_start_camera(handles.out_ptr);
        
        [errorCode,handles.out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', handles.out_ptr,0,0,handles.sBufNr_1,act_xsize,act_ysize,bitpix);
        pco_errdisp('PCO_AddBufferEx',errorCode);
        
        [errorCode,handles.out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', handles.out_ptr,0,0,handles.sBufNr_2,act_xsize,act_ysize,bitpix);
        pco_errdisp('PCO_AddBufferEx',errorCode);
        pause(0.5);
        disp('live preview on');
    end
    % -----------------------------------
    n = rem(imgcount,2) + 1;
    if(n == 1)
        %  disp(['Wait for buffer 1 n: ',int2str(n)]);
        [errorCode,handles.out_ptr,handles.buflist_1]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', handles.out_ptr,1,handles.buflist_1,50);
        if(errorCode)
            pco_errdisp('PCO_WaitforBuffer 1 in while loop',errorCode);
            break;
        end
        %  disp(['statusdll: ',num2str(buflist_1.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_1.dwStatusDrv,'%08X')]);
        if((bitand(handles.buflist_1.dwStatusDll,hex2dec('00008000')))&&(handles.buflist_1.dwStatusDrv==0))
            % 0x00008000 = buffer event is set
            % dwStatusDrv==0, no error occurred during transfer
            % s=strcat(s,'Event buf_1, image ',int2str(n),' done, StatusDrv ',num2str(buflist_1.dwStatusDrv,'%08X'));
            % this will copy our data to image_stack
            [errorCode,handles.out_ptr,handles.image_stack(:,:,n)]  ...
                = calllib('PCO_CAM_SDK','PCO_GetBuffer',handles.out_ptr,handles.sBufNr_1,handles.im_ptr_1,handles.ev_ptr_1);
            if(errorCode)
                pco_errdisp('PCO_GetBuffer',errorCode);
                break;
            end
            
            % display image
            %             set(handles.h_image, 'CData', handles.image_stack(:,:,n)');
            %             if imgcount == 0
            %                 caxis auto;
            %             end
            %             drawnow;
            handles.image_current = (handles.image_stack(:,:,n)');
            % normalize for display
            image_show = cv.normalize(handles.image_current, 'Alpha', 0, 'Beta', 2^16-1, 'NormType', 'MinMax');
            cv.imshow(handles.name, image_show);
            drawnow;
            
            handles.buflist_1.dwStatusDll= bitand(handles.buflist_1.dwStatusDll,hex2dec('FFFF7FFF'));
            
            handles.im_ptr_1 = libpointer('uint16Ptr',handles.image_stack(:,:,n));
            [errorCode,handles.out_ptr,handles.sBufNr_1,handles.image_stack(:,:,n),handles.ev_ptr_1] ...
                = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr,handles.sBufNr_1,imasize,handles.im_ptr_1,handles.ev_ptr_1);
            if(errorCode)
                pco_errdisp('PCO_AllocateBuffer',errorCode);
                break;
            end
            [errorCode,handles.out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', handles.out_ptr,0,0,handles.sBufNr_1,act_xsize,act_ysize,bitpix);
            if(errorCode)
                pco_errdisp('PCO_AddBufferEx',errorCode);
                break;
            end
        end
    else
        %  disp(['Wait for buffer 2 n: ',int2str(n)]);
        [errorCode,handles.out_ptr,handles.buflist_2]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', handles.out_ptr,1,handles.buflist_2,50);
        if(errorCode)
            pco_errdisp('PCO_WaitforBuffer 2 in while loop',errorCode);
            break;
        end
        %  disp(['statusdll: ',num2str(buflist_2.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_2.dwStatusDrv,'%08X')]);
        if(bitand(handles.buflist_2.dwStatusDll,hex2dec('00008000'))&&(handles.buflist_2.dwStatusDrv==0))
            % s=strcat(s,'Event buf_2, image ',int2str(n),' done, StatusDrv ',num2str(buflist_2.dwStatusDrv,'%08X'));
            % this will copy our data to image_stack
            [errorCode,handles.out_ptr,handles.image_stack(:,:,n)] ...
                = calllib('PCO_CAM_SDK','PCO_GetBuffer',handles.out_ptr,handles.sBufNr_2,handles.im_ptr_2,handles.ev_ptr_2);
            if(errorCode)
                pco_errdisp('PCO_GetBuffer',errorCode);
                break;
            end
            
            % display image
            %             set(handles.h_image, 'CData', handles.image_stack(:,:,n)');
            %             drawnow;
            handles.image_current = (handles.image_stack(:,:,n)');
            image_show = cv.normalize(handles.image_current, 'Alpha', 0, 'Beta', 2^16-1, 'NormType', 'MinMax');
            cv.imshow(handles.name, image_show);
            drawnow;
            
            handles.buflist_2.dwStatusDll= bitand(handles.buflist_2.dwStatusDll,hex2dec('FFFF7FFF'));
            
            handles.im_ptr_2 = libpointer('uint16Ptr',handles.image_stack(:,:,n));
            [errorCode,handles.out_ptr,handles.sBufNr_2,handles.image_stack(:,:,n),handles.ev_ptr_2] ...
                = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr,handles.sBufNr_2,imasize,handles.im_ptr_2,handles.ev_ptr_2);
            if(errorCode)
                pco_errdisp('PCO_AllocateBuffer',errorCode);
                break;
            end
            [errorCode,handles.out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', handles.out_ptr,0,0,handles.sBufNr_2,act_xsize,act_xsize,bitpix);
            if(errorCode)
                pco_errdisp('PCO_AddBufferEx',errorCode);
                break;
            end
        end
    end
    
    imgcount = imgcount + 1;
    % display FPS
    telapsed = toc(tstart);
    fps = round(1/telapsed, 1);
    set(handles.text2, 'String', [handles.name, ' ', sprintf('%04.1f',fps)]);
end
set(handles.text2, 'String', [handles.name, ' ', sprintf('%04.1f',0)]);
disp('live preview off');

% set trigger mode to software trigger
set(handles.popupmenu1, 'Value', 2)
handles.triggerMode = 'single';

%this will remove all pending buffers in the queue
[errorCode, handles.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', handles.out_ptr);
pco_errdisp('PCO_CancelImages',errorCode);

handles.subfunc.fh_stop_camera(handles.out_ptr);
triggermode=uint16(1);
handles.subfunc.fh_set_triggermode(handles.out_ptr,triggermode);
errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', handles.out_ptr);
if errorCode
    pco_errdisp('PCO_ArmCamera',errorCode);
    return
else
    disp('switched to single shot mode');
end

% Allocate Buffer
if handles.mode_reset == 0
    image_st = zeros(handles.height,handles.width);
    handles.sBufNr=int16(-1);
    handles.im_ptr = libpointer('uint16Ptr',image_st);
    handles.ev_ptr = libpointer('voidPtr');
    imasize = 2 * handles.width * handles.height;
    [errorCode,handles.out_ptr,handles.sBufNr,image_st,handles.ev_ptr]  ...
        = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr, handles.sBufNr, imasize, handles.im_ptr, handles.ev_ptr);
    if(errorCode)
        pco_errdisp('PCO_AllocateBuffer',errorCode);
        return;
    end
    handles.mode_reset = 1;
    uiresume(handles.figure1);
end
handles.subfunc.fh_start_camera(handles.out_ptr);

guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% uiresume(handles.figure1);

%this will remove all pending buffers in the queue
[errorCode, handles.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', handles.out_ptr);
pco_errdisp('PCO_CancelImages',errorCode);

%stop recording if it is on
handles.subfunc.fh_stop_camera(handles.out_ptr);

%free all buffers
if isfield(handles,'sBufNr_1')    
    errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',handles.out_ptr,handles.sBufNr_1);
    pco_errdisp('PCO_FreeBuffer sBufNr_1',errorCode);    
    errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',handles.out_ptr,handles.sBufNr_2);
    pco_errdisp('PCO_FreeBuffer sBufNr_2',errorCode);
end

if isfield(handles,'sBufNr')
    errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',handles.out_ptr,handles.sBufNr);
    pco_errdisp('PCO_FreeBuffer sBufNr',errorCode);
end

%close image window
cv.destroyWindow(handles.name);
%close camera
errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera',handles.out_ptr);
if(errorCode)
    pco_errdisp('PCO_CloseCamera',errorCode);
else
    disp('camera closed');
end

delete(handles.figure1);
delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global image_current;

[FileName, PathName] = uiputfile('*.tif', 'Save As', '..\sample_images\');
if PathName==0
    return;
end

SaveName = fullfile(PathName, FileName);
imwrite(handles.image_current, SaveName, 'tif');

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
edit1 = str2double(get(hObject,'string'));
if isnan(edit1)
    set(handles.edit1,'string','50');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
%Trigger: select trigger mode of camera
%            0: TRIGGER_MODE_AUTOTRIGGER
%            1: TRIGGER_MODE_SOFTWARETRIGGER
%            2: TRIGGER_MODE_EXTERNALTRIGGER
%            3: TRIGGER_MODE_EXTERNALEXPOSURECONTROL:

contents = get(hObject,'Value');
switch contents
    case 1
        % set trigger mode to auto
        handles.triggerMode = 'auto';
        handles.subfunc.fh_stop_camera(handles.out_ptr);
        triggermode=uint16(0);
        handles.subfunc.fh_set_triggermode(handles.out_ptr,triggermode);
        errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', handles.out_ptr);
        if errorCode
            pco_errdisp('PCO_ArmCamera',errorCode);
            return
        else
            disp('free run mode');
        end
    case 2
        % set trigger mode to software trigger
        handles.triggerMode = 'single';
        %this will remove all pending buffers in the queue
        [errorCode, handles.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', handles.out_ptr);
        pco_errdisp('PCO_CancelImages',errorCode);
        handles.subfunc.fh_stop_camera(handles.out_ptr);
        triggermode=uint16(1);
        handles.subfunc.fh_set_triggermode(handles.out_ptr,triggermode);
        errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', handles.out_ptr);
        if errorCode
            pco_errdisp('PCO_ArmCamera',errorCode);
            return
        else
            disp('single shot mode');
        end
        
        % Allocate Buffer
        if handles.mode_reset == 0
            handles.sBufNr=int16(-1);
            handles.im_ptr = libpointer('uint16Ptr',handles.image_stack(:,:,1));
            handles.ev_ptr = libpointer('voidPtr');
            imasize = 2 * handles.width * handles.height;
            [errorCode,handles.out_ptr,handles.sBufNr,handles.image_stack(:,:,1),handles.ev_ptr]  ...
                = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', handles.out_ptr, handles.sBufNr, imasize, handles.im_ptr, handles.ev_ptr);
            if(errorCode)
                pco_errdisp('PCO_AllocateBuffer',errorCode);
                return;
            end
            handles.mode_reset = 1;
            uiresume(handles.figure1);
        end
        
        handles.subfunc.fh_start_camera(handles.out_ptr);
    
    otherwise        
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
