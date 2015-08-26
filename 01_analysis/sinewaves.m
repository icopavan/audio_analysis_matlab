%sine
t=-pi*2:1/500:pi*4;   % Time Samples
x=sin(t);         % Generate Sine Wave  
h1=figure(1);
PlotAxisAtOrigin(t,x);        % Plot Sine Wave

set(h1, 'Position', [150 150 500 200]);
set(gcf,'PaperPositionMode','auto');
saveas(h1,'sine1.pdf');

%5*sin(2*t+pi/2)
t=-pi*2:1/500:pi*3;   % Time Samples
x=5*sin(2*t+pi/2);         % Generate Sine Wave  
h2=figure(2);
hold on;
PlotAxisAtOrigin(t,x);        % Plot Sine Wave
hold off;

set(h2, 'Position', [700 150 500 200]);
set(gcf,'PaperPositionMode','auto');
%saveas(h2,'sine2.pdf');

%discretisierung
t=0:1/500:pi*5;   % Time Samples
x=sin(t);         % Generate Sine Wave  
h3=figure(3);
plot(t,x);        % Plot Sine Wave

set(h3, 'Position', [150 450 500 200]);
set(gcf,'PaperPositionMode','auto');
%saveas(h3,'sine3.pdf');

t=0:1:40;                   % Time Samples
f=500;                      % Input Signal Frequency
fs=8000;                    % Sampling Frequency
x=sin(2*pi*f/fs*t);         % Generate Sine Wave  
h4=figure(4);
stem(t*1/fs*1000,x,'r');	% View the samples

set(h4, 'Position', [700 450 500 200]);
set(gcf,'PaperPositionMode','auto');
%saveas(h4,'sine4.pdf');


r = 1/10000;
%repeated sine without window
t=1:r:10;   % Time Samples
x=sin(t+pi);         % Generate Sine Wave  
T=1:r/3:10;
X=[x,x,x];
X=X(1:length(X)-2);
h5=figure(5);
plot(T,X);        % Plot Sine Wave

set(h5, 'Position', [150 150 500 200]);
set(gcf,'PaperPositionMode','auto');
saveas(h5,'sine5.pdf');


%repeated sine with window
t=1:r:10;   % Time Samples
x=sin(t+pi);         % Generate Sine Wave 
w = hamming(length(x));
x_w = x.*w';
T=1:r/3:10;
X=[x_w,x_w,x_w];
X=X(1:length(X)-2);
h6=figure(6);
plot(T,X);        % Plot Sine Wave

set(h6, 'Position', [150 450 500 200]);
set(gcf,'PaperPositionMode','auto');
saveas(h6,'sine6.pdf');



