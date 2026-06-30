actuation=0:10:100;
C_close=[0.00,3.61,9.03,15.46,21.19,28.15,37.17,46.69,58.77,67.05,73.93];
C_open=[0.00,14.16,22.45,32.29,44.07,52.73,60.43,65.46,69.23,71.94,74.26];
RP_open=[0.00,18.04,31.20,49.22,67.53,82.74,100.48,113.84,124.61,135.11,143.31];
RP_close=[0.00,18.25,33.51,51.14,68.56,86.81,103.04,116.87,129.79,138.94,144.12];

figure('Color','w','Units','normalized','Position',[0.1 0.1 0.6 0.6]);
plot(actuation,C_open,'b-o','LineWidth',1.5,'DisplayName','Compliant (Opening)');
hold on;
plot(actuation,C_close,'b--s','LineWidth',1.5,'DisplayName','Compliant (Closing)');
plot(actuation,RP_open,'r-o','LineWidth',1.5,'DisplayName','R&P (Opening)');
plot(actuation,RP_close,'r--s','LineWidth',1.5,'DisplayName','R&P (Closing)');
grid on;

xlabel('Actuation (%)','FontSize',12,'Interpreter','latex');
ylabel('Finger Gap (mm)','FontSize',12,'Interpreter','latex');
title('Kinematic Hysteresis Comparison','FontSize',14,'Interpreter','latex');
legend('Location','northwest','Interpreter','latex');
set(gca,'FontSize',11,'TickLabelInterpreter','latex');

print('hysteresis_graph','-dpng','-r300');