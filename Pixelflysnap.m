[ errorCode_pf, out_ptr_pf, sBufNr_pf, im_ptr_pf, ev_ptr_pf ] = pco_pf_open(5,0);

%s = daq.createSession('ni');
%addDigitalChannel(s,'Dev1', 'Port0/Line0', 'OutputOnly');
%outputSingleScan(s,1)

image_stack = zeros(1392,1040)';

tic
for imIdx = 1:10
    image_stack = pco_pf_getsnapshot(out_ptr_pf, sBufNr_pf, im_ptr_pf, ev_ptr_pf);
    pco_errdisp('pco_edge_getsnapshot', errorCode_pf);
    imagesc(image_stack(:,:),[1500 5000]);
    colormap(gray(256))
    drawnow
end
toc

%outputSingleScan(s,0)
pco_edge_close(out_ptr_pf, sBufNr_pf);