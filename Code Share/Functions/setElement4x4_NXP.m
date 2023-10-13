function setElement4x4_NXP(array, elementX, elementY, phaseSetting, attenSetting)

nx                  = 4             ;
ny                  = 4             ;
arrayMapping        = [5,   7,  1,  3; ...
                       6,   8,  2,  4; ...
                       12, 10, 16, 14; ...
                       11,  9, 15, 13];

icMapping           = [2, 1; 3, 4];


bitResoltuion       = 8;
minPhaseShiht       = 360./2^bitResoltuion;



phaseArray                            = zeros(nx, nx);
attenArray                            = ones(nx, nx).*255;
enableArray                           = ones(nx, nx);
enableArray(elementY, elementX)       = 0;
phaseArray(elementY, elementX)        = phaseSetting;
attenArray(elementY, elementX)        = attenSetting;

for n = 1:size(icMapping, 1)*size(icMapping, 2)
    [icY, icX]  = find(icMapping == n);
    phaseICnA    = reshape(phaseArray((icY-1)*2+1:icY*2, ...
        (icX-1)*2+1:icX*2), 1, 4);
    enableICnA   = reshape(enableArray((icY-1)*2+1:icY*2, ...
        (icX-1)*2+1:icX*2), 1, 4);
    attenICnA    = reshape(attenArray((icY-1)*2+1:icY*2, ...
        (icX-1)*2+1:icX*2), 1, 4);
    [~, s]      = sort(reshape(arrayMapping((icY-1)*2+1:icY*2, ...
        (icX-1)*2+1:icX*2), 1, 4));
    phase2sendA(n,:) = phaseICnA(s);
    en2sendA(n,:)    = enableICnA(s);
    atten2sendA(n,:) = attenICnA(s);
end

atten2sendA(atten2sendA>=2^bitResoltuion-1)  = 2^bitResoltuion-1;
atten2sendA(atten2sendA<=0)   = 0;




array.setBW0(phase2sendA, atten2sendA, en2sendA);


end