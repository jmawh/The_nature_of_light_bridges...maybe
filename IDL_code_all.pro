; ########################################################################################################
; This script currrently represents the entire code base. In time it will be split up into something
; more acceptable
; ########################################################################################################


; Getting the data. This returns an array of 408 objects, each with 47 images

data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
cube_1 = READFITS(data[1]) 
tvim, cube_1[*,*,1], /sc

xstepper, cube_1>50<3000, xsize = 500, ysize=500

; Alternatively we can select a particular wavelength and look at how the picture changes in time.

time_cube_15 = FLTARR(1000,1000,408)

FOR i=0, 407 DO BEGIN &$
    lambda_cube = READFITS(data[i], /silent)&$
    time_cube_15 [*,*,i] = lambda_cube[*,*,15] &$
ENDFOR
    
xstepper, time_cube_15, xsize=700, ysize=700
; OR
aia_lct, r, g, b, wavelnth='171', /load 
xstepper, ALOG(time_cube_15>0.1)>6<10, xsize=700, ysize=700

; This last iteration of the xstepper gives a clear picture of the shocks we will be investigating 
; with the yellowish color scheme.

; We can also display a single, 2 dimensional picture of a shock developing - 10th fits file, 16th 
; frame:

cube_9 = READFITS(data[9])
tvim, cube_9[*,*,15], /sc, pcharsize=2, xtitle='x - axis', ytitle = 'y - axis'

;Light curve plotting for x = 470, y = 472 in time_cube_15 (15th slice of every time step)
; plot image:

tvim, time_cube_15[*,*,0], /sc
pick
; pick allows the user to select a point on the open plot
cadence = 1.2
time = FINDGEN(408) * cadence

plot, time, REFORM(time_cube_15[470,472, *]) ; plus titles etc etc

; making figures to be saved out - cut down version from Davids notes
; for pre-created 2-D image 'image':

image_map = MAKE_MAP(image, dx=100, dy=100, xc=500, y)

set_plot, 'ps'
device, filename='/home/40147775/msci/mycode/image_name.eps'
plot_map, image_map



; 				Time Averaging of Pixels.

data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
time_cube_15 = FLTARR(1000,1000,408)

FOR i=0, 407 DO BEGIN &$
    lambda_cube = READFITS(data[i], /silent)&$
    time_cube_15 [*,*,i] = lambda_cube[*,*,15] &$
ENDFOR

mean_time_cube_15 = FLTARR(1000,1000,408)
mean_intensities = FLTARR(1000,1000)

FOR i = 0, 999 DO BEGIN &$
	FOR j=0, 999 DO BEGIN &$
		mean_intensities[i,j] = MEAN(time_cube_15[i,j,*]) &$
	ENDFOR 
ENDFOR 

FOR i = 0, 407 DO BEGIN &$
	mean_time_cube_15[*,*,i] = time_cube_15[*,*,i] - mean_intensities[*,*] &$
ENDFOR	

loadct, 0
xstepper, mean_time_cube_15, xsize=700, ysize=700


; 				OR Time average number two

data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
time_cube_15 = FLTARR(1000,1000,408)

FOR i=0, 407 DO BEGIN &$
    lambda_cube = READFITS(data[i], /silent)&$
    time_cube_15 [*,*,i] = lambda_cube[*,*,15] &$
ENDFOR

mean_time_cube_15 = FLTARR(1000,1000,408)
mn_intes = FLTARR(1000,1000)

FOR i = 0, 999 DO BEGIN &$
	FOR j = 0, 999 DO BEGIN &$
		mn_intes[i,j] = MEAN(REFORM(time_cube_15[i,j,*]))
ENDFOR

FOR i = 0, 407 DO BEGIN &$
	mean_time_cube_15[*,*,i] = time_cube_15[*,*,i] - mean_intensities[*,*] &$
ENDFOR	

loadct, 0
xstepper, mean_time_cube_15, xsize=700, ysize=700


; ###################################################################################################
; 				My Running Mean Subraction, using time_cube_15
; ###################################################################################################
 
rms_time_cube_15 = FLTARR(1000,1000,408)
last_25 = time_cube_15[*,*,382:407]
first_25 = time_cube_15[*,*,0:24]
last_25_rms = fltarr(1000,1000)
first_25_rms = fltarr(1000,1000)

