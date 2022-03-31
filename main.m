% PAM and PCM Script
% by David Castillo, Soledad Villegas

% Delete Cache's Data
close all
clear all
clc

% Construction of the Signal
% Create parameters to overlap of sinusoidal
% Signal_1
A=1;                    % Amplitud de la señal de informacion
fm=4e3;                 % Frequencia de la señal de informacion
wm=2*pi*fm;             % Frecuencia de la señal de informacion en radianes
tm=1/fm;                % Periodo de la señal de informacion

factor=50;                        % Factor de muestreo
frecuenciaNyquist=2*fm;           % Tasa de Nyquist
fs=factor*frecuenciaNyquist;      % Frecuencia de muestreo
ts=1/fs;                          % Periodo de muestreo

rangoDinamico=5;                  % Rango de variacion de la señal de informacion
snrQuatizationdB = 35;
snrQuatization = 10^(snrQuatizationdB/10);

% Para obtener el numero de niveles en una cuantizacion uniforme
%L = sqrt(snrQuatization/3);
L=8;
if L==0 || L < 0
    disp('Fuera del Rango Establecido')
elseif L > 0 && L<=1
    L=1;
elseif L>1 && L<=2
    L=2;
elseif L>2 && L<=4
    L=4;
elseif L>4 && L<=8
    L=8;
elseif L>8 && L<=16
    L=16;
elseif L>16 && L<=32
    L=32;
elseif L>32 && L<=64
    L=64;
elseif L>64 && L<=128
    L=128;
elseif L>128 && L<=256
    L=256;
end

n = log(L)/log(2); %Numero de Bits

% Armo el numero de muestras para 3 Periodos
d = tm;       % Duracion de la señal
numMuestras = tm/ts;

t = 0:ts:d*n; %Vector de Tiempo
tsampler=0:ts:d*n-ts;

F = A*cos(2*pi*fm.*t);

% Acondicionamiento O normalizacion
F = F/max(F);
F = F*rangoDinamico;

% Senal Cuadrada
squareSignal = zeros(1,n);
squareSignal(1:1)=1;
squareSignal = repmat(squareSignal,1,numMuestras);
F(end)=[];
t(end)=[];

% Muestreo
Fsample = F.*squareSignal;

% PAM
PAM = [];
k=1;
t_pam = 0:ts/n:(d*n-ts/n);
for i=1:1:length(Fsample)
    for j=1:1:n    
        PAM(k)= Fsample(i);
        k=k+1;
    end
end

k=1;
% Retencion
Fretention=reshape(Fsample,n,[]);
FretentionSignal = [];
for i=1:1:length(Fretention)
    for j=1:1:n
        FretentionSignal(k) = Fretention(1,i);
        k=k+1;
    end
end

% Creo un Vector con los niveles de cuantificacion
a = rangoDinamico*2/L;
valoresCuatificacion = -5+a/2:a:5-a/2;

% Quantizing
quatizedSignal = FretentionSignal;
vector = FretentionSignal;
for i=1:1:length(FretentionSignal)
    if FretentionSignal(i) >= valoresCuatificacion(end)
        quatizedSignal(i)= valoresCuatificacion(end);
        vector(i) = L-1;
    elseif FretentionSignal(i) <= valoresCuatificacion(1)
        quatizedSignal(i)=valoresCuatificacion(1);
        vector(i) = 0;
    else
        for j=1:1:L
            if (FretentionSignal(i) > valoresCuatificacion(j) && FretentionSignal(i) < valoresCuatificacion(j) + a/2) || (FretentionSignal(i) < valoresCuatificacion(j) && FretentionSignal(i) > valoresCuatificacion(j) - a/2) 
                quatizedSignal(i) = valoresCuatificacion(j);
                vector(i)=j-1;
            end
        end
    end
end

% Ancho de banda PCM
R_b= n*frecuenciaNyquist;
Tb_pcm=1/R_b;
B_pcm= 1/(2*Tb_pcm);

pcm =reshape(vector,n,[]);
pcm_r = pcm(1,:);
pcm_r=dec2bin(pcm_r);

trama=[];
k=1;

numSamplePoints=10;
for i=1:1:length(pcm_r)
     for j=1:1:n
         for d=1:1:numSamplePoints
             trama(k) = string(pcm_r(i,j));
             k=k+1;
         end
     end
 end

tb=0:Tb_pcm/numSamplePoints:Tb_pcm*n*numMuestras;
tb(end)=[];
 
% Graphics


%PAM signal
figure('Name','PAM SIGNAL')
plot(t, F, t_pam, PAM,'LineWidth',1.5)
    xlabel('t[s]')
    ylabel('Voltage[V]')
    title('PAM SIGNAL')

% Quantized Signal
figure('Name','QUANTIZED SIGNAL')
plot(t,F,t,quatizedSignal, 'LineWidth',1.5)
    yticks(valoresCuatificacion)
    style = get(gca,'XTickLabel');  
    set(gca,'XTickLabel',style,'fontsize',8)
    set(gca,'XTickLabelMode','auto')
    title('Quantized Signal')
    ylabel('Levels of Quatization [V]')
    xlabel('t[s]')

% Tags for Coded
tagsDec=0:1:L-1;
tagsBin=dec2bin(tagsDec);
tagsBin=string(tagsBin);
tagsBin=num2cell(tagsBin);

% Coded Signal
figure('Name','CODED SIGNAL')
plot(t,F,t,quatizedSignal, 'LineWidth',1.5)
    yticks(valoresCuatificacion)
    yticklabels(tagsBin)
    style = get(gca,'XTickLabel');  
    set(gca,'XTickLabel',style,'fontsize',8)
    set(gca,'XTickLabelMode','auto')
    title('Coded Signal')
    ylabel('Levels of Voltage [V]')
    xlabel('t[s]')
    grid on;

% Digital Data
f1=figure('Name','PCM Signal - Digital Data');
plot(tb,trama, 'LineWidth',1.5);
    axis([0 tb(1000) -2 2])
    grid on;
    grid minor;
    title('PCM Signal - Digital Data')
    ylabel('Bit Value')
    xlabel('t[s]')

% % Digital Data Animation
% f1=figure('Name','Digital Data');
% for i=1:1:length(tb)
%     plot(tb(1:i),trama(1:i), 'LineWidth',1.5);
%     axis([0 tb(1000) -2 2])
%     grid on;
%     grid minor;
%     pause(0.0001)
% end