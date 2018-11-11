function [Q] = QFactor(Rx_eff, Tx_eff_Meff)
% ����˵����
% 1. �ʺ�QAM���Ƶ�Qֵ����
% 2. �����յ��ľ������·���Ϊ2^Meff x N�ľ���
% 3. ��Tx_eff_MeffΪ����ʱ�������������Ի�����Ĺ��ƣ�������ϵͳ����
%    ��ʱ�����Tx_eff_Meff����Ӧ��Ϊ���������

% -------------------------------------------------------------------

if size(Tx_eff_Meff,1)*size(Tx_eff_Meff,2) > 1
    Tx_eff = Tx_eff_Meff;
    q = sqrt(size(Rx_eff,1)*size(Rx_eff,2))/sqrt(sum(sum(abs ...
        (Rx_eff - Tx_eff).^2./(abs(Tx_eff).^2))));
    Q = 20*log10(q);
else
    Meff = Tx_eff_Meff;
    [Rx_rows, Rx_cols] = size(Rx_eff);
    Rx_eff = reshape(Rx_eff, 1, Rx_rows*Rx_cols);
    %--------------------------------------------------------------%
    thread = -2^(Meff/2)+2:2:2^(Meff/2)-2;
    D_temp = 0;
    k = length(thread);
    for m = 1:k;
        [rows_r,cols_r] = find(real(Rx_eff) <= thread(m));
        temp_r = Rx_eff(:,cols_r);
        Rx_eff(:,cols_r) = [];
        for n = 1:k
            [rows_i,cols_i] = find(imag(temp_r) <= thread(n));
            temp_i = temp_r(:,cols_i);
            C_avg_temp = mean(temp_i);
            D_temp = D_temp + ...
                sum((abs(temp_i - C_avg_temp)).^2/(abs(C_avg_temp))^2);
            temp_r(:,cols_i) = [];
        end
        C_avg_temp = mean(temp_r);
        D_temp = D_temp + ...
            sum((abs(temp_r - C_avg_temp)).^2/(abs(C_avg_temp))^2);
    end
    for n = 1:k
        [rows_i,cols_i] = find(imag(Rx_eff) <= thread(n));
        temp_i = Rx_eff(:,cols_i);
        C_avg_temp = mean(temp_i);
        D_temp = D_temp + ...
            sum((abs(temp_i - C_avg_temp)).^2/(abs(C_avg_temp))^2);
        Rx_eff(:,cols_i) = [];
    end
    C_avg_temp = mean(Rx_eff);
    D_temp = D_temp + ...
        sum((abs(Rx_eff - C_avg_temp)).^2/(abs(C_avg_temp))^2);
    D_temp = sqrt(D_temp);
    %--------------------------------------------------------------%
    q = sqrt(Rx_rows*Rx_cols)/D_temp;
    Q = 20*log10(q);
end