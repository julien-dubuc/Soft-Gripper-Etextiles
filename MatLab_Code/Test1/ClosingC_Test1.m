clear;clc;
files=dir('C_C_3_*.csv');
if isempty(files)
    fprintf('No files found\n');return;
end
% Sort increments in descending order (100% -> 0%)
increments=zeros(length(files),1);
for i=1:length(files)
    num=regexp(files(i).name,'\d+','match');
    increments(i)=str2double(num{end});
end
[~,sort_idx]=sort(increments,'descend');
files=files(sort_idx);
fprintf('   STEP 4: COMPLIANT CLOSING (INCREMENTS 100%% -> 0%%)\n');
fprintf('%-15s | %-15s | %-15s\n','FILE','OPENING','STATUS');
fprintf('-------------------------------------------------------\n');
for i=1:length(files)
    nom_f=files(i).name;
    data=readmatrix(nom_f,'NumHeaderLines',7);
    data(isnan(data(:,1)),:)=[];
    dist_geom_all=[];
    for f=1:size(data,1)
        frame=data(f,3:end);
        % Extract valid points
        pts=[];
        for k=1:3:length(frame)-2
            pt=frame(k:k+2);
            if ~any(isnan(pt)),pts=[pts;pt];end
        end
        dist_geom=NaN;
        if ~isempty(pts)
            % Filter reflections (ghosts)
            centre=median(pts,1);
            pts=pts(vecnorm(pts-centre,2,2)<150,:);
            % Validate structure (7 markers expected)
            if size(pts,1)<7
                dist_geom=0.00;
            else
                % Calculation via fingers (smallest X)
                [~,sort_X]=sort(pts(:,1));
                doigt_1=pts(sort_X(1),:);
                doigt_2=pts(sort_X(2),:);
                dist_geom=norm(doigt_1-doigt_2);
                if dist_geom<12.0,dist_geom=0.00;end
            end
        end
        if ~isnan(dist_geom),dist_geom_all=[dist_geom_all;dist_geom];end
    end
    % Calculate median result per file
    res_geom=0.00;status="Closed/Contact";
    if ~isempty(dist_geom_all)
        res_geom=median(dist_geom_all);
        if res_geom>5.0,status="Open";end
    end
    fprintf('%-15s | %6.2f mm      | %-15s\n',nom_f,res_geom,status);
end