FOR i = 0, 999 DO BEGIN &$
	FOR j = 0, 999 DO BEGIN &$
		last_25_rms[i,j] = MEAN(last_25[i,j,*]) &$
		first_25_rms[i,j] = MEAN(first_25[i,j,*]) &$
ENDFOR

FOR k = 25, 382 DO BEGIN &$
	print, k &$
	FOR i = 0, 999 DO BEGIN &$
		FOR j = 0, 999 DO BEGIN &$
			mini_cube_15 = time_cube_15[i,j, (k-10):(k+10)] &$
			rms_time_cube_15[i,j,k] = MEAN(mini_cube_15) &$
ENDFOR

; finding the total mean array:
FOR i=0, 24 DO BEGIN &$
	rms_time_cube_15[*,*,i] = first_25_rms[*,*] &$
	rms_time_cube_15[*,*,i+382] = last_25_rms[*,*] &$
ENDFOR

																																																																																																													final_rms_time_cube_15 = time_cube_15 - rms_time_cube_15
xstepper, final_rms_time_cube_15, xsize=700, ysize=700 

																																																																																																																																											
	
; ################################################################################################
; 		Running Mean Subtraction, Comparison of different averaging times. 
; ################################################################################################

data = file_search('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

cadence = 9.4                           ;Length of time per scan in seconds
length_100 = RND(100/cadence)
length_300 = RND(300/cadence)
length_500 = RND(500/cadence)	        ;Number of scans in 5 minute period (300s)
bound_100 = RND(length_100/2)-1 
bound_300 = RND(length_300/2)-1 
bound_500 = RND(length_500/2)-1         ;Split number of scans in that period into 2, 2.5 each side
val_100 = bound_100*2 + 1
val_300 = bound_300*2 + 1
val_500 = bound_500*2 + 1

n_scans = 408

x1 = 0
y1 = 0
x2 = 999
y2 = 999

x = (x2-x1)+1
y = (y2-y1)+1

;Edge images surronding line core

z1 = 15
z2 = 19

scans = fltarr(x, y, n_scans)
sub_scans_300 = fltarr(x, y, n_scans) 	; creating the 3D arrays to store the final result in
sub_scans_100 = fltarr(x, y, n_scans)
sub_scans_500 = fltarr(x, y, n_scans)
avg = fltarr(n_scans)
sum = fltarr(x,y)
average_im = fltarr(x,y)
average_im[*] = 0.

;This loop creates array of wavelength integrated images about the line core of Ca 8542Å
;Also produces an average of wavelength integrated image

FOR i=0, (n_scans - 1) DO BEGIN &$
    sum[*] = 0. &$
        z=readfits(data[i], /silent) &$
        cropped = z[x1:x2,y1:y2,z1:z2] &$
        sum = TOTAL(cropped,3) / (z2-z1+1) &$
        average_im = average_im + (rotate(sum, 7) / FLOAT(n_scans)) &$ ; rotate(sum, 7) is a 270 CCLW
        scans[*,*,i] = (rotate(sum, 7)) &$			       ; rotation
        print, i &$
ENDFOR


;			Perform running mean subtraction, 300s

FOR i=0, (n_scans - 1) DO BEGIN &$

    IF i lt bound_300 THEN sub_scans_300[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,0:(length_300-1)],3)/length_300) &$
    IF i gt (n_scans - bound_300-1) THEN sub_scans_300[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,(n_scans-length_300):  (n_scans-1)],3)/length_300) &$
    IF i gt (bound_300-1) AND i lt (n_scans - bound_300) THEN sub_scans_300[*,*,i] = scans[*, *,i]-(TOTAL(scans[*,*,(i-bound_300):(i+bound_300)],3)/val_300) &$
    print, i &$

ENDFOR

;			Perform running mean subtraction, 100s

