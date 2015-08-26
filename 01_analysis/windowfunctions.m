N = 65;
w = window(@hanning,N);
w1 = window(@blackman,N);
w2 = window(@hamming,N); 
w3 = window(@gausswin,N,2.5); 
wvtool(w,w1,w2, w3)