% PAM and PCM Script
% by David Castillo, Soledad Villegas

close all
clear all
clc

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
L = sqrt(snrQuatization/3);

if L==0 || L < 0
    disp('Fuera del Rango Establecido')
elseif L > 0 && L<=1
    L=1
elseif L>1 && L<=2
    L=2
elseif L>2 && L<=4
    L=4
elseif L>4 && L<=8
    L=8
elseif L>8 && L<=16
    L=16
elseif L>16 && L<=32
    L=32
elseif L>32 && L<=64
    L=64
elseif L>64 && L<=128
    L=128
elseif L>128 && L<=256
    L=256
end

n = log(L)/log(2); %Numero de Bits

% Armo el numero de muestras para 3 Periodos
d = tm;       % Duracion de la señal
numMuestras = tm/ts;

t = 0:ts:d*n; %Vector de Tiempo
F = A*cos(2*pi*fm.*t)

% Acondicionamiento O normalizacion
F = F/max(F);
F = F*rangoDinamico;

% Senal Cuadrada
squareSignal = zeros(1,n);
squareSignal(1:n/2)=1;
squareSignal = repmat(squareSignal,1,numMuestras)
F(end)=[]
t(end)=[]

% Muestreo
pam_F = F.*squareSignal;

% Retencion
pam_Fr=reshape(pam_F,n,[])
PAM = pam_Fr(1,:)
pamSiganl = zeros(1,n)
pampam = []
k=1;
for i=1:1:length(pam_Fr)
    for j=1:1:n
        pampam(k) = PAM(i);
        k=k+1;
    end
end

% Creo un Vector con los niveles de cuantificacion
a = rangoDinamico*2/L;
valoresCuatificacion = -5+a/2:a:5-a/2;


%PAM
vector = pampam;
for i=1:1:length(pampam)
    if pampam(i) >= valoresCuatificacion(end)
        pampam(i) = valoresCuatificacion(end);
        vector(i) = L;
    elseif pampam(i) <= valoresCuatificacion(1)
        pampam(i) = valoresCuatificacion(1);
        vector(i) = 0;
    else
        for j=1:1:L
            if (pampam(i) > valoresCuatificacion(j) && pampam(i) < valoresCuatificacion(j) + a/2) || (pampam(i) < valoresCuatificacion(j) && pampam(i) > valoresCuatificacion(j) - a/2) 
                pampam(i) = valoresCuatificacion(j);
                vector(i)=j;
            end
        end
    end
end

figure
plot(t,F,t,pampam, 'LineWidth',1.5)
yticks(valoresCuatificacion)
style = get(gca,'XTickLabel');  
set(gca,'XTickLabel',style,'fontsize',8)
set(gca,'XTickLabelMode','auto')

pcm =reshape(vector,n,[]);
pcm_r = pcm(1,:);
pcm_r=dec2bin(pcm_r);
pcm_r(:,1)=[]

trama=vector;
k=1;
for i=1:1:length(pcm_r)
    for j=1:1:n
       trama(k) = string(pcm_r(i,j));
       k=k+1;
    end
end
