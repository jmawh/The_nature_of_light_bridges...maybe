; ####################################################################################################
; Work with the inverted data
; ####################################################################################################

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav', /VERBOSE
loadct, 5
; variables = fit_spec, numbermat, fit_model_temp, fit_model_elpres

; For a slice through the atmosphere at a given x or y coord:
atmos_slice = TRANSPOSE(REFORM(fit_model_temp[*,*,202]))
tvim, atmos_slice[*,*], /sc
; or a cut down version of the x axis
tvim, atmos_slice[170:230, *], /sc
; For a x-y map at a given atmospheric height:

tvim, fit_model_temp[25,*,*], /sc

; ###########################################################################################
; 	Cutting down the first 40 to the same size as the rest - saved in test_folder
; ###########################################################################################
; The first 40 frames (0-39) came with a full screen scan which is uneccessary and creates a 
; much bigger file size. This cuts that down
; file path to folder containing only the 0-39 th files - this only fixes the fit_model_temp files
; '/home/40147775/msci/inversion_data/zero_to_39_full_scans/inversion_burst_0000.sav'
; THIS CODE IS REDUNDANT, DATA DELETED TO MAKE SPACE
FOR i=0, 39 DO BEGIN &$
	IF (i le 9) THEN RESTORE, '/home/40147775/msci/inversion_data/zero_to_39_full_scans/inversion_burst_000'+arr2str(i, /trim)+'.sav' &$
	IF (i gt 9) AND (i le 99) THEN RESTORE, '/home/40147775/msci/inversion_data/zero_to_39_full_scans/inversion_burst_00'+arr2str(i, /trim)+'.sav' &$
	fit_model_temp = fit_model_temp[*,200:750, 260:810] &$
	IF (i le 9) THEN save, FILENAME='/home/40147775/msci/inversion_data/test_folder/inversion_burst_000'+arr2str(i, /trim)+'.sav', fit_model_temp &$
	IF (i gt 9) AND (i le 99) THEN save, FILENAME='/home/40147775/msci/inversion_data/test_folder/inversion_burst_00'+arr2str(i, /trim)+'.sav', fit_model_temp &$
ENDFOR


; unit test (kinda): comparison to make sure it worked - now redundant - simply a record of work.
restore, '/home/40147775/msci/inversion_data/test_folder/inversion_burst_0001.sav', /verbose
temp_new = fit_model_temp
restore, '/home/40147775/msci/inversion_data/zero_to_39_full_scans/inversion_burst_0001.sav'
temp = fit_model_temp
temp_new[10,0,0]
temp[10,200,260]
; these are the same

; These files have then been copied into the main usage folder: inversion_data/14Jul_Inv

; ###########################################################################################
; 		 slice of optical depth against height varying in time (single y value)
; ###########################################################################################

tau_and_x_against_time = fltarr(551, 75, 110)
y_value = 257
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_x_slice = TRANSPOSE(REFORM(temp[*,*,y_value])) &$
	tau_and_x_against_time[*,*,i] = tau_and_x_slice[*,*] &$
ENDFOR
	
xstepper, tau_and_x_against_time, xsize=1900, ysize=500
; frame 72, y=276 on is interesting - heat develops, propagates, collides, moves down to some extent?
; frame 39, y=284 just above the LB looks pretty odd - maybe check y=281-287 1 by 1
; 293 is the y value of a two hotspots(in sub_scans_300), one in each umbra, found from 
; marked_sub_scan[200:750, 250:810, 9], rotated it becomes 257


; ###########################################################################################
; 		 time evolution of x against y for a single optical depth
; ###########################################################################################

