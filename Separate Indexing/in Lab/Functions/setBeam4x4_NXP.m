 function array = setBeam4x4_NXP(array, varargin) %(array, theta, phi, atten)
    %   Array looks like this (antenna side up)
    %
    %                                            hole
    %                 5     7          1   3     
    %            ----   IC2            IC1   ----               
    %           |     6     8          2   4     |
    %           |                                |
    %        ---|                                |---
    %       |   |                                |   | 
    %       |   |     12    10       16    14    |   |
    %       |    ----   IC3             IC4  ----    |           
    %       |         11    9        15    13        |
    %       |                                        |
    %         --------------------------------------
    %                           |
    %     hole                  |
    %                           |
    %                         RF_Com 
    %                                 

    %
    %   * Digital Connections
    %   - Chain 01 (CS0): NI -> IC1 -> IC2
    %   - Chain 02 (CS1): NI -> IC3 -> IC4
    %
    %   * NFPA 
    %   There are 4 near-field probes, placed at the same location 
    %   as the ICs.  
    %   switch1 -->IC3
    %   switch2 -->IC2
    %   switch3 -->IC1
    %   switch4 -->IC4
    %
    %   * Anti-Phase
    %   odd rows are anti-phase fed for V-pol
    %   odd columns are anti-phase fed for H-pol
    %
    %   * Switching
    %   Switchs (ADRF5043) are controled by V1, V2 VEN.  
    %   VEN (enable) is active low.
    %   V1-2 are connected to NI D04-05, VEN to D03
    %   
    %   Probe  V1 | V2
    %   ---------------------------
    %     1     [0 0]
    %     2     [1 0]
    %     3     [0 1]
    %     4     [1 1]


    
nx                  = 4             ;
ny                  = 4             ;


arrayMapping = [5,   7,  1,  3; ...
                6,   8,  2,  4; ...
                12, 10, 16, 14; ...
                11,  9, 15, 13];

icMapping    = [2, 1; 3, 4];

%icMapping    = [1, 2; 4, 3];

bitResoltuion   = 8;
minPhaseShiht   = 360./2^bitResoltuion;
            


calFilePath                 = './Array Calibration Files/';
calFlag                     = 0;
calPowerFlagNew             = 0;
calPowerFileFlag            = 0;
calPhaseFileFlag            = 0;
CalPowerFlag                = 1;
CalPhaseFlag                = 1;
theta                       = 0;
phi                         = 0;
atten                       = 0;
offset                      = 0;
carrierFrequenyScalingFlag  = false;
taperArray                  = ones(nx, ny);
enableArray                 = zeros(nx, ny);

if ~isempty(varargin)
    for i = 1:length(varargin)
        if isstr(varargin{i})
            switch varargin{i}
                case 'CalFlag'
                    calFlag = varargin{i+1};
                case 'CalPowerFlag'
                    calPowerFlag = varargin{i+1};
                case 'CalPowerFlagNew'
                    calPowerFlagNew = varargin{i+1};
                case 'CalPhaseFlag'
                    CalPhaseFlag = varargin{i+1};
                case 'CalFilePath'
                    calFilePath = varargin{i+1};
                case 'Theta'
                    theta   = varargin{i+1};
                case 'Phi'
                    phi     = varargin{i+1};
                case 'Attenuation'
                    atten   = varargin{i+1};
                case 'CarrierFrequency'
                    carrierFrequenyScaling      = varargin{i+1}./38e9;
                    carrierFrequenyScalingFlag  = true;
                case 'Taper'
                    taperFile                   = varargin{i+1};
                    load(taperFile);
                    coeff       = dataSave{2}.estimatedCoef;
                    coeff       = coeff./max(abs(coeff));
                    taperArray  = reshape(coeff, [nx, ny]).';
                case 'Enable'
                    enableArray = varargin{i+1};
                    if size(enableArray, 1) ~= [nx, ny]
                        disp('Size of Enable Input Does not Match Array Size');
                        enableArray  = zeros(nx, ny);
                    end
                case 'CalPowerFile'
                    calPowerFileFlag = 1;
                    elementPowerVsPhaseBeforeCal_NXP = varargin{i+1};
                case 'CalPhaseFile'
                    calPhaseFileFlag = 1;
                    phaseSettingAfterCal = varargin{i+1};
                    
            end
                
        end
    end
end

dx              = reshape(repmat(1:nx, 1, nx),  nx,  nx).'-1;
dy              = reshape(repmat(1:ny, 1, ny),  ny,  ny)-1;

dx(:, 3) = 2.2;
dx(:, 4) = 3.2;

