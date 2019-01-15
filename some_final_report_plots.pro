; ####################################################################################################
; 				Plots for final report (some of)
; ####################################################################################################

; Sunspot, umbral flashes, light bridges and example temperature inversions are already taken care
; of courtesy of the presentation

; IV temperature inversions - photosphere
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav'
temp = fit_model_temp
image = temp[5,*,*] ; 5 for photosphere, 70 for chromosphere
image = reform(image)
image_map = make_map(image, dx =0.0703 , dy=0.0703 , xc =19.4 - (0.5*0.0703), yc =19.4 - (0.5*0.0703))
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IV_sunspot_photosphere_temp_2.eps', /encapsulated, xsize=24, ysize=24, /tt_font, set_font='Times', font_size=14, /color, bits_per_pixel=8
!p.background = 255
!p.color = 0
loadct, 5, /silent
x1 = 0.2
y1 = 0.2
x2 = 0.8
y2 = 0.8
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Temperature of the Solar Photosphere', xtickinterval=10, ytickinterval=10, position=[0.2,0.2,0.8,0.8]
colorbar, bottom=0, ncolors=255, charsize=1.5, charthick=2, color=0, divisions=2,minrange=7250, maxrange=8950, position=[x2+0.015,y1,x2+0.03,y2], /vertical, /right,ticknames=tickmarknames, title=’Intensity (arb. units)’, font=-1
device, /close
set_plot, 'x'


; IV temperature inversions - chromosphere
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0001.sav'
temp = fit_model_temp
image = temp[70,*,*] ; 5 for photosphere, 70 for chromosphere
image = reform(image)
image_map = make_map(image, dx =0.0703 , dy=0.0703 , xc =19.4 - (0.5*0.0703), yc =19.4 - (0.5*0.0703))
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IV_sunspot_chromosphere_temp_2.eps', /encapsulated, xsize=24, ysize=24, /tt_font, set_font='Times', font_size=14, /color, bits_per_pixel=8
!p.background = 255
!p.color = 0
loadct, 5, /silent
x1 = 0.2
y1 = 0.2
x2 = 0.8
y2 = 0.8
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Temperature of the Solar Chromosphere', xtickinterval=10, ytickinterval=10, position=[0.2,0.2,0.8,0.8]
colorbar, bottom=0, ncolors=255, charsize=1.5, charthick=2, color=0, divisions=2,minrange=2200, maxrange=5150, position=[x2+0.015,y1,x2+0.03,y2], /vertical, /right,ticknames=tickmarknames, title=’Intensity (arb. units)’, font=-1
device, /close
set_plot, 'x'


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

hist_100 = HISTOGRAM(sub_scan_100, NBINS = 100)
hist_300 = HISTOGRAM(sub_scan_300, NBINS = 100)
hist_500 = HISTOGRAM(sub_scan_500, NBINS = 100)

hist_100_x = findgen(n_elements(hist_100)) + min(sub_scan_100)
hist_300_x = findgen(n_elements(hist_300)) + min(sub_scan_300)
hist_500_x = findgen(n_elements(hist_500)) + min(sub_scan_500)

