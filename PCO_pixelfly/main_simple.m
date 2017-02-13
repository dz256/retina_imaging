% pixelfly
[ errorCode_pf, out_ptr_pf, sBufNr_pf, im_ptr_pf, ev_ptr_pf ] = pco_pf_open(5);

image_stack = pco_pf_getsnapshot(out_ptr_pf, sBufNr_pf, im_ptr_pf, ev_ptr_pf);
pco_errdisp('pco_edge_getsnapshot', errorCode_pf);
figure;imshow(image_stack,[]);

pco_edge_close(out_ptr_pf, sBufNr_pf);
