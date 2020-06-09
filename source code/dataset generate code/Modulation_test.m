clear
clc
%随机生成测试集的代码 测试集包括了 调制识别和解调之前的基带信号 正例标签为调制识别的正确结果和解调后的正确结果
%测试集包括输入了高阶累积量还有原始的信号，根据高阶累积量进行调试识别，识别出类型后进行解调
%这里测试集是从-10DB 到20DB按照步长为2生成不同SNR的三种8psk QPSK 16QAM的信号
%% init
j = sqrt(-1);
NTest = 100;
EsNo_low = 20;
EsNo_high = 44;
gap = 2;
L = 100;
NClass = 3;
NFeatures = 9;
%根据信号snr的不同生成测试集，snr的范围向量如下
EsNo_array = EsNo_low:gap:EsNo_high;
%调制识别AI模型测试集 总体高阶累积量
test_data = zeros(length(EsNo_array) * NClass * NTest, NFeatures + 2);
%总体端到端系统测试集
test_data_demodulation = zeros(length(EsNo_array) * NClass * NTest, L+1 );
test_label_demodulation = zeros(length(EsNo_array) * NClass * NTest, L );

%8psk 解调模型测试集合
test_data_demodulation_psk8 = zeros(length(EsNo_array) * NTest, L+1 );
test_label_demodulation_psk8= zeros(length(EsNo_array) * NTest, L );
test_cumulant_psk8= zeros(length(EsNo_array)* NTest, NFeatures);
%4psk 解调模型测试集
test_data_demodulation_psk4= zeros(length(EsNo_array)  * NTest, L+1 );
test_label_demodulation_psk4= zeros(length(EsNo_array) * NTest, L );
test_cumulant_psk4= zeros(length(EsNo_array)* NTest, NFeatures);
%16qam解调模型测试集
test_data_demodulation_qam16 = zeros(length(EsNo_array)  * NTest, L+1 );
test_label_demodulation_qam16 = zeros(length(EsNo_array) * NTest, L );
test_cumulant_qam16= zeros(length(EsNo_array)* NTest, NFeatures);
%% get test data
for idx = 1:length(EsNo_array)
    EsNo = EsNo_array(idx);
    P = 10^(EsNo/10);

    % psk8测试集
    signalData = zeros(NTest, L);
    signalData_psk8 = zeros(NTest, L);
    labelData_psk8 = zeros(NTest, L);
    noiseData = zeros(NTest, L);
    mod = comm.PSKModulator('ModulationOrder',8,'PhaseOffset',0);
    x = constellation(mod);
    xN = length(x);
    for row = 1:NTest
        for col = 1:L
            a=unidrnd(xN);
            s = x(a);
            signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
            %得到解调信号测试集和标签 8psk
            labelData_psk8(row,col)= a-1;
            signalData_psk8(row,col)=signalData(row, col);
            noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        end
    end
    %得到测试集的高阶累积量并且打上标签类型
    cumulants = func_get_cumulants(signalData, noiseData);
    for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+row;
        for i = 1:NFeatures
            test_data(row_r, i) = cumulants(row, i);
        end
        test_data(row_r, NFeatures+1) = 0;
        test_data(row_r, NFeatures+2) = EsNo;
        %得到8psk的高阶累积量
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_psk8(row_s, i) = cumulants(row, i);
        end
    end
    %得到测试集的信号数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_psk8(row, i);
        end
        test_data_demodulation(row_r, L+1) = EsNo;
        %得到单独的8psk的测试集 行数
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_psk8(row_s, i) = signalData_psk8(row, i);
        end
        test_data_demodulation_psk8(row_s, L+1) = EsNo;
     end
    %得到测试集的标签数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+row;
        for i = 1:L
            test_label_demodulation(row_r, i) = labelData_psk8(row, i);
        end
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_label_demodulation_psk8(row_s, i) = labelData_psk8(row, i);
        end
    end
    %qpsk
    signalData = zeros(NTest, L);
    signalData_psk4 = zeros(NTest, L);
    labelData_psk4 = zeros(NTest, L);
    noiseData = zeros(NTest, L);
    mod = comm.PSKModulator('ModulationOrder',4,'PhaseOffset',0);
    x = constellation(mod);
    xN = length(x);
    for row = 1:NTest
        for col = 1:L
            a=unidrnd(xN);
            s = x(a);
            signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
            %得到解调信号测试集和标签 4psk
            labelData_psk4(row,col)= a-1;
            signalData_psk4(row,col)=signalData(row, col);
            noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        end
    end
    %得到测试集的高阶累积量并且打上标签类型
    cumulants = func_get_cumulants(signalData, noiseData);
    for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+NTest+row;
        for i = 1:NFeatures
            test_data(row_r, i) = cumulants(row, i);
        end
        test_data(row_r, NFeatures+1) = 1;
        test_data(row_r, NFeatures+2) = EsNo;
        %得到4psk的高阶累积量
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_psk4(row_s, i) = cumulants(row, i);
        end
    end
    %得到测试集的信号数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_psk4(row, i);
        end
         test_data_demodulation(row_r, L+1) = EsNo;
        %得到单独的4psk的测试集 行数
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_psk4(row_s, i) = signalData_psk4(row, i);
        end
        test_data_demodulation_psk4(row_s, L+1) = EsNo;
     end
    %得到测试集的标签数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+NTest+row;
        for i = 1:L
            test_label_demodulation(row_r, i) = labelData_psk4(row, i);
        end
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_label_demodulation_psk4(row_s, i) = labelData_psk4(row, i);
        end
    end
    
    % qam16
    signalData = zeros(NTest, L);
    signalData_qam16 = zeros(NTest, L);
    labelData_qam16 = zeros(NTest, L);
    noiseData = zeros(NTest, L);
    mod = comm.RectangularQAMModulator('ModulationOrder',16,...
        'NormalizationMethod','Average power','AveragePower',1);
    x = constellation(mod);
    xN = length(x);
    for row = 1:NTest
        for col = 1:L
            a=unidrnd(xN);
            s = x(a);
            signalData(row, col) = sqrt(P)*s + sqrt(1/2)*(randn+j*randn);
            %得到解调信号测试集和标签 16QAM
            labelData_qam16(row,col)= a-1;
            signalData_qam16(row,col)=signalData(row, col);
            noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        end
    end
    cumulants = func_get_cumulants(signalData, noiseData);
    for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+2*NTest+row;
        for i = 1:NFeatures
            test_data(row_r, i) = cumulants(row, i);
        end
        test_data(row_r, NFeatures+1) = 2;
        test_data(row_r, NFeatures+2) = EsNo;
        %得到16qam的高阶累积量
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_qam16(row_s, i) = cumulants(row, i);
        end
    end
     %得到测试集的信号数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+2*NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_qam16(row, i);
        end
        test_data_demodulation(row_r, L+1) = EsNo;
        %得到单独的16qam的测试集 行数
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_qam16(row_s, i) = signalData_qam16(row, i);
        end
        test_data_demodulation_qam16(row_s, L+1) = EsNo;
     end
    %得到测试集的标签数据
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+2*NTest+row;
        for i = 1:L
            test_label_demodulation(row_r, i) = labelData_qam16(row, i);
        end
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_label_demodulation_qam16(row_s, i) = labelData_qam16(row, i);
        end
    end
    
    
end

%csvwrite('test_cumulant.csv', test_data);
%save test_data_demodulation test_data_demodulation;
%save test_label_demodulation test_label_demodulation;

%save test_data_demodulation_psk8 test_data_demodulation_psk8;
%save test_label_demodulation_psk8 test_label_demodulation_psk8;
%csvwrite('test_cumulant_psk8.csv', test_cumulant_psk8);

save test_data_demodulation_qam16 test_data_demodulation_qam16;
save test_label_demodulation_qam16 test_label_demodulation_qam16;
csvwrite('test_cumulant_qam16.csv', test_cumulant_qam16);

%save test_data_demodulation_psk4 test_data_demodulation_psk4;
%save test_label_demodulation_psk4 test_label_demodulation_psk4;
%csvwrite('test_cumulant_psk4.csv', test_cumulant_psk4);
%csvwrite('test_data_demodulation.csv', test_data_demodulation);
%csvwrite('test_label_demodulation.csv', test_label_demodulation);

