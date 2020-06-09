
%MODULATION_TRAIN 此处显示有关此函数的摘要
%   生成QPSK 16QAM 8PSK的调制后的数字基带信号 并且提取出高阶累积量 做调制识别和解调的训练集并且打上标签
clear
clc
%% init
% 定义复数
j = sqrt(-1);
% 每个类型的信号的序列数目
NTrain = 10000;
%信号最低的snr
EsNo_low = 20;
%信号最高的snr
EsNo_high = 50;
%每一个序列包含的码元数目
L = 100;
%信号的类型个数
NClass = 3;
%高阶累积量的个数
NFeatures = 9;
train_data = zeros(NClass * NTrain, NFeatures + 1);
%% get train data

% psk8 训练集的产生
%定义信号数组
signalData = zeros(NTrain, L);
signalData_psk8 = zeros(NTrain, L);
%定义噪声数组
noiseData = zeros(NTrain, L);
%定义码元数组
labelData_psk8 = zeros(NTrain, L);
%定义8PSK发生器用matlab信号工具箱
mod = comm.PSKModulator('ModulationOrder',8,'PhaseOffset',0);
%获取星座形式的 复数的码元发生器
x = constellation(mod);
%获取当前进制
xN = length(x);
%开始循环生成训练集
%这里生成的训练集是服从信噪比-10db到20db均匀分布的
for row = 1:NTrain
    EsNo = (EsNo_high - EsNo_low)*rand + EsNo_low;
    P = 10^(EsNo/10);
    for col = 1:L
        %产生随机码元并且8psk调制得到复数表示
        a=unidrnd(xN);
        s = x(a);
        %计算出数字基带信号表达式并且通过加性高斯白噪声信道AWGN
        signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
        %得到解调信号训练集和标签 8psk
        labelData_psk8(row,col)= a-1;
        signalData_psk8(row,col)=signalData(row, col);
        %随机得到噪声序列
        noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
    end
end
%计算所有8PSK信号的高阶累积量 计算公式见吴添的论文第三章
cumulants = func_get_cumulants(signalData, noiseData);
for row = 1:NTrain
    for i = 1:NFeatures
        train_data(row, i) = cumulants(row, i);
    end
    %给QPSK调制的类型打上标签 0代表8PSK 1代表QPSK 2代表16QAM
    train_data(row, NFeatures+1) = 0;
end

% qpsk
disp('qpsk begin');
%定义qpsk信号数组
signalData = zeros(NTrain, L);
signalData_psk4 = zeros(NTrain, L);
%定义qpsk噪声数组
noiseData = zeros(NTrain, L);
%定义码元数组
labelData_psk4 = zeros(NTrain, L);
%定义qpsk发生器用matlab信号工具箱
mod = comm.PSKModulator('ModulationOrder',4,'PhaseOffset',0);
%获取星座形式的 复数的码元发生器
x = constellation(mod);
%获取当前进制
xN = length(x);
%开始循环生成训练集
%这里生成的训练集是服从信噪比-10db到20db均匀分布的
for row = 1:NTrain
    EsNo = (EsNo_high - EsNo_low)*rand + EsNo_low;
    %功率计算
    P = 10^(EsNo/10);
    for col = 1:L
        %产生随机码元并且Qpsk调制得到复数表示
        a=unidrnd(xN);
        s = x(a);
        %计算出数字基带信号表达式并且通过加性高斯白噪声信道AWGN
        signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
        %得到4psk解调信号训练集和标签 
        labelData_psk4(row,col)= a-1;
        signalData_psk4(row,col)=signalData(row, col);
        %随机得到噪声序列
        noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
    end
end
%计算所有QPSK信号的高阶累积量 计算公式见吴添的论文第三章
cumulants = func_get_cumulants(signalData, noiseData);
for row = 1:NTrain
     for i = 1:NFeatures
        train_data(row+NTrain, i) = cumulants(row, i);
     end
     %给QPSK调制的类型打上标签 0代表8PSK 1代表QPSK 2代表16QAM
     train_data(row+NTrain, NFeatures+1) = 1;
end

% qam16 调制过程与上面类似
signalData = zeros(NTrain, L);
signalData_qam16 = zeros(NTrain, L);

noiseData = zeros(NTrain, L);
%定义码元数组
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
        %得到解调信号训练集和标签 16qam
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

