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
; file path to folder containing only the 0-39 th files - this only fixes the fit_model_temp files
; '/home/40147775/msci/inversion_data/zero_to_39_full_scans/inversion_burst_0000.sav'

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
y_value = 284
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
; frame 72,y=276 on is interesting - heat develops, propagates, collides, moves down to some extent?
; frame 39, y=284 just above the LB looks pretty odd - maybe check y=281-287 1 by 1
 1 by 1
; ###########################################################################################
; 		 time evolution of x against y for a single optical depth
; ###########################################################################################

x_and_y_against_time = fltarr(551,551,110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	x_and_y_against_time[*,*,i] = fit_model_temp[60,*,*] &$
ENDFOR

xstepper, x_and_y_against_time, xsize=700, ysize=700

; investigations
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'
xstepper, TRANSPOSE(fit_model_temp), xsize=700, ysize=700
; this is shows the LB hotter than surroundings at about 60th optical depth step



	

