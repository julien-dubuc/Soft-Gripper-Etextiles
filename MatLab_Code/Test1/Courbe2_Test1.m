F_C=[0,2,4,6,8,10,12,14,17.60]; %Force
F_RP=[0,2,4,6,6.93];
D_C=[0,9.51,10.82,11.90,13.28,13.98,14.96,15.93,16.71]; % Deflection
D_RP=[0,40.20,40.96,41.66,42.09];

figure('Color','w','Units','normalized','Position',[0.1 0.1 0.6 0.6]);
plot(F_C,D_C,'b-o','LineWidth',2,'DisplayName','Compliant Gripper');
hold on;
plot(F_RP,D_RP,'r-s','LineWidth',2,'DisplayName','R\&P Gripper');
grid on;

xlabel('Applied Force (N)','FontSize',12,'Interpreter','latex');
ylabel('Finger Deflection (mm)','FontSize',12,'Interpreter','latex');
title('Effective Compliance','FontSize',14,'Interpreter','latex');
legend('Location','southeast','Interpreter','latex');
set(gca,'FontSize',11,'TickLabelInterpreter','latex');

print('stiffness_graph','-dpng','-r300');