step_100 = (max(sub_scan_100) - min(sub_scan_100))/n_elements(hist_100)
step_300 = (max(sub_scan_300) - min(sub_scan_300))/n_elements(hist_300)
step_500 = (max(sub_scan_500) - min(sub_scan_500))/n_elements(hist_500)
new_x_100 = (min(sub_scan_100) + findgen(n_elements(hist_100))*step_100) + 30 ; to center
new_x_300 = (min(sub_scan_300) + findgen(n_elements(hist_300))*step_300) + 20 ; to center
new_x_500 = (min(sub_scan_500) + findgen(n_elements(hist_500))*step_500) + 42 ; to center

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_100_sec_rms_scan2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, new_x_100, hist_100, yrange=[0, 250000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 100 Second RMS', charsize=1.5, thick=2
device, /close
set_plot, 'x'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_300_sec_rms_scan2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, new_x_300, hist_300, yrange=[0, 250000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 300 Second RMS', charsize=1.5, thick=2
device, /close
set_plot, 'x'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/VI_500_sec_rms_scan2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, new_x_500, hist_500, yrange=[0, 250000000], xrange=[-500,500], ytitle='Frequency Density', xtitle='Intensity', title='Intensity Distribution for 500 Second RMS', charsize=1.5, thick=2 
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
device, filename='/home/40147775/msci/figs/report_figs/VII_doppler_vel_of_quiet_sun_corrected2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, qs_dv, yrange=[-0.5, 0.5], ytitle='Doppler Velocity (km/s)', xtitle='Time(s)', title='Doppler Velocity of the Quiet Sun', charsize=1.5, thick=2, xrange=[0,400]
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
image_map1 = make_map(corr_slice, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IX_temp_corrected_example.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
plot_map, image_map1, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Applying Umbral Correction', xtickinterval=5, ytickinterval=2
device, /close
set_plot, 'x'

image_map2 = make_map(atm_slice, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IXb_un_temp_corrected_example.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
plot_map, image_map2, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Without Correction', xtickinterval=5, ytickinterval=2
device, /close
set_plot, 'x'

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/IX_event_77_temperature_corr_mult.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
mult, 1,2
plot_map, image_map2, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Without Correction', xtickinterval=5, ytickinterval=2, position = [0.1,0.55, 0.9, 0.9]
plot_map, image_map1, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='With Umbral Correction', xtickinterval=5, ytickinterval=2, position = [0.1,0.1,0.9, 0.35]
device, /close
set_plot, 'x'

; X 4 plot of event 77
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'

frame_1 = sub_scans_300[300:450,470:620,72]
frame_2 = sub_scans_300[300:450,470:620,76]
frame_3 = sub_scans_300[300:450,470:620,79]
frame_4 = sub_scans_300[300:450,470:620,82]

frame_1 = BYTSCL(frame_1, min = (-300), max = 760)
frame_2 = BYTSCL(frame_2, min = (-300), max = 760)
frame_3 = BYTSCL(frame_3, min = (-300), max = 760)
frame_4 = BYTSCL(frame_4, min = (-300), max = 760)

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
device, filename='/home/40147775/msci/figs/report_figs/X_event_77_multiplot_colour.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
mult, 1,1
plot_map, map_1, position=[x1,y3,x2,y4], /noerase, title='Frame 72', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_2, position=[x3,y3,x4,y4], /noerase, title='Frame 76', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_3, position=[x1,y1,x2,y2], /noerase, title='Frame 79', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_4, position=[x3,y1,x4,y2], /noerase, title='Frame 82', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
device, /close
set_plot, 'x'



; XI 4 plot of event 90
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/rms_scans.sav'

frame_1 = sub_scans_300[300:450,470:620,90]
frame_2 = sub_scans_300[300:450,470:620,95]
frame_3 = sub_scans_300[300:450,470:620,99]
frame_4 = sub_scans_300[300:450,470:620,101]

frame_1 = BYTSCL(frame_1, min = (-300), max = 760)
frame_2 = BYTSCL(frame_2, min = (-300), max = 760)
frame_3 = BYTSCL(frame_3, min = (-300), max = 760)
frame_4 = BYTSCL(frame_4, min = (-300), max = 760)

x1 = 0.1
x2 = 0.45
x3 = 0.55
x4 = 0.9
y1 = 0.1 
y2 = 0.42
y3 = 0.58
y4 = 0.9

; creating image maps for each image
map_1 = make_map(frame_1, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_2 = make_map(frame_2, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_3 = make_map(frame_3, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)
map_4 = make_map(frame_4, xc=5.25 - (0.5*0.0703), yc=5.25 - (0.5*0.0703), dx=0.0703, dy = 0.0703)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/X_event_90_multiplot_colour.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
mult, 1,1
plot_map, map_1, position=[x1,y3,x2,y4], /noerase, title='Frame 90', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_2, position=[x3,y3,x4,y4], /noerase, title='Frame 95', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_3, position=[x1,y1,x2,y2], /noerase, title='Frame 99', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
plot_map, map_4, position=[x3,y1,x4,y2], /noerase, title='Frame 101', xtitle='Distance (Mm)', ytitle='Distance (Mm)'
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
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
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
	cube = readfits(data[i], silent) &$
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
; uncertainty in maximum dv in region of interest: Take the avergae of the three (max = either side)
; and display average +- stddev of all three:
dvs = [3.944, 4.459, 4.081]
dv_max = mean(dvs)
err = stddev(dvs)
; = 4.16 +- 0.27 km/s
; same for the time after the interaction, 80 - 85
rest = doppler_velocity[60:70]
mean_dv = mean(rest)
err_rest = stddev(rest)
; 1.88 +- 0.43

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
restore, '/home/40147775/msci/inversion_data/14Jul_Inv/nlte_temp_correction_all.sav'
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


; Shock propagation velocity
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav', /verbose
xstepper, sub_scans_300[*,*,0:300], xsize=700, ysize=700
; 1) 50, 54, right umbra
; 2) 72, 77, top part
; 3) 90, 95, top part
; 4) 115, 119, right umbra
; 5) 147, 152, left umbra
; 6) 188, 195, right umbra, moving down
; 7) 240, 245, left umbra
; 8) 273, 278, right umbra, big front
; using tvim, sub_scans_300[*,*,i]

