//-----------------------------------------------------------------//
// Name        | readme.txt                  | Type: ( ) source    //
//-------------------------------------------|       ( ) header    //
// Project     | Matlab edge                 |       (*) others    //
//-----------------------------------------------------------------//
// Platform    | INTEL PC                                          //
//-----------------------------------------------------------------//
// Environment | Matlab 2011                                       //
//-----------------------------------------------------------------//
// Purpose     | instructions for use                              //
//-----------------------------------------------------------------//
// Author      | MBL, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    | 0,0,0,6                                           //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//             |                                                   //
//             |                                                   //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2012 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


The Matlab edge project is a collection of example m-files, one c-file and
additional header files.
Also the necessary dll-files are included.

With these files the setup of the camera can be done and
there are function to grab images to an Matlab imagestack. 

Only a subset of all possible camera settings is done in the examples.
For further setup see the pco.camera SDK description.


To run the example code copy and unzip the matlab archiv in a distinct install directory.
Depending on your environment copy the dll and lib files either from the w32 or the x64
subdirectory to the install directory.

Then open Matlab and select the the install directory.

Compile the grabfunc.c mex function
'mex grabfunc.c -lSC2_Cam -L.\'


All m-files which begin with pco_ include subfunctions, which can be used in other files

There are three example files described below

For a simple test call camera_info.m m-file
'camera_info()'
This should output some messages about camera type and camera revisions


Single Grab
'edge_single(6)'
Grab and display a single image with exposure time of 6ms.

'edge_single(2,5)'
Grab and display a 5-time single images with starting exposure time of 2ms.
After each run exposure time is multiplied by factor 2


Multi grab to test different grab functions
'edge_test(20)'
does three grabs of 20 image into an imagestack and does display a portion of the images in an image window
camera is setup for low PixelRate of 95Mhz
first grab is calling the function from pco_get_live_images.m file
second grab is calling the function from pco_imagestack from the grabfunc mex file with addfirst variable set to 0
camera is setup for high PixelRate of 286Mhz
third grab is calling the function from pco_imagestack from the grabfunc mex file with addfirst variable set to 1


All m-files use a common structure glvar.
Setting variables of this structure different behaviour of loading/unloading SDK library and
open/close of the camera could be accomplished.


All example code was tested with Matlab2011 64Bit Version.

When writing your own m-files it might happen that matlab does stop due to a syntax or other error.
Because then the camera is not closed correctly, the next run of the corrected m-file will fail.
To avoid this best practice is to run 'pco_camera_info()', which will return with error but does 
close the camera and unload the SC2_Cam-library.If your m-file does alos use the grabfunc-library,
you have to unload this too, because it is internally linked to the SC2_Cam-library. 










  
