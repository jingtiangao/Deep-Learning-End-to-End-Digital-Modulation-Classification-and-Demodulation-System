
%MODULATION_TRAIN �˴���ʾ�йش˺�����ժҪ
%   ����QPSK 16QAM 8PSK�ĵ��ƺ�����ֻ����ź� ������ȡ���߽��ۻ��� ������ʶ��ͽ����ѵ�������Ҵ��ϱ�ǩ
clear
clc
%% init
% ���帴��
j = sqrt(-1);
% ÿ�����͵��źŵ�������Ŀ
NTrain = 10000;
%�ź���͵�snr
EsNo_low = 20;
%�ź���ߵ�snr
EsNo_high = 50;
%ÿһ�����а�������Ԫ��Ŀ
L = 100;
%�źŵ����͸���
NClass = 3;
%�߽��ۻ����ĸ���
NFeatures = 9;
train_data = zeros(NClass * NTrain, NFeatures + 1);
%% get train data

% psk8 ѵ�����Ĳ���
%�����ź�����
signalData = zeros(NTrain, L);
signalData_psk8 = zeros(NTrain, L);
%������������
noiseData = zeros(NTrain, L);
%������Ԫ����
labelData_psk8 = zeros(NTrain, L);
%����8PSK��������matlab�źŹ�����
mod = comm.PSKModulator('ModulationOrder',8,'PhaseOffset',0);
%��ȡ������ʽ�� ��������Ԫ������
x = constellation(mod);
%��ȡ��ǰ����
xN = length(x);
%��ʼѭ������ѵ����
%�������ɵ�ѵ�����Ƿ��������-10db��20db���ȷֲ���
for row = 1:NTrain
    EsNo = (EsNo_high - EsNo_low)*rand + EsNo_low;
    P = 10^(EsNo/10);
    for col = 1:L
        %���������Ԫ����8psk���Ƶõ�������ʾ
        a=unidrnd(xN);
        s = x(a);
        %��������ֻ����źű��ʽ����ͨ�����Ը�˹�������ŵ�AWGN
        signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
        %�õ�����ź�ѵ�����ͱ�ǩ 8psk
        labelData_psk8(row,col)= a-1;
        signalData_psk8(row,col)=signalData(row, col);
        %����õ���������
        noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
    end
end
%��������8PSK�źŵĸ߽��ۻ��� ���㹫ʽ����������ĵ�����
cumulants = func_get_cumulants(signalData, noiseData);
for row = 1:NTrain
    for i = 1:NFeatures
        train_data(row, i) = cumulants(row, i);
    end
    %��QPSK���Ƶ����ʹ��ϱ�ǩ 0����8PSK 1����QPSK 2����16QAM
    train_data(row, NFeatures+1) = 0;
end

% qpsk
disp('qpsk begin');
%����qpsk�ź�����
signalData = zeros(NTrain, L);
signalData_psk4 = zeros(NTrain, L);
%����qpsk��������
noiseData = zeros(NTrain, L);
%������Ԫ����
labelData_psk4 = zeros(NTrain, L);
%����qpsk��������matlab�źŹ�����
mod = comm.PSKModulator('ModulationOrder',4,'PhaseOffset',0);
%��ȡ������ʽ�� ��������Ԫ������
x = constellation(mod);
%��ȡ��ǰ����
xN = length(x);
%��ʼѭ������ѵ����
%�������ɵ�ѵ�����Ƿ��������-10db��20db���ȷֲ���
for row = 1:NTrain
    EsNo = (EsNo_high - EsNo_low)*rand + EsNo_low;
    %���ʼ���
    P = 10^(EsNo/10);
    for col = 1:L
        %���������Ԫ����Qpsk���Ƶõ�������ʾ
        a=unidrnd(xN);
        s = x(a);
        %��������ֻ����źű��ʽ����ͨ�����Ը�˹�������ŵ�AWGN
        signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
        %�õ�4psk����ź�ѵ�����ͱ�ǩ 
        labelData_psk4(row,col)= a-1;
        signalData_psk4(row,col)=signalData(row, col);
        %����õ���������
        noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
    end
end
%��������QPSK�źŵĸ߽��ۻ��� ���㹫ʽ����������ĵ�����
cumulants = func_get_cumulants(signalData, noiseData);
for row = 1:NTrain
     for i = 1:NFeatures
        train_data(row+NTrain, i) = cumulants(row, i);
     end
     %��QPSK���Ƶ����ʹ��ϱ�ǩ 0����8PSK 1����QPSK 2����16QAM
     train_data(row+NTrain, NFeatures+1) = 1;
end

% qam16 ���ƹ�������������
signalData = zeros(NTrain, L);
signalData_qam16 = zeros(NTrain, L);

noiseData = zeros(NTrain, L);
%������Ԫ����
labelData_qam16 = zeros(NTrain, L);
mod = comm.RectangularQAMModulator('ModulationOrder',16,...
        'NormalizationMethod','Average power','AveragePower',1);
x = constellation(mod);
xN = length(x);
for row = 1:NTrain
    EsNo = (EsNo_high - EsNo_low)*rand + EsNo_low;
    P = 10^(EsNo/10);
    for col = 1:L
        a=unidrnd(xN);
        s = x(a);
        signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
        noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        %�õ�����ź�ѵ�����ͱ�ǩ 16qam
        labelData_qam16(row,col)= a-1;
        signalData_qam16(row,col)=signalData(row, col);
    end
end
cumulants = func_get_cumulants(signalData, noiseData);
for row = 1:NTrain
    for i = 1:NFeatures
        train_data(row + 2*NTrain, i) = cumulants(row, i);
    end
    train_data(row + 2*NTrain, NFeatures+1) = 2;
end
%csvwrite('train_modulation.csv', train_data);

%save train_demodulation_data_psk8 signalData_psk8;
%save train_demodulation_data_psk4 signalData_psk4;
save train_demodulation_data_qam16 signalData_qam16;
%save train_demodulation_label_psk8 labelData_psk8;
%save train_demodulation_label_psk4 labelData_psk4;
save train_demodulation_label_qam16 labelData_qam16;

%csvwrite('train_demodulation_data_psk8.csv', signalData_psk8);
%csvwrite('train_demodulation_data_psk4.csv', signalData_psk4);
%csvwrite('train_demodulation_data_qam16.csv', signalData_qam16);
%csvwrite('train_demodulation_label_psk8.csv', labelData_psk8);
%csvwrite('train_demodulation_label_psk4.csv', labelData_psk4);
%csvwrite('train_demodulation_label_qam16.csv', labelData_qam16);

