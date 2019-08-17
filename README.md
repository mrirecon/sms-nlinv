These scripts reproduce the experiments described in the article:
    
S. Rosenzweig, H.C.M. Holme, R.N. Wilke, D. Voit, J. Frahm and M. Uecker.
Simultaneous Multi-Slice MRI using Cartesian and Radial FLASH and Regularized Nonlinear Inversion: SMS-NLINV.
Magnetic Resonance in Medicine 79:2057-2066 (2018) [DOI: 10.1002/mrm.26878](http://onlinelibrary.wiley.com/doi/10.1002/mrm.26878/full), [arXiv:1705.04135](https://arxiv.org/abs/1705.04135)

For reconstruction we provide an adapted version of the Berkeley Advanced Reconstruction Toolbox (BART) [1].


In each folder the *.sh shell-scripts must be started. These scripts require BART [1]:

Install BART[1], enter the corresponding directory and checkout the sms-nlinv branch

    > git checkout sms-nlinv
    > make

The data can be viewed e.g. with 'view'[2] or be loaded into Matlab or Python using 
the wrappers provided in BART subdirectories './matlab' and './python'

[For Cartesian experiments, the patterns are explicitely provided.]

If you need further help to run the scripts, I am happy to help you: sebastian.rosenzweig@med.uni-goettingen.de

August 29, 2017 - Sebastian Rosenzweig

[1] https://mrirecon.github.io/bart
[2] https://github.com/mrirecon/view



