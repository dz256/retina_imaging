
while get(hObject,'Value')
    % toggle button is pressed, live preview on
    tstart = tic;
    
    % first frame, initialize camera
    if imgcount == 0
                
        pause(0.2);
        handles.image_current = zeros(act_ysize,act_xsize,'uint16');
        set(handles.popupmenu1, 'Value', 1)
        
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
        
        % start recording if it is off
        handles.subfunc.fh_start_camera(handles.out_ptr);
        pause(0.5);
        disp('live preview on');
    end
    % -----------------------------------
    n = rem(imgcount,2) + 1;
    if(n == 1)
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
            % display image
            %             set(handles.h_image, 'CData', handles.image_stack(:,:,n)');
            %             drawnow;
            handles.image_current = (handles.image_stack(:,:,n)');
            image_show = cv.normalize(handles.image_current, 'Alpha', 0, 'Beta', 2^16-1, 'NormType', 'MinMax');
            cv.imshow(handles.name, image_show);
            drawnow;
            
            handles.buflist_2.dwStatusDll= bitand(handles.buflist_2.dwStatusDll,hex2dec('FFFF7FFF'));
            
            handles.im_ptr_2 = libpointer('uint16Ptr',handles.image_stack(:,:,n));
    end
    
    imgcount = imgcount + 1;
    % display FPS
    telapsed = toc(tstart);
    fps = round(1/telapsed, 1);
    set(handles.text2, 'String', [handles.name, ' ', sprintf('%04.1f',fps)]);
end
set(handles.text2, 'String', [handles.name, ' ', sprintf('%04.1f',0)]);
disp('live preview off');





if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
      % Camera is off. Change button string and start camera.
      set(handles.startStopCamera,'String','Stop Camera')
      start(handles.video)
      set(handles.startAcquisition,'Enable','on');
      set(handles.captureImage,'Enable','on');
else
      % Camera is on. Stop camera and change button string.
      set(handles.startStopCamera,'String','Start Camera')
      stop(handles.video)
      set(handles.startAcquisition,'Enable','off');
      set(handles.captureImage,'Enable','off');
end