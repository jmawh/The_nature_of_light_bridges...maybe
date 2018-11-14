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

 
temp = fit_model_temp
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


RESTORE, 'inversion_burst_0078.sav'
x_and_y_over_tau = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau[*,*,i] = frame[*,*] &$
ENDFOR

xstepper, x_and_y_over_tau, xsize=700, ysize=700

; #####################################################################################################
; 			Time frame 96 - is there a temperature change?
; ####################################################################################################

RESTORE, 'inversion_burst_0096.sav'
x_and_y_over_tau96 = fltarr(551,551,75)
FOR i=0, 74 DO BEGIN &$
	frame = reform(fit_model_temp[i,*,*]) &$
	x_and_y_over_tau96[*,*,i] = frame[*,*] &$
ENDFOR