FOR i=0, (n_scans - 1) DO BEGIN &$

    IF i lt bound_100 THEN sub_scans_100[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,0:(length_100-1)],3)/length_100) &$
    IF i gt (n_scans - bound_100-1) THEN sub_scans_100[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,(n_scans-length_100):  (n_scans-1)],3)/length_100) &$
    IF i gt (bound_100-1) AND i lt (n_scans - bound_100) THEN sub_scans_100[*,*,i] = scans[*, *,i]-(TOTAL(scans[*,*,(i-bound_100):(i+bound_100)],3)/val_100) &$
    print, i &$

ENDFOR

;			Perform running mean subtraction, 500s

FOR i=0, (n_scans - 1) DO BEGIN &$

    IF i lt bound_500 THEN sub_scans_500[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,0:(length_500-1)],3)/length_500) &$
    IF i gt (n_scans - bound_500-1) THEN sub_scans_500[*,*,i] = scans[*, *, i] - (TOTAL(scans[*,*,(n_scans-length_500):  (n_scans-1)],3)/length_500) &$
    IF i gt (bound_500-1) AND i lt (n_scans - bound_500) THEN sub_scans_500[*,*,i] = scans[*, *,i]-(TOTAL(scans[*,*,(i-bound_500):(i+bound_500)],3)/val_500) &$
    print, i &$

ENDFOR

xstepper, sub_scans_100, xsize=700, ysize=700
xstepper, sub_scans_300, xsize=700, ysize=700
xstepper, sub_scans_500, xsize=700, ysize=700


; 			Analysis of the different time averages

MINMAX(sub_scans_100)
MINMAX(sub_scans_300)
MINMAX(sub_scans_500)

MEAN(sub_scans_100)
MEAN(sub_scans_300)
MEAN(sub_scans_500)

STDDEV(sub_scans_100)
STDDEV(sub_scans_300)
STDDEV(sub_scans_500)

; 		  Plot histograms of the intensity for a given frame

frame_6_100 = sub_scans_100[*,*,6]
frame_6_300 = sub_scans_300[*,*,6]
frame_6_500 = sub_scans_500[*,*,6]

!p.background = 255
!p.color = 0

hist_100 = HISTOGRAM(frame_6_100)
hist_300 = HISTOGRAM(frame_6_300)
hist_500 = HISTOGRAM(frame_6_500)

; 				Creates histogram.eps file
set_plot, 'ps'
device, filename='/home/40147775/msci/my_code/histograms.eps', /encapsulated, xsize=24, ysize=24
plot, hist_100, title='Histogram of Intensities for 100s Average', ytitle='Frequency', xtitle='Pixel Value'
plot, hist_300, title='Histogram of Intensities for 300s Average', ytitle='Frequency', xtitle='Pixel Value'
plot, hist_500, title='Histogram of Intensities for 500s Average', ytitle='Frequency', xtitle='Pixel Value'
device, /close
set_plot, 'x'


; 			https://github.com/jmawh/The_nature_of_light_bridges...maybe.git	First contouring attempt
; 		   Skeleton code borrowed from Scott; well modified

sigma_100 = 40.9
sigma_300 = 80.0
sigma_500 = 90.6

FOR i=0, 407 DO BEGIN &$
	window,0,xsize=700,ysize=700,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = sub_scans_100[*,*,i] &$
	tvim, frame &$
	loadct, 39, /silent &$
	contour, frame, levels=[50,100], /over, color='red' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/my_code/contour_1/img'+ name + '.png', tvrd(/true) &$
ENDFOR

; #############################################################################################
; 				Making a mask,  Code adapted from David
;##############################################################################################			   	
average_image = fltarr(1000,1000)
FOR i =0, 99 DO average_image = average_image + READFITS(data[i], /SILENT, nslice=0)/100

tvim, average_image, /sc
level = 1400
contour, average_image, levels=[1400], /over
; 1000 gives the umbra but not the left LB,
; 
umb_mask = fltarr(1000,1000)
elements = where(average_image lt level)
umb_mask[elements] = 1
tvim, umb_mask, /sc

; ##################################################################################################
; 	   Doing an umbral mask and a a zoom of the umbra for contour video
; ##################################################################################################

; 		Masking just the umbra (run above code block first)
FOR i=0, 407 DO BEGIN &$
	window,0,xsize=700,ysize=700,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = sub_scans_300[*,*,i] * umb_mask &$
	tvim, frame &$
	loadct, 39, /silent &$
	contour, frame, levels=[50,100], /over, color='red' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/my_code/contour_umb_msk_300_50_100/img'+ name + '.png', tvrd(/true) &$
