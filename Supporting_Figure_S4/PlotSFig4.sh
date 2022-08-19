#!/bin/bash
set -e

# Plot Residual
#sed -n '/Res:/p' Output.txt | awk '{print NR-1, "\t", $0}' | sed 's/Res://' > SupportingFigureS4.txt # Extract Step and Residuum
sed -n -e 's/^.*\(Res:\)/\1/p' Output.txt | awk '{print NR-1, "\t", $0}' | sed 's/Res://' > SupportingFigureS4.txt # Extract Step and Residuum
# Plot using Python 3.x
./plot.py -x "Newton step" -y "Residuum [a.u.]" -g -d "0 1" --xlim "-0.5 11.5" -e "eps" --ms 10  SupportingFigureS4.txt SupportingFigureS4
