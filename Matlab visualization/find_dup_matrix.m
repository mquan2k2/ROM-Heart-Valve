maxNodes = 57888;
flag = zeros(169, maxNodes);        % 0 = unique, 1 = duplicate
xyz = zeros(169, maxNodes, 3);
coord_map = containers.Map();

folder = 'D:\LAB\FlowField0.5\unzipped\';

outerStr = '0000800';

for i = 0:168
    innerStr = sprintf('%04d', i);
    filename = ['q_' outerStr '.' innerStr];
    filePath = fullfile(folder, filename);

    fid = fopen(filePath, 'r');
    fgetl(fid); fgetl(fid);
    data = textscan(fid, repmat('%f', 1, 16), 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    fclose(fid);

    coords = [data{1}, data{2}, data{3}];  % n × 3
    xyz(i+1, 1:size(coords,1), :) = coords;

    for j = 1:size(coords,1)
        key = sprintf('%.8f_%.8f_%.8f', coords(j,1), coords(j,2), coords(j,3));
        if isKey(coord_map, key)
            flag(i+1, j) = 1;
        else
            coord_map(key) = true;
            flag(i+1, j) = 0;
        end
    end
end



writematrix(flag, fullfile('D:\LAB\FlowField0.5\', 'duplicate_flag.txt'));