ENDFOR


; 		Masking a rectangle that completely surrounds the umbra 
rect_mask = fltarr(1000,1000)
rect_mask[287:638, 339:586] = 1

FOR i=0, 407 DO BEGIN &$
	window,0,xsize=700,ysize=700,/pixmap &$
	!p.background = 255 &$
	!p.color = 0 &$
	loadct, 0, /silent &$
	frame = sub_scans_300[*,*,i] * rect_mask &$
	tvim, frame &$
	loadct, 39, /silent &$
	contour, frame, levels=[50,100], /over, color='red' &$
	IF (i le 9) THEN name = '00' + arr2str(i, /trim) &$
        IF (i gt 9) AND (i le 99) THEN name = '0' + arr2str(i, /trim) &$
        IF (i gt 99) THEN name = arr2str(i, /trim) &$
	write_png, '/home/40147775/msci/my_code/contour_rect_msk_300_50_100/img'+ name + '.png', tvrd(/true) &$
ENDFOR

; ############################################################################################
; 		Examining the light curves of the light bridge, single pixel
;#############################################################################################			    

; LB coords: (418,477)

cadence = 1.2
time = FINDGEN(408) * cadence

plot, time, REFORM(time_cube_15[418,477, *]) ; plus titles etc etc

; Modified video - this replaces xstepper without the need to actually create the 3D array for it.
cube1 = readfits(data[1])
FOR i=0, 20 DO BEGIN &$
	tvim, cube1[*,*,i] &$
	wait, 0.5 &$
ENDFOR


; 		    Sub_scan_300 with LB marked as on surface (lambda 1)

marked_sub_scan = sub_scans_300

level = 1000

xcoord = [409,405,405,397,418,424,432,432,420,403]
xcoord = xcoord-500

ycoord = [470,497,455,430,432,457,476,505,509,511]
ycoord = ycoord-500

new_x = xcoord + 500
new_y = -ycoord +500

FOR i=0, 9 DO BEGIN &$
	marked_sub_scan[new_x[i], new_y[i],*] = level &$
ENDFOR

xstepper, marked_sub_scan, xsize=700, ysize=700

; ######################################################################################################
; 		Average light curve for 4 pixels of the light bridge
; ######################################################################################################

pixel1 = sub_scans_300[412,557,*]
pixel2 = sub_scans_300[414,545,*]
pixel3 = sub_scans_300[416,530,*]
pixel4 = sub_scans_300[416,510,*]

avg_pixel = (pixel1 + pixel2 + pixel3 + pixel4)/4

cadence = 1
time = FINDGEN(408) * cadence
plot, time, avg_pixel
plot, time, avg_pixel, yrange = [-200, 300]
plot, time[0:50], avg_pixel[0:50], yrange = [-200,200]
plot, time[80:110], avg_pixel[80:110], yrange = [-200,200]
plot, time[160:190], avg_pixel[160:190], yrange = [-200,200]
plot, time[270:290], avg_pixel[270:290]

; modifying the avg_pixel array to have a flat line for the bad data
mod_avg_pixel = avg_pixel
mod_avg_pixel[308:349] = 0

plot, time, mod_avg_pixel

; we can modify the marked sub_scan in the same way
mod_marked_sub_scan = marked_sub_scan
mod_marked_sub_scan[*,*, 308:349] = 0

xstepper, mod_marked_sub_scan, xsize=700, ysize=700

; ###################################################################################################
; 			Creating an line profile that can be plotted 
; ###################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
cube_42 = readfits(data(100))
quiet_sun_cube_42 = cube_42[350:650, 730:900, *]
avg_profile = TOTAL(TOTAL(quiet_sun_cube_42,2),1) / 51471 ; average value for the whole 2d image

;overplot a pixel square (3x3) - we get its line profile (and shift) relative to the quiet sun
pixel_grid = cube_42[403:405, 461:463, *]
avg_pixel_grid = TOTAL(TOTAL(pixel_grid, 2),1) / 9

