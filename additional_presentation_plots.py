# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
import matplotlib.pyplot as plt

frame_shk = [33,72,90]
frame_shk = np.array(frame_shk)
inten = [339,429,376]
inten = np.array(inten)

temp_shk = [4416, 4248, 4469]
temp_shk = np.array(temp_shk)
frame_lb = [42,78,100]
frame_lb = np.array(frame_lb)
temp_lb = [4390, 4264, 3612]
temp_lb = np.array(temp_lb)


plt.plot(frame_shk, inten, 'D', markersize=10)
plt.title('Plot of Intensity for a Forming Shock', fontsize=16)
plt.ylabel('Intensity', fontsize=14)
plt.xlabel('Event Frame', fontsize=14)
plt.xlim(0,110)
plt.ylim(0,550)
plt.errorbar(frame_shk, inten, 80, linestyle='')
plt.savefig('C:/Users/mawhi/Documents/msci_project/project_presentation/presentation_figs/intensity_shk.png', dpi = 500)
plt.show()

plt.plot(frame_shk, temp_shk, 'D', markersize=10)
plt.title('Plot of Temperature for a Forming Shock', fontsize=16)
plt.ylabel('Temperature (K)', fontsize=14)
plt.xlabel('Event Frame', fontsize=14)
plt.xlim(0,110)
plt.ylim(0,5000)
plt.savefig('C:/Users/mawhi/Documents/msci_project/project_presentation/presentation_figs/temp_shk.png', dpi = 500)
plt.show()

plt.plot(frame_lb, temp_lb, 'D', markersize=10)
plt.title('Plot of Temperature at the Light Bridge', fontsize=16)
plt.ylabel('Temperature (K)', fontsize=14)
plt.xlabel('Interaction Frame', fontsize=14)
plt.xlim(0,110)
plt.ylim(0,5000)
plt.savefig('C:/Users/mawhi/Documents/msci_project/project_presentation/presentation_figs/temp_lb.png', dpi = 500)
plt.show()
