; ####################################################################################################
; 				Plots for final report (some of)
; ####################################################################################################

; Sunspot, umbral flashes, light bridges and example temperature inversions are already taken care
; of courtesy of the presentation, starting at V in the to_do_... list:

; V Distribtuions of original intensity at line core.
; use time cube 15, 0 - 300 frames
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav', /verbose
line_core = time_cube_15[*,*,0:300]
; reform into a single array - a big one
line_core = reform(line_core, n_elements(line_core))

hist_original_data = HISTOGRAM(line_core)
 
; saving out the plot
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/V_dist_of_original_intensity.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, hist_original_data, yrange=[0,500000], ytitle='Frequency Density', xtitle = 'Intensity', position=[0.2,0.2,0.8,0.8], thick=2,charthick=2, charsize=1.5, font=-1, title='Intensity Distribution of Original Data'
device, /close
set_plot, 'x'


; VI Distributions of RMS intensity
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'
sub_scans_100 = sub_scans_100[*,*,0:300]
sub_scans_300 = sub_scans_300[*,*,0:300]
sub_scans_500 = sub_scans_500[*,*,0:300]

sub_scan_100 = reform(sub_scans_100, n_elements(sub_scans_100))
sub_scan_300 = reform(sub_scans_300, n_elements(sub_scans_300))
sub_scan_500 = reform(sub_scans_500, n_elements(sub_scans_500))

hist_100 = HISTOGRAM(sub_scan_100)
hist_300 = HISTOGRAM(sub_scan_300)
hist_500 = HISTOGRAM(sub_scan_500)

