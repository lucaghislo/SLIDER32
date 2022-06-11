function [y, f] = myfft( x, fs, NFFT, windowFunction, doPlot )
    % MYFFT  Perform the Fast Fourier Transform of vector X with a 
    %   sampling frequency FS.
    %
    %   MYFFT(X,FS) computes the discrete Fourier transform (DFT) of X 
    %   using a fast Fourier transform (FFT) algorithm. X is windowed with 
    %   a Hann window.
    %    
    %   MYFFT(X,FS,NFFT) computes the NFFT-point DFT of vector X.
    %   X is windowed with a Hann window.
    %    
    %   MYFFT(X,FS,NFFT,WINDOWFUNCTION) computes the NFFT-point DFT of 
    %   X. X is windowed with the window specified in WINDOWFUNCTION.
    %   Possible values of WINDOWFUNCTION are:
    %   - 'hann': Hann window function(default)
    %   - 'hamming': Hamming window function
    %   - 'blackmanharris': Blackman-Harris window function
    %   - 'rect': rectangular window funtion
    %
    %   MYFFT(___,DOPLOT) specifies if the result of the FFT has to be
    %   showed on a graph or not.
    %
    %   Created by: Patrick Locatelli
    %   Version: 1.1

    if nargin < 5
        doPlot = false;
    end
    if nargin < 4 || isempty(windowFunction)
        windowFunction = 'hann';
    end
    if nargin < 3 || isempty(NFFT)
        NFFT = -1;
    end
        
    if isrow(x)
        x = x';
    end
    
    % Check if the data contains NaN values
    if any(isnan(x))
        warning('The input vector contains NaN values. Trying filling such values with ''fillmissing'' function.')
        x = fillmissing(x,'spline');
    end
    
    %% Determine the number of points in the FFT (= resolution)
    if NFFT < 0
        NFFT = 2^nextpow2(size(x,1));
    end
    
    %% Window the data
    switch windowFunction
        case 'hann'
            coeff = hann(size(x,1));
            coherentGain = 0.5;
        case 'hamming'
            coeff = hamming(size(x,1));
            coherentGain = 0.54;
        case 'blackmanharris'
            coeff = blackmanharris(size(x,1));
            coherentGain = 0.42;
        otherwise
            coeff = rectwin(size(x,1));
            coherentGain = 1;
    end
    
    x = x .* coeff;
    
    %% Calculate the FFT of x
    % Determine the FFT over NFFT points (zero-padding included in the function)
    xdft = fft(x, NFFT);
    
    % Convert from two-sided to single-sided power spectrum
    if ~mod(NFFT,2)
        % Even
        xdft = xdft(1:NFFT/2 + 1,:);
        xdft(2:end-1,:) = 2*xdft(2:end-1,:);
    else
        % Odd
        xdft = xdft(1:floor(NFFT/2) + 1,:);
        xdft(2:end,:) = 2*xdft(2:end,:);
    end
        
    % Compute the amplitude spectrum
    ydft = 1/size(x,1) .* abs(xdft);             % EDITED: 1/NFFT
    
    % Apply the window correction factor
    ydft = ydft / coherentGain;
    
    % Finally, determine the frequencies array
    freq = fs/2 * linspace(0, 1, NFFT/2 + 1);
    
    %% Plot the results
    if doPlot == true || nargout == 0
        figure; plot(freq, ydft)
        grid on
        xlabel 'Frequency (Hz)'
        ylabel 'Amplitude'
    end
    
    %% Return values, if requested
    if nargout > 0
        y = ydft;
        f = freq';
    end
end