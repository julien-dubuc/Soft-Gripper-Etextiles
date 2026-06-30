clear;clc;close all;
% DATA Trial 1 - Time in ms, Force in N
% RACK & PINION DATA (Trial 1)
data_rp=[
    1,0.00;63,0.00;155,-0.00;248,-0.00;340,-0.00;433,0.00;526,0.00;
    619,0.00;711,0.00;804,0.00;896,0.00;989,-0.00;1082,-0.00;1175,0.00;
    1268,0.00;1360,0.00;1453,0.07;1545,0.41;1638,0.86;1731,1.30;1823,1.70;
    1916,2.05;2008,2.39;2101,2.70;2194,3.03;2286,3.32;2378,3.58;2471,3.64;
    2563,3.61;2656,3.62;2749,3.62;2841,3.61;2933,3.60;3026,3.59;3118,3.59;
    3211,3.58;3304,3.58;3396,3.58;3488,3.57;3581,3.57;3673,3.56;3766,3.56;
    3858,3.56;3951,3.56;4043,3.55;4135,3.55;4228,3.55;4321,3.55;4413,3.54;
    4506,3.54;4598,3.54;4690,3.54;4782,3.53;4876,3.54;4968,3.53;5060,3.53;
    5153,3.53;5245,3.53;5337,3.53;5431,3.53;5523,3.53;5615,3.52;5707,3.52;
    5800,3.52;5892,3.52;5985,3.52;6078,3.52;6170,3.51;6262,3.51;6355,3.51;
    6447,3.51;6540,3.50;6633,3.51;6725,3.51;6817,3.50;6909,3.50;7002,3.50;
    7095,3.50;7187,3.50;7280,3.54;7372,3.90;7465,4.15;7557,4.04;7651,3.93;
    7743,3.90;7836,3.86;7928,3.86;8021,3.88;8113,3.86;8207,3.77;8299,2.91;
    8392,1.43;8484,1.26;8577,1.33;8669,1.34;8763,0.94;8855,0.49;8948,0.27;
    9040,0.10;9132,0.02
];
%COMPLIANT DATA (Trial 1)
data_compliant=[
    1,0.00;52,0.00;137,-0.00;229,-0.00;322,-0.01;414,-0.00;507,-0.01;
    599,-0.00;693,0.00;785,0.00;878,-0.00;970,-0.00;1063,-0.00;1155,0.00;
    1248,0.00;1341,0.00;1433,0.00;1526,0.14;1618,0.80;1710,1.68;1804,2.50;
    1896,3.28;1988,4.00;2081,4.65;2173,5.26;2265,5.82;2359,6.35;2451,6.84;
    2543,7.30;2635,7.72;2728,8.11;2820,8.46;2913,8.76;3005,9.00;3098,9.07;
    3190,9.05;3282,9.04;3374,9.03;3467,9.02;3560,9.01;3652,9.00;3744,9.00;
    3836,9.00;3929,8.99;4022,8.98;4114,8.97;4206,8.97;4299,8.97;4391,8.96;
    4483,8.96;4576,8.95;4669,8.95;4761,8.95;4853,8.95;4945,8.94;5038,8.94;
    5131,8.93;5223,8.93;5315,8.93;5407,8.93;5500,8.92;5592,8.92;5685,8.92;
    5777,8.92;5870,8.92;5962,8.91;6054,8.91;6146,8.91;6239,8.91;6332,8.90;
    6424,8.90;6516,8.90;6608,8.90;6700,8.89;6794,8.89;6886,8.89;6978,8.89;
    7070,8.89;7162,8.89;7255,8.88;7348,8.72;7441,7.87;7533,6.63;7625,5.47;
    7718,4.40;7810,3.38;7904,2.36;7996,1.39;8088,0.51;8181,0.05;8273,0.00;
    8366,-0.00;8459,0.00;8552,0.00;8644,0.00;8737,0.00;8829,-0.00;8922,-0.00;
    9015,0.00;9108,0.00
];
%Convert time to seconds
t_rp=data_rp(:,1)/1000;
f_rp=data_rp(:,2);
t_compliant=data_compliant(:,1)/1000;
f_compliant=data_compliant(:,2);
%VIDEO ANCHOR POINTS (Time vs. Current)
% Anchor points (seconds)
t_anchors_rp=[0,1,2,3,4,5,6,7,8,9,9.15];
t_anchors_comp=[0,1,2,3,4,5,6,7,8,9,9.11];
% Actual readings from video (Trial 1)
i_rp_values=[0,0.124,0.262,0.371,0.368,0.365,0.358,0.362,0.082,0.204,0];
i_comp_values=[0,0.068,0.228,0.362,0.362,0.361,0.360,0.358,0.101,0.095,0];
% Interpolation
current_rp=interp1(t_anchors_rp,i_rp_values,t_rp,'pchip');
current_compliant=interp1(t_anchors_comp,i_comp_values,t_compliant,'pchip');
%DUAL-AXIS PLOTTING
figure('Color',[1 1 1],'Position',[100,100,850,500]);
hold on;grid on;
set(gca,'FontSize',11,'LineWidth',1,'GridLineStyle',':');
% LEFT AXIS: GRASPING FORCE (N)
yyaxis left
p1=plot(t_compliant,f_compliant,'b-','LineWidth',2.5);
p2=plot(t_rp,f_rp,'r-','LineWidth',2.5);
ylabel('Grasping Force (N)','FontSize',12,'FontWeight','bold','Color','k');
ylim([-0.5 11]);
ax=gca;
ax.YColor=[0 0 0];
% RIGHT AXIS: MOTOR CURRENT (A)
yyaxis right
p3=plot(t_compliant,current_compliant,'b--','LineWidth',2.0);
p4=plot(t_rp,current_rp,'r--','LineWidth',2.0);
ylabel('Motor Current (A)','FontSize',12,'FontWeight','bold','Color',[0.3 0.3 0.3]);
ylim([0 0.5]);
ax.YColor=[0.3 0.3 0.3];
% LABELS 
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
title('Dynamic Grasping Profile','FontSize',13,'FontWeight','bold');
xlim([0 9.2]);
% PHASE DELIMITATION LINES
xline(2.0,'k:','LineWidth',1.2,'HandleVisibility','off');
xline(7.1,'k:','LineWidth',1.2,'HandleVisibility','off');
text(1.0,10.2,'PHASE 1: Closing','FontSize',9,'FontWeight','bold','HorizontalAlignment','center');
text(4.5,10.2,'PHASE 2: Active Holding','FontSize',9,'FontWeight','bold','HorizontalAlignment','center');
text(8.1,10.2,'PHASE 3: Opening','FontSize',9,'FontWeight','bold','HorizontalAlignment','center');
%LEGEND CONTROL
legend([p1,p2,p3,p4],...
       {'Force: Compliant','Force: Rack & Pinion','Current: Compliant','Current: Rack & Pinion'},...
       'Location','northwest','Box','on');