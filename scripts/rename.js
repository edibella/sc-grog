// Pull in file system utilities
fs = require('fs');

// Specify npm name and Matlab Package name
NPM_NAME = 'sc-grog';
MATLAB_NAME = '+ScGrog';

// Rename package so that MATLAB can use it.
npmPath = "../" + NPM_NAME;
newPath = "../" + MATLAB_NAME;
fs.renameSync(npmPath, newPath);
