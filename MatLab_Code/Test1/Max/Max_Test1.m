clear;clc;
fichiers={'Max_opening_R&P_000.csv';'Max_opening_C.csv';};
fprintf('   STEP 1 : MAX OPENING AND MIN CLOSING\n');
fprintf('%-30s | %-15s | %-15s\n','FILE','OPENING','STATUT');
fprintf('-----------------------------------------------------------------\n');
for i=1:length(fichiers)
    nom_f=fichiers{i};
    if ~isfile(nom_f),continue;end
    data=readmatrix(nom_f,'NumHeaderLines',7);
    data(isnan(data(:,1)),:)=[];
    dist_all=[];
    
    for f=1:size(data,1)
        frame=data(f,3:end);
        % Extract valid markers
        pts=[];
        for k=1:3:length(frame)-2
            pt=frame(k:k+2);
            if ~any(isnan(pt)),pts=[pts;pt];end
        end
        if ~isempty(pts)
            % Filter ghosts (distance from center < 200mm)
            centre=median(pts,1);
            pts=pts(vecnorm(pts-centre,2,2)<200,:); 
            
            % Check for finger fusion
            if size(pts,1)<6
                dist_all=[dist_all;0.00];
            else
                % Use X-axis topology to find fingertips
                [~,sort_X]=sort(pts(:,1));
                doigt_1=pts(sort_X(1),:);
                doigt_2=pts(sort_X(2),:);
                d=norm(doigt_1-doigt_2);
                if d<12.0
                    d=0.00;
                end
                dist_all=[dist_all;d];
            end
        end
    end
    % Calculate median result
    res=0.00;
    statut="Closed/Contact";
    if ~isempty(dist_all)
        res=median(dist_all);
        if res>5.0
            statut="Open";
        end
    end
    
    fprintf('%-30s | %6.2f mm      | %-15s\n',nom_f,res,statut);
end