hist_100_x = findgen(n_elements(hist_100)) + min(sub_scan_100)
hist_300_x = findgen(n_elements(hist_300)) + min(sub_scan_300)
hist_500_x = findgen(n_elements(hist_500)) + min(sub_scan_500)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_100_sec_rms_scan.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, hist_100_x, hist_100, yrange=[0, 6000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 100 Second RMS', charsize=1.5, thick=2
device, /close
set_plot, 'x'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_300_sec_rms_scan.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, hist_300_x, hist_300, yrange=[0, 6000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 300 Second RMS', charsize=1.5, thick=2
device, /close
set_plot, 'x'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_500_sec_rms_scan.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, hist_500_x, hist_500, yrange=[0, 6000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 500 Second RMS', charsize=1.5, thick=2 
device, /close
set_plot, 'x'

; VII DV of quiet sun before and after correcting bad data.
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
quiet_profile_means = fltarr(408)
FOR i=0, 407 DO BEGIN &$
	print, i &$
	cube_i = readfits(data[i], /silent) &$	
	quiet_square = cube_i[350:650, 730:900, *] &$
	profile_of_quiet_sun = total(total(quiet_square,2),1)/ 51471 &$
	fit_of_quiet_sun = GAUSSFIT(wave, profile_of_quiet_sun, quiet_coeff, NTERMS = 6) &$
	quiet_profile_means[i] = quiet_coeff[1] &$
ENDFOR

mean_good_data = mean(quiet_profile_means[0:307], /double) ; double makes a BIG difference
quiet_profile_means[308:349] = mean_good_data
mean(quiet_profile_means[0:307], /double)
stddev(quiet_profile_means[0:307], /double)
plot, quiet_profile_means, yrange=[8541.9,8542.1] ; quick check
quiet_sun_line_core = mean(quiet_profile_means[0:307], /double)
qs_dv = (quiet_profile_means - quiet_sun_line_core)/quiet_sun_line_core*300000

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VII_doppler_vel_of_quiet_sun_corrected.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, qs_dv, yrange=[-0.5, 0.5], ytitle='Doppler Velocity', xtitle='Time Step', title='Doppler Velocity of the Quiet Sun', charsize=1.5, thick=2 
device, /close
set_plot, 'x'

; VIII Location of quiet sun investigation
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
cube = readfits(data[10])
quiet_frame = reform(cube[*,*,1])
quiet_frame[349:351, 730:900] = 0
quiet_frame[649:651, 730:900] = 0
quiet_frame[350:650, 729:731] = 0
quiet_frame[350:650, 899:901] = 0


image_map = MAKE_MAP(quiet_frame, xc=35.15, yc=35.15, dx=0.0703 , dy=0.0703 )
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VIII_quiet_sun_area.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Quiet Sun Investigation Area', xtickinterval=10, ytickinterval=10, position=[0.25,0.2,0.75,0.8]
device, /close
set_plot, 'x'


; IX: Temperature corrections to the data
restore, '/home/40147775/msci/inversion_data/my_sav_files/uncorrected_first_analysis.sav'
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0041.sav'
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'

corr_slice = fltarr(551,75)
atm_slice = REFORM(tau_and_x_against_time_276[*,*,10])
FOR i=0, 74 DO BEGIN &$	
	corr_slice[*,i] = atm_slice[*,i] * umb_corr[i] &$
ENDFOR
loadct, 5
image_map = make_map(corr_slice, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IX_temp_corrected_example.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Applying Umbral Correction', xtickinterval=5, ytickinterval=2
device, /close
set_plot, 'x'

image_map = make_map(atm_slice, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IXb_un_temp_corrected_example.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Applying Umbral Correction', xtickinterval=5, ytickinterval=2
device, /close
set_plot, 'x'

; X 4 plot of event 77
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'

frame_1 = sub_scans_300[300:450,470:620,72]
frame_2 = sub_scans_300[300:450,470:620,76]
frame_3 = sub_scans_300[300:450,470:620,79]
frame_4 = sub_scans_300[300:450,470:620,83]

x1 = 0.1
x2 = 0.45
x3 = 0.55
x4 = 0.9
y1 = 0.1 
y2 = 0.42
y3 = 0.58
y4 = 0.9

; creatng image maps for each image
map_1 = make_map(frame_1, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_2 = make_map(frame_2, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_3 = make_map(frame_3, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_4 = make_map(frame_4, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/X_event_77_multiplot.eps'
!p.background = 255 
!p.color = 0 
loadct, 0, /silent
mult, 1,1
plot_map, map_1, position=[x1,y3,x2,y4], /noerase, title='Frame 72', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_2, position=[x3,y3,x4,y4], /noerase, title='Frame 76', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_3, position=[x1,y1,x2,y2], /noerase, title='Frame 79', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_4, position=[x3,y1,x4,y2], /noerase, title='Frame 83', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
device, /close
set_plot, 'x'



; XI 4 plot of event 90
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'

frame_1 = sub_scans_300[300:450,470:620,90]
frame_2 = sub_scans_300[300:450,470:620,95]
frame_3 = sub_scans_300[300:450,470:620,99]
frame_4 = sub_scans_300[300:450,470:620,102]

x1 = 0.1
x2 = 0.45
x3 = 0.55
x4 = 0.9
y1 = 0.1 
y2 = 0.42
y3 = 0.58
y4 = 0.9

; creatng image maps for each image
map_1 = make_map(frame_1, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_2 = make_map(frame_2, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_3 = make_map(frame_3, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_4 = make_map(frame_4, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/X_event_90_multiplot.eps'
!p.background = 255 
!p.color = 0 
loadct, 0, /silent
mult, 1,1
plot_map, map_1, position=[x1,y3,x2,y4], /noerase, title='Frame 90', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_2, position=[x3,y3,x4,y4], /noerase, title='Frame 95', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_3, position=[x1,y1,x2,y2], /noerase, title='Frame 88', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_4, position=[x3,y1,x4,y2], /noerase, title='Frame 102', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
device, /close
set_plot, 'x'


; XII 4 plot of event 156
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'

frame_1 = sub_scans_300[300:450,470:620,156]
frame_2 = sub_scans_300[300:450,470:620,158]
frame_3 = sub_scans_300[300:450,470:620,160]
frame_4 = sub_scans_300[300:450,470:620,164]

x1 = 0.1
x2 = 0.45
x3 = 0.55
x4 = 0.9
y1 = 0.1 
y2 = 0.42
y3 = 0.58
y4 = 0.9

; creatng image maps for each image
map_1 = make_map(frame_1, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_2 = make_map(frame_2, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_3 = make_map(frame_3, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_4 = make_map(frame_4, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/X_event_156_multiplot.eps'
!p.background = 255 
!p.color = 0 
loadct, 0, /silent
mult, 1,1
plot_map, map_1, position=[x1,y3,x2,y4], /noerase, title='Frame 156', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_2, position=[x3,y3,x4,y4], /noerase, title='Frame 158', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_3, position=[x1,y1,x2,y2], /noerase, title='Frame 160', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_4, position=[x3,y1,x4,y2], /noerase, title='Frame 164', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
device, /close
set_plot, 'x'

; XIII/XIV Temperature at formation with errors

RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/temp_slice_all_events.sav', /verbose

; uncertainty in temp taken as plus minus one step in x ordinate, one step in height and one step in time.
form_temp_41 = reform(angle_slice_tau_90[182:184, 62:64, 32:34], 27)
form_temp_77 = reform(tau_and_x_event_70[175:177,63:65,72:74], 27)
form_temp_90 = reform(angle_slice_tau_90[184:186, 62:64, 89:91], 27)

mean_form_41 = MEAN(form_temp_41)
mean_form_77 = MEAN(form_temp_77)
mean_form_90 = MEAN(form_temp_90)

error_form_41 = STDDEV(form_temp_41)
error_form_77 = STDDEV(form_temp_77)
error_form_90 = STDDEV(form_temp_90)

temp_form = [mean_form_41, mean_form_77, mean_form_90]
temp_form_error = [error_form_41, error_form_77, error_form_90]

lb_temp_41 = reform(angle_slice_tau_90[206:208, 71:73, 77:79], 27)
lb_temp_77 = reform(tau_and_x_event_70[207:209, 71:73, 77:79], 27)
lb_temp_90 = reform(angle_slice_tau_90[207:209, 71:73, 98:100], 27)

mean_lb_41 = MEAN(lb_temp_41)
mean_lb_77 = MEAN(lb_temp_77)
mean_lb_90 = MEAN(lb_temp_90)

error_lb_41 = STDDEV(lb_temp_41)
error_lb_77 = STDDEV(lb_temp_77)
error_lb_90 = STDDEV(lb_temp_90)

temp_lb = [mean_lb_41, mean_lb_77, mean_lb_90]
temp_error_lb = [error_lb_41, error_lb_77, error_lb_90]

SAVE, FILENAME='/home/40147775/msci/inversion_data/my_sav_files/XIII_data_temp_and_error.sav', temp_form, temp_form_error, temp_lb, temp_error_lb
; exported to python for making a graph


; XV - already have

; XVI temp-time-dv plot for event 77

RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/temp_slice_all_events.sav', /verbose
temperature_time = fltarr(75,16)
FOR i = 0,15 DO BEGIN &$                                                                        
temperature_slice = tau_and_x_event_70[209:211, *, i+70] &$                         
temperature_time[*,i] = REFORM(TOTAL(temperature_slice, 1) / 3.) &$                         
ENDFOR   
; only take the top of the atmosphere, where the interaction happens.
cutdown_temp = temperature_time[50:*, *]
log_temp_time = ALOG10(cutdown_temp)
log_temp_time = ROTATE(log_temp_time, 1)
;tvim, log_temp_time;
new_llt = fltarr(16,25)
FOR i =0, 15 DO new_llt[i, *] = log_temp_time[15-i, *]
	
delta_lambda=fltarr(110)
mean_examined_area = fltarr(110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[407:409, 453:455, *] &$ 
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - 8542.012 &$
ENDFOR
; location of the light bridge isn't as it appears in the data, it has been rotated 
; before being put into the inversion. So 286 in the inversion scans == 286 + 260 = 546 reflected in the 
; centre of the x coordinates: 500-546+500 = 454
doppler_velocity = (delta_lambda/8542.012)*3.e5 ; km/s

map_for_event_77 = make_map(new_llt, xc = 77, yc =4.8 - (0.5*0.1), dx = 1, dy = 0.1 )
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XVI_temp_time_dv_event_77.eps', /color
!p.background = 255
!p.color = 0
loadct, 3, /silent
plot_map, map_for_event_77, position=[0.25,0.2,0.75,0.80],ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1.5, charthick=1.5, xticklen=-.015, yticklen=-.015, xtitle='Time Step', ytitle='Log(Optical Depth)' , title='Behaviour of Heat at LB', xtickinterval=5, ytickinterval=0.5
AXIS, YAXIS=1, YRANGE = (!Y.CRANGE*2-6), YSTYLE = 1, YTITLE = 'Doppler Velocity (km/s)', charsize=1.5
oplot, findgen(n_elements(doppler_velocity[70:85]))+70, doppler_velocity[70:85]/1.8+2.8
device, /close
set_plot, 'x'

; XVII temp-time-dv plot for event 90

RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/temp_slice_all_events.sav', /verbose
temperature_time = fltarr(75,16)
FOR i = 0,15 DO BEGIN &$                                                                        
temperature_slice = angle_slice_tau_90[209:211, *, i+70] &$                         
temperature_time[*,i] = REFORM(TOTAL(temperature_slice, 1) / 3.) &$                         
ENDFOR   
; only take the top of the atmosphere, where the interaction happens.
cutdown_temp = temperature_time[50:*, *]
log_temp_time = ALOG10(cutdown_temp)
log_temp_time = ROTATE(log_temp_time, 1)
;tvim, log_temp_time;
new_llt = fltarr(16,25)
FOR i =0, 15 DO new_llt[i, *] = log_temp_time[15-i, *]
	
delta_lambda=fltarr(110)
mean_examined_area = fltarr(110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[407:409, 453:455, *] &$ 
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - 8542.012 &$
ENDFOR
; location of the light bridge isn't as it appears in the data, it has been rotated 
; before being put into the inversion. So 286 in the inversion scans == 286 + 260 = 546 reflected in the 
; centre of the x coordinates: 500-546+500 = 454
doppler_velocity = (delta_lambda/8542.012)*3.e5 ; km/s

map_for_event_90 = make_map(new_llt, xc = 97, yc =4.8 - (0.5*0.1), dx = 1, dy = 0.1 )


plot_map, map_for_event_90, position=[0.25,0.2,0.75,0.80],ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1.5, charthick=1.5, xticklen=-.015, yticklen=-.015, xtitle='Time Step', ytitle='Log(Optical Depth)' , title='Behaviour of Heat at LB', xtickinterval=5, ytickinterval=0.5
AXIS, YAXIS=1, YRANGE = (!Y.CRANGE*2-6), YSTYLE = 1, YTITLE = 'Doppler Velocity (km/s)', charsize=1.5
oplot, findgen(n_elements(doppler_velocity[90:105]))+90, doppler_velocity[90:105]/1.8+2.8

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XVII_temp_time_dv_event_90.eps', /color
!p.background = 255
!p.color = 0
loadct, 3, /silent
plot_map, map_for_event_90, position=[0.25,0.2,0.75,0.80],ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1.5, charthick=1.5, xticklen=-.015, yticklen=-.015, xtitle='Time Step', ytitle='Log(Optical Depth)' , title='Behaviour of Heat at LB', xtickinterval=5, ytickinterval=0.5
AXIS, YAXIS=1, YRANGE = (!Y.CRANGE*2-6), YSTYLE = 1, YTITLE = 'Doppler Velocity (km/s)', charsize=1.5
loadct, 0, /silent
oplot, findgen(n_elements(doppler_velocity[90:105]))+90, doppler_velocity[90:105]/1.8+2.8
device, /close
set_plot, 'x'

;XVIII doppler velocity at the light bridge
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
; as above
delta_lambda=fltarr(110)
mean_examined_area = fltarr(110)
FOR i=0, 109 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[407:409, 453:455, *] &$ 
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - 8542.012 &$
ENDFOR
doppler_velocity = (delta_lambda/8542.012)*3.e5 ; km/s

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XVIII_doppler_vel_at_lb.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, findgen(110), doppler_velocity, xtitle='Time Step', ytitle = 'Doppler Velocity (km/s)', position=[0.2,0.2,0.8,0.8], thick=3, CHARTHICK=2, charsize=1.5, font=-1, title='Doppler Velocity at the Light Bridge', xticks = 6
device, /close
set_plot, 'x'

