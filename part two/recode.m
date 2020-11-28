function [] = recode(fileName,seconds)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
recObj = audiorecorder(48000,16,1);
disp('Start recording.');
recordblocking(recObj, seconds);
disp('End of Recording.');
% 回放录音数据
%play(recObj);
% 获取录音数据
myRecording = getaudiodata(recObj);
% 绘制录音数据波形
plot(myRecording);
filename = [fileName,'.wav']; 
audiowrite(filename,myRecording,48000);
end