; Format x1, y1, x2, y2, frames_elapsed) -> e1
e1 = [487, 480, 497, 466, 4]
e2 = [382, 541, 382, 557, 5]
e3 = [387, 541, 376, 555, 5]
e4 = [491, 493, 478, 464, 4]
e5 = [356, 522, 347, 549, 5]
e6 = [475, 527, 470, 485, 7]
e7 = [372, 528, 378, 551, 5]
e8 = [491, 489, 474, 472, 5]

; making prop, a 2D array of the above info
prop = fltarr(5, 8)
prop[*,0] = e1
prop[*,1] = e2
prop[*,2] = e3
prop[*,3] = e4
prop[*,4] = e5
prop[*,5] = e6
prop[*,6] = e7
prop[*,7] = e8

prop_pixels = fltarr(8)
prop_time = [4,5,5,4,5,7,5,5] * 9.4
FOR i=0, 7 DO BEGIN &$
	; hyp = sqrt((x2-x1)^2 + (y2-y1)^2)
	prop_pixels[i] = SQRT(abs(prop[2,i] - prop[0, i])^2 + abs(prop[3,i] - prop[1, i])^2) &$
ENDFOR
	
prop_dist = prop_pixels*70.3
prop_speed = prop_dist/prop_time
; prop speed in km/s

SAVE, filename='/home/40147775/msci/inversion_data/my_sav_files/propagation_speed.sav', prop_speed


; XX mult plot of temp for event 70
RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/temp_slice_all_events.sav', /verbose
loadct, 5

form_77 = ALOG10(tau_and_x_event_70[*,*,73])>3.55<3.75
heat_77 = ALOG10(tau_and_x_event_70[*,*,76])>3.55<3.75
form_77[150:151, 0:5  ] = 3.55
form_77[150:151, 10:15] = 3.55
form_77[150:151, 20:25] = 3.55
form_77[150:151, 30:35] = 3.75
form_77[150:151, 40:45] = 3.75
form_77[150:151, 50:55] = 3.75
form_77[150:151, 60:65] = 3.75
form_77[150:151, 70:74] = 3.75

form_77[250:251, 0:5  ] = 3.55
form_77[250:251, 10:15] = 3.55
form_77[250:251, 20:25] = 3.55
form_77[250:251, 30:35] = 3.75
form_77[250:251, 40:45] = 3.75
form_77[250:251, 50:55] = 3.75
form_77[250:251, 60:65] = 3.75
form_77[250:251, 70:74] = 3.75

