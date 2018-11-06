; ####################################################################################################
; Work with the inverted data
; ####################################################################################################

RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav', /VERBOSE
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



SAVE, FILENAME='/home/40147775/msci/data/common_vars.sav', time_cube_15, sub_scans_300, marked_sub_scan




write_png, '/home/40147775/msci/my_code/contour_rect_msk_300_50_100/img'+ name + '.png', tvrd(/true) &$


; ###########################################################################################
; 	atmos against x axis as y varies - to be finished
; ###########################################################################################

sweep_over_y = fltarr()
FOR i=0, 20 DO BEGIN &$
	print, i &$
	IF (i le 9) THEN RESTORE, 'inversion_burst_000'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 9) AND (i le 99) THEN RESTORE, 'inversion_burst_00'+ arr2str(i, /trim) + '.sav' &$
        IF (i gt 99) THEN RESTORE, 'inversion_burst_0'+ arr2str(i, /trim) + '.sav' &$
	temp = fit_model_temp &$
	
ENDFOR