; Now there is two lines, one considered at rest and the other may have a doppler shift
; this code determines the lambda shift by fitting a gaussian and then taking the mean.

smooth_avg_pixel_grid = SMOOTH(avg_pixel_grid, 3)
avg_profile_fit = GAUSSFIT(wave, avg_profile, coeff_avg, NTERMS=4)
area_profile_fit = GAUSSFIT(wave, avg_pixel_grid, coeff_grid, NTERMS=6)
plot, wave, avg_profile
oplot, wave, avg_profile_fit, color='90'

mean_avg_profile = coeff_avg[1]
mean_examined_area = coeff_grid[1]

lambda_shift = mean_examined_area - mean_avg_profile

doppler_vel = (lambda_shift/mean_avg_profile)*3.e5
doppler_vel

; total plot
plot, wave, avg_profile
oplot, wave, avg_profile_fit, color='90'
oplot, wave, smooth(avg_pixel_grid,3,/edge_truncate)
oplot, wave, area_profile_fit

; #####################################################################################################
; Creating an doppler velocity for all times, averaged, not instrument corrected, manually fixed
; #####################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')


cube_100 = readfits(data(100)) 	; arbitary choice
quiet_sun_square = cube_100[350:650, 730:900, *]
quiet_sun_profile = TOTAL(TOTAL(quiet_sun_square,2),1) / 51471 ; average value for the whole 2d image 62900
quiet_profile_fit = GAUSSFIT(wave, quiet_sun_profile, quiet_sun_coeff, NTERMS=6) ;orig = 4 - little diff
mean_avg_profile = quiet_sun_coeff[1]

;considering a 3x3 pixel area of examination
delta_lambda=fltarr(408)
mean_examined_area = fltarr(408)
FOR i=0, 407 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[403:405, 461:463, *] &$ ; original: cube[403:405, 461:463, *]
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, NTERMS=6)&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - mean_avg_profile &$
ENDFOR

; code to identify the problem areas:
delta_lambda[308:349] = 0 	;removing bad data
abs_delta_lambda = ABS(delta_lambda)
FOR i=0, 407 DO BEGIN &$
	IF (abs_delta_lambda[i] gt 0.2) THEN BEGIN &$
		print, i &$

END
; returns 0,10,43,45,47,60,61,77

cube_0 = readfits(data[0])
cube_10 = readfits(data[10])
cube_43 = readfits(data[43])
cube_45 = readfits(data[45])
cube_47 = readfits(data[47])
cube_60 = readfits(data[60])
cube_61 = readfits(data[61])
cube_77 = readfits(data[77])

plot, wave, TOTAL(TOTAL(cube_77[403:405, 461:463, *],2),1)/9

delta_lambda[0] = 8542.1088 - mean_avg_profile
delta_lambda[10] = 8542.0816 - mean_avg_profile
delta_lambda[43] = 8542.1292 - mean_avg_profile
delta_lambda[45] = 8542.0816 - mean_avg_profile
delta_lambda[47] = 8542.0442 - mean_avg_profile
delta_lambda[60] = 8542.1258 - mean_avg_profile
delta_lambda[61] = 8542.0816 - mean_avg_profile
delta_lambda[77] = 8542.1156 - mean_avg_profile

; plotting
dv_lb = (delta_lambda/mean_avg_profile)*3.e5 ; km/s
mean_1 = mean(dv_lb[0:308])
mean_2 = mean(dv_lb[350:407])
total_mean = (n_elements(dv_lb[0:308])*mean_1 + n_elements(dv_lb[350:407])*mean_2)/(n_elements(dv_lb[0:308])+n_elements(dv_lb[350:407]))
dv_lb[308:349] = total_mean; bad data area

plot, findgen(408), dv_lb, xtitle='Time step', ytitle='LOS Velocity, km/s'


; ####################################################################################################
; 		Creating an intensity profile for single wavelengths - basically not a thing
; ####################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

time_cube_15 = FLTARR(1000,1000,200) ; 200 to get a start, keeps filling memory
FOR i=0, 199 DO BEGIN &$
    lambda_cube = READFITS(data[i], /silent)&$
    time_cube_15 [*,*,i] = lambda_cube[*,*,15] &$
