function [datas] = fsk(fileName,message)
%将字符串转二进制字符串序列
originM = dec2bin(message,7);
%将二进制字符串转二进制数组，并用fliplr翻转，因为使用bi2de二进制转字符串时与生成二进制的01序列是反向的
datas = fliplr(double(originM) - '0');

%生成0，1两种信号符
fs = 48000;
fm = 1000;
Am = 1;
symbol_len = 480;
t = (0:1/fs:(symbol_len - 1)/fs);
smb1 = Am*cos(2*pi*fm*t);
smb0 = zeros(1,symbol_len);
sig = [];

%前导码，preamble_order
preamble = [];
preamble_order = [1,0,1,0,1,0,1,1];
for i = 1:length(preamble_order)
    if preamble_order(i) == 0
        preamble = [preamble,smb0];
    else
        preamble = [preamble,smb1];
    end
end

for i=1:3
    preamble = [preamble,preamble];
end

%header, 主要是数据长度，加不加序列号还未定，1个字节
header = length(message);
header = dec2bin(header,8);
header = fliplr(double(header) - '0');

header_code = [];
for i = 1:8
    if header(i) == 0
        header_code = [header_code,smb0];
    else
        header_code = [header_code,smb1];
    end
end

%生成01序列
[r,c] = size(datas);
for i = 1:r
    for j = 1:c
        if datas(i,j) == 0
            sig = [sig,smb0];
        else
            sig = [sig,smb1];
        end
    end
end

sig = [preamble,header_code,sig];

%载波
fc = 1000;
t = 0:1/fs:(length(sig) - 1)/fs;
carrier_wave = cos(2*pi*fc*t);
sig_carrier = sig.*carrier_wave;
figure(1);
plot(sig_carrier);

audiowrite([fileName,'.wav'],sig_carrier,fs);
end

