; #########################################################################################
; First image processing and set-up for saving out plots
; #########################################################################################

; set-up the environment:
!p.background = 255
!p.color = 0

; 0 = b/w, 1=blue, 3 = red, 5,11,39 also useful. ; Or ;aia_lct, r, g, b, wavelnth='171', /load
loadct, 0, /silent

; Modify as required
data = FILE_SEARCH('/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/*.fits')
RESTORE, '/home/40147775/msci/data/14Jul2016/AR12565/IBIS/final_scans/common_vars.sav', /verbose
; common_vars.sav contains 3 objects, time_cube_15, sub_scans_300, marked_sub_scan

; Play a video of an RMS (300 seconds) version of the data over the line core with LB marked
xstepper, marked_sub_scan, xsize=700, ysize=700

; Still image of a particular frame
cube_41 = readfits(data[i])
tvim, cube_41[*,*,16], xtitle='xaxis', ytitle='yaxis'

; Creating plots suitable for reports (heavily based on code provided by David):
image = cube_41[*,*,10]

delta_x = 100
delta_y = 100

xcen = 500 ; all images are 1000x1000
ycen = 500 

image_map = MAKE_MAP(image, dx=delta_x, dy=delta_y, xc=xcen, yc=ycen)

; examine the map (image)
plot map, image map, ycharsize=2, xcharsize=2, xthick=2, ythick=2, charsize=2, charthick=2,
xticklen=-.025, yticklen=-.025, xtitle=’Distance (km)’, ytitle=’Distance (km)’, title=’TITLE’, xtickinterval=50, ytickinterval=50, dmin=50, dmax=5000, /log

x1 = 0.1
x2 = 0.9
y1 = 0.1
y2 = 0.9

set_plot, 'ps'
device, filename=’SPECIFY_FILE_OUTPUT_PATH.eps’, /encapsulated,
xsize=24, ysize=24, /tt font, set font=’Times’, font size=1, /color, bits per pixel=8

LOADCT, 0, /silent
!p.background = 255
!p.color = 0
aia lct, r, g, b, wavelnth=’171’, /load

plot map, image map, ycharsize=1.4, xcharsize=1.4, xthick=2, ythick=2, charsize=10,
charthick=2, xticklen=-.025, yticklen=-.025, xtitle=’Distance (km)’, ytitle=’Distance (km)’,
title=’Ca II K line core’, xtickinterval=50, ytickinterval=50, dmin=50, dmax=5000,
/log, position=[x1,y1,x2,y2]

colorbar, bottom=0, ncolors=255, charsize=12, charthick=2, color=0, divisions=2,
minrange=50, maxrange=5000, position=[x1+0.015,y1,x2+0.03,y2], /vertical, /right,
ticknames=tickmarknames, title=’Intensity (arb. units)’, font=-1

device, /close
IDL> set plot, ’x’

