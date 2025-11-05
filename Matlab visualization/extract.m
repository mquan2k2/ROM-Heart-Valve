folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\unzipped\';

for g = 1:100
    outer = 200*g;
    outerStr = sprintf('%07d', outer);

    blocks = cell(169,1);
    for i = 0:168
        innerStr = sprintf('%04d', i);
        filePath = fullfile(folder, ['q_' outerStr '.' innerStr]);

        fid = fopen(filePath, 'r');

        C = textscan(fid, '%f%f%f%f%f%f%*[^\n]', ...
            'HeaderLines', 2, 'MultipleDelimsAsOne', true);
        fclose(fid);
        blocks{i+1} = [C{1},C{2},C{3},C{4},C{5},C{6}];
    end

    M = vertcat(blocks{:});
    [M_unique,~,~] = unique(M,'rows','stable');
    M_unique = sortrows(M_unique,[1 2 3]);
    snapshot = [M_unique(:,4);M_unique(:,5);M_unique(:,6)];

    idstr = sprintf('%d', g);
    outFile = fullfile('C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots', ...
                   ['Valve_0.5mm_Snapshot_' idstr '.txt']);
    writematrix(snapshot, outFile);


    if(g == 100)
        coords = M_unique(:,1:3);
        outFile = fullfile('C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots', ...
                   'coords.txt');
        writematrix(coords, outFile);
    end
end

