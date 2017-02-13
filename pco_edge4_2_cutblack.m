function [image_stack] = pco_edge4_2_cutblack(stack_in)
%Cut black pixels of pco_edge4.2 full resolution image(s) in image_stack.
%Adapt this function if camera ROI is used.
%
%   [image_stack] = pco_edge4_2_cutblack(stack_in)
%
% * Input parameters :
%    stack_in    uint16(,2060,)  grabbed image stack
% * Output parameters :
%    image_stack uint16(,2048,)  image stack with cut black pixel
%

[yres,xres,count]=size(stack_in);
if(count==1)
 if(xres==2060)   
%  image_stack=zeros(yres,2048,'uint16');
  image_stack(:,:)=stack_in(:,1:2048);
 else
  image_stack(:,:)=stack_in(:,:);
 end 
else
 if(xres==2060)   
  image_stack=zeros(yres,2048,count,'uint16');
  for n=1:count
   image_stack(:,:,n)=stack_in(:,1:2048,n);
  end
 else
  image_stack=stack_in;
 end 
end