heat_77[150:151, 0:5  ] = 3.55
heat_77[150:151, 10:15] = 3.55
heat_77[150:151, 20:25] = 3.55
heat_77[150:151, 30:35] = 3.75
heat_77[150:151, 40:45] = 3.75
heat_77[150:151, 50:55] = 3.75
heat_77[150:151, 60:65] = 3.75
heat_77[150:151, 70:74] = 3.75

heat_77[250:251, 0:5  ] = 3.55
heat_77[250:251, 10:15] = 3.55
heat_77[250:251, 20:25] = 3.55
heat_77[250:251, 30:35] = 3.75
heat_77[250:251, 40:45] = 3.75
heat_77[250:251, 50:55] = 3.75
heat_77[250:251, 60:65] = 3.75
heat_77[250:251, 70:74] = 3.75

formation = make_map(form_77, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
heating = make_map(heat_77, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XX_event_70_temp_mult2.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
mult, 1,2
plot_map, formation, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Formation of Shock Frame 73', xtickinterval=5, ytickinterval=2, position = [0.1,0.6, 0.9, 0.9]
plot_map, heating, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Interaction with LB Frame 76', xtickinterval=5, ytickinterval=2, position = [0.1,0.1,0.9, 0.4]
device, /close
set_plot, 'x'

; XXI mult plot of temp for event 90
RESTORE, '/home/40147775/msci/inversion_data/my_sav_files/temp_slice_all_events.sav', /verbose
loadct, 5

form_90 = ALOG10(angle_slice_tau_90[*,*,89])>3.55<3.75
heat_90 = ALOG10(angle_slice_tau_90[*,*,93])>3.55<3.75

; adding vertical lines to highlight ROI
form_90[150:151, 0:5  ] = 3.55
form_90[150:151, 10:15] = 3.55
form_90[150:151, 20:25] = 3.55
form_90[150:151, 30:35] = 3.75
form_90[150:151, 40:45] = 3.75
form_90[150:151, 50:55] = 3.75
form_90[150:151, 60:65] = 3.75
form_90[150:151, 70:74] = 3.75

form_90[250:251, 0:5  ] = 3.55
form_90[250:251, 10:15] = 3.55
form_90[250:251, 20:25] = 3.55
form_90[250:251, 30:35] = 3.75
form_90[250:251, 40:45] = 3.75
form_90[250:251, 50:55] = 3.75
form_90[250:251, 60:65] = 3.75
form_90[250:251, 70:74] = 3.75

heat_90[150:151, 0:5  ] = 3.55
heat_90[150:151, 10:15] = 3.55
heat_90[150:151, 20:25] = 3.55
heat_90[150:151, 30:35] = 3.75
heat_90[150:151, 40:45] = 3.75
heat_90[150:151, 50:55] = 3.75
heat_90[150:151, 60:65] = 3.75
heat_90[150:151, 70:74] = 3.75

heat_90[250:251, 0:5  ] = 3.55
heat_90[250:251, 10:15] = 3.55
heat_90[250:251, 20:25] = 3.55
heat_90[250:251, 30:35] = 3.75
heat_90[250:251, 40:45] = 3.75
heat_90[250:251, 50:55] = 3.75
heat_90[250:251, 60:65] = 3.75
heat_90[250:251, 70:74] = 3.75

formation = make_map(form_90, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)
heating = make_map(heat_90, xc = 17-0.5*0.0703, yc = 2.3, dx= 0.0703, dy =0.1)

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XXI_event_90_temp_mult2.eps', /color
!p.background = 255 
!p.color = 0 
loadct, 5, /silent
mult, 1,2
plot_map, formation, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Formation of Shock Frame 89', xtickinterval=5, ytickinterval=2, position = [0.1,0.6, 0.9, 0.9]
plot_map, heating, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=1, charthick=1.5, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Log(Optical Depth)' , title='Interaction with LB Frame 93', xtickinterval=5, ytickinterval=2, position = [0.1,0.1,0.9, 0.4]
device, /close
set_plot, 'x'

; XXII example spectra in quiet Sun
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
cube = readfits(data[30])
subcube = cube[500:502, 800:802, *]
spectra = total(total(subcube,2),1)/9
spectra = SMOOTH(spectra, 3)
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XXII_con_spectra.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, wave, spectra, xtitle='Wavelength / !3' + STRING(197B) + '!X', ytitle = 'Intensity', position=[0.2,0.2,0.8,0.8], thick=3, CHARTHICK=2, charsize=2, font=-1, title='Spectra Example for the Quiet Sun', xticks = 4, yrange=[1000,2800]
device, /close
set_plot, 'x'

; XXII example spectra with discontinuties
data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
cube = readfits(data[75])
subcube = cube[361:363, 474:476, *]
spectra = total(total(subcube,2),1)/9
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XXII_discon_spectra2.eps'
loadct, 0, /silent
!p.background = 255 
!p.color = 0 
plot, wave, spectra, xtitle='Wavelength / !3' + STRING(197B) + '!X', ytitle = 'Intensity', position=[0.2,0.2,0.8,0.8], thick=3, CHARTHICK=2, charsize=2, font=-1, title='Spectra of Shock Formation', xticks = 4, yrange= [600,1200]
device, /close
set_plot, 'x'

;XXIII Maltby values plot comparing polyfit to interpol

; start with the interpol
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/mackkl_m.sav', /verbose
height_m = mackkl_m.h
optical_depth_m = mackkl_m.tau5
log_optical_depth_m = ALOG10(optical_depth_m)

; grid values for interpol
x_out = findgen(1140)
x_out = x_out/100
x_out = x_out - 10
; od_h is the interpol y values (values of height)
od_h = interpol(height_m, ALOG10(optical_depth_m), x_out)

; polyfit version
oh_fit = POLY_FIT(log_optical_depth_m, height_m, 25)
g = findgen(1140, increment=0.01)
od_values = g - 10
fit_od_h = fltarr(1140)
fit_od_h_i = fltarr(51)

FOR i=0,1139 DO BEGIN &$
	fit_od_h[i] = TOTAL(fit_od_h_i) &$
	FOR j=0, 25 DO BEGIN &$
	fit_od_h_i[j] = oh_fit[j] * h[i]^j  &$
ENDFOR
; fit_od_h is the polyfitted version
; plotting

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XXIII_maltby_comparison.eps'
loadct, 5
!p.color = 0
!p.background = 255
plot, log_optical_depth_m, height_m, psym =4, xtitle=' log(!7s!3)', ytitle = 'Height (km)', position=[0.2,0.2,0.8,0.8], thick=3, CHARTHICK=2, charsize=2, font=-1, title='Plot of Optical Depth against Height' ; original data 
oplot, od_values, fit_od_h, color='120', thick = 2
oplot, x_out, od_h, color = '60', thick = 2
device, /close
set_plot, 'x'


;XXIV location of temp slices 77 and 90
; these are variables tau_and_x_event_70 (y = 286 for all x)
; and angle_slice_tau_90 (y = x+83)
; restore an inversion burst and modify:
RESTORE, '/home/40147775/msci/inversion_data/14Jul_Inv/inversion_burst_0090.sav'
temp_cube = fit_model_temp
photo_img = reform(temp_cube[1, *, *])
photo_img[*, 285:287] = 7500
FOR i=0, 450 DO photo_img[i:i+2, i+83:i+84] = 7500 &$

image_map = make_map(photo_img, dx =0.0703 , dy=0.0703 , xc =19.4 - (0.5*0.0703), yc =19.4 - (0.5*0.0703))
set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/XXIV_slice_locations.eps', /encapsulated, xsize=24, ysize=24, /tt_font, set_font='Times', font_size=14, /color, bits_per_pixel=8
!p.background = 255
!p.color = 0
loadct, 5, /silent
plot_map, image_map, ycharsize=1, xcharsize=1, xthick=2, ythick=2, charsize=2, charthick=2, xticklen=-.025, yticklen=-.025, xtitle='Distance (Mm)', ytitle='Distance (Mm)' , title='Location of Atmosphere Slices', xtickinterval=10, ytickinterval=10, position=[0.2,0.2,0.8,0.8]
device, /close
set_plot, 'x'


