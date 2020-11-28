%message用来检查信号是否正确，preamblePos则是检测前导码出现位置
%只支持ascii码的信息，因为设计的header只有一个字节，默认一个数据包字符串长度不超过255个字符
%当fsk编码两个数据包时能成功解读。
function [preamblePos,dataLength,message] = decodeFsk(fileName)
%通过音频文件名获得信号
[sig_carrier,fs] = audioread(fileName);
symbol_len = 480;

%查看输入音频信号图
figure(2);
plot(sig_carrier);

%载波
fc = 1000;
t = 0:1/fs:(length(sig_carrier) - 1)/fs;
carrier_wave = cos(2*pi*fc*t);
sig_rec = sig_carrier' .* carrier_wave;


%滤波
base_sig = [];
for i = 1:symbol_len:length(sig_rec)
    smb = sig_rec(i:i+symbol_len-1);
    hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,900,1100,fs),'butter');
    res = filter(hd,smb);
    base_sig = [base_sig, res];
end

%查看滤波后的音频图
figure(3);
plot(base_sig);

%解码
decode_datas = [];
thresh = 1;
for i = 1:symbol_len:length(base_sig)
    smb = base_sig(i:i+symbol_len-1);
    A = sum(abs(smb));
    if A > thresh
        decode_datas = [decode_datas, 1];
    else
        decode_datas = [decode_datas, 0];
    end
end

%判断前导码
%前导码
preamble = [1,0,1,0,1,0,1,1];
for i=1:3
    preamble = [preamble,preamble];
end

%找出前导码序列出现的位置
preamblePos = strfind(decode_datas,preamble);
dataLength = length(decode_datas);
%按照前导码出现的位置获取信息
message = [];
for i = 1:length(preamblePos)
    %已知前导码的位置，前导码后一个字节是header，可用来计算字符长度
    messageLength = bi2de(decode_datas(1,preamblePos(i) + length(preamble):preamblePos(i) + length(preamble) + 7));
    %通过前导码、header的位置确定字符串起始点，再按字符长度解出信息
    %已知ascii码最高位都是0，且考虑fsk中dec2bin生成的二进制矩阵，每列只有7位，所以j设计为增加7
    for j = preamblePos(i) + length(preamble) + 8:7:preamblePos(i) + length(preamble) + 7 + 7*messageLength
        mes = bi2de(decode_datas(1,j:j+6));
        message = [message,char(mes)];
    end
end

end

