folder = 'D:\LAB\FlowField0.5\unzipped\';
maxNodes = 57888;
active_flag = zeros(169, maxNodes);

% time steps
for g = 0:99
    outer = 200 + g * 200;
    outerStr = sprintf('%07d', outer);

    % cpu cores
    for i = 0:168
        innerStr = sprintf('%04d', i);
        filename = ['q_' outerStr '.' innerStr];
        filePath = fullfile(folder, filename);

        if ~isfile(filePath)
            warning('Missing file: %s', filePath);
            continue;
        end

        fid = fopen(filePath, 'r');
        fgetl(fid); fgetl(fid);  % skip the first two headers
        data = textscan(fid, repmat('%f', 1, 16), 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
        fclose(fid);


        u = data{4};
        v = data{5};
        w = data{6};


        nonzero = (abs(u) > 1e-12) | (abs(v) > 1e-12) | (abs(w) > 1e-12);

        
        active_flag(i+1, 1:length(nonzero)) = active_flag(i+1, 1:length(nonzero)) | nonzero';
    end
end


writematrix(active_flag, fullfile('D:\LAB\FlowField0.5\', 'active_nodes.txt'));