x_and_y_against_time = fltarr(551,551,110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	x_and_y_against_time[*,*,i] = fit_model_temp[10,*,*] &$
ENDFOR

xstepper, x_and_y_against_time, xsize=700, ysize=700

; investigations
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'
xstepper, TRANSPOSE(fit_model_temp), xsize=700, ysize=700
; this is shows the LB hotter than surroundings at about 60th optical depth step

; #############################################################################################
; 	Saving out some variables that do not have corrections applied
; #############################################################################################
; tau_and_x_against_time_n implies this took place at a y value of n 
; x_and_y_against_time_n implies this view is at the nth tau step

SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/uncorrected_first_analysis.sav', tau_and_x_against_time_276, tau_and_x_against_time_284, x_and_y_against_time_60, x_and_y_against_time_10

; #############################################################################################
; 		Applying corrections to the data.
; #############################################################################################
restore, '/home/40147775/msci/inversion_data/my_sav_files/uncorrected_first_analysis.sav'
; see variables above for those saved into this file.
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'
; /verbose yields depthscale (optical depths, tau) QS_corr, penumb_corr, umb_corr

 
temp = fit_model_tempx
; pixel picked in the light bridge
lb = REFORM(temp[*,210,276])
lb_umbcorr = REFORM(temp[*,210,276])*umb_corr
lb_pencorr = REFORM(temp[*,210,276])*penumb_corr
lb_qscorr = REFORM(temp[*,210,276])*QS_corr

plot, depthscale, lb			   ; white
oplot, depthscale, lb_umbcorr, color='90'  ; dull red
oplot, depthscale, lb_pencorr, color='60'  ; blue/purple
oplot, depthscale, lb_qscorr, color ='120' ; bright red

plot, depthscale, lb_umbcorr/lb, xtitle='Optical Depth', ytitle='Correction Factor'
oplot, depthscale, lb_pencorr/lb, color='90'
oplot, depthscale, lb_qscorr/lb, color='60'

; Creating a corrected version of tau_and_x_against_time_276
corr_tau_x_time = fltarr(551,75,110)
FOR i=0, 74 DO BEGIN &$
	corr_tau_x_time[*,i,*] = reform(tau_and_x_against_time[*,i,*]) * umb_corr[i] &$
ENDFOR

pmm, tau_and_x_against_time_276
pmm, corr_tau_x_time

xstepper, tau_and_x_against_time_276>2500<10000, xsize=1900, ysize=500
xstepper, corr_tau_x_time>3500<10000, xsize=1900, ysize=500


tau_and_x_against_time_276[1:10,10,1:10] 
penumb_corr[10]
corr_tau_x_time [1:10,10,1:10]

; #################################################################################################
;	Examining shocks far from the light bridge
; #################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav'
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'
xstepper, sub_scans_300, xsize=700, ysize=700
tvim, sub_scans_300[*,*, 74]
; this scan has a bright patch at (386, 545) moving vertically on the full scan
; this translates to (186, 285) in the reduced data set, we choose a vertical line, through
; pixel 186 for the full range of atmospheric heights
; 

tau_and_y_against_time = fltarr(551, 75, 110)
x_value = 186	; NEED A DIFFERENT VALUE
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_y_slice = TRANSPOSE(REFORM(temp[*,x_value,*])) &$
	tau_and_y_against_time[*,*,i] = tau_and_y_slice[*,*] &$
ENDFOR

xstepper, tau_and_y_against_time, xsize=1900, ysize=500

; slice through the LB, fixed x
tau_and_y_against_time = fltarr(551, 75, 110)
x_value = 210	; NEED A DIFFERENT VALUE
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_y_slice = TRANSPOSE(REFORM(temp[*,x_value,*])) &$
	tau_and_y_against_time[*,*,i] = tau_and_y_slice[*,*] &$
ENDFOR

xstepper, tau_and_y_against_time, xsize=1900, ysize=500
; the lb runs between y=270 and y=308 roughly - from fit_temp_model[10,*,*], cut to that area

xstepper, tau_and_y_against_time[270:308, *,*], xsize = 400, ysize=800

; Cut right up the middle of the larger umbra with umbra corrections
tau_and_y_against_time = fltarr(551, 75, 110)
x_value = 285	
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_y_slice = TRANSPOSE(REFORM(temp[*,x_value,*])) &$
	tau_and_y_against_time[*,*,i] = tau_and_y_slice[*,*] &$
ENDFOR
; applying correction
corr_tau_y_time = fltarr(551,75,110)
FOR i=0, 74 DO BEGIN &$
	corr_tau_y_time[*,i,*] = reform(tau_and_y_against_time[*,i,*]) * umb_corr[i] &$
ENDFOR

xstepper, tau_and_y_against_time, xsize=1900, ysize=500
xstepper, corr_tau_y_time, xsize=1900, ysize=500

; ######################################################################################################
; 			Creating time cubes examining each shock event at LB - REDUNDANT
; ######################################################################################################

;RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav'
; Results in to_do_list_and_results
;xstepper, marked_sub_scan, xsize = 700, ysize=700
;tvim, marked_sub_scan[200:700,400:700,75], /sc

; Turning marked_sub_scan coordinates into ones that can be used with the inversion data set:
;old_x = [403, 402, 385] 
;old_y = [548, 546, 552]
;new_x = old_x - 200
;new_y = (500-(old_y-500)) - 260
; these might all hve wrong y values
; 1. (403,548) -> (203,192), 45 deg
; 2. (402,546) -> (202,194), 45 deg
; 3. (385, 552)-> (185,188), vertical (403,548) -> (203,192), vertical
; 4. (403,548) -> (203,192), 45 deg

; ###################################################################################################
; 			Creating a slice at 45 degrees to the x-axis 
; ###################################################################################################
; the offset term refers to the difference in x and y. For example, to have a line of gradient 1
; pass through (403,548) -> (203,288) it needs to start at (0,85) => offset = 85
; (403, 546) -> (203, 286), offset = 83


RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'
angle_slice_tau_against_time = fltarr(450, 75, 110)
line_of_slice = REFORM(fit_model_temp[15,*,*])
offset = 83
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	FOR f=0, 449 DO BEGIN &$
		pix_x = f &$
		pix_y = offset + f &$
		angle_slice_tau_against_time[f,*,i] = temp[*, pix_x, pix_y] &$
		line_of_slice[pix_x, pix_y] = 4000
ENDFOR
	
xstepper, angle_slice_tau_against_time, xsize=1900, ysize=500
test = angle_slice_tau_against_time
test[203, *, *] = 6000
xstepper, test, xsize=1900, ysize=500

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'

image = REFORM(fit_model_temp[40,*,*])
image2 = marked_sub_scan[*,*,75]
FOR i=0, 400 DO BEGIN &$
	image[i,i+85] = 1000 &$
ENDFOR
SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/slice_403_546_45deg.sav', line_of_slice, angle_slice_tau_against_time

write_png, '/home/40147775/msci/figs/test1.png', line_of_slice

; ######################################################################################################
; 	Shock vertical propagation, from 73 on
; ######################################################################################################
vertical_slice_tau_against_time = fltarr(551, 75, 110)
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0077.sav'
line_of_slice = REFORM(fit_model_temp[15,*,*])
x_value = 178
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	tau_and_x_slice = TRANSPOSE(REFORM(fit_model_temp[*,x_value,*])) &$
	vertical_slice_tau_against_time[*,*,i] = tau_and_x_slice[*,*] &$
ENDFOR
line_of_slice[x_value, *] = 4000

tvim, line_of_slice
xstepper, vertical_slice_tau_against_time[*,0:20, *], xsize=1900, ysize=500


;#####################################################################################################
; 			Temperature - Intensity Comparison for a single time frame
; ####################################################################################################
; 77th time step, 10th depthscale step, one in temperature, one in intensity
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav'

x_and_y_against_time = fltarr(551,551,110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	x_and_y_against_time[*,*,i] = fit_model_temp[10,*,*] &$
ENDFOR

temp_frame77 = x_and_y_against_time[*,*,*]
intensity_frame77 = marked_sub_scan[200:750, 260:810, 0:110]


FOR i=0, 109 DO BEGIN &$
	window,0,xsize=700,ysize=700,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = temp_frame77[*,*,i] &$
	frame2 = intensity_frame77[*,*,i] &$
	tvim, frame &$
	contour, frame, levels=[50,100], /over, color='red' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/inversion_data/my_sav_files/temp_frame77/img'+ name + '.png', tvrd(/true) &$
	loadct, 0, /silent &$
	tvim, frame2 &$
	write_png, '/home/40147775/msci/inversion_data/my_sav_files/intensity_frame77/img'+ name + '.png', tvrd(/true) &$

ENDFOR

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p temp_frame_77.mp4

; #####################################################################################################
; 		Time frame 41 - determining temperature height of first shock event
; ####################################################################################################

RESTORE, 'inversion_burst_0041.sav'
x_and_y_over_tau = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau[*,*,i] = frame[*,*] &$
ENDFOR

; #####################################################################################################
; 			Time frame 74 - determining temperature height of the shock
; ####################################################################################################

RESTORE, 'inversion_burst_0074.sav'
x_and_y_over_tau74 = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau74[*,*,i] = frame[*,*] &$
ENDFOR
; The intensity pattern is noticable eveywhere- the entire atmosphere in the is hotter than the 
; surrounding area at the shock coordinates.

; #####################################################################################################
; 		Time frame 77/78 - determining temperature height the shock at the light bridge
; ####################################################################################################

RESTORE, 'inversion_burst_0077.sav'
x_and_y_over_tau77 = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau77[*,*,i] = frame[*,*] &$
ENDFOR

SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/shock77_the_golden_event.sav', x_and_y_over_tau74, x_and_y_over_tau77

xstepper, x_and_y_over_tau74, xsize=700, ysize=700
xstepper, x_and_y_over_tau77, xsize=700, ysize=700


RESTORE, 'inversion_burst_0078.sav'
x_and_y_over_tau78 = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau78[*,*,i] = frame[*,*] &$
ENDFOR

xstepper, x_and_y_over_tau78, xsize=700, ysize=700

; look at the lb at the pixels where it is hotter than the neighbourhood due to heating, frm 77
; pixel coordinate: (209, 283) - fix y and run over x
tau_and_x_against_time77 = fltarr(551, 75, 110)
y_value = 283
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_x_slice = TRANSPOSE(REFORM(temp[*,*,y_value])) &$
	tau_and_x_against_time77[*,*,i] = tau_and_x_slice[*,*] &$
ENDFOR
	
xstepper, tau_and_x_against_time77, xsize=1900, ysize=500


; #####################################################################################################
; 			Time frame 96 - is there a temperature change?
; ####################################################################################################

RESTORE, 'inversion_burst_0096.sav'
x_and_y_over_tau96 = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau96[*,*,i] = frame[*,*] &$
ENDFOR

xstepper, x_and_y_over_tau96, xsize=700, ysize=700


; Meeting with David, 15/11/18

; Taking an average of temperature across the light bridge and plotting against time 
; either with plot or tvim
RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/uncorrected_first_analysis.sav'
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'
tvim,tau_and_x_against_time_276[*,*,77]
; then run pick to get the left and right of the LB
temperature_time = FLTARR(75, 16)
left_of_lb = 206
right_of_lb = 219
FOR t = 0,15 DO BEGIN &$		; originally _276
    temperature_slice = TAU_AND_X_AGAINST_TIME_284[left_of_lb:right_of_lb, *, t+70] &$
    temperature_time[*,t] = REFORM(TOTAL(temperature_slice, 1) / n_elements(temperature_slice[*,t])) &$
ENDFOR

!p.background = 255
!p.color = 0

tvim, temperature_time, xtitle='Pseudo height, photosphere -> chromosphere', ytitle='time step ( 0 => 70th time step)'

; This creates a plot of the temperature as a function of optical depth where time is represented by
; the changing line colour.
; The position of the line peak is the height of the temperature fluctuation.

loadct, 0, /silent
plot, depthscale, temperature_time[*,0], xst=1, thick=2, xtitle='Log(tau), left = chromosphere, right=photosphere'
loadct, 5, /silent
FOR i = 1, 15 DO oplot, depthscale,  temperature_time[*, i], thick=2, color=18*i

; This is the same plot as above except that the x-axis has been cut down, removing part of
; the photosphere           
plot, depthscale[40:*], temperature_time[40:*,0], xst=1, yst=1, thick=2, yr=[3500, 5000] ,xtitle='Log(tau), left = chromosphere, right=photosphere', ytitle='~temperature'
FOR i = 1, 15 DO oplot, depthscale[40:*], temperature_time[40:*, i], thick=2, color=17*i

; this is still hard to see clearly: separate the lines

plot, depthscale[40:*], temperature_time[40:*,0], xst=1, yst=1, thick=2, yr=[3500, 20000] ,xtitle='Log(tau), left = chromosphere, right=photosphere', ytitle='~temperature'
FOR i = 1, 15 DO oplot, depthscale[40:*], temperature_time[40:*, i]+(1000*i), thick=2, color=17*i
                                                                                                                                                          
; Returning to the image of the temperature, filtering it more
tvim, ALOG10(temperature_time),/sc

tvim, ALOG10(temperature_time),/sc,range=[3.55,3.75]
                               
; Averaging over only the first 3 pixels of the LB:
temperature_time3 = fltarr(75,16)
FOR i = 0,15 DO BEGIN &$     ;origin_276                                                                   
    temperature_slice = TAU_AND_X_AGAINST_TIME_284[206:208, *, i+70] &$                         
    temperature_time3[*,i] = REFORM(TOTAL(temperature_slice, 1) / 3.) &$                         
ENDFOR                                                                

plot, depthscale[40:*], temperature_time3[40:*,0], xst=1, yst=1, thick=2, yr=[3500, 15000]      
FOR i = 1, 15 DO oplot, depthscale[40:*],temperature_time3[40:*, i]+(500*i), thick=2, color=17*i

; image as is and then rotated to make it easier to understand
tvim, ALOG10(temperature_time3),/sc,range=[3.55,3.75]                                                    
tvim, ROTATE(ALOG10(temperature_time3),5),/sc,range=[3.55,3.75]
; This last rotation shows clearly the heat entering at the top of the atmosphere and then 
; subsequently sinking into the lower atmosphere over the following frames. This cut in 
; particular has 3 separate examples of this. The next step is to explore doopler velocities 
; for the same area.

; create a similar map for dopper shift - a grid, that can be compared directly to the temperature map
; basically i need a LOS map for y=276, x=206-208 (averaged) from tiem steps 70-85. Hopefully at the 
; time steps where the flow appears to be down, into the atmosphere will be same time steps as the 
; red flow down in tvim, ROTATE(ALOG10(temperature_time3),5),/sc,range=[3.55,3.75].

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
los_vel_lb = fltarr(3)
los_vel_avg = fltarr(111)
FOR k = 0, 109 DO BEGIN &$ 
	print, k &$
	cube = readfits(data[k]) &$
	los_vel_avg[k] = TOTAL(los_vel_lb)/n_elements(los_vel_lb) &$
	FOR i=463, 465 DO BEGIN &$
		pixel = cube[i,286,*] &$ ; originally 276
		pixel_profile = TOTAL(TOTAL(pixel,2),1) &$
		pixel_fit = GAUSSFIT(wave, pixel_profile, pixel_coeff, ESTIMATES =[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005]) &$
		mean_pixel_fit = pixel_coeff[1] &$
		d_lambda = mean_pixel_fit - 8542.01694 &$
		x_val = i - 463 &$
		dv = (d_lambda/8542.01694)*3.e5 &$
		if (dv gt 10) then (dv = 10) &$
		if (dv lt -10) then (dv = -10) &$
		los_vel_lb[x_val] = dv &$
ENDFOR

plot, los_vel_avg
plot, los_vel_avg[70:85], xtitle='time step, starting at 70', ytitle='Doppler velocity, km/s'

; ##################################################################################################
;	 Temperature map as above but for the event frame 90 on
; ###################################################################################################
RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/uncorrected_first_analysis.sav'
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'

temperature_time_90 = FLTARR(75, 16)
left_of_lb = 206
right_of_lb = 209
FOR t = 0,15 DO BEGIN &$ 		; originally _276
    temperature_slice = TAU_AND_X_AGAINST_TIME_284[left_of_lb:right_of_lb, *, t+90] &$
    temperature_time_90[*,t] = REFORM(TOTAL(temperature_slice, 1) / n_elements(temperature_slice[*,t])) &$
ENDFOR

!p.background = 255
!p.color = 0

tvim, temperature_time_90, xtitle='Pseudo height, photosphere -> chromosphere', ytitle='time step ( 0 => 70th time step)'



;#####################################################################################################
; Creating a figure comparing the Doppler velocity to the temperature - 77 event
;#####################################################################################################
cutdown_temp3 = temperature_time3[50:*, *]
log_temp_time3 = ALOG10(cutdown_temp3)
log_temp_time3 = ROTATE(log_temp_time3, 5)
tvim, log_temp_time3, xtitle='Atmosphere, left = toward chromosphere, right = toward photosphere', ytitle='Time Step'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/los_lb.eps'
!p.background = 255
!p.color = 0
plot, los_vel_avg[70:85], xtitle='time step, starting at 70', ytitle='Doppler velocity, km/s'
device, /close

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/log_temp_time3.eps', /color
loadct, 3
!p.background = 255
!p.color = 0
tvim, log_temp_time3, /sc, xtitle='Pseudo optical height', ytitle='time'
device, /close
set_plot, 'x'


set_plot, 'ps'
device, filename='/home/40147775/msci/figs/temp_with_los.eps', /color
loadct, 3
!p.background = 255
!p.color = 0
tvim, rotate(log_temp_time3,3), xtitle='Time Step', ytitle='Pseudo optical height', /sc
loadct, 2
oplot, findgen(16), (los_vel_avg[70:85]*7)+8, thick=2
loadct, 3
;axis, yaxis=1, YTITLE='LOS Vel',ystyle=1,YRANGE = (!Y.CRANGE)/12
device, /close
set_plot, 'x'

;#####################################################################################################
; Creating a figure comparing the Doppler velocity to the temperature - 90 event
;#####################################################################################################
cutdown_temp_90 = temperature_time_90[50:*, *]
log_temp_time_90 = ALOG10(cutdown_temp_90)
log_temp_time_90 = ROTATE(log_temp_time_90, 5)
tvim, log_temp_time_90, xtitle='Atmosphere, left = toward chromosphere, right = toward photosphere', ytitle='Time Step'


set_plot, 'ps'
device, filename='/home/40147775/msci/figs/temp_with_los_frame_90.eps', /color
loadct, 3
!p.background = 255
!p.color = 0
tvim, rotate(log_temp_time_90,3), xtitle='Time Step', ytitle='Pseudo optical height', /sc
loadct, 20
oplot, findgen(16), (los_vel_avg[90:105]*7)+8, thick=2
loadct, 3
;axis, yaxis=1, YTITLE='LOS Vel',ystyle=1,YRANGE = (!Y.CRANGE)/12
device, /close
set_plot, 'x'


; ###########################################################################################################
; 	Concise temperature of Lb with LOS vel
; ###########################################################################################################
; calculate los_avg_vel first
start_time = 70
temperature_time = FLTARR(75, 16)
left_of_lb = 206
right_of_lb = 209
FOR t = 0,15 DO BEGIN &$ 		; originally _276
    temperature_slice = TAU_AND_X_AGAINST_TIME_284[left_of_lb:right_of_lb, *, t+start_time] &$
    temperature_time[*,t] = REFORM(TOTAL(temperature_slice, 1) / n_elements(temperature_slice[*,t])) &$
ENDFOR

cutdown_temp = temperature_time[50:*, *]
log_temp_time = ALOG10(cutdown_temp)
log_temp_time = ROTATE(log_temp_time_90, 5)

loadct, 3
!p.background = 255
!p.color = 0
tvim, rotate(log_temp_time,3), xtitle='Time Step', ytitle='Pseudo optical height', /sc
loadct, 20
oplot, findgen(16), (los_vel_avg[start_time:start_time + 15]*7)+8, thick=2


; #######################################################################################################
; Conversion of optical depth to height
; #######################################################################################################
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/mackkl_m.sav', /verbose

density_m = mackkl_m.nhtot * 1.67E-27 * (100.)^3.
temp_m = mackkl_m.t
field_m  = SQRT(8. * !pi * mackkl_m.ptot)
height_m = mackkl_m.h
optical_depth_m = mackkl_m.tau5

th_fit = POLY_FIT(height_m,temp_m ,10)

; testing the fit
g = findgen(2249)
h = g - 122

fit_h_t = fltarr(8900)
FOR i=0,2248 DO BEGIN &$
	fit_h_t[i] = th_fit[0] + th_fit[1]*h[i] + th_fit[2]*h[i]^2 + th_fit[3]*h[i]^3 + th_fit[4]*h[i]^4 + th_fit[5]*h[i]^5 + th_fit[6]*h[i]^6 + th_fit[7]*h[i]^7 + th_fit[8]*h[i]^8 + th_fit[9]*h[i]^9 + th_fit[10]*h[i]^10  &$
ENDFOR

plot, h, fit_h_t ; plotting the fitted height against the temperature
oplot, height_m, temp_m, color='120' ; overplotting the actual function in red
; This serves as a good fit below ~1800km 

; Finding a fit for height as a function of the log of optical depth:
log_optical_depth_m = ALOG10(optical_depth_m)
oh_fit = POLY_FIT(log_optical_depth_m, height_m, 25)
; testing the fit
g = findgen(1140, increment=0.01)
h = g - 10
fit_od_h = fltarr(1140)
fit_od_h_i = fltarr(51)

FOR i=0,1139 DO BEGIN &$
	fit_od_h[i] = TOTAL(fit_od_h_i) &$
	FOR j=0, 25 DO BEGIN &$
	fit_od_h_i[j] = oh_fit[j] * h[i]^j  &$
ENDFOR
plot, log_optical_depth_m, height_m
oplot, h, fit_od_h, color='120'
; This fit is far from perfect, it completely breaks at very low values of log_optical_depth_m. 
; However it is sufficient for my purposes since it is an acceptable fit down to log(tau) = -6
; which is the lowest value in the data set.


; saving out the fitted variables
SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/conversions.sav', fit_h_t, fit_od_h, oh_fit, th_fit

; ######################################################################################################
; 	Turning the conversions into routines
; ######################################################################################################

; This function is a bit long and has numerical values where instead they could be called from
; a sav file however this means the code can later be used by anyone, even without the sav file.
; Alternatively the files are saved in conversions.sav

FUNCTION OD_TO_HEIGHT, x
	coeff = [7.1475964, -114.84059, -59.765961, 56.392883, 103.45804, $
      		 -17.811371, -56.965546, -13.085274, 7.4847431, 4.1276894, $
                 0.62685931, -0.010470539, -0.0097609535, -0.00038388267, 5.8086371e-06,$
                 -7.4927193e-06, -5.0584674e-07, 1.5012848e-08, 6.6001649e-10, -1.4498822e-10,$
                 -7.4073955e-11, -6.6161486e-12, -1.1637715e-13, 4.3538225e-14, 2.6420194e-15,$
                 -1.9521756e-16]
		partial_sum = fltarr(26)
	FOR j=0, 25 DO BEGIN &$
		partial_sum[j] = fit_coeff[j] * (optical_depth)^j &$

	RETURN, height
END
; This ^ doesn't work yet - I'll have another go when I've some more important things done.


; #########################################################################################################
; 			Interpolating until the fancy function works
; #########################################################################################################

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/mackkl_m.sav', /verbose

density_m = mackkl_m.nhtot * 1.67E-27 * (100.)^3.
temp_m = mackkl_m.t
field_m  = SQRT(8. * !pi * mackkl_m.ptot)
height_m = mackkl_m.h
optical_depth_m = mackkl_m.tau5

x_out = findgen(1140)
x_out = x_out/100
x_out = x_out - 10

od_h = interpol(height_m, ALOG10(optical_depth_m), x_out)

loadct, 5
!p.background=255
!p.color=0
plot, ALOG10(optical_depth_m), height_m, xtitle='Log of Optical Depth', ytitle='Height /Km', title= 'Log of Optical Depth against Height'
oplot, x_out, od_h, color = '120'

; so now od_h holds all the values of optical depth from -10 to 1.4, simply subset as necessary for
; plot etc

x_out2 = findgen(2249)
x_out2 = x_out2 - 122

tp_h = interpol(temp_m, height_m, x_out2)

plot, height_m, temp_m, xtitle='Height /Km', ytitle='Temperature /K', title= 'Temperature against Height'
oplot, x_out2, tp_h, color='120'

; So now optical depth can be replaced with a height.


; #######################################################################################################
;		Cubes - one for the interaction(70), one for the lesser interaction (90)
; #######################################################################################################

tau_and_x_event_70 = fltarr(551, 75, 110)
y_value = 286
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	tau_and_x_slice = TRANSPOSE(REFORM(temp[*,*,y_value])) &$
	tau_and_x_event_70[*,*,i] = tau_and_x_slice[*,*] &$
ENDFOR
loadct, 5
xstepper, ALOG10(tau_and_x_event_70), xsize=1900, ysize=500
tvim, ALOG10(tau_and_x_event_70[*,*,73]), /sc
loadct, 3
xstepper, ALOG10(tau_and_x_event_70)>3.55<3.75, xsize=1900, ysize=500

; watch from 73 for first shock, from 90 for second shock.
; It might be possible to make this even better with a 45 degree angle for the frame 90 event - 
; that ought to be more conclusive. The same coordinates should be fine.

; Trying for a 45 degree view of the frame 90 event.

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0090.sav' ; arbitary
angle_slice_tau_90 = fltarr(450, 75, 110)
line_of_slice_90 = REFORM(fit_model_temp[15,*,*])
offset = 83 									 ; should be fine
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	FOR f=0, 449 DO BEGIN &$
		pix_x = f &$
		pix_y = offset + f &$
		angle_slice_tau_90[f,*,i] = temp[*, pix_x, pix_y] &$
		line_of_slice_90[pix_x, pix_y] = 4000
ENDFOR

tvim, line_of_slice_90
xstepper, ALOG10(angle_slice_tau_90)>3.55<3.75, xsize=1900, ysize=500
lb_bold = angle_slice_tau_90
lb_bold[203, *, *] = 6000
xstepper, lb_bold, xsize=1900, ysize=500

; betwee these two one can see the movement of the event at frame 90 ish.

; #####################################################################################################
;				Upgrading the plots with useful axis
; #####################################################################################################
; 1 pixel = 0.097 arcsec, 1 arcsec = 725 km 
; => 1 pixel = 70.327km
; => data set spans 551*70.327 = 38750.1 km = 38.75 Mm

; values from conversions
tvim, ALOG10(tau_and_x_event_70[*,*,10])>3.55<3.75 , xtitle='Distance / Mm', xrange=[0,38.75], yrange=[-130, 1860], ytitle='Geometric Height / km'

tvim, angle_slice_tau_90[*,*,10] , xtitle='Distance / Mm', xrange=[0,31.6], yrange=[-130, 1860], ytitle='Geometric Height / km'
; #########################################################################################################
;			Saving out these files as pngs to be turned into videos later
; #########################################################################################################

; Start with the slice acorss x for fixed y:
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1900,ysize=500,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = tau_and_x_event_70[*,*,i] &$ 
	tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance / Mm', xrange=[0,38.75], yrange=[-130, 1860], ytitle='Geometric Height / km' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/tau_and_x_event_70/img'+ name + '.png', tvrd(/true) &$
ENDFOR							

; Now the 45 degree one
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1900,ysize=500,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = angle_slice_tau_90[*,*,i] &$ ;reduce the fov: angle_slice_event_90[110:339, *, i]
	tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance / Mm', xrange=[0,31.6], yrange=[-130, 1860], ytitle='Geometric Height / km' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/angle_slice_tau_90/img'+ name + '.png', tvrd(/true) &$
ENDFOR						; remve _cut for full fov
; #########################################################################################################
;		Saving out these files as pngs to be turned into videos later- CUT DOWN FOV	
; #########################################################################################################

; Start with the slice acorss x for fixed y:
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1900,ysize=500,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = tau_and_x_event_70[110:339,*,i] &$ ; reduce the fov: tau_and_x_event_70[110:339, *, i]
	tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance / Mm', xrange=[0,16.1], yrange=[-130, 1860], ytitle='Geometric Height / km', pcharsize=3, lcharsize=2, title = 'Horizontal slice through the solar atmosphere' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/tau_and_x_event_70_cut/img'+ name + '.png', tvrd(/true) &$
ENDFOR							; remove _cut for full fov

; Now the 45 degree one
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1900,ysize=500,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = angle_slice_tau_90[110:339,*,i] &$ 
	tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance (Mm)', xrange=[0,16.1], yrange=[-130, 1860], ytitle='Geometric Height (km)', pcharsize=3, lcharsize=2, title = 'Angle slice through the solar atmosphere' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/angle_slice_tau_90_cut/img'+ name + '.png', tvrd(/true) &$
ENDFOR						

; #######################################################################################################
; 				Above images to video	(ran in folder)	
; #######################################################################################################
; adaptable frame rate, no filling in:

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p event_70_90_lb_interaction_final.mp4

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p event_90_angle_lb_interaction_final.mp4

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p cut_fov_horizontal_slice.mp4

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p cut_fov_angle_slice.mp4
; #####################################################################################################
;		Looking at another collison event 41 - similariaties with 77?
; #####################################################################################################

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav' ; arbitary
angle_slice_tau_41 = fltarr(450, 75, 110)
line_of_slice_41 = REFORM(fit_model_temp[15,*,*])
offset = 83 									 ; should be fine
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	FOR f=0, 449 DO BEGIN &$
		pix_x = f &$
		pix_y = offset + f &$
		angle_slice_tau_41[f,*,i] = temp[*, pix_x, pix_y] &$
		line_of_slice_41[pix_x, pix_y] = 4000
ENDFOR

!p.background = 255
!p.color = 0
tvim, line_of_slice_41
xstepper, ALOG10(angle_slice_tau_41)>3.55<3.75, xsize=1900, ysize=500

; saving this out 
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1900,ysize=500,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 5, /silent &$
	frame = angle_slice_tau_41[*,*,i] &$
	tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance / Mm', xrange=[0,31.6], yrange=[-130, 1860], ytitle='Geometric Height / km' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/angle_slice_tau_41/img'+ name + '.png', tvrd(/true) &$
ENDFOR

; ran in folder on png's
ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p event_41_angle_lb_interaction_final.mp4
; video produced

; #################################################################################################
; 					Presentation specific plots
; ###############################################################################################
;Intensity plots of the sunspot
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
cube = readfits(data[30])
frame = cube[*,*,5] 
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_photosphere.eps'
!p.background = 255
!p.color = 0
loadct, 3, /silent
;aia_lct, r, g, b, wavelnth=’171’, /load
tvim, frame[*,*], xtitle='Distance / Mm', xrange=[0,70], yrange=[0, 70], ytitle='Distance / Mm', title='Intensity Plot of the Solar Photosphere', pcharsize=2, lcharsize=3
device, /close
set_plot, 'x'

, xtitle='Distance / Mm', xrange=[0,70], yrange=[0, 70], ytitle='Distance / Mm',pcharsize=10, lcharsize=15



data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
cube = readfits(data[30])
frame = cube[*,*,15] 
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_chromosphere.eps'
!p.background = 255
!p.color = 0
loadct, 3, /silent
;aia_lct, r, g, b, wavelnth=’171’, /load
tvim,frame, xtitle='Distance / Mm', xrange=[0,70], yrange=[0, 70], ytitle='Distance / Mm',pcharsize=10, lcharsize=15
device, /close
set_plot, 'x'


; Temperature plots (having ran above)
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav'
temp = fit_model_temp
frame = temp[5,*,*]
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_temperature_photosphere.eps'
!p.background = 255
!p.color = 0
loadct, 3, /silent
;aia_lct, r, g, b, wavelnth=’171’, /load
tvim,frame, xtitle='Distance / Mm', xrange=[0,40], yrange=[0, 40], ytitle='Distance / Mm',pcharsize=10, lcharsize=15, title='Sunspot Temperature in the Photosphere'
device, /close
set_plot, 'x'

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav'
temp = fit_model_temp
frame = temp[60,*,*]
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_temperature_chromosphere.eps'
!p.background = 255
!p.color = 0
loadct, 3, /silent
;aia_lct, r, g, b, wavelnth=’171’, /load
tvim,frame, xtitle='Distance / Mm', xrange=[0,40], yrange=[0, 40], ytitle='Distance / Mm',pcharsize=10, lcharsize=15, title='Sunspot Temperature in the Chromosphere'
device, /close
set_plot, 'x'

; Spectra example
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
cube = readfits(data[30])
subcube = cube[500:505, 850:855, *]
spectra = total(total(subcube,2),1)/36
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/spectra_example_2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, wave, spectra, xtitle='Wavelength / !3' + STRING(197B) + '!X', ytitle = 'Intensity', position=[0.2,0.2,0.8,0.8], thick=3, CHARTHICK=2, charsize=2, font=-1, title='Spectra Example for the Quiet Sun', xticks = 4
device, /close
set_plot, 'x'


; Shock propagation
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav'
xsteppper, marked_sub_scan, xsize=700, ysize=700
; frames 14,18,20 left umbra
tvim, marked_sub_scan[*,*,14]
; x ordinate from 297 to 397, y from 484 to 584
tvim, sub_scans_300[301:401,484:584,14]
; Take 4 images, frame 14,16,18,20:

frame = sub_scans_300[301:401,484:584,20]
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/shock_frame_20.eps'
!p.background = 255
!p.color = 0
loadct, 0, /silent
tvim,frame, xtitle='Distance / Mm', xrange=[0,7], yrange=[0, 7], ytitle='Distance / Mm',pcharsize=2, lcharsize=2, title='Shock Propagation'
device, /close
set_plot, 'x'

; example x against tau in temperature
loadct, 3
frame = tau_and_x_event_70[*,*,73]
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/presentation_figs/temperature_inversion.eps'
!p.background = 255
!p.color = 0
loadct, 3, /silent
tvim, frame, xtitle='Distance / Mm', xrange=[0,40], yrange=[-130, 1860], ytitle='Height / km', title='Temperature Inversion Example',pcharsize=1, lcharsize=1
device, /close
set_plot, 'x'

window,0,xsize=1900,ysize=500,/pixmap 
!p.background = 255 
!p.color = 0 
loadct, 3, /silent 
frame = angle_slice_tau_41[*,*,i] 
tvim, ALOG10(frame)>3.55<3.75, xtitle='Distance / Mm', xrange=[0,40], yrange=[-130, 1860], ytitle='Geometric Height / km' 
write_png, '/home/40147775/msci/figs/presentation_figs/please_work.png', tvrd(/true) 

; ##########################################################################################################
; converting to png
; #########################################################################################################

convert sunspot_chromosphere.eps sunspot_chromosphere.png
convert sunspot_photosphere.eps sunspot_photosphere.png
convert spectra_example.eps spectra_example.png
convert sunspot_temperature_chromosphere.eps sunspot_temperature_chromosphere.png
convert sunspot_temperature_photosphere.eps sunspot_temperature_photosphere.png
convert shock_frame_14.eps shock_frame_14.png
convert shock_frame_16.eps shock_frame_16.png
convert shock_frame_18.eps shock_frame_18.png
convert shock_frame_20.eps shock_frame_20.png


; Intensity plots for the presentation take 2
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
cube = readfits(data[30])
image = cube[*,*,5] ; 5 for photosphere, 15 for chromosphere
image_map = MAKE_MAP(image, xc=35.15, yc=35.15, dx=0.0703 , dy=0.0703 ); dx=100, dy=100, 
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_photosphere_take_2.eps', /encapsulated, xsize=24, ysize=24, /tt_font, set_font='Times', font_size=16, /color, bits_per_pixel=8
!p.background = 255
!p.color = 0
loadct, 3, /silent
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Intensity of the Solar Photosphere', xtickinterval=10, ytickinterval=10, position=[0.2,0.2,0.8,0.8]
device, /close
set_plot, 'x'

; Temperature plots for presentation take 2
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav'
temp = fit_model_temp
image = temp[5,*,*] ; 5 for photosphere, 70 for chromosphere
image = reform(image)
image_map = make_map(image, dx =0.0703 , dy=0.0703 , xc =19.4 - (0.5*0.0703), yc =19.4 - (0.5*0.0703))
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/sunspot_photosphere_temp_2.eps', /encapsulated, xsize=24, ysize=24, /tt_font, set_font='Times', font_size=14, /color, bits_per_pixel=8
!p.background = 255
!p.color = 0
loadct, 5, /silent
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Temperature of the Solar Photosphere', xtickinterval=10, ytickinterval=10, position=[0.2,0.2,0.8,0.8]
device, /close
set_plot, 'x'


; Converting to high quality png:
convert -density 300 sunspot_chromosphere_take_2.eps -resize 1024x1024 sunspot_chromosphere_take_2.png
; then replace the transparent background with white:
convert - flatten image.png, image.png


; rms scan saved out as pngs to turn into a video
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav', /verbose
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1000,ysize=1000,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = sub_scans_300[*,*,i] &$
	tvim, frame, xtitle='Distance / Mm', xrange=[0,70], ytitle='Distance / Mm', yrange=[0,70] &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/rms_scan/img'+ name + '.png', tvrd(/true) &$
ENDFOR

ffmpeg -framerate 15 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p rms_scan.mp4

; zoomed in rms sub scan
FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1000,ysize=1000,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = sub_scans_300[200:750,260:810,i] &$
	tvim, frame, xtitle='Distance / Mm', xrange=[0,40], ytitle='Distance / Mm', yrange=[0,40] &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/rms_scan_zoom/img'+ name + '.png', tvrd(/true) &$
ENDFOR

ffmpeg -framerate 4 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p rms_scan_zoom.mp4

; time cube 15 for video conversion:

FOR i=0, 109 DO BEGIN &$
	window,0,xsize=1000,ysize=1000,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = time_cube_15[*,*,i] &$
	tvim, frame &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/figs/time_cube/img'+ name + '.png', tvrd(/true) &$
ENDFOR

ffmpeg -framerate 15 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p time_cube.mp4


; ###########################################################################################################
; 		Exploring Coorrelations and trends in the data.
; ###########################################################################################################
; Data/quantaties that I have:
; - doppler velocity
; - intensity (luminosity due to fuction called intensity)
; - temperature
; I need transverse velocity - at least for the 3 shocks

; #######################################################################################################
;		Start by comparing doppler velocity to luminosity for a given time
; #######################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

time = 41
cube = readfits(data[41])
; start by comparing average intensity:
; intensity at x,y is 
luminosity = total(cube, 3)/n_elements(reform(cube[1,1,*]))

quiet_profile_means = fltarr(408)
FOR i=0, 407 DO BEGIN &$
	print, i &$
	cube_i = readfits(data[i], /silent) &$	
	quiet_square = cube_i[350:650, 730:900, *] &$
	profile_of_quiet_sun = total(total(quiet_square,2),1)/ 51471 &$
	fit_of_quiet_sun = GAUSSFIT(wave, profile_of_quiet_sun, quiet_coeff, NTERMS = 6) &$
	quiet_profile_means[i] = quiet_coeff[1] &$
ENDFOR

; remove bad data and replace with mean of good data
mean_good_data = mean(quiet_profile_means[0:307], /double) ; double makes a BIG difference
quiet_profile_means[308:349] = mean_good_data
mean(quiet_profile_means[0:307], /double)
stddev(quiet_profile_means[0:307], /double)
plot, quiet_profile_means, yrange=[8541.9,8542.1] ; quick check
quiet_sun_line_core = mean(quiet_profile_means[0:307], /double)
; quiet_sun_line_core is the rest wavelength of the quiet sun = 8542.016

delta_lambda=fltarr(551,551)
FOR i=200, 750 DO BEGIN &$
	print, i &$
	FOR j=260, 810 DO BEGIN &$
		examination_area = cube[i, j, *] &$ 
		examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) &$
		examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
		pixel_line_core = examination_area_coeff[1] &$
		delta_lambda[i-200,j-260] = pixel_line_core - 8542.016 &$
ENDFOR

doppler_velocity = (delta_lambda/8542.016)*3.e5 ; km/s
tvim, doppler_velocity, /sc, range=[-5,5]
tvim, luminosity[200:750, 260:810], /sc

lum = luminosity[200:750, 260:810, *]
lum = reform(lum, 303601)
dv = reform(doppler_velocity, 303601)
FOR i=0, n_elements(dv)-1 DO BEGIN &$
	IF dv[i] GT 5 THEN dv[i] = 5 &$
	IF dv[i] LT (-5) THEN dv[i] = (-5) &$
ENDFOR

; save out varibles to plot in python
SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/doppler_vel_and_luminosity.sav', dv, lum


; #######################################################################################################
;			  Temperature and doppler velocity for a given time
; #######################################################################################################
; temperature can easily be extracted from the inversion scans.
; Doppler velocity as above.

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0077.sav'
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
time = 77
cube = readfits(data[time])
temp = fit_model_temp

; find the average temperature across the height of the atmosphere:
temp_avg = total(temp, 1)/n_elements(reform(temp[*,1,1]))

; doppler velocity
delta_lambda=fltarr(551,551)
FOR i=200, 750 DO BEGIN &$
	print, i &$
	FOR j=260, 810 DO BEGIN &$
		examination_area = cube[i, j, *] &$ 
		examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) &$
		examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
		pixel_line_core = examination_area_coeff[1] &$
		delta_lambda[i-200,j-260] = pixel_line_core - 8542.016 &$
ENDFOR

doppler_velocity = (delta_lambda/8542.016)*3.e5 ; km/s
; still has some massive values



