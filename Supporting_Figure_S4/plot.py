#!/usr/bin/env python
# histogram for noise amplification evaluation

import numpy as np
import sys
import matplotlib
import matplotlib.pyplot as plt
from optparse import OptionParser

parser = OptionParser(description="Creates histogram.", usage="usage: %prog [-options] <xy_0> <xy_1> ... <dst>")
parser.add_option("-x", dest="xlabel",
                 help="xlabel. (Default: %default)", default="x")
parser.add_option("-y", dest="ylabel",
		 help="ylabel. (Default: %default)", default="y")
parser.add_option("-l", dest="legend",
		 help="Legend 'name1 name2 ...'.", default="")
parser.add_option("-f", dest="fontsize",
		 help="Fontsize. Default: (%default)", default=30)
parser.add_option("--xlim", dest="xlim",
		 help="xlim. Pass: 'min max'.", default="")
parser.add_option("--ylim", dest="ylim",
		 help="ylim. Pass: 'min max'.", default="")
parser.add_option("-g", dest="grid", action="store_true",
		 help="Set grid", default=False)
parser.add_option("--rmh", dest="rmheader", action="store_true",
		 help="Remove first line (header).", default=False)
parser.add_option("--ms", dest="ms", 
		 help="Size of markers.", default=-1)
parser.add_option("-r", dest="xticksRot",
		 help="Rotate xticks. Default: %default", default=0)
parser.add_option("-d", dest="data",
		 help="Which columns belong to x|y. Default: '%default''", default="1 0")
parser.add_option("--loc", dest="loc",
		 help="Legend location. Default: '%default''", default="upper right")
parser.add_option("-e", dest="ending",
		 help="File-format. Default: '%default''", default="pdf")
parser.add_option("--log", dest="log", 
		  help="Logarithmic axis. Pass 'x' or 'y'.", default="")
(options, args) = parser.parse_args() 

rmheader = bool(options.rmheader)

# Number of plots
n = len(args)-1 

# Total number of lines
totLines = 0
for line in open(str(args[0])):
    totLines += 1
if(rmheader):
    totLines -= 1
    
# Get values
src = np.zeros(shape=(totLines,2,n))
for i in range(0,n):
	index = 0
	for line in open(str(args[i])):
		if(rmheader and index==0):
		    # do nothing
		    index += 1
		else:
		  l = line.split("\t")
		  src[index,0,i] = l[0]
		  src[index,1,i] = l[1]
		  index += 1

# Plot Adjustments
grid = bool(options.grid)
xlim = str(options.xlim)
xlim = [float(k) for k in xlim.split()]
ylim = str(options.ylim)
ylim = [float(k) for k in ylim.split()]
log = str(options.log)
fontsize = str(options.fontsize)
matplotlib.rcParams['font.size'] =  fontsize # Font size
matplotlib.rcParams['lines.linewidth'] = 4 # Line Width
color = ["black","red","grey","blue"]
linestyle = ["-", "--", "-.", ":"] 
marker = ["o", "^", "s", "8"]

ms = float(options.ms)
xlabel = str(options.xlabel)
ylabel = str(options.ylabel)
legend = str(options.legend)
legend = [str(k) for k in legend.split()]
loc = str(options.loc)
ending = str(options.ending)
xticksRot = int(options.xticksRot)
data = str(options.data)
data = [int(k) for k in data.split()]

# Output
dst = str(args[-1])+"."+ending


fig = plt.figure()
a = fig.add_subplot(111)
for i in range(0,n):
	a.plot			(src[:,data[0],...,i], src[:,data[1],...,i],  linestyle=linestyle[i], marker = marker[i], markersize=ms, color = color[i], label='the data')
a.set_xlabel				(xlabel)
a.set_ylabel				(ylabel)
if(xlim):
	a.set_xlim			([xlim[0],xlim[1]])	
if(ylim):
	a.set_ylim			([ylim[0],ylim[1]])			
if(legend):
	a.legend			(legend,loc=loc,fontsize=30)
if(grid):
	a.grid				()
if(log == "x"):
	a.set_xscale			('log')
if(log == "y"):
	a.set_yscale			('log')	
plt.xticks				(rotation=xticksRot)
fig.tight_layout			(pad=0.1)
fig.savefig				(dst)