ENDFOR

quiet_sun_square = time_cube_15[350:650, 730:900, *]
quiet_sun_profile = TOTAL(TOTAL(quiet_sun_square,2),1) / 62900 ; average value for the whole 2d image

examination_area = time_cube_15[403:405, 461:463, *] 
examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) / 9 

plot, findgen(200), quiet_sun_profile
oplot, findgen(200), examination_area_profile, color = '90'

; Saving out some variables

SAVE, FILENAME='/home/40147775/msci/data/common_vars.sav', time_cube_15, sub_scans_300, marked_sub_scan

; #####################################################################################################
; 				Checking the quietness of the quiet sun
; #####################################################################################################

; we will assume that if the square of 51k+ pixels doesn't change significantly over time then any of 
; them shuld provide a good profile for the quiet Sun.
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

; remove bad data and replace with mean of good data
mean_good_data = mean(quiet_profile_means[0:307], /double) ; double makes a BIG difference
quiet_profile_means[308:349] = mean_good_data
mean(quiet_profile_means[0:307], /double)
stddev(quiet_profile_means[0:307], /double)
plot, quiet_profile_means, yrange=[8541.9,8542.1] ; quick check
quiet_sun_line_core = mean(quiet_profile_means[0:307], /double)

; #####################################################################################################
; 					LOS Plot, interesting results
; #####################################################################################################

RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

; LOS map capped at +- 10 km/s for 300th - 600th pixel square
cube_41 = readfits(data[100]) 
los_vel = fltarr(300,300) 
FOR i=300, 599 DO BEGIN &$
    FOR j=300, 599 DO BEGIN &$
	pixel = cube_41[i,j,*] &$
	pixel_profile = TOTAL(TOTAL(pixel,2),1) &$
	pixel_fit = GAUSSFIT(wave, pixel_profile, pixel_coeff,ESTIMATES =[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005]) &$
	mean_pixel_fit = pixel_coeff[1] &$
	d_lambda = mean_pixel_fit - quiet_sun_line_core &$
	k = i-300 &$
	l = j-300 &$
	dv = (d_lambda/quiet_sun_line_core)*3.e5 &$
	if (dv gt 10) then (dv = 10) &$
	if (dv lt -10) then (dv = -10) &$
	los_vel[k,l] = dv &$
	;plot, wave, pixel_profile &$
	;oplot, wave, pixel_fit &$
	;wait, 0.2
ENDFOR
tvim, los_vel[*,*], /sc

; 			For 20x20 grid over the light bridge over all time

los_vel_lb = fltarr(3,3)
FOR k = 0, 407 DO BEGIN &$ 
cube = readfits(data[k]) &$
tvim, los_vel_lb[*,*], /sc &$
FOR i=403, 405 DO BEGIN &$
    FOR j=463, 465 DO BEGIN &$
	pixel = cube[i,j,*] &$
	pixel_profile = TOTAL(TOTAL(pixel,2),1) &$
	pixel_fit = GAUSSFIT(wave, pixel_profile, pixel_coeff, ESTIMATES =[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005]) &$
	mean_pixel_fit = pixel_coeff[1] &$
	d_lambda = mean_pixel_fit - quiet_sun_line_core &$
	x = i-403 &$
	y = j-465 &$
	dv = (d_lambda/quiet_sun_line_core)*3.e5 &$
	if (dv gt 10) then (dv = 10) &$
	if (dv lt -10) then (dv = -10) &$
	los_vel_lb[x,y] = dv &$
ENDFOR

; ####################################################################################################
; 		Creating final line profile for all wavelengths, averaged, comparing doppler vel
; ####################################################################################################
 
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

