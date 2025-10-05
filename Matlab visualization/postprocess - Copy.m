 n = 7004448;
times = [10, 15, 20, 25];
folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots\';

for k = 1:numel(times)
    t = times(k);


    figure('Name',sprintf('Snapshot %d',t),'NumberTitle','off');

    c = readmatrix(fullfile(folder, 'coords.txt'));
    fname = sprintf('Valve_0.5mm_Snapshot_%04d.txt', t);
    Vfield = readmatrix(fullfile(folder, fname));

    vx = Vfield(1:n,1);
    vy = Vfield(n+1:2*n,1);
    vz = Vfield(2*n+1:3*n,1);

    x = unique(c(:,1));  nx = numel(x);
    y = unique(c(:,2));  ny = numel(y);
    z = unique(c(:,3));  nz = numel(z);

    [~,ix] = ismember(c(:,1), x);
    [~,iy] = ismember(c(:,2), y);
    [~,iz] = ismember(c(:,3), z);
    lin = sub2ind([ny,nx,nz], iy, ix, iz);

    Vx = nan(ny,nx,nz); Vy = Vx; Vz = Vx;
    Vx(lin) = vx; Vy(lin) = vy; Vz(lin) = vz;

    [X,Y,Z] = meshgrid(x, y, z);
    [curlx, curly, curlz, ~] = curl(X, Y, Z, Vx, Vy, Vz);


    omegaMag = curlx;
    isoLevel = 1.8;

    hold on;

    p = patch(isosurface(X, Y, Z, omegaMag,  isoLevel));
    isonormals(X, Y, Z, omegaMag, p);
    set(p, 'FaceColor','red','EdgeColor','none');

    q = patch(isosurface(X, Y, Z, omegaMag, -isoLevel));
    isonormals(X, Y, Z, omegaMag, q);
    set(q, 'FaceColor','blue','EdgeColor','none');

    daspect([1 1 1]); box on; axis vis3d;
    camlight headlight; lighting gouraud;

    axis([-1 9 -1.5 1.5 -1.5 1.5]);
    view(315, 20);
    title(sprintf('Snapshot %d', t));

    hold off;
end
