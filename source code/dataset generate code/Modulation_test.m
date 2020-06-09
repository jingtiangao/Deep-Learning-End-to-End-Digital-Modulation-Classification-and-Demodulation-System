clear
clc
%������ɲ��Լ��Ĵ��� ���Լ������� ����ʶ��ͽ��֮ǰ�Ļ����ź� ������ǩΪ����ʶ�����ȷ����ͽ�������ȷ���
%���Լ����������˸߽��ۻ�������ԭʼ���źţ����ݸ߽��ۻ������е���ʶ��ʶ������ͺ���н��
%������Լ��Ǵ�-10DB ��20DB���ղ���Ϊ2���ɲ�ͬSNR������8psk QPSK 16QAM���ź�
%% init
j = sqrt(-1);
NTest = 100;
EsNo_low = 20;
EsNo_high = 44;
gap = 2;
L = 100;
NClass = 3;
NFeatures = 9;
%�����ź�snr�Ĳ�ͬ���ɲ��Լ���snr�ķ�Χ��������
EsNo_array = EsNo_low:gap:EsNo_high;
%����ʶ��AIģ�Ͳ��Լ� ����߽��ۻ���
test_data = zeros(length(EsNo_array) * NClass * NTest, NFeatures + 2);
%����˵���ϵͳ���Լ�
test_data_demodulation = zeros(length(EsNo_array) * NClass * NTest, L+1 );
test_label_demodulation = zeros(length(EsNo_array) * NClass * NTest, L );

%8psk ���ģ�Ͳ��Լ���
test_data_demodulation_psk8 = zeros(length(EsNo_array) * NTest, L+1 );
test_label_demodulation_psk8= zeros(length(EsNo_array) * NTest, L );
test_cumulant_psk8= zeros(length(EsNo_array)* NTest, NFeatures);
%4psk ���ģ�Ͳ��Լ�
test_data_demodulation_psk4= zeros(length(EsNo_array)  * NTest, L+1 );
test_label_demodulation_psk4= zeros(length(EsNo_array) * NTest, L );
test_cumulant_psk4= zeros(length(EsNo_array)* NTest, NFeatures);
%16qam���ģ�Ͳ��Լ�
test_data_demodulation_qam16 = zeros(length(EsNo_array)  * NTest, L+1 );
test_label_demodulation_qam16 = zeros(length(EsNo_array) * NTest, L );
test_cumulant_qam16= zeros(length(EsNo_array)* NTest, NFeatures);
%% get test data
for idx = 1:length(EsNo_array)
    EsNo = EsNo_array(idx);
    P = 10^(EsNo/10);

    % psk8���Լ�
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
            %�õ�����źŲ��Լ��ͱ�ǩ 8psk
            labelData_psk8(row,col)= a-1;
            signalData_psk8(row,col)=signalData(row, col);
            noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        end
    end
    %�õ����Լ��ĸ߽��ۻ������Ҵ��ϱ�ǩ����
    cumulants = func_get_cumulants(signalData, noiseData);
    for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+row;
        for i = 1:NFeatures
            test_data(row_r, i) = cumulants(row, i);
        end
        test_data(row_r, NFeatures+1) = 0;
        test_data(row_r, NFeatures+2) = EsNo;
        %�õ�8psk�ĸ߽��ۻ���
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_psk8(row_s, i) = cumulants(row, i);
        end
    end
    %�õ����Լ����ź�����
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_psk8(row, i);
        end
        test_data_demodulation(row_r, L+1) = EsNo;
        %�õ�������8psk�Ĳ��Լ� ����
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_psk8(row_s, i) = signalData_psk8(row, i);
        end
        test_data_demodulation_psk8(row_s, L+1) = EsNo;
     end
    %�õ����Լ��ı�ǩ����
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
            %�õ�����źŲ��Լ��ͱ�ǩ 4psk
            labelData_psk4(row,col)= a-1;
            signalData_psk4(row,col)=signalData(row, col);
            noiseData(row, col) = sqrt(1/2)*(randn+j*randn);
        end
    end
    %�õ����Լ��ĸ߽��ۻ������Ҵ��ϱ�ǩ����
    cumulants = func_get_cumulants(signalData, noiseData);
    for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+NTest+row;
        for i = 1:NFeatures
            test_data(row_r, i) = cumulants(row, i);
        end
        test_data(row_r, NFeatures+1) = 1;
        test_data(row_r, NFeatures+2) = EsNo;
        %�õ�4psk�ĸ߽��ۻ���
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_psk4(row_s, i) = cumulants(row, i);
        end
    end
    %�õ����Լ����ź�����
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_psk4(row, i);
        end
         test_data_demodulation(row_r, L+1) = EsNo;
        %�õ�������4psk�Ĳ��Լ� ����
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_psk4(row_s, i) = signalData_psk4(row, i);
        end
        test_data_demodulation_psk4(row_s, L+1) = EsNo;
     end
    %�õ����Լ��ı�ǩ����
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
            %�õ�����źŲ��Լ��ͱ�ǩ 16QAM
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
        %�õ�16qam�ĸ߽��ۻ���
        row_s = (idx-1)*NTest+row;
        for i = 1:NFeatures
            test_cumulant_qam16(row_s, i) = cumulants(row, i);
        end
    end
     %�õ����Լ����ź�����
     for row = 1:NTest
        row_r = (idx-1)*NClass*NTest+2*NTest+row;
        for i = 1:L
            test_data_demodulation(row_r, i) = signalData_qam16(row, i);
        end
        test_data_demodulation(row_r, L+1) = EsNo;
        %�õ�������16qam�Ĳ��Լ� ����
        row_s = (idx-1)*NTest+row;
        for i = 1:L
            test_data_demodulation_qam16(row_s, i) = signalData_qam16(row, i);
        end
        test_data_demodulation_qam16(row_s, L+1) = EsNo;
     end
    %�õ����Լ��ı�ǩ����
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

