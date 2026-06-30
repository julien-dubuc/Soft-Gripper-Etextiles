clear;clc;
forces_str=["0","2","4","6","8","10","12","14","Max"];
forces_num=[0,2,4,6,8,10,12,14,NaN];
fprintf('STEP 5: DEFLECTION AND STIFFNESS RESULTS (N/mm)\n');
% Calculate reference position (Common zero)
valeurs_zero_C=[];
valeurs_zero_RP=[];
for t=1:3
    dc=get_distance(sprintf('C_F_%d_0.csv',t));
    drp=get_distance(sprintf('RP_F_%d_0.csv',t));
    if ~isnan(dc)&&dc>20.0,valeurs_zero_C=[valeurs_zero_C;dc];end
    if ~isnan(drp)&&drp>20.0,valeurs_zero_RP=[valeurs_zero_RP;drp];end
end
D0_C_commun=median(valeurs_zero_C,'omitnan');
if isnan(D0_C_commun),D0_C_commun=40.0;end
if isempty(valeurs_zero_RP)
    D0_RP_commun=D0_C_commun;
else
    D0_RP_commun=median(valeurs_zero_RP,'omitnan');
end
fprintf('COMPLIANT COMMON ZERO : %.2f mm\n',D0_C_commun);
fprintf('R&P COMMON ZERO       : %.2f mm\n',D0_RP_commun);
fprintf('%-8s | %-22s | %-6s | %-6s || %-22s | %-6s | %-6s\n','FORCE','R&P DEFLECTION (1,2,3)','AVG RP','k_rp','C DEFLECTION (1,2,3)','AVG C','k_c');
fprintf('----------------------------------------------------------------------------------------------------------\n');
% Calculate deflections by force and stiffness
for i=1:length(forces_str)
    F_str=forces_str(i);
    F_num=forces_num(i);
    def_RP=NaN(1,3);
    def_C=NaN(1,3);
    for t=1:3
        d_rp=get_distance(sprintf('RP_F_%d_%s.csv',t,F_str));
        if ~isnan(d_rp),def_RP(t)=abs(d_rp-D0_RP_commun);end
        d_c=get_distance(sprintf('C_F_%d_%s.csv',t,F_str));
        if ~isnan(d_c),def_C(t)=abs(d_c-D0_C_commun);end
    end
    if F_num==0,def_RP=[0 0 0];def_C=[0 0 0];end
    avg_RP=mean(def_RP,'omitnan');
    avg_C=mean(def_C,'omitnan');
    k_rp=F_num/avg_RP;
    k_c=F_num/avg_C;
    fprintf('%-8s | %s %s %s | %s | %s || %s %s %s | %s | %s\n',...
        F_str,fmt_c(def_RP(1)),fmt_c(def_RP(2)),fmt_c(def_RP(3)),fmt_c(avg_RP),fmt_c(k_rp),...
        fmt_c(def_C(1)),fmt_c(def_C(2)),fmt_c(def_C(3)),fmt_c(avg_C),fmt_c(k_c));
end
function str=fmt_c(v)
    if isnan(v),str='  --- ';else,str=sprintf('%6.2f',v);end
end
function dist=get_distance(nom_f)
    dist=NaN;
    if ~isfile(nom_f),return;end
    try
        data=readmatrix(nom_f,'NumHeaderLines',7);
        data(isnan(data(:,1)),:)=[];
        dist_all=[];
        for f=1:size(data,1)
            frame=data(f,3:end);
            pts=[];
            for k=1:3:length(frame)-2
                pt=frame(k:k+2);
                if ~any(isnan(pt)),pts=[pts;pt];end
            end
            % Geometric extraction via X-axis (depth)
            if ~isempty(pts)
                centre=median(pts,1);
                pts=pts(vecnorm(pts-centre,2,2)<150,:);
                if size(pts,1)>=2
                    [~,sort_X]=sort(pts(:,1));
                    dist_all=[dist_all;norm(pts(sort_X(1),:)-pts(sort_X(2),:))];
                end
            end
        end
        if ~isempty(dist_all),dist=median(dist_all);end
    catch
    end
end