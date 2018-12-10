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
y2 = 0.45
y3 = 0.55
y4 = 0.9

set_plot, 'ps'
device, filename='/home/40147775/msci/figs/report_figs/X_event_7_multiplot.eps'
!p.background = 255 
!p.color = 0 
loadct, 0, /silent
mult, 2,2
tvim, frame_1, position=[x1,y3,x2,y4], xrange
tvim, frame_2, position=[x3,y3,x4,y4]
tvim, frame_3, position=[x1,y1,x2,y2]
tvim, frame_4, position=[x3,y1,x4,y2]
device, /close
set_plot, 'x'