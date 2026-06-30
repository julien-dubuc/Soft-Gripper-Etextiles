clear;clc;
files=dir('RP_C_3_*.csv');
if isempty(files)
    fprintf('No RP_C_3_*.csv files found.\n');return;
end
% Numerical sort (100% -> 0%)
increments=zeros(length(files),1);
for i=1:length(files)
    num=regexp(files(i).name,'\d+','match');
    increments(i)=str2double(num{end});
end
[~,sort_idx]=sort(increments,'descend');
files=files(sort_idx);
fprintf('   STEP 1: R&P CLOSING (INCREMENTS 100%% -> 0%%)\n');
fprintf('%-15s | %-15s | %-15s\n','FILE','OPENING','STATUS');
fprintf('-------------------------------------------------------\n');
for i=1:length(files)
    nom_f=files(i).name;
    
    data=readmatrix(nom_f,'NumHeaderLines',7);
    data(isnan(data(:,1)),:)=[];
    
    dist_geom_all=[];
    
    for f=1:size(data,1)
        frame=data(f,3:end);
        
        %X-AXIS GEOMETRY (Depth)
        pts=[];
        for k=1:3:length(frame)-2
            pt=frame(k:k+2);
            if ~any(isnan(pt)),pts=[pts;pt];end
        end
        
        dist_geom=NaN;
        if ~isempty(pts)
            % Remove ghosts (points > 150mm from center)
            centre=median(pts,1);
            pts=pts(vecnorm(pts-centre,2,2)<150,:);
            
            if size(pts,1)<6
                % If a marker is missing, assume fingers are touching/merged
                dist_geom=0.00;
            else
                % Fingertips have the smallest X
                [~,sort_X]=sort(pts(:,1));
                doigt_1=pts(sort_X(1),:);
                doigt_2=pts(sort_X(2),:);
                
                dist_geom=norm(doigt_1-doigt_2);
                
                % Safety: If gap < 12mm, consider full contact
                if dist_geom<12.0,dist_geom=0.00;end
            end
        end
        
        if ~isnan(dist_geom),dist_geom_all=[dist_geom_all;dist_geom];end
    end
    %MEDIAN RESULTS
    res_geom=0.00;status="Closed/Contact";
    if ~isempty(dist_geom_all)
        res_geom=median(dist_geom_all);
        if res_geom>5.0,status="Open";end
    end
    fprintf('%-15s | %6.2f mm      | %-15s\n',nom_f,res_geom,status);
end
