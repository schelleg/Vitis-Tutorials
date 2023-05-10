%
% Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
% SPDX-License-Identifier: X11
%

function Hd = ChannelFilter
%CHANNELFILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.7 and Signal Processing Toolbox 8.3.
% Generated on: 23-Nov-2020 15:27:15

% FIR Window Raised-cosine filter designed using the FIRRCOS function.

% All frequency values are normalized to 1.

N    = 120;        % Order
Fc   = 0.8;        % Cutoff Frequency
TM   = 'Rolloff';  % Transition Mode
R    = 0.25;       % Rolloff
DT   = 'sqrt';     % Design Type
Beta = 1;          % Window Parameter

% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = firrcos(N, Fc, R, 2, TM, DT, [], win);
Hd = dfilt.dffir(b);

% [EOF]
