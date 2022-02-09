function reducerAnalysis1
	% Author : Matt R. Flax <flatmax@>
	% free software, MIT license.
	% Copyright Flatmax Pty Ltd 2022
outDir='/tmp/measurements';
eval(['!mkdir -p ' outDir]);

% fn={'2_TLNoTrim3.wav', '2_10inch50mm_2.wav','2_10inch60mm_2.wav','2_10inch80mm_1.wav'};
% legStr={'No reducer','10" 50mm', '10" 65mm','10" 80mm'};
fn={'2_10inch60mm_2.wav','2_10InchTL_1.wav','2_10InchTLExp1.wav','2_10InchTLExp2_1.wav'};
legStr={'10" 65mm','10" 65mm+TL','10" 65mm+TL+exp','10" 65mm+TL+exp+exp'};
for c=1:length(fn)
	[h(:,:,c), HSm(:,:,c), f, fs(c), H(:,:,c)]=loadAndSmooth(fn{c});
	if fs(1)~=fs(c) error('fs mismatch'); end
end

hFront=squeeze(h(:,1,:));
hBack=squeeze(h(:,2,:));
HFront=squeeze(H(:,1,:));
HBack=squeeze(H(:,2,:));

fa=15e2;
Nc=660;

figure(1); clf
ax(1)=subplot(211);
semilogx(f, 20*log10(abs(HFront))); grid on;
ylabel('dB');
set(gca,'xlim',[10 10e3], 'ylim',[-40 15]);
legend(legStr,'location','best')
title('Front of speaker')
ax(2)=subplot(212);
semilogx(f, 20*log10(abs(HBack))); grid on;
xlabel('f (Hz)'); ylabel('dB');
% set(gca,'xlim',[10 10e3], 'ylim',[-40 15]);
title('Back of speaker')
linkaxes(ax,'x')
set(gca,'xlim',[10 fa], 'ylim',[-40 15]);
legend(legStr,'location','best')
eval(['print -depsc ' outDir '/measurements.front.back.eps']);

set(gca,'xlim',[10 200], 'ylim',[-40 15]);
eval(['print -dpng ' outDir '/measurements.front.back.png']);

HSum=squeeze(sum(HSm,2));
figure(2); clf
semilogx(f, 20*log10(abs(HSum))); grid on; hold on
legend(legStr,'location','best')
set(gca,'xlim',[10 10e3], 'ylim',[-20 20]);
title('Front and back summed')
xlabel('f (Hz)'); ylabel('dB');
% set(gca,'xlim',[10 10e3], 'ylim',[-40 15]);
% set(gca,'xlim',[10 fa], 'ylim',[-40 15]);
eval(['print -depsc ' outDir '/measurements.summed.eps']);

figure(3); clf
ax(1)=subplot(211);
semilogx(hFront); grid on;
ylabel('amplitude');
% set(gca,'xlim',[10 10e3], 'ylim',[-40 15]);
legend(legStr,'location','eastoutside')
title('Front of speaker')
ax(2)=subplot(212);
semilogx(hBack); grid on;
xlabel('sample'); ylabel('amplitude');
% set(gca,'xlim',[10 10e3], 'ylim',[-40 15]);
title('Back of speaker')
legend(legStr,'location','eastoutside')
linkaxes(ax,'x')
% set(gca,'xlim',[10 fa], 'ylim',[-40 15]);
eval(['print -depsc ' outDir '/measurements.time.eps']);

end

function [h, HSm, f, fs, H]=loadAndSmooth(fn)
[h,fs]=audioread(fn);
[N,M]=size(h);
H=abs(fft(h));
f=linspace(0,fs,N+1); f(end)=[];
fact=10e-1;
for m=1:M
	HSm(:,m)=csaps(f', H(:,m), fact, f');
end
% HSm=H;
end