; Taking the average profile from part of the quiet sun. Essentially we are assuming that
; the average of the quiet sun is the correct rest wavelength (and it doesn't change in time)

;cube_100 = readfits(data(100)) 	; arbitary choice
;quiet_sun_square = cube_100[350:650, 730:900, *]
;quiet_sun_profile = TOTAL(TOTAL(quiet_sun_square,2),1) / 51471 ; average value for the whole 2d image 62900
;quiet_profile_fit = GAUSSFIT(wave, quiet_sun_profile, quiet_sun_coeff, NTERMS=6) ;orig = 4 - little diff
;mean_avg_profile = quiet_sun_coeff[1]

;considering a 3x3 pixel area of examination
delta_lambda=fltarr(408)
mean_examined_area = fltarr(408)
FOR i=0, 407 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[403:405, 461:463, *] &$ ; original: cube[403:405, 461:463, *]
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - quiet_sun_line_core &$
ENDFOR

doppler_velocity = (delta_lambda/quiet_sun_line_core)*3.e5 ; km/s
doppler_velocity[308:349] = mean(doppler_velocity[0:307]) ; bad data area

plot, findgen(408), doppler_velocity, xtitle='Time', ytitle='LOS Velocity, km/s'

; ####################################################################################################
; 		Creating final line profile for all wavelengths, averaged corrected for instrument
; ####################################################################################################
 
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/wavelengths_original.sav'
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/prefilter.8542.reference.profile.Apr2015.sav'	;, /verbose
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')

prefilter_response = PREFILT8542_REF_MAIN
prefilter_wavelengths = PREFILT8542_REF_WVSCL
quiet_sun_wavelength = 8542.12	; mean_avg_profile = 8542.0156, using true value instead
interpol_filter_response = INTERPOL(prefilter_response, prefilter_wavelengths + quiet_sun_wavelength, wave)

;cube_100 = readfits(data(100)) 	; arbitary choice
;quiet_sun_square = cube_100[350:650, 730:900, *]
;quiet_sun_profile = TOTAL(TOTAL(quiet_sun_square,2),1) / 51471 ; average value for the whole 2d image 62900
;quiet_sun_profile = quiet_sun_profile/interpol_filter_response
;quiet_profile_fit = GAUSSFIT(wave, quiet_sun_profile, quiet_sun_coeff, NTERMS=6) ;orig = 4 - little diff
mean_avg_profile = quiet_sun_line_core	;(run quietness code), used to be quiet_sun_coeff[1]

;considering a 3x3 pixel area of examination
delta_lambda=fltarr(408)
mean_examined_area = fltarr(408)
FOR i=0, 407 DO BEGIN &$
	print, i &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[403:405, 461:463, *] &$ ; original: cube[403:405, 461:463, *]
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_profile = examination_area_profile/interpol_filter_response &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	mean_examined_area[i] = examination_area_coeff[1] &$
	delta_lambda[i] = mean_examined_area[i] - mean_avg_profile &$
ENDFOR

dv_corrected = (delta_lambda/mean_avg_profile)*3.e5 ; km/s
mean_1 = mean(dv_corrected[0:308])
mean_2 = mean(dv_corrected[350:407])
total_mean = (n_elements(dv_corrected[0:308])*mean_1 + n_elements(dv_corrected[350:407])*mean_2)/(n_elements(dv_corrected[0:308])+n_elements(dv_corrected[350:407]))
dv_corrected[308:349] = total_mean; bad data area

plot, findgen(408), dv_corrected, xtitle='Time step', ytitle='LOS Velocity, km/s'

; ########################################################################################################
; 			"Video" of changing profile for each time step (run above code first)
; ########################################################################################################

FOR i=0, 407 DO BEGIN &$
	cube = readfits(data[i], /silent) &$
	examination_area = cube[403:405, 461:463, *] &$ ; original: cube[403:405, 461:463, *]
	examination_area_profile = TOTAL(TOTAL(examination_area, 2),1) /9 &$
	examination_area_profile = examination_area_profile/interpol_filter_response &$
	examination_area_fit = GAUSSFIT(wave, examination_area_profile, examination_area_coeff, ESTIMATES=[-1281.2, 8542.0, 0.197, -1272979.2, 193.3, -0.005])&$
	plot, wave, quiet_profile_fit &$
	oplot, wave, examination_area_fit &$
	WAIT, 0.4 &$
ENDFOR


; #######################################################################################################
; 					 Linux based video creation, png -> mp4		
; #######################################################################################################
; one image per second, but with 30 of each image

ffmpeg -framerate 1 -pattern_type glob -i '*.png' \
  -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4

; adaptable frame rate, no filling in:

ffmpeg -framerate 5 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p out.mp4