% dy(3, :) = 2.2;
% dy(4, :) = 3.2;
% 
if length(theta)>1
    dummy = 0;

    for counter = 1:length(theta)
        if carrierFrequenyScalingFlag
            dx              = reshape(repmat(1:nx, 1, nx),  nx,  nx).'...
                .*carrierFrequenyScaling(counter);
            dy              = reshape(repmat(1:ny, 1, ny),  ny,  ny)...
                .*carrierFrequenyScaling(counter);
        end
        dummy           = dummy + exp(-1i.*pi...
            .*sind(theta(counter)).*((dx-1).*cosd(phi(counter))+...
            (dy-1).*sind(phi(counter))));
    end
    phaseValue = angle(dummy);
else
    phaseValue = angle(exp(-1i.*pi.*sind(theta).*((dx-1).*cosd(phi)+...
        (dy-1).*sind(phi))));
end


phaseCal   = zeros(nx, ny);
attenValue = ones(nx, ny).*(2^(bitResoltuion)-1);

freqInterestIndex = 1701;
if calFlag
    try
        if calPowerFileFlag == 0
            load([calFilePath 'elementPowerVsPhaseBeforeCal_NXP_Decoupling']);
        end
        if calPhaseFileFlag == 0
            load([calFilePath 'phaseSettingAfterCal_NXP_Default']);
        end
        
        minPower = min(min(min(20.*log10(abs(elementPowerVsPhaseBeforeCal_NXP(:, :, :, freqInterestIndex))), [], 3)));
        offset   = zeros(nx, ny)+minPower;
        
        if CalPhaseFlag
            phaseCal = phaseSettingAfterCal;
        else
            phaseValue(:, 1:2:end)               = phaseValue(:, 1:2:end)+pi;
        end
        
        if calPowerFlagNew
            offset = (min(20.*log10(abs(elementPowerVsPhaseBeforeCal_NXP(:, :, :, freqInterestIndex))), [], 3));
        end

        
    catch
        elementPowerVsPhaseBeforeCal_NXP   = 2^bitResoltuion-1+zeros(nx, ny, 2^bitResoltuion);
        phaseCal                           = zeros(nx, ny);
        %phaseValue(1:2:end,:)             = phaseValue(1:2:end,:)+pi;
        phaseValue(:, 1:2:end)             = phaseValue(:, 1:2:end)+pi;
        disp('error loading array cal files');
    end
else
    elementPowerVsPhaseBeforeCal_NXP       = 2^bitResoltuion-1+zeros(nx, ny, 2^bitResoltuion);
    phaseCal                               = zeros(nx, ny);
    phaseValue(:, 1:2:end)                 = phaseValue(:, 1:2:end)+pi;
    %phaseValue(1:2:end, :)               = phaseValue(1:2:end, :)+pi;
    %phaseValue(:, 1:2:end)   = phaseValue(:, 1:2:end)+pi;
end

phaseValue      = phaseValue+angle(taperArray);
magValue        = abs(taperArray);



phaseValueArray = mod(round((phaseValue*180/pi)/minPhaseShiht), 2^bitResoltuion);
phaseValueArray = mod(phaseValueArray+phaseCal, 2^bitResoltuion);

if ((calFlag*calPowerFlag)==1) || ((calFlag*calPowerFlagNew)==1)
    for xPos = 1:nx
        for yPos = 1:ny
            attenValue(yPos, xPos)  = 255-round(...
                (20.*log10(abs(elementPowerVsPhaseBeforeCal_NXP(yPos, xPos, phaseValueArray(yPos, xPos)+1, freqInterestIndex)))...
                -offset(yPos, xPos))/0.0625);
        end
    end
end

magValueArray   = -round(20.*log10(magValue)./0.5)+attenValue;

for n = 1:size(icMapping, 1)*size(icMapping, 2)
    [icY, icX] = find(icMapping == n);
    phaseICn  = reshape(phaseValueArray((icY-1)*2+1:icY*2, (icX-1)*2+1:icX*2), 1, 4);
    magICn    = reshape(magValueArray((icY-1)*2+1:icY*2, (icX-1)*2+1:icX*2), 1, 4);
    enableICn =  reshape(enableArray((icY-1)*2+1:icY*2, (icX-1)*2+1:icX*2), 1, 4);
    [~, s]  = sort(reshape(arrayMapping((icY-1)*2+1:icY*2, (icX-1)*2+1:icX*2), 1, 4));
    phase2send(n,:) = phaseICn(s);
    atten2send(n,:) = magICn(s);
    en2send(n,:)    = enableICn(s);
end




phase2send                  = mod(phase2send, 2^bitResoltuion);
atten2send                  = atten2send + atten;

atten2send(atten2send>=2^bitResoltuion)  = 2^bitResoltuion-1;
atten2send(atten2send<=0)                = 0;

[array, ~]                               = array.setBW0(phase2send, atten2send, en2